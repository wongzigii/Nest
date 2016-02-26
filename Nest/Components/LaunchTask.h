//
//  LaunchTask.h
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

@import Foundation;
@import ObjectiveC;

NS_ASSUME_NONNULL_BEGIN

typedef void (* LTLaunchTaskSelectorHandler)(
    SEL, // Task selector
    id, // Task owner
    Method, // Task method
    NSArray *, // Task arguments
    const void * __nullable  // Task context
);

typedef void (* LTLaunchTaskContextCleanupHandler)(void *);

FOUNDATION_EXPORT BOOL LTRegisterLaunchTask(
    const char *, // selector prefix
    const LTLaunchTaskSelectorHandler,
    const void * __nullable, // context
    const LTLaunchTaskContextCleanupHandler __nullable,
    int // priority
);

NS_ASSUME_NONNULL_END
