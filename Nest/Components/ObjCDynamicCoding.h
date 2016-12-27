//
//  ObjCDynamicCoding.h
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import Foundation;

typedef id (*ObjCDynamicCodingDecodeCallBack) (const Class cls, const NSCoder * decoder, const NSString * key);

typedef void (*ObjCDynamicCodingEncodeCallBack) (const Class cls, const NSCoder * encoder, const NSString * key, const id value);

/** Registers an accessor's getter and setter with a given type identifier(
 A part of or an Objective-C type encoding). Wraps 
 `ObjCDynamicCodingRegisterAccessorWithCodingCallBacks` with default coding
 call-backs.
 */
FOUNDATION_EXTERN BOOL ObjCDynamicCodingRegisterCodingCallBacks(const char * typeEncoding, const ObjCDynamicCodingDecodeCallBack decodeCallBack, const ObjCDynamicCodingEncodeCallBack encodeCallBack);
