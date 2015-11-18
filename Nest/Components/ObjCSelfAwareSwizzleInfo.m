//
//  ObjCSelfAwareSwizzleInfo.m
//  Nest
//
//  Created by Manfred on 11/18/15.
//
//

@import ObjectiveC;
@import Foundation;

#import "ObjCSelfAwareSwizzleInfo.h"

#if TARGET_OS_IOS || TARGET_OS_TV

@import UIKit;

#define ApplicationDidFinishLaunchingNotification UIApplicationDidFinishLaunchingNotification

#elif TARGET_OS_WATCH

#elif TARGET_OS_MAC

@import AppKit;

#define ApplicationDidFinishLaunchingNotification NSApplicationDidFinishLaunchingNotification

#endif

@class ApplicationLaunchFinishingObserver;

static const char * kSelfAwareSwizzleSelectorNameTemplate =
"_nest_selfAwareSwizzle_";

#define SELF_AWARE_SWIZZLE_SELECTOR_MIN_LENGTH 23

static NSMutableDictionary * kSelfAwareSwizzleInfoDict = NULL;
static OSSpinLock kSelfAwareSwizzleInfoLock = OS_SPINLOCK_INIT;

typedef ObjCSelfAwareSwizzleInfo * SelfSwizzleInfoGetter(id, SEL);
typedef SelfSwizzleInfoGetter * SelfSwizzleInfoGetterRef;

static void scanAndActivateSelfAwareSwizzleSelectorsOnClass(Class);
static BOOL isSelfAwareSwizzleSelector(char const * selectorName);
static void processSelfSwizzleSelector(Class, Method, SEL);
static void swizzleWithInfo(ObjCSelfAwareSwizzleInfo * info);

static dispatch_once_t sharedAppLaunchFinishingObserverToken;
static ApplicationLaunchFinishingObserver * sharedAppLaunchFinishingObserver;

#pragma mark - ObjCSelfAwareSwizzleInfo
@implementation ObjCSelfAwareSwizzleInfo
- (instancetype)initWithTargetClass:(Class)targetClass
                           selector:(SEL)selector
             implementationExchange:(ImplementationExchange)implementationExchange
{
    self = [super init];
    if (self) {
        _targetClass = targetClass;
        _targetSelector = selector;
        _implementationExchange = implementationExchange;
    }
    return self;
}
@end

#pragma mark - ApplicationLaunchFinishingObserver
@interface ApplicationLaunchFinishingObserver : NSObject
@end

@implementation ApplicationLaunchFinishingObserver
- (instancetype)init {
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(applicationDidFinishLaunching:)
         name:ApplicationDidFinishLaunchingNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ApplicationDidFinishLaunchingNotification
     object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
#if DEBUG
    NSTimeInterval start = [NSDate date].timeIntervalSinceReferenceDate;
#endif
    
    // Swizzle loaded bundles
    unsigned int classCount = 0;
    
    Class * classes = objc_copyClassList(&classCount);
    
    for (unsigned int index = 0; index < classCount; index ++) {
        Class aClass = classes[index];
        
        scanAndActivateSelfAwareSwizzleSelectorsOnClass(aClass);
    }
    
    free(classes);

#if DEBUG
    NSTimeInterval end = [NSDate date].timeIntervalSinceReferenceDate;
    
    NSLog(@"%f seconds took to complete self-aware swizzle. %u classes were scanned.",
          (end - start), classCount);
#endif
}
@end

#pragma mark - NSObject Swizzle Initialization
@interface NSObject (SelfAwareSwizzle)
@end

@implementation NSObject (SelfAwareSwizzle)
+ (void)load {
    dispatch_once(&sharedAppLaunchFinishingObserverToken, ^{
        sharedAppLaunchFinishingObserver =
        [[ApplicationLaunchFinishingObserver alloc] init];
    });
}
@end

void scanAndActivateSelfAwareSwizzleSelectorsOnClass(Class aClass) {
    char const * className = class_getName(aClass);
    Class metaClass = objc_getMetaClass(className);
    
    unsigned int methodCount = 0;
    
    Method * methods = class_copyMethodList(metaClass, &methodCount);
    
    // Scane class methods to check self swizzle selectors
    for (unsigned int index = 0; index < methodCount; index ++) {
        Method method = methods[index];
        
        SEL selector = method_getName(method);
        const char * selectorName = sel_getName(selector);
        
        if (isSelfAwareSwizzleSelector(selectorName)) {
            // Self-aware swizzle selector found!
            processSelfSwizzleSelector(aClass, method, selector);
        }
    }
    
    free(methods);
}

BOOL isSelfAwareSwizzleSelector(char const * selectorName) {
    if (strlen(selectorName) > SELF_AWARE_SWIZZLE_SELECTOR_MIN_LENGTH) {
        return strncmp(kSelfAwareSwizzleSelectorNameTemplate,
                       selectorName,
                       SELF_AWARE_SWIZZLE_SELECTOR_MIN_LENGTH)
        == 0;
    }
    return NO;
}

void processSelfSwizzleSelector(Class aClass, Method method, SEL selector) {
    // Get self-aware swizzle info
    IMP imp_selfSwizzleInfoGetter = method_getImplementation(method);
    
    SelfSwizzleInfoGetterRef selfSwizzleInfoGetter =
    (SelfSwizzleInfoGetterRef) imp_selfSwizzleInfoGetter;
    
    ObjCSelfAwareSwizzleInfo * swizzleInfo = (* selfSwizzleInfoGetter)
    (aClass, selector);
    
    if (aClass != swizzleInfo.targetClass) {
        NSLog(@"Class to swizzle %@ is not equal to %@",
              NSStringFromClass(aClass),
              NSStringFromClass(swizzleInfo.targetClass));
    }
    
    swizzleWithInfo(swizzleInfo);
}

void swizzleWithInfo(ObjCSelfAwareSwizzleInfo * info) {
    while (!OSSpinLockTry(&kSelfAwareSwizzleInfoLock)) {}
    
    if (kSelfAwareSwizzleInfoDict == NULL) {
        kSelfAwareSwizzleInfoDict = [[NSMutableDictionary alloc] init];
    }
    
    Class targetClass = info.targetClass;
    
    SEL targetSelector = info.targetSelector;
    
    NSString * className = NSStringFromClass(targetClass);
    NSString * selectorName = NSStringFromSelector(targetSelector);
    
    // Use CF functions here to avoid Objective-C dynamic dispatch
    NSMutableDictionary * swizzledSelectors =
    CFDictionaryGetValue((__bridge const CFMutableDictionaryRef)kSelfAwareSwizzleInfoDict,
                         (__bridge const void *)(className));
    
    if (swizzledSelectors == nil) {
        swizzledSelectors = [[NSMutableDictionary alloc] init];
        
        CFDictionarySetValue((__bridge const CFMutableDictionaryRef)kSelfAwareSwizzleInfoDict,
                             (__bridge const void *)(className),
                             (__bridge const void *)(swizzledSelectors));
    }
    
    id flag = CFDictionaryGetValue((__bridge const CFMutableDictionaryRef)swizzledSelectors,
                                   (__bridge const void *)(selectorName));
    
    if (!flag) {
        IMP impOriginal =
        class_getMethodImplementation(targetClass, targetSelector);
        
        IMP impSwizzled = info.implementationExchange(impOriginal);
        
        Method targetMethod =
        class_getInstanceMethod(targetClass, targetSelector);
        
        char const * encoding = method_getTypeEncoding(targetMethod);
        
        class_replaceMethod(targetClass, targetSelector, impSwizzled, encoding);
        
        CFDictionarySetValue((__bridge const CFMutableDictionaryRef)swizzledSelectors,
                             (__bridge const void *)(selectorName),
                             (__bridge const void *)(@YES));
    }
    
    OSSpinLockUnlock(&kSelfAwareSwizzleInfoLock);
}