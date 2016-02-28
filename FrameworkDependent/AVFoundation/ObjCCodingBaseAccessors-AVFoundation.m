//
//  ObjCCodingBaseAccessors-AVFoundation.m
//  Nest
//
//  Created by Manfred on 2/28/16.
//
//

@import Foundation;
@import ObjectiveC;
@import AVFoundation;

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBase+Internal.h"

static void SetCMTimeValue(id, SEL, CMTime);

static CMTime GetCMTimeValue(id, SEL);

static void SetCMTimeRangeValue(id, SEL, CMTimeRange);

static CMTimeRange GetCMTimeRangeValue(id, SEL);

static void SetCMTimeMappingValue(id, SEL, CMTimeMapping);

static CMTimeMapping GetCMTimeMappingValue(id, SEL);

static id DecodeCMTime (NSCoder *, NSString *);

static void EncodeCMTime (NSCoder *, NSString *, id);

static id DecodeCMTimeRange (NSCoder *, NSString *);

static void EncodeCMTimeRange (NSCoder *, NSString *, id);

static id DecodeCMTimeMapping (NSCoder *, NSString *);

static void EncodeCMTimeMapping (NSCoder *, NSString *, id);

#pragma mark - Register
@implementation ObjCCodingBase(AVFoundationAccessors)
+ (void)load {
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCMTimeValue,
        (IMP)&SetCMTimeValue,
        @encode(CMTime),
        &DecodeCMTime,
        &EncodeCMTime
    );
    
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCMTimeRangeValue,
        (IMP)&SetCMTimeRangeValue,
        @encode(CMTimeRange),
        &DecodeCMTimeRange,
        &EncodeCMTimeRange
    );
    
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCMTimeMappingValue,
        (IMP)&SetCMTimeMappingValue,
        @encode(CMTimeMapping),
        &DecodeCMTimeMapping,
        &EncodeCMTimeMapping
    );
}
@end

void SetCMTimeValue(id self, SEL _cmd, CMTime value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CMTime), nil);
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

static CMTime GetCMTimeValue(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(CMTime), nil);
    
    CMTime value = kCMTimeZero;
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

void SetCMTimeRangeValue(id self, SEL _cmd, CMTimeRange value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CMTimeRange), nil);
    
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

CMTimeRange GetCMTimeRangeValue(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(CMTimeRange), nil);
    
    CMTimeRange value = kCMTimeRangeZero;
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

void SetCMTimeMappingValue(id self, SEL _cmd, CMTimeMapping value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CMTimeMapping), nil);
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

CMTimeMapping GetCMTimeMappingValue(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(CMTimeMapping), nil);
    
    CMTimeMapping value = {kCMTimeRangeZero, kCMTimeRangeZero};
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

id DecodeCMTime (NSCoder * decoder, NSString * key) {
    CMTime time = [decoder decodeCMTimeForKey: key];
    
    return [NSValue valueWithCMTime:time];
}

void EncodeCMTime (NSCoder * coder, NSString * key, id value) {
    CMTime time = [value CMTimeValue];
    
    [coder encodeCMTime:time forKey:key];
}

id DecodeCMTimeRange (NSCoder * decoder, NSString * key) {
    CMTimeRange timeRange = [decoder decodeCMTimeRangeForKey: key];
    
    return [NSValue valueWithCMTimeRange:timeRange];
}

void EncodeCMTimeRange (NSCoder * coder, NSString * key, id value) {
    CMTimeRange timeRange = [value CMTimeRangeValue];
    
    [coder encodeCMTimeRange:timeRange forKey:key];
}

id DecodeCMTimeMapping (NSCoder * decoder, NSString * key) {
    CMTimeMapping timeMapping = [decoder decodeCMTimeMappingForKey: key];
    
    return [NSValue valueWithCMTimeMapping:timeMapping];
}

void EncodeCMTimeMapping (NSCoder * coder, NSString * key, id value) {
    CMTimeMapping timeMapping = [value CMTimeMappingValue];
    
    [coder encodeCMTimeMapping:timeMapping forKey:key];
}
