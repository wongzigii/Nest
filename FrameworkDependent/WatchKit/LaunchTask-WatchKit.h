//
//  LaunchTask+WatchKit.h
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

@import WatchKit;

#import "LaunchTask.h"

#define LTAppDelegate WKExtensionDelegate

#define LTAppDelegateUserCodeEntryPointSelector applicationDidFinishLaunching

#define LTAppDelegateUserCodeEntryPointSelectorEncode "@:"

typedef void LTLaunchTasksPerformerAppDelegate(
    id<WKExtensionDelegate>, SEL
);

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate
    LTLaunchTasksPerformerAppDelegateSwizzled;

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate
    LTLaunchTasksPerformerAppDelegateInjected;
