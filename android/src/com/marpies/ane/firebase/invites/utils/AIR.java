/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.marpies.ane.firebase.invites.utils;

import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.util.Log;
import com.marpies.ane.firebase.invites.FirebaseInviteActivity;
import com.marpies.ane.firebase.invites.FirebaseInvitesExtensionContext;

public class AIR {

	private static final String TAG = "FirebaseInvites";
	private static boolean mLogEnabled = true;

	private static FirebaseInvitesExtensionContext mContext;

	public static void log( String message ) {
		if( mLogEnabled ) {
			Log.i( TAG, message );
		}
	}

	public static void dispatchEvent( String eventName, String message ) {
		mContext.dispatchStatusEventAsync( eventName, message );
	}

	public static void startFirebaseInvitesActivity() {
		if( !FirebaseInviteActivity.isRunning ) {
			AIR.log( "FirebaseInvites | FirebaseInviteActivity is not running, firing up!" );
			startActivity( FirebaseInviteActivity.class );
		} else {
			AIR.log( "FirebaseInvites | FirebaseInviteActivity is already running!" );
		}
	}

	private static void startActivity( Class<?> activityClass ) {
		Intent intent = new Intent( mContext.getActivity().getApplicationContext(), activityClass );
		ResolveInfo info = mContext.getActivity().getPackageManager().resolveActivity( intent, 0 );
		if( info == null ) {
			log( "Activity " + activityClass.getSimpleName() + " could not be started. Make sure you specified the activity in the android manifest." );
			return;
		}
		mContext.getActivity().startActivity( intent );
	}

	/**
	 *
	 *
	 * Getters / Setters
	 *
	 *
	 */

	public static FirebaseInvitesExtensionContext getContext() {
		return mContext;
	}

	public static void setContext( FirebaseInvitesExtensionContext context ) {
		mContext = context;
	}

	public static void setLogEnabled( boolean value ) {
		mLogEnabled = value;
	}

}
