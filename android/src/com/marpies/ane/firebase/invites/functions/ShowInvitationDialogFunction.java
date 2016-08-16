/*
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

package com.marpies.ane.firebase.invites.functions;

import android.content.Intent;
import android.net.Uri;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.IActivityResultCallback;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.google.android.gms.appinvite.AppInviteInvitation;
import com.marpies.ane.firebase.invites.data.FirebaseInvitesEvent;
import com.marpies.ane.firebase.invites.utils.AIR;
import com.marpies.ane.firebase.invites.utils.FREObjectUtils;
import org.json.JSONArray;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;

public class ShowInvitationDialogFunction extends BaseFunction implements IActivityResultCallback {

	private static final int REQUEST_INVITE = 19973;

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		String title = FREObjectUtils.getString( args[0] );
		String message = (args[1] != null) ? FREObjectUtils.getString( args[1] ) : null;
		String deepLink = (args[2] != null) ? FREObjectUtils.getString( args[2] ) : null;
		String imageURL = (args[3] != null) ? FREObjectUtils.getString( args[3] ) : null;
		String callToActionText = (args[4] != null) ? FREObjectUtils.getString( args[4] ) : null;
		String emailHtmlContent = (args[5] != null) ? FREObjectUtils.getString( args[5] ) : null;
		String emailSubject = (args[6] != null) ? FREObjectUtils.getString( args[6] ) : null;
		String googleAnalyticsTrackingId = (args[7] != null) ? FREObjectUtils.getString( args[7] ) : null;
		String targetAndroidClientId = (args[8] != null) ? FREObjectUtils.getString( args[8] ) : null;
		String targetIOSClientId = (args[9] != null) ? FREObjectUtils.getString( args[9] ) : null;

		AppInviteInvitation.IntentBuilder inviteBuilder = new AppInviteInvitation.IntentBuilder( title );
		Intent inviteIntent;
		if( message != null ) {
			inviteBuilder.setMessage( message );
		}
		if( deepLink != null ) {
			inviteBuilder.setDeepLink( Uri.parse( deepLink ) );
		}
		if( imageURL != null ) {
			inviteBuilder.setCustomImage( Uri.parse( imageURL ) );
		}
		if( callToActionText != null ) {
			inviteBuilder.setCallToActionText( callToActionText );
		}
		if( emailHtmlContent != null ) {
			inviteBuilder.setEmailHtmlContent( emailHtmlContent );
		}
		if( emailSubject != null ) {
			inviteBuilder.setEmailSubject( emailSubject );
		}
		if( googleAnalyticsTrackingId != null ) {
			inviteBuilder.setGoogleAnalyticsTrackingId( googleAnalyticsTrackingId );
		}
		try {
			inviteIntent = inviteBuilder.build();
			AIR.log( "Invite intent built, opening dialog..." );
			AndroidActivityWrapper.GetAndroidActivityWrapper().addActivityResultListener( this );
			AIR.getContext().getActivity().startActivityForResult( inviteIntent, REQUEST_INVITE );
		} catch( Exception e ) {
			/* Incorrect dialog data */
			AIR.log( "Invite intent creation failed: " + e.getLocalizedMessage() );
			AIR.dispatchEvent( FirebaseInvitesEvent.INVITE_ERROR, e.getLocalizedMessage() );
		}

		return null;
	}

	public void onActivityResult( int requestCode, int resultCode, Intent data ) {
		AIR.log( "AppInviteDialog | result reqCode: " + requestCode );
		if( requestCode == REQUEST_INVITE ) {
			AndroidActivityWrapper.GetAndroidActivityWrapper().removeActivityResultListener( this );
			if( resultCode == RESULT_OK ) {
				String[] ids = AppInviteInvitation.getInvitationIds( resultCode, data );
				JSONArray response = new JSONArray();
				for( String id : ids ) {
					response.put( id );
					AIR.log( "FirebaseInviteActivity::onActivityResult: sent invitation " + id );
				}
				AIR.dispatchEvent( FirebaseInvitesEvent.INVITE_SUCCESS, response.toString() );
			} else {
				String errorMessage = (resultCode == RESULT_CANCELED) ? "Operation was canceled by the user." : "There was an error sending the invitation";
				AIR.log( "FirebaseInviteActivity::onActivityResult error: " + errorMessage );
				AIR.dispatchEvent( FirebaseInvitesEvent.INVITE_ERROR, errorMessage );
			}
		}
	}

}

