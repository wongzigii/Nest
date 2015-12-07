//
//  LaunchTask+UIKit.h
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

@import UIKit;

#import "LaunchTask.h"

typedef BOOL LTLaunchTaskPerformer(id<UIApplicationDelegate>,
    SEL,
    UIApplication *,
    NSDictionary *);

#define LTAppDelegate UIApplicationDelegate

#define LTLaunchTasksPerformSelector application:willFinishLaunchingWithOptions:

#define LTLaunchTasksPerformSelectorEncode "@:@@"

FOUNDATION_EXPORT LTLaunchTaskPerformer LTSwizzledLaunchTasksPerformer;

FOUNDATION_EXPORT LTLaunchTaskPerformer LTInjectedLaunchTasksPerformer;