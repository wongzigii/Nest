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
public func sel_belongsToProtocol(aSelector: Selector,
    _ aProtocol: Protocol) -> Bool
{
    for optionBits: UInt in 0..<(1 << 2) {
        let isRequired = optionBits & 1 != 0
        let isInstance = !(optionBits & (1 << 1) != 0)
        
        let methodDescription = protocol_getMethodDescription(aProtocol,
            aSelector, isRequired, isInstance)
        
        if (!methodDescription.name.description.isEmpty ||
            methodDescription.types.memory != 0)
        {
            return true
        }
    }
    return false
}