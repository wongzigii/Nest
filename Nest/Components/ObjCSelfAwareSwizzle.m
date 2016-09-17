//
//  ObjCSelfAwareSwizzle.m
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import ObjectiveC;

#import <Nest/Nest-Swift.h>

#import "LaunchTask.h"

/*
 Objective-C Self-Aware Swizzle is indeed a launch task.(See LaunchTask.h
 for more)
 */

#pragma mark - Types
typedef struct OCSASSelfAwareSwizzleTaskContext {
    CFMutableDictionaryRef swizzledRecords;
} OCSASSelfAwareSwizzleTaskContext;

typedef NS_OPTIONS(NSUInteger, OCSASSelfAwareSwizzleSelectorMatchResult) {
    OCSASSelfAwareSwizzleSelectorMatchResultUnmatched           = 0,
    OCSASSelfAwareSwizzleSelectorMatchResultMatched             = 1 << 0,
    OCSASSelfAwareSwizzleSelectorMatchResultMatchedIgnoreCase   = 1 << 1,
};

typedef id (* OCSASSelfAwareSwizzleGetter)(id, SEL);

#pragma mark - Functions Prototypes

static void OCSASSelfAwareSwizzleTaskContextCleanupHandler(void *);

void OCSASSelfAwareSwizzleTaskSelectorHandler(
    SEL,
    id,
    Method,
    NSArray *,
    const void *
);

static void OCSASPerformSelfAwareSwizzle(
    ObjCSelfAwareSwizzle *,
    Class,
    const OCSASSelfAwareSwizzleTaskContext *
);

#if DEBUG
static BOOL OCSASDoesClassHostSelfAwareSelectorOnClass(Class, Class);

static NSString * OCSASSelfAwareSwizzleDescription(ObjCSelfAwareSwizzle *);
#endif

#pragma mark - Functions Implementations
void OCSASSelfAwareSwizzleTaskContextCleanupHandler(void * taskContext) {
    OCSASSelfAwareSwizzleTaskContext * selfAwareSwizzleTaskContext =
        (OCSASSelfAwareSwizzleTaskContext *)taskContext;
    
    if (selfAwareSwizzleTaskContext -> swizzledRecords) {
        CFRelease(selfAwareSwizzleTaskContext -> swizzledRecords);
    }
    
    free(selfAwareSwizzleTaskContext);
}

void OCSASSelfAwareSwizzleTaskSelectorHandler(
    SEL taskSelector,
    id taskOwner,
    Method taskMethod,
    NSArray * taskArgs,
    const void * taskContext
    )
{
    OCSASSelfAwareSwizzleTaskContext * selfAwareSwizzleTaskContext =
    (OCSASSelfAwareSwizzleTaskContext *)taskContext;
    
    // Get self-aware swizzle context
    OCSASSelfAwareSwizzleGetter SelfAwareSwizzleGetter =
    (OCSASSelfAwareSwizzleGetter)method_getImplementation(taskMethod);
    
    id potentialSwizzle = (* SelfAwareSwizzleGetter)(
        taskOwner,
        taskSelector
    );
    
    if (potentialSwizzle == nil) {
#if DEBUG
        NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ returns nil.",
              NSStringFromSelector(taskSelector),
              NSStringFromClass(taskOwner));
#endif
        return;
    }
    
    if ([potentialSwizzle isKindOfClass:[ObjCSelfAwareSwizzle class]]) {
        ObjCSelfAwareSwizzle * swizzle =
        (ObjCSelfAwareSwizzle *)potentialSwizzle;
        OCSASPerformSelfAwareSwizzle(
            swizzle,
            taskOwner,
            selfAwareSwizzleTaskContext
        );
    } else if ([potentialSwizzle isKindOfClass:[NSArray class]]) {
        NSArray * potentialSwizzles = (NSArray *)potentialSwizzle;
        
        [potentialSwizzles enumerateObjectsUsingBlock:
         ^(id eachPotentialSwizzle, NSUInteger idx, BOOL * stop) {
             if ([eachPotentialSwizzle
                  isKindOfClass:[ObjCSelfAwareSwizzle class]])
             {
                 ObjCSelfAwareSwizzle * swizzle =
                 (ObjCSelfAwareSwizzle *)eachPotentialSwizzle;
                 OCSASPerformSelfAwareSwizzle(
                    swizzle,
                    taskOwner,
                    selfAwareSwizzleTaskContext
                );
             }
#if DEBUG
             else {
                 NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ doesn't return with a value of type of %@ but %@.",
                       NSStringFromSelector(taskSelector),
                       NSStringFromClass(taskOwner),
                       NSStringFromClass([ObjCSelfAwareSwizzle class]),
                       NSStringFromClass([potentialSwizzle class]));
             }
#endif
         }];
    }
#if DEBUG
    else {
        NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ doesn't return with a value of type of %@ but %@.",
              NSStringFromSelector(taskSelector),
              NSStringFromClass(taskOwner),
              NSStringFromClass([ObjCSelfAwareSwizzle class]),
              NSStringFromClass([potentialSwizzle class]));
    }
#endif
}

#if DEBUG
BOOL OCSASDoesClassHostSelfAwareSelectorOnClass(
    Class hostClass,
    Class targetClass
    )
{
    if (hostClass == targetClass) {
        return YES;
    } else if (class_isMetaClass(targetClass)) {
        char const * className = class_getName(hostClass);
        Class hostMetaClass = objc_getMetaClass(className);
        if (hostMetaClass == targetClass) {
            return YES;
        }
    }
    
    return NO;
}
#endif

void OCSASPerformSelfAwareSwizzle(
    ObjCSelfAwareSwizzle * swizzle,
    Class aClass,
    const OCSASSelfAwareSwizzleTaskContext * taskContext
    )
{
    Class targetClass = swizzle.targetClass;
    
    SEL targetSelector = swizzle.targetSelector;
    
#if DEBUG
    if (!OCSASDoesClassHostSelfAwareSelectorOnClass(aClass, targetClass)) {
        NSLog(@"Class to be swizzled %@ is not the Self-Aware Swizzle selector's host class %@.",
              NSStringFromClass(targetClass),
              NSStringFromClass(aClass));
    }
    if (targetSelector == NSSelectorFromString(@"dealloc")) {
        NSLog(@"Swizzling againsts -dealloc is discouraged!");
    }
    if (targetSelector == NSSelectorFromString(@"retain")) {
        NSLog(@"Swizzling againsts -reatain is discouraged!");
    }
    if (targetSelector == NSSelectorFromString(@"release")) {
        NSLog(@"Swizzling againsts -release is discouraged!");
    }
    if (targetSelector == NSSelectorFromString(@"retainCount")) {
        NSLog(@"Swizzling againsts -retainCount is discouraged!");
    }
#endif
    
    CFMutableDictionaryRef swizzledRecordsForClass = (CFMutableDictionaryRef)
    CFDictionaryGetValue(
        taskContext -> swizzledRecords,
        (__bridge const void *)(targetClass)
    );
    
    if (swizzledRecordsForClass == NULL) {
        swizzledRecordsForClass = CFDictionaryCreateMutable(
            kCFAllocatorDefault,
            0,
            NULL,
            &kCFTypeDictionaryValueCallBacks
        );
        
        CFDictionarySetValue(
            taskContext -> swizzledRecords,
            (__bridge const void *)(targetClass),
            swizzledRecordsForClass
        );
        
        CFRelease(swizzledRecordsForClass);
    }
    
    CFMutableArrayRef performedSwizzles = (CFMutableArrayRef)
        CFDictionaryGetValue(swizzledRecordsForClass, targetSelector);
    
    if (performedSwizzles == NULL) {
        performedSwizzles = CFArrayCreateMutable(
            kCFAllocatorDefault,
            0,
            &kCFTypeArrayCallBacks
        );
        
        CFDictionarySetValue(
            swizzledRecordsForClass,
            targetSelector,
            performedSwizzles
        );
        
        CFRelease(performedSwizzles);
    }
    
    BOOL noEqualPerformedSwizzle = YES;
    
    CFIndex numberOfSwizzles = CFArrayGetCount(performedSwizzles);
    
    // Check duplicate
    for (CFIndex index = 0; index < numberOfSwizzles; index ++) {
        ObjCSelfAwareSwizzle * performedSwizzle =
            CFArrayGetValueAtIndex(performedSwizzles, index);
        
        if ([performedSwizzle isEqual:swizzle]) {
            noEqualPerformedSwizzle = NO;
            break;
        }
    }
    
    if (noEqualPerformedSwizzle) {
        Method targetMethod = class_getInstanceMethod(
            targetClass,
            targetSelector
        );
        
        struct objc_method_description * targetMethodDescription =
        method_getDescription(targetMethod);
        
        if (targetMethodDescription == NULL) {
#if DEBUG
            NSLog(@"Swizzling FAILED: Selector wasn't implemented: %@",
                  OCSASSelfAwareSwizzleDescription(swizzle));
#endif
        } else {
            NSError * error = nil;
            
            if ([swizzle perform:&error]) {
                CFArrayAppendValue(
                    performedSwizzles,
                    (__bridge const void *)(swizzle)
                );
#if DEBUG
                NSLog(@"Swizzling succeeded %@",
                      OCSASSelfAwareSwizzleDescription(swizzle));
#endif
            } else {
#if DEBUG
                NSLog(@"Swizzling FAILED due to error: %@", error.description);
#endif
            }
        }
    }
#if DEBUG
    else {
        NSLog(@"Swizzling FAILED: Duplicate swizzling: %@",
              OCSASSelfAwareSwizzleDescription(swizzle));
    }
#endif
    
    
}

#if DEBUG
NSString * OCSASSelfAwareSwizzleDescription(ObjCSelfAwareSwizzle * swizzle) {
    if (swizzle.isMetaClass) {
        return [NSString stringWithFormat:@"[%@ +%@]",
                NSStringFromClass(swizzle.targetClass),
                NSStringFromSelector(swizzle.targetSelector)];
    } else {
        return [NSString stringWithFormat:@"[%@ -%@]",
                NSStringFromClass(swizzle.targetClass),
                NSStringFromSelector(swizzle.targetSelector)];
    }
}
#endif

#pragma mark - Register Self-Aware Swizzle as A Launch Task
@interface NSObject(SelfAwareSwizzle)
@end

@implementation NSObject(SelfAwareSwizzle)
+ (void)load {
    // Create a clean task cotnext
    OCSASSelfAwareSwizzleTaskContext * taskContextRef =
    malloc(sizeof(OCSASSelfAwareSwizzleTaskContext));
    memset(taskContextRef, 0, sizeof(OCSASSelfAwareSwizzleTaskContext));
    
    // Initialize task context
    taskContextRef -> swizzledRecords = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        NULL,
        &kCFTypeDictionaryValueCallBacks
    );
    
    // Register launch task info
    LTRegisterLaunchTask(
        "_ObjCSelfAwareSwizzle_",
        &OCSASSelfAwareSwizzleTaskSelectorHandler,
        taskContextRef,
        &OCSASSelfAwareSwizzleTaskContextCleanupHandler,
        -100
    );
}
@end

