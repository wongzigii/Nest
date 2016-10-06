//
//  LaunchTask+AppKit.h
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

@import AppKit;

#import "LaunchTask.h"

#define LTStoryboard NSStoryboard

#define LTMainStoryboardFileKey @"NSMainStoryboardFile"

#define LTAppDelegate NSApplicationDelegate

#define LTAppDelegateUserCodeEntryPointSelector applicationWillFinishLaunching:

#define LTAppDelegateUserCodeEntryPointSelectorEncode "@:@"

typedef void LTLaunchTasksPerformerAppDelegate(
    id<NSApplicationDelegate>, SEL, NSNotification *
);

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate LTLaunchTasksPerformerAppDelegateSwizzled;

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate LTLaunchTasksPerformerAppDelegateInjected;
