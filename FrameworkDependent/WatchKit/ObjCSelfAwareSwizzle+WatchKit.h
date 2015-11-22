//
//  ObjCSelfAwareSwizzle+WatchKit.h
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import WatchKit;

typedef void ObjCRawIdSel(id<WKExtensionDelegate>, SEL);

#define OCSASAppDelegate WKExtensionDelegate

#define OCSASAppDidFinishLaunching applicationDidFinishLaunching

#define OCSASAppDidFinishLaunchingEncode "@:"

FOUNDATION_EXPORT ObjCRawIdSel
OCSASSwizzledAppDidFinishLaunching;

FOUNDATION_EXPORT ObjCRawIdSel
OCSASInjectedAppDidFinishLaunching;