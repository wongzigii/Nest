//
//  ObjCKeyValueStore+Internal.m
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

@import ObjectiveC;

#import <Nest/ObjCKeyValueStore.h>
#import "ObjCKeyValueStore+Internal.h"

#pragma mark - Type
typedef struct _ObjCKeyValueStoreAccessor {
    const char * typeIdentifier;
    const size_t typeIdentifierLength;
    const IMP getterImpl;
    const IMP setterImpl;
} ObjCKeyValueStoreAccessor;

#pragma mark - Function Prototype
#pragma mark Synthesize Property
static BOOL ObjCKeyValueStoreSynthesizeSetterForClass(Class, SEL);
static BOOL ObjCKeyValueStoreSynthesizeGetterForClass(Class, SEL);

static void ObjCKeyValueStoreCacheSetter(Class, SEL, NSString *);
static void ObjCKeyValueStoreCacheGetter(Class, SEL, NSString *);

static NSString * ObjCKeyValueStorePropertyNameForGetterForClassHierarchy(Class, SEL);
static NSString * ObjCKeyValueStorePropertyNameForSetterForClassHierarchy(Class, SEL);

static NSString * ObjCKeyValueStorePropertyNameForGetterForClass(Class, SEL);
static NSString * ObjCKeyValueStorePropertyNameForSetterForClass(Class, SEL);

static const IMP ObjCKeyValueStoreGetterImplForType(const char *);
static const IMP ObjCKeyValueStoreSetterImplForType(const char *);

#pragma mark Accessor Utilities
/// Returns true when their `typeIdentifier`s are same.
static const ObjCKeyValueStoreAccessor * ObjCKeyValueStoreAccessorCreate(
    const char * typeIdentifier,
    const IMP getterImpl,
    const IMP setterImpl
);

static void ObjCKeyValueStoreAccessorRelease(
    ObjCKeyValueStoreAccessor * accessor
);

static Boolean ObjCKeyValueStoreAccessorEqual(const void *, const void *);

#pragma mark Internal Utilities
static NSString * ObjCKeyValueStoreAccessorCapitalizedPropertyName(const char *);
static ObjCKeyValueStoreAccessor * ObjCKeyValueStoreAccessorForType(const char *);

#pragma mark - Variables
static CFArrayCallBacks ObjCKeyValueStoreAccessorArrayCallBacks = {
    0,
    NULL,
    NULL,
    NULL,
    &ObjCKeyValueStoreAccessorEqual
};

static CFMutableArrayRef kRegisteredAccessors = NULL;

static CFMutableDictionaryRef kPropertyNameForGetterForClass = NULL;
static CFMutableDictionaryRef kPropertyNameForSetterForClass = NULL;

#pragma mark - Function Implmentation
#pragma mark Synthesize
BOOL ObjCKeyValueStoreSynthesizeSetterForClassHierarchy(Class class, SEL selector) {
    while (class != [ObjCKeyValueStore class]) {
        if (ObjCKeyValueStoreSynthesizeSetterForClass(class, selector)) {
            return YES;
        }

        class = [class superclass];
    }

    return NO;
}

BOOL ObjCKeyValueStoreSynthesizeSetterForClass(Class class, SEL selector) {
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
            = ObjCKeyValueStoreAccessorCapitalizedPropertyName(
                [propertyName UTF8String]
            );

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
            ObjCKeyValueStoreCacheSetter(class, selector, propertyName);

            const char * propertyType
            = property_copyAttributeValue(property, "T");

            char setterTypesPrototype[256] = "v@:";

            const char * setterTypes
            = strcat(setterTypesPrototype, propertyType);

            const IMP setter = ObjCKeyValueStoreSetterImplForType(propertyType);

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

BOOL ObjCKeyValueStoreSynthesizeGetterForClassHierarchy(Class class, SEL selector) {
    while (class != [ObjCKeyValueStore class]) {
        if (ObjCKeyValueStoreSynthesizeGetterForClass(class, selector)) {
            return YES;
        }

        class = [class superclass];
    }

    return NO;
}

BOOL ObjCKeyValueStoreSynthesizeGetterForClass(Class class, SEL selector) {
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
            ObjCKeyValueStoreCacheGetter(class, selector, propertyName);

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

            const IMP getter = ObjCKeyValueStoreGetterImplForType(propertyType);

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
void ObjCKeyValueStoreCacheSetter(
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

void ObjCKeyValueStoreCacheGetter(
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
NSString * ObjCKeyValueStorePropertyNameForSetterForClassHierarchy(Class class, SEL selector) {
    while (class != [ObjCKeyValueStore class]) {
        NSString * propertyName
        = ObjCKeyValueStorePropertyNameForSetterForClass(class, selector);

        if (propertyName) {
            return propertyName;
        }

        class = [class superclass];
    }

    return nil;
}

NSString * ObjCKeyValueStorePropertyNameForSetterForClass(Class class, SEL selector) {
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

NSString * ObjCKeyValueStorePropertyNameForGetterForClassHierarchy(Class class, SEL selector) {
    while (class != [ObjCKeyValueStore class]) {
        NSString * propertyName
        = ObjCKeyValueStorePropertyNameForGetterForClass(class, selector);

        if (propertyName) {
            return propertyName;
        }

        class = [class superclass];
    }

    return nil;
}

NSString * ObjCKeyValueStorePropertyNameForGetterForClass(Class class, SEL selector) {
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

BOOL ObjCKeyValueStoreIsPropertyName(Class class, NSString * propertyName) {
    return (class_getProperty(class, propertyName.UTF8String) != NULL);
}

#pragma mark Register Accessors
const ObjCKeyValueStoreAccessor * ObjCKeyValueStoreAccessorCreate(
    const char * typeIdentifier,
    const IMP getter,
    const IMP setter
    )
{
    size_t typeIdentifierLength = strlen(typeIdentifier);

    ObjCKeyValueStoreAccessor * accessor
    = malloc(sizeof(ObjCKeyValueStoreAccessor));

    size_t typeIdentifierSize = sizeof(char) * typeIdentifierLength;

    char * copiedTypeIdentifier = malloc(typeIdentifierSize);

    memcpy(copiedTypeIdentifier, typeIdentifier, typeIdentifierSize);

    * accessor = (ObjCKeyValueStoreAccessor){
        copiedTypeIdentifier,
        typeIdentifierLength,
        getter,
        setter
    };

    return accessor;
}

void ObjCKeyValueStoreAccessorRelease(ObjCKeyValueStoreAccessor * accessor) {
    free((void *)accessor -> typeIdentifier);
    free(accessor);
}

Boolean ObjCKeyValueStoreAccessorEqual(
    const void * value1,
    const void * value2
    )
{
    ObjCKeyValueStoreAccessor * lhs = (ObjCKeyValueStoreAccessor *)value1;
    ObjCKeyValueStoreAccessor * rhs = (ObjCKeyValueStoreAccessor *)value2;

    return lhs -> typeIdentifierLength == rhs -> typeIdentifierLength &&
        strcmp(lhs -> typeIdentifier, rhs -> typeIdentifier) == 0;
}

BOOL ObjCKeyValueStoreRegisterAccessor(
    const IMP getter,
    const IMP setter,
    const char * typeIdentifier
    )
{
    const ObjCKeyValueStoreAccessor * accessor
    = ObjCKeyValueStoreAccessorCreate(
        typeIdentifier,
        getter,
        setter
    );

    if (kRegisteredAccessors == NULL) {
        kRegisteredAccessors = CFArrayCreateMutable(
            kCFAllocatorDefault,
            0,
            &ObjCKeyValueStoreAccessorArrayCallBacks
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
            @"Duplicate ObjCKeyValueStore accessor registration for property of type %s",
            typeIdentifier
        );
#endif
        ObjCKeyValueStoreAccessorRelease((void *)accessor);
        return NO;
    } else {
        CFArrayAppendValue(kRegisteredAccessors, accessor);
        return YES;
    }
}

const IMP ObjCKeyValueStoreGetterImplForType(const char * type) {
    ObjCKeyValueStoreAccessor * targetedAccessor
    = ObjCKeyValueStoreAccessorForType(type);

    if (targetedAccessor == NULL) {
        return NULL;
    } else {
        return targetedAccessor -> getterImpl;
    }
}

const IMP ObjCKeyValueStoreSetterImplForType(const char * type) {
    ObjCKeyValueStoreAccessor * targetedAccessor
    = ObjCKeyValueStoreAccessorForType(type);

    if (targetedAccessor == NULL) {
        return NULL;
    } else {
        return targetedAccessor -> setterImpl;
    }
}

void ObjCKeyValueStoreAssertAccessor(
    id self,
    SEL _cmd,
    ObjCKeyValueStoreAccessorKind kind,
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
    case ObjCKeyValueStoreAccessorKindGetter:
        propertyName
            = ObjCKeyValueStorePropertyNameForGetterForClassHierarchy([self class], _cmd);
        break;
    case ObjCKeyValueStoreAccessorKindSetter:
        propertyName
            = ObjCKeyValueStorePropertyNameForSetterForClassHierarchy([self class], _cmd);
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
        *r_propertyType = propertyTypeEncoding;
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

        // Create allowed type encoding string
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

            // Check type encoding viability
            BOOL isEachAllowedTypeEncodingViable
            = strncmp(
                propertyTypeEncoding,
                eachAllowedTypeEncoding,
                eachAllowedTypeEncodingLength
            ) == 0;

            if (isEachAllowedTypeEncodingViable) {
                // Do cleanup when type encoding is viable
                if (allowedTypeEncodings != NULL) {
                    free((void *)allowedTypeEncodings);
                    if (r_propertyType == NULL) {
                        free((char *)propertyTypeEncoding);
                    }
                }
                return;
            }

            // Concatenate allowed type encodings
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
            case ObjCKeyValueStoreAccessorKindGetter:
                accessorKindDescription = getterKindDescription;
                break;
            case ObjCKeyValueStoreAccessorKindSetter:
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

#pragma mark Internal Utilities
NSString * ObjCKeyValueStoreAccessorCapitalizedPropertyName(
    const char * rawPropertyName
    )
{
    NSString * propertyName = [NSString stringWithUTF8String:rawPropertyName];
    
    NSString * capitalizedPropertyName = nil;

    NSUInteger propertyNameLength = [propertyName length];
    
    if (propertyNameLength > 1) {
        NSRange propertyNameRange = NSMakeRange(0, propertyNameLength);
        
        NSMutableString * capitalizedBase = [[NSMutableString alloc] init];
        __block NSRange firstSubstringRange;
        [propertyName enumerateSubstringsInRange:propertyNameRange
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock:
         ^(NSString * _Nullable substring,
            NSRange substringRange,
            NSRange enclosingRange,
            BOOL * _Nonnull stop
           )
         {
             if (substringRange.location == 0) {
                 [capitalizedBase appendString: substring.capitalizedString];
                 firstSubstringRange = substringRange;
             } else {
                 * stop = YES;
             }
         }];
        
        NSUInteger firstSubstringEnd = NSMaxRange(firstSubstringRange);
        NSUInteger restSubstringLength
        = propertyNameLength - firstSubstringRange.length;
        NSRange restSubstringRange
        = NSMakeRange(firstSubstringEnd, restSubstringLength);
        NSString * restString
        = [propertyName substringWithRange:restSubstringRange];
        
        [capitalizedBase appendString:restString];
        
        capitalizedPropertyName = capitalizedBase;
    } else {
        capitalizedPropertyName
        = [NSString stringWithCString:rawPropertyName
                             encoding:NSUTF8StringEncoding]
        .capitalizedString;
    }

    return capitalizedPropertyName;
}

ObjCKeyValueStoreAccessor * ObjCKeyValueStoreAccessorForType(
    const char * typeEncoding
    )
{
    CFIndex count = CFArrayGetCount(kRegisteredAccessors);

    ObjCKeyValueStoreAccessor * targetedAccessor = NULL;

    for (CFIndex index = 0; index < count; index ++) {
        const void * value = CFArrayGetValueAtIndex(
            kRegisteredAccessors,
            index
        );

        const ObjCKeyValueStoreAccessor * accessor = value;

        if (strncmp(
                accessor -> typeIdentifier,
                typeEncoding,
                accessor -> typeIdentifierLength
            ) == 0
            )
        {
            targetedAccessor = (ObjCKeyValueStoreAccessor *)accessor;
        }

        if (targetedAccessor != NULL) {
            break;
        }
    }

    return targetedAccessor;
}
