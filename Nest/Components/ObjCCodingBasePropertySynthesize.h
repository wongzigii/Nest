//
//  ObjCCodingBasePropertySynthesize.h
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import Foundation;

FOUNDATION_EXTERN BOOL ObjCCodingBaseRegisterAccessor(
    const char *, // type identifier
    const IMP, // getter ;
    const IMP // setter implmentation
);

FOUNDATION_EXTERN NSString * ObjCCodingBasePropertyNameForGetter(Class, SEL);
FOUNDATION_EXTERN NSString * ObjCCodingBasePropertyNameForSetter(Class, SEL);
FOUNDATION_EXTERN BOOL ObjCCodingBaseIsPropertyName(Class, NSString *);
FOUNDATION_EXTERN BOOL ObjCCodingBaseSynthesizeSetter(Class, SEL);
FOUNDATION_EXTERN BOOL ObjCCodingBaseSynthesizeGetter(Class, SEL);
