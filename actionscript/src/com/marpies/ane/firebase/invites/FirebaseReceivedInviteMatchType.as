package com.marpies.ane.firebase.invites {

    /**
     * An enum that represents the match type of an invitation.
     */
    public class FirebaseReceivedInviteMatchType {

        /**
         * The match between the deep link and this device may not be perfect,
         * hence you should not reveal any personal information related to the deep link.
         */
        public static const WEAK:String = "weak";

        /**
         * The match between the deep link and this device is exact,
         * hence you could reveal any personal information related to the deep link.
         */
        public static const STRONG:String = "strong";

    }

}
