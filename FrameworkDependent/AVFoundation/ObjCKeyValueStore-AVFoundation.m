//
//  ObjCKeyValueStore-AVFoundation.m
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

@import ObjectiveC;
@import AVFoundation;

#import <Nest/ObjCKeyValueStore.h>
#import "ObjCKeyValueStore+Internal.h"

static void SetCMTimeValue(id, SEL, CMTime);

static CMTime GetCMTimeValue(id, SEL);

static void SetCMTimeRangeValue(id, SEL, CMTimeRange);

static CMTimeRange GetCMTimeRangeValue(id, SEL);

static void SetCMTimeMappingValue(id, SEL, CMTimeMapping);

static CMTimeMapping GetCMTimeMappingValue(id, SEL);

#pragma mark - Register
@implementation ObjCKeyValueStore(AVFoundationAccessors)
+ (void)load {
    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCMTimeValue,
        (IMP)&SetCMTimeValue,
        @encode(CMTime)
    );

    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCMTimeRangeValue,
        (IMP)&SetCMTimeRangeValue,
        @encode(CMTimeRange)
    );

    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCMTimeMappingValue,
        (IMP)&SetCMTimeMappingValue,
        @encode(CMTimeMapping)
    );
}
@end

void SetCMTimeValue(id self, SEL _cmd, CMTime value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CMTime), nil);

    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

static CMTime GetCMTimeValue(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, NULL, @encode(CMTime), nil);

    CMTime value = kCMTimeZero;

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}

void SetCMTimeRangeValue(id self, SEL _cmd, CMTimeRange value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CMTimeRange), nil);


    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

CMTimeRange GetCMTimeRangeValue(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, NULL, @encode(CMTimeRange), nil);

    CMTimeRange value = kCMTimeRangeZero;

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}

void SetCMTimeMappingValue(id self, SEL _cmd, CMTimeMapping value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CMTimeMapping), nil);

    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

CMTimeMapping GetCMTimeMappingValue(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, NULL, @encode(CMTimeMapping), nil);

    CMTimeMapping value = {kCMTimeRangeZero, kCMTimeRangeZero};

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}
