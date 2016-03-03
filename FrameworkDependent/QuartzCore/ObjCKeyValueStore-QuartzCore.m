//
//  ObjCKeyValueStore-QuartzCore.m
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

@import ObjectiveC;
@import QuartzCore;

#import <Nest/ObjCKeyValueStore.h>
#import "ObjCKeyValueStore+Internal.h"

static void SetCATransform3DValue(id, SEL, CATransform3D);

static CATransform3D GetCATransform3DValue(id, SEL);

#pragma mark - Register
@implementation ObjCKeyValueStore(QuartzCoreAccessors)
+ (void)load {
    ObjCKeyValueStoreRegisterAccessor(
        (IMP)&GetCATransform3DValue,
        (IMP)&SetCATransform3DValue,
        @encode(CATransform3D)
    );
}
@end

void SetCATransform3DValue(id self, SEL _cmd, CATransform3D value) {
    NSString * propertyName = nil;
    const char * propertyType = NULL;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindSetter, &propertyName, &propertyType, NULL, @encode(CATransform3D), nil);

    NSValue * primitiveValue = [[NSValue alloc] initWithBytes:&value
                                                     objCType:propertyType];

    free((char *)propertyType);

    [self willChangeValueForKey:propertyName];

    [self setPrimitiveValue:primitiveValue forKey:propertyName];

    [self didChangeValueForKey:propertyName];
}

CATransform3D GetCATransform3DValue(id self, SEL _cmd) {
    NSString * propertyName = nil;

    ObjCKeyValueStoreAssertAccessor(self, _cmd, ObjCKeyValueStoreAccessorKindGetter, &propertyName, NULL, NULL, @encode(CATransform3D), nil);

    CATransform3D value = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    id primitiveValue = [self primitiveValueForKey:propertyName];

    [primitiveValue getValue:&value];

    return value;
}
