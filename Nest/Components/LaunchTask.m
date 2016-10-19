//
//  LaunchTask.m
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

#import "LaunchTask.h"
#import "LaunchTask+Internal.h"

@import Darwin;

#pragma mark - Types
typedef struct _LTLaunchTaskInfo {
    const char * selectorPrefix;
    size_t selectorPrefixLength;
    LTLaunchTaskHandler selectorHandler;
    const void * context;
    LTLaunchTaskContextCleanupHandler contextCleanupHandler;
    int priority; // 0 by default
} LTLaunchTaskInfo;

typedef NS_ENUM(NSInteger, LTApplicationUserInterfaceCreationApproach) {
    LTApplicationUserInterfaceCreationApproachNib,
    LTApplicationUserInterfaceCreationApproachStoryboard,
    LTApplicationUserInterfaceCreationApproachProgramatic,
};

typedef NS_ENUM(NSInteger, LTExtensionUserInterfaceCreationApproach) {
    LTExtensionUserInterfaceCreationApproachStoryboard,
    LTExtensionUserInterfaceCreationApproachExtensionPrincipalClass,
};

typedef NS_OPTIONS(NSUInteger, LTLaunchTaskSelectorMatchResult) {
    LTLaunchTaskSelectorUnmatched           = 0,
    LTLaunchTaskSelectorMatched             = 1 << 0,
#if DEBUG
    LTLaunchTaskSelectorMatchedIgnoreCase   = 1 << 1,
#endif
};

typedef struct _LTBufferedClassInvokeContext {
    LTLaunchTaskInfo * taskInfo;
    void * argumentsArray;
} LTBufferedClassInvokeContext;

typedef id (* LTLaunchTasksPerformerStoryboardRef)(
    const id, const SEL, const NSString *, const NSBundle *
);

typedef id (* LTLaunchTasksPerformerExtensionPrincipalClassRef)(
    const id, const SEL, const NSString *, const NSBundle *
);

#if DEBUG
typedef id (* LTLaunchTasksPerformerXcodeAgentsRef)(const id, const SEL);
#endif

#pragma mark - Variables
static CFMutableArrayRef kLTRegisteredLaunchTaskInfo = NULL;
static CFMutableDictionaryRef
kLTLaunchTasksPerformerAppDelegateImpSwizzleMap = NULL;
static BOOL kHasLaunchTasksPerformerInjected = NO;
static BOOL kIsLaunchTasksPerformerInjectionSucceeded = NO;
#if DEBUG
static BOOL kIsLaunchTaskEnabled = YES;
#endif

#pragma mark - Constants
#define ExtensionBundlePathSuffix       @"appex"
#if DEBUG
#define XcodeAgentsBundlePathSuffix     @"/Developer/Library/Xcode/Agents"
#define PlaygroundBundleIDPrefix        @"com.apple.dt.playground"
#endif
#define ExtensionKey                    @"NSExtension"
#define ExtensionPrincipalClassKey      @"NSExtensionPrincipalClass"
#define ExtensionMainStoryboardKey      @"NSExtensionMainStoryboard"
#define MainNibFileKey                  @"NSMainNibFile"

#pragma mark - Function Prototypes
static LTLaunchTaskInfo * LTLaunchTaskInfoCreate(
    const char *,
    const LTLaunchTaskHandler,
    const void *,
    const LTLaunchTaskContextCleanupHandler,
    int
);

static LTApplicationUserInterfaceCreationApproach LTGetApplicationUserInterfaceCreationApproach();

static LTExtensionUserInterfaceCreationApproach LTGetExtensionUserInterfaceCreationApproach();

static BOOL LTRegisterLaunchTaskInfo(const LTLaunchTaskInfo *);

static BOOL LTFindUserCodeEntryPointAndInjectLaunchTasksPerformer(void);

static BOOL LTInjectsAsApplication(void);

static BOOL LTInjectsAsExtension(void);

static BOOL LTInjectsToStoryboard(void);

#if DEBUG
static BOOL LTInjectsAsXcodeAgents(void);

static BOOL LTInjectsAsPlaygroundPage(void);
#endif

static BOOL LTInjectsToNib(void);

static BOOL LTInjectsToAppDelegate(void);

static BOOL LTInjectsToExtensionPrincipalClass(void);

static LTLaunchTasksPerformerExtensionPrincipalClassRef
    LTLaunchTasksPerformerExtensionPrincipalClassReplaced;

static id LTLaunchTasksPerformerExtensionPrincipalClass(
    const id, const SEL, const NSString *, const NSBundle *
);

static LTLaunchTasksPerformerStoryboardRef
    LTLaunchTasksPerformerStoryboardReplaced;

static id LTLaunchTasksPerformerStoryboard(
    const id, const SEL, const NSString *, const NSBundle *
);

#if DEBUG
static LTLaunchTasksPerformerXcodeAgentsRef
    LTLaunchTasksPerformerXcodeAgentsReplaced;

static id LTLaunchTasksPerformerXcodeAgents(const id, const SEL);
#endif

static LTLaunchTaskSelectorMatchResult LTMatchLaunchTaskSelector(
    const SEL,
    const LTLaunchTaskInfo *
);

static Boolean LTBufferedClassEqual(const void *, const void *);

static void LTBufferedClassScanAndPerformLaunchTask(const void *, void *);

static void LTScanLaunchTaskSelectorsOnClassAndPerform(
    const Class,
    const LTLaunchTaskInfo *,
    const NSArray *
);

static void
    LTSetAppDelegateLaunchTasksPerformerOriginalImpForClass(
    const Class, const IMP
);

// All the compare operation shall be gauranteed in a same thread.
static BOOL LTLaunchTaskInfoEqualToInfo(
    const LTLaunchTaskInfo *,
    const LTLaunchTaskInfo *
);

static void LTLaunchTaskInfoRelease(LTLaunchTaskInfo *);

static void LTLaunchTaskHandlerDefault(
    const SEL,
    const id,
    const Method,
    const NSArray *,
    const void *
);

#pragma mark - Function Implementations
BOOL LTRegisterLaunchTask(
    const char * selectorPrefix,
    const LTLaunchTaskHandler selectorHandler,
    const void * context,
    const LTLaunchTaskContextCleanupHandler contextCleanupHandler,
    int priority
    )
{
    if (!kHasLaunchTasksPerformerInjected) {
        kIsLaunchTasksPerformerInjectionSucceeded
            = LTFindUserCodeEntryPointAndInjectLaunchTasksPerformer();
        if (!kIsLaunchTasksPerformerInjectionSucceeded) {
#if DEBUG
            NSLog(@"Inject point not found for main bundle: %@. Call LTPerformLaunchTasksIfNeeded() manually in the very begining of your code instead.", [NSBundle mainBundle]);
#endif
        }
        kHasLaunchTasksPerformerInjected = YES;
    }
    
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

LTApplicationUserInterfaceCreationApproach
    LTGetApplicationUserInterfaceCreationApproach()
{
    NSBundle * mainBundle = [NSBundle mainBundle];
    
    NSString * mainNibFileName
        = [mainBundle objectForInfoDictionaryKey:MainNibFileKey];
    
    NSString * mainStoryboardFileName
        = [mainBundle objectForInfoDictionaryKey:LTMainStoryboardFileKey];
    
    NSCAssert(
        !(mainNibFileName && mainStoryboardFileName),
        @"An application cannot have both %@ and %@ at the same time in its info.plist. Remove one of them.", MainNibFileKey, LTMainStoryboardFileKey
    );
    
    if (mainNibFileName) {
#if DEBUG
        NSLog(@"Application was detected that it creates user interface via nib file.");
#endif
        return LTApplicationUserInterfaceCreationApproachNib;
    }
    
    if (mainStoryboardFileName) {
#if DEBUG
        NSLog(@"Application was detected that it creates user interface via storyboard file.");
#endif
        return LTApplicationUserInterfaceCreationApproachStoryboard;
    }
    
#if DEBUG
    NSLog(@"Application was detected that it creates user interface programatically.");
#endif
    return LTApplicationUserInterfaceCreationApproachProgramatic;
}

LTExtensionUserInterfaceCreationApproach
    LTGetExtensionUserInterfaceCreationApproach()
{
    NSBundle * mainBundle = [NSBundle mainBundle];
    
    NSDictionary * extensionInfo
        = [mainBundle objectForInfoDictionaryKey:ExtensionKey];
    
    if (extensionInfo == nil) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Extension bundle has no \"%@\" key.", ExtensionKey];
    }
    
#if DEBUG
    NSString * extensionPricipalClassName
        = extensionInfo[ExtensionPrincipalClassKey];
#endif
    
    NSString * extensionMainStoryboardName
        = extensionInfo[ExtensionMainStoryboardKey];
    
    NSCAssert(
        !(extensionPricipalClassName && extensionMainStoryboardName),
        @"An extension cannot have both %@ and %@ at the same time in its info.plist. Remove one of them.",
        ExtensionPrincipalClassKey,
        ExtensionMainStoryboardKey
    );
    
    NSCAssert(
        (extensionPricipalClassName || extensionMainStoryboardName),
        @"An extension must have one of %@ and %@ in its info.plist. Add one of them.",
        ExtensionPrincipalClassKey,
        ExtensionMainStoryboardKey
    );
    
    if (extensionMainStoryboardName != nil) {
#if DEBUG
        NSLog(@"Extension was detected that it creates user interface via storyboard file.");
#endif
        return LTExtensionUserInterfaceCreationApproachStoryboard;
    }
    
#if DEBUG
    NSLog(@"Extension was detected that it creates user interface via extension principal class.");
#endif
    return LTExtensionUserInterfaceCreationApproachExtensionPrincipalClass;
}

LTLaunchTaskInfo * LTLaunchTaskInfoCreate(
    const char * selectorPrefix,
    const LTLaunchTaskHandler launchTaskSelectorHandler,
    const void * context,
    const LTLaunchTaskContextCleanupHandler contextCleanupHandler,
    int priotity
    )
{
    size_t prefixLength = strlen(selectorPrefix);
    
    char * copiedSelectorPrefix = malloc(prefixLength * sizeof(char));
    memcpy(copiedSelectorPrefix, selectorPrefix, prefixLength * sizeof(char));
    
    LTLaunchTaskInfo * info = malloc(sizeof(LTLaunchTaskInfo));
    
    * info = (LTLaunchTaskInfo) {
        copiedSelectorPrefix,
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

#pragma mark Launch Task Process
void LTPerformLaunchTasksIfNeeded() {
    LTPerformLaunchTasksOnLoadedClasses(nil);
}

void LTPerformLaunchTasksOnLoadedClasses(const id firstArg, ...) {
    
    NSMutableArray * args = [[NSMutableArray alloc] init];
    
    id argToEnlist = firstArg;
    
    va_list argList;
    va_start(argList, firstArg);
    while (argToEnlist != nil) {
        [args addObject:argToEnlist];
        argToEnlist = va_arg(argList, id);
    }
    va_end(argList);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if DEBUG
        if (!kIsLaunchTaskEnabled) {
            NSLog(@"Launch Task was disabled.");
            return;
        }
        
        NSTimeInterval start = [NSDate date].timeIntervalSinceReferenceDate;
#endif
        CFIndex scannedClassCount = 0;
        
        if (kLTRegisteredLaunchTaskInfo != NULL) {
            CFArrayCallBacks classBufferCallBacks = {
                0, NULL, NULL, NULL, &LTBufferedClassEqual
            };
            // We don't use a raw pointer here because we want to make
            // use of CFMutableArray's capacity growth strategy.
            CFMutableArrayRef classBuffer
                = CFArrayCreateMutable(kCFAllocatorDefault, 0, &classBufferCallBacks);
            
            BOOL isClassBufferReady = NO;
            
            CFIndex infoCount =
                CFArrayGetCount(kLTRegisteredLaunchTaskInfo);
            
            CFRange registeredInfoRange = CFRangeMake(0, infoCount);
            
            CFArraySortValues(
                kLTRegisteredLaunchTaskInfo,
                registeredInfoRange,
                &LTLaunchTaskInfoComparator,
                NULL
            );
            
            for (CFIndex infoIdx = 0; infoIdx < infoCount; infoIdx ++) {
                LTLaunchTaskInfo * info = (LTLaunchTaskInfo *)
                    CFArrayGetValueAtIndex(kLTRegisteredLaunchTaskInfo, infoIdx);
                
                if (!isClassBufferReady) {
                    unsigned int imgCount = 0;
                    
                    const char * * imgs = objc_copyImageNames(&imgCount);
                    
                    for (unsigned int imgIdx = 0; imgIdx < imgCount; imgIdx ++) {
                        const char * img = imgs[imgIdx];
                        
                        unsigned int clsCount = 0;
                        
                        const char * * clsNames
                            = objc_copyClassNamesForImage(img, &clsCount);
                        
                        for (unsigned int clsIdx = 0; clsIdx < clsCount; clsIdx ++) {
                            
                            const char * clsName = clsNames[clsIdx];
                            
                            Class cls = objc_getClass(clsName);
                            
                            // Getting class this way avoids the weak linked.
                            if (cls) {
                                LTScanLaunchTaskSelectorsOnClassAndPerform(cls, info, args);
                                CFArrayAppendValue(classBuffer,  (__bridge const void *)(cls));
                                scannedClassCount += 1;
                            }
                        }
                        
                        free(clsNames);
                    }
                    
                    free(imgs);
                    
                    isClassBufferReady = YES;
                } else {
                    CFRange totalRange = CFRangeMake(0, CFArrayGetCount(classBuffer));
                    LTBufferedClassInvokeContext context = {
                        info,
                        (__bridge void *)(args)
                    };
                    CFArrayApplyFunction(classBuffer, totalRange, &LTBufferedClassScanAndPerformLaunchTask, &context);
                }
            }
            
            CFRelease(classBuffer);
            
            for (CFIndex idx = 0; idx < infoCount; idx ++) {
                LTLaunchTaskInfo * registeredInfo = (LTLaunchTaskInfo *)
                CFArrayGetValueAtIndex(kLTRegisteredLaunchTaskInfo, idx);
                
                if (registeredInfo->contextCleanupHandler != NULL) {
                    const void * context = registeredInfo->context;
                    NSCAssert(context != NULL, @"Context shall not be NULL here");
                    LTLaunchTaskContextCleanupHandler cleanupHandler =
                        registeredInfo->contextCleanupHandler;
                    
                    (* cleanupHandler)((void *)context);
                }
                
                LTLaunchTaskInfoRelease(registeredInfo);
            }
            
            CFRelease(kLTRegisteredLaunchTaskInfo);
        }
        
#if DEBUG
        NSTimeInterval end = [NSDate date].timeIntervalSinceReferenceDate;
        NSLog(@"%f seconds took to complete all launch tasks. %@ classes were scanned.",
              (end - start), @(scannedClassCount));
#endif
    });
}

Boolean LTBufferedClassEqual(const void * value1, const void * value2) {
    return value1 == value2;
}

void LTBufferedClassScanAndPerformLaunchTask(const void * value, void * context) {
    
    Class cls = (__bridge Class) value;
    LTBufferedClassInvokeContext * ctx
        = (LTBufferedClassInvokeContext *) context;
    
    LTLaunchTaskInfo * info = ctx -> taskInfo;
    NSArray * args = (__bridge NSArray *)(ctx -> argumentsArray);
    
    LTScanLaunchTaskSelectorsOnClassAndPerform(cls, info, args);
}

void LTScanLaunchTaskSelectorsOnClassAndPerform(
    const Class aClass,
    const LTLaunchTaskInfo * info,
    const NSArray * args
    )
{
    char const * className = class_getName(aClass);
    Class metaClass = objc_getMetaClass(className);
    
    unsigned int methodCount = 0;
    
    Method * methods = class_copyMethodList(metaClass, &methodCount);
    
    // Scan class methods to check launch task selectors
    for (unsigned int index = 0; index < methodCount; index ++) {
        Method method = methods[index];
        
        SEL selector = method_getName(method);
        
        LTLaunchTaskSelectorMatchResult selMatchResult =
            LTMatchLaunchTaskSelector(selector, info);
        
        if (selMatchResult & LTLaunchTaskSelectorMatched) {
            const void * context = info -> context;
            info -> selectorHandler(selector, aClass, method, args, context);
        }
#if DEBUG
        else if (selMatchResult & LTLaunchTaskSelectorMatchedIgnoreCase) {
            NSLog(@"Found a pseudo launch task Selector, you might ignored the case of some letters when spelling it: %@",
                  NSStringFromSelector(selector));
        }
#endif
    }
    
    free(methods);
}

LTLaunchTaskSelectorMatchResult LTMatchLaunchTaskSelector(
    const SEL selector,
    const LTLaunchTaskInfo * info
    )
{
    const char * expectedSelPrefix = info -> selectorPrefix;
    size_t expectedSelPrefixLength = info -> selectorPrefixLength;
    
    const char * selName = sel_getName(selector);
    
    if (strncmp(
            expectedSelPrefix,
            selName,
            expectedSelPrefixLength
        ) == 0
        )
    {
        return LTLaunchTaskSelectorMatched;
    }
#if DEBUG
    else if (strncasecmp(
                expectedSelPrefix,
                selName,
                expectedSelPrefixLength
             ) == 0
             )
    {
        return LTLaunchTaskSelectorUnmatched
        | LTLaunchTaskSelectorMatchedIgnoreCase;
    } else {
        return LTLaunchTaskSelectorUnmatched;
    }
#else
    return LTLaunchTaskSelectorUnmatched;
#endif
}

void LTLaunchTaskHandlerDefault(
    const SEL selector,
    const id owner,
    const Method method,
    const NSArray * args,
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

#pragma mark Find User Code Entry Point and Inject Launch Tasks Performer
BOOL LTFindUserCodeEntryPointAndInjectLaunchTasksPerformer() {
    NSMainBundleCategory mainBundleCategory
        = [[NSBundle mainBundle] category];
    
    switch (mainBundleCategory) {
        case NSMainBundleCategoryApplication:
            if (LTInjectsAsApplication()) {
#if DEBUG
                NSLog(@"Found user code entry point and injected launch task performer as application.");
#endif
                return YES;
            }
            break;
        case NSMainBundleCategoryExtension:
            if (LTInjectsAsExtension()) {
#if DEBUG
                NSLog(@"Found user code entry point and injected launch task performer as extension.");
#endif
                return YES;
            }
            break;
#if DEBUG
        case NSMainBundleCategoryPlaygroundPage:
            if (LTInjectsAsPlaygroundPage()) {
                NSLog(@"Found user code entry point and injected launch task performer as Xcode Playground page.");
                return YES;
            }
            break;
        case NSMainBundleCategoryXcodeAgents:
            if (LTInjectsAsXcodeAgents()) {
                NSLog(@"Found user code entry point and injected launch task performer as Xcode Agents.");
                return YES;
            }
            break;
#endif
        default: break;
    }
    
    return NO;
}

BOOL LTInjectsToStoryboard() {
    SEL storyboardUserCodeEntryPointSelector
    = @selector(storyboardWithName:bundle:);
    
    const char * storyboardClassName
        = [NSStringFromClass([LTStoryboard class]) UTF8String];
    Class storyboardMetaClass = objc_getMetaClass(storyboardClassName);
    
    LTLaunchTasksPerformerStoryboardReplaced
    = (LTLaunchTasksPerformerStoryboardRef) class_replaceMethod(
        storyboardMetaClass,
        storyboardUserCodeEntryPointSelector,
        (IMP)&LTLaunchTasksPerformerStoryboard,
        "@:@@"
    );
    
    NSCAssert(
        LTLaunchTasksPerformerStoryboardReplaced,
        @"Cannot inject launch tasks performer to %@'s selector: %@",
        NSStringFromClass(storyboardMetaClass),
        NSStringFromSelector(storyboardUserCodeEntryPointSelector)
    );
    
    return LTLaunchTasksPerformerStoryboardReplaced != NULL;
}

BOOL LTInjectsToNib() {
#if DEBUG
    NSLog(@"LaunchTask cannot handle launching from nib currently. Ask for support if you need.");
#endif
    return NO;
}

BOOL LTInjectsToAppDelegate() {
    BOOL success = NO;
    
    Protocol * AppDelegateProtocol = @protocol(LTAppDelegate);
    
    SEL userCodeEntryPointSelector
        = @selector(LTAppDelegateUserCodeEntryPointSelector);
    
    const char * userCodeEntryPointEncode
        = LTAppDelegateUserCodeEntryPointSelectorEncode;
    
    unsigned int classCount = 0;
    
    // We don't use `objc_copyClassNamesForImage` to get classes only
    // in the main bundle here because some users can specify their
    // app delegate to be a class in a third party framework.
    
    Class * classes = objc_copyClassList(&classCount);
    
    for (unsigned int idx = 0; idx < classCount; idx ++) {
        Class cls = classes[idx];
        
        if (class_conformsToProtocol(cls, AppDelegateProtocol)) {
            BOOL isPotentialUserCodeEntryPoint
                = class_respondsToSelector(
                    cls,
                    userCodeEntryPointSelector
                );
            
            if (isPotentialUserCodeEntryPoint) {
                NSLog(@"Swizzle the user code entry point.");
                /* Swizzle */
                
                IMP originalImp = class_replaceMethod(
                    cls,
                    userCodeEntryPointSelector,
                    (IMP)&LTLaunchTasksPerformerAppDelegateSwizzled,
                    userCodeEntryPointEncode
                );
                
                LTSetAppDelegateLaunchTasksPerformerOriginalImpForClass(
                    cls,
                    originalImp
                );
                
                NSLog(@"hehe");
                
                success = success || YES;
            } else {
                NSLog(@"Inject the user code entry point.");
                /* Inject */
                
                class_addMethod(
                    cls,
                    userCodeEntryPointSelector,
                    (IMP)&LTLaunchTasksPerformerAppDelegateInjected,
                    userCodeEntryPointEncode
                );
                
                success = success || YES;
            }
            
        }
    }
    
    free(classes);
    
    NSCAssert(
        success,
        @"No app delegate(class conforms to %@) found in all loaded bundles. Check your code that if you have added @NSApplicationMain above your app delegate class definition when your app delegate is written in Swift, or if you have set correct app delegate class in your main function when your app delegate is written in Objective-C.",
        NSStringFromProtocol(AppDelegateProtocol)
    );
    
    return success;
}

BOOL LTInjectsToExtensionPrincipalClass() {
    NSDictionary * extensionInfo
        = [[NSBundle mainBundle] objectForInfoDictionaryKey:ExtensionKey];
    
    NSCAssert(extensionInfo, @"No, it's impossible.");
    
    NSString * extensionPrincipalClassName
        = extensionInfo[ExtensionPrincipalClassKey];
    
    NSCAssert(
        extensionPrincipalClassName,
        @"Extension's principal class name was not set. Or the extension principal class' key(%@) was changed.", ExtensionPrincipalClassKey
    );
    
    Class extensionPrincipalClass
        = NSClassFromString(extensionPrincipalClassName);
    
    SEL extensionPrincipalClassUserCodeEntryPointSelector
        = @selector(initWithNibName:bundle:);
    
    LTLaunchTasksPerformerExtensionPrincipalClassReplaced
        = (LTLaunchTasksPerformerExtensionPrincipalClassRef)
        class_replaceMethod(
            extensionPrincipalClass,
            extensionPrincipalClassUserCodeEntryPointSelector,
            (IMP)&LTLaunchTasksPerformerExtensionPrincipalClass,
            "@:@@"
        );
    
    NSCAssert(
        LTLaunchTasksPerformerExtensionPrincipalClassReplaced,
        @"Cannot inject launch tasks performer to %@'s selector: %@",
        NSStringFromClass(extensionPrincipalClass),
        NSStringFromSelector(extensionPrincipalClassUserCodeEntryPointSelector)
    );
    
    return LTLaunchTasksPerformerExtensionPrincipalClassReplaced != NULL;
}

BOOL LTInjectsAsApplication() {
    __block BOOL success = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LTApplicationUserInterfaceCreationApproach UserInterfaceCreationApproach
            = LTGetApplicationUserInterfaceCreationApproach();
        
        switch (UserInterfaceCreationApproach) {
            case LTApplicationUserInterfaceCreationApproachStoryboard:
                success = LTInjectsToStoryboard();
                break;
            case LTApplicationUserInterfaceCreationApproachNib:
                success = LTInjectsToNib();
                break;
            case LTApplicationUserInterfaceCreationApproachProgramatic:
                success = LTInjectsToAppDelegate();
                break;
        }
        
    });
    return success;
}

BOOL LTInjectsAsExtension() {
    __block BOOL success = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LTExtensionUserInterfaceCreationApproach UserInterfaceCreationApproach
            = LTGetExtensionUserInterfaceCreationApproach();
        
        switch (UserInterfaceCreationApproach) {
            case LTExtensionUserInterfaceCreationApproachStoryboard:
                success = LTInjectsToStoryboard();
                break;
            case LTExtensionUserInterfaceCreationApproachExtensionPrincipalClass:
                success = LTInjectsToExtensionPrincipalClass();
                break;
        }
    });
    return success;
}

#if DEBUG
BOOL LTInjectsAsXcodeAgents() {
    __block BOOL success = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* We don't have to worry about the usage of private API here,
         because the whole piece of code is guarded with the DEBUG flag, 
         which means it would not be compiled in to the production.
         */
        Class userCodeEntryPointClass
            = NSClassFromString(@"XCTestDriver");
        if (userCodeEntryPointClass) {
            SEL userCodeEntryPointSelector = @selector(init);
            
            LTLaunchTasksPerformerXcodeAgentsReplaced
                = (LTLaunchTasksPerformerXcodeAgentsRef)
                class_replaceMethod(
                    userCodeEntryPointClass,
                    userCodeEntryPointSelector,
                    (IMP)&LTLaunchTasksPerformerXcodeAgents,
                    "@:"
                );
            
            NSCAssert(
                LTLaunchTasksPerformerXcodeAgentsReplaced,
                @"Cannot inject launch tasks performer to %@'s selector: %@",
                NSStringFromClass(userCodeEntryPointClass),
                NSStringFromSelector(userCodeEntryPointSelector)
            );
            
            success = LTLaunchTasksPerformerXcodeAgentsReplaced != NULL;
        }
    });
    return success;
}

BOOL LTInjectsAsPlaygroundPage() {
    __block BOOL success = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Launch Task currently doesn't support Xcode Playground pages.");
    });
    return success;
}
#endif

LTLaunchTasksPerformerAppDelegate *
    LTGetAppDelegateLaunchTasksPerformerOriginalImpForClass(
        const Class aClass
    )
{
    if (kLTLaunchTasksPerformerAppDelegateImpSwizzleMap == NULL) {
        kLTLaunchTasksPerformerAppDelegateImpSwizzleMap =
        CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
    }
    return (LTLaunchTasksPerformerAppDelegate *) CFDictionaryGetValue(
        kLTLaunchTasksPerformerAppDelegateImpSwizzleMap,
        (__bridge const void *)(aClass)
    );
}

void LTSetAppDelegateLaunchTasksPerformerOriginalImpForClass(
    const Class aClass,
    const IMP impl
    )
{
    if (kLTLaunchTasksPerformerAppDelegateImpSwizzleMap == NULL) {
        kLTLaunchTasksPerformerAppDelegateImpSwizzleMap =
        CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
    }
    CFDictionarySetValue(
        kLTLaunchTasksPerformerAppDelegateImpSwizzleMap,
        (__bridge const void *)(aClass),
        impl
    );
}

id LTLaunchTasksPerformerStoryboard(
    const id self,
    const SEL _cmd,
    const NSString * name,
    const NSBundle * bundleOrNil
    )
{
    LTPerformLaunchTasksOnLoadedClasses(nil);
    
    NSCAssert(
        LTLaunchTasksPerformerStoryboardReplaced != NULL,
        @"No original implementation found."
    );
    
    return (* LTLaunchTasksPerformerStoryboardReplaced)(
        self, _cmd, name, bundleOrNil
    );
}

#if DEBUG
id LTLaunchTasksPerformerXcodeAgents(const id self, const SEL _cmd) {
    LTPerformLaunchTasksOnLoadedClasses(nil);
    
    NSCAssert(
        LTLaunchTasksPerformerXcodeAgentsReplaced != NULL,
        @"No original implementation found."
    );
    
    return (* LTLaunchTasksPerformerXcodeAgentsReplaced)(self, _cmd);
}
#endif

id LTLaunchTasksPerformerExtensionPrincipalClass(
    const id self,
    const SEL _cmd,
    const NSString * nibNameOrNil,
    const NSBundle * bundleOrNil
    )
{
    LTPerformLaunchTasksOnLoadedClasses(nil);
    
    NSCAssert(
        LTLaunchTasksPerformerExtensionPrincipalClassReplaced != NULL,
        @"No original implementation found."
    );
    
    return LTLaunchTasksPerformerExtensionPrincipalClassReplaced(
        self, _cmd, nibNameOrNil, bundleOrNil
    );
}

@implementation NSObject(LaunchTask)
+ (void)load {
    LTRegisterLaunchTask(
        "_LaunchTask_",
        &LTLaunchTaskHandlerDefault,
        NULL,
        NULL,
        0
    );
}
@end

#pragma mark - Managed Launch Task
#if DEBUG
void LTSetLaunchTaskEnabled(BOOL enabled) {
    if (kIsLaunchTaskEnabled != enabled) {
        kIsLaunchTaskEnabled = enabled;
    }
}
#endif

#pragma mark - NSBundle Utilities
@implementation NSBundle (Category)
- (NSMainBundleCategory)category {
    if ([NSBundle mainBundle] == self) {
        if ([[self bundlePath] hasSuffix:ExtensionBundlePathSuffix]) {
            return NSMainBundleCategoryExtension;
        }
#if DEBUG
        if ([[self bundlePath] hasSuffix:XcodeAgentsBundlePathSuffix]) {
            return NSMainBundleCategoryXcodeAgents;
        }
        if ([[self bundleIdentifier] hasPrefix:PlaygroundBundleIDPrefix]) {
            return NSMainBundleCategoryPlaygroundPage;
        }
#endif
        return NSMainBundleCategoryApplication;
    }
    return NSMainBundleCategoryNotMainBundle;
}

@end
