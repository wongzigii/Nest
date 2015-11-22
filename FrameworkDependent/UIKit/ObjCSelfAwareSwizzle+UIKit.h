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

#define OCSASAppDidFinishLaunching application:didFinishLaunchingWithOptions:

#define OCSASAppDidFinishLaunchingEncode "@:@@"

FOUNDATION_EXPORT ObjCRawIdSelUIApplicationNSDictionary_BOOL
    OCSASSwizzledAppDidFinishLaunching;

FOUNDATION_EXPORT ObjCRawIdSelUIApplicationNSDictionary_BOOL
    OCSASInjectedAppDidFinishLaunching;
