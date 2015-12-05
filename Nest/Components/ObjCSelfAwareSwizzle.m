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

#import "ObjCSelfAwareSwizzle.h"

#pragma mark - Types
typedef struct OCSASSelfAwareSwizzleTaskContext {
    CFMutableDictionaryRef swizzledRecords;
} OCSASSelfAwareSwizzleTaskContext;

typedef id OCSASSelfAwareSwizzleContextGetter(id, SEL);

typedef OCSASSelfAwareSwizzleContextGetter *
OCSASSelfAwareSwizzleContextGetterRef;

typedef NS_OPTIONS(NSUInteger, OCSASSelfAwareSwizzleSelectorMatchResult) {
    OCSASSelfAwareSwizzleSelectorMatchResultUnmatched           = 0,
    OCSASSelfAwareSwizzleSelectorMatchResultMatched             = 1 << 0,
    OCSASSelfAwareSwizzleSelectorMatchResultMatchedIgnoreCase   = 1 << 1,
};

#pragma mark - Functions Prototypes
static LTLaunchTaskContextCleanupHandler
    OCSASSelfAwareSwizzleTaskContextCleanupHandelr;

static LTLaunchTaskSelectorHandler
    OCSASSelfAwareSwizzleTaskSelectorHandelr;

static void OCSASPerformSelfAwareSwizzleWithContext(
    ObjCSelfAwareSwizzleContext *,
    Class,
    OCSASSelfAwareSwizzleTaskContext *);

static BOOL OCSASDoesClassHostSelfAwareSelectorOnClass(Class, Class);

static NSString * OCSASSelfAwareSwizzleContextDescription(
    ObjCSelfAwareSwizzleContext *);

#pragma mark - Functions Implementations
void OCSASSelfAwareSwizzleTaskContextCleanupHandelr(void * taskContext) {
    OCSASSelfAwareSwizzleTaskContext * selfAwareSwizzleTaskContext =
        (OCSASSelfAwareSwizzleTaskContext *)taskContext;
    
    if (selfAwareSwizzleTaskContext -> swizzledRecords) {
        CFRelease(selfAwareSwizzleTaskContext -> swizzledRecords);
    }
    
    free(selfAwareSwizzleTaskContext);
}

void OCSASSelfAwareSwizzleTaskSelectorHandelr(SEL taskSelector,
    id taskOwner,
    Method taskMethod,
    NSArray * taskArgs,
    void * taskContext)
{
    OCSASSelfAwareSwizzleTaskContext * selfAwareSwizzleTaskContext =
    (OCSASSelfAwareSwizzleTaskContext *)taskContext;
    
    // Get self-aware swizzle context
    OCSASSelfAwareSwizzleContextGetterRef selfAwareSwizzleContextGetter =
    (OCSASSelfAwareSwizzleContextGetterRef)method_getImplementation(taskMethod);
    
    id potentialContext = (* selfAwareSwizzleContextGetter)(taskOwner,
        taskSelector);
    
    if (potentialContext == nil) {
#if DEBUG
        NSLog(@"Expected Self-Aware Swizzle selector: %@ on %@ returns nil.",
              NSStringFromSelector(taskSelector),
              NSStringFromClass(taskOwner));
#endif
        return;
    }
    
    if ([potentialContext isKindOfClass:[ObjCSelfAwareSwizzleContext class]]) {
        ObjCSelfAwareSwizzleContext * swizzleContext =
        (ObjCSelfAwareSwizzleContext *)potentialContext;
        OCSASPerformSelfAwareSwizzleWithContext(swizzleContext,
            taskOwner,
            selfAwareSwizzleTaskContext);
    } else if ([potentialContext isKindOfClass:[NSArray class]]) {
        NSArray * potentialContexts = (NSArray *)potentialContext;
        
        [potentialContexts enumerateObjectsUsingBlock:
         ^(id eachPotentialContext, NSUInteger idx, BOOL * stop) {
             if ([eachPotentialContext
                  isKindOfClass:[ObjCSelfAwareSwizzleContext class]])
             {
                 ObjCSelfAwareSwizzleContext * swizzleContext =
                 (ObjCSelfAwareSwizzleContext *)eachPotentialContext;
                 OCSASPerformSelfAwareSwizzleWithContext(swizzleContext,
                    taskOwner,
                    selfAwareSwizzleTaskContext);
             }
#if DEBUG
             else {
                 NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ doesn't return with a value of type of %@ but %@.",
                       NSStringFromSelector(taskSelector),
                       NSStringFromClass(taskOwner),
                       NSStringFromClass([ObjCSelfAwareSwizzleContext class]),
                       NSStringFromClass([potentialContext class]));
             }
#endif
         }];
    }
#if DEBUG
    else {
        NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ doesn't return with a value of type of %@ but %@.",
              NSStringFromSelector(taskSelector),
              NSStringFromClass(taskOwner),
              NSStringFromClass([ObjCSelfAwareSwizzleContext class]),
              NSStringFromClass([potentialContext class]));
    }
#endif
}

BOOL OCSASDoesClassHostSelfAwareSelectorOnClass(Class hostClass,
    Class targetClass)
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

void OCSASPerformSelfAwareSwizzleWithContext(
    ObjCSelfAwareSwizzleContext * context,
    Class aClass,
    OCSASSelfAwareSwizzleTaskContext * taskContext)
{
    Class targetClass = context.targetClass;
    
    SEL targetSelector = context.targetSelector;
    
#if DEBUG
    if (!OCSASDoesClassHostSelfAwareSelectorOnClass(aClass, targetClass)) {
        NSLog(@"Class to be swizzled %@ is not the Self-Aware Swizzle selector's host class %@.",
              NSStringFromClass(aClass),
              NSStringFromClass(targetClass));
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
    CFDictionaryGetValue(taskContext -> swizzledRecords,
        (__bridge const void *)(targetClass));
    
    if (swizzledRecordsForClass == NULL) {
        swizzledRecordsForClass = CFDictionaryCreateMutable(kCFAllocatorDefault,
            0,
            NULL,
            &kCFTypeDictionaryValueCallBacks);
        
        CFDictionarySetValue(taskContext -> swizzledRecords,
            (__bridge const void *)(targetClass),
            swizzledRecordsForClass);
        
        CFRelease(swizzledRecordsForClass);
    }
    
    CFMutableArrayRef swizzledContexts = (CFMutableArrayRef)
        CFDictionaryGetValue(swizzledRecordsForClass,
            targetSelector);
    
    if (swizzledContexts == NULL) {
        swizzledContexts = CFArrayCreateMutable(kCFAllocatorDefault,
                        0,
                        &kCFTypeArrayCallBacks);
        
        CFDictionarySetValue(swizzledRecordsForClass,
            targetSelector,
            swizzledContexts);
        
        CFRelease(swizzledContexts);
    }
    
    BOOL noEqualContext = YES;
    
    CFIndex numberOfContexts = CFArrayGetCount(swizzledContexts);
    
    for (CFIndex index = 0; index < numberOfContexts; index ++) {
        ObjCSelfAwareSwizzleContext * swizzledContext =
            CFArrayGetValueAtIndex(swizzledContexts, index);
        
        if ([swizzledContext isEqual:context]) {
            noEqualContext = NO;
            break;
        }
    }
    
    if (noEqualContext) {
        Method targetMethod = class_getInstanceMethod(targetClass,
            targetSelector);
        
        struct objc_method_description * targetMethodDescription =
        method_getDescription(targetMethod);
        
        if (targetMethodDescription == NULL) {
#if DEBUG
            NSLog(@"Swizzling FAILED: Selector wasn't implemented: %@",
                  OCSASSelfAwareSwizzleContextDescription(context));
#endif
        } else {
            IMP originalImp =
            class_getMethodImplementation(targetClass, targetSelector);
            
            IMP swizzledImp = [context perform: originalImp];
            
            Method targetMethod =
            class_getInstanceMethod(targetClass, targetSelector);
            
            char const * encoding = method_getTypeEncoding(targetMethod);
            
            class_replaceMethod(targetClass,
                targetSelector,
                swizzledImp,
                encoding);
            
            CFArrayAppendValue(swizzledContexts,
                (__bridge const void *)(context));
            
#if DEBUG
            NSLog(@"Swizzling succeeded %@",
                  OCSASSelfAwareSwizzleContextDescription(context));
#endif
        }
    }
#if DEBUG
    else {
        NSLog(@"Swizzling FAILED: Duplicate swizzling: %@",
              OCSASSelfAwareSwizzleContextDescription(context));
    }
#endif
    
    
}

NSString * OCSASSelfAwareSwizzleContextDescription(
    ObjCSelfAwareSwizzleContext * context)
{
    if (context.isMetaClass) {
        return [NSString stringWithFormat:@"[%@ +%@]",
                NSStringFromClass(context.targetClass),
                NSStringFromSelector(context.targetSelector)];
    } else {
        return [NSString stringWithFormat:@"[%@ -%@]",
                NSStringFromClass(context.targetClass),
                NSStringFromSelector(context.targetSelector)];
    }
}

#pragma mark - Register Self-Aware Swizzle as A Launch Task
@interface NSObject(SelfAwareSwizzle)
@end

@implementation NSObject(SelfAwareSwizzle)
+ (void)load {
    NSLog(@"NSObject(SelfAwareSwizzle) was loaded");
    // Create a clean task cotnext
    OCSASSelfAwareSwizzleTaskContext * taskContextRef =
    malloc(sizeof(OCSASSelfAwareSwizzleTaskContext));
    memset(taskContextRef, 0, sizeof(OCSASSelfAwareSwizzleTaskContext));
    
    // Initialize task context
    taskContextRef -> swizzledRecords = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        NULL,
        &kCFTypeDictionaryValueCallBacks);
    
    // Create task info
    LTLaunchTaskInfo ObjCSelfAwareSwizzleLaunchTaskInfo =
    LTLaunchTaskInfoMake("_ObjCSelfAwareSwizzle_",
                         &OCSASSelfAwareSwizzleTaskSelectorHandelr,
                         taskContextRef,
                         &OCSASSelfAwareSwizzleTaskContextCleanupHandelr);
    
    // Register task info
    LTRegisterLaunchTaskInfo(ObjCSelfAwareSwizzleLaunchTaskInfo);
}
@end

