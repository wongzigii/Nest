//
//  ObjCCodingBasePropertySynthesize.h
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

@import Foundation;

/** Register a accessor's getter and setter with given type identifier(
 Objective-C type encoding.)
 
 -Discussion: Hard Coded Type Encoding V.S. `@encode` Compiler Directive.
 
 Though `@encode` is much more flexible but since:
 
 1. Type encodings inside the Objective-C runtime somtimes trailing with 
 Motorola garbage(argument frame size and argument frame offset, which is 
 architecture dependent.)
 
 2. C struct using platform dependent types (NSInteger, NSUInteger, CGFloat) has
 different type encodings on different architectures.
 
 3. Object type encoding sometimes trailing with the object's class name inside
 the Objective-C type system.
 
 The most efficient and accurate way to match type encodings is just to match
 the most forward common part, which means:
 
 1. Match `SEL` with ":" but not ":4"(4 for the argument frame offset, which 
 means 4 bytes.)
 
 2. Match `CGSize` with "{CGSize=" but not "{CGSize=dd}"(on 64-bit arch) nor
 "{CGSize=ff}"(on 32-bit arch).
 
 3. Match `id`(any object, no type specified) with "@" but not "@\"Foo\"" nor
 "@\"Bar\"".
 
 So use hard coded type encoding in the first argument of this function instead
 of `@encode`.
 */
FOUNDATION_EXTERN BOOL ObjCCodingBaseRegisterAccessor(
    const char *, // type identifier
    const IMP, // getter implementation
    const IMP // setter implmentation
);

FOUNDATION_EXTERN NSString * ObjCCodingBasePropertyNameForGetter(Class, SEL);
FOUNDATION_EXTERN NSString * ObjCCodingBasePropertyNameForSetter(Class, SEL);
FOUNDATION_EXTERN BOOL ObjCCodingBaseIsPropertyName(Class, NSString *);
FOUNDATION_EXTERN BOOL ObjCCodingBaseSynthesizeSetter(Class, SEL);
FOUNDATION_EXTERN BOOL ObjCCodingBaseSynthesizeGetter(Class, SEL);
