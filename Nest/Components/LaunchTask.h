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

/// Represents a handler to handle a launch task selector.
///
/// - Parameter selector: The launch task selector.
///
/// - Parameter owner: The class owns the launch task selector.
///
/// - Parameter method: The method represents the task.
///
/// - Parameter arguments: The arguments of the task method.
///
/// - Parameter context: The user defined context for tasking.
typedef void (* LTLaunchTaskSelectorHandler)(
    SEL selector,
    id owner,
    Method method,
    NSArray * arguments,
    const void * __nullable  context
);

/// Represents a cleanup handler for the user defined context in a launch
/// task selector handler.
typedef void (* LTLaunchTaskContextCleanupHandler)(void * context);

/// Registers a launch task.
///
/// - Parameter selectorPrefix: The prefix of the launch task. Begining
/// with "_" and ending with "_" is recommended.
///
/// - Parameter taskHandler: The handelr of the launch task.
///
/// - Parameter method: The method represents the task.
///
/// - Parameter context: The user defined context of the launch task.
///
/// - Parameter contextCleanupHandler: The user defined context cleanup
/// handler.
///
/// - Parameter priority: The priority of the launch task. The higher one
/// would be excuted earlier.
///
/// - Returns: A boolean value indicates whether the task was excuted
/// successfully.
///
/// - Notes: You shall call this function in `[NSObject +load]`, which is
/// to say, you have to call this function in Objective-C, but not Swift.
FOUNDATION_EXPORT BOOL LTRegisterLaunchTask(
    const char * selectorPrefix,
    const LTLaunchTaskSelectorHandler taskHandler,
    const void * __nullable context,
    const LTLaunchTaskContextCleanupHandler __nullable contextCleanupHandler,
    int priority
);

NS_ASSUME_NONNULL_END
