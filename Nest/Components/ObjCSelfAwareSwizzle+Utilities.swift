//
//  ObjCSelfAwareSwizzle.swift
//  Nest
//
//  Created by Manfred on 11/22/15.
//
//

import Foundation
import ObjectiveC

public typealias ObjCSelfAwareSwizzling = (IMP) -> IMP

//MARK: Inter-Selector Swizzle
public func swizzleClassMethodSelector(
    aSelector: Selector,
    with anotherSelector: Selector,
    on aClass: AnyClass
    )
    -> ObjCSelfAwareSwizzle
{
    let className = class_getName(aClass)
    let metaClass = objc_getMetaClass(className)
    return swizzleInstanceMethodSelector(
        aSelector,
        with: anotherSelector,
        on: metaClass as! AnyClass
    )
}

public func swizzleInstanceMethodSelector(
    aSelector: Selector,
    with anotherSelector: Selector,
    on aClass: AnyClass
    )
    -> ObjCSelfAwareSwizzle
{
    return ObjCSelfAwareSwizzle(
        class: aClass,
        originalSelector: aSelector,
        swizzledSelector: anotherSelector
    )
}

//MARK: Inter-Implementation Swizzle
public func swizzleClassMethodSelector<F>(
    aSelector: Selector,
    on aClass: AnyClass,
    original: UnsafeMutablePointer<F>,
    swizzled: F
    )
    -> ObjCSelfAwareSwizzle
{
    let className = class_getName(aClass)
    let metaClass = objc_getMetaClass(className)
    return swizzleInstanceMethodSelector(
        aSelector,
        on: metaClass as! AnyClass,
        original: original,
        swizzled: swizzled
    )
}

public func swizzleInstanceMethodSelector<F>(
    aSelector: Selector,
    on aClass: AnyClass,
    original originalPtr: UnsafeMutablePointer<F>,
    swizzled: F
    )
    -> ObjCSelfAwareSwizzle
{
    return ObjCSelfAwareSwizzle(
        class: aClass,
        selector: aSelector,
        originalPtr: unsafeBitCast(originalPtr, UnsafeMutablePointer<IMP>.self),
        swizzled: unsafeBitCast(swizzled, IMP.self)
    )
}


//MARK: Recipe Swizzle
public func swizzleClassMethodSelector<R: ObjCSelfAwareSwizzleRecipeType>(
    aSelector: Selector,
    on aClass: AnyClass,
    recipe: R.Type
    )
    -> ObjCSelfAwareSwizzle
{
    let className = class_getName(aClass)
    let metaClass = objc_getMetaClass(className)
    return swizzleInstanceMethodSelector(
        aSelector,
        on: metaClass as! AnyClass,
        recipe: recipe
    )
}

public func swizzleInstanceMethodSelector<R: ObjCSelfAwareSwizzleRecipeType>(
    aSelector: Selector,
    on aClass: AnyClass,
    recipe: R.Type
    )
    -> ObjCSelfAwareSwizzle
{
    let originalPtr = withUnsafePointer(&recipe.original) {$0}
    return ObjCSelfAwareSwizzle(
        class: aClass,
        selector: aSelector,
        originalPtr: unsafeBitCast(originalPtr, UnsafeMutablePointer<IMP>.self),
        swizzled: unsafeBitCast(recipe.swizzled, IMP.self)
    )
}

//MARK: Deprecated
@available(*, unavailable, renamed="swizzleClassMethodSelector")
public func withObjCSelfAwareSwizzleContext<F>(
    forClassMethodSelector aSelector: Selector,
    onClass aClass: AnyClass,
    original: UnsafeMutablePointer<F>,
    swizzled: F
    )
    -> ObjCSelfAwareSwizzle
{
    let className = class_getName(aClass)
    let metaClass = objc_getMetaClass(className)
    return swizzleInstanceMethodSelector(
        aSelector,
        on: metaClass as! AnyClass,
        original: original,
        swizzled: swizzled
    )
}

@available(*, unavailable, renamed="swizzleInstanceMethodSelector")
public func withObjCSelfAwareSwizzleContext<F>(
    forInstanceMethodSelector aSelector: Selector,
    onClass aClass: AnyClass,
    original originalPtr:  UnsafeMutablePointer<F>,
    swizzled: F
    )
    -> ObjCSelfAwareSwizzle
{
    return ObjCSelfAwareSwizzle(
        class: aClass,
        selector: aSelector,
        originalPtr: unsafeBitCast(originalPtr, UnsafeMutablePointer<IMP>.self),
        swizzled: unsafeBitCast(swizzled, IMP.self)
    )
}

