//
//  ObjCDynamicPropertyAccessors-QuartzCore.m
//  Nest
//
//  Created by Manfred on 26/12/2016.
//
//

@import Foundation;

#if TARGET_OS_IOS
@import UIKit;
#elif TARGET_OS_TV
@import UIKit;
#elif TARGET_OS_MAC
@import AppKit;
#endif

@import QuartzCore;

#import <Nest/ObjCDynamicPropertySynthesizer.h>

@ObjCDynamicPropertyGetter(CATransform3D) {
    CATransform3D retVal = CATransform3DIdentity;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CATransform3DValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CATransform3D) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCATransform3D:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CATransform3D, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CATransform3DValue];
};

@ObjCDynamicPropertySetter(CATransform3D, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCATransform3D:newValue] forKey:_prop];
};
