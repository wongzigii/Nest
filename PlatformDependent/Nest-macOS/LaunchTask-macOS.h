//
//  LaunchTask-macOS.h
//  Nest
//
//  Created by Manfred on 23/12/2016.
//
//

@import AppKit;

#define LTExtensionPrincipalClassKey                    @"NSExtensionPrincipalClass"

#define LTExtensionMainStoryboardKey                    @"NSExtensionMainStoryboard"

#define LTMainNibFileKey                                @"NSMainNibFile"

#define LTStoryboard                                    NSStoryboard

#define LTMainStoryboardFileKey                         @"NSMainStoryboardFile"

#define LTAppDelegate                                   NSApplicationDelegate

#define LTAppDelegateUserCodeEntryPointSelector         applicationWillFinishLaunching:

#define LTAppDelegateUserCodeEntryPointSelectorEncode   "@:@"

typedef void LTLaunchTasksPerformerAppDelegate(
id<NSApplicationDelegate>, SEL, NSNotification *
);

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate LTLaunchTasksPerformerAppDelegateSwizzled;

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate LTLaunchTasksPerformerAppDelegateInjected;
