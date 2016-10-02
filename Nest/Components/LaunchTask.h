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

// Launch Task offers ability to excute tasks during the process launch.
//
// - Notes: Currently only supports application, app extension without
// storyboard.
//
// History
// =======
// Since Swift banned `NSObject`'s `+load` method, method swizzling in
// Swift became unsafe. To solve this problem, Launch Task has came out.
//
// The key to a safe method swizzling is to swizzle only once and swizzle
// as early as possible. Traditional Objective-C style method swizzling in
// `[NSObject +load]` ensures the earliness since the `+load` method only
// get called during the bundle loading, and with the `dispatch_once`
// function, it ensures done-for-only-once. But for Swift code cannot
// control the bundle loading, some people moved the code to the
// `+initialize` method, which is also not recommended. For example, if
// you want to swizzle `UIView` in your framework twice and place the two
// swizzlings in different files, with the `+initilize` approach, you
// cannot do it. That's because Swift checks the code more strictly than
// Objective-C and functions with duplicate signature would be judged as
// malformed code. Since you place the two `UIView` swizzling in different
// files but both in the `+initialzie` method, there are two `+initialize`
// functions in `UIView` with the same function signature in you Swift
// code now.
//
// To solve this problem, we need another window to do the things that we
// had used to do. And I found this window, which is the process launch
// time. For applications, application instances all have a delegate and
// it will call its delegate's will-finish-launching function when it was
// about to finish the launch. This is a good window for method swizzling
// because all the user code are not excuted before it and I think most
// people would not be interested in modifying system code's behavior. For
// those people, this window also fails you. But except you want to do
// something with `UIApplication` instances or other equivilant objects in
// other targets, this constraint shall not be concerned.
//
// Working Mechanism
// =================
// The performer of launch tasks is injected during the loading of the
// containing bundle, which is before the user code will be excuted.(For
// example, for iOS applications, before the `UIApplication` instances
// call its delegate's will-finish-launching function. And then, it will
// inject a launch task performer to the process' user code entry point
// and counting that performer to perform all the registered launch tasks.
//
// ````
// Process Launched
//
//        |
//        ⌵
//
// Main Bundle Loaded
// * Register your launch tasks
//
//        |
//        ⌵
//
// Other Bundles Loaded
// * Register your launch tasks
//
//        |
//        ⌵
//
// Containing Bundle Loaded -------+
// * Register your launch tasks    |
//                                 |
//        |                        |
//        ⌵                        |
//                                 |
// Other Bundles Loaded            | Inject
// * Register your launch tasks    |
//                                 |
//        |                        |
//        ⌵                        |
//                                 |
// Launch Tasks Performer <--------+
// * Search registered launch tasks
// and perform them all.
//
//        |
//        ⌵
//
// User Code Entry Point
// ````
//
// How to Schedule A Launch Task
// =============================
// The launch tasks performer searches the selector of all the classes'
// class methods with speficied launch task prefix. Which is to say, if
// you want to schedule a default launch task whose launch task selector
// prefix is, by default, "_LaunchTask_", you shall write:
//
// ````Swift
// extension WhateverObjectiveCBasedClass {
//
//     @objc
//     private class func _LaunchTask_aLaunchTask() {
//         print("A just have scheduled a launch task.")
//     }
//
// }
// ````
//
// Of course, with a function, you can have arguments and return value.
//
// But since the user code entry points not always come with arguments(
// like app extension, no arguments), and if your launch tasks are put in
// frameworks for both app and app extension, you shall not count on
// receiving them all the time -- which means you shall keep those
// arguments optional.
//
// And to deal with return value, you have to use custom launch task
// handler, becasue the default one just invokes the launch task and does
// nothing with the return value. To see an example about dealing with
// return value, you can see the Objective-C Self-Aware Swizzle component.
//
// How to Register A Custom Luanch Task
// ====================================
// Since the launch tasks performer is called before the user code entry
// point, your shall register your customed kind of launch task in any
// `NSObject` based class' `+load` method:
//
// ````
// LTRegisterLaunchTask(
//     "_CustomLaunchTask_",
//     &CustomTaskHandler,
//     NULL,
//     NULL,
//     0
// );
// ````
// The previous code registered a launch task whose selector prefix is
// "_CustomLaunchTask_" and handles the csutom launch task with
// `CustomTaskHandler`.
//

/// Handles a launch task.
///
/// - Parameter selector: The selector of a recognized launch task.
///
/// - Parameter owner: The class owns the recognized launch task.
///
/// - Parameter method: The Objective-C method represents the launch task.
///
/// - Parameter arguments: The arguments of the launch task Objective-C
/// method.
///
/// - Parameter context: The user defined context used for the launch task
/// working.
typedef void (* LTLaunchTaskHandler)(
    SEL selector,
    id owner,
    Method method,
    NSArray * arguments,
    const void * __nullable  context
) NS_SWIFT_UNAVAILABLE("Define launch task handler in Objective-C.");

/// Represents a cleanup handler for the user defined context in a launch
/// task selector handler. The framework calls the handler each time
/// completes a launch task.
typedef void (* LTLaunchTaskContextCleanupHandler)(void * context)
NS_SWIFT_UNAVAILABLE("Define launch task context cleanup handler in Objective-C.");

/// Registers a launch task.
///
/// - Parameter selectorPrefix: The prefix of the launch task. Begining
/// with "_" and ending with "_" is recommended.
///
/// - Parameter taskHandler: The handelr to handle all recognized launch
/// tasks for the specified selector prefix.
///
/// - Parameter context: The user defined context used for the launch task
/// working. You can define your own working varialbes in the context.
///
/// - Parameter contextCleanupHandler: The user defined context cleanup
/// handler. The framework calls this handler after all recognized launch
/// tasks for the specified selector prefix completed.
///
/// - Parameter priority: The priority of the launch task. The higher one
/// would be recognized and excuted earlier.
///
/// - Returns: A boolean value indicates whether the task was excuted
/// successfully.
///
/// - Notes: You shall call this function in `[NSObject +load]`, which is
/// to say, you have to call this function in Objective-C, but not Swift.
///
/// - Dicussion: A launch task would be counted as a duplicate when its
/// `selectorPrefix`, `taskHandler` and `contextCleanupHandler` is same
/// to an existed launch task's.
FOUNDATION_EXPORT BOOL LTRegisterLaunchTask(
    const char * selectorPrefix,
    const LTLaunchTaskHandler taskHandler,
    const void * __nullable context,
    const LTLaunchTaskContextCleanupHandler __nullable contextCleanupHandler,
    int priority
) NS_SWIFT_UNAVAILABLE("You shall call this function in +load method with Objective-C code.");

NS_ASSUME_NONNULL_END
