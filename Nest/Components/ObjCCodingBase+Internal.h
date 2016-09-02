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
 special taking for `NSNumber`) into consideration. It decodes values with
 `NSCoder`'s `-decodeObjectForKey:`. But for those `NSValue` wrapped, and non-
 `NSNumber` values, the call-back would convert them from `NSData` at first.
 */
FOUNDATION_EXTERN const ObjCCodingBaseDecodeCallBack
kObjCCodingBaseDefaultDecodeCallBack;

/** The default implementation of encode call-back.

 -Dicussion: The default encode call-back took Foundation's mechanism(NSCoder's
 special taking for `NSNumber`) into consideration. It encodes values with
 `NSCoder`'s `-encodeObject:forKey:`. But for those `NSValue` wrapped, and non-
 `NSNumber` values, the call-back would convert them into `NSData` at first.
 */
FOUNDATION_EXTERN const ObjCCodingBaseEncodeCallBack
kObjCCodingBaseDefaultEncodeCallBack;

/** Registers an accessor's getter and setter with a given type identifier(
 A part of or an Objective-C type encoding). Wraps 
 `ObjCCodingBaseRegisterAccessorWithCodingCallBacks` with default coding
 call-backs.
 */
FOUNDATION_EXTERN BOOL ObjCCodingBaseRegisterCodingCallBacks(
    const char * typeIdentifier,// type identifier
    const ObjCCodingBaseDecodeCallBack decodeCallBack, // decode call-back
    const ObjCCodingBaseEncodeCallBack encodeCallBack // encode call-back
);

FOUNDATION_EXPORT ObjCCodingBaseEncodeCallBack
ObjCCodingBaseEncodeCallBackForProperty(Class, NSString *);

FOUNDATION_EXPORT ObjCCodingBaseDecodeCallBack
ObjCCodingBaseDecodeCallBackForProperty(Class, NSString *);
