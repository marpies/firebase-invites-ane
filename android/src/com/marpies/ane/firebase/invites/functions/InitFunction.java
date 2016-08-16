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

package com.marpies.ane.firebase.invites.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.marpies.ane.firebase.invites.FirebaseInviteActivity;
import com.marpies.ane.firebase.invites.utils.AIR;
import com.marpies.ane.firebase.invites.utils.FREObjectUtils;

public class InitFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		AIR.setLogEnabled( FREObjectUtils.getBoolean( args[0] ) );
		AIR.log( "FirebaseInvites::init" );

		/* Check for invite on startup */
		AIR.startFirebaseInvitesActivity();

		return null;
	}

}
