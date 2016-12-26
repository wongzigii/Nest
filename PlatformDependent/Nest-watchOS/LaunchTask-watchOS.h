//
//  LaunchTask-watchOS.h
//  Nest
//
//  Created by Manfred on 23/12/2016.
//
//

@import WatchKit;

#define LTClockKitComplicationPrincipalClassKey         @"CLKComplicationPrincipalClass"

#define LTAppDelegate                                   WKExtensionDelegate

#define LTAppDelegateUserCodeEntryPointSelector         applicationDidFinishLaunching

#define LTAppDelegateUserCodeEntryPointSelectorEncode   "@:"

typedef void LTLaunchTasksPerformerAppDelegate(id<WKExtensionDelegate>, SEL);

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate
LTLaunchTasksPerformerAppDelegateSwizzled;

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate
LTLaunchTasksPerformerAppDelegateInjected;
