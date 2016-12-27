//
//  ObjCDynamicPropertyAccessors-CoreGraphics.m
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
#elif TARGET_OS_WATCH
@import UIKit;
#elif TARGET_OS_MAC
@import AppKit;
#endif
@import CoreGraphics;

#import <Nest/ObjCDynamicPropertySynthesizer.h>

@ObjCDynamicPropertyGetter(CGPoint) {
    CGPoint retVal = CGPointZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CGPointValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGPoint) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGPoint:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CGVector) {
    CGVector retVal = CGVectorMake(0, 0);
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CGVectorValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGVector) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGVector:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CGSize) {
    CGSize retVal = CGSizeZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CGSizeValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGSize) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGSize:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CGRect) {
    CGRect retVal = CGRectZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CGRectValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGRect) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGRect:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CGAffineTransform) {
    CGAffineTransform retVal = CGAffineTransformIdentity;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CGAffineTransformValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGAffineTransform) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGAffineTransform:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CGPoint, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CGPointValue];
};

@ObjCDynamicPropertySetter(CGPoint, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGPoint:newValue] forKey:_prop];
};

@ObjCDynamicPropertyGetter(CGVector, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CGVectorValue];
};

@ObjCDynamicPropertySetter(CGVector, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGVector:newValue] forKey:_prop];
};

@ObjCDynamicPropertyGetter(CGSize, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CGSizeValue];
};

@ObjCDynamicPropertySetter(CGSize, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGSize:newValue] forKey:_prop];
};

@ObjCDynamicPropertyGetter(CGRect, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CGRectValue];
};

@ObjCDynamicPropertySetter(CGRect, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGRect:newValue] forKey:_prop];
};

@ObjCDynamicPropertyGetter(CGAffineTransform, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CGAffineTransformValue];
};

@ObjCDynamicPropertySetter(CGAffineTransform, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGAffineTransform:newValue] forKey:_prop];
};
