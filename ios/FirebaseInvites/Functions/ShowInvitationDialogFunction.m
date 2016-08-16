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

#import "ShowInvitationDialogFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import "FirebaseInvites.h"
#import "FirebaseInviteDialogVO.h"

FREObject fbinv_showInvitationDialog( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [FirebaseInvites log:@"FirebaseInvites::fbinv_showInvitationDialog"];
    
    FirebaseInviteDialogVO* dialogVO = [[FirebaseInviteDialogVO alloc] init];
    dialogVO.title = [MPFREObjectUtils getNSString:argv[0]];
    dialogVO.message = (argv[1] != nil) ? [MPFREObjectUtils getNSString:argv[1]] : nil;
    dialogVO.deepLink = (argv[2] != nil) ? [MPFREObjectUtils getNSString:argv[2]] : nil;
    dialogVO.imageURL = (argv[3] != nil) ? [MPFREObjectUtils getNSString:argv[3]] : nil;
    dialogVO.callToActionText = (argv[4] != nil) ? [MPFREObjectUtils getNSString:argv[4]] : nil;
    dialogVO.targetAndroidClientId = (argv[8] != nil) ? [MPFREObjectUtils getNSString:argv[8]] : nil;
    dialogVO.appDescription = (argv[10] != nil) ? [MPFREObjectUtils getNSString:argv[10]] : nil;
    
    [[[FirebaseInvites sharedInstance] helper] openInvitationDialog:dialogVO];
    
    return nil;
}