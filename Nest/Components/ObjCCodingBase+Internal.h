//
//  ObjCCodingBase+Internal.h
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import Foundation;

typedef id (*ObjCCodingBaseDecodeCallBack) (Class, NSCoder *, NSString *);

typedef void (*ObjCCodingBaseEncodeCallBack) (Class, NSCoder *, NSString *, id);

/** The default implementation of decode call-back.
 
 -Dicussion: The default decode call-back took Foundation's mechanism(NSCoder's 
 special taking for `NSNumber`) into consideration. It decodes value with
 `NSCoder`'s `-decodeObjectForKey:`. But for those `NSValue` wrapped, and non-
 `NSNumber` values, the call-back would convert them from `NSData` at first.
 */
FOUNDATION_EXTERN const ObjCCodingBaseDecodeCallBack
kObjCCodingBaseDefaultDecodeCallBack;

/** The default implementation of encode call-back.
 
 -Dicussion: The default encode call-back took Foundation's mechanism(NSCoder's 
 special taking for `NSNumber`) into consideration. Encodes values with 
 `NSCoder`'s `-encodeObject:forKey:`. But for those `NSValue` wrapped, and non-
 `NSNumber` values, the call-back would convert them into `NSData` at first.
 */
FOUNDATION_EXTERN const ObjCCodingBaseEncodeCallBack
kObjCCodingBaseDefaultEncodeCallBack;

/** Registers an accessor's getter and setter with given a type identifier(
 A part of or an Objective-C type encoding.) 
 Wraps `ObjCCodingBaseRegisterAccessorWithCodingCallBacks` with default coding
 call-backs.
 */
FOUNDATION_EXTERN BOOL ObjCCodingBaseRegisterAccessor(
    const IMP, // getter implementation
    const IMP, // setter implmentation
    const char * // type identifier
);

/** Registers an accessor's getter and setter with given a type identifier(
 A part of or an Objective-C type encoding) and decode, encode call-backs.
 */
FOUNDATION_EXTERN BOOL ObjCCodingBaseRegisterAccessorWithCodingCallBacks(
    const IMP, // getter implementation
    const IMP, // setter implmentation
    const char *, // type identifier
    const ObjCCodingBaseDecodeCallBack, // decode call-back
    const ObjCCodingBaseEncodeCallBack // encode call-back
);

FOUNDATION_EXTERN BOOL ObjCCodingBaseIsPropertyName(Class, NSString *);

FOUNDATION_EXTERN BOOL ObjCCodingBaseSynthesizeSetter(Class, SEL);
FOUNDATION_EXTERN BOOL ObjCCodingBaseSynthesizeGetter(Class, SEL);

FOUNDATION_EXPORT ObjCCodingBaseEncodeCallBack
ObjCCodingBaseEncodeCallBackForProperty(Class, NSString *);

FOUNDATION_EXPORT ObjCCodingBaseDecodeCallBack
ObjCCodingBaseDecodeCallBackForProperty(Class, NSString *);

typedef NS_ENUM(NSInteger) {
    ObjCCodingBaseAccessorKindGetter,
    ObjCCodingBaseAccessorKindSetter
} ObjCCodingBaseAccessorKind;

/** Asserts the accessor and returning the property name and type.

 @param     self    The instance owns the accessor

 @param     _cmd    The accessor's selector.

 @param     kind    The accessor's kind(getter/setter).

 @param     r_propertyName      Accessor's relative property name. Cannot be
    nil.

 @param     r_propertyType      Accessor's relative property type. Could be nil.

 @param     description     The accessor's description. Use nil value to make
    the function to deduce the description from allowed type encodings.

 @param     firstAllowedTypeEncodings, ...      Allowed type encodings for the
    accessor implementation. At leat 1 allowed type encoding is required.

 */
FOUNDATION_EXTERN void ObjCCodingBaseAssertAccessor(
    id                  self,
    SEL                 _cmd,
    ObjCCodingBaseAccessorKind        kind,
    NSString * *        r_propertyName,
    const char * *      r_propertyType,
    const char *        description,
    const char *        firstAllowedTypeEncoding,
    ...
);
