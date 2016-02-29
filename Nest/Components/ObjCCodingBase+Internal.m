//
//  ObjCCodingBase+Internal.m
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import ObjectiveC;

#import <Nest/ObjCCodingBase.h>
#import "ObjCCodingBase+Internal.h"

#pragma mark - Type
typedef struct _ObjCCodingBaseAccessor {
    const char * typeIdentifier;
    const size_t typeIdentifierLength;
    const IMP getter;
    const IMP setter;
    const ObjCCodingBaseDecodeCallBack decodeCallBack;
    const ObjCCodingBaseEncodeCallBack encodeCallBack;
} ObjCCodingBaseAccessor;

#pragma mark - Function Prototype
#pragma mark Synthesize Property
static BOOL _ObjCCodingBaseSynthesizeSetter(Class, SEL);
static BOOL _ObjCCodingBaseSynthesizeGetter(Class, SEL);

static void ObjCCodingBaseCacheSetter(Class, SEL, NSString *);
static void ObjCCodingBaseCacheGetter(Class, SEL, NSString *);

NSString * ObjCCodingBasePropertyNameForGetter(Class, SEL);
NSString * ObjCCodingBasePropertyNameForSetter(Class, SEL);

NSString * _ObjCCodingBasePropertyNameForGetter(Class, SEL);
NSString * _ObjCCodingBasePropertyNameForSetter(Class, SEL);

static const IMP ObjCCodingBaseGetterImplForType(const char *);
static const IMP ObjCCodingBaseSetterImplForType(const char *);

#pragma mark Accessor Utilities
/// Returns true when their `typeIdentifier` is same.
static const ObjCCodingBaseAccessor * ObjCCodingBaseAccessorCreate(
    const char *,
    const IMP,
    const IMP,
    const ObjCCodingBaseDecodeCallBack,
    const ObjCCodingBaseEncodeCallBack
);

static void ObjCCodingBaseAccessorRelease(ObjCCodingBaseAccessor *);

static Boolean ObjCCodingBaseAccessorEqual(const void *, const void *);

#pragma mark Coding
id ObjCCodingBaseDefaultDecodeCallBack (Class, NSCoder *, NSString *);
void ObjCCodingBaseDefaultEncodeCallBack (Class, NSCoder *, NSString *, id);

#pragma mark Internal Utilities
NSString * ObjCCodingBaseCapitalizedPropertyName(const char *);
ObjCCodingBaseAccessor * ObjCCodingBaseAccessorForType(const char *);

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

const ObjCCodingBaseDecodeCallBack kObjCCodingBaseDefaultDecodeCallBack
= &ObjCCodingBaseDefaultDecodeCallBack;

const ObjCCodingBaseEncodeCallBack kObjCCodingBaseDefaultEncodeCallBack
= &ObjCCodingBaseDefaultEncodeCallBack;

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
            NSString * capitalizedPropertyName
            = ObjCCodingBaseCapitalizedPropertyName([propertyName UTF8String]);

            NSString * propertySetter
            = [[@"set" stringByAppendingString:capitalizedPropertyName]
               stringByAppendingString:@":"];

            const char * rawPropertySetter
            = [propertySetter UTF8String];

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
    const IMP setter,
    const ObjCCodingBaseDecodeCallBack decodeCallBack,
    const ObjCCodingBaseEncodeCallBack encodeCallback
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
        setter,
        decodeCallBack,
        encodeCallback
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
    const IMP getter,
    const IMP setter,
    const char * typeIdentifier
    )
{
    return ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
        getter,
        setter,
        typeIdentifier,
        NULL,
        NULL
    );
}

BOOL ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
    const IMP getter,
    const IMP setter,
    const char * typeIdentifier,
    const ObjCCodingBaseDecodeCallBack decodeCallBack,
    const ObjCCodingBaseEncodeCallBack encodeCallBack
    )
{
    ObjCCodingBaseDecodeCallBack guaranteedDecodeCallBack = NULL;
    ObjCCodingBaseEncodeCallBack guaranteedEncodeCallBack = NULL;

    if (decodeCallBack == NULL) {
        guaranteedDecodeCallBack = &ObjCCodingBaseDefaultDecodeCallBack;
    } else {
        guaranteedDecodeCallBack = decodeCallBack;
    }

    if (encodeCallBack == NULL) {
        guaranteedEncodeCallBack = &ObjCCodingBaseDefaultEncodeCallBack;
    } else {
        guaranteedEncodeCallBack = encodeCallBack;
    }

    const ObjCCodingBaseAccessor * accessor = ObjCCodingBaseAccessorCreate(
        typeIdentifier,
        getter,
        setter,
        guaranteedDecodeCallBack,
        guaranteedEncodeCallBack
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
    ObjCCodingBaseAccessor * targetedAccessor
    = ObjCCodingBaseAccessorForType(type);

    if (targetedAccessor == NULL) {
        return NULL;
    } else {
        return targetedAccessor -> getter;
    }
}

const IMP ObjCCodingBaseSetterImplForType(const char * type) {
    ObjCCodingBaseAccessor * targetedAccessor
    = ObjCCodingBaseAccessorForType(type);

    if (targetedAccessor == NULL) {
        return NULL;
    } else {
        return targetedAccessor -> setter;
    }
}

void ObjCCodingBaseAssertAccessor(
    id self,
    SEL _cmd,
    ObjCCodingBaseAccessorKind kind,
    NSString * * r_propertyName,
    const char * * r_propertyType,
    const char * description,
    const char * firstAllowedTypeEncoding,
    ...
    )
{
    // Get property name
    NSString * propertyName = NULL;

    switch (kind) {
    case ObjCCodingBaseAccessorKindGetter:
        propertyName = ObjCCodingBasePropertyNameForGetter([self class], _cmd);
        break;
    case ObjCCodingBaseAccessorKindSetter:
        propertyName = ObjCCodingBasePropertyNameForSetter([self class], _cmd);
        break;
    }

    NSCAssert(
        propertyName != nil,
        @"No property for selector \"%@\" on %@.",
        NSStringFromSelector(_cmd),
        self
    );

    *r_propertyName = propertyName;

    // Get property type encoding
    objc_property_t property = class_getProperty(
        [self class],
        [propertyName UTF8String]
    );

    const char * propertyTypeEncoding
    = property_copyAttributeValue(property, "T");

    if (r_propertyType != NULL) {
        * r_propertyType = propertyTypeEncoding;
    }

    // Iterate allowed type encodings
    va_list args;

    if (firstAllowedTypeEncoding) {
        // Calculate allowed type encodings
        char * allowedTypeEncodings = NULL;
        size_t allocatedAllowedTypeEncodingsSize = 0;

        // Check the first allowed type encoding
        size_t firstAllowedTypeEncodingLength
        = strlen(firstAllowedTypeEncoding);

        BOOL isFirstAllowedTypeEncodingViable
        = strncmp(
            propertyTypeEncoding,
            firstAllowedTypeEncoding,
            firstAllowedTypeEncodingLength
        ) == 0;

        if (isFirstAllowedTypeEncodingViable) {
            if (r_propertyType == NULL) {
                free((char *)propertyTypeEncoding);
            }
            return;
        }

        // Concatenate accessor description
        size_t firstAllowedTypeEncodingSize
        = sizeof(char) * firstAllowedTypeEncodingLength;

        allowedTypeEncodings = malloc(firstAllowedTypeEncodingSize);

        allocatedAllowedTypeEncodingsSize = firstAllowedTypeEncodingSize;

        memcpy(
            allowedTypeEncodings,
            firstAllowedTypeEncoding,
            firstAllowedTypeEncodingSize
        );

        // Check each allowed type encoding
        va_start(args, firstAllowedTypeEncoding);
        const char * eachAllowedTypeEncoding = NULL;
        while ((eachAllowedTypeEncoding = va_arg(args, const char *))) {

            size_t eachAllowedTypeEncodingLength
            = strlen(eachAllowedTypeEncoding);

            BOOL isEachAllowedTypeEncodingViable
            = strncmp(
                propertyTypeEncoding,
                eachAllowedTypeEncoding,
                eachAllowedTypeEncodingLength
            ) == 0;

            if (isEachAllowedTypeEncodingViable) {
                if (allowedTypeEncodings != NULL) {
                    free((void *)allowedTypeEncodings);
                    if (r_propertyType == NULL) {
                        free((char *)propertyTypeEncoding);
                    }
                }
                return;
            }

            // Concatenate accessor description
            size_t eachAllowedTypeEncodingSize
            = sizeof(char) * eachAllowedTypeEncodingLength;

            static const char * separator = " ,";
            size_t separatorLength = strlen(separator);
            size_t separatorSize = separatorLength * sizeof(char);

            allocatedAllowedTypeEncodingsSize
            += eachAllowedTypeEncodingSize;

            allowedTypeEncodings
            = realloc(
                allowedTypeEncodings,
                allocatedAllowedTypeEncodingsSize
            );

            memmove(allowedTypeEncodings, separator, separatorSize);
            memmove(
                allowedTypeEncodings,
                eachAllowedTypeEncoding,
                eachAllowedTypeEncodingSize
            );
        }
        va_end(args);

        // Calculate accessor kind description
        static const char * getterKindDescription = "Getter";
        static const char * setterKindDescription = "Setter";

        const char * accessorKindDescription = NULL;

        switch (kind) {
            case ObjCCodingBaseAccessorKindGetter:
                accessorKindDescription = getterKindDescription;
                break;
            case ObjCCodingBaseAccessorKindSetter:
                accessorKindDescription = setterKindDescription;
                break;
        }

        // Decude accessor description if needed
        const char * actualAccessorDescription = NULL;
        if (description == NULL) {
            actualAccessorDescription = allowedTypeEncodings;
        } else {
            actualAccessorDescription = description;
        }

        [NSException raise:NSInternalInconsistencyException
                    format:@"%s of %s cannot handle property of type %s, which only allows type of %s",
         accessorKindDescription,
         actualAccessorDescription,
         propertyTypeEncoding,
         allowedTypeEncodings];
    } else {
        [NSException raise:NSInvalidArgumentException
                    format:@"At least 1 allowed type encoding is required."];
    }

    if (r_propertyType == NULL) {
        free((char *)propertyTypeEncoding);
    }
}

#pragma mark Coding
id ObjCCodingBaseDefaultDecodeCallBack (
    Class aClass,
    NSCoder * coder,
    NSString * key
    )
{
    id decodedValue = [coder decodeObjectForKey:key];
    
    if ([decodedValue isKindOfClass:[NSData class]]) {
        NSData * decodedData = decodedValue;
        
        objc_property_t property = class_getProperty(
            aClass,
            [key UTF8String]
        );
        
        const char * propertyTypeEncoding
        = property_copyAttributeValue(property, "T");
        
        static const char * identifierEncoding = @encode(NSData);
        
        static const char * ommittedEncodings[] = {
            @encode(char),
            @encode(int), 
            @encode(short),
            @encode(long),
            @encode(long long),
            @encode(unsigned char), 
            @encode(unsigned int),
            @encode(unsigned short),
            @encode(unsigned long),
            @encode(unsigned long long),
            @encode(BOOL),
            @encode(double),
            @encode(float),
            NULL
        };
        
        int checkingOmmittedIndex = 0;
        const char * checkingOmmittedEncoding
        = ommittedEncodings[checkingOmmittedIndex];
        
        while (checkingOmmittedEncoding) {
            size_t checkingOmmittedEncodingLength
            = strlen(checkingOmmittedEncoding);
            
            if (strncmp(
                    propertyTypeEncoding,
                    checkingOmmittedEncoding,
                    checkingOmmittedEncodingLength
                ) != 0)
            {
                free((char *)propertyTypeEncoding);
                return decodedValue;
            }
            
            checkingOmmittedIndex += 1;
            checkingOmmittedEncoding = ommittedEncodings[checkingOmmittedIndex];
        }
        
        const size_t identifierEncodingLength = strlen(identifierEncoding);
        
        if (strncmp(
                propertyTypeEncoding,
                identifierEncoding, 
                identifierEncodingLength
            ) != 0)
        {
            void * data = malloc(decodedData.length);
            
            [decodedData getBytes:data length:decodedData.length];
            
            NSValue * value = [NSValue valueWithBytes:data
                                             objCType:propertyTypeEncoding];
            
            free(data);
            free((char *)propertyTypeEncoding);
            
            return value;
        }
        
        free((char *)propertyTypeEncoding);
    }
    
    return decodedValue;
}

void ObjCCodingBaseDefaultEncodeCallBack (
    Class aClass,
    NSCoder * coder,
    NSString * key,
    id value
    )
{
    if ([value isKindOfClass:[NSValue class]]
        && ![value isKindOfClass:[NSNumber class]])
    {
        NSUInteger size;
        const char * encoding = [value objCType];
        NSGetSizeAndAlignment(encoding, &size, NULL);
        
        void * ptr = malloc(size);
        [value getValue:ptr];
        
        NSData * data = [NSData dataWithBytes:ptr length:size];
        
        free(ptr);
        
        [coder encodeObject:data forKey:key];
    } else {
        [coder encodeObject:value forKey:key];
    }
}

ObjCCodingBaseEncodeCallBack ObjCCodingBaseEncodeCallBackForProperty(
    Class aClass,
    NSString * propertyName
    )
{
    objc_property_t property = class_getProperty(
        aClass,
        [propertyName UTF8String]
    );

    const char * propertyTypeEncoding
    = property_copyAttributeValue(property, "T");

    ObjCCodingBaseAccessor * targetedAccessor
    = ObjCCodingBaseAccessorForType(propertyTypeEncoding);

    free((char *)propertyTypeEncoding);

    if (targetedAccessor == NULL) {
        return NULL;
    } else {
        return targetedAccessor -> encodeCallBack;
    }
}

ObjCCodingBaseDecodeCallBack ObjCCodingBaseDecodeCallBackForProperty(
    Class aClass,
    NSString * propertyName
    )
{
    objc_property_t property = class_getProperty(
        aClass,
        [propertyName UTF8String]
    );

    const char * propertyTypeEncoding
    = property_copyAttributeValue(property, "T");

    ObjCCodingBaseAccessor * targetedAccessor
    = ObjCCodingBaseAccessorForType(propertyTypeEncoding);

    free((char *)propertyTypeEncoding);

    if (targetedAccessor == NULL) {
        return NULL;
    } else {
        return targetedAccessor -> decodeCallBack;
    }
}


#pragma mark Internal Utilities
NSString * ObjCCodingBaseCapitalizedPropertyName(const char * rawPropertyName) {
    size_t propertyNameLength = strlen(rawPropertyName);

    NSString * capitalizedPropertyName = nil;

    if (propertyNameLength > 1) {
        char firstLetter = *(rawPropertyName);
        capitalizedPropertyName
        = [NSString stringWithFormat:@"%@%@",
           [NSString stringWithCString:&firstLetter
                              encoding:NSUTF8StringEncoding]
           .capitalizedString,
           [NSString stringWithCString:(rawPropertyName + 1)
                              encoding:NSUTF8StringEncoding]];
    } else {
        capitalizedPropertyName
        = [NSString stringWithCString:rawPropertyName
                             encoding:NSUTF8StringEncoding]
        .capitalizedString;
    }

    return capitalizedPropertyName;
}

ObjCCodingBaseAccessor * ObjCCodingBaseAccessorForType(
    const char * typeEncoding
    )
{
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
                typeEncoding,
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

    return targetedAccessor;
}
