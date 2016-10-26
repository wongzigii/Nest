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
typedef struct _ObjCSelfAwareSwizzleContext {
    CFMutableDictionaryRef swizzledRecords;
} ObjCSelfAwareSwizzleContext;

typedef NS_OPTIONS(NSUInteger, ObjCSelfAwareSwizzleSelectorMatchResult) {
    ObjCSelfAwareSwizzleSelectorMatchResultUnmatched           = 0,
    ObjCSelfAwareSwizzleSelectorMatchResultMatched             = 1 << 0,
    ObjCSelfAwareSwizzleSelectorMatchResultMatchedIgnoreCase   = 1 << 1,
};

typedef id (* ObjCSelfAwareSwizzleCombinationGetter)(id, SEL);

#pragma mark - Functions Prototypes

static void ObjCSelfAwareSwizzleContextCleanupHandler(void *);

static void ObjCSelfAwareSwizzleSelectorHandler(
    const SEL,
    const id,
    const Method,
    const NSArray *,
    const void *
);

static void ObjCSelfAwareSwizzlePerformSwizzleCombination(
    const id,
    const SEL,
    const Class,
    const ObjCSelfAwareSwizzleContext *
);

static void ObjCSelfAwareSwizzlePerformSwizzle(
    ObjCSelfAwareSwizzle *,
    Class,
    const ObjCSelfAwareSwizzleContext *
);

static void ObjCSelfAwareSwizzlePerformSwizzles(
    const id <NSFastEnumeration>,
    const SEL,
    const Class,
    const ObjCSelfAwareSwizzleContext *
);

#if DEBUG
static BOOL ObjCSelfAwareSwizzleDoesClassHostSelfAwareSelectorOnClass(
    const Class, const Class
);

static NSString * ObjCSelfAwareSwizzleDescription(
    const ObjCSelfAwareSwizzle *
);
#endif

#pragma mark - Functions Implementations
void ObjCSelfAwareSwizzleContextCleanupHandler(void * context) {
    ObjCSelfAwareSwizzleContext * selfAwareContext =
        (ObjCSelfAwareSwizzleContext *)context;
    
    if (selfAwareContext -> swizzledRecords) {
        CFRelease(selfAwareContext -> swizzledRecords);
    }
    
    free(selfAwareContext);
}

void ObjCSelfAwareSwizzleSelectorHandler(
    SEL selector,
    id owner,
    Method method,
    NSArray * args,
    const void * context
    )
{
    // Get self-aware swizzle combination
    ObjCSelfAwareSwizzleCombinationGetter swizzleCombinationGetter =
        (ObjCSelfAwareSwizzleCombinationGetter)
        method_getImplementation(method);
    
    id swizzleCombination = (* swizzleCombinationGetter)(
        owner,
        selector
    );
    
    if (swizzleCombination == nil) {
#if DEBUG
        NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ returns nil.",
              NSStringFromSelector(selector),
              NSStringFromClass(owner));
#endif
        return;
    }
    
    ObjCSelfAwareSwizzleContext * selfAwareSwizzleContext =
        (ObjCSelfAwareSwizzleContext *)context;
    
    ObjCSelfAwareSwizzlePerformSwizzleCombination(
        swizzleCombination, selector, owner, selfAwareSwizzleContext
    );
}

#if DEBUG
BOOL ObjCSelfAwareSwizzleDoesClassHostSelfAwareSelectorOnClass(
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

void ObjCSelfAwareSwizzlePerformSwizzleCombination(
    const id swizzleCombination,
    const SEL sel,
    const Class cls,
    const ObjCSelfAwareSwizzleContext * ctx
    )
{
    if ([swizzleCombination isKindOfClass:[ObjCSelfAwareSwizzle class]]) {
        ObjCSelfAwareSwizzle * swizzle =
            (ObjCSelfAwareSwizzle *)swizzleCombination;
        
        ObjCSelfAwareSwizzlePerformSwizzle(
            swizzle,
            cls,
            ctx
        );
    } else if ([swizzleCombination conformsToProtocol:@protocol(NSFastEnumeration)]) {
        NSObject <NSFastEnumeration> * swizzles
            = (NSObject <NSFastEnumeration> *)swizzleCombination;
        
        ObjCSelfAwareSwizzlePerformSwizzles(swizzles, sel, cls, ctx);
    }
#if DEBUG
    else {
        NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ doesn't return with a value of type of %@ but %@.",
              NSStringFromSelector(sel),
              NSStringFromClass(cls),
              NSStringFromClass([ObjCSelfAwareSwizzle class]),
              NSStringFromClass([swizzleCombination class]));
    }
#endif
}

void ObjCSelfAwareSwizzlePerformSwizzle(
    ObjCSelfAwareSwizzle * swizzle,
    Class aClass,
    const ObjCSelfAwareSwizzleContext * taskContext
    )
{
    Class targetClass = swizzle.targetClass;
    
    SEL targetSelector = swizzle.targetSelector;
    
#if DEBUG
    if (!ObjCSelfAwareSwizzleDoesClassHostSelfAwareSelectorOnClass(aClass, targetClass)) {
        NSLog(@"Class to be swizzled %@ is not the Self-Aware Swizzle selector's containing class %@.",
              NSStringFromClass(targetClass),
              NSStringFromClass(aClass));
    }
    if (targetSelector == NSSelectorFromString(@"dealloc")
        || targetSelector == NSSelectorFromString(@"retain")
        || targetSelector == NSSelectorFromString(@"release")
        || targetSelector == NSSelectorFromString(@"retainCount")
        )
    {
        NSLog(@"Swizzling againsts -%@ is discouraged!", NSStringFromSelector(targetSelector));
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
                  ObjCSelfAwareSwizzleDescription(swizzle));
#endif
        } else {
            NSError * error = nil;
            
            if ([swizzle perform:&error]) {
                CFArrayAppendValue(
                    performedSwizzles,
                    (__bridge const void *)(swizzle)
                );
#if DEBUG
                NSLog(@"Swizzle succeeded %@",
                      ObjCSelfAwareSwizzleDescription(swizzle));
#endif
            } else {
#if DEBUG
                NSLog(@"Swizzle FAILED due to error: %@", error.description);
#endif
            }
        }
    }
#if DEBUG
    else {
        NSLog(@"Swizzling FAILED: Duplicate swizzling: %@",
              ObjCSelfAwareSwizzleDescription(swizzle));
    }
#endif
}

void ObjCSelfAwareSwizzlePerformSwizzles(
    NSObject <NSFastEnumeration> * swizzles,
    SEL sel,
    Class cls,
    const ObjCSelfAwareSwizzleContext * ctx
    )
{
    BOOL isSwizzlesADictionary
        = [swizzles isKindOfClass:[NSDictionary class]];
    
    BOOL isSwizzlesAMapTable
        = [swizzles isKindOfClass:[NSMapTable class]];
    
    for (id each in swizzles) {
        if (isSwizzlesADictionary) {
            NSDictionary * dict = (NSDictionary *) swizzles;
            id potentialSwizzle = dict[each];
            if (potentialSwizzle) {
                ObjCSelfAwareSwizzlePerformSwizzleCombination(
                    potentialSwizzle, sel, cls, ctx
                );
            }
        } else if (isSwizzlesAMapTable) {
            NSMapTable * mapTable = (NSMapTable *) swizzles;
            id potentialSwizzle = [mapTable objectForKey:each];
            if (potentialSwizzle) {
                ObjCSelfAwareSwizzlePerformSwizzleCombination(
                    potentialSwizzle, sel, cls, ctx
                );
            }
        } else {
            if ([each isKindOfClass:[ObjCSelfAwareSwizzle class]]) {
                ObjCSelfAwareSwizzle * swizzle
                    = (ObjCSelfAwareSwizzle *) each;
                ObjCSelfAwareSwizzlePerformSwizzle(swizzle, cls, ctx);
            } else if ([each conformsToProtocol:@protocol(NSFastEnumeration)]) {
                NSObject <NSFastEnumeration> * swizzles
                    = (NSObject <NSFastEnumeration> *)each;
                ObjCSelfAwareSwizzlePerformSwizzles(
                    swizzles, sel, cls, ctx
                );
            }
#if DEBUG
            else {
                NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ doesn't return with a value of type of %@ but %@.",
                      NSStringFromSelector(sel),
                      NSStringFromClass(cls),
                      NSStringFromClass([ObjCSelfAwareSwizzle class]),
                      NSStringFromClass([each class]));
            }
#endif
        }
    }
}

#if DEBUG
NSString * ObjCSelfAwareSwizzleDescription(ObjCSelfAwareSwizzle * swizzle) {
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
    ObjCSelfAwareSwizzleContext * contextRef =
        calloc(1, sizeof(ObjCSelfAwareSwizzleContext));
    
    // Initialize task context
    contextRef -> swizzledRecords = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        NULL,
        &kCFTypeDictionaryValueCallBacks
    );
    
    // Register launch task info
    LTRegisterLaunchTask(
        "_ObjCSelfAwareSwizzle_",
        &ObjCSelfAwareSwizzleSelectorHandler,
        contextRef,
        &ObjCSelfAwareSwizzleContextCleanupHandler,
        -100
    );
}
@end

