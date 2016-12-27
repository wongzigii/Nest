//
//  ObjCDynamicPropertyAccessors-CoreMedia.m
//  Nest
//
//  Created by Manfred on 26/12/2016.
//
//

@import CoreMedia;
@import AVFoundation;

#import <Nest/ObjCDynamicPropertySynthesizer.h>

@ObjCDynamicPropertyGetter(CMTime) {
    CMTime retVal = kCMTimeZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CMTimeValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CMTime) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCMTime:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CMTime, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CMTimeValue];
};

@ObjCDynamicPropertySetter(CMTime, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCMTime:newValue] forKey:_prop];
};

@ObjCDynamicPropertyGetter(CMTimeRange) {
    CMTimeRange retVal = kCMTimeRangeZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CMTimeRangeValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CMTimeRange) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCMTimeRange:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CMTimeRange, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CMTimeRangeValue];
};

@ObjCDynamicPropertySetter(CMTimeRange, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCMTimeRange:newValue] forKey:_prop];
};

@ObjCDynamicPropertyGetter(CMTimeMapping) {
    CMTimeMapping retVal = CMTimeMappingMakeEmpty(kCMTimeRangeZero);
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] CMTimeMappingValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CMTimeMapping) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCMTimeMapping:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(CMTimeMapping, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] CMTimeMappingValue];
};

@ObjCDynamicPropertySetter(CMTimeMapping, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCMTimeMapping:newValue] forKey:_prop];
};
