//
//  ObjCCodingBasePropertySynthesize.m
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import ObjectiveC;

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBasePropertySynthesize.h"

#pragma mark - Type
typedef struct _ObjCCodingBaseAccessor {
    const char * typeIdentifier;
    const size_t typeIdentifierLength;
    const IMP getter;
    const IMP setter;
} ObjCCodingBaseAccessor;

#pragma mark - Function Prototype
static BOOL _ObjCCodingBaseSynthesizeSetter(Class, SEL);
static BOOL _ObjCCodingBaseSynthesizeGetter(Class, SEL);

static void ObjCCodingBaseCacheSetter(Class, SEL, NSString *);
static void ObjCCodingBaseCacheGetter(Class, SEL, NSString *);

NSString * _ObjCCodingBasePropertyNameForGetter(Class, SEL);
NSString * _ObjCCodingBasePropertyNameForSetter(Class, SEL);

/// Returns true when their `typeIdentifier` is same.
static const ObjCCodingBaseAccessor * ObjCCodingBaseAccessorCreate(
    const char *,
    const IMP,
    const IMP
);

static void ObjCCodingBaseAccessorRelease(ObjCCodingBaseAccessor *);

static Boolean ObjCCodingBaseAccessorEqual(const void *, const void *);

static const IMP ObjCCodingBaseGetterImplForType(const char *);
static const IMP ObjCCodingBaseSetterImplForType(const char *);

#pragma mark - Variables
static CFArrayCallBacks ObjCCodingBaseAccessorArrayCallBacks = {
    0,
    NULL,
    NULL,
    NULL,
    &ObjCCodingBaseAccessorEqual
};

static CFMutableArrayRef kRegisteredAccessors = NULL;

static CFMutableDictionaryRef kPropertyNameForGetterForClass = NULL;
static CFMutableDictionaryRef kPropertyNameForSetterForClass = NULL;

#pragma mark - Function Implmentation
#pragma mark Synthesize
BOOL ObjCCodingBaseSynthesizeSetter(Class class, SEL selector) {
    while (class != [ObjCCodingBase class]) {
        if (_ObjCCodingBaseSynthesizeSetter(class, selector)) {
            return YES;
        }
        
        class = [class superclass];
    }
    
    return NO;
}

BOOL _ObjCCodingBaseSynthesizeSetter(Class class, SEL selector) {
    unsigned int propertyCount = 0;
    
    objc_property_t * propertyList =
    class_copyPropertyList(class, &propertyCount);
    
    unsigned int propertyIndex = 0;
    BOOL targeted = NO;
    BOOL synthesized = NO;
    
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
            size_t propertyNameLength = strlen(rawPropertyName);
            
            NSString * propertyName = nil;
            
            if (propertyNameLength > 1) {
                char firstLetter = *(rawPropertyName);
                propertyName
                = [NSString stringWithFormat:@"%@%@",
                   [NSString stringWithCString:&firstLetter
                                      encoding:NSUTF8StringEncoding]
                   .capitalizedString,
                   [NSString stringWithCString:(rawPropertyName + 1)
                                      encoding:NSUTF8StringEncoding]];
            } else {
                propertyName
                = [NSString stringWithCString:rawPropertyName
                                     encoding:NSUTF8StringEncoding];
            }
            
            NSString * propertySetter
            = [[@"set" stringByAppendingString:propertyName]
               stringByAppendingString:@":"];
            
            const char * rawPropertySetter
            = [propertySetter cStringUsingEncoding:NSUTF8StringEncoding];
            
            if (strcmp(rawPropertySetter, rawSelectorName) == 0) {
                targeted = YES;
            }
            
        }
        
        if (targeted) {
            ObjCCodingBaseCacheSetter(class, selector, propertyName);
            
            const char * propertyType
            = property_copyAttributeValue(property, "T");
            
            char setterTypesPrototype[256] = "v@:";
            
            const char * setterTypes
            = strcat(setterTypesPrototype, propertyType);
            
            const IMP setter = ObjCCodingBaseSetterImplForType(propertyType);
            
            if (setter != NULL) {
                if (class_addMethod(class, selector, setter, setterTypes)) {
                    synthesized = YES;
                }
            }
        }
        
        propertyIndex ++;
    }
    
    free(propertyList);
    
    return targeted && synthesized;
}

BOOL ObjCCodingBaseSynthesizeGetter(Class class, SEL selector) {
    while (class != [ObjCCodingBase class]) {
        if (_ObjCCodingBaseSynthesizeGetter(class, selector)) {
            return YES;
        }
        
        class = [class superclass];
    }
    
    return NO;
}

BOOL _ObjCCodingBaseSynthesizeGetter(Class class, SEL selector) {
    unsigned int propertyCount = 0;
    
    objc_property_t * propertyList =
    class_copyPropertyList(class, &propertyCount);
    
    unsigned int propertyIndex = 0;
    BOOL targeted = NO;
    BOOL synthesized = NO;
    
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
            ObjCCodingBaseCacheGetter(class, selector, propertyName);
            
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
            
            const IMP getter = ObjCCodingBaseGetterImplForType(propertyType);
            
            if (getter != NULL) {
                if (class_addMethod(class, selector, getter, getterTypes)) {
                    synthesized = YES;
                }
            }
        }
        
        propertyIndex ++;
    }
    
    free(propertyList);
    
    return targeted && synthesized;
}

#pragma mark Cache Property Name
void ObjCCodingBaseCacheSetter(
    Class class,
    SEL selector,
    NSString * propertyName
    )
{
    if (kPropertyNameForSetterForClass == NULL) {
        kPropertyNameForSetterForClass = CFDictionaryCreateMutable(
            kCFAllocatorDefault,
            0,
            NULL,
            &kCFTypeDictionaryValueCallBacks
        );
        NSCAssert(
            kPropertyNameForSetterForClass != NULL,
            @"Initialize kPropertyNameForSetterForClass failed"
        );
    }
    
    CFMutableDictionaryRef classDict = (CFMutableDictionaryRef)
    CFDictionaryGetValue(
        kPropertyNameForSetterForClass,
        (__bridge const void *)(class)
    );
    
    if (classDict == NULL) {
        classDict = CFDictionaryCreateMutable(
            kCFAllocatorDefault,
            0,
            NULL, 
            &kCFTypeDictionaryValueCallBacks
        );
        
        CFDictionarySetValue(
            kPropertyNameForSetterForClass,
            (__bridge const void *)(class),
            classDict
        );
    }
    
    if (!CFDictionaryContainsKey(classDict, selector)) {
        CFDictionarySetValue(
            classDict,
            selector,
            (__bridge const void *)(propertyName)
        );
    }
}

void ObjCCodingBaseCacheGetter(
    Class class,
    SEL selector,
    NSString * propertyName
    )
{
    
    if (kPropertyNameForGetterForClass == NULL) {
        kPropertyNameForGetterForClass = CFDictionaryCreateMutable(
            kCFAllocatorDefault,
            0, 
            NULL,
            &kCFTypeDictionaryValueCallBacks
        );
        NSCAssert(
            kPropertyNameForGetterForClass != NULL,
            @"Initialize kPropertyNameForGetterForClass failed"
        );
    }
    
    CFMutableDictionaryRef classDict = (CFMutableDictionaryRef)
    CFDictionaryGetValue(
        kPropertyNameForGetterForClass,
        (__bridge const void *)(class)
    );
    
    if (classDict == NULL) {
        classDict = CFDictionaryCreateMutable(
            kCFAllocatorDefault,
            0,
            NULL,
            &kCFTypeDictionaryValueCallBacks
        );
        
        CFDictionarySetValue(
            kPropertyNameForGetterForClass,
            (__bridge const void *)(class),
            classDict
        );
    }
    
    if (!CFDictionaryContainsKey(classDict, selector)) {
        CFDictionarySetValue(
            classDict,
            selector,
            (__bridge const void *)(propertyName)
        );
    }
}

#pragma mark Query Property Name
NSString * ObjCCodingBasePropertyNameForSetter(Class class, SEL selector) {
    while (class != [ObjCCodingBase class]) {
        NSString * propertyName
        = _ObjCCodingBasePropertyNameForSetter(class, selector);
        
        if (propertyName) {
            return propertyName;
        }
        
        class = [class superclass];
    }
    
    return nil;
}

NSString * _ObjCCodingBasePropertyNameForSetter(Class class, SEL selector) {
    CFMutableDictionaryRef classDict = (CFMutableDictionaryRef)
    CFDictionaryGetValue(
        kPropertyNameForSetterForClass,
        (__bridge const void *)(class)
    );
    
    if (classDict != NULL) {
        return (NSString *)CFDictionaryGetValue(classDict, selector);
    } else {
        return nil;
    }
}

NSString * ObjCCodingBasePropertyNameForGetter(Class class, SEL selector) {
    while (class != [ObjCCodingBase class]) {
        NSString * propertyName
        = _ObjCCodingBasePropertyNameForGetter(class, selector);
        
        if (propertyName) {
            return propertyName;
        }
        
        class = [class superclass];
    }
    
    return nil;
}

NSString * _ObjCCodingBasePropertyNameForGetter(Class class, SEL selector) {
    CFMutableDictionaryRef classDict = (CFMutableDictionaryRef)
    CFDictionaryGetValue(
        kPropertyNameForGetterForClass,
        (__bridge const void *)(class)
    );
    
    if (classDict != NULL) {
        return (NSString *)CFDictionaryGetValue(classDict, selector);
    } else {
        return nil;
    }
}

BOOL ObjCCodingBaseIsPropertyName(Class class, NSString * propertyName) {
    return (class_getProperty(class, propertyName.UTF8String) != NULL);
}

#pragma mark Register Accessors
const ObjCCodingBaseAccessor * ObjCCodingBaseAccessorCreate(
    const char * typeIdentifier,
    const IMP getter,
    const IMP setter
    )
{
    size_t typeIdentifierLength = strlen(typeIdentifier);
    
    ObjCCodingBaseAccessor * accessor = malloc(sizeof(ObjCCodingBaseAccessor));
    
    size_t typeIdentifierSize = sizeof(char) * typeIdentifierLength;
    
    char * copiedTypeIdentifier = malloc(typeIdentifierSize);
    
    memcpy(copiedTypeIdentifier, typeIdentifier, typeIdentifierSize);
    
    * accessor = (ObjCCodingBaseAccessor){
        copiedTypeIdentifier,
        typeIdentifierLength,
        getter,
        setter
    };
    
    return accessor;
}

void ObjCCodingBaseAccessorRelease(ObjCCodingBaseAccessor * accessor) {
    free((void *)accessor -> typeIdentifier);
    free(accessor);
}

Boolean ObjCCodingBaseAccessorEqual(
    const void * value1,
    const void * value2
    )
{
    ObjCCodingBaseAccessor * lhs = (ObjCCodingBaseAccessor *)value1;
    ObjCCodingBaseAccessor * rhs = (ObjCCodingBaseAccessor *)value2;
    
    return lhs -> typeIdentifierLength == rhs -> typeIdentifierLength &&
        strcmp(lhs -> typeIdentifier, rhs -> typeIdentifier) == 0;
}

BOOL ObjCCodingBaseRegisterAccessor(
    const char * typeIdentifier,
    const IMP getter,
    const IMP setter
    )
{
    const ObjCCodingBaseAccessor * accessor = ObjCCodingBaseAccessorCreate(
        typeIdentifier,
        getter,
        setter
    );
    
    if (kRegisteredAccessors == NULL) {
        kRegisteredAccessors = CFArrayCreateMutable(
            kCFAllocatorDefault,
            0,
            &ObjCCodingBaseAccessorArrayCallBacks
        );
        NSCAssert(
            kRegisteredAccessors != NULL,
            @"Initialize kRegisteredAccessors failed."
        );
    }
    
    CFIndex count = CFArrayGetCount(kRegisteredAccessors);
    
    if (CFArrayContainsValue(
            kRegisteredAccessors,
            CFRangeMake(0, count),
            accessor
            )
        )
    {
#if DEBUG
        NSLog(
            @"Duplicate ObjCCodingBase accessor registration for property of type %s",
            typeIdentifier
        );
#endif
        ObjCCodingBaseAccessorRelease((void *)accessor);
        return NO;
    } else {
        CFArrayAppendValue(kRegisteredAccessors, accessor);
        return YES;
    }
}

const IMP ObjCCodingBaseGetterImplForType(const char * type) {
    
    CFIndex count = CFArrayGetCount(kRegisteredAccessors);
    
    ObjCCodingBaseAccessor * targetedAccessor = NULL;
    
    for (CFIndex index = 0; index < count; index ++) {
        const void * value = CFArrayGetValueAtIndex(
            kRegisteredAccessors,
            index
        );
        
        const ObjCCodingBaseAccessor * accessor = value;
        
        if (strncmp(
                accessor -> typeIdentifier,
                type,
                accessor -> typeIdentifierLength
                ) == 0
            )
        {
            targetedAccessor = (ObjCCodingBaseAccessor *)accessor;
        }
        
        if (targetedAccessor != NULL) {
            break;
        }
    }
    
    if (targetedAccessor == NULL) {
        return NULL;
    } else {
        return targetedAccessor -> getter;
    }
}

const IMP ObjCCodingBaseSetterImplForType(const char * type) {
    
    CFIndex count = CFArrayGetCount(kRegisteredAccessors);
    
    ObjCCodingBaseAccessor * targetedAccessor = NULL;
    
    for (CFIndex index = 0; index < count; index ++) {
        const void * value = CFArrayGetValueAtIndex(
            kRegisteredAccessors,
            index
        );
        
        const ObjCCodingBaseAccessor * accessor = value;
        
        if (strncmp(
                accessor -> typeIdentifier,
                type,
                accessor -> typeIdentifierLength
                ) == 0
            )
        {
            targetedAccessor = (ObjCCodingBaseAccessor *)accessor;
        }
        
        if (targetedAccessor != NULL) {
            break;
        }
    }
    
    if (targetedAccessor == NULL) {
        return NULL;
    } else {
        return targetedAccessor -> setter;
    }
}
