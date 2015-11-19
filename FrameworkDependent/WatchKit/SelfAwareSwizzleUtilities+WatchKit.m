//
//  SelfAwareSwizzleUtilities+WatchKit.m
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import ObjectiveC;

#import "SelfAwareSwizzleUtilities.h"

#include "SelfAwareSwizzleUtilities+WatchKit.h"

void OCSASSwizzledProcessDidFinishLaunching(
    id<WKExtensionDelegate> self,
    SEL _cmd)
{
    OCSASPerformSelfAwareSwizzleOnLoadedClasses();
    
    Class class = [self class];
    
    ObjCRawIdSel * original_imp = (ObjCRawIdSel *)
    OCSASOriginalProcessDidFinishLaunchingImplementationForClass(class);
    
    if (original_imp != NULL) {
        original_imp(self, _cmd);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
    }
}

void OCSASInjectedProcessDidFinishLaunching(
    id<WKExtensionDelegate> self,
    SEL _cmd)
{
    OCSASPerformSelfAwareSwizzleOnLoadedClasses();
}