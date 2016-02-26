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

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBasePropertySynthesize.h"

static void SetCATransform3DValue(id, SEL, CATransform3D);

static CATransform3D GetCATransform3DValue(id, SEL);

#pragma mark - Register
@implementation ObjCCodingBase(QuartzCoreAccessors)
+ (void)load {
    
    ObjCCodingBaseRegisterAccessor(
        "{CATransform3D=",
        (IMP)&GetCATransform3DValue,
        (IMP)&SetCATransform3DValue
    );
}
@end

void SetCATransform3DValue(id self, SEL _cmd, CATransform3D value) {
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
    
    if (strncmp(propertyType, "{CGAffineTransform=", 15) == 0) {
        NSValue * primitiveValue
        = [NSValue valueWithBytes:&value objCType:propertyType];
        [self setPrimitiveValue:primitiveValue forKey:propertyName];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set value of %@ with setter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
    }
    
    [self didChangeValueForKey:propertyName];
}

CATransform3D GetCATransform3DValue(id self, SEL _cmd) {
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
    
    CATransform3D convertedValue
    = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    
    [value getValue:&convertedValue];
    
    if (strncmp(propertyType, "{CGAffineTransform=", 15) == 0) {
        return convertedValue;
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot get value of %@ with getter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
        return (CATransform3D){
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
        };
    }
}