//
//  ObjCDynamicCoding-CoreGraphics.c
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
#elif TARGET_OS_OSX
@import AppKit;
#endif

#import <Nest/MacroUtilities.h>
#import "ObjCDynamicCoding.h"

/// Represents `CGPoint`, `CGVector` and `CGSize`
typedef struct _CGFloat2 {
    CGFloat member1;
    CGFloat member2;
} CGFloat2;

static id DecodeCGPoint (Class, NSCoder *, NSString *);
static void EncodeCGPoint (Class, NSCoder *, NSString *, id);

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
static id DecodeCGVector (Class, NSCoder *, NSString *);
static void EncodeCGVector (Class, NSCoder *, NSString *, id);
#endif

static id DecodeCGSize (Class, NSCoder *, NSString *);
static void EncodeCGSize (Class, NSCoder *, NSString *, id);

static id DecodeCGRect (Class, NSCoder *, NSString *);
static void EncodeCGRect (Class, NSCoder *, NSString *, id);

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
static id DecodeCGAffineTransform (Class, NSCoder *, NSString *);
static void EncodeCGAffineTransform (Class, NSCoder *, NSString *, id);
#endif

#pragma mark - Register
_NEST_MODULE_CONSTRUCTOR_HIGH_PRIORITY
static void ObjCDynamicCodingLoadCustomCallBacks() {
    ObjCDynamicCodingRegisterCodingCallBacks(
        @encode(CGPoint),
        &DecodeCGPoint,
        &EncodeCGPoint
    );
    
    ObjCDynamicCodingRegisterCodingCallBacks(
        @encode(CGSize),
        &DecodeCGSize,
        &EncodeCGSize
    );
    
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    ObjCDynamicCodingRegisterCodingCallBacks(
        @encode(CGVector),
        &DecodeCGVector,
        &EncodeCGVector
    );
#endif
    
    ObjCDynamicCodingRegisterCodingCallBacks(
        @encode(CGRect),
        &DecodeCGRect,
        &EncodeCGRect
    );
    
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    ObjCDynamicCodingRegisterCodingCallBacks(
        @encode(CGAffineTransform),
        &DecodeCGAffineTransform,
        &EncodeCGAffineTransform
    );
#endif
}

#pragma mark Coding
id DecodeCGPoint (Class aClass, NSCoder * decoder, NSString * key) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGPoint point = [decoder decodeCGPointForKey:key];
    return [NSValue valueWithCGPoint:point];
#elif TARGET_OS_OSX
    CGPoint point = [decoder decodePointForKey: key];
    return [NSValue valueWithPoint: point];
#endif
}

void EncodeCGPoint (Class aClass, NSCoder * coder, NSString * key, id value) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGPoint point = [value CGPointValue];
    [coder encodeCGPoint:point forKey:key];
#elif TARGET_OS_OSX
    CGPoint point = [value pointValue];
    [coder encodePoint:point forKey:key];
#endif
}

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
id DecodeCGVector (Class aClass, NSCoder * decoder, NSString * key) {
    CGVector vector = [decoder decodeCGVectorForKey:key];
    return [NSValue valueWithCGVector:vector];
}

void EncodeCGVector (Class aClass, NSCoder * coder, NSString * key, id value) {
    CGVector vector = [value CGVectorValue];
    [coder encodeCGVector:vector forKey:key];
}
#endif

id DecodeCGSize (Class aClass, NSCoder * decoder, NSString * key) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGSize size = [decoder decodeCGSizeForKey:key];
    return [NSValue valueWithCGSize:size];
#elif TARGET_OS_OSX
    CGSize size = [decoder decodeSizeForKey: key];
    return [NSValue valueWithSize: size];
#endif
}

void EncodeCGSize (Class aClass, NSCoder * coder, NSString * key, id value) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGSize size = [value CGSizeValue];
    [coder encodeCGSize:size forKey:key];
#elif TARGET_OS_OSX
    CGSize size = [value sizeValue];
    [coder encodeSize:size forKey:key];
#endif
}

id DecodeCGRect (Class aClass, NSCoder * decoder, NSString * key) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGRect rect = [decoder decodeCGRectForKey:key];
    return [NSValue valueWithCGRect:rect];
#elif TARGET_OS_OSX
    CGRect rect = [decoder decodeRectForKey: key];
    return [NSValue valueWithRect: rect];
#endif
}

void EncodeCGRect (Class aClass, NSCoder * coder, NSString * key, id value) {
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    CGRect rect = [value CGRectValue];
    [coder encodeCGRect:rect forKey:key];
#elif TARGET_OS_OSX
    CGRect rect = [value rectValue];
    [coder encodeRect:rect forKey:key];
#endif
}

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
id DecodeCGAffineTransform (Class aClass, NSCoder * decoder, NSString * key) {
    CGAffineTransform transform = [decoder decodeCGAffineTransformForKey:key];
    return [NSValue valueWithCGAffineTransform:transform];
}

void EncodeCGAffineTransform (Class aClass, NSCoder * coder, NSString * key, id value) {
    CGAffineTransform transform = [value CGAffineTransformValue];
    [coder encodeCGAffineTransform:transform forKey:key];
}
#endif
