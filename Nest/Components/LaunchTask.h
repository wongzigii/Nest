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

/// Task selector, task owner, task arguments, task context
typedef void LTLaunchTaskSelectorHandler(
    SEL,
    id,
    Method,
    NSArray *,
    void * _Nullable
);

typedef LTLaunchTaskSelectorHandler * LTLaunchTaskSelectorHandlerRef;

typedef void LTLaunchTaskContextCleanupHandler(void *);

typedef LTLaunchTaskContextCleanupHandler *
    LTLaunchTaskContextCleanupHandlerRef;

#define LTLaunchTaskSelectorPrefixMaxLength 256

typedef struct LTLaunchTaskInfo {
    char selectorPrefix[LTLaunchTaskSelectorPrefixMaxLength];
    size_t selectorPrefixLength;
    LTLaunchTaskSelectorHandlerRef selectorHandler;
    void * context;
    LTLaunchTaskContextCleanupHandlerRef contextCleanupHandler;
    int priority; // 0 by default
} LTLaunchTaskInfo;

FOUNDATION_EXPORT LTLaunchTaskInfo LTLaunchTaskInfoMake(
    const char *                                    selectorPrefix,
    LTLaunchTaskSelectorHandlerRef                  selectorHandler,
    void *  _Nullable                               context,
    LTLaunchTaskContextCleanupHandlerRef _Nullable  contextCleanupHandler
);

FOUNDATION_EXPORT BOOL LTRegisterLaunchTaskInfo(LTLaunchTaskInfo);

NS_ASSUME_NONNULL_END