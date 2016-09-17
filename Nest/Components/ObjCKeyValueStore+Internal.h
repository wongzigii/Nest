//
//  ObjCKeyValueStore+Internal.h
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

@import Foundation;

/** Registers an accessor's getter and setter with given a type identifier(
 A part of or an Objective-C type encoding.) 
 */
FOUNDATION_EXTERN BOOL ObjCKeyValueStoreRegisterAccessor(
    const IMP getterImpl, // getter implementation
    const IMP setterImpl, // setter implmentation
    const char * typeIdentifier // type identifier
);

FOUNDATION_EXTERN BOOL ObjCKeyValueStoreIsPropertyName(
    Class aClass,
    NSString * propertyName
);

FOUNDATION_EXTERN BOOL ObjCKeyValueStoreSynthesizeSetterForClassHierarchy(
	Class aClass,
	SEL selector
);

FOUNDATION_EXTERN BOOL ObjCKeyValueStoreSynthesizeGetterForClassHierarchy(
    Class aClass,
    SEL selector
);

typedef NS_ENUM(NSInteger) {
    ObjCKeyValueStoreAccessorKindGetter,
    ObjCKeyValueStoreAccessorKindSetter
} ObjCKeyValueStoreAccessorKind;

/** Asserts the accessor and returning the property name and type.

 @param     self                The instance owns the accessor

 @param     _cmd                The accessor's selector.

 @param     kind                The accessor's kind(getter/setter).

 @param     r_propertyName      Accessor's relative property name. Cannot
 be nil.

 @param     r_propertyType      Accessor's relative property type. Could 
 be nil.

 @param     description     The accessor's description. Use nil value to 
 make the function to deduce the description from allowed type encodings.

 @param     firstAllowedTypeEncodings, ...      Allowed type encodings for
 the accessor implementation. At leat 1 allowed type encoding is required.
 */
FOUNDATION_EXTERN void ObjCKeyValueStoreAssertAccessor(
	id                                  self,
	SEL                                 _cmd,
	ObjCKeyValueStoreAccessorKind       kind,
	NSString * *                        r_propertyName,
	const char * *                      r_propertyType,
	const char *                        description,
	const char *                        firstAllowedTypeEncoding,
	...
);
