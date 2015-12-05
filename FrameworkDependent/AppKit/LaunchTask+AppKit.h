//
//  LaunchTask+AppKit.h
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

@import AppKit;

#import "LaunchTask.h"

typedef void LTLaunchTaskPerformer(id<NSApplicationDelegate>,
    SEL,
    NSNotification *);

#define LTAppDelegate NSApplicationDelegate

#define LTLaunchTasksPerformSelector applicationWillFinishLaunching:

#define LTLaunchTasksPerformSelectorEncode "@:@"

FOUNDATION_EXPORT LTLaunchTaskPerformer LTSwizzledLaunchTasksPerformer;

FOUNDATION_EXPORT LTLaunchTaskPerformer LTInjectedLaunchTasksPerformer;
