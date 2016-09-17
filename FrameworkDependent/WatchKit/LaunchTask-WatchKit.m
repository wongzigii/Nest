//
//  LaunchTask+WatchKit.m
//  Nest
//
//  Created by Manfred on 12/4/15.
//
//

#import "LaunchTask-WatchKit.h"
#import "LaunchTask+Internal.h"

void LTSwizzledLaunchTasksPerformer(id<WKExtensionDelegate> self, SEL _cmd) {
    LTPerformLaunchTasksOnLoadedClasses(nil);
    
    Class class = [self class];
    
    LTLaunchTaskPerformer * original_imp = (LTLaunchTaskPerformer *)
    LTLaunchTaskPerformerReplacedImpForClass(class);
    
    if (original_imp != NULL) {
        original_imp(self, _cmd);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
    }
}

void LTInjectedLaunchTasksPerformer(id<WKExtensionDelegate> self, SEL _cmd) {
    LTPerformLaunchTasksOnLoadedClasses(nil);
}

void LTLaunchTaskHandlerDefault(SEL taskSelector,
    id taskOwner,
    void * context)
{
    
}
