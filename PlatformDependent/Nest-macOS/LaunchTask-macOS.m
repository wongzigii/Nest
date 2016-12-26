//
//  LaunchTask-macOS.m
//  Nest
//
//  Created by Manfred on 23/12/2016.
//
//

#import "LaunchTask-macOS.h"
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
