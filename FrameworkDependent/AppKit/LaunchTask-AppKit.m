//
//  LaunchTask+AppKit.m
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

#import "LaunchTask-AppKit.h"
#import "LaunchTask+Internal.h"

void LTLaunchTasksPerformerAppDelegateSwizzled(
    id<NSApplicationDelegate> self,
    SEL _cmd,
    NSNotification * notification
    )
{
    LTPerformLaunchTasksOnLoadedClasses(notification, nil);
    
    Class class = [self class];
    
    LTLaunchTasksPerformerAppDelegate * originalImp =
        LTGetAppDelegateLaunchTasksPerformerOriginalImpForClass(class);
    
    if (originalImp != NULL) {
        originalImp(self, _cmd, notification);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
    }
}

void LTLaunchTasksPerformerAppDelegateInjected(
    id<NSApplicationDelegate> self,
    SEL _cmd,
    NSNotification * notification
    )
{
    LTPerformLaunchTasksOnLoadedClasses(notification, nil);
}
