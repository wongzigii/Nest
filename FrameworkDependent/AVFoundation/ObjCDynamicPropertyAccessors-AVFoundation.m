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
        retVal = [[self primitiveValueForKey:_key] CMTimeValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CMTime) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCMTime:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(CMTime, NONATOMIC) {
    return [[self primitiveValueForKey:_key] CMTimeValue];
};

@ObjCDynamicPropertySetter(CMTime, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCMTime:newValue] forKey:_key];
};

@ObjCDynamicPropertyGetter(CMTimeRange) {
    CMTimeRange retVal = kCMTimeRangeZero;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] CMTimeRangeValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CMTimeRange) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCMTimeRange:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(CMTimeRange, NONATOMIC) {
    return [[self primitiveValueForKey:_key] CMTimeRangeValue];
};

@ObjCDynamicPropertySetter(CMTimeRange, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCMTimeRange:newValue] forKey:_key];
};

@ObjCDynamicPropertyGetter(CMTimeMapping) {
    CMTimeMapping retVal = CMTimeMappingMakeEmpty(kCMTimeRangeZero);
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] CMTimeMappingValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(CMTimeMapping) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithCMTimeMapping:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(CMTimeMapping, NONATOMIC) {
    return [[self primitiveValueForKey:_key] CMTimeMappingValue];
};

@ObjCDynamicPropertySetter(CMTimeMapping, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithCMTimeMapping:newValue] forKey:_key];
};
