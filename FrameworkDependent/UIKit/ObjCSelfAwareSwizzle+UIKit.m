//
//  ObjCSelfAwareSwizzle+UIKit.m
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import ObjectiveC;

#import "ObjCSelfAwareSwizzle.h"
#import "ObjCSelfAwareSwizzle+UIKit.h"

BOOL OCSASSwizzledSelfAwareSwizzlePerformer(
    id<UIApplicationDelegate> self,
    SEL _cmd,
    UIApplication * application,
    NSDictionary * options)
{
    OCSASPerformSelfAwareSwizzleOnLoadedClasses();
    
    Class class = [self class];
    
    ObjCRawIdSelUIApplicationNSDictionary_BOOL * original_imp =
        (ObjCRawIdSelUIApplicationNSDictionary_BOOL *)
        OCSASOriginalSelfAwareSwizzlePerformerForClass(class);
    
    if (original_imp != NULL) {
        return original_imp(self, _cmd, application, options);
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot find original implementation for %@ on %@",
         NSStringFromSelector(_cmd),
         NSStringFromClass(class)];
        return NO;
    }
}

BOOL OCSASInjectedSelfAwareSwizzlePerformer(
    id<UIApplicationDelegate> self,
    SEL _cmd,
    UIApplication * application,
    NSDictionary * options)
{
    OCSASPerformSelfAwareSwizzleOnLoadedClasses();
    
    return YES;
}
