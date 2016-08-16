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

package com.marpies.ane.firebase.invites;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentActivity;
import com.google.android.gms.appinvite.AppInvite;
import com.google.android.gms.appinvite.AppInviteInvitationResult;
import com.google.android.gms.appinvite.AppInviteReferral;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.marpies.ane.firebase.invites.data.FirebaseInvitesEvent;
import com.marpies.ane.firebase.invites.utils.AIR;

public class FirebaseInviteActivity extends FragmentActivity implements GoogleApiClient.OnConnectionFailedListener {

	public static boolean isRunning = false;

	private GoogleApiClient mGoogleApiClient;

	@Override
	protected void onCreate( Bundle savedInstanceState ) {
		super.onCreate( savedInstanceState );

		isRunning = true;

		AIR.log( "FirebaseInviteActivity::onCreate" );

		/* Create auto managed GoogleApiClient for this activity */
		mGoogleApiClient = new GoogleApiClient.Builder( this )
				.enableAutoManage( this, this )
				.addApi( AppInvite.API )
				.build();

		/* Attempt to get the invitation and deep link */
		AppInvite.AppInviteApi.getInvitation( mGoogleApiClient, this, false )
				.setResultCallback(
						new ResultCallback<AppInviteInvitationResult>() {
							@Override
							public void onResult( @NonNull AppInviteInvitationResult result ) {
								if( result.getStatus().isSuccess() ) {
									Intent intent = result.getInvitationIntent();
									String invitationId = AppInviteReferral.getInvitationId( intent );
									String deepLink = AppInviteReferral.getDeepLink( intent );

									AIR.log( "Invitation id: " + invitationId );
									AIR.log( "Deep Link found: " + deepLink );

									if( invitationId == null || invitationId.equals( "" ) ) {
										invitationId = "-1";
									}

									AIR.dispatchEvent( FirebaseInvitesEvent.INVITATION_RECEIVE, String.format(
											"{ \"invitationId\": \"%s\", \"deepLink\": \"%s\", \"matchType\": \"strong\" }",
											invitationId, deepLink
									) );
								} else {
									AIR.log( "getInvitation: no deep link found." );
								}
								AIR.log( "FirebaseInviteActivity | finishing..." );
								finish();
							}
						} );
	}

	@Override
	public void onBackPressed() {
		finish();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		AIR.log( "FirebaseInviteActivity::onDestroy" );
		mGoogleApiClient = null;
		isRunning = false;
	}

	/**
	 * GoogleApiClient callback
	 */

	@Override
	public void onConnectionFailed( @NonNull ConnectionResult connectionResult ) {
		/* Unresolvable GoogleApiClient error occurred */
		AIR.log( "FirebaseInviteActivity | GoogleApiClient could not be created for Invites API." );
		finish();
	}

}