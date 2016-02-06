//
//  ObjCCodingBase.m
//  Nest
//
//  Created by Manfred on 2/5/16.
//
//

@import ObjectiveC;

#import "ObjCCodingBase.h"

typedef union _ObjCIntegerBasedValue {
    char asChar;
    int asInt;
    short asShort;
    long asLong;
    long long asLongLong;
    unsigned char asUnsignedChar;
    unsigned int asUnsignedInt;
    unsigned short asUnsignedShort;
    unsigned long asUnsignedLong;
    unsigned long long asUnsignedLongLong;
    BOOL asBOOL;
    void * asObject;
} ObjCIntegerBasedValue;

typedef union _ObjCFloatingPointValue {
    double asDouble;
    float asFloat;
} ObjCFloatingPointValue;

static void ObjCCodingBaseSetIntegerBasedValue(id, SEL, ObjCIntegerBasedValue);
static ObjCIntegerBasedValue ObjCCodingBaseGetIntegerBasedValue(id, SEL);

static void ObjCCodingBaseSetFloatingPointValue (
    id,
    SEL,
    ObjCFloatingPointValue
);

static ObjCFloatingPointValue ObjCCodingBaseGetFloatingPointValue(id, SEL);

static NSMutableDictionary * kPropertyNameForGetterForClass = nil;
static NSMutableDictionary * kPropertyNameForSetterForClass = nil;

@interface ObjCCodingBase()
@property (nonatomic, readonly, strong) NSMutableDictionary * internalStorage;
@end

@implementation ObjCCodingBase
+ (id)defaultValueForKey:(NSString *)key {
    return nil;
}

- (id)valueForUndefinedKey:(NSString *)key {
    if ([self isDynamicPropertyKey:key]) {
        return [_internalStorage objectForKey:key];
    } else {
        return [super valueForUndefinedKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([self isDynamicPropertyKey:key]) {
        [_internalStorage setObject:value forKey:key];
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
                    if (defaultValue == nil) {
                        return nil;
                    } else {
                        value = defaultValue;
                    }
                }
                
                [self setValue:value forUndefinedKey:propertyName];
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
    if ([self synthesizeDynamicPropertySetterWithSelector:selector]) {
        return YES;
    } else if ([self synthesizeDynamicPropertyGetterWithSelector:selector]) {
        return YES;
    } else {
        return [super resolveInstanceMethod:selector];
    }
}

+ (BOOL)synthesizeDynamicPropertySetterWithSelector:(SEL)selector {
    unsigned int propertyCount = 0;
    
    objc_property_t * propertyList =
    class_copyPropertyList([self class], &propertyCount);
    
    unsigned int propertyIndex = 0;
    BOOL targeted = NO;
    
    const char * rawSelectorName = sel_getName(selector);
    
    while (propertyIndex < propertyCount && !targeted) {
        
        objc_property_t property = propertyList[propertyIndex];
        
        const char * rawPropertyName = property_getName(property);
        
        NSString * propertyName
        = [NSString stringWithCString:rawPropertyName
                             encoding:NSUTF8StringEncoding];
        
        const char * rawSetterName = property_copyAttributeValue(property, "S");
        
        if (rawSetterName != NULL) {
            if (strcmp(rawSetterName, rawSelectorName) == 0) {
                targeted = YES;
            }
        } else {
            NSString * propertySetter
            = [[@"set" stringByAppendingString:propertyName.capitalizedString]
               stringByAppendingString:@":"];
            
            const char * rawPropertySetter
            = [propertySetter cStringUsingEncoding:NSUTF8StringEncoding];
            
            if (strcmp(rawPropertySetter, rawSelectorName) == 0) {
                targeted = YES;
            }
            
        }
        
        if (targeted) {
            [self cacheSetter:selector withPropertyName:propertyName];
            
            const char * propertyType
            = property_copyAttributeValue(property, "T");
            
            char setterTypesPrototype[256] = "v@:";
            
            const char * setterTypes
            = strcat(setterTypesPrototype, propertyType);
            
            
            if (propertyType[0] == 'd' || propertyType[0] == 'f') {
                class_addMethod(
                    [self class],
                    selector,
                    (IMP)&ObjCCodingBaseSetFloatingPointValue,
                    setterTypes
                );
            } else {
                class_addMethod(
                    [self class],
                    selector,
                    (IMP)&ObjCCodingBaseSetIntegerBasedValue,
                    setterTypes
                );
            }
        }
        
        propertyIndex ++;
    }
    
    free(propertyList);
    
    return targeted;
}

+ (BOOL)synthesizeDynamicPropertyGetterWithSelector:(SEL)selector {
    unsigned int propertyCount = 0;
    
    objc_property_t * propertyList =
    class_copyPropertyList([self class], &propertyCount);
    
    unsigned int propertyIndex = 0;
    BOOL targeted = NO;
    
    const char * rawSelectorName = sel_getName(selector);
    
    while (propertyIndex < propertyCount && !targeted) {
        
        objc_property_t property = propertyList[propertyIndex];
        
        const char * rawPropertyName = property_getName(property);
        
        NSString * propertyName
        = [NSString stringWithCString:rawPropertyName
                             encoding:NSUTF8StringEncoding];
        
        char * rawGetterName = property_copyAttributeValue(property, "G");
        
        if (rawGetterName != NULL) {
            if (strcmp(rawGetterName, rawSelectorName) == 0) {
                targeted = YES;
            }
        } else {
            if (strcmp(rawPropertyName, rawSelectorName) == 0) {
                targeted = YES;
            }
        }
        
        if (targeted) {
            [self cacheGetter:selector withPropertyName:propertyName];
            
            const char * propertyType
            = property_copyAttributeValue(property, "T");
            
            char getterTypes[256] = "@:";
            
            size_t prorotypeLength = 2; //strlen(propertyType);
            
            memmove(
                getterTypes + prorotypeLength,
                getterTypes,
                prorotypeLength + 1
            );
            
            for (size_t index = 0; index < prorotypeLength; ++index) {
                getterTypes[index] = propertyType[index];
            }
            
            if (propertyType[0] == 'd' || propertyType[0] == 'f') {
                class_addMethod(
                    [self class],
                    selector,
                    (IMP)&ObjCCodingBaseGetFloatingPointValue,
                    getterTypes
                );
            } else {
                class_addMethod(
                    [self class],
                    selector,
                    (IMP)&ObjCCodingBaseGetIntegerBasedValue,
                    getterTypes
                );
            }
        }
        
        propertyIndex ++;
    }
    
    free(propertyList);
    
    return targeted;
}

+ (void)cacheSetter:(SEL)selector withPropertyName:(NSString *)propertyName {
    NSString * className = NSStringFromClass(self);
    NSString * selectorName = NSStringFromSelector(selector);
    
    if (kPropertyNameForSetterForClass == nil) {
        kPropertyNameForSetterForClass = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary * classDict = kPropertyNameForSetterForClass[className];
    
    if (classDict == nil) {
        classDict = [[NSMutableDictionary alloc] init];
        kPropertyNameForSetterForClass[className] = classDict;
    }
    
    if (classDict[selectorName] == nil) {
        classDict[selectorName] = propertyName;
    }
}

+ (void)cacheGetter:(SEL)selector withPropertyName:(NSString *)propertyName {
    NSString * className = NSStringFromClass(self);
    NSString * selectorName = NSStringFromSelector(selector);
    
    if (kPropertyNameForGetterForClass == nil) {
        kPropertyNameForGetterForClass = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary * classDict = kPropertyNameForGetterForClass[className];
    
    if (classDict == nil) {
        classDict = [[NSMutableDictionary alloc] init];
        kPropertyNameForGetterForClass[className] = classDict;
    }
    
    if (classDict[selectorName] == nil) {
        classDict[selectorName] = propertyName;
    }
}

- (NSString *)propertyNameForSetter:(SEL)selector {
    NSString * className = NSStringFromClass([self class]);
    NSString * selectorName = NSStringFromSelector(selector);
    
    return kPropertyNameForSetterForClass[className][selectorName];
}

- (NSString *)propertyNameForGetter:(SEL)selector {
    NSString * className = NSStringFromClass([self class]);
    NSString * selectorName = NSStringFromSelector(selector);
    
    return kPropertyNameForGetterForClass[className][selectorName];
}

- (BOOL)isDynamicPropertyKey:(NSString *)key {
    return (class_getProperty([self class], key.UTF8String) != NULL);
}
@end

void ObjCCodingBaseSetIntegerBasedValue(
        id self,
        SEL _cmd,
        ObjCIntegerBasedValue value
    )
{
    NSString * propertyName = [self propertyNameForSetter:_cmd];
    
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
    
    if (propertyType[0] == '@') {
        [[self internalStorage] setObject:(__bridge id)(value.asObject)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'c') {
        [[self internalStorage] setObject:@(value.asChar)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'i') {
        [[self internalStorage] setObject:@(value.asInt)
                                   forKey:propertyName];
    } else if (propertyType[0] == 's') {
        [[self internalStorage] setObject:@(value.asShort)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'l') {
        [[self internalStorage] setObject:@(value.asLong)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'q') {
        [[self internalStorage] setObject:@(value.asLongLong)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'C') {
        [[self internalStorage] setObject:@(value.asUnsignedChar)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'I') {
        [[self internalStorage] setObject:@(value.asUnsignedInt)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'S') {
        [[self internalStorage] setObject:@(value.asUnsignedShort)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'L') {
        [[self internalStorage] setObject:@(value.asUnsignedLong)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'Q') {
        [[self internalStorage] setObject:@(value.asUnsignedLongLong)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'f') {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set floating pointer value with native value setter"];
    } else if (propertyType[0] == 'd') {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set floating pointer value with native value setter"];
    } else if (propertyType[0] == 'B') {
        [[self internalStorage] setObject:@(value.asBOOL)
                                   forKey:propertyName];
    } else {
        NSValue * wrappedValue
        = [NSValue valueWithBytes:&value objCType:propertyType];
        
        [[self internalStorage] setObject:wrappedValue forKey:propertyName];
    }
    
    [self didChangeValueForKey:propertyName];
}

ObjCIntegerBasedValue ObjCCodingBaseGetIntegerBasedValue(id self, SEL _cmd) {
    NSString * propertyName = [self propertyNameForGetter:_cmd];
    
    NSAssert(
        propertyName != nil,
        @"No property name for selector \"%@\".",
        NSStringFromSelector(_cmd)
    );
    
    id value = ([[self internalStorage] objectForKey:propertyName]);
    
    objc_property_t property = class_getProperty(
        [self class],
        [propertyName cStringUsingEncoding:NSUTF8StringEncoding]
    );
    
    const char * propertyType
    = property_copyAttributeValue(property, "T");
    
    if (propertyType[0] == '@') {
        return (ObjCIntegerBasedValue)(__bridge void *)(value);
    } else if (propertyType[0] == 'c') {
        return (ObjCIntegerBasedValue)[value charValue];
    } else if (propertyType[0] == 'i') {
        return (ObjCIntegerBasedValue)[value intValue];
    } else if (propertyType[0] == 's') {
        return (ObjCIntegerBasedValue)[value shortValue];
    } else if (propertyType[0] == 'l') {
        return (ObjCIntegerBasedValue)[value longValue];
    } else if (propertyType[0] == 'q') {
        return (ObjCIntegerBasedValue)[value longLongValue];
    } else if (propertyType[0] == 'C') {
        return (ObjCIntegerBasedValue)[value unsignedCharValue];
    } else if (propertyType[0] == 'I') {
        return (ObjCIntegerBasedValue)[value unsignedIntValue];
    } else if (propertyType[0] == 'S') {
        return (ObjCIntegerBasedValue)[value unsignedShortValue];
    } else if (propertyType[0] == 'L') {
        return (ObjCIntegerBasedValue)[value unsignedLongValue];
    } else if (propertyType[0] == 'Q') {
        return (ObjCIntegerBasedValue)[value unsignedLongLongValue];
    } else if (propertyType[0] == 'f') {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot get floating pointer value with native value getter"];
        return (ObjCIntegerBasedValue)-1;
    } else if (propertyType[0] == 'd') {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot get floating pointer value with native value getter"];
        return (ObjCIntegerBasedValue)-1;
    } else if (propertyType[0] == 'B') {
        return (ObjCIntegerBasedValue)[value boolValue];
    } else {
        size_t rawValue = 0;
        [value getValue:&rawValue];
        return (ObjCIntegerBasedValue)(void *)rawValue;
    }
}

void ObjCCodingBaseSetFloatingPointValue(
    id self,
    SEL _cmd,
    ObjCFloatingPointValue value
    )
{
    NSString * propertyName = [self propertyNameForSetter:_cmd];
    
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
    
    if (propertyType[0] == 'f') {
        [[self internalStorage] setObject:@(value.asFloat)
                                   forKey:propertyName];
    } else if (propertyType[0] == 'd') {
        [[self internalStorage] setObject:@(value.asDouble)
                                   forKey:propertyName];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set native value with floating pointer value setter"];
    }
    
    [self didChangeValueForKey:propertyName];
}

ObjCFloatingPointValue ObjCCodingBaseGetFloatingPointValue(id self, SEL _cmd) {
    NSString * propertyName = [self propertyNameForGetter:_cmd];
    
    NSAssert(
        propertyName != nil,
        @"No property name for selector \"%@\".",
        NSStringFromSelector(_cmd)
    );
    
    id value = ([[self internalStorage] objectForKey:propertyName]);
    
    objc_property_t property = class_getProperty(
        [self class],
        [propertyName cStringUsingEncoding:NSUTF8StringEncoding]
    );
    
    const char * propertyType
    = property_copyAttributeValue(property, "T");
    
    if (propertyType[0] == 'f') {
        return (ObjCFloatingPointValue)[value floatValue];
    } else if (propertyType[0] == 'd') {
        return (ObjCFloatingPointValue)[value doubleValue];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot get native value with floating pointer value getter"];
        return (ObjCFloatingPointValue)(-1.0);
    }
}

