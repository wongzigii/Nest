//
//  ObjCSelfAwareSwizzle+AppKit.m
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import ObjectiveC;

#import "ObjCSelfAwareSwizzle.h"
#import "ObjCSelfAwareSwizzle+AppKit.h"

void OCSASAppDidFinishLaunching(
    id<NSApplicationDelegate> self,
    SEL _cmd,
    NSApplication * application)
{
    OCSASPerformSelfAwareSwizzleOnLoadedClasses();
    
    Class class = [self class];
    
    ObjCRawIdSelNSApplication * original_imp = (ObjCRawIdSelNSApplication *)
    OCSASOriginalAppDidFinishLaunchingImplementationForClass(class);
    
    if (original_imp != NULL) {
        original_imp(self, _cmd, application);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
    }
}

void OCSASInjectedAppDidFinishLaunching(
    id<NSApplicationDelegate> self,
    SEL _cmd,
    NSApplication * application)
{
    OCSASPerformSelfAwareSwizzleOnLoadedClasses();
}