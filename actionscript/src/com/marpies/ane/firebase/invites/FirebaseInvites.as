/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.marpies.ane.firebase.invites {

    import flash.events.StatusEvent;
    import flash.system.Capabilities;

    CONFIG::ane {
        import flash.external.ExtensionContext;
    }

    /**
     * Class providing API to receive and send Firebase invitations.
     */
    public class FirebaseInvites {

        private static const TAG:String = "[FirebaseInvites]";
        private static const EXTENSION_ID:String = "com.marpies.ane.firebase.invites";
        private static const iOS:Boolean = Capabilities.manufacturer.indexOf( "iOS" ) > -1;
        private static const ANDROID:Boolean = Capabilities.manufacturer.indexOf( "Android" ) > -1;

        CONFIG::ane {
            private static var mContext:ExtensionContext;
        }

        /* Event codes */
        private static const INVITE_SUCCESS:String = "inviteSuccess";
        private static const INVITE_ERROR:String = "inviteError";
        private static const INVITATION_RECEIVE:String = "invitationReceive";

        /* Internal */
        private static var mDialogBuilder:FirebaseInvitesDialogBuilder;

        /* Callbacks */
        private static var mDialogCallback:InviteDialogCallback;
        private static var mInvitationReceiveCallbacks:Vector.<Function> = new <Function>[];

        /* Misc */
        private static var mInitialized:Boolean;
        private static var mLogEnabled:Boolean;

        /**
         * @private
         * Do not use. FirebaseInvites is a static class.
         */
        public function FirebaseInvites() {
            throw Error( "FirebaseInvites is static class." );
        }

        /**
         *
         *
         * Public API
         *
         *
         */

        /**
         * Initializes extension context.
         *
         * @param showLogs Set to <code>true</code> to show extension log messages.
         *
         * @return <code>true</code> if the extension context was created, <code>false</code> otherwise
         */
        public static function init( showLogs:Boolean = false ):Boolean {
            if( !isSupportedPlatform || !isSupported ) return false;
            if( mInitialized ) return true;

            mLogEnabled = showLogs;

            /* Initialize context */
            if( !initExtensionContext() ) {
                log( "Error creating extension context for " + EXTENSION_ID );
                return false;
            }
            /* Listen for native library events */
            CONFIG::ane {
                mContext.addEventListener( StatusEvent.STATUS, onStatus );
            }

            mDialogCallback = new InviteDialogCallback();
            mDialogBuilder = FirebaseInvitesDialogBuilder.instance;
            if( mInvitationReceiveCallbacks === null ) {
                mInvitationReceiveCallbacks = new <Function>[];
            }

            /* Call init */
            CONFIG::ane {
                mContext.call( "init", showLogs );
            }

            mInitialized = true;
            return true;
        }

        /**
         * Adds callback that will be called when the app is launched from an invitation link.
         *
         * @param callback Function with the following signature:
         * <listing version="3.0">
         * function callback( invitation:FirebaseInvitation ):void { };
         * </listing>
         *
         * @see #removeInvitationReceivedCallback()
         */
        public static function addInvitationReceivedCallback( callback:Function ):void {
            if( !isSupportedPlatform || !isSupported ) return;

            if( callback === null ) throw new ArgumentError( "Parameter callback cannot be null." );
            if( mInvitationReceiveCallbacks === null ) throw new ArgumentError( "The extension was disposed." );

            if( mInvitationReceiveCallbacks.indexOf( callback ) < 0 ) {
                mInvitationReceiveCallbacks[mInvitationReceiveCallbacks.length] = callback;
            }
        }

        /**
         * Removes callback that was added earlier using <code>FirebaseInvites.addInvitationReceivedCallback</code>.
         *
         * @param callback Function to remove.
         *
         * @see #addInvitationReceivedCallback()
         */
        public static function removeInvitationReceivedCallback( callback:Function ):void {
            if( !isSupportedPlatform || !isSupported ) return;

            if( callback === null ) throw new ArgumentError( "Parameter callback cannot be null." );
            if( mInvitationReceiveCallbacks === null ) throw new ArgumentError( "The extension was disposed." );

            var index:int = mInvitationReceiveCallbacks.indexOf( callback );
            if( index >= 0 ) {
                mInvitationReceiveCallbacks.removeAt( index );
            }
        }

        /**
         * Disposes native extension context.
         */
        public static function dispose():void {
            if( !isSupportedPlatform ) return;
            validateExtensionContext();

            mDialogCallback = null;
            mDialogBuilder = null;

            CONFIG::ane {
                mContext.removeEventListener( StatusEvent.STATUS, onStatus );
                mContext.dispose();
                mContext = null;
            }

            mInitialized = false;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Getter for internal dialog builder used for creating and sending Firebase invitations.
         */
        public static function get dialog():FirebaseInvitesDialogBuilder {
            if( !isSupportedPlatform || !isSupported ) return null;
            validateExtensionContext();

            if( mDialogBuilder === null ) throw new Error( "Initialize the extension before sending invitations." );
            return mDialogBuilder.init();
        }

        /**
         * Extension version.
         */
        public static function get version():String {
            return "1.0.0";
        }

        /**
         * Supported on iOS 8+ and Android with Google Play Services app installed.
         */
        public static function get isSupported():Boolean {
            if( !initExtensionContext() ) return false;

            var result:Boolean;
            CONFIG::ane {
                result = mContext.call( "isSupported" ) as Boolean;
            }

            return result;
        }

        /**
         *
         *
         * Internal API
         *
         *
         */

        /**
         * @private
         */
        internal static function openDialogInternal( dialog:FirebaseInvitesDialog ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            CONFIG::ane {
                mDialogCallback.init( dialog.mSuccessCallback, dialog.mErrorCallback );
                mContext.call( "showInvitationDialog",
                                dialog.mTitle, dialog.mMessage, dialog.mDeepLink,
                                dialog.mImageURL, dialog.mCallToActionText, dialog.mEmailHtmlContent,
                                dialog.mEmailSubject, dialog.mGoogleAnalyticsTrackingId, dialog.mTargetAndroidClientId,
                                dialog.mTargetIOSClientId, dialog.mAppDescription );
            }
        }

        /**
         *
         *
         * Private API
         *
         *
         */

        private static function onStatus( event:StatusEvent ):void {
            switch( event.code ) {
                case INVITE_SUCCESS:
                    var invitationIdsArray:Array = JSON.parse( event.level ) as Array;
                    var invitationIds:Vector.<String> = (invitationIdsArray === null) ? null : Vector.<String>( invitationIdsArray );
                    mDialogCallback.triggerSuccess( invitationIds );
                    mDialogCallback.reset();
                    return;

                case INVITE_ERROR:
                    mDialogCallback.triggerError( event.level );
                    mDialogCallback.reset();
                    return;

                case INVITATION_RECEIVE:
                    var json:Object = JSON.parse( event.level );
                    var invitation:FirebaseInvitation = FirebaseInvitation.fromJSON( json );
                    var length:int = mInvitationReceiveCallbacks.length;
                    /* Create callbacks copy because a callback may be removed when triggered */
                    var tempCallbacks:Vector.<Function> = new <Function>[];
                    for( var i:int = 0; i < length; ++i ) {
                        tempCallbacks[i] = mInvitationReceiveCallbacks[i];
                    }
                    for( i = 0; i < length; ++i ) {
                        tempCallbacks[i]( invitation );
                    }
                    return;
            }
        }

        /**
         * Initializes extension context.
         * @return <code>true</code> if initialized successfully, <code>false</code> otherwise.
         */
        private static function initExtensionContext():Boolean {
            var result:Boolean;
            CONFIG::ane {
                if( mContext === null ) {
                    mContext = ExtensionContext.createExtensionContext( EXTENSION_ID, null );
                }
                result = mContext !== null;
            }
            return result;
        }

        private static function validateExtensionContext():void {
            CONFIG::ane {
                if( !mContext ) throw new Error( "FirebaseInvites extension was not initialized. Call init() first." );
            }
        }

        private static function log( message:String ):void {
            if( mLogEnabled ) {
                trace( TAG, message );
            }
        }

        private static function get isSupportedPlatform():Boolean {
            return iOS || ANDROID;
        }

    }
}

class InviteDialogCallback {

    private var mErrorCallback:Function;
    private var mSuccessCallback:Function;

    public function InviteDialogCallback():void {
    }

    internal function triggerSuccess( invitationIds:Vector.<String> ):void {
        if( mSuccessCallback !== null ) {
            mSuccessCallback( invitationIds );
        }
    }

    internal function triggerError( errorMessage:String ):void {
        if( mErrorCallback !== null ) {
            mErrorCallback( errorMessage );
        }
    }

    internal function init( successCallback:Function, errorCallback:Function ):void {
        mSuccessCallback = successCallback;
        mErrorCallback = errorCallback;
    }

    internal function reset():void {
        init( null, null );
    }

}