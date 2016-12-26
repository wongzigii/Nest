//
//  ObjCDynamicObject.m
//  Nest
//
//  Created by Manfred on 26/12/2016.
//
//

#import "ObjCDynamicObject.h"

@interface ObjCDynamicObject()
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSString *, id> * internalStorage;
@end

@implementation ObjCDynamicObject
- (instancetype)init {
    self = [super init];
    if (self) {
        _internalStorage = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setPrimitiveValue:(nullable id)primitiveValue forKey:(NSString *)key {
    _internalStorage[key] = primitiveValue;
}

- (nullable id)primitiveValueForKey:(NSString *)key {
    return _internalStorage[key];
}

- (id)copyWithZone:(NSZone *)zone {
    ObjCDynamicObject * copied = [[[self class] allocWithZone:zone] init];
    copied -> _internalStorage = [_internalStorage mutableCopy];
    return copied;
}
@end
