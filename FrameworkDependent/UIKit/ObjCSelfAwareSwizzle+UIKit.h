//
//  ObjCSelfAwareSwizzle+UIKit.h
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import UIKit;

typedef BOOL ObjCRawIdSelUIApplicationNSDictionary_BOOL(
    id<UIApplicationDelegate>,
    SEL,
    UIApplication *,
    NSDictionary *);

#define OCSASAppDelegate UIApplicationDelegate

#define OCSASSelfAwareSwizzlePerformingSelector \
application:willFinishLaunchingWithOptions:

#define OCSASSelfAwareSwizzlePerformingSelectorEncode "@:@@"

FOUNDATION_EXPORT ObjCRawIdSelUIApplicationNSDictionary_BOOL
    OCSASSwizzledSelfAwareSwizzlePerformer;

FOUNDATION_EXPORT ObjCRawIdSelUIApplicationNSDictionary_BOOL
    OCSASInjectedSelfAwareSwizzlePerformer;
