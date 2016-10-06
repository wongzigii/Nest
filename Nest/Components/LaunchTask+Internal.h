//
//  LaunchTask+Internal.h
//  Nest
//
//  Created by Manfred on 12/5/15.
//
//

@import Foundation;

#if TARGET_OS_IOS || TARGET_OS_TV
#import "LaunchTask-UIKit.h"
#elif TARGET_OS_WATCH
#import "LaunchTask-WatchKit.h"
#elif TARGET_OS_MAC
#import "LaunchTask-AppKit.h"
#endif

FOUNDATION_EXPORT void LTPerformLaunchTasksOnLoadedClasses(const id, ...);

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate *
    LTGetAppDelegateLaunchTasksPerformerOriginalImpForClass(const Class);
