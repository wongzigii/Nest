//
//  ObjCSelfAwareSwizzle+AppKit.h
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import AppKit;

typedef void ObjCRawIdSelNSApplication(id<NSApplicationDelegate>,
    SEL,
    NSApplication *);

#define OCSASAppDelegate NSApplicationDelegate

#define OCSASAppDidFinishLaunching applicationDidFinishLaunching:

#define OCSASAppDidFinishLaunchingEncode "@:@"

FOUNDATION_EXPORT ObjCRawIdSelNSApplication
OCSASSwizzledAppDidFinishLaunching;

FOUNDATION_EXPORT ObjCRawIdSelNSApplication
OCSASInjectedAppDidFinishLaunching;