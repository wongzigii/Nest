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

#define OCSASSelfAwareSwizzlePerformingSelector applicationDidFinishLaunching

#define OCSASSelfAwareSwizzlePerformingSelectorEncode "@:"

FOUNDATION_EXPORT ObjCRawIdSel OCSASSwizzledSelfAwareSwizzlePerformer;

FOUNDATION_EXPORT ObjCRawIdSel OCSASInjectedSelfAwareSwizzlePerformer;