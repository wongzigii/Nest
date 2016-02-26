//
//  ObjCCodingBase.m
//  Nest
//
//  Created by Manfred on 2/5/16.
//
//

@import ObjectiveC;

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBasePropertySynthesize.h"

@interface ObjCCodingBase()
@property (nonatomic, readonly, strong) NSMutableDictionary * internalStorage;
@end

@implementation ObjCCodingBase
+ (id)defaultValueForKey:(NSString *)key {
    return nil;
}

- (id)primitiveValueForKey:(NSString *)key {
    return _internalStorage[key];
}

- (void)setPrimitiveValue:(id __nullable)value forKey:(NSString *)key {
    _internalStorage[key] = value;
}

- (id)valueForUndefinedKey:(NSString *)key {
    if (ObjCCodingBaseIsPropertyName([self class], key)) {
        return [self primitiveValueForKey:key];
    } else {
        return [super valueForUndefinedKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if (ObjCCodingBaseIsPropertyName([self class], key)) {
        [self setPrimitiveValue:value forKey:key];
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _internalStorage = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _internalStorage = [[NSMutableDictionary alloc] init];
        
        Class inspectedClass = [self class];
        
        Class searchingTerminateClass = [ObjCCodingBase class];
        
        while (inspectedClass != searchingTerminateClass) {
            
            unsigned int propertyCount = 0;
            
            objc_property_t * propertyList
            = class_copyPropertyList(inspectedClass, &propertyCount);
            
            for (unsigned int index = 0; index < propertyCount; index ++) {
                objc_property_t property = propertyList[index];
                
                const char * rawPropertyName = property_getName(property);
                
                NSString * propertyName
                = [NSString stringWithCString:rawPropertyName
                                     encoding:NSUTF8StringEncoding];
                
                id value = [aDecoder decodeObjectForKey:propertyName];
                
                if (value == nil) {
                    id defaultValue
                    = [[self class] defaultValueForKey:propertyName];
                    
                    if (defaultValue != nil) {
                        value = defaultValue;
                    }
                }
                
                [self setValue:value forKey:propertyName];
            }
            
            inspectedClass = [inspectedClass superclass];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    for (NSString * key in _internalStorage) {
        id value = [self valueForKey:key];
        [coder encodeObject:value forKey:key];
    }
}

+ (BOOL)resolveInstanceMethod:(SEL)selector {
    if (ObjCCodingBaseSynthesizeGetter(self, selector)) {
        return YES;
    } else if (ObjCCodingBaseSynthesizeSetter(self, selector)) {
        return YES;
    } else {
        return [super resolveInstanceMethod:selector];
    }
}

@end

