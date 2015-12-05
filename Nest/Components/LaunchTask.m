//
//  LaunchTask.m
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

#import "LaunchTask.h"
#import "LaunchTaskInternal.h"

#if TARGET_OS_IOS || TARGET_OS_TV
#import "LaunchTask+UIKit.h"
#elif TARGET_OS_WATCH
#import "LaunchTask+WatchKit.h"
#elif TARGET_OS_MAC
#import "LaunchTask+AppKit.h"
#endif

typedef NS_OPTIONS(NSUInteger, LTLaunchTaskSelectorMatchResult) {
    LTLaunchTaskSelectorMatchResultUnmatched            = 0,
    LTLaunchTaskSelectorMatchResultMatched              = 1 << 0,
    LTLaunchTaskSelectorMatchResultMatchedIgnoreCase    = 1 << 1,
};

static void LTSwizzleAllPossibleAppDelegates();
static LTLaunchTaskSelectorMatchResult LTMatchLaunchTaskSelector(SEL,
    LTLaunchTaskInfo *);
void LTScanAndActivateLaunchTaskSelectorsOnClass(Class,
    LTLaunchTaskInfo *,
    NSArray *);

// All the compare operation shall be gauranteed in a same thread.
BOOL LTLaunchTaskInfoEqualToInfo(LTLaunchTaskInfo *, LTLaunchTaskInfo *);

static LTLaunchTaskSelectorHandler LTLaunchTaskSelectorHandlerDefault;

static CFMutableArrayRef        kLTRegisteredLaunchTaskInfos = NULL;
static CFMutableDictionaryRef   kLTLaunchTasksPerformerReplacingMap = NULL;

static LTLaunchTaskInfo         kLTLaunchTaskInfoDefault = {
    "_LaunchTask_",
    12,
    &LTLaunchTaskSelectorHandlerDefault
};

#pragma mark - Extern Variables

LTLaunchTaskInfo LTLaunchTaskInfoMake(const char * selectorPrefix,
    LTLaunchTaskSelectorHandlerRef launchTaskSelectorHandler,
    void * context,
    LTLaunchTaskContextCleanupHandlerRef contextCleanupHandler)
{
    size_t prefixLength = strlen(selectorPrefix);
    
    LTLaunchTaskInfo info = (LTLaunchTaskInfo) {
        "\0",
        prefixLength,
        launchTaskSelectorHandler,
        context, 
        contextCleanupHandler
    };
    
    int offset = 0;
    char selectorChar = selectorPrefix[offset];
    while (selectorChar != '\0'
           && offset <= LTLaunchTaskSelectorPrefixMaxLength)
    {
        info.selectorPrefix[offset] = selectorPrefix[offset];
        offset ++;
    }
    
    return info;
}

BOOL LTRegisterLaunchTaskInfo(LTLaunchTaskInfo info) {
    if (kLTRegisteredLaunchTaskInfos == NULL) {
        kLTRegisteredLaunchTaskInfos = CFArrayCreateMutable(kCFAllocatorDefault,
            0, nil);
    }
    
    CFIndex registeredInfoCount = CFArrayGetCount(kLTRegisteredLaunchTaskInfos);
    
    for (CFIndex index = 0; index < registeredInfoCount; index ++) {
        LTLaunchTaskInfo * registeredInfo = (LTLaunchTaskInfo *)
            CFArrayGetValueAtIndex(kLTRegisteredLaunchTaskInfos, index);
        
        if (LTLaunchTaskInfoEqualToInfo(registeredInfo, &info)) {
            return NO;
        }
    }
    
    LTLaunchTaskInfo * infoRef = malloc(sizeof(LTLaunchTaskInfo));
    
    memcpy(infoRef, &info, sizeof(LTLaunchTaskInfo));
    
    CFArrayAppendValue(kLTRegisteredLaunchTaskInfos, infoRef);
    
    return YES;
}

#pragma mark - Launch Task Process
void LTPerformLaunchTasksOnLoadedClasses(id firstArg, ...) {
    NSMutableArray * args = [[NSMutableArray alloc] init];
    
    va_list argList;
    va_start(argList, firstArg);
    while (firstArg != nil) {
        [args addObject:firstArg];
        firstArg = va_arg(argList, id);
    }
    va_end(argList);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if DEBUG
        NSTimeInterval start = [NSDate date].timeIntervalSinceReferenceDate;
#endif
        
        CFIndex registeredInfoCount =
        CFArrayGetCount(kLTRegisteredLaunchTaskInfos);
        
        // Swizzle loaded bundles
        unsigned int classCount = 0;
        
        Class * classList = objc_copyClassList(&classCount);
        
        for (unsigned int index = 0; index < classCount; index ++) {
            Class class = classList[index];
            
            for (CFIndex index = 0; index < registeredInfoCount; index ++) {
                LTLaunchTaskInfo * info = (LTLaunchTaskInfo *)
                CFArrayGetValueAtIndex(kLTRegisteredLaunchTaskInfos, index);
                
                LTScanAndActivateLaunchTaskSelectorsOnClass(class, info, args);
            }
        }
        
        free(classList);
        
        if (kLTRegisteredLaunchTaskInfos != NULL) {
            CFIndex registeredInfoCount =
            CFArrayGetCount(kLTRegisteredLaunchTaskInfos);
            
            for (CFIndex index = 0; index < registeredInfoCount; index ++) {
                LTLaunchTaskInfo * registeredInfo = (LTLaunchTaskInfo *)
                CFArrayGetValueAtIndex(kLTRegisteredLaunchTaskInfos, index);
                
                if (registeredInfo->contextCleanupHandler != NULL) {
                    void * context = registeredInfo->context;
                    NSCAssert(context != NULL,
                        @"Context shall not be NULL here");
                    LTLaunchTaskContextCleanupHandlerRef cleanupHandler =
                        registeredInfo->contextCleanupHandler;
                    
                    (*cleanupHandler)(context);
                }
                
                free(registeredInfo);
            }
            
            CFRelease(kLTRegisteredLaunchTaskInfos);
        }
        
#if DEBUG
        NSTimeInterval end = [NSDate date].timeIntervalSinceReferenceDate;
        NSLog(@"%f seconds took to complete all launch tasks. %u classes were scanned.",
              (end - start), classCount);
#endif
    });
    
}

void LTScanAndActivateLaunchTaskSelectorsOnClass(Class aClass,
    LTLaunchTaskInfo * info,
    NSArray * args)
{
    char const * className = class_getName(aClass);
    Class metaClass = objc_getMetaClass(className);
    
    unsigned int methodCount = 0;
    
    Method * methods = class_copyMethodList(metaClass, &methodCount);
    
    // Scane class methods to check self swizzle selectors
    for (unsigned int index = 0; index < methodCount; index ++) {
        Method method = methods[index];
        
        SEL selector = method_getName(method);
        
        LTLaunchTaskSelectorMatchResult selectorMatchResult =
        LTMatchLaunchTaskSelector(selector, info);
        
        if (selectorMatchResult
            & LTLaunchTaskSelectorMatchResultMatched)
        {
            void * context = info -> context;
            info -> selectorHandler(selector, aClass, method, args, context);
        }
#if DEBUG
        else if (selectorMatchResult
                 & LTLaunchTaskSelectorMatchResultMatchedIgnoreCase)
        {
            NSLog(@"Found a pseudo launch task Selector, you might ignored some cases when spelt it: %@",
                  NSStringFromSelector(selector));
        }
#endif
    }
    
    free(methods);
}

LTLaunchTaskSelectorMatchResult LTMatchLaunchTaskSelector(SEL selector,
    LTLaunchTaskInfo * info)
{
    const char * expectedSelectorPrefix = info -> selectorPrefix;
    size_t expectedSelectorPrefixLength = info -> selectorPrefixLength;
    
    const char * selectorName = sel_getName(selector);
    
    if (strncmp(expectedSelectorPrefix,
                selectorName,
                expectedSelectorPrefixLength)
        == 0)
    {
        return LTLaunchTaskSelectorMatchResultMatched;
    }
#if DEBUG
    else if (strncasecmp(expectedSelectorPrefix,
                         selectorName,
                         expectedSelectorPrefixLength)
             == 0)
    {
        return LTLaunchTaskSelectorMatchResultUnmatched
        | LTLaunchTaskSelectorMatchResultMatchedIgnoreCase;
    } else {
        return LTLaunchTaskSelectorMatchResultUnmatched;
    }
#endif
}

void LTLaunchTaskSelectorHandlerDefault(SEL taskSelector,
    id taskOwner,
    Method taskMethod,
    NSArray * taskArgs,
    void * taskContext)
{
    unsigned int taskMethodArgCount = method_getNumberOfArguments(taskMethod);
    
    int availableArgCount = (int) taskMethodArgCount - 2;
    
    NSCAssert(availableArgCount >= 0, @"Invalid argument count!");
    
    NSUInteger taskArgCount = [taskArgs count];
    
    struct objc_method_description * taskMethodDescription =
        method_getDescription(taskMethod);
    
    NSMethodSignature * taskMethodSignature =
    [NSMethodSignature signatureWithObjCTypes:taskMethodDescription -> types];
    
    NSInvocation * taskMethodInvocation =
    [NSInvocation invocationWithMethodSignature:taskMethodSignature];
    
    [taskMethodInvocation setTarget:taskOwner];
    [taskMethodInvocation setSelector:taskSelector];
    
    int argumentsToSend = MIN(taskArgCount, availableArgCount);
    
    for (int idx = 0; idx < 0 + argumentsToSend; idx ++) {
        [taskMethodInvocation setArgument: (__bridge void *)(taskArgs[idx])
                                  atIndex: idx + 2];
    }
    
    [taskMethodInvocation invoke];
}

BOOL LTLaunchTaskInfoEqualToInfo(LTLaunchTaskInfo * info1,
    LTLaunchTaskInfo * info2)
{
    return (strcmp(info1 -> selectorPrefix, info2 -> selectorPrefix) == 0)
    && info1 -> selectorPrefixLength    == info2 -> selectorPrefixLength
    && info1 -> selectorHandler         == info2 -> selectorHandler
    && info1 -> contextCleanupHandler   == info2 -> contextCleanupHandler;
}

#pragma mark - Internal
void LTSwizzleAllPossibleAppDelegates() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Inject implementation in to all classes conforms to process delegate
        
        kLTLaunchTasksPerformerReplacingMap =
        CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
        
        Protocol * protocol_appDelegate =
        @protocol(LTAppDelegate);
        
        SEL selector_launchTasksPerform =
        @selector(LTLaunchTasksPerformSelector);
        
        unsigned int classCount = 0;
        
        Class * classes = objc_copyClassList(&classCount);
        
        for (unsigned int index = 0; index < classCount; index ++) {
            Class eachClass = classes[index];
            
            if (class_conformsToProtocol(eachClass, protocol_appDelegate)) {
                
                if (class_respondsToSelector(eachClass,
                    selector_launchTasksPerform))
                {
                    // Swizzle
                    
                    // Keep original
                    IMP original_imp =
                    class_getMethodImplementation(eachClass,
                        selector_launchTasksPerform);
                    
                    CFDictionarySetValue(kLTLaunchTasksPerformerReplacingMap,
                        (__bridge const void *)(eachClass),
                        original_imp);
                    
                    // Set new
                    class_replaceMethod(eachClass,
                        selector_launchTasksPerform,
                        (IMP)&LTSwizzledLaunchTasksPerformer,
                        LTLaunchTasksPerformSelectorEncode);
                    
                } else {
                    // Inject
                    class_addMethod(eachClass,
                        selector_launchTasksPerform,
                        (IMP)&LTInjectedLaunchTasksPerformer,
                        LTLaunchTasksPerformSelectorEncode);
                    
                }
                
            }
        }
        
        free(classes);
        
    });
}

IMP LTLaunchTaskPerformerReplacedImpForClass(Class aClass) {
    return (IMP) CFDictionaryGetValue(kLTLaunchTasksPerformerReplacingMap,
        (__bridge const void *)(aClass));
}

#pragma mark - Launch Task Preprocess
@interface NSObject(LaunchTask)
@end

@implementation NSObject(LaunchTask)
+ (void)load {
    NSLog(@"NSObject(LaunchTask) was loaded");
    LTSwizzleAllPossibleAppDelegates();
    LTRegisterLaunchTaskInfo(kLTLaunchTaskInfoDefault);
}
@end
