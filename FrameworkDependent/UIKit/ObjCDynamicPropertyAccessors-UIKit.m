//
//  ObjCDynamicPropertyAccessors-UIKit.m
//  Nest
//
//  Created by Manfred on 26/12/2016.
//
//

@import UIKit;

#import <Nest/ObjCDynamicPropertySynthesizer.h>

@ObjCDynamicPropertyGetter(UIOffset) {
    UIOffset retVal = UIOffsetZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] UIOffsetValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(UIOffset, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] UIOffsetValue];
};

@ObjCDynamicPropertySetter(UIOffset) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithUIOffset:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertySetter(UIOffset, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithUIOffset:newValue] forKey:_prop];
};

@ObjCDynamicPropertyGetter(UIEdgeInsets) {
    UIEdgeInsets retVal = UIEdgeInsetsZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] UIEdgeInsetsValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(UIEdgeInsets, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] UIEdgeInsetsValue];
};

@ObjCDynamicPropertySetter(UIEdgeInsets) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithUIEdgeInsets:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertySetter(UIEdgeInsets, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithUIEdgeInsets:newValue] forKey:_prop];
};
