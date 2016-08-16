package com.marpies.ane.firebase.invites {

    /**
     * @private
     * VO representing invitation dialog. For internal use only.
     */
    public class FirebaseInvitesDialog {

        /**
         * @private
         */
        internal var mTitle:String;
        /**
         * @private
         */
        internal var mMessage:String;
        /**
         * @private
         */
        internal var mDeepLink:String;
        /**
         * @private
         */
        internal var mImageURL:String;
        /**
         * @private
         */
        internal var mEmailHtmlContent:String;
        /**
         * @private
         */
        internal var mEmailSubject:String;
        /**
         * @private
         */
        internal var mCallToActionText:String;
        /**
         * @private
         */
        internal var mGoogleAnalyticsTrackingId:String;
        /**
         * @private
         */
        internal var mTargetIOSClientId:String;
        /**
         * @private
         */
        internal var mAppDescription:String;
        /**
         * @private
         */
        internal var mTargetAndroidClientId:String;
        /**
         * @private
         */
        internal var mSuccessCallback:Function;
        /**
         * @private
         */
        internal var mErrorCallback:Function;

        /**
         * @private
         */
        public function FirebaseInvitesDialog() { }

    }

}
