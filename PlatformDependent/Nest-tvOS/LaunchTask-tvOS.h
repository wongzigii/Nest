//
//  LaunchTask-tvOS.h
//  Nest
//
//  Created by Manfred on 23/12/2016.
//
//

@import UIKit;

#define LTExtensionPrincipalClassKey                    @"NSExtensionPrincipalClass"

#define LTExtensionMainStoryboardKey                    @"NSExtensionMainStoryboard"

#define LTMainNibFileKey                                @"NSMainNibFile"

#define LTStoryboard                                    UIStoryboard

#define LTMainStoryboardFileKey                         @"UIMainStoryboardFile"

#define LTAppDelegate                                   UIApplicationDelegate

#define LTAppDelegateUserCodeEntryPointSelector         application:willFinishLaunchingWithOptions:

#define LTAppDelegateUserCodeEntryPointSelectorEncode   "@:@@"

typedef BOOL LTLaunchTasksPerformerAppDelegate(
id<UIApplicationDelegate>, SEL, UIApplication *, NSDictionary *
);

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate LTLaunchTasksPerformerAppDelegateSwizzled;

FOUNDATION_EXPORT LTLaunchTasksPerformerAppDelegate LTLaunchTasksPerformerAppDelegateInjected;
