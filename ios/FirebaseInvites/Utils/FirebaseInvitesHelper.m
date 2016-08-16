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

#import "FirebaseInvitesHelper.h"
#import "FirebaseInvites.h"
#import "FirebaseInvitesEvent.h"
#import "MPUserActivityDelegate.h"
#import <AIRExtHelpers/MPUIApplicationDelegate.h>
#import <FirebaseDynamicLinks/FirebaseDynamicLinks.h>

@implementation FirebaseInvitesHelper {
    id<FIRInviteBuilder> mInviteDialog;
    MPUserActivityDelegate* mUserActivityDelegate;
    NSString* mCurrentDynamicLink;
}

# pragma mark - Public API

- (id) init {
    self = [super init];
    
    if( self ) {
        [FirebaseInvites log:@"FirebaseInvitesHelper::init"];
        mCurrentDynamicLink = nil;
        NSDictionary* launchOptions = [MPUIApplicationDelegate launchOptions];
        /* Enable activity continuation on iOS 9+ */
        if( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4 ) {
            [self addContinuationListener];
            [self handleUniversalLinkLaunch:launchOptions];
        }
        /* Check if the app was launched from a Firebase invitation URL (iOS 8 and older) */
        else if( launchOptions != nil ) {
            /* Check if it contains UIApplicationLaunchOptionsURLKey */
            NSURL* launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
            if( launchURL != nil ) {
                [self checkFirebaseInvites:launchURL sourceApplication:launchOptions[UIApplicationLaunchOptionsSourceApplicationKey] annotation:@{}];
            }
        }
        [[MPUIApplicationDelegate sharedInstance] addListener:self];
    }
    
    return self;
}

- (void) openInvitationDialog:(FirebaseInviteDialogVO*) dialogVO {
    [FirebaseInvites log:@"FirebaseInvitesHelper::openInvitationDialog"];
    
    mInviteDialog = [FIRInvites inviteDialog];
    [mInviteDialog setInviteDelegate:self];
    [mInviteDialog setTitle:dialogVO.title];
    if( dialogVO.message != nil ) {
        [mInviteDialog setMessage:dialogVO.message];
    }
    if( dialogVO.deepLink != nil ) {
        [mInviteDialog setDeepLink:dialogVO.deepLink];
    }
    if( dialogVO.callToActionText != nil ) {
        [mInviteDialog setCallToActionText:dialogVO.callToActionText];
    }
    if( dialogVO.imageURL != nil ) {
        [mInviteDialog setCustomImage:dialogVO.imageURL];
    }
    if( dialogVO.appDescription != nil ) {
        [mInviteDialog setDescription:dialogVO.appDescription];
    }
    if( dialogVO.targetAndroidClientId != nil ) {
        FIRInvitesTargetApplication* targetApp = [[FIRInvitesTargetApplication alloc] init];
        targetApp.androidClientID = dialogVO.targetAndroidClientId;
        [mInviteDialog setOtherPlatformsTargetApplication:targetApp];
    }
    
    [mInviteDialog open];
}

# pragma mark - MPUIApplicationListener

- (BOOL)application:(nullable UIApplication *)application openURL:(nullable NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
    return [self checkFirebaseInvites:url sourceApplication:sourceApplication annotation:annotation];
}

# pragma mark - MPUserActivityListener

- (BOOL) application:(nullable UIApplication *)application continueUserActivity:(nullable NSUserActivity *)userActivity restorationHandler:(nullable void (^)(NSArray* _Nullable))restorationHandler {
    [FirebaseInvites log:@"FirebaseInvitesHelper | application continueUserActivity"];
    if( userActivity != nil ) {
        [FirebaseInvites log:@"Checking invite in userActivity webpage URL"];
        return [self handleIncomingWebpageURL:userActivity.webpageURL];
    }
    return NO;
}

# pragma mark - FIRInviteDelegate

- (void)inviteFinishedWithInvitations:(NSArray *)invitationIds error:(nullable NSError *)error {
    [FirebaseInvites log:@"FirebaseInvitesHelper inviteFinishedWithInvitations"];
    if( error == nil ) {
        NSString* jsonArray = [self getJSONArray:invitationIds];
        [FirebaseInvites log:[NSString stringWithFormat:@"Invitation ids: %@", invitationIds]];
        [FirebaseInvites dispatchEvent:INVITE_SUCCESS withMessage:jsonArray];
    } else {
        [FirebaseInvites log:[NSString stringWithFormat:@"Error sending invitations: %@", error.localizedDescription]];
        [FirebaseInvites dispatchEvent:INVITE_ERROR withMessage:error.localizedDescription];
    }
    mInviteDialog = nil;
}

# pragma mark - Private API

- (BOOL) checkFirebaseInvites:(nullable NSURL*) url sourceApplication:(nullable NSString*) sourceApplication annotation:(nullable id)annotation {
    [FirebaseInvites log:[NSString stringWithFormat:@"FirebaseInvitesHelper | checking invite for URL: %@", url]];
    FIRReceivedInvite *invite = [FIRInvites handleURL:url sourceApplication:sourceApplication annotation:annotation];
    if( invite != nil ) {
        NSString* matchType = (invite.matchType == FIRReceivedInviteMatchTypeWeak) ? @"weak" : @"strong";
        [FirebaseInvites log:[NSString stringWithFormat:@"FirebaseInvitesHelper | got invite id: %@ | link: %@ | matchType: %@", invite.inviteId, invite.deepLink, matchType]];
        [self dispatchInvitation:invite.inviteId deepLink:invite.deepLink matchType:matchType];
        return YES;
    }
    return NO;
}

- (void) handleUniversalLinkLaunch:(NSDictionary*) launchOptions {
    /* (iOS 9+) Handle Universal link on launch, if there is any */
    if( launchOptions != nil ) {
        NSDictionary* userActivityDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
        if( userActivityDictionary != nil ) {
            // To avoid using undocumented keys, we use enumerateKeysAndObjectsUsingBlock:
            [userActivityDictionary enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL* _Nonnull stop) {
                if( [obj isKindOfClass:[NSUserActivity class]] ) {
                    NSUserActivity* userActivity = obj;
                    [self handleIncomingWebpageURL:userActivity.webpageURL];
                    *stop = YES;
                }
            }];
        }
    }
}

- (BOOL) handleIncomingWebpageURL:(nullable NSURL*) webpageURL {
    [FirebaseInvites log:[NSString stringWithFormat:@"User activity link: %@", webpageURL]];
    if( webpageURL != nil ) {
        /* Check if the dynamic link is not being processed already (may happen on
         * app launch when the app is backgrounded by OS after long inactive period) */
        if( mCurrentDynamicLink != nil && [mCurrentDynamicLink isEqualToString:webpageURL.absoluteString] ) {
            [FirebaseInvites log:[NSString stringWithFormat:@"Already processing link: %@", mCurrentDynamicLink]];
            return YES;
        }
        
        mCurrentDynamicLink = webpageURL.absoluteString;
        BOOL linkHandled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:webpageURL completion:^(FIRDynamicLink * _Nullable dynamicLink, NSError * _Nullable error) {
            mCurrentDynamicLink = nil;
            if( dynamicLink != nil ) {
                /* Try to get invitation id from the URL */
                NSString* invitationId = nil;
                NSString* urlString = webpageURL.absoluteString;
                if( [urlString containsString:@"app.goo.gl/i/"] ) {
                    invitationId = [urlString lastPathComponent];
                    [FirebaseInvites log:[NSString stringWithFormat:@"Manual inv id from dynamic link: %@", invitationId]];
                }
                [FirebaseInvites log:[NSString stringWithFormat:@"FirebaseInvitesHelper | found dynamicLink: %@", dynamicLink.url]];
                /* Dispatch the invitation if invitation id was found */
                if( invitationId != nil && dynamicLink.url != nil ) {
                    NSString* matchType = (dynamicLink.matchConfidence == FIRDynamicLinkMatchConfidenceWeak) ? @"weak" : @"strong";
                    [self dispatchInvitation:invitationId deepLink:dynamicLink.url.absoluteString matchType:matchType];
                }
            }
            if( error != nil ) {
                [FirebaseInvites log:[NSString stringWithFormat:@"FirebaseInvitesHelper | dynamicLink error: %@", error.localizedDescription]];
            }
        }];
        if( !linkHandled ) {
            mCurrentDynamicLink = nil;
        }
        return linkHandled;
    }
    return NO;
}

- (void) dispatchInvitation:(NSString*) invitationId deepLink:(NSString*) deepLink matchType:(NSString*) matchType {
    [FirebaseInvites dispatchEvent:INVITATION_RECEIVE
                       withMessage:[NSString stringWithFormat:@"{ \"invitationId\": \"%@\", \"deepLink\": \"%@\", \"matchType\": \"%@\" }", invitationId, deepLink, matchType]];
}

- (void) addContinuationListener {
    mUserActivityDelegate = [[MPUserActivityDelegate alloc] init];
    [mUserActivityDelegate setListener:self];
}

- (NSString*) getJSONArray:(NSArray*) array {
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    if( !jsonData ) {
        return @"[{ \"error\": \"Error serializing NSArray into JSON.\"}]";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
