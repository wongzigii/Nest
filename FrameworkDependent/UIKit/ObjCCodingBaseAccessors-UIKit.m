//
//  ObjCCodingBaseAccessors-UIKit.c
//  Nest
//
//  Created by Manfred on 2/26/16.
//
//

@import UIKit;
@import ObjectiveC;

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBase+Internal.h"

static void SetUIOffsetValue(id, SEL, UIOffset);

static UIOffset GetUIOffsetValue(id, SEL);

static void SetUIEdgeInsetsValue(id, SEL, UIEdgeInsets);

static UIEdgeInsets GetUIEdgeInsetsValue(id, SEL);

static id DecodeUIOffset (NSCoder *, NSString *);

static void EncodeUIOffset (NSCoder *, NSString *, id);

static id DecodeUIEdgeInsets (NSCoder *, NSString *);

static void EncodeUIEdgeInsets (NSCoder *, NSString *, id);

#pragma mark - Register
@implementation ObjCCodingBase(UIKitAccessors)
+ (void)load {
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetUIOffsetValue,
        (IMP)&SetUIOffsetValue,
        @encode(UIOffset),
        &DecodeUIOffset,
        &EncodeUIOffset
    );
    
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetUIEdgeInsetsValue,
        (IMP)&SetUIEdgeInsetsValue,
        @encode(UIEdgeInsets),
        &DecodeUIEdgeInsets,
        &EncodeUIEdgeInsets
    );
}
@end

void SetUIOffsetValue(id self, SEL _cmd, UIOffset value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(UIOffset), nil);
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

UIOffset GetUIOffsetValue(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(UIOffset), nil);
    
    UIOffset value = {0, 0};
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

void SetUIEdgeInsetsValue(id self, SEL _cmd, UIEdgeInsets value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(UIEdgeInsets), nil);
    
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

UIEdgeInsets GetUIEdgeInsetsValue(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(UIEdgeInsets), nil);
    
    UIEdgeInsets value = {0, 0, 0, 0};
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

id DecodeUIOffset (NSCoder * decoder, NSString * key) {
    UIOffset offset = [decoder decodeUIOffsetForKey:key];
    
    return [NSValue valueWithUIOffset:offset];
}

void EncodeUIOffset (NSCoder * coder, NSString * key, id value) {
    UIOffset offset = [value UIOffsetValue];
    
    [coder encodeUIOffset:offset forKey:key];
}

id DecodeUIEdgeInsets (NSCoder * decoder, NSString * key) {
    UIEdgeInsets edgeInsets = [decoder decodeUIEdgeInsetsForKey:key];
    
    return [NSValue valueWithUIEdgeInsets:edgeInsets];
}

void EncodeUIEdgeInsets (NSCoder * coder, NSString * key, id value) {
    UIEdgeInsets edgeInsets = [value UIEdgeInsetsValue];
    
    [coder encodeUIEdgeInsets:edgeInsets forKey:key];
}
