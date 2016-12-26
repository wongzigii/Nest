//
//  ObjCDynamicPropertySynthesizer.h
//  Nest
//
//  Created by Manfred on 25/12/2016.
//
//

#ifndef ObjCDynamicPropertySynthesizer_h
#define ObjCDynamicPropertySynthesizer_h

#import <Foundation/Foundation.h>
#import <Nest/Metamacros.h>
#import <Nest/MacroUtilities.h>
#import <Nest/ObjCDynamicPropertySynthesizing.h>

NS_ASSUME_NONNULL_BEGIN

#define COPY       _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_COPY
#define RETAIN     _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_RETAIN
#define NONATOMIC  _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_NONATOMIC
#define WEAK       _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_WEAK

typedef NS_OPTIONS(NSInteger, ObjCDynamicPropertyAttributes) {
    ObjCDynamicPropertyAttributesNone = 0,
    ObjCDynamicPropertyAttributesCopy = 1 << 0,
    ObjCDynamicPropertyAttributesRetain = 1 << 1,
    ObjCDynamicPropertyAttributesNonatomic = 1 << 2,
    ObjCDynamicPropertyAttributesWeak = 1 << 3
};

/// Make a dynamic property attributes.
///
/// (_OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_NONE, ##__VA_ARGS__) is a trick
/// `20`, which `_OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_NONE` stands for, is
/// metamacros's largest argument number, `##__VA__ARGS__` eliminates itself
/// when `__VA__ARGS__` has nothing.
#define ObjCDynamicPropertyAttributesMake(...) \
    metamacro_foreach_concat(,,_ObjCDynamicPropertyAttributeOptions(_OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_NONE, ##__VA_ARGS__))

FOUNDATION_EXTERN NSString * NSStringFromObjCDynamicPropertyAttributes(ObjCDynamicPropertyAttributes attributes);

/// Defines a global dynamic property getter. Does nothing when there is an
/// existed one with specified return type and property attributes.
#define ObjCDynamicPropertyGetter(RETURN_TYPE, ...) \
    _NEST_KEYWORD_FILE_SCOPE \
        static _ObjCDynamicPropertyGetter(RETURN_TYPE); \
        _NEST_MODULE_CONSTRUCTOR_HIGH_PRIORITY \
        static void metamacro_concat(nest_add_dynamic_property_getter, __LINE__)() { \
            ObjCDynamicPropertyAttributes attributes = ObjCDynamicPropertyAttributesMake(__VA_ARGS__); \
            _ObjCDynamicPropertySynthesizerAddGetter((IMP)&_ObjCDynamicPropertyGetterName, @encode(RETURN_TYPE), attributes, __FILE__, __LINE__); \
        } \
        _ObjCDynamicPropertyGetter(RETURN_TYPE) \

/// Defines a global dynamic property setter. Does nothing when there is an
/// existed one with specified return type and property attributes.
#define ObjCDynamicPropertySetter(TYPE, ...) \
    _NEST_KEYWORD_FILE_SCOPE \
        static _ObjCDynamicPropertySetter(TYPE); \
        _NEST_MODULE_CONSTRUCTOR_HIGH_PRIORITY \
        static void metamacro_concat(nest_add_dynamic_property_setter, __LINE__)() {\
            ObjCDynamicPropertyAttributes attributes = ObjCDynamicPropertyAttributesMake(__VA_ARGS__); \
            _ObjCDynamicPropertySynthesizerAddSetter((IMP)&_ObjCDynamicPropertySetterName, @encode(TYPE), attributes, __FILE__, __LINE__); \
        } \
        _ObjCDynamicPropertySetter(TYPE) \

/// Defines a class specific dynamic property getter. Always replace the
/// originally one whenever whether is an existed one with specified return type
/// and property attributes.
#define ObjCDynamicPropertyClassSpecificGetter(CLASS, RETURN_TYPE, ...) \
    _NEST_KEYWORD_FILE_SCOPE \
        static _ObjCDynamicPropertyClassSpecificGetter(RETURN_TYPE, CLASS); \
        _NEST_MODULE_CONSTRUCTOR_HIGH_PRIORITY \
        static void metamacro_concat(nest_add_CLASS_specific_dynamic_property_getter, __LINE__)() { \
            ObjCDynamicPropertyAttributes attributes = ObjCDynamicPropertyAttributesMake(__VA_ARGS__); \
            ObjCDynamicPropertySynthesizerSetClassSpecificGetter(CLASS, (IMP)&_ObjCDynamicPropertyClassSpecificGetterName(CLASS), @encode(RETURN_TYPE), attributes); \
        } \
        _ObjCDynamicPropertyClassSpecificGetter(RETURN_TYPE, CLASS) \

/// Defines a class specific dynamic property setter. Always replace the
/// originally one whenever whether is an existed one with specified return type
/// and property attributes.
#define ObjCDynamicPropertyClassSpecificSetter(CLASS, TYPE, ...) \
    _NEST_KEYWORD_FILE_SCOPE \
        static _ObjCDynamicPropertyClassSpecificSetter(CLASS, TYPE); \
        _NEST_MODULE_CONSTRUCTOR_HIGH_PRIORITY \
        static void metamacro_concat(nest_add_CLASS_specific_dynamic_property_setter, __LINE__)() { \
            ObjCDynamicPropertyAttributes attributes = ObjCDynamicPropertyAttributesMake(__VA_ARGS__); \
            ObjCDynamicPropertySynthesizerSetClassSpecificSetter((IMP)&_ObjCDynamicPropertyClassSpecificSetterName(CLASS), @encode(TYPE), attributes); \
        } \
        void _ObjCDynamicPropertyClassSpecificSetter(CLASS, TYPE) \

/// Gets the property name in dynamic property accessor's implementation
///
/// - Notes:
/// Only works in dynamic property accessor's implementation.
#define _key ObjCDynamicPropertySynthesizerPropertyNameForSelectorWithClass(_cmd, [self class])

/// Adds a global dynamic property getter implementation.
///
/// Returns NO when there is an existed one. The adding operation is ommited at
/// the same time.
FOUNDATION_EXTERN BOOL ObjCDynamicPropertySynthesizerAddGetter(IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attributes);

/// Adds a global dynamic property setter implementation.
///
/// Returns NO when there is an existed one. The adding operation is ommited at
/// the same time.
FOUNDATION_EXTERN BOOL ObjCDynamicPropertySynthesizerAddSetter(IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attributes);

/// Sets a class specific dynamic property getter implementation.
FOUNDATION_EXTERN void ObjCDynamicPropertySynthesizerSetClassSpecificGetter(Class cls, IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attributes);

/// Sets a class specific dynamic property setter implementation.
FOUNDATION_EXTERN void ObjCDynamicPropertySynthesizerSetClassSpecificSetter(Class cls, IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attributes);

/// Gets the dynamic property's name with its class and selector(whenever the
/// setter or getter's).
FOUNDATION_EXTERN NSString * ObjCDynamicPropertySynthesizerPropertyNameForSelectorWithClass(SEL selector, Class cls);

#pragma mark - Implementation Details
/* You shall not write code depends on following things. */

#define _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_COPY       0
#define _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_RETAIN     1
#define _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_NONATOMIC  2
#define _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_WEAK       3
#define _OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_NONE       20

/// Resolves a property attribute option from an argument.
///
/// A simple simulation to the following decision tree:
///
/// ```
///     NOTHING
///   /         \
/// COPY      NOT COPY
///          /        \
///       RETAIN  NOT RETAIN
///              /          \
///         NONATOMIC  NOT NOATOMIC
///                    /            \
///                  WEAK        NOT WEAK
///                                     \
///                                    NONE
///
/// ```
#define _ObjCDynamicPropertyAttributeOption(INDEX, ARG) \
    metamacro_if_eq(COPY, ARG)(ObjCDynamicPropertyAttributesCopy)( \
        metamacro_if_eq(RETAIN, ARG)(ObjCDynamicPropertyAttributesRetain)( \
            metamacro_if_eq(NONATOMIC, ARG)(ObjCDynamicPropertyAttributesNonatomic)( \
                metamacro_if_eq(WEAK, ARG)(ObjCDynamicPropertyAttributesWeak)( \
                    metamacro_if_eq(_OBJC_DYNAMIC_PROPERTY_ATTRIBUTE_NONE, ARG)(ObjCDynamicPropertyAttributesNone)( \
                    ) \
                ) \
            ) \
        ) \
    ) \

/// Resolves property attributes options from arguments.
#define _ObjCDynamicPropertyAttributeOptions(...) \
    metamacro_foreach(_ObjCDynamicPropertyAttributeOption,|, __VA_ARGS__)

#define _ObjCDynamicPropertyGetterName metamacro_concat(nest_dynamic_property_getter, __LINE__)
#define _ObjCDynamicPropertySetterName metamacro_concat(nest_dynamic_property_setter, __LINE__)

#define _ObjCDynamicPropertyGetter(RETURN_TYPE) RETURN_TYPE _ObjCDynamicPropertyGetterName(id<ObjCDynamicPropertySynthesizing> self, SEL _cmd)
#define _ObjCDynamicPropertySetter(TYPE) void _ObjCDynamicPropertySetterName(id<ObjCDynamicPropertySynthesizing> self, SEL _cmd, TYPE newValue)

#define _ObjCDynamicPropertyClassSpecificGetterName(CLASS) metamacro_concat(nest_CLASS_dynamic_property_getter, __LINE__)
#define _ObjCDynamicPropertyClassSpecificSetterName(CLASS) metamacro_concat(nest_CLASS_dynamic_property_setter, __LINE__)

#define _ObjCDynamicPropertyClassSpecificGetter(RETURN_TYPE, CLASS) RETURN_TYPE _ObjCDynamicPropertyClassSpecificGetterName(CLASS)(CLASS self, SEL _cmd)
#define _ObjCDynamicPropertyClassSpecificSetter(CLASS, TYPE) void _ObjCDynamicPropertyClassSpecificSetterName(CLASS)(CLASS self, SEL _cmd, TYPE newValue)

/// Adds a global dynamic property getter implementation and logs failure info
/// if it is failed when built with `DEBUG` configuration.
__attribute__((visibility("hidden")))
FOUNDATION_EXTERN void _ObjCDynamicPropertySynthesizerAddGetter(IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attributes, const char * file, int line)
NS_SWIFT_UNAVAILABLE("_ObjCDynamicPropertySynthesizerAddGetter is unavailable in Swift, use ObjCDynamicPropertySynthesizerAddGetter instead.");

/// Adds a global dynamic property setter implementation and logs failure info
/// if it is failed when built with `DEBUG` configuration.
__attribute__((visibility("hidden")))
FOUNDATION_EXTERN void _ObjCDynamicPropertySynthesizerAddSetter(IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attributes, const char * file, int line)
NS_SWIFT_UNAVAILABLE("_ObjCDynamicPropertySynthesizerAddSetter is unavailable in Swift, use ObjCDynamicPropertySynthesizerAddSetter instead.");

NS_ASSUME_NONNULL_END

#endif /* ObjCDynamicPropertySynthesizer_h */
