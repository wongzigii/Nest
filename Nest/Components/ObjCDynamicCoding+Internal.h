//
//  ObjCDynamicCoding+Internal.h
//  Nest
//
//  Created by Manfred on 27/12/2016.
//
//

#import <Nest/ObjCDynamicCoding.h>

FOUNDATION_EXPORT ObjCDynamicCodingEncodeCallBack ObjCDynamicCodingGetEncodeCallBackForPropertyName(const Class, const NSString *);

FOUNDATION_EXPORT ObjCDynamicCodingDecodeCallBack ObjCDynamicCodingGetDecodeCallBackForPropertyName(const Class, const NSString *);
