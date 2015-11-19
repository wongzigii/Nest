//
//  SelfAwareSwizzleUtilities.h
//  Nest
//
//  Created by Manfred on 11/19/15.
//
//

@import Foundation;

FOUNDATION_EXPORT void OCSASSwizzleAllPossibleProcessDelegates();
FOUNDATION_EXPORT void OCSASPerformSelfAwareSwizzleOnLoadedClasses();
FOUNDATION_EXPORT IMP OCSASOriginalProcessDidFinishLaunchingImplementationForClass(Class aClass);
