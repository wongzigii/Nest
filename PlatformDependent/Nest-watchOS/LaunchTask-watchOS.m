//
//  LaunchTask-watchOS.m
//  Nest
//
//  Created by Manfred on 23/12/2016.
//
//

#import "LaunchTask-watchOS.h"
#import "LaunchTask+Internal.h"

void LTLaunchTasksPerformerAppDelegateSwizzled(id<WKExtensionDelegate> self, SEL _cmd) {
    LTPerformLaunchTasksOnLoadedClasses(nil);
    
    Class class = [self class];
    
    LTLaunchTasksPerformerAppDelegate * originalImp =
    LTGetAppDelegateLaunchTasksPerformerOriginalImpForClass(class);
    
    if (originalImp != NULL) {
        originalImp(self, _cmd);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
    }
}

void LTLaunchTasksPerformerAppDelegateInjected(id<WKExtensionDelegate> self, SEL _cmd) {
    LTPerformLaunchTasksOnLoadedClasses(nil);
}

