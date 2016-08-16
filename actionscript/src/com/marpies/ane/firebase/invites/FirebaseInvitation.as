package com.marpies.ane.firebase.invites {

    /**
     * Class representing Firebase invitation. Provides access to the invitation id and deep link.
     */
    public class FirebaseInvitation {

        private var mId:String;
        private var mDeepLink:String;
        private var mMatchType:String;

        /**
         * @private
         */
        public function FirebaseInvitation() {
        }

        /**
         * @private
         */
        internal static function fromJSON( json:Object ):FirebaseInvitation {
            var invitation:FirebaseInvitation = new FirebaseInvitation();
            invitation.mId = json.invitationId;
            invitation.mDeepLink = json.deepLink;
            invitation.mMatchType = json.matchType;
            return invitation;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Returns invitation id.
         */
        public function get id():String {
            return mId;
        }

        /**
         * Returns deep link from an invitation if the deep link was set when the invitation was created.
         */
        public function get deepLink():String {
            return mDeepLink;
        }

        /**
         * Returns the match type of the received invitation.
         *
         * @see com.marpies.ane.firebase.invites.FirebaseReceivedInviteMatchType
         */
        public function get matchType():String {
            return mMatchType;
        }

    }

}
