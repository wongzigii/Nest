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

/// Task selector, task owner, task context
typedef void LTLaunchTaskSelectorHandler(SEL,id, Method, NSArray *, void *);

typedef LTLaunchTaskSelectorHandler * LTLaunchTaskSelectorHandlerRef;

typedef void LTLaunchTaskContextCleanupHandler(void *);

typedef LTLaunchTaskContextCleanupHandler *
    LTLaunchTaskContextCleanupHandlerRef;

#define LTLaunchTaskSelectorPrefixMaxLength 255

typedef struct LTLaunchTaskInfo {
    char selectorPrefix[LTLaunchTaskSelectorPrefixMaxLength];
    size_t selectorPrefixLength;
    LTLaunchTaskSelectorHandlerRef selectorHandler;
    void * context;
    LTLaunchTaskContextCleanupHandlerRef contextCleanupHandler;
} LTLaunchTaskInfo;

typedef LTLaunchTaskInfo * LTLaunchTaskInfoRef;

FOUNDATION_EXPORT LTLaunchTaskInfo LTLaunchTaskInfoMake(
    const char *                            selectorPrefix,
    LTLaunchTaskSelectorHandlerRef          selectorHandler,
    void *                                  context,
    LTLaunchTaskContextCleanupHandlerRef    contextCleanupHandler);

FOUNDATION_EXPORT BOOL LTRegisterLaunchTaskInfo(LTLaunchTaskInfo);

NS_ASSUME_NONNULL_END