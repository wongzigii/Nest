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
        retVal = [[self primitiveValueForKey:_key] UIOffsetValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(UIOffset, NONATOMIC) {
    return [[self primitiveValueForKey:_key] UIOffsetValue];
};

@ObjCDynamicPropertySetter(UIOffset) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithUIOffset:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertySetter(UIOffset, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithUIOffset:newValue] forKey:_key];
};

@ObjCDynamicPropertyGetter(UIEdgeInsets) {
    UIEdgeInsets retVal = UIEdgeInsetsZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] UIEdgeInsetsValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(UIEdgeInsets, NONATOMIC) {
    return [[self primitiveValueForKey:_key] UIEdgeInsetsValue];
};

@ObjCDynamicPropertySetter(UIEdgeInsets) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithUIEdgeInsets:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertySetter(UIEdgeInsets, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithUIEdgeInsets:newValue] forKey:_key];
};
