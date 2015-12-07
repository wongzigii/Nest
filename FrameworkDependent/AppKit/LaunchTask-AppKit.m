//
//  LaunchTask+AppKit.m
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

#import "LaunchTask-AppKit.h"
#import "LaunchTaskInternal.h"

void LTSwizzledLaunchTasksPerformer(id<NSApplicationDelegate> self,
    SEL _cmd,
    NSNotification * notification)
{
    LTPerformLaunchTasksOnLoadedClasses(notification, nil);
    
    Class class = [self class];
    
    LTLaunchTaskPerformer * original_imp = (LTLaunchTaskPerformer *)
    LTLaunchTaskPerformerReplacedImpForClass(class);
    
    if (original_imp != NULL) {
        original_imp(self, _cmd, notification);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
    }
}

void LTInjectedLaunchTasksPerformer(id<NSApplicationDelegate> self,
    SEL _cmd,
    NSNotification * notification)
{
    LTPerformLaunchTasksOnLoadedClasses(notification, nil);
}

void LTLaunchTaskSelectorHandlerDefault(SEL taskSelector,
    id taskOwner,
    void * context)
{
    
}