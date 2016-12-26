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
        retVal = [[self primitiveValueForKey:_key] CGPointValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGPoint) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGPoint:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(CGVector) {
    CGVector retVal = CGVectorMake(0, 0);
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] CGVectorValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGVector) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGVector:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(CGSize) {
    CGSize retVal = CGSizeZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] CGSizeValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGSize) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGSize:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(CGRect) {
    CGRect retVal = CGRectZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] CGRectValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGRect) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGRect:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(CGAffineTransform) {
    CGAffineTransform retVal = CGAffineTransformIdentity;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] CGAffineTransformValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CGAffineTransform) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCGAffineTransform:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(CGPoint, NONATOMIC) {
    return [[self primitiveValueForKey:_key] CGPointValue];
};

@ObjCDynamicPropertySetter(CGPoint, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGPoint:newValue] forKey:_key];
};

@ObjCDynamicPropertyGetter(CGVector, NONATOMIC) {
    return [[self primitiveValueForKey:_key] CGVectorValue];
};

@ObjCDynamicPropertySetter(CGVector, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGVector:newValue] forKey:_key];
};

@ObjCDynamicPropertyGetter(CGSize, NONATOMIC) {
    return [[self primitiveValueForKey:_key] CGSizeValue];
};

@ObjCDynamicPropertySetter(CGSize, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGSize:newValue] forKey:_key];
};

@ObjCDynamicPropertyGetter(CGRect, NONATOMIC) {
    return [[self primitiveValueForKey:_key] CGRectValue];
};

@ObjCDynamicPropertySetter(CGRect, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGRect:newValue] forKey:_key];
};

@ObjCDynamicPropertyGetter(CGAffineTransform, NONATOMIC) {
    return [[self primitiveValueForKey:_key] CGAffineTransformValue];
};

@ObjCDynamicPropertySetter(CGAffineTransform, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCGAffineTransform:newValue] forKey:_key];
};
