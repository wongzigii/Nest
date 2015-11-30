//
//  ObjCSelfAwareSwizzle.m
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import ObjectiveC;

#import <Nest/Nest-Swift.h>

#if TARGET_OS_IOS || TARGET_OS_TV
#import "ObjCSelfAwareSwizzle+UIKit.h"
#elif TARGET_OS_WATCH
#import "ObjCSelfAwareSwizzle+WatchKit.h"
#elif TARGET_OS_MAC
#import "ObjCSelfAwareSwizzle+AppKit.h"
#endif

#import "ObjCSelfAwareSwizzle.h"

typedef NS_OPTIONS(NSUInteger, OCSASSelfAwareSwizzleSelectorMatchResult) {
    OCSASSelfAwareSwizzleSelectorMatchResultUnmatched           = 0,
    OCSASSelfAwareSwizzleSelectorMatchResultMatched             = 1 << 0,
    OCSASSelfAwareSwizzleSelectorMatchResultMatchedIgnoreCase   = 1 << 1,
};

typedef ObjCSelfAwareSwizzleContext * OCSASSelfAwareSwizzleContextGetter(
    id, SEL);

typedef OCSASSelfAwareSwizzleContextGetter *
OCSASSelfAwareSwizzleContextGetterRef;

static const char * kOCSASSelfAwareSwizzleSelectorPrefix =
"_ObjCSelfAwareSwizzle_";

#define OCSASSelfAwareSwizzleSelectorPrefixLength 22

static void OCSASSwizzleAllPossibleAppDelegates();
static void OCSASScanAndActivateSelfAwareSwizzleSelectorsOnClass(Class);
static OCSASSelfAwareSwizzleSelectorMatchResult
    OCSASMatchSelfAwareSwizzleSelector(SEL);
static void OCSASActivateSelfSwizzleSelector(Class, Method, SEL);
static BOOL OCSASDoesClassHostSelfAwareSelectorOnClass(Class hostClass,
    Class targetClass);
static void OCSASPerformSelfAwareSwizzleWithContext(
    ObjCSelfAwareSwizzleContext *);
static NSString * OCSASSelfAwareSwizzleContextDescription(
    ObjCSelfAwareSwizzleContext * context);

static CFMutableDictionaryRef OCSASOriginalSelfAwareSwizzlePerformerMap = NULL;

static CFMutableDictionaryRef OCSASSwizzledRecords = NULL;

#pragma mark - Self-Aware Swizzle Preprocess
@interface NSObject(SelfAwareSwizzle)
@end

@implementation NSObject(SelfAwareSwizzle)
+ (void)load {
    NSLog(@"Main bundle: %@", [NSBundle mainBundle].description);
    NSLog(@"Main bundle principal class: %@", NSStringFromClass([NSBundle mainBundle].principalClass));
    OCSASSwizzleAllPossibleAppDelegates();
}
@end

void OCSASSwizzleAllPossibleAppDelegates() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Inject implementation in to all classes conforms to process delegate
        
        OCSASOriginalSelfAwareSwizzlePerformerMap =
        CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
        
        Protocol * appDelegateProtocol =
        @protocol(OCSASAppDelegate);
        
        SEL selfAwareSwizzlePerformingSelector =
        @selector(OCSASSelfAwareSwizzlePerformingSelector);
        
        unsigned int classCount = 0;
        
        Class * classes = objc_copyClassList(&classCount);
        
        for (unsigned int index = 0; index < classCount; index ++) {
            Class aClass = classes[index];
            
            if (class_conformsToProtocol(aClass, appDelegateProtocol)) {
                
                if (class_respondsToSelector(aClass,
                        selfAwareSwizzlePerformingSelector))
                {
                    // Swizzle
                    
                    // Keep original
                    IMP original_imp =
                    class_getMethodImplementation(aClass,
                        selfAwareSwizzlePerformingSelector);
                    
                    CFDictionarySetValue(
                        OCSASOriginalSelfAwareSwizzlePerformerMap,
                        (__bridge const void *)(aClass),
                        original_imp);
                    
                    // Set new
                    class_replaceMethod(aClass,
                        selfAwareSwizzlePerformingSelector,
                        (IMP)&OCSASSwizzledSelfAwareSwizzlePerformer,
                        OCSASSelfAwareSwizzlePerformingSelectorEncode);
                    
                } else {
                    // Inject
                    class_addMethod(aClass,
                        selfAwareSwizzlePerformingSelector,
                        (IMP)&OCSASInjectedSelfAwareSwizzlePerformer,
                        OCSASSelfAwareSwizzlePerformingSelectorEncode);
                    
                }
                
            }
        }
        
        free(classes);
        
    });
}

IMP OCSASOriginalSelfAwareSwizzlePerformerForClass(Class aClass) {
    return (IMP) CFDictionaryGetValue(
        OCSASOriginalSelfAwareSwizzlePerformerMap,
        (__bridge const void *)(aClass));
}

#pragma mark - Self-Aware Swizzle Process
void OCSASPerformSelfAwareSwizzleOnLoadedClasses() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#if DEBUG
        NSTimeInterval start = [NSDate date].timeIntervalSinceReferenceDate;
#endif
        
        OCSASSwizzledRecords = CFDictionaryCreateMutable(kCFAllocatorDefault,
            0,
            NULL,
            &kCFTypeDictionaryValueCallBacks);
        
        // Swizzle loaded bundles
        unsigned int classCount = 0;
        
        Class * classes = objc_copyClassList(&classCount);
        
        for (unsigned int index = 0; index < classCount; index ++) {
            Class aClass = classes[index];
            OCSASScanAndActivateSelfAwareSwizzleSelectorsOnClass(aClass);
        }
        
        free(classes);
        
        CFRelease(OCSASSwizzledRecords);
        
#if DEBUG
        NSTimeInterval end = [NSDate date].timeIntervalSinceReferenceDate;
        NSLog(@"%f seconds took to complete self-aware swizzle. %u classes were scanned.",
              (end - start), classCount);
#endif
    });
}

void OCSASScanAndActivateSelfAwareSwizzleSelectorsOnClass(Class aClass) {
    char const * className = class_getName(aClass);
    Class metaClass = objc_getMetaClass(className);
    
    unsigned int methodCount = 0;
    
    Method * methods = class_copyMethodList(metaClass, &methodCount);
    
    // Scane class methods to check self swizzle selectors
    for (unsigned int index = 0; index < methodCount; index ++) {
        Method method = methods[index];
        
        SEL selector = method_getName(method);
        
        OCSASSelfAwareSwizzleSelectorMatchResult selectorMatchResult =
            OCSASMatchSelfAwareSwizzleSelector(selector);
        
        if (selectorMatchResult
                & OCSASSelfAwareSwizzleSelectorMatchResultMatched)
        {
            OCSASActivateSelfSwizzleSelector(aClass, method, selector);
        }
#if DEBUG
        else if (selectorMatchResult
                    & OCSASSelfAwareSwizzleSelectorMatchResultMatchedIgnoreCase)
        {
            NSLog(@"Found a pseudo Self-Aware Swizzle Selector, you might ignored some cases when spelt it: %@",
                  NSStringFromSelector(selector));
        }
#endif
    }
    
    free(methods);
}

OCSASSelfAwareSwizzleSelectorMatchResult
    OCSASMatchSelfAwareSwizzleSelector(SEL selector)
{
    const char * selectorName = sel_getName(selector);
    
    if (strlen(selectorName) > OCSASSelfAwareSwizzleSelectorPrefixLength) {
        if (strncmp(kOCSASSelfAwareSwizzleSelectorPrefix,
                selectorName,
                OCSASSelfAwareSwizzleSelectorPrefixLength) == 0)
        {
            return OCSASSelfAwareSwizzleSelectorMatchResultMatched;
        }
#if DEBUG
        else if (strncasecmp(kOCSASSelfAwareSwizzleSelectorPrefix,
                        selectorName,
                        OCSASSelfAwareSwizzleSelectorPrefixLength)  == 0)
        {
            return OCSASSelfAwareSwizzleSelectorMatchResultUnmatched
                | OCSASSelfAwareSwizzleSelectorMatchResultMatchedIgnoreCase;
        } else {
            return OCSASSelfAwareSwizzleSelectorMatchResultUnmatched;
        }
#endif
    }
    return OCSASSelfAwareSwizzleSelectorMatchResultUnmatched;
}

void OCSASActivateSelfSwizzleSelector(Class aClass, Method method, SEL selector)
{
    // Get self-aware swizzle context
    OCSASSelfAwareSwizzleContextGetterRef selfAwareSwizzleContextGetter =
    (OCSASSelfAwareSwizzleContextGetterRef)method_getImplementation(method);
    
    id object = (* selfAwareSwizzleContextGetter)(aClass, selector);
    
    if (object == nil) {
#if DEBUG
        NSLog(@"Expected Self-Aware Swizzle selector: %@ on %@ returns nil.",
              NSStringFromSelector(selector),
              NSStringFromClass(aClass));
#endif
        return;
    }
    
    if ([object isKindOfClass:[ObjCSelfAwareSwizzleContext class]]) {
        ObjCSelfAwareSwizzleContext * swizzleContext =
        (ObjCSelfAwareSwizzleContext *)object;
        
#if DEBUG
        SEL targetSelector = swizzleContext.targetSelector;
        if (!OCSASDoesClassHostSelfAwareSelectorOnClass(aClass,
                swizzleContext.targetClass))
        {
            NSLog(@"Class to be swizzled %@ is not the Self-Aware Swizzle selector's host class %@.",
                  NSStringFromClass(aClass),
                  NSStringFromClass(swizzleContext.targetClass));
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
        OCSASPerformSelfAwareSwizzleWithContext(swizzleContext);
    }
#if DEBUG
    else {
        NSLog(@"Unexpected Self-Aware Swizzle selector: %@ on %@ doesn't return with a value of type of %@ but %@.",
              NSStringFromSelector(selector),
              NSStringFromClass(aClass),
              NSStringFromClass([ObjCSelfAwareSwizzleContext class]),
              NSStringFromClass([object class]));
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
    ObjCSelfAwareSwizzleContext * context)
{
    Class targetClass = context.targetClass;
    
    SEL targetSelector = context.targetSelector;
    
    CFMutableDictionaryRef swizzledRecordsForClass = (CFMutableDictionaryRef)
        CFDictionaryGetValue(OCSASSwizzledRecords,
            (__bridge const void *)(targetClass));
    
    if (swizzledRecordsForClass == NULL) {
        swizzledRecordsForClass = CFDictionaryCreateMutable(kCFAllocatorDefault,
            0,
            NULL,
            &kCFTypeDictionaryValueCallBacks);
        
        CFDictionarySetValue(OCSASSwizzledRecords,
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

