//
//  ObjCKeyValueStore-CoreGraphics.m
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

@import ObjectiveC;
@import CoreGraphics;

#import <Nest/ObjCKeyValueStore.h>
#import "ObjCKeyValueStore+Internal.h"

/// Represents `CGPoint`, `CGVector` and `CGSize`
typedef struct _CGFloat2 {
    CGFloat member1;
    CGFloat member2;
} CGFloat2;

static void SetCGFloat2Value(id, SEL, CGFloat2);

static CGFloat2 GetCGFloat2Value(id, SEL);

static void SetCGRectValue(id, SEL, CGRect);

static CGRect GetCGRectValue(id, SEL);

static void SetCGAffineTransformValue(id, SEL, CGAffineTransform);

static CGAffineTransform GetCGAffineTransformValue(id, SEL);

#pragma mark - Register
@implementation ObjCKeyValueStore(CoreGraphicsAccessors)
+ (void)load {
    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCGFloat2Value,
        (IMP)&SetCGFloat2Value,
        @encode(CGPoint)
    );

    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCGFloat2Value,
        (IMP)&SetCGFloat2Value,
        @encode(CGSize)
    );

    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCGFloat2Value,
        (IMP)&SetCGFloat2Value,
        @encode(CGVector)
    );

    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCGRectValue,
        (IMP)&SetCGRectValue,
        @encode(CGRect)
    );

    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCGAffineTransformValue,
        (IMP)&SetCGAffineTransformValue,
        @encode(CGAffineTransform)
    );
}
@end

void SetCGFloat2Value(id self, SEL _cmd, CGFloat2 value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, "CGFloat2", @encode(CGPoint), @encode(CGVector), @encode(CGSize), nil);

    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

CGFloat2 GetCGFloat2Value(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, "CGFloat2", @encode(CGPoint), @encode(CGVector), @encode(CGSize), nil);

    CGFloat2 value = {0, 0};

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}

void SetCGRectValue(id self, SEL _cmd, CGRect value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CGRect), nil);


    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

CGRect GetCGRectValue(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, NULL, @encode(CGRect), nil);

    CGRect value = CGRectMake(0, 0, 0, 0);

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}

void SetCGAffineTransformValue(id self, SEL _cmd, CGAffineTransform value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CGAffineTransform), nil);

    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

CGAffineTransform GetCGAffineTransformValue(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, NULL, @encode(CGAffineTransform), nil);

    CGAffineTransform value = {0, 0, 0, 0, 0, 0};

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}
