//
//  LaunchTask+Internal.h
//  Nest
//
//  Created by Manfred on 12/5/15.
//
//

@import Foundation;

#if TARGET_OS_IOS
#import "LaunchTask-iOS.h"
#elif TARGET_OS_TV
#import "LaunchTask-tvOS.h"
#elif TARGET_OS_WATCH
#import "LaunchTask-watchOS.h"
#elif TARGET_OS_MAC
#import "LaunchTask-macOS.h"
#endif

FOUNDATION_EXPORT void LTPerformLaunchTasksOnLoadedClasses(const id, ...);

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate *
    LTGetAppDelegateLaunchTasksPerformerOriginalImpForClass(const Class);
