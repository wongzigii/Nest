//
//  ObjCSelfAwareSwizzleRecipe.swift
//  Nest
//
//  Created by Manfred on 2/21/16.
//
//

public protocol ObjCSelfAwareSwizzleRecipe {
    associatedtype FunctionPointer
    static var original: FunctionPointer! { get set }
    static var swizzled: FunctionPointer { get }
}
