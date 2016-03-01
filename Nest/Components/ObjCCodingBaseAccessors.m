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
#import "ObjCCodingBase+Internal.h"

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
} IntegerValue;

typedef union _FloatingPointValue {
    double asDouble;
    float asFloat;
} FloatingPointValue;

#pragma mark - Function Prototypes

static void SetInteger(id, SEL, IntegerValue);

static IntegerValue GetInteger(id, SEL);

static void SetFloating(id, SEL, FloatingPointValue);

static FloatingPointValue GetFloating(id, SEL);

static void SetObject(id, SEL, id);

static id GetObject(id, SEL);

static void SetSelector(id, SEL, SEL);

static SEL GetSelector(id, SEL);

static void SetNSRange(id, SEL, NSRange);

static NSRange GetNSRange(id, SEL);

#pragma mark - Register
@implementation ObjCCodingBase(NativeAccessors)
+ (void)load {
    ObjCCodingBaseRegisterAccessor((IMP)&GetSelector, (IMP)&SetSelector, @encode(SEL));
    
    ObjCCodingBaseRegisterAccessor((IMP)&GetObject, (IMP)&SetObject, @encode(id));
    
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(char));
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(int));
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(short));
#ifdef __LP64__
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, "l");
#else
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(long));
#endif
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(long long));
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(unsigned char));
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(unsigned int));
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(unsigned short));
#ifdef __LP64__
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, "L");
#else
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(unsigned long));
#endif
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(unsigned long long));
    ObjCCodingBaseRegisterAccessor((IMP)&GetInteger, (IMP)&SetInteger, @encode(BOOL));
    
    ObjCCodingBaseRegisterAccessor((IMP)&GetFloating, (IMP)&SetFloating, @encode(double));
    ObjCCodingBaseRegisterAccessor((IMP)&GetFloating, (IMP)&SetFloating, @encode(float));
    
    ObjCCodingBaseRegisterAccessor((IMP)&GetNSRange, (IMP)&SetNSRange, @encode(NSRange));
}
@end

#pragma mark - Function Implementations
void SetInteger(id self, SEL _cmd, IntegerValue value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, "integer", @encode(char), @encode(short), @encode(int), @encode(long), @encode(long long), @encode(unsigned char), @encode(unsigned short), @encode(unsigned int), @encode(unsigned long), @encode(unsigned long long), @encode(BOOL), nil);
    
    [self willChangeValueForKey:propertyName];
    
    /* Because `NSNumber` doesn't get `-initWithBytes:objCType:` implemented,
     the super implementation(belongs to `NSValue`) always returns
     `NSConcreteValue` instance instead of `NSNumber`'s concrete class instance,
     and `NSCoder`'s decoding for numbers relies on `NSNumber`'s accessor, we
     must dispatch the conversion manually.
     */
    if (propertyType[0] == 'c') {
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
    }
    
    free((char *)propertyType);
    
    [self didChangeValueForKey:propertyName];
}

IntegerValue GetInteger(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, "integer", @encode(char), @encode(short), @encode(int), @encode(long), @encode(long long), @encode(unsigned char), @encode(unsigned short), @encode(unsigned int), @encode(unsigned long), @encode(unsigned long long), @encode(BOOL), nil);
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    // Use the biggest sized type to set 0.
    IntegerValue value = (IntegerValue)(long long)0;
    
    [primitiveValue getValue:&value];
    
    return value;
}

void SetFloating(id self, SEL _cmd, FloatingPointValue value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, "floating point", @encode(double), @encode(float), nil);
    
    [self willChangeValueForKey:propertyName];
    
    /* Because `NSNumber` doesn't get `-initWithBytes:objCType:` implemented,
     the super implementation(belongs to `NSValue`) always returns 
     `NSConcreteValue` instance instead of `NSNumber`'s concrete class instance,
     and `NSCoder`'s decoding for numbers relies on `NSNumber`'s accessor, we 
     must dispatch the conversion manually.
     */
    if (propertyType[0] == 'f') {
        [self setPrimitiveValue:@(value.asFloat) forKey:propertyName];
    } else if (propertyType[0] == 'd') {
        [self setPrimitiveValue:@(value.asDouble) forKey:propertyName];
    }
    
    free((char *)propertyType);
    
    [self didChangeValueForKey:propertyName];
}

FloatingPointValue GetFloating(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, "floating point", @encode(double), @encode(float), nil);
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    // Use the biggest sized type to set 0.
    FloatingPointValue floatingPointValue = (FloatingPointValue)(double)0.0;
    
    [primitiveValue getValue:&floatingPointValue];
    
    return floatingPointValue;
}

void SetObject(id self, SEL _cmd, id value) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, NULL, "object", @encode(id), nil);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:value forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

id GetObject(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, "object", @encode(id), nil);
    
    id value = [self primitiveValueForKey:propertyName];
    
    return value;
}

void SetSelector(id self, SEL _cmd, SEL selector) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, NULL, "selector", @encode(SEL), nil);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:NSStringFromSelector(selector) forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

SEL GetSelector(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, "selector", @encode(SEL), nil);
    
    id value = [self primitiveValueForKey:propertyName];
    
    return NSSelectorFromString(value);
}

void SetNSRange(id self, SEL _cmd, NSRange range) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, NULL, NULL, @encode(NSRange), nil);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:[NSValue valueWithRange:range] forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

NSRange GetNSRange(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(NSRange), nil);
    
    id value = [self primitiveValueForKey:propertyName];
    
    return [value rangeValue];
}
