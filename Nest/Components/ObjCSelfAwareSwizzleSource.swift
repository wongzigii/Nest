//
//  ObjCSelfAwareSwizzleSource.swift
//  Nest
//
//  Created by Manfred on 2/21/16.
//
//

import Foundation
import ObjectiveC

internal enum ObjCSelfAwareSwizzleSource: Equatable {
    case Implementation(
        class: AnyClass,
        selector: ObjectiveC.Selector,
        originalImplPointer: UnsafeMutablePointer<IMP>,
        swizzledImpl: IMP
    )
    
    case Selector(
        class: AnyClass,
        originalSelector: ObjectiveC.Selector,
        swizzledSelector: ObjectiveC.Selector
    )
}

internal func == (
    lhs: ObjCSelfAwareSwizzleSource,
    rhs: ObjCSelfAwareSwizzleSource
    )
    -> Bool
{
    switch (lhs, rhs) {
    case let (
        .Implementation(
            lhsClass,
            lhsSelector,
            lhsOriginalImplPointer,
            lhsSwizzledImpl
        ),
        .Implementation(
            rhsClass,
            rhsSelector,
            rhsOriginalImplPointer,
            rhsSwizzledImpl
        )
        ):
        
        return lhsClass === rhsClass
            && lhsSelector == rhsSelector
            && lhsOriginalImplPointer == rhsOriginalImplPointer
            && lhsSwizzledImpl == rhsSwizzledImpl
        
    case let (
        .Selector(lhsClass, lhsOriginalSelector, lhsSwizzledSelector),
        .Selector(rhsClass, rhsOriginalSelector, rhsSwizzledSelector)
        ):
        
        return lhsClass === rhsClass
            && lhsOriginalSelector == rhsOriginalSelector
            && lhsSwizzledSelector == rhsSwizzledSelector
    default:
        return false
    }
}
