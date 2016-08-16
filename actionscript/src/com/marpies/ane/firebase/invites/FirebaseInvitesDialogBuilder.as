package com.marpies.ane.firebase.invites {

    /**
     * Builder to create Firebase invite dialogs. It should not be instantiated manually,
     * use FirebaseInvites.dialog to access the builder.
     */
    public class FirebaseInvitesDialogBuilder {

        /* Singleton stuff */
        private static var mCanInitialize:Boolean;
        private static var mInstance:FirebaseInvitesDialogBuilder;

        private var mDialog:FirebaseInvitesDialog;

        /**
         * @private
         */
        public function FirebaseInvitesDialogBuilder() {
            if( !mCanInitialize ) throw new Error( "FirebaseInvitesDialogBuilder cannot be used directly. Access it using FirebaseInvites.dialog." );
        }

        /**
         * @private
         */
        internal static function get instance():FirebaseInvitesDialogBuilder {
            if( !mInstance ) {
                mCanInitialize = true;
                mInstance = new FirebaseInvitesDialogBuilder();
                mCanInitialize = false;
            }
            return mInstance;
        }

        /**
         * Initializes builder for new dialog.
         */
        internal function init():FirebaseInvitesDialogBuilder {
            mDialog = new FirebaseInvitesDialog();
            return this;
        }

        /**
         * Sets title for the dialog.
         */
        public function setTitle( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mTitle = value;
            return this;
        }

        /**
         * Sets the invite message. It can be edited by the sender.
         */
        public function setMessage( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mMessage = value;
            return this;
        }

        /**
         * The deep link that is made available to the app when opened from the invitation.
         */
        public function setDeepLink( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mDeepLink = value;
            return this;
        }

        /**
         * URL of custom image for invitations. This must not be set if <code>setEmailHtmlContent</code> is set.
         *
         * <p>It can be a network url with scheme <code>http</code> (on Android) or <code>https</code> (on iOS and Android).
         * The supported image formats are <code>jpg</code>, <code>jpeg</code> and <code>png</code>.</p>
         */
        public function setCustomImageURL( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mImageURL = value;
            return this;
        }

        /**
         * <strong>Android only</strong> - HTML-formatted (UTF-8 encoded, no JavaScript) content for invites sent through email.
         * If set, this will be sent instead of the default email. This must be set along with <code>setEmailSubject</code>.
         */
        public function setEmailHtmlContent( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mEmailHtmlContent = value;
            return this;
        }

        /**
         * <strong>Android only</strong> - The subject for invites sent by email. This must be set along with <code>setEmailHtmlContent</code>.
         */
        public function setEmailSubject( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mEmailSubject = value;
            return this;
        }

        /**
         * Text shown on the email invitation for the user to accept the invitation.
         * Default install text used if not set. This must not be set if <code>setEmailHtmlContent</code> is used.
         */
        public function setCallToActionText( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mCallToActionText = value;
            return this;
        }

        /**
         * <strong>Android only</strong> - Sets the Google Analytics Tracking id. The tracking id should be created for the calling application
         * under Google Analytics. The tracking id is recommended so that invitations sent from the calling
         * application are available in Google Analytics.
         */
        public function setGoogleAnalyticsTrackingId( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mGoogleAnalyticsTrackingId = value;
            return this;
        }

        /**
         * Sets different application to be targeted by this invitation. Setting the target client ID
         * for the invitation ensures that it goes to the correct app.
         */
        public function setTargetIOSClientId( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mTargetIOSClientId = value;
            return this;
        }

        /**
         * Sets different application to be targeted by this invitation. Setting the target client ID
         * for the invitation ensures that it goes to the correct app.
         */
        public function setTargetAndroidClientId( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mTargetAndroidClientId = value;
            return this;
        }

        /**
         * <strong>iOS only</strong> - Sets the app description displayed in email invitations.
         */
        public function setAppDescription( value:String ):FirebaseInvitesDialogBuilder {
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );
            mDialog.mAppDescription = value;
            return this;
        }

        /**
         * Function that is called when the invite is successfully sent.
         *
         * @param responseCallback The callback is expected to have this signature:
         * <listing version="3.0">
         * function onInviteSuccess( invitationIds:Vector.&lt;String&gt; ):void { }
         * </listing>
         */
        public function setSuccessCallback( responseCallback:Function ):FirebaseInvitesDialogBuilder {
            if( responseCallback === null ) throw new ArgumentError( "Parameter responseCallback cannot be null." );
            mDialog.mSuccessCallback = responseCallback;
            return this;
        }

        /**
         * Function that is called when the invite fails to be sent, or the dialog is cancelled by the user.
         *
         * @param errorCallback The callback is expected to have this signature:
         * <listing version="3.0">
         * function onInviteError( errorMessage:String ):void {
         *     // errorMessage may contain the reason of the failure
         * }
         * </listing>
         */
        public function setErrorCallback( errorCallback:Function ):FirebaseInvitesDialogBuilder {
            if( errorCallback === null ) throw new ArgumentError( "Parameter errorCallback cannot be null." );
            mDialog.mErrorCallback = errorCallback;
            return this;
        }

        /**
         * Opens native UI with the invitation dialog.
         *
         * <p>To open the dialog successfully on iOS, user must be signed in into your app with his Google
         * account and you must have the App Store ID set in your developer console project.</p>
         */
        public function open():void {
            if( mDialog.mTitle === null ) throw new Error( "Dialog title must be specified." );

            FirebaseInvites.openDialogInternal( mDialog );
        }

    }

}
