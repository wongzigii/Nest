//
//  ObjCDynamicPropertySynthesizing.m
//  Nest
//
//  Created by Manfred on 24/12/2016.
//
//

#import <objc/message.h>

#import <dlfcn.h>

#import "fishhook.h"

#import "ObjCDynamicPropertySynthesizer.hpp"
#import "ObjCDynamicPropertySynthesizing.h"

#import "ObjCDynamicPropertySynthesizer.h"

NS_ASSUME_NONNULL_BEGIN
#pragma mark - Function Prototypes
typedef BOOL NSObjectResolveInstanceMethod (id, SEL, SEL);
static NSObjectResolveInstanceMethod * kNSObjectResolveInstanceMethodOriginal;
static NSObjectResolveInstanceMethod NSObjectResolveInstanceMethodSwizzled;

typedef id NSObjectValueForKey (id, SEL, NSString *);
static NSObjectValueForKey * kNSObjectValueForKeyOriginal;
static NSObjectValueForKey NSObjectValueForKeySwizzled;

typedef void NSObjectSetValueForKey (id, SEL, id, NSString *);
static NSObjectSetValueForKey * kNSObjectSetValueForKeyOriginal;
static NSObjectSetValueForKey NSObjectSetValueForKeySwizzled;

typedef BOOL ClassAddPropertyFunc (Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount);
static ClassAddPropertyFunc * kClass_addPropertyOriginal;
static ClassAddPropertyFunc class_addPropertyRebound;
static void class_didAddProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL succeeded);

_NEST_MODULE_CONSTRUCTOR_LOW_PRIORITY
static void InjectDynamicPropertySynthesizer() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Rebind class_addProperty
        kClass_addPropertyOriginal = (ClassAddPropertyFunc *) dlsym(RTLD_DEFAULT, "class_addProperty");
        
        void * replacment = (void *)&class_addPropertyRebound;
        void * * replaced = (void * *)&kClass_addPropertyOriginal;
        
        struct rebinding rebind_for_class_addProperty = {
            "class_addProperty",
            replacment,
            replaced,
        };
        
#if DEBUG
        if (rebind_symbols(&rebind_for_class_addProperty, 1) == 0) {
            NSLog(@"Rebind class_addProperty succeeded.");
        } else {
            NSLog(@"Rebind class_addProperty failed.");
        }
#else
        rebind_symbols(&rebind_for_class_addProperty, 1) == 0
#endif
        
        // Swizzle -valueForKey:
        Method valueForKey = class_getInstanceMethod([NSObject class], @selector(valueForKey:));
        kNSObjectValueForKeyOriginal = (NSObjectValueForKey *)method_getImplementation(valueForKey);
        method_setImplementation(valueForKey, (IMP)&NSObjectValueForKeySwizzled);
        
        // Swizzle -setValue:forKey:
        Method setValueForKey = class_getInstanceMethod([NSObject class], @selector(setValue:forKey:));
        kNSObjectSetValueForKeyOriginal = (NSObjectSetValueForKey *)method_getImplementation(setValueForKey);
        method_setImplementation(setValueForKey, (IMP)&NSObjectSetValueForKeySwizzled);
        
        // Swizzle +resolveInstanceMethod:
        Method resolveInstanceMethod = class_getClassMethod([NSObject class], @selector(resolveInstanceMethod:));
        kNSObjectResolveInstanceMethodOriginal = (NSObjectResolveInstanceMethod *)method_getImplementation(resolveInstanceMethod);
        method_setImplementation(resolveInstanceMethod, (IMP)&NSObjectResolveInstanceMethodSwizzled);
    });
}

void NSObjectSetValueForKeySwizzled (id self, SEL _cmd, id value, NSString * key) {
    if ([self conformsToProtocol:@protocol(ObjCDynamicPropertySynthesizing)]) {
        if (nest::ObjCDynamicPropertySynthesizer::shared().isDynamicProperty([self class], key)) {
            id <ObjCDynamicPropertySynthesizing> dynamic = self;
            [dynamic setPrimitiveValue:value forKey:key];
            return;
        }
    }
    
    (* kNSObjectSetValueForKeyOriginal)(self, _cmd, value, key);
}

id NSObjectValueForKeySwizzled (id self, SEL _cmd, NSString * key) {
    if ([self conformsToProtocol:@protocol(ObjCDynamicPropertySynthesizing)]) {
        if (nest::ObjCDynamicPropertySynthesizer::shared().isDynamicProperty([self class], key)) {
            id <ObjCDynamicPropertySynthesizing> dynamic = self;
            return [dynamic primitiveValueForKey:key];
        }
    }
    
    return (* kNSObjectValueForKeyOriginal)(self, _cmd, key);
}

BOOL NSObjectResolveInstanceMethodSwizzled(id self, SEL _cmd, SEL selector) {
    if ([self conformsToProtocol:@protocol(ObjCDynamicPropertySynthesizing)]) {
        if (nest::ObjCDynamicPropertySynthesizer::shared().synthesizeProperty([self class], selector)) {
            return YES;
        }
    }
    return (* kNSObjectResolveInstanceMethodOriginal)(self, _cmd, selector);
}

BOOL class_addPropertyRebound(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount) {
    BOOL succeeded = (* kClass_addPropertyOriginal)(cls, name, attributes, attributeCount);
    class_didAddProperty(cls, name, attributes, attributeCount, succeeded);
    return succeeded;
}

void class_didAddProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL succeeded) {
    if (succeeded && nest::ObjCDynamicPropertySynthesizer::shared().isClassPrepared(cls)) {
        nest::ObjCDynamicPropertySynthesizer::shared().classDidAddProperty(cls, name, attributes, attributeCount);
    }
}

NS_ASSUME_NONNULL_END
