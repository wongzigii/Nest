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

void OCSASSwizzledSelfAwareSwizzlePerformer(
    id<NSApplicationDelegate> self,
    SEL _cmd,
    NSNotification * notification)
{
    OCSASPerformSelfAwareSwizzleOnLoadedClasses();
    
    Class class = [self class];
    
    ObjCRawIdSelNSNotification * original_imp = (ObjCRawIdSelNSNotification *)
    OCSASOriginalSelfAwareSwizzlePerformerForClass(class);
    
    if (original_imp != NULL) {
        original_imp(self, _cmd, notification);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
    }
}

void OCSASInjectedSelfAwareSwizzlePerformer(
    id<NSApplicationDelegate> self,
    SEL _cmd,
    NSNotification * notification)
{
    OCSASPerformSelfAwareSwizzleOnLoadedClasses();
}
