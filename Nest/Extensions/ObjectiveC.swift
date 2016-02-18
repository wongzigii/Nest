//
//  ObjectiveC.swift
//  Nest
//
//  Created by Manfred Lau on 12/13/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation

/**
Returns true when the given selector belongs to the given protocol.
*/
public func sel_belongsToProtocol(
    aSelector: Selector,
    _ aProtocol: Protocol
    )
    -> Bool
{
    for optionBits: UInt in 0..<(1 << 2) {
        let isRequired = optionBits & 1 != 0
        let isInstance = !(optionBits & (1 << 1) != 0)
        
        let methodDescription = protocol_getMethodDescription(
            aProtocol,
            aSelector,
            isRequired,
            isInstance
        )
        
        if !objc_method_description_isEmpty(methodDescription) {
            return true
        }
    }
    return false
}

public func objc_method_description_isEmpty(
    var methodDescription: objc_method_description
    )
    -> Bool
{
    let ptr = withUnsafePointer(&methodDescription) { UnsafePointer<Int8>($0) }
    for offset in 0..<sizeof(objc_method_description) {
        if ptr[offset] != 0 {
            return false
        }
    }
    return true
}

public func property_isEmpty(
    var property: objc_property_t
    )
    -> Bool
{
    let ptr = withUnsafePointer(&property) { UnsafePointer<Int8>($0) }
    for offset in 0..<sizeof(objc_property_t) {
        if ptr[offset] != 0 {
            return false
        }
    }
    return true
}

public func sel_isEmpty(
    var selector: Selector
    )
    -> Bool
{
    let ptr = withUnsafePointer(&selector) { UnsafePointer<Int8>($0) }
    for offset in 0..<sizeof(Selector) {
        if ptr[offset] != 0 {
            return false
        }
    }
    return true
}

