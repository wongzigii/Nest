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

//MARK: Selector-Wise Swizzle
public func swizzle(
    classSelector aSelector: Selector,
    with anotherSelector: Selector,
    on aClass: AnyClass
    )
    -> ObjCSelfAwareSwizzle
{
    let className = class_getName(aClass)
    let metaClass = objc_getMetaClass(className)
    return swizzle(
        instanceSelector: aSelector,
        with: anotherSelector,
        on: metaClass as! AnyClass
    )
}

public func swizzle(
    instanceSelector aSelector: Selector,
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

//MARK: Implementation-Wise Swizzle
public func swizzle<F>(
    classSelector aSelector: Selector,
    on aClass: AnyClass,
    original: UnsafeMutablePointer<F>,
    swizzled: F
    )
    -> ObjCSelfAwareSwizzle
{
    let className = class_getName(aClass)
    let metaClass = objc_getMetaClass(className)
    return swizzle(
        instanceSelector: aSelector,
        on: metaClass as! AnyClass,
        original: original,
        swizzled: swizzled
    )
}

public func swizzle<F>(
    instanceSelector aSelector: Selector,
    on aClass: AnyClass,
    original originalPtr: UnsafeMutablePointer<F>,
    swizzled: F
    )
    -> ObjCSelfAwareSwizzle
{
    return ObjCSelfAwareSwizzle(
        class: aClass,
        selector: aSelector,
        originalPtr: unsafeBitCast(originalPtr, to: UnsafeMutablePointer<IMP>.self),
        swizzled: unsafeBitCast(swizzled, to: IMP.self)
    )
}

//MARK: Recipe Swizzle
public func swizzle<R: ObjCSelfAwareSwizzleRecipe>(
    classSelector aSelector: Selector,
    on aClass: AnyClass,
    recipe: R.Type
    )
    -> ObjCSelfAwareSwizzle
{
    let className = class_getName(aClass)
    let metaClass = objc_getMetaClass(className)
    return swizzle(
        instanceSelector: aSelector,
        on: metaClass as! AnyClass,
        recipe: recipe
    )
}

public func swizzle<R: ObjCSelfAwareSwizzleRecipe>(
    instanceSelector aSelector: Selector,
    on aClass: AnyClass,
    recipe: R.Type
    )
    -> ObjCSelfAwareSwizzle
{
    let originalPtr = withUnsafePointer(to: &recipe.original) {$0}
    return ObjCSelfAwareSwizzle(
        class: aClass,
        selector: aSelector,
        originalPtr: unsafeBitCast(originalPtr, to: UnsafeMutablePointer<IMP>.self),
        swizzled: unsafeBitCast(recipe.swizzled, to: IMP.self)
    )
}
