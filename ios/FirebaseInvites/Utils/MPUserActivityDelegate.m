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

#import "MPUserActivityDelegate.h"
#import <objc/runtime.h>

static MPUserActivityDelegate* airMPUserActivityDelegate = nil;
NSObject<MPUserActivityListener>* airMPUserActivityListener;

@implementation MPUserActivityDelegate

+ (id) sharedInstance {
    if( airMPUserActivityDelegate == nil ) {
        airMPUserActivityDelegate = [[MPUserActivityDelegate alloc] init];
    }
    return airMPUserActivityDelegate;
}

- (id) init {
    self = [super init];
    
    if( self != nil ) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id delegate = [[UIApplication sharedApplication] delegate];
            if( delegate == nil ) return;
            
            Class adobeDelegateClass = object_getClass( delegate );
            
            SEL delegateSelector = @selector(application:continueUserActivity:restorationHandler:);
            [self overrideDelegate:adobeDelegateClass method:delegateSelector withMethod:@selector(mpair_application:continueUserActivity:restorationHandler:)];
        });
    }
    
    return self;
}

- (void) setListener:(NSObject<MPUserActivityListener>*) listener {
    airMPUserActivityListener = listener;
}

- (void) removeListener {
    airMPUserActivityListener = nil;
}

# pragma mark - Private API

- (BOOL)mpair_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    BOOL result = NO;
    if( airMPUserActivityListener != nil ) {
        result = [airMPUserActivityListener application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }
    if( [self respondsToSelector:@selector(mpair_application:continueUserActivity:restorationHandler:)] ) {
        return [self mpair_application:application continueUserActivity:userActivity restorationHandler:restorationHandler] || result;
    }
    return result;
}

- (BOOL) overrideDelegate:(Class) delegateClass method:(SEL) delegateSelector withMethod:(SEL) swizzledSelector {
    Method originalMethod = class_getInstanceMethod(delegateClass, delegateSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(delegateClass,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
    
    if (didAddMethod) {
        class_replaceMethod(delegateClass,
                            delegateSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return didAddMethod;
}


@end
