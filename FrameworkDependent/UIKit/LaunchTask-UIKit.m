//
//  LaunchTask+UIKit.m
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

#import "LaunchTask-UIKit.h"
#import "LaunchTask+Internal.h"

BOOL LTLaunchTasksPerformerAppDelegateSwizzled(
    id<UIApplicationDelegate> self,
    SEL _cmd,
    UIApplication * application,
    NSDictionary * options
    )
{
    LTPerformLaunchTasksOnLoadedClasses(application, options, nil);
    
    Class class = [self class];
    
    LTLaunchTasksPerformerAppDelegate * originalImp =
        LTGetAppDelegateLaunchTasksPerformerOriginalImpForClass(class);
    
    if (originalImp != NULL) {
        return originalImp(self, _cmd, application, options);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
        return NO;
    }
}

BOOL LTLaunchTasksPerformerAppDelegateInjected(
    id<UIApplicationDelegate> self,
    SEL _cmd,
    UIApplication * application,
    NSDictionary * options
    )
{
    LTPerformLaunchTasksOnLoadedClasses(application, options, nil);
    
    return YES;
}
