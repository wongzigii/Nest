//
//  ObjCSelfAwareSwizzleImplSource.swift
//  Nest
//
//  Created by Manfred on 2/21/16.
//
//

import Foundation
import ObjectiveC

internal enum ObjCSelfAwareSwizzleImplSource: Equatable {
    case impl(
        class: AnyClass,
        selector: ObjectiveC.Selector,
        originalImplPointer: UnsafeMutablePointer<IMP>,
        swizzledImpl: IMP
    )
    
    case selector(
        class: AnyClass,
        originalSelector: ObjectiveC.Selector,
        swizzledSelector: ObjectiveC.Selector
    )
}

internal func == (
    lhs: ObjCSelfAwareSwizzleImplSource,
    rhs: ObjCSelfAwareSwizzleImplSource
    )
    -> Bool
{
    switch (lhs, rhs) {
    case let (
        .impl(lhsClass, lhsSel, lhsOriginalImplPtr, lhsSwizzledImpl),
        .impl(rhsClass, rhsSel, rhsOriginalImplPtr, rhsSwizzledImpl)
        ):
        
        return lhsClass === rhsClass
            && lhsSel == rhsSel
            && lhsOriginalImplPtr == rhsOriginalImplPtr
            && lhsSwizzledImpl == rhsSwizzledImpl
        
    case let (
        .selector(lhsClass, lhsOriginalSelector, lhsSwizzledSelector),
        .selector(rhsClass, rhsOriginalSelector, rhsSwizzledSelector)
        ):
        
        return lhsClass === rhsClass
            && lhsOriginalSelector == rhsOriginalSelector
            && lhsSwizzledSelector == rhsSwizzledSelector
    default:
        return false
    }
}
