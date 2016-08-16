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

#import "FirebaseInvites.h"
#import "Functions/InitFunction.h"
#import "Functions/ShowInvitationDialogFunction.h"
#import "Functions/IsSupportedFunction.h"

static BOOL FirebaseInvitesLogEnabled = NO;
FREContext FirebaseInvitesExtContext = nil;
static FirebaseInvites* FirebaseInvitesSharedInstance = nil;

@implementation FirebaseInvites

@synthesize helper;

+ (id) sharedInstance {
    if( FirebaseInvitesSharedInstance == nil ) {
        FirebaseInvitesSharedInstance = [[FirebaseInvites alloc] init];
    }
    return FirebaseInvitesSharedInstance;
}

+ (void) dispatchEvent:(const NSString*) eventName {
    [self dispatchEvent:eventName withMessage:@""];
}

+ (void) dispatchEvent:(const NSString*) eventName withMessage:(NSString*) message {
    NSString* messageText = message ? message : @"";
    FREDispatchStatusEventAsync( FirebaseInvitesExtContext, (const uint8_t*) [eventName UTF8String], (const uint8_t*) [messageText UTF8String] );
}

+ (void) log:(const NSString*) message {
    if( FirebaseInvitesLogEnabled ) {
        NSLog( @"[iOS-FirebaseInvites] %@", message );
    }
}

+ (void) showLogs:(BOOL) showLogs {
    FirebaseInvitesLogEnabled = showLogs;
}

@end

/**
 *
 *
 * Context initialization
 *
 *
 **/

FRENamedFunction airFirebaseInvitesExtFunctions[] = {
    { (const uint8_t*) "init",                 0, fbinv_init },
    { (const uint8_t*) "showInvitationDialog", 0, fbinv_showInvitationDialog },
    { (const uint8_t*) "isSupported",          0, fbinv_isSupported }
};

void FirebaseInvitesContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet ) {
    *numFunctionsToSet = sizeof( airFirebaseInvitesExtFunctions ) / sizeof( FRENamedFunction );
    
    *functionsToSet = airFirebaseInvitesExtFunctions;
    
    FirebaseInvitesExtContext = ctx;
}

void FirebaseInvitesContextFinalizer( FREContext ctx ) { }

void FirebaseInvitesInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &FirebaseInvitesContextInitializer;
    *ctxFinalizerToSet = &FirebaseInvitesContextFinalizer;
}

void FirebaseInvitesFinalizer( void* extData ) { }







