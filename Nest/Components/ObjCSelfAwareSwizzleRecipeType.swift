//
//  ObjCSelfAwareSwizzleRecipeType.swift
//  Nest
//
//  Created by Manfred on 2/21/16.
//
//

import Foundation

public protocol ObjCSelfAwareSwizzleRecipeType {
    associatedtype FunctionPointer
    static var original: FunctionPointer! { get set }
    static var swizzled: FunctionPointer { get }
}
