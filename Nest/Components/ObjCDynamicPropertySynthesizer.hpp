//
//  ObjCDynamicPropertySynthesizer.hpp
//  Nest
//
//  Created by Manfred on 24/12/2016.
//
//

#ifndef ObjCDynamicPropertySynthesizer_hpp
#define ObjCDynamicPropertySynthesizer_hpp

#include <objc/runtime.h>

#include <string>
#include <vector>
#include <forward_list>
#include <unordered_map>

namespace nest {
#pragma mark - nest::ObjCDynamicPropertySynthesizer
    class ObjCDynamicPropertySynthesizer {
    private:
#pragma mark - Member Types
#pragma mark GlobalUniqueStringPointerHashFunc
        class GlobalUniqueStringUniquePtrHashFunc {
        public:
            size_t operator() (const std::unique_ptr<std::string>& key) const {
                std::hash<std::string> hash_func;
                return hash_func(* key);
            }
        };
        
#pragma mark IsGlobalUniqueStringPointerEqualFunc
        class IsGlobalUniqueStringUniquePtrEqualFunc {
        public:
            bool operator() (const std::unique_ptr<std::string>& t1, const std::unique_ptr<std::string>& t2) const {
                return !(t1 -> compare(* t2));
            }
        };
        
#pragma mark GlobalUniqueStringPointerHashFunc
        class GlobalUniqueStringPointerHashFunc {
        public:
            size_t operator() (std::string * key) const {
                std::hash<std::string> hash_func;
                return hash_func(* key);
            }
        };
        
#pragma mark IsGlobalUniqueStringPointerEqualFunc
        class IsGlobalUniqueStringPointerEqualFunc {
        public:
            bool operator() (std::string * t1, std::string * t2) const {
                return !(t1 -> compare(* t2));
            }
        };
        
#pragma mark PropertyAttributes
        struct PropertyAttributes {
        public:
            std::unique_ptr<std::string> type_encoding;
            std::unique_ptr<std::string> name;
            bool is_read_only;
            bool is_copy;
            bool is_retain;
            bool is_nonatomic;
            std::unique_ptr<std::string> getter_name;
            std::unique_ptr<std::string> setter_name;
            bool is_dynamic;
            bool is_weak;
            bool is_garbage_collection_eligible;
            std::unique_ptr<std::string> type_encoding_old;
            std::unique_ptr<std::string> ivar;
            
            PropertyAttributes(objc_property_t property);
            
            PropertyAttributes(const char * name, const objc_property_attribute_t * attributes, unsigned int attribute_count);
        private:
            static std::unique_ptr<std::string> getPropertyDefaultSetterName(const char * raw_property_name);
            
            void _init(const char * raw_name, const objc_property_attribute_t * attributes, unsigned int attribute_count);
        };
        
    public:
#pragma mark AccessorKind
        enum class AccessorKind: int {
            getter,
            setter
        };
        
    private:
#pragma mark AccessorDescription
        struct AccessorDescription {
            AccessorKind kind;
            
            PropertyAttributes * property_attributes;
            
            // type encoding for the accessor, not the property
            std::unique_ptr<std::string> accessor_type_encodings;
            
            AccessorDescription(AccessorKind kind, PropertyAttributes * property_attributes);
        };
        
#pragma mark ImplementationCenter
        class ImplementationCenter {
        public:
            static ImplementationCenter& shared() {
                static ImplementationCenter instance;
                return instance;
            }
            
            bool addImplementation(IMP imp, AccessorKind kind, const char * type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak);
            
            void setImplementation(IMP imp, AccessorKind kind, const char * type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak);
            
            IMP getImplementation(AccessorDescription * accessor_description);
            
            ImplementationCenter();
            
        private:
            std::unique_ptr<std::string> _implemenationIdentifier(const char *type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak);
            
            std::unique_ptr<std::unordered_map<std::unique_ptr<std::string>, IMP, GlobalUniqueStringUniquePtrHashFunc, IsGlobalUniqueStringUniquePtrEqualFunc>> getter_implementations_;
            std::unique_ptr<std::unordered_map<std::unique_ptr<std::string>, IMP, GlobalUniqueStringUniquePtrHashFunc, IsGlobalUniqueStringUniquePtrEqualFunc>> setter_implementations_;
            
        public:
            ImplementationCenter(ImplementationCenter const&)   = delete;
            void operator=(ImplementationCenter const&)         = delete;
        };
        
#pragma mark ClassDescription
        class ClassDescription {
        public:
            ClassDescription(Class cls);
            
            void appendProperty(const char * name, const objc_property_attribute_t * attributes, unsigned int attribute_count);
            
            void prepareIfNeeded();
            
            bool is_prepared() { return is_prepared_; }
            
            AccessorDescription * getAccessorDescription(SEL selector);
            
            std::string * name() { return name_.get(); }
            
            ImplementationCenter * implementationCenter();
            
        private:
            bool _processPropertyAttributesIfNeeded(std::unique_ptr<PropertyAttributes>& property_attributes);
            
            void _processPropertyAttributes(std::unique_ptr<PropertyAttributes>& property_attributes);
            
            bool _shouldProcessPropertyAttributes(std::unique_ptr<PropertyAttributes>& property_attributes);
            
            std::unique_ptr<std::string> name_;
            
            bool is_prepared_;
            
            std::unique_ptr<std::vector<std::unique_ptr<PropertyAttributes>>> processed_property_attributes_;
            
            std::unique_ptr<std::forward_list<std::unique_ptr<PropertyAttributes>>> pending_property_attributes_;
            
            /* Stores property accessor description.
             * The key is the name of `property_attributes` in `AccessorDescription`.
             * The key is raw pointer to get avoid of unneccessary ownership consideration.
             */
            std::unique_ptr<std::unordered_map<std::string *, std::unique_ptr<AccessorDescription>, GlobalUniqueStringPointerHashFunc, IsGlobalUniqueStringPointerEqualFunc>> accessor_descriptions_;
            
            std::unique_ptr<ImplementationCenter> dedicated_implementation_center_;
        };
        
#pragma mark - Member Functions
    public:
        static ObjCDynamicPropertySynthesizer& shared() {
            static ObjCDynamicPropertySynthesizer instance;
            return instance;
        }
        
        bool isClassPrepared(Class cls);
        
        void classDidAddProperty(Class cls, const char * name, const objc_property_attribute_t * attributes, unsigned int attribute_count);
        
        bool synthesizeProperty(Class cls, SEL selector);
        
        static std::string * getPropertyName(Class cls, SEL selector);
        
        static bool addImplementation(IMP imp, AccessorKind kind, const char * type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak);
        
        static void setClassSpecificImplementation(Class cls, IMP imp, AccessorKind kind, const char * type_encoding, bool is_copy, bool is_retain, bool is_nonatomic, bool is_weak);
        
    private:
        ObjCDynamicPropertySynthesizer();
        
        ClassDescription * _prepareClassIfNeeded(Class cls);
        
        /* Stores class descriptions.
         * The key is the name of `ClassDescription`.
         * The key is raw pointer to get avoid of unneccessary ownership consideration.
         */
        std::unique_ptr<std::unordered_map<std::string *, std::unique_ptr<ClassDescription>, GlobalUniqueStringPointerHashFunc, IsGlobalUniqueStringPointerEqualFunc>> class_descriptions_;
        
    public:
        ObjCDynamicPropertySynthesizer(ObjCDynamicPropertySynthesizer const&)   = delete;
        void operator=(ObjCDynamicPropertySynthesizer const&)                   = delete;
    };
}

#endif /* ObjCDynamicPropertySynthesizer_hpp */
