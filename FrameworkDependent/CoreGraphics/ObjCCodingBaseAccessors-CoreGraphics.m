//
//  ObjCCodingBaseAccessors-CoreGraphics.c
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import ObjectiveC;
@import Foundation;
@import CoreGraphics;

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
@import UIKit;
#elif TARGET_OS_MAC
@import AppKit;
#endif

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBase+Internal.h"

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

static id DecodeCGPoint (Class, NSCoder *, NSString *);
static void EncodeCGPoint (Class, NSCoder *, NSString *, id);

static id DecodeCGVector (Class, NSCoder *, NSString *);
static void EncodeCGVector (Class, NSCoder *, NSString *, id);

static id DecodeCGSize (Class, NSCoder *, NSString *);
static void EncodeCGSize (Class, NSCoder *, NSString *, id);

static id DecodeCGRect (Class, NSCoder *, NSString *);
static void EncodeCGRect (Class, NSCoder *, NSString *, id);

static id DecodeCGAffineTransform (Class, NSCoder *, NSString *);
static void EncodeCGAffineTransform (Class, NSCoder *, NSString *, id);

#pragma mark - Register
@implementation ObjCCodingBase(CoreGraphicsAccessors)
+ (void)load {
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCGFloat2Value,
        (IMP)&SetCGFloat2Value,
        @encode(CGPoint),
        &DecodeCGPoint,
        &EncodeCGPoint
    );
    
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCGFloat2Value,
        (IMP)&SetCGFloat2Value,
        @encode(CGSize),
        &DecodeCGSize,
        &EncodeCGSize
    );
    
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCGFloat2Value,
        (IMP)&SetCGFloat2Value,
        @encode(CGVector),
        &DecodeCGVector,
        &EncodeCGVector
    );
    
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCGRectValue,
        (IMP)&SetCGRectValue,
        @encode(CGRect),
        &DecodeCGRect,
        &EncodeCGRect
    );
    
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCGAffineTransformValue,
        (IMP)&SetCGAffineTransformValue,
        @encode(CGAffineTransform),
        &DecodeCGAffineTransform,
        &EncodeCGAffineTransform
    );
}
@end

void SetCGFloat2Value(id self, SEL _cmd, CGFloat2 value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, "CGFloat2", @encode(CGPoint), @encode(CGVector), @encode(CGSize), nil);
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value 
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

CGFloat2 GetCGFloat2Value(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, "CGFloat2", @encode(CGPoint), @encode(CGVector), @encode(CGSize), nil);
    
    CGFloat2 value = {0, 0};
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

void SetCGRectValue(id self, SEL _cmd, CGRect value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CGRect), nil);
    
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

CGRect GetCGRectValue(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(CGRect), nil);
    
    CGRect value = CGRectMake(0, 0, 0, 0);
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

void SetCGAffineTransformValue(id self, SEL _cmd, CGAffineTransform value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CGAffineTransform), nil);
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

CGAffineTransform GetCGAffineTransformValue(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(CGAffineTransform), nil);
    
    CGAffineTransform value = {0, 0, 0, 0, 0, 0};
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

#pragma mark Coding
id DecodeCGPoint (Class aClass, NSCoder * decoder, NSString * key) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGPoint point = [decoder decodeCGPointForKey:key];
    return [NSValue valueWithCGPoint:point];
#elif TARGET_OS_MAC
    CGPoint point = [decoder decodePointForKey: key];
    return [NSValue valueWithPoint: point];
#endif
}

void EncodeCGPoint (Class aClass, NSCoder * coder, NSString * key, id value) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGPoint point = [value CGPointValue];
    [coder encodeCGPoint:point forKey:key];
#elif TARGET_OS_MAC
    CGPoint point = [value pointValue];
    [coder encodePoint:point forKey:key];
#endif
}

id DecodeCGVector (Class aClass, NSCoder * decoder, NSString * key) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGVector vector = [decoder decodeCGVectorForKey:key];
    return [NSValue valueWithCGVector:vector];
#elif TARGET_OS_MAC
    NSData * data = [decoder decodeObjectForKey:key];
    
    CGVector vector = {0, 0};
    [data getBytes:&vector length:sizeof(CGVector)];
    
    return [NSValue valueWithBytes:&vector objCType:@encode(CGVector)];
#endif
}

void EncodeCGVector (Class aClass, NSCoder * coder, NSString * key, id value) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGVector vector = [value CGVectorValue];
    [coder encodeCGVector:vector forKey:key];
#elif TARGET_OS_MAC
    CGVector vector = {0, 0};
    
    [value getValue:&vector];
    
    NSData * data = [NSData dataWithBytes:&vector
                                   length:sizeof(CGVector)];
    
    [coder encodeObject:data forKey:key];
#endif
}

id DecodeCGSize (Class aClass, NSCoder * decoder, NSString * key) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGSize size = [decoder decodeCGSizeForKey:key];
    return [NSValue valueWithCGSize:size];
#elif TARGET_OS_MAC
    CGSize size = [decoder decodeSizeForKey: key];
    return [NSValue valueWithSize: size];
#endif
}

void EncodeCGSize (Class aClass, NSCoder * coder, NSString * key, id value) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGSize size = [value CGSizeValue];
    [coder encodeCGSize:size forKey:key];
#elif TARGET_OS_MAC
    CGSize size = [value sizeValue];
    [coder encodeSize:size forKey:key];
#endif
}

id DecodeCGRect (Class aClass, NSCoder * decoder, NSString * key) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGRect rect = [decoder decodeCGRectForKey:key];
    return [NSValue valueWithCGRect:rect];
#elif TARGET_OS_MAC
    CGRect rect = [decoder decodeRectForKey: key];
    return [NSValue valueWithRect: rect];
#endif
}

void EncodeCGRect (Class aClass, NSCoder * coder, NSString * key, id value) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGRect rect = [value CGRectValue];
    [coder encodeCGRect:rect forKey:key];
#elif TARGET_OS_MAC
    CGRect rect = [value rectValue];
    [coder encodeRect:rect forKey:key];
#endif
}

id DecodeCGAffineTransform (Class aClass, NSCoder * decoder, NSString * key) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGAffineTransform transform = [decoder decodeCGAffineTransformForKey:key];
    return [NSValue valueWithCGAffineTransform:transform];
#elif TARGET_OS_MAC
    NSData * data = [decoder decodeObjectForKey:key];
    
    CGAffineTransform transform = {0, 0, 0, 0, 0, 0};
    
    [data getBytes:&transform length:sizeof(CGAffineTransform)];
    
    return [NSValue valueWithBytes:&transform 
                          objCType:@encode(CGAffineTransform)];
#endif
}

void EncodeCGAffineTransform (Class aClass, NSCoder * coder, NSString * key, id value) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGAffineTransform transform = [value CGAffineTransformValue];
    [coder encodeCGAffineTransform:transform forKey:key];
#elif TARGET_OS_MAC
    CGAffineTransform transform = {0, 0, 0, 0, 0, 0};
    
    [value getValue:&transform];
    
    NSData * data = [NSData dataWithBytes:&transform
                                   length:sizeof(CGAffineTransform)];
    
    [coder encodeObject:data forKey:key];
#endif
}
