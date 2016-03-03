//
//  ObjCKeyValueStore-UIKit.m
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

@import ObjectiveC;
@import UIKit;

#import <Nest/ObjCKeyValueStore.h>
#import "ObjCKeyValueStore+Internal.h"

static void SetUIOffsetValue(id, SEL, UIOffset);

static UIOffset GetUIOffsetValue(id, SEL);

static void SetUIEdgeInsetsValue(id, SEL, UIEdgeInsets);

static UIEdgeInsets GetUIEdgeInsetsValue(id, SEL);

#pragma mark - Register
@implementation ObjCKeyValueStore(UIKitAccessors)
+ (void)load {
    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetUIOffsetValue,
        (IMP)&SetUIOffsetValue,
        @encode(UIOffset)
    );

    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetUIEdgeInsetsValue,
        (IMP)&SetUIEdgeInsetsValue,
        @encode(UIEdgeInsets)
    );
}
@end

void SetUIOffsetValue(id self, SEL _cmd, UIOffset value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(UIOffset), nil);

    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

UIOffset GetUIOffsetValue(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, NULL, @encode(UIOffset), nil);

    UIOffset value = {0, 0};

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}

void SetUIEdgeInsetsValue(id self, SEL _cmd, UIEdgeInsets value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(UIEdgeInsets), nil);


    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

UIEdgeInsets GetUIEdgeInsetsValue(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, NULL, @encode(UIEdgeInsets), nil);

    UIEdgeInsets value = {0, 0, 0, 0};

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}
