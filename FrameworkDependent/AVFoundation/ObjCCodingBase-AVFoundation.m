//
//  ObjCCodingBase-AVFoundation.m
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

static id DecodeCMTime (Class, NSCoder *, NSString *);

static void EncodeCMTime (Class, NSCoder *, NSString *, id);

static id DecodeCMTimeRange (Class, NSCoder *, NSString *);

static void EncodeCMTimeRange (Class, NSCoder *, NSString *, id);

static id DecodeCMTimeMapping (Class, NSCoder *, NSString *);

static void EncodeCMTimeMapping (Class, NSCoder *, NSString *, id);

#pragma mark - Register
@implementation ObjCCodingBase(AVFoundationAccessors)
+ (void)load {
    ObjCCodingBaseRegisterCodingCallBacks(
        @encode(CMTime),
        &DecodeCMTime,
        &EncodeCMTime
    );
    
    ObjCCodingBaseRegisterCodingCallBacks(
        @encode(CMTimeRange),
        &DecodeCMTimeRange,
        &EncodeCMTimeRange
    );
    
    ObjCCodingBaseRegisterCodingCallBacks(
        @encode(CMTimeMapping),
        &DecodeCMTimeMapping,
        &EncodeCMTimeMapping
    );
}
@end

id DecodeCMTime (Class aClass, NSCoder * decoder, NSString * key) {
    CMTime time = [decoder decodeCMTimeForKey: key];
    
    return [NSValue valueWithCMTime:time];
}

void EncodeCMTime (Class aClass, NSCoder * coder, NSString * key, id value) {
    CMTime time = [value CMTimeValue];
    
    [coder encodeCMTime:time forKey:key];
}

id DecodeCMTimeRange (Class aClass, NSCoder * decoder, NSString * key) {
    CMTimeRange timeRange = [decoder decodeCMTimeRangeForKey: key];
    
    return [NSValue valueWithCMTimeRange:timeRange];
}

void EncodeCMTimeRange (Class aClass, NSCoder * coder, NSString * key, id value) {
    CMTimeRange timeRange = [value CMTimeRangeValue];
    
    [coder encodeCMTimeRange:timeRange forKey:key];
}

id DecodeCMTimeMapping (Class aClass, NSCoder * decoder, NSString * key) {
    CMTimeMapping timeMapping = [decoder decodeCMTimeMappingForKey: key];
    
    return [NSValue valueWithCMTimeMapping:timeMapping];
}

void EncodeCMTimeMapping (Class aClass, NSCoder * coder, NSString * key, id value) {
    CMTimeMapping timeMapping = [value CMTimeMappingValue];
    
    [coder encodeCMTimeMapping:timeMapping forKey:key];
}
