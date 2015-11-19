//
//  SelfAwareSwizzleUtilities+WatchKit.h
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import WatchKit;

typedef void ObjCRawIdSel(id<WKExtensionDelegate>, SEL);

#define OCSASProcessDelegate WKExtensionDelegate

#define OCSASProcessDidFinishLaunching applicationDidFinishLaunching

#define OCSASProcessDidFinishLaunchingEncode "@:"

FOUNDATION_EXPORT ObjCRawIdSel
OCSASSwizzledProcessDidFinishLaunching;

FOUNDATION_EXPORT ObjCRawIdSel
OCSASInjectedProcessDidFinishLaunching;