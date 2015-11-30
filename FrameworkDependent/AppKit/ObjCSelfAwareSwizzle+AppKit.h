//
//  ObjCSelfAwareSwizzle+AppKit.h
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import AppKit;

typedef void ObjCRawIdSelNSNotification(id<NSApplicationDelegate>,
    SEL,
    NSNotification *);

#define OCSASAppDelegate NSApplicationDelegate

#define OCSASSelfAwareSwizzlePerformingSelector applicationWillFinishLaunching:

#define OCSASSelfAwareSwizzlePerformingSelectorEncode "@:@"

FOUNDATION_EXPORT ObjCRawIdSelNSNotification
OCSASSwizzledSelfAwareSwizzlePerformer;

FOUNDATION_EXPORT ObjCRawIdSelNSNotification
OCSASInjectedSelfAwareSwizzlePerformer;