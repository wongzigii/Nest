//
//  ObjCSelfAwareSwizzleUtilities+AppKit.h
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import AppKit;

typedef void ObjCRawIdSelNSApplication(id<NSApplicationDelegate>,
    SEL,
    NSApplication *);

#define OCSASProcessDelegate NSApplicationDelegate

#define OCSASProcessDidFinishLaunching applicationDidFinishLaunching:

#define OCSASProcessDidFinishLaunchingEncode "@:@"

FOUNDATION_EXPORT ObjCRawIdSelNSApplication
OCSASSwizzledProcessDidFinishLaunching;

FOUNDATION_EXPORT ObjCRawIdSelNSApplication
OCSASInjectedProcessDidFinishLaunching;