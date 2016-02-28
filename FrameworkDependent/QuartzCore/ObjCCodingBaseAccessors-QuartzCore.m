//
//  ObjCCodingBaseAccessors-QuartzCore.c
//  Nest
//
//  Created by Manfred on 2/26/16.
//
//

@import Foundation;
@import ObjectiveC;
@import QuartzCore;

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
@import UIKit;
#elif TARGET_OS_MAC
@import AppKit;
#endif

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBase+Internal.h"

static void SetCATransform3DValue(id, SEL, CATransform3D);

static CATransform3D GetCATransform3DValue(id, SEL);

static id DecodeCATransform3D (NSCoder *, NSString *);

static void EncodeCATransform3D (NSCoder *, NSString *, id);
    
#pragma mark - Register
@implementation ObjCCodingBase(QuartzCoreAccessors)
+ (void)load {
    ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        (IMP)&GetCATransform3DValue,
        (IMP)&SetCATransform3DValue,
        @encode(CATransform3D),
        &DecodeCATransform3D,
        &EncodeCATransform3D
    );
}
@end

void SetCATransform3DValue(id self, SEL _cmd, CATransform3D value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CATransform3D), nil);
    
    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];
    
    free((char *)propertyType);
    
    [self willChangeValueForKey:propertyName];
    
    [self setPrimitiveValue:primitiveValue forKey:propertyName];
    
    [self didChangeValueForKey:propertyName];
}

CATransform3D GetCATransform3DValue(id self, SEL _cmd) {
    NSString * propertyName = nil;
    
    ObjCCodingBaseAssertAccessor(self, _cmd, ObjCCodingBaseAccessorKindGetter, &propertyName, NULL, NULL, @encode(CATransform3D), nil);
    
    CATransform3D value = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    
    id primitiveValue = [self primitiveValueForKey:propertyName];
    
    [primitiveValue getValue:&value];
    
    return value;
}

id DecodeCATransform3D (NSCoder * decoder, NSString * key) {
    NSData * data = [decoder decodeObjectForKey:key];
    
    CATransform3D transform = {0, 0, 0, 0, 0, 0, 0, 0, 0};
    
    [data getBytes:&transform length:sizeof(CATransform3D)];
    
    return [NSValue valueWithCATransform3D:transform];
}

void EncodeCATransform3D (NSCoder * coder, NSString * key, id value) {
    CATransform3D transform = [value CATransform3DValue];
    
    NSData * data = [NSData dataWithBytes:&transform
                                   length:sizeof(CATransform3D)];
    
    [coder encodeObject:data forKey:key];
}