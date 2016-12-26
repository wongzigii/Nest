//
//  ObjCDynamicPropertySynthesizer.cpp
//  Nest
//
//  Created by Manfred on 24/12/2016.
//
//

#include <CoreFoundation/CoreFoundation.h>

#include <algorithm>
#include <iostream>

#include "ObjCDynamicPropertySynthesizer.h"
#include "ObjCDynamicPropertySynthesizer.hpp"

#pragma mark - C Bindings
NSString * NSStringFromObjCDynamicPropertyAttributes(ObjCDynamicPropertyAttributes attributes) {
    NSMutableArray<NSString *> * attributeDescriptions = [[NSMutableArray<NSString *> alloc] init];
    if ((attributes & ObjCDynamicPropertyAttributesCopy) != 0) {
        [attributeDescriptions addObject:@"COPY"];
    }
    if ((attributes & ObjCDynamicPropertyAttributesRetain) != 0) {
        [attributeDescriptions addObject:@"RETAIN"];
    }
    if ((attributes & ObjCDynamicPropertyAttributesNonatomic) != 0) {
        [attributeDescriptions addObject:@"NONATOMIC"];
    }
    if ((attributes & ObjCDynamicPropertyAttributesWeak) != 0) {
        [attributeDescriptions addObject:@"WEAK"];
    }
    return [attributeDescriptions componentsJoinedByString:@" "];
}

NSString * NSStringFromObjCDynamicPropertyTypeEncodingAndAttributes(const char * typeEncoding, ObjCDynamicPropertyAttributes attributes) {
    NSMutableArray<NSString *> * descriptions = [[NSMutableArray<NSString *> alloc] init];
    
    [descriptions addObject:[NSString stringWithCString:typeEncoding encoding:NSUTF8StringEncoding]];
    
    if ((attributes & ObjCDynamicPropertyAttributesCopy) != 0) {
        [descriptions addObject:@"COPY"];
    }
    if ((attributes & ObjCDynamicPropertyAttributesRetain) != 0) {
        [descriptions addObject:@"RETAIN"];
    }
    if ((attributes & ObjCDynamicPropertyAttributesNonatomic) != 0) {
        [descriptions addObject:@"NONATOMIC"];
    }
    if ((attributes & ObjCDynamicPropertyAttributesWeak) != 0) {
        [descriptions addObject:@"WEAK"];
    }
    return [descriptions componentsJoinedByString:@" "];
}

NSString * ObjCDynamicPropertySynthesizerPropertyNameForSelectorWithClass(SEL selector, Class cls) {
    auto property_name = nest::ObjCDynamicPropertySynthesizer::getPropertyName(cls, selector);
    if (property_name) {
        return [NSString stringWithCString:property_name -> c_str() encoding:NSUTF8StringEncoding];
    }
    return nil;
}

BOOL ObjCDynamicPropertySynthesizerAddGetter(IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attrs) {
    return nest::ObjCDynamicPropertySynthesizer::addImplementation(imp, nest::ObjCDynamicPropertySynthesizer::AccessorKind::getter, typeEncoding, (attrs & ObjCDynamicPropertyAttributesCopy) != 0, (attrs & ObjCDynamicPropertyAttributesRetain) != 0, (attrs & ObjCDynamicPropertyAttributesNonatomic) != 0, (attrs & ObjCDynamicPropertyAttributesWeak) != 0);
}

BOOL ObjCDynamicPropertySynthesizerAddSetter(IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attrs) {
    return nest::ObjCDynamicPropertySynthesizer::addImplementation(imp, nest::ObjCDynamicPropertySynthesizer::AccessorKind::setter, typeEncoding, (attrs & ObjCDynamicPropertyAttributesCopy) != 0, (attrs & ObjCDynamicPropertyAttributesRetain) != 0, (attrs & ObjCDynamicPropertyAttributesNonatomic) != 0, (attrs & ObjCDynamicPropertyAttributesWeak) != 0);
}

void _ObjCDynamicPropertySynthesizerAddGetter(IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attributes, const char * file, int line) {
#if DEBUG
    if (!ObjCDynamicPropertySynthesizerAddGetter(imp, typeEncoding, attributes)) {
        NSLog(@"Dynamic property getter implementation for \"%@\" was omitted because there is an existed one. SOURCE FILE: %s LINE: %d", NSStringFromObjCDynamicPropertyTypeEncodingAndAttributes(typeEncoding, attributes), file, line);
    }
#else
    ObjCDynamicPropertySynthesizerAddGetter(imp, typeEncoding, attributes);
#endif
}

void _ObjCDynamicPropertySynthesizerAddSetter(IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attributes, const char * file, int line) {
#if DEBUG
    if (!ObjCDynamicPropertySynthesizerAddSetter(imp, typeEncoding, attributes)) {
        NSLog(@"Dynamic property setter implementation for \"%@\" was omitted because there is an existed one. SOURCE FILE: %s LINE: %d", NSStringFromObjCDynamicPropertyTypeEncodingAndAttributes(typeEncoding, attributes), file, line);
    }
#else
    ObjCDynamicPropertySynthesizerAddSetter(imp, typeEncoding, attributes);
#endif
}

void ObjCDynamicPropertySynthesizerSetClassSpecificGetter(Class cls, IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attrs) {
    nest::ObjCDynamicPropertySynthesizer::setClassSpecificImplementation(cls, imp, nest::ObjCDynamicPropertySynthesizer::AccessorKind::getter, typeEncoding, (attrs & ObjCDynamicPropertyAttributesCopy) != 0, (attrs & ObjCDynamicPropertyAttributesRetain) != 0, (attrs & ObjCDynamicPropertyAttributesNonatomic) != 0, (attrs & ObjCDynamicPropertyAttributesWeak) != 0);
}

void ObjCDynamicPropertySynthesizerSetClassSpecificSetter(Class cls, IMP imp, const char * typeEncoding, ObjCDynamicPropertyAttributes attrs) {
    nest::ObjCDynamicPropertySynthesizer::setClassSpecificImplementation(cls, imp, nest::ObjCDynamicPropertySynthesizer::AccessorKind::setter, typeEncoding, (attrs & ObjCDynamicPropertyAttributesCopy) != 0, (attrs & ObjCDynamicPropertyAttributesRetain) != 0, (attrs & ObjCDynamicPropertyAttributesNonatomic) != 0, (attrs & ObjCDynamicPropertyAttributesWeak) != 0);
}

#pragma mark - nest::ClassDescription
nest::ObjCDynamicPropertySynthesizer::ClassDescription::ClassDescription(Class cls) {
    auto raw_name = class_getName(cls);
    name_ = std::unique_ptr<std::string>(new std::string(raw_name));
    is_prepared_ = false;
    accessor_descriptions_ = std::unique_ptr<std::unordered_map<std::string *, std::unique_ptr<AccessorDescription>, GlobalUniqueStringPointerHashFunc, IsGlobalUniqueStringPointerEqualFunc>>(new std::unordered_map<std::string *, std::unique_ptr<AccessorDescription>, GlobalUniqueStringPointerHashFunc, IsGlobalUniqueStringPointerEqualFunc>);
    pending_property_attributes_ = std::unique_ptr<std::forward_list<std::unique_ptr<PropertyAttributes>>>(new std::forward_list<std::unique_ptr<PropertyAttributes>>());
    processed_property_attributes_ = std::unique_ptr<std::vector<std::unique_ptr<PropertyAttributes>>>(new std::vector<std::unique_ptr<PropertyAttributes>>());
    dedicated_implementation_center_ = std::unique_ptr<ImplementationCenter>();
    
    unsigned int property_count = 0;
    auto properties = class_copyPropertyList(cls, &property_count);
    
    processed_property_attributes_ -> reserve(property_count);
    accessor_descriptions_ -> reserve(property_count * 2);
    
    for (unsigned int index = 0; index < property_count; index ++) {
        auto property = properties[index];
        std::unique_ptr<PropertyAttributes> property_attributes (new PropertyAttributes(property));
        
        _processPropertyAttributesIfNeeded(property_attributes);
    }
    
    free(properties);
}

nest::ObjCDynamicPropertySynthesizer::ImplementationCenter * nest::ObjCDynamicPropertySynthesizer::ClassDescription::implementationCenter() {
    if (dedicated_implementation_center_ == nullptr) {
        dedicated_implementation_center_.reset(new ImplementationCenter());
    }
    return dedicated_implementation_center_.get();
}

nest::ObjCDynamicPropertySynthesizer::AccessorDescription * nest::ObjCDynamicPropertySynthesizer::ClassDescription::getAccessorDescription(SEL selector) {
    auto raw_selector_name = sel_getName(selector);
    std::unique_ptr<std::string> selector_name (new std::string(raw_selector_name));
    auto matches = accessor_descriptions_ -> find(selector_name.get());
    if (matches != accessor_descriptions_ -> end()) {
        return matches -> second.get();
    }
#if DEBUG
        std::cout << "Missing accessor description for selector: " << * selector_name << std::endl;
        for (auto &each : * accessor_descriptions_) {
            std::cout << "Existed accessor description setter: -" << * each.second -> property_attributes -> setter_name << ", getter: -" << * each.second -> property_attributes -> getter_name  << std::endl;
        }
#endif
    return nullptr;
}

void nest::ObjCDynamicPropertySynthesizer::ClassDescription::prepareIfNeeded() {
    if (!(pending_property_attributes_ -> empty())) {
        
        for (auto &property_attributes : * pending_property_attributes_) {
            _processPropertyAttributesIfNeeded(property_attributes);
        }
        
        pending_property_attributes_ -> clear();
    }
    
    assert(pending_property_attributes_ -> empty());
}

void nest::ObjCDynamicPropertySynthesizer::ClassDescription::appendProperty(const char *name, const objc_property_attribute_t *attributes, unsigned int attribute_count) {
    pending_property_attributes_ -> push_front(std::unique_ptr<PropertyAttributes>(new PropertyAttributes(name, attributes, attribute_count)));
}

bool nest::ObjCDynamicPropertySynthesizer::ClassDescription::_processPropertyAttributesIfNeeded(std::unique_ptr<PropertyAttributes>& property_attributes) {
    if (_shouldProcessPropertyAttributes(property_attributes)) {
        _processPropertyAttributes(property_attributes);
        return true;
    }
    return false;
}

void nest::ObjCDynamicPropertySynthesizer::ClassDescription::_processPropertyAttributes(std::unique_ptr<PropertyAttributes>& property_attributes) {
    std::unique_ptr<AccessorDescription> getter_description (new AccessorDescription(AccessorKind::getter, property_attributes.get()));
    accessor_descriptions_ -> emplace(std::make_pair(property_attributes -> getter_name.get(), std::move(getter_description)));
    
    if (!(property_attributes -> is_read_only)) {
        std::unique_ptr<AccessorDescription> setter_description (new AccessorDescription(AccessorKind::setter, property_attributes.get()));
        accessor_descriptions_ -> emplace(std::make_pair(property_attributes -> setter_name.get(), std::move(setter_description)));
    }
    
    processed_property_attributes_ -> push_back(std::move(property_attributes));
}


bool nest::ObjCDynamicPropertySynthesizer::ClassDescription::_shouldProcessPropertyAttributes(std::unique_ptr<PropertyAttributes>& property_attributes) {
    return property_attributes -> is_dynamic;
}

#pragma mark - nest::PropertyAttributes
std::unique_ptr<std::string> nest::ObjCDynamicPropertySynthesizer::PropertyAttributes::getPropertyDefaultSetterName(const char *raw_property_name) {
    auto property_name = CFStringCreateWithCString(kCFAllocatorDefault, raw_property_name, kCFStringEncodingUTF8);
    auto property_name_length = CFStringGetLength(property_name);
    
    assert(property_name_length > 0);
    
    auto initial_character_range = CFStringGetRangeOfComposedCharactersAtIndex(property_name, 0);
    auto rest_substring_range = CFRangeMake(initial_character_range.length, property_name_length - initial_character_range.length);
    
    auto first_character = CFStringCreateWithSubstring(kCFAllocatorDefault, property_name, initial_character_range);
    auto first_character_uppercased = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, first_character);
    CFStringUppercase(first_character_uppercased, CFLocaleGetSystem());
    
    auto rest_substring = CFStringCreateWithSubstring(kCFAllocatorDefault, property_name, rest_substring_range);
    
    auto default_setter_name_cf = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("set%@%@:"), first_character_uppercased, rest_substring);
    
    const char * default_setter_name_raw = CFStringGetCStringPtr(default_setter_name_cf, kCFStringEncodingUTF8);
    
    std::unique_ptr<std::string> default_setter_name (new std::string(default_setter_name_raw));
    
    return default_setter_name;
}

nest::ObjCDynamicPropertySynthesizer::PropertyAttributes::PropertyAttributes(const char * raw_name, const objc_property_attribute_t * attributes, unsigned int attribute_count) {
    _init(raw_name, attributes, attribute_count);
}

nest::ObjCDynamicPropertySynthesizer::PropertyAttributes::PropertyAttributes(objc_property_t property) {
    auto raw_name = property_getName(property);
    unsigned int attribute_count = 0;
    auto attributes = property_copyAttributeList(property, &attribute_count);
    
    _init(raw_name, attributes, attribute_count);
    
    free((void *)attributes);
}


void nest::ObjCDynamicPropertySynthesizer::PropertyAttributes::_init(const char *raw_name, const objc_property_attribute_t *attributes, unsigned int attribute_count) {
    auto property_default_setter_name = getPropertyDefaultSetterName(raw_name);
    
    name = std::unique_ptr<std::string>(new std::string(raw_name));
    is_read_only = false;
    is_copy = false;
    is_retain = false;
    is_nonatomic = false;
    getter_name = std::unique_ptr<std::string>(new std::string(raw_name));
    setter_name = std::unique_ptr<std::string>(std::move(property_default_setter_name));
    is_dynamic = false;
    is_weak = false;
    is_garbage_collection_eligible = false;
    type_encoding_old = std::unique_ptr<std::string>();
    ivar = std::unique_ptr<std::string>();
    
    for (unsigned int index = 0; index < attribute_count; index ++) {
        auto attribute = attributes[index];
        auto attribute_name = (* attribute.name);
        switch (attribute_name) {
            case 'R':
                is_read_only = true;
                break;
            case 'C':
                is_copy = true;
                break;
            case '&':
                is_retain = true;
                break;
            case 'G':
                getter_name.reset(new std::string(attribute.value));
                break;
            case 'S':
                setter_name.reset(new std::string(attribute.value));
                break;
            case 'D':
                is_dynamic = true;
                break;
            case 'W':
                is_weak = true;
                break;
            case 'P':
                // Shall throw
                is_garbage_collection_eligible = true;
                break;
            case 't':
                type_encoding_old.reset(new std::string(attribute.value));
                break;
            case 'T':
                type_encoding.reset(new std::string(attribute.value));
                break;
            case 'V':
                ivar.reset(new std::string(attribute.value));
                break;
        }
    }
}

#pragma mark - nest::AccessorDescription
nest::ObjCDynamicPropertySynthesizer::AccessorDescription::AccessorDescription(AccessorKind kind, PropertyAttributes * property_attributes) {
    this -> kind = kind;
    this -> property_attributes = property_attributes;
    switch (kind) {
        case AccessorKind::getter: {
            auto type_encodings = "@:";
            accessor_type_encodings = std::unique_ptr<std::string>(new std::string(type_encodings));
            break;
        }
        case AccessorKind::setter: {
            std::string type_encodings = "@:";
            type_encodings += (* property_attributes -> type_encoding);
            accessor_type_encodings = std::unique_ptr<std::string>(new std::string(type_encodings));
            break;
        }
    }
}

#pragma mark - nest::ImplementationCenter
nest::ObjCDynamicPropertySynthesizer::ImplementationCenter::ImplementationCenter() {
    getter_implementations_ = std::unique_ptr<std::unordered_map<std::unique_ptr<std::string>, IMP, GlobalUniqueStringUniquePtrHashFunc, IsGlobalUniqueStringUniquePtrEqualFunc>>(new std::unordered_map<std::unique_ptr<std::string>, IMP, GlobalUniqueStringUniquePtrHashFunc, IsGlobalUniqueStringUniquePtrEqualFunc>);
    setter_implementations_ = std::unique_ptr<std::unordered_map<std::unique_ptr<std::string>, IMP, GlobalUniqueStringUniquePtrHashFunc, IsGlobalUniqueStringUniquePtrEqualFunc>>(new std::unordered_map<std::unique_ptr<std::string>, IMP, GlobalUniqueStringUniquePtrHashFunc, IsGlobalUniqueStringUniquePtrEqualFunc>);
}

bool nest::ObjCDynamicPropertySynthesizer::ImplementationCenter::addImplementation(IMP imp, nest::ObjCDynamicPropertySynthesizer::AccessorKind kind, const char *type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak) {
    auto identifier = ImplementationCenter::_implemenationIdentifier(type_encoding, is_copy, is_retain, is_nonatomic, is_weak);
    
    switch (kind) {
        case AccessorKind::getter:
            if (getter_implementations_ -> find(identifier) == getter_implementations_ -> end()) {
                getter_implementations_ -> emplace(std::make_pair(std::move(identifier), imp));
                return true;
            }
            return false;
            break;
        case AccessorKind::setter:
            if (setter_implementations_ -> find(identifier) == setter_implementations_ -> end()) {
                setter_implementations_ -> emplace(std::make_pair(std::move(identifier), imp));
                return true;
            }
            return false;
            break;
    }
}

void nest::ObjCDynamicPropertySynthesizer::ImplementationCenter::setImplementation(IMP imp, nest::ObjCDynamicPropertySynthesizer::AccessorKind kind, const char *type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak) {
    auto identifier = ImplementationCenter::_implemenationIdentifier(type_encoding, is_copy, is_retain, is_nonatomic, is_weak);
    
    switch (kind) {
        case AccessorKind::getter:
            getter_implementations_ -> emplace(std::make_pair(std::move(identifier), imp));
            break;
        case AccessorKind::setter:
            setter_implementations_ -> emplace(std::make_pair(std::move(identifier), imp));
            break;
    }
}

IMP nest::ObjCDynamicPropertySynthesizer::ImplementationCenter::getImplementation(nest::ObjCDynamicPropertySynthesizer::AccessorDescription *accessor_description) {
    
    auto property_attributes = accessor_description -> property_attributes;
    
    auto identifier = _implemenationIdentifier(property_attributes -> type_encoding -> c_str(), property_attributes -> is_copy, property_attributes -> is_retain, property_attributes -> is_nonatomic, property_attributes -> is_weak);
    
    
    switch (accessor_description -> kind) {
        case AccessorKind::getter: {
            auto matches = getter_implementations_ -> find(identifier);
            if (matches != getter_implementations_ -> end()) {
                return matches -> second;
            }
#if DEBUG
            std::cout << "Missing getter implementation for implementation identifier: " << * identifier << std::endl;
            for (auto &each : * getter_implementations_) {
                std::cout << "Existed getter implementation implementation identifier: " << * each.first << std::endl;
            }
#endif
            break;
        }
        case AccessorKind::setter: {
            auto matches = setter_implementations_ -> find(identifier);
            if (matches != setter_implementations_ -> end()) {
                return matches -> second;
            }
#if DEBUG
            std::cout << "Missing setter implementation for implementation identifier: " << * identifier << std::endl;
            for (auto &each : * setter_implementations_) {
                std::cout << "Existed setter implementation implementation identifier: " << * each.first << std::endl;
            }
#endif
            break;
        }
    }
    return nullptr;
}

std::unique_ptr<std::string> nest::ObjCDynamicPropertySynthesizer::ImplementationCenter::_implemenationIdentifier(const char *type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak) {
    std::unique_ptr<std::string> identifier (new std::string(type_encoding));
    
    if (is_copy) {
        identifier -> append("c");
    }
    if (is_retain) {
        identifier -> append("&");
    }
    if (is_nonatomic) {
        identifier -> append("N");
    }
    if (is_weak) {
        identifier -> append("W");
    }
    
    return identifier;
}

#pragma mark - nest::ObjCDynamicPropertySynthesizer
nest::ObjCDynamicPropertySynthesizer::ObjCDynamicPropertySynthesizer() {
    class_descriptions_ = std::unique_ptr<std::unordered_map<std::string *, std::unique_ptr<ClassDescription>, GlobalUniqueStringPointerHashFunc, IsGlobalUniqueStringPointerEqualFunc>>(new std::unordered_map<std::string *, std::unique_ptr<ClassDescription>, GlobalUniqueStringPointerHashFunc, IsGlobalUniqueStringPointerEqualFunc>);
}

bool nest::ObjCDynamicPropertySynthesizer::isClassPrepared(Class cls) {
    auto class_raw_name = class_getName(cls);
    std::unique_ptr<std::string> class_name (new std::string(class_raw_name));
    auto matched = class_descriptions_->find(class_name.get());
    if (matched != class_descriptions_->end()) {
        auto class_description = matched -> second.get();
        return class_description -> is_prepared();
    }
    return false;
}

void nest::ObjCDynamicPropertySynthesizer::classDidAddProperty(Class cls, const char * name, const objc_property_attribute_t * attributes, unsigned int attribute_count) {
    auto class_raw_name = class_getName(cls);
    std::unique_ptr<std::string> class_name (new std::string(class_raw_name));
    auto matched = class_descriptions_ -> find(class_name.get());
    if (matched != class_descriptions_ -> end()) {
        auto class_description = matched -> second.get();
        class_description -> appendProperty(name, attributes, attribute_count);
    }
}

bool nest::ObjCDynamicPropertySynthesizer::synthesizeProperty(Class cls, SEL selector) {
    auto class_description = _prepareClassIfNeeded(cls);
    
    auto accessor_description = class_description -> getAccessorDescription(selector);
    
    if (accessor_description) {
        IMP implementation = ImplementationCenter::shared().getImplementation(accessor_description);
        
        if (implementation) {
            auto types = accessor_description -> accessor_type_encodings -> c_str();
            return class_addMethod(cls, selector, implementation, types);
        } else {
#if DEBUG
            if (class_isMetaClass(cls)) {
                std::cout << "No implementation found for class " << * class_description -> name() << "'s property: " << * accessor_description -> property_attributes -> name << ", which invoked by accessing selector: +" << sel_getName(selector) << "." << std::endl;
            } else {
                std::cout << "No implementation found for class " << * class_description -> name() << "'s property: " << * accessor_description -> property_attributes -> name << ", which invoked by accessing selector: -" << sel_getName(selector) << "." << std::endl;
            }
#endif
        }
    } else {
#if DEBUG
        if (class_isMetaClass(cls)) {
            std::cout << "No accessor description found for class " << * class_description -> name() << "'s selector: +" << sel_getName(selector) << "." << std::endl;
        } else {
            std::cout << "No accessor description found for class " << * class_description -> name() << "'s selector: -" << sel_getName(selector) << "." << std::endl;
        }
#endif
    }
    return false;
}

std::string * nest::ObjCDynamicPropertySynthesizer::getPropertyName(Class cls, SEL selector) {
    auto class_raw_name = class_getName(cls);
    std::unique_ptr<std::string> class_name (new std::string(class_raw_name));
    auto matched = shared().class_descriptions_->find(class_name.get());
    if (matched != shared().class_descriptions_->end()) {
        auto accessor_description = matched -> second -> getAccessorDescription(selector);
        auto property_attributes = accessor_description -> property_attributes;
        return property_attributes -> name.get();
    }
    return nil;
}

bool nest::ObjCDynamicPropertySynthesizer::addImplementation(IMP imp, AccessorKind kind, const char * type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak) {
    return ImplementationCenter::shared().addImplementation(imp, kind, type_encoding, is_copy, is_retain, is_nonatomic, is_weak);
}

void nest::ObjCDynamicPropertySynthesizer::setClassSpecificImplementation(Class cls, IMP imp, AccessorKind kind, const char * type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak) {
    auto class_description = shared()._prepareClassIfNeeded(cls);
    class_description -> implementationCenter() -> setImplementation(imp, kind, type_encoding, is_copy, is_retain, is_nonatomic, is_weak);
}

nest::ObjCDynamicPropertySynthesizer::ClassDescription * nest::ObjCDynamicPropertySynthesizer::_prepareClassIfNeeded(Class cls) {
    auto class_raw_name = class_getName(cls);
    std::unique_ptr<std::string> class_name (new std::string(class_raw_name));
    auto matched = class_descriptions_ -> find(class_name.get());
    if(matched == class_descriptions_ -> end()) {
        std::unique_ptr<ClassDescription> class_description (new ClassDescription(cls));
        auto emplaced = class_descriptions_ -> emplace(std::make_pair(class_description -> name(), std::move(class_description)));
        return emplaced.first -> second.get();
    } else {
        matched -> second -> prepareIfNeeded();
        return matched -> second.get();
    }
}
