//
//  LaunchTask+UIKit.h
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

@import UIKit;

#import "LaunchTask.h"

#define LTStoryboard UIStoryboard

#define LTMainStoryboardFileKey @"UIMainStoryboardFile"

#define LTAppDelegate UIApplicationDelegate

#define LTAppDelegateUserCodeEntryPointSelector application:willFinishLaunchingWithOptions:

#define LTAppDelegateUserCodeEntryPointSelectorEncode "@:@@"

typedef BOOL LTLaunchTasksPerformerAppDelegate(
    id<UIApplicationDelegate>, SEL, UIApplication *, NSDictionary *
);

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate LTLaunchTasksPerformerAppDelegateSwizzled;

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate LTLaunchTasksPerformerAppDelegateInjected;
