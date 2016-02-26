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
#import "ObjCCodingBasePropertySynthesize.h"

/// Represents `CGPoint` and `CGSize`
typedef struct _CGFloat2 {
    CGFloat member1;
    CGFloat member2;
} CGFloat2;

/// Represents `CGRect`
typedef struct _CGFloat4 {
    CGFloat member1;
    CGFloat member2;
    CGFloat member3;
    CGFloat member4;
} CGFloat4;

static void SetCGFloat2Value(id, SEL, CGFloat2);

static CGFloat2 GetCGFloat2Value(id, SEL);

static void SetCGFloat4Value(id, SEL, CGFloat4);

static CGFloat4 GetCGFloat4Value(id, SEL);

#pragma mark - Register
@implementation ObjCCodingBase(UIKitAccessors)
+ (void)load {
    ObjCCodingBaseRegisterAccessor(
        "{UIOffset=",
        (IMP)&GetCGFloat2Value,
        (IMP)&SetCGFloat2Value
    );
    
    ObjCCodingBaseRegisterAccessor(
        "{UIEdgeInsets=",
        (IMP)&GetCGFloat4Value,
        (IMP)&SetCGFloat4Value
    );
}
@end

void SetCGFloat2Value(id self, SEL _cmd, CGFloat2 value) {
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
    
    if (strncmp(propertyType, "{UIOffset=", 10) == 0) {
        NSValue * primitiveValue
        = [NSValue valueWithBytes:&value objCType:propertyType];
        [self setPrimitiveValue:primitiveValue forKey:propertyName];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set value of %@ with CGFloat 2 setter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
    }
    
    [self didChangeValueForKey:propertyName];
}

CGFloat2 GetCGFloat2Value(id self, SEL _cmd) {
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
    
    CGFloat2 convertedValue = {0, 0};
    
    [value getValue:&convertedValue];
    
    if (strncmp(propertyType, "{CGSize=", 8) == 0
        || strncmp(propertyType, "{CGPoint=", 9) == 0
        || strncmp(propertyType, "{CGVector=", 10) == 0)
    {
        return convertedValue;
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot get value of %@ with CGFloat 2 getter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
        return (CGFloat2){-1, -1};
    }
}

void SetCGFloat4Value(id self, SEL _cmd, CGFloat4 value) {
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
    
    if (strncmp(propertyType, "{UIEdgeInsets=", 14) == 0) {
        NSValue * primitiveValue
        = [NSValue valueWithBytes:&value objCType:propertyType];
        [self setPrimitiveValue:primitiveValue forKey:propertyName];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set value of %@ with CGFloat 4 setter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
    }
    
    [self didChangeValueForKey:propertyName];
}

CGFloat4 GetCGFloat4Value(id self, SEL _cmd) {
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
    
    CGFloat4 convertedValue = {0, 0, 0, 0};
    
    [value getValue:&convertedValue];
    
    if (strncmp(propertyType, "{UIEdgeInsets=", 14) == 0) {
        return convertedValue;
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot get value of %@ with CGFloat 4 getter",
         [NSString stringWithCString:propertyType encoding:NSUTF8StringEncoding]];
        return (CGFloat4){-1, -1, -1, -1};
    }
}