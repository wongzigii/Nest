//
//  ObjCDynamicCoding.h
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import Foundation;

typedef id (*ObjCDynamicCodingDecodeCallBack) (const Class, const NSCoder *, const NSString *);

typedef void (*ObjCDynamicCodingEncodeCallBack) (const Class, const NSCoder *, const NSString *, const id);

/** The default implementation of decode call-back.

 -Dicussion: The default decode call-back took Foundation's mechanism(NSCoder's
 special taking for `NSNumber`) into consideration. It decodes values with
 `NSCoder`'s `-decodeObjectForKey:`. But for those `NSValue` wrapped, and non-
 `NSNumber` values, the call-back would convert them from `NSData` at first.
 */
FOUNDATION_EXTERN const ObjCDynamicCodingDecodeCallBack kObjCDynamicCodingDefaultDecodeCallBack;

/** The default implementation of encode call-back.

 -Dicussion: The default encode call-back took Foundation's mechanism(NSCoder's
 special taking for `NSNumber`) into consideration. It encodes values with
 `NSCoder`'s `-encodeObject:forKey:`. But for those `NSValue` wrapped, and non-
 `NSNumber` values, the call-back would convert them into `NSData` at first.
 */
FOUNDATION_EXTERN const ObjCDynamicCodingEncodeCallBack kObjCDynamicCodingDefaultEncodeCallBack;

/** Registers an accessor's getter and setter with a given type identifier(
 A part of or an Objective-C type encoding). Wraps 
 `ObjCDynamicCodingRegisterAccessorWithCodingCallBacks` with default coding
 call-backs.
 */
FOUNDATION_EXTERN BOOL ObjCDynamicCodingRegisterCodingCallBacks(const char * typeIdentifier, const ObjCDynamicCodingDecodeCallBack decodeCallBack, const ObjCDynamicCodingEncodeCallBack encodeCallBack);

FOUNDATION_EXPORT ObjCDynamicCodingEncodeCallBack ObjCDynamicCodingEncodeCallBackForProperty(const Class, const NSString *);

FOUNDATION_EXPORT ObjCDynamicCodingDecodeCallBack ObjCDynamicCodingDecodeCallBackForProperty(const Class, const NSString *);
