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
#import "LaunchTask-UIKit.h"
#elif TARGET_OS_WATCH
#import "LaunchTask-WatchKit.h"
#elif TARGET_OS_MAC
#import "LaunchTask-AppKit.h"
#endif

#pragma mark - Types
typedef struct LTLaunchTaskInfo {
    const char * selectorPrefix;
    size_t selectorPrefixLength;
    LTLaunchTaskSelectorHandler selectorHandler;
    const void * context;
    LTLaunchTaskContextCleanupHandler contextCleanupHandler;
    int priority; // 0 by default
} LTLaunchTaskInfo;

typedef NS_OPTIONS(NSUInteger, LTLaunchTaskSelectorMatchResult) {
    LTLaunchTaskSelectorMatchResultUnmatched            = 0,
    LTLaunchTaskSelectorMatchResultMatched              = 1 << 0,
    LTLaunchTaskSelectorMatchResultMatchedIgnoreCase    = 1 << 1,
};

#pragma mark - Function Prototypes
static LTLaunchTaskInfo * LTLaunchTaskInfoCreate(
    const char *,
    const LTLaunchTaskSelectorHandler,
    const void *,
    const LTLaunchTaskContextCleanupHandler,
    int
);

static BOOL LTRegisterLaunchTaskInfo(const LTLaunchTaskInfo *);

static BOOL LTFindInjectPointAndInject();

static BOOL LTSwizzleAllPossibleAppDelegates();

static BOOL LTSwizzleExtensionPrincipalClassOrExtensionInitialViewController() ;

static id LTLaunchTaskAppExtensionPerformer(id self, SEL _cmd);

static LTLaunchTaskSelectorMatchResult LTMatchLaunchTaskSelector(
    SEL,
    const LTLaunchTaskInfo *
);

static void LTScanAndActivateLaunchTaskSelectorsOnClass(
    Class,
    const LTLaunchTaskInfo *,
    NSArray *
);

void LTSaveLaunchTaskPerformerReplacedImpForClass(Class, IMP);

// All the compare operation shall be gauranteed in a same thread.
static BOOL LTLaunchTaskInfoEqualToInfo(
    const LTLaunchTaskInfo *,
    const LTLaunchTaskInfo *
);

static void LTLaunchTaskInfoRelease(LTLaunchTaskInfo *);

static void LTLaunchTaskSelectorHandlerDefault(
    SEL,
    id,
    Method,
    NSArray *,
    const void *
);

#pragma mark - Values
static CFMutableArrayRef            kLTRegisteredLaunchTaskInfo = NULL;
static CFMutableDictionaryRef       kLTLaunchTasksPerformerReplacingMap = NULL;

#pragma mark - Function Implementations
BOOL LTRegisterLaunchTask(
    const char * selectorPrefix,
    LTLaunchTaskSelectorHandler selectorHandler,
    const void * context,
    LTLaunchTaskContextCleanupHandler contextCleanupHandler,
    int priority
    )
{
    // Create task info
    LTLaunchTaskInfo * launchTaskInfo = LTLaunchTaskInfoCreate(
        selectorPrefix,
        selectorHandler,
        context,
        contextCleanupHandler,
        priority
    );
    
    // Register task info
    if (LTRegisterLaunchTaskInfo(launchTaskInfo)) {
        return YES;
    } else {
        LTLaunchTaskInfoRelease(launchTaskInfo);
        return NO;
    }
}

LTLaunchTaskInfo * LTLaunchTaskInfoCreate(
    const char * selectorPrefix,
    LTLaunchTaskSelectorHandler launchTaskSelectorHandler,
    const void * context,
    LTLaunchTaskContextCleanupHandler contextCleanupHandler,
    int priotity
    )
{
    size_t prefixLength = strlen(selectorPrefix);
    
    char * managedSelectorPrefix = malloc(prefixLength * sizeof(char));
    memcpy(managedSelectorPrefix, selectorPrefix, prefixLength * sizeof(char));
    
    LTLaunchTaskInfo * info = malloc(sizeof(LTLaunchTaskInfo));
    
    * info = (LTLaunchTaskInfo) {
        managedSelectorPrefix,
        prefixLength,
        launchTaskSelectorHandler,
        context, 
        contextCleanupHandler,
        0
    };
    
    return info;
}

void LTLaunchTaskInfoRelease(LTLaunchTaskInfo * info) {
    free((void *)(* info).selectorPrefix);
    free(info);
}

BOOL LTRegisterLaunchTaskInfo(const LTLaunchTaskInfo * info) {
    if (kLTRegisteredLaunchTaskInfo == NULL) {
        kLTRegisteredLaunchTaskInfo = CFArrayCreateMutable(
            kCFAllocatorDefault,
            0,
            nil
        );
    }
    
    CFIndex registeredInfoCount = CFArrayGetCount(kLTRegisteredLaunchTaskInfo);
    
    for (CFIndex index = 0; index < registeredInfoCount; index ++) {
        LTLaunchTaskInfo * registeredInfo = (LTLaunchTaskInfo *)
            CFArrayGetValueAtIndex(kLTRegisteredLaunchTaskInfo, index);
        
        if (LTLaunchTaskInfoEqualToInfo(registeredInfo, info)) {
            return NO;
        }
    }
    
    CFArrayAppendValue(kLTRegisteredLaunchTaskInfo, info);
    
    return YES;
}

CFComparisonResult LTLaunchTaskInfoComparator(
    const void *val1,
    const void *val2,
    void *context
    )
{
    LTLaunchTaskInfo * info1 = (LTLaunchTaskInfo *) val1;
    LTLaunchTaskInfo * info2 = (LTLaunchTaskInfo *) val2;
    
    if (info1 -> priority > info2 -> priority) {
        return kCFCompareGreaterThan;
    } else if (info1 -> priority < info2 -> priority) {
        return kCFCompareLessThan;
    } else {
        return kCFCompareEqualTo;
    }
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
        // Swizzle loaded bundles
        unsigned int classCount = 0;
        
        if (kLTRegisteredLaunchTaskInfo != NULL) {
            CFIndex registeredInfoCount =
            CFArrayGetCount(kLTRegisteredLaunchTaskInfo);
            
            CFRange registeredInfoRange = CFRangeMake(0, registeredInfoCount);
            
            CFArraySortValues(
                kLTRegisteredLaunchTaskInfo,
                registeredInfoRange,
                &LTLaunchTaskInfoComparator,
                NULL
            );
            
            Class * classList = objc_copyClassList(&classCount);
            
            for (
                CFIndex infoIndex = 0;
                infoIndex < registeredInfoCount;
                infoIndex ++
                )
            {
                for (unsigned int classIndex = 0;
                     classIndex < classCount;
                     classIndex ++)
                {
                    Class class = classList[classIndex];
                    LTLaunchTaskInfo * info = (LTLaunchTaskInfo *)
                    CFArrayGetValueAtIndex(
                        kLTRegisteredLaunchTaskInfo,
                        infoIndex
                    );
                    
                    LTScanAndActivateLaunchTaskSelectorsOnClass(
                        class,
                        info,
                        args
                    );
                }
                
            }
            
            free(classList);
            
            for (CFIndex index = 0; index < registeredInfoCount; index ++) {
                LTLaunchTaskInfo * registeredInfo = (LTLaunchTaskInfo *)
                CFArrayGetValueAtIndex(kLTRegisteredLaunchTaskInfo, index);
                
                if (registeredInfo->contextCleanupHandler != NULL) {
                    const void * context = registeredInfo->context;
                    NSCAssert(context != NULL,
                              @"Context shall not be NULL here");
                    LTLaunchTaskContextCleanupHandler cleanupHandler =
                    registeredInfo->contextCleanupHandler;
                    
                    (*cleanupHandler)((void *)context);
                }
                
                LTLaunchTaskInfoRelease(registeredInfo);
            }
            
            CFRelease(kLTRegisteredLaunchTaskInfo);
        }
        
#if DEBUG
        NSTimeInterval end = [NSDate date].timeIntervalSinceReferenceDate;
        NSLog(@"%f seconds took to complete all launch tasks. %u classes were scanned.",
              (end - start), classCount);
#endif
    });
    
}

void LTScanAndActivateLaunchTaskSelectorsOnClass(
    Class aClass,
    const LTLaunchTaskInfo * info,
    NSArray * args
    )
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
        
        if (selectorMatchResult & LTLaunchTaskSelectorMatchResultMatched) {
            const void * context = info -> context;
            info -> selectorHandler(selector, aClass, method, args, context);
        }
#if DEBUG
        else if (selectorMatchResult
                 & LTLaunchTaskSelectorMatchResultMatchedIgnoreCase)
        {
            NSLog(@"Found a pseudo launch task Selector, you might ignored some cases when spelling it: %@",
                  NSStringFromSelector(selector));
        }
#endif
    }
    
    free(methods);
}

LTLaunchTaskSelectorMatchResult LTMatchLaunchTaskSelector(
    SEL selector,
    const LTLaunchTaskInfo * info
    )
{
    const char * expectedSelectorPrefix = info -> selectorPrefix;
    size_t expectedSelectorPrefixLength = info -> selectorPrefixLength;
    
    const char * selectorName = sel_getName(selector);
    
    if (strncmp(
            expectedSelectorPrefix,
            selectorName,
            expectedSelectorPrefixLength
        ) == 0
        )
    {
        return LTLaunchTaskSelectorMatchResultMatched;
    }
#if DEBUG
    else if (strncasecmp(
                expectedSelectorPrefix,
                selectorName,
                expectedSelectorPrefixLength
             ) == 0
             )
    {
        return LTLaunchTaskSelectorMatchResultUnmatched
        | LTLaunchTaskSelectorMatchResultMatchedIgnoreCase;
    } else {
        return LTLaunchTaskSelectorMatchResultUnmatched;
    }
#else
    return LTLaunchTaskSelectorMatchResultUnmatched;
#endif
}

void LTLaunchTaskSelectorHandlerDefault(
    SEL selector,
    id owner,
    Method method,
    NSArray * args,
    const void * context
    )
{
    unsigned int taskMethodArgCount = method_getNumberOfArguments(method);
    
    int availableArgCount = (int) taskMethodArgCount - 2;
    
    NSCAssert(availableArgCount >= 0, @"Invalid argument count!");
    
    int taskArgCount = (int) [args count];
    
    struct objc_method_description * taskMethodDescription =
        method_getDescription(method);
    
    NSMethodSignature * taskMethodSignature =
    [NSMethodSignature signatureWithObjCTypes:taskMethodDescription -> types];
    
    NSInvocation * taskMethodInvocation =
    [NSInvocation invocationWithMethodSignature:taskMethodSignature];
    
    taskMethodInvocation.target = owner;
    taskMethodInvocation.selector = selector;
    
    int argumentsToSend = MIN(taskArgCount, availableArgCount);
    
    for (int idx = 0; idx < 0 + argumentsToSend; idx ++) {
        [taskMethodInvocation setArgument: (__bridge void *)(args[idx])
                                  atIndex: idx + 2];
    }
    
    [taskMethodInvocation invoke];
}

BOOL LTLaunchTaskInfoEqualToInfo(
    const LTLaunchTaskInfo * info1,
    const LTLaunchTaskInfo * info2
    )
{
    return (strcmp(info1 -> selectorPrefix, info2 -> selectorPrefix) == 0)
    && info1 -> selectorPrefixLength    == info2 -> selectorPrefixLength
    && info1 -> selectorHandler         == info2 -> selectorHandler
    && info1 -> contextCleanupHandler   == info2 -> contextCleanupHandler;
}

#pragma mark - Launch Task Preprocess
BOOL LTFindInjectPointAndInject() {
    if (LTSwizzleAllPossibleAppDelegates()) {
        return YES;
    } else if (LTSwizzleExtensionPrincipalClassOrExtensionInitialViewController()) {
        return YES;
    }
    return NO;
}

BOOL LTSwizzleAllPossibleAppDelegates() {
    __block BOOL success = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Return early for app extensions. Because no app delegate here.
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@"appex"]) {
            return;
        }
        
        // Inject implementation in to all classes conforms to process delegate
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
                    class_getMethodImplementation(
                        eachClass,
                        selector_launchTasksPerform
                    );
                    
                    LTSaveLaunchTaskPerformerReplacedImpForClass(eachClass, original_imp);
                    
                    // Set new
                    class_replaceMethod(
                        eachClass,
                        selector_launchTasksPerform,
                        (IMP)&LTSwizzledLaunchTasksPerformer,
                        LTLaunchTasksPerformSelectorEncode
                    );
                    success = success || YES;
                } else {
                    // Inject
                    class_addMethod(
                        eachClass,
                        selector_launchTasksPerform,
                        (IMP)&LTInjectedLaunchTasksPerformer,
                        LTLaunchTasksPerformSelectorEncode
                    );
                    success = success || YES;
                }
                
            }
        }
        
        free(classes);
        
    });
    return success;
}

BOOL LTSwizzleExtensionPrincipalClassOrExtensionInitialViewController() {
    __block BOOL success = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary * extensionInfo = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSExtension"];
        
        NSString * extensionPricipalClassName = extensionInfo[@"NSExtensionPrincipalClass"];
        
        if (extensionPricipalClassName) {
            // Investiage initializers
            Class extensionPricipalClass = NSClassFromString(extensionPricipalClassName);
            unsigned int methodCount = 0;
            Method * methods = class_copyMethodList(extensionPricipalClass, &methodCount);
            for (unsigned int idx = 0; idx < methodCount; idx ++) {
                Method eachMethod = methods[idx];
                SEL methodName = method_getName(eachMethod);
                NSString * methodString = NSStringFromSelector(methodName);
                if ([methodString isEqualToString:@"init"]) {
                    IMP original_imp = class_replaceMethod(extensionPricipalClass, methodName, (IMP)&LTLaunchTaskAppExtensionPerformer, "@:");
                    LTSaveLaunchTaskPerformerReplacedImpForClass(extensionPricipalClass, original_imp);
                    success = YES;
                    break;
                }
            }
            free(methods);
        }
    });
    return success;
}

IMP LTLaunchTaskPerformerReplacedImpForClass(Class aClass) {
    if (kLTLaunchTasksPerformerReplacingMap == NULL) {
        kLTLaunchTasksPerformerReplacingMap =
        CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
    }
    return (IMP) CFDictionaryGetValue(kLTLaunchTasksPerformerReplacingMap,
        (__bridge const void *)(aClass));
}

void LTSaveLaunchTaskPerformerReplacedImpForClass(Class aClass, IMP impl) {
    if (kLTLaunchTasksPerformerReplacingMap == NULL) {
        kLTLaunchTasksPerformerReplacingMap =
        CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
    }
    CFDictionarySetValue(
        kLTLaunchTasksPerformerReplacingMap,
        (__bridge const void *)(aClass),
        impl
    );
}

id LTLaunchTaskAppExtensionPerformer(id self, SEL _cmd) {
    LTPerformLaunchTasksOnLoadedClasses(nil);
    Class class = [self class];
    
    id (*original_imp)(id, SEL) = (id (*)(id, SEL))
    LTLaunchTaskPerformerReplacedImpForClass(class);
    
    if (original_imp != NULL) {
        return original_imp(self, _cmd);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
        return nil;
    }
}

@interface NSObject(LaunchTask)
@end

@implementation NSObject(LaunchTask)
+ (void)load {
    if (!LTFindInjectPointAndInject()) {
#if DEBUG
        NSLog(@"Inject point not found for main bundle: %@", [NSBundle mainBundle]);
#endif
    }
    
    LTRegisterLaunchTask(
        "_LaunchTask_",
        &LTLaunchTaskSelectorHandlerDefault,
        NULL,
        NULL,
        0
    );
}
@end


