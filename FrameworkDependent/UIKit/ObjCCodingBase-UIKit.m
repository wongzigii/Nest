//
//  ObjCCodingBase-UIKit.c
//  Nest
//
//  Created by Manfred on 2/26/16.
//
//

@import UIKit;
@import ObjectiveC;

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBase+Internal.h"

static id DecodeUIOffset (Class, NSCoder *, NSString *);

static void EncodeUIOffset (Class, NSCoder *, NSString *, id);

static id DecodeUIEdgeInsets (Class, NSCoder *, NSString *);

static void EncodeUIEdgeInsets (Class, NSCoder *, NSString *, id);

#pragma mark - Register
@implementation ObjCCodingBase(UIKitAccessors)
+ (void)load {
    ObjCCodingBaseRegisterCodingCallBacks(
        @encode(UIOffset),
        &DecodeUIOffset,
        &EncodeUIOffset
    );
    
    ObjCCodingBaseRegisterCodingCallBacks(
        @encode(UIEdgeInsets),
        &DecodeUIEdgeInsets,
        &EncodeUIEdgeInsets
    );
}
@end

id DecodeUIOffset (Class aClass, NSCoder * decoder, NSString * key) {
    UIOffset offset = [decoder decodeUIOffsetForKey:key];
    
    return [NSValue valueWithUIOffset:offset];
}

void EncodeUIOffset (Class aClass, NSCoder * coder, NSString * key, id value) {
    UIOffset offset = [value UIOffsetValue];
    
    [coder encodeUIOffset:offset forKey:key];
}

id DecodeUIEdgeInsets (Class aClass, NSCoder * decoder, NSString * key) {
    UIEdgeInsets edgeInsets = [decoder decodeUIEdgeInsetsForKey:key];
    
    return [NSValue valueWithUIEdgeInsets:edgeInsets];
}

void EncodeUIEdgeInsets (Class aClass, NSCoder * coder, NSString * key, id value) {
    UIEdgeInsets edgeInsets = [value UIEdgeInsetsValue];
    
    [coder encodeUIEdgeInsets:edgeInsets forKey:key];
}
