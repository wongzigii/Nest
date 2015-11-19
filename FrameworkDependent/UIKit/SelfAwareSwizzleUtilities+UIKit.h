//
//  SelfAwareSwizzleUtilities+UIKit.h
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

#define OCSASProcessDelegate UIApplicationDelegate

#define OCSASProcessDidFinishLaunching application:didFinishLaunchingWithOptions:

#define OCSASProcessDidFinishLaunchingEncode "@:@@"

FOUNDATION_EXPORT ObjCRawIdSelUIApplicationNSDictionary_BOOL
    OCSASSwizzledProcessDidFinishLaunching;

FOUNDATION_EXPORT ObjCRawIdSelUIApplicationNSDictionary_BOOL
    OCSASInjectedProcessDidFinishLaunching;
