//
//  LaunchTask+WatchKit.h
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

@import WatchKit;

#import "LaunchTask.h"

typedef void LTLaunchTaskPerformer(id<WKExtensionDelegate>, SEL);

#define LTAppDelegate WKExtensionDelegate

#define LTLaunchTasksPerformSelector applicationDidFinishLaunching

#define LTLaunchTasksPerformSelectorEncode "@:"

FOUNDATION_EXPORT LTLaunchTaskPerformer LTSwizzledLaunchTasksPerformer;

FOUNDATION_EXPORT LTLaunchTaskPerformer LTInjectedLaunchTasksPerformer;
