/**
 * https://forums.adobe.com/thread/1424424
 */

package com.marpies.ane.firebase.invites;

import android.content.res.Configuration;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.IActivityStateChangeCallback;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.marpies.ane.firebase.invites.functions.InitFunction;
import com.marpies.ane.firebase.invites.functions.IsSupportedFunction;
import com.marpies.ane.firebase.invites.functions.ShowInvitationDialogFunction;
import com.marpies.ane.firebase.invites.utils.AIR;

import java.util.HashMap;
import java.util.Map;

public class FirebaseInvitesExtensionContext extends FREContext implements IActivityStateChangeCallback {

	private AndroidActivityWrapper mActivityWrapper;

	public FirebaseInvitesExtensionContext() {
		mActivityWrapper = AndroidActivityWrapper.GetAndroidActivityWrapper();
		mActivityWrapper.addActivityStateChangeListner( this );
	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();

		functions.put( "init", new InitFunction() );
		functions.put( "showInvitationDialog", new ShowInvitationDialogFunction() );
		functions.put( "isSupported", new IsSupportedFunction() );

		return functions;
	}

	@Override
	public void dispose() {
		AIR.setContext( null );

		if( mActivityWrapper != null ) {
			mActivityWrapper.removeActivityStateChangeListner( this );
			mActivityWrapper = null;
		}
	}

	@Override
	public void onActivityStateChanged( AndroidActivityWrapper.ActivityState activityState ) {
		AIR.log( "FirebaseInvitesExtensionContext::onActivityStateChanged " + activityState.toString() );
		if( activityState == AndroidActivityWrapper.ActivityState.RESUMED ) {
			if( !FirebaseInviteActivity.isRunning ) {
				AIR.startFirebaseInvitesActivity();
			}
		}
	}

	@Override
	public void onConfigurationChanged( Configuration configuration ) {
	}

}
