//
//  ObjCCodingBaseAccessors.c
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import ObjectiveC;
@import Foundation;

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBasePropertySynthesize.h"

#pragma mark - Types
typedef union _IntegerValue {
    char asChar;
    int asInt;
    short asShort;
    long asLong;
    long long asLongLong;
    unsigned char asUnsignedChar;
    unsigned int asUnsignedInt;
    unsigned short asUnsignedShort;
    unsigned long asUnsignedLong;
    unsigned long long asUnsignedLongLong;
    BOOL asBOOL;
    void * asAny;
} IntegerValue;

typedef union _FloatingPointValue {
    double asDouble;
    float asFloat;
} FloatingPointValue;

typedef union _PrimitiveValue {
    FloatingPointValue  asFloatingPoint;
    IntegerValue        asInteger;
} PrimitiveValue;

#pragma mark - Function Prototypes

static void SetInteger(id, SEL, IntegerValue);

static IntegerValue GetInteger(id, SEL);

static void SetFloating(id, SEL,FloatingPointValue);

static FloatingPointValue GetFloating(id, SEL);

#pragma mark - Register
@implementation ObjCCodingBase(NativeAccessors)
+ (void)load {
    ObjCCodingBaseRegisterAccessor("@", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("c", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("i", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("s", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("l", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("q", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("C", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("I", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("S", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("L", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("Q", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("B", (IMP)&GetInteger, (IMP)&SetInteger);
    ObjCCodingBaseRegisterAccessor("d", (IMP)&GetFloating, (IMP)&SetFloating);
    ObjCCodingBaseRegisterAccessor("f", (IMP)&GetFloating, (IMP)&SetFloating);
}
@end

#pragma mark - Function Implementations
void SetInteger(id self, SEL _cmd, IntegerValue value) {
    NSString * propertyName
    = ObjCCodingBasePropertyNameForSetter([self class], _cmd);
    
    NSAssert(
        propertyName != nil,
        @"No property name for selector \"%@\".",
        NSStringFromSelector(_cmd)
    );
    
    objc_property_t property = class_getProperty(
        [self class],
        [propertyName cStringUsingEncoding:NSUTF8StringEncoding]
    );
    
    const char * propertyType
    = property_copyAttributeValue(property, "T");
    
    [self willChangeValueForKey:propertyName];
    
    if (propertyType[0] == '@') {
        [self setPrimitiveValue:(__bridge id)(value.asAny)
                         forKey:propertyName];
    } else if (propertyType[0] == 'c') {
        [self setPrimitiveValue:@(value.asChar)
                         forKey:propertyName];
    } else if (propertyType[0] == 'i') {
        [self setPrimitiveValue:@(value.asInt)
                         forKey:propertyName];
    } else if (propertyType[0] == 's') {
        [self setPrimitiveValue:@(value.asShort)
                         forKey:propertyName];
    } else if (propertyType[0] == 'l') {
        [self setPrimitiveValue:@(value.asLong)
                         forKey:propertyName];
    } else if (propertyType[0] == 'q') {
        [self setPrimitiveValue:@(value.asLongLong)
                         forKey:propertyName];
    } else if (propertyType[0] == 'C') {
        [self setPrimitiveValue:@(value.asUnsignedChar)
                         forKey:propertyName];
    } else if (propertyType[0] == 'I') {
        [self setPrimitiveValue:@(value.asUnsignedInt)
                         forKey:propertyName];
    } else if (propertyType[0] == 'S') {
        [self setPrimitiveValue:@(value.asUnsignedShort)
                         forKey:propertyName];
    } else if (propertyType[0] == 'L') {
        [self setPrimitiveValue:@(value.asUnsignedLong)
                         forKey:propertyName];
    } else if (propertyType[0] == 'Q') {
        [self setPrimitiveValue:@(value.asUnsignedLongLong)
                         forKey:propertyName];
    } else if (propertyType[0] == 'B') {
        [self setPrimitiveValue:@(value.asBOOL)
                         forKey:propertyName];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set value of %@ with integer setter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
    }
    
    [self didChangeValueForKey:propertyName];
}

IntegerValue GetInteger(id self, SEL _cmd) {
    NSString * propertyName
    = ObjCCodingBasePropertyNameForGetter([self class], _cmd);
    
    NSAssert(
        propertyName != nil,
        @"No property name for selector \"%@\".",
        NSStringFromSelector(_cmd)
    );
    
    id value = [self primitiveValueForKey:propertyName];
    
    objc_property_t property = class_getProperty(
        [self class],
        [propertyName cStringUsingEncoding:NSUTF8StringEncoding]
    );
    
    const char * propertyType
    = property_copyAttributeValue(property, "T");
    
    if (propertyType[0] == '@') {
        return (IntegerValue)(__bridge void *)(value);
    } else if (propertyType[0] == 'c') {
        return (IntegerValue)[value charValue];
    } else if (propertyType[0] == 'i') {
        return (IntegerValue)[value intValue];
    } else if (propertyType[0] == 's') {
        return (IntegerValue)[value shortValue];
    } else if (propertyType[0] == 'l') {
        return (IntegerValue)[value longValue];
    } else if (propertyType[0] == 'q') {
        return (IntegerValue)[value longLongValue];
    } else if (propertyType[0] == 'C') {
        return (IntegerValue)[value unsignedCharValue];
    } else if (propertyType[0] == 'I') {
        return (IntegerValue)[value unsignedIntValue];
    } else if (propertyType[0] == 'S') {
        return (IntegerValue)[value unsignedShortValue];
    } else if (propertyType[0] == 'L') {
        return (IntegerValue)[value unsignedLongValue];
    } else if (propertyType[0] == 'Q') {
        return (IntegerValue)[value unsignedLongLongValue];
    } else if (propertyType[0] == 'B') {
        return (IntegerValue)[value boolValue];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot get value of %@ with integer getter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
        return (IntegerValue)-1;
    }
}

void SetFloating(id self, SEL _cmd, FloatingPointValue value) {
    NSString * propertyName
    = ObjCCodingBasePropertyNameForSetter([self class], _cmd);
    
    NSAssert(
        propertyName != nil,
        @"No property name for selector \"%@\".",
        NSStringFromSelector(_cmd)
    );
    
    objc_property_t property = class_getProperty(
        [self class],
        [propertyName cStringUsingEncoding:NSUTF8StringEncoding]
    );
    
    const char * propertyType
    = property_copyAttributeValue(property, "T");
    
    [self willChangeValueForKey:propertyName];
    
    if (propertyType[0] == 'f') {
        [self setPrimitiveValue:@(value.asFloat) forKey:propertyName];
    } else if (propertyType[0] == 'd') {
        [self setPrimitiveValue:@(value.asDouble) forKey:propertyName];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot get value of %@ with floating pointer getter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
    }
    
    [self didChangeValueForKey:propertyName];
}

FloatingPointValue GetFloating(id self, SEL _cmd) {
    NSString * propertyName
    = ObjCCodingBasePropertyNameForGetter([self class], _cmd);
    
    NSAssert(
        propertyName != nil,
        @"No property name for selector \"%@\".",
        NSStringFromSelector(_cmd)
    );
    
    id value = [self primitiveValueForKey:propertyName];
    
    objc_property_t property = class_getProperty(
        [self class],
        [propertyName cStringUsingEncoding:NSUTF8StringEncoding]
    );
    
    const char * propertyType
    = property_copyAttributeValue(property, "T");
    
    if (propertyType[0] == 'f') {
        return (FloatingPointValue)[value floatValue];
    } else if (propertyType[0] == 'd') {
        return (FloatingPointValue)[value doubleValue];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set value of %@ with floating pointer setter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
        return (FloatingPointValue)(-1.0);
    }
}
