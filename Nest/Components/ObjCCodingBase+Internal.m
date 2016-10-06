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
typedef struct _ObjCCodingBaseCodingCallBack {
    const char * typeIdentifier;
    const size_t typeIdentifierLength;
    const ObjCCodingBaseDecodeCallBack decodeCallBack;
    const ObjCCodingBaseEncodeCallBack encodeCallBack;
} ObjCCodingBaseCodingCallBack;

#pragma mark - Function Prototypes
/// Returns true when their `typeIdentifier` is same.
static const ObjCCodingBaseCodingCallBack * ObjCCodingBaseCodingCallBackCreate(
    const char *,
    const ObjCCodingBaseDecodeCallBack,
    const ObjCCodingBaseEncodeCallBack
);

static void ObjCCodingBaseCodingCallBackRelease(ObjCCodingBaseCodingCallBack *);

static Boolean ObjCCodingBaseCodingCallBackEqual(const void *, const void *);

#pragma mark Coding
static id ObjCCodingBaseDefaultDecodeCallBack (Class, NSCoder *, NSString *);
static void ObjCCodingBaseDefaultEncodeCallBack (Class, NSCoder *, NSString *, id);

#pragma mark Internal Utilities
static ObjCCodingBaseCodingCallBack * ObjCCodingBaseCodingCallBackForType(
    const char *
);

#pragma mark - Variables
static CFArrayCallBacks ObjCCodingBaseCodingCallBackArrayCallBacks = {
    0,
    NULL,
    NULL,
    NULL,
    &ObjCCodingBaseCodingCallBackEqual
};

static CFMutableArrayRef kRegisteredCodingCallBacks = NULL;

const ObjCCodingBaseDecodeCallBack kObjCCodingBaseDefaultDecodeCallBack
= &ObjCCodingBaseDefaultDecodeCallBack;

const ObjCCodingBaseEncodeCallBack kObjCCodingBaseDefaultEncodeCallBack
= &ObjCCodingBaseDefaultEncodeCallBack;

#pragma mark - Function Implmentation
#pragma mark Register Coding Call-Back
const ObjCCodingBaseCodingCallBack * ObjCCodingBaseCodingCallBackCreate(
    const char * typeIdentifier,
    const ObjCCodingBaseDecodeCallBack decodeCallBack,
    const ObjCCodingBaseEncodeCallBack encodeCallback
    )
{
    size_t typeIdentifierLength = strlen(typeIdentifier);

    ObjCCodingBaseCodingCallBack * codingCallBack
    = malloc(sizeof(ObjCCodingBaseCodingCallBack));

    size_t typeIdentifierSize = sizeof(char) * typeIdentifierLength;

    char * copiedTypeIdentifier = malloc(typeIdentifierSize);

    memcpy(copiedTypeIdentifier, typeIdentifier, typeIdentifierSize);

    * codingCallBack = (ObjCCodingBaseCodingCallBack){
        copiedTypeIdentifier,
        typeIdentifierLength,
        decodeCallBack,
        encodeCallback
    };

    return codingCallBack;
}

void ObjCCodingBaseCodingCallBackRelease(
    ObjCCodingBaseCodingCallBack * callBack
    )
{
    free((void *)callBack -> typeIdentifier);
    free(callBack);
}

Boolean ObjCCodingBaseCodingCallBackEqual(
    const void * value1,
    const void * value2
    )
{
    ObjCCodingBaseCodingCallBack * lhs
    = (ObjCCodingBaseCodingCallBack *)value1;
    ObjCCodingBaseCodingCallBack * rhs
    = (ObjCCodingBaseCodingCallBack *)value2;

    return lhs -> typeIdentifierLength == rhs -> typeIdentifierLength &&
        strcmp(lhs -> typeIdentifier, rhs -> typeIdentifier) == 0;
}

BOOL ObjCCodingBaseRegisterCodingCallBacks(
    const char * typeIdentifier,
    const ObjCCodingBaseDecodeCallBack decodeCallBack,
    const ObjCCodingBaseEncodeCallBack encodeCallBack
    )
{
    NSCAssert(decodeCallBack != NULL, @"decode call-back cannot be NULL");
    NSCAssert(encodeCallBack != NULL, @"encode call-back cannot be NULL");
    
    const ObjCCodingBaseCodingCallBack * codingCallBack
    = ObjCCodingBaseCodingCallBackCreate(
        typeIdentifier,
        decodeCallBack,
        encodeCallBack
    );

    if (kRegisteredCodingCallBacks == NULL) {
        kRegisteredCodingCallBacks = CFArrayCreateMutable(
            kCFAllocatorDefault,
            0,
            &ObjCCodingBaseCodingCallBackArrayCallBacks
        );
        NSCAssert(
            kRegisteredCodingCallBacks != NULL,
            @"Initialize kRegisteredCodingCallBacks failed."
        );
    }

    CFIndex count = CFArrayGetCount(kRegisteredCodingCallBacks);

    if (CFArrayContainsValue(
            kRegisteredCodingCallBacks,
            CFRangeMake(0, count),
            codingCallBack
            )
        )
    {
#if DEBUG
        NSLog(
            @"Duplicate ObjCCodingBase coding call back registration for property of type %s",
            typeIdentifier
        );
#endif
        ObjCCodingBaseCodingCallBackRelease((void *)codingCallBack);
        return NO;
    } else {
        CFArrayAppendValue(kRegisteredCodingCallBacks, codingCallBack);
        return YES;
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

    // A special conversion for `NSData` `decodedValue` instance
    if ([decodedValue isKindOfClass:[NSData class]]) {
        NSData * decodedData = decodedValue;

        objc_property_t property = class_getProperty(aClass, [key UTF8String]);

        const char * propertyTypeEncoding
        = property_copyAttributeValue(property, "T");

        static const char * identityEncoding = @encode(NSData);

        const size_t identifierEncodingLength = strlen(identityEncoding);

        // Only works for the properties which are not type of `NSData`
        if (strncmp(
                propertyTypeEncoding,
                identityEncoding,
                identifierEncodingLength
            ) != 0)
        {

            // Continue to filter natively supported `NSNumber`s out

            // I don't want count the omitted encodings manually, use a `NULL`
            // terminated array instead.
            static const char * omittedEncodings[] = {
                @encode(char),
                @encode(int),
                @encode(short),
#ifdef __LP64__
                "l",
#else
                @encode(long),
#endif
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

            int currentOmittedEncodingIndex = 0;
            const char * currentOmittedEncoding
            = omittedEncodings[currentOmittedEncodingIndex];

            while (currentOmittedEncoding) {
                size_t currentOmittedEncodingLength
                = strlen(currentOmittedEncoding);

                if (strncmp(
                        propertyTypeEncoding,
                        currentOmittedEncoding,
                        currentOmittedEncodingLength
                    ) == 0)
                {
                    free((char *)propertyTypeEncoding);
                    return decodedValue;
                }

                currentOmittedEncodingIndex += 1;
                currentOmittedEncoding
                = omittedEncodings[currentOmittedEncodingIndex];
            }
            
            NSUInteger size = 0;
            NSGetSizeAndAlignment(propertyTypeEncoding, &size, NULL);

            // Deal with `NSData` -> `NSValue` conversion
            void * rawData = malloc(decodedData.length);
            memset(rawData, 0, size);

            [decodedData getBytes:rawData length:decodedData.length];

            NSValue * value = [NSValue valueWithBytes:rawData
                                             objCType:propertyTypeEncoding];

            free(rawData);
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
        NSUInteger size = 0;
        const char * encoding = [value objCType];
        NSGetSizeAndAlignment(encoding, &size, NULL);

        void * rawData = malloc(size);
        memset(rawData, 0, size);
        [value getValue:rawData];

        NSData * data = [NSData dataWithBytes:rawData length:size];

        free(rawData);

        [coder encodeObject:data forKey:key];
    } else {
        [coder encodeObject:value forKey:key];
    }
}

ObjCCodingBaseEncodeCallBack ObjCCodingBaseEncodeCallBackForProperty(
    const Class aClass,
    const NSString * propertyName
    )
{
    objc_property_t property = class_getProperty(
        aClass,
        [propertyName UTF8String]
    );

    const char * propertyTypeEncoding
    = property_copyAttributeValue(property, "T");

    ObjCCodingBaseCodingCallBack * targetedCodingCallBack
    = ObjCCodingBaseCodingCallBackForType(propertyTypeEncoding);

    free((char *)propertyTypeEncoding);

    if (targetedCodingCallBack == NULL) {
        return kObjCCodingBaseDefaultEncodeCallBack;
    } else {
        return targetedCodingCallBack -> encodeCallBack;
    }
}

ObjCCodingBaseDecodeCallBack ObjCCodingBaseDecodeCallBackForProperty(
    const Class aClass,
    const NSString * propertyName
    )
{
    objc_property_t property = class_getProperty(
        aClass,
        [propertyName UTF8String]
    );

    const char * propertyTypeEncoding
    = property_copyAttributeValue(property, "T");

    ObjCCodingBaseCodingCallBack * targetedCodingCallBack
    = ObjCCodingBaseCodingCallBackForType(propertyTypeEncoding);

    free((char *)propertyTypeEncoding);

    if (targetedCodingCallBack == NULL) {
        return kObjCCodingBaseDefaultDecodeCallBack;
    } else {
        return targetedCodingCallBack -> decodeCallBack;
    }
}


#pragma mark Internal Utilities
ObjCCodingBaseCodingCallBack * ObjCCodingBaseCodingCallBackForType(
    const char * typeEncoding
    )
{
    CFIndex count = CFArrayGetCount(kRegisteredCodingCallBacks);

    ObjCCodingBaseCodingCallBack * targetedCodingCallBack = NULL;

    for (CFIndex index = 0; index < count; index ++) {
        const void * value = CFArrayGetValueAtIndex(
            kRegisteredCodingCallBacks,
            index
        );

        const ObjCCodingBaseCodingCallBack * codingCallBack = value;

        if (strncmp(
                codingCallBack -> typeIdentifier,
                typeEncoding,
                codingCallBack -> typeIdentifierLength
            ) == 0
            )
        {
            targetedCodingCallBack
            = (ObjCCodingBaseCodingCallBack *)codingCallBack;
        }

        if (targetedCodingCallBack != NULL) {
            break;
        }
    }

    return targetedCodingCallBack;
}
