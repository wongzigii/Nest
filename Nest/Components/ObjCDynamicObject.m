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

static inline void ObjCDynamicObjectLoadInternalStorageIfNeeded(ObjCDynamicObject * self);
@end

@implementation ObjCDynamicObject
- (NSMutableDictionary<NSString *,id> *)internalStorage {
    ObjCDynamicObjectLoadInternalStorageIfNeeded(self);
    return _internalStorage;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)setPrimitiveValue:(nullable id)primitiveValue forKey:(NSString *)key {
    ObjCDynamicObjectLoadInternalStorageIfNeeded(self);
    _internalStorage[key] = primitiveValue;
}

- (nullable id)primitiveValueForKey:(NSString *)key {
    ObjCDynamicObjectLoadInternalStorageIfNeeded(self);
    return _internalStorage[key];
}

- (id)copyWithZone:(NSZone *)zone {
    ObjCDynamicObject * copied = [[[self class] allocWithZone:zone] init];
    copied -> _internalStorage = [_internalStorage mutableCopy];
    return copied;
}

static inline void ObjCDynamicObjectLoadInternalStorageIfNeeded(ObjCDynamicObject * self) {
    if (self -> _internalStorage == nil) {
        self -> _internalStorage = [[NSMutableDictionary alloc] init];
    }
}
@end



