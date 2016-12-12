//
//  ObjCKeyValueStore.m
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

#import "ObjCKeyValueStore.h"
#import "ObjCKeyValueStore+Internal.h"

@interface ObjCKeyValueStore()
@property (nonatomic, readonly, strong) NSMutableDictionary * internalStorage;
@end

@implementation ObjCKeyValueStore
- (instancetype)init {
    self = [super init];
    
    if (self) {
        _internalStorage = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)_setInternalStorage:(NSMutableDictionary *)internalStorage {
    _internalStorage = internalStorage;
}

- (id)primitiveValueForKey:(NSString *)key {
    return _internalStorage[key];
}

- (void)setPrimitiveValue:(id __nullable)value forKey:(NSString *)key {
    _internalStorage[key] = value;
}

- (id)valueForKey:(NSString *)key {
    if (ObjCKeyValueStoreIsPropertyName([self class], key)) {
        return [self primitiveValueForKey:key];
    } else {
        return [super valueForKey:key];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (ObjCKeyValueStoreIsPropertyName([self class], key)) {
        [self setPrimitiveValue:value forKey:key];
    } else {
        [super setValue:value forKey:key];
    }
}

+ (BOOL)resolveInstanceMethod:(SEL)selector {
    if (ObjCKeyValueStoreSynthesizeGetterForClassHierarchy(self, selector)) {
        return YES;
    } else if (ObjCKeyValueStoreSynthesizeSetterForClassHierarchy(self, selector)) {
        return YES;
    } else {
        return [super resolveInstanceMethod:selector];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    ObjCKeyValueStore * copied = [[[self class] allocWithZone:zone] init];
    [copied _setInternalStorage:[self.internalStorage mutableCopy]];
    return copied;
}

@end
