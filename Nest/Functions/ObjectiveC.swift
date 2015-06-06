//
//  ObjectiveC.swift
//  Nest
//
//  Created by Manfred Lau on 12/13/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation

public func sel_belongsToProtocol(aSelector: Selector, aProtocol: Protocol) -> Bool
{
    for optionBits: UInt in 0..<(1 << 2) {
        let isRequired = optionBits & 1 != 0
        let isInstance = !(optionBits & (1 << 1) != 0)
        
        let methodDescription = protocol_getMethodDescription(aProtocol, aSelector, isRequired, isInstance)
        
        return (!methodDescription.name.description.isEmpty || methodDescription.types.memory != 0)
    }
    return false
}

public func class_swizzleClass(aClass: AnyClass, selector: Selector, withImplementation: IMP, selectorPrefix: String) {
    let swizzlingSelector = Selector(selectorPrefix + selector.description)
    let swizzledMethod = class_getInstanceMethod(aClass, selector)
    
    let swizzledMethodTypeEncoding = method_getTypeEncoding(swizzledMethod)
    
    let isMethodAddedSuccessful = class_addMethod(aClass, swizzlingSelector, withImplementation, swizzledMethodTypeEncoding)
    
    if isMethodAddedSuccessful {
        let swizzlingMethod = class_getInstanceMethod(aClass, swizzlingSelector)
        method_exchangeImplementations(swizzledMethod, swizzlingMethod)
    } else {
        NSLog("WARNING: Swizzle \(swizzlingSelector) on \(aClass) with prefix \(selectorPrefix) failed. Method already exists.")
    }
}
