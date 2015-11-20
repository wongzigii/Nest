//
//  ObjCSelfAwareSwizzleUtilities.m
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import ObjectiveC;

#import <Nest/ObjCSelfAwareSwizzleInfo.h>

#if TARGET_OS_IOS
#import "ObjCSelfAwareSwizzleUtilities+UIKit.h"
#elif TARGET_OS_TV
#import "ObjCSelfAwareSwizzleUtilities+UIKit.h"
#elif TARGET_OS_WATCH
#import "ObjCSelfAwareSwizzleUtilities+WatchKit.h"
#elif TARGET_OS_MAC
#import "ObjCSelfAwareSwizzleUtilities+AppKit.h"
#endif

#import "ObjCSelfAwareSwizzleUtilities.h"

static const char * kOCSASSelfAwareSwizzleSelectorPrefix =
"_ObjCSelfAwareSwizzle_";

#define OCSASSelfAwareSwizzleSelectorMinLength 22

typedef ObjCSelfAwareSwizzleInfo * OCSASSelfSwizzleInfoGetter(id, SEL);

typedef OCSASSelfSwizzleInfoGetter * OCSASSelfSwizzleInfoGetterRef;

static void OCSASScanAndActivateSelfAwareSwizzleSelectorsOnClass(Class);
static BOOL OCSASIsSelfAwareSwizzleSelector(char const *);
static void OCSASActivateSelfSwizzleSelector(Class, Method, SEL);
static void OCSASPerformSelfAwareSwizzleWithInfo(ObjCSelfAwareSwizzleInfo *);

static CFMutableDictionaryRef OCSASOriginalProcessDidFinishLaunchingImpDict;

#pragma mark - Self-Aware Swizzle Process
void OCSASSwizzleAllPossibleProcessDelegates() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Inject implementation in to all classes conforms to process delegate
        
        OCSASOriginalProcessDidFinishLaunchingImpDict =
        CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
        
        Protocol * processDelegate =
        @protocol(OCSASProcessDelegate);
        
        SEL processDidFinishLaunching =
        @selector(OCSASProcessDidFinishLaunching);
        
        unsigned int classCount = 0;
        
        Class * classes = objc_copyClassList(&classCount);
        
        for (unsigned int index = 0; index < classCount; index ++) {
            Class aClass = classes[index];
            
            if (class_conformsToProtocol(aClass, processDelegate)) {
                
                if (class_respondsToSelector(aClass,
                        processDidFinishLaunching))
                {
                    // Swizzle
                    
                    // Keep original
                    IMP original_imp =
                    class_getMethodImplementation(aClass,
                        processDidFinishLaunching);
                    
                    CFDictionarySetValue(
                        OCSASOriginalProcessDidFinishLaunchingImpDict,
                        (__bridge const void *)(aClass),
                        original_imp);
                    
                    // Set new
                    class_replaceMethod(aClass,
                        processDidFinishLaunching,
                        (IMP)&OCSASSwizzledProcessDidFinishLaunching,
                        OCSASProcessDidFinishLaunchingEncode);
                    
                } else {
                    // Inject
                    class_addMethod(aClass,
                        processDidFinishLaunching,
                        (IMP)&OCSASInjectedProcessDidFinishLaunching,
                        OCSASProcessDidFinishLaunchingEncode);
                    
                }
                
            }
        }
        
        free(classes);
        
    });
}

void OCSASPerformSelfAwareSwizzleOnLoadedClasses() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if DEBUG
        NSTimeInterval start = [NSDate date].timeIntervalSinceReferenceDate;
#endif
        
        // Swizzle loaded bundles
        unsigned int classCount = 0;
        
        Class * classes = objc_copyClassList(&classCount);
        
        for (unsigned int index = 0; index < classCount; index ++) {
            Class aClass = classes[index];
            OCSASScanAndActivateSelfAwareSwizzleSelectorsOnClass(aClass);
        }
        
        free(classes);
        
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
        const char * selectorName = sel_getName(selector);
        
        if (OCSASIsSelfAwareSwizzleSelector(selectorName)) {
            // Self-aware swizzle selector found!
            OCSASActivateSelfSwizzleSelector(aClass, method, selector);
        }
    }
    
    free(methods);
}

BOOL OCSASIsSelfAwareSwizzleSelector(char const * selectorName) {
    if (strlen(selectorName) > OCSASSelfAwareSwizzleSelectorMinLength) {
        
        return strncmp(
            kOCSASSelfAwareSwizzleSelectorPrefix,
            selectorName,
            OCSASSelfAwareSwizzleSelectorMinLength)
        == 0;
        
    }
    return NO;
}

void OCSASActivateSelfSwizzleSelector(Class aClass, Method method, SEL selector)
{
    // Get self-aware swizzle info
    IMP imp_selfSwizzleInfoGetter = method_getImplementation(method);
    
    OCSASSelfSwizzleInfoGetterRef selfSwizzleInfoGetter =
    (OCSASSelfSwizzleInfoGetterRef) imp_selfSwizzleInfoGetter;
    
    id object = (* selfSwizzleInfoGetter)(aClass, selector);
    
    if (object == nil) {
#if DEBUG
        NSLog(@"Expected Self-Aware Swizzle selector: %@ on %@ returns nil.",
              NSStringFromSelector(selector),
              NSStringFromClass(aClass));
#endif
        return;
    }
    
    if ([object isKindOfClass:[ObjCSelfAwareSwizzleInfo class]]) {
        ObjCSelfAwareSwizzleInfo * swizzleInfo =
        (ObjCSelfAwareSwizzleInfo *)object;
        
#if DEBUG
        SEL targetSelector = swizzleInfo.targetSelector;
        if (aClass != swizzleInfo.targetClass) {
            NSLog(@"Class to be swizzled %@ is not Self-Aware Swizzle selector's host class %@.",
                  NSStringFromClass(aClass),
                  NSStringFromClass(swizzleInfo.targetClass));
        }
        if (targetSelector == NSSelectorFromString(@"dealloc")) {
            NSLog(@"Swizzling against -dealloc is discouraged!");
        }
        if (targetSelector == NSSelectorFromString(@"retain")) {
            NSLog(@"Swizzling against -reatain is discouraged!");
        }
        if (targetSelector == NSSelectorFromString(@"release")) {
            NSLog(@"Swizzling against -release is discouraged!");
        }
        if (targetSelector == NSSelectorFromString(@"retainCount")) {
            NSLog(@"Swizzling against -retainCount is discouraged!");
        }
#endif
        OCSASPerformSelfAwareSwizzleWithInfo(swizzleInfo);
    } else {
#if DEBUG
        NSLog(@"Expected Self-Aware Swizzle selector: %@ on %@ doesn't return with value of type of %@ but %@.",
              NSStringFromSelector(selector),
              NSStringFromClass(aClass),
              NSStringFromClass([ObjCSelfAwareSwizzleInfo class]),
              NSStringFromClass([object class]));
#endif
    }
}

void OCSASPerformSelfAwareSwizzleWithInfo(ObjCSelfAwareSwizzleInfo * info) {
    
    Class targetClass = info.targetClass;
    
    SEL targetSelector = info.targetSelector;
    
    IMP originalImp =
    class_getMethodImplementation(targetClass, targetSelector);
    
    if (originalImp == NULL) {
#if DEBUG
        NSLog(@"Selector -%@ on %@ to swizzle doesn't have implementation.",
              NSStringFromSelector(targetSelector),
              NSStringFromClass(targetClass));
#endif
    } else {
        IMP swizzledImp = info.implementationExchange(originalImp);
        
        Method targetMethod =
        class_getInstanceMethod(targetClass, targetSelector);
        
        char const * encoding = method_getTypeEncoding(targetMethod);
        
        class_replaceMethod(targetClass, targetSelector, swizzledImp, encoding);
        
#if DEBUG
        NSLog(@"Swizzled -%@ on %@",
              NSStringFromSelector(targetSelector),
              NSStringFromClass(targetClass));
#endif
    }
}

IMP OCSASOriginalProcessDidFinishLaunchingImplementationForClass(Class aClass) {
    return (IMP) CFDictionaryGetValue(
        OCSASOriginalProcessDidFinishLaunchingImpDict,
        (__bridge const void *)(aClass));
}