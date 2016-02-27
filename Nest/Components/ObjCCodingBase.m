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

static NSString *  kObjCCodingBaseVersionKey
= @"com.WeZZard.Nest.ObjCCodingBase.version";

@interface ObjCCodingBase()
@property (nonatomic, readonly, strong) NSMutableDictionary * internalStorage;
@end

@implementation ObjCCodingBase
+ (NSInteger)version {
    return 0;
}

+ (BOOL)migrateValue:(id  _Nullable __autoreleasing *)value
              forKey:(NSString *__autoreleasing  _Nonnull *)key
                from:(NSInteger)fromVersion
                  to:(NSInteger)toVersion
{
    return NO;
}

+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(version))]) {
        return 0;
    }
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
        NSInteger classVersion = [[self class] version];
        
        NSInteger binaryVersion
        = [aDecoder decodeIntegerForKey:kObjCCodingBaseVersionKey];
        
        BOOL shouldMigrate = classVersion != binaryVersion;
        
        BOOL isWholeMigrationSucceeded = YES;
        
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
                
                if (shouldMigrate) {
                    BOOL isValueMigrationSucceeded
                    = [[self class] migrateValue:&value
                                          forKey:&propertyName
                                            from:binaryVersion
                                              to:classVersion];
                    
                    isWholeMigrationSucceeded
                    = isWholeMigrationSucceeded && isValueMigrationSucceeded;
                } else {
                    if (value == nil) {
                        id defaultValue
                        = [[self class] defaultValueForKey:propertyName];
                        
                        if (defaultValue != nil) {
                            value = defaultValue;
                        }
                    }
                }
                
                if (propertyName != nil) {
                    [self setValue:value forKey:propertyName];
                }
            }
            
            free(propertyList);
            
            inspectedClass = [inspectedClass superclass];
        }
        
        if (shouldMigrate && !isWholeMigrationSucceeded) {
            return nil;
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

