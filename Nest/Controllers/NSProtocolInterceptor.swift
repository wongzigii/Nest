//
//  NSProtocolInterpreter.swift
//  Nest
//
//  Created by Manfred Lau on 11/28/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation

public final class NSProtocolInterceptor: NSObject, NSCoding {
    private struct CodingKeys {
        static let interceptedProcotols = "interceptedProtocols"
        static let receiver = "receiver"
        static let middleMan = "middleMan"
    }
    
    private var _interceptedProtocols: [Protocol]
    public var interceptedProtocols: [Protocol] {
        return _interceptedProtocols
    }
    
    public weak var receiver: NSObjectProtocol?
    public weak var middleMan: NSObjectProtocol?
    
    public init?(coder aDecoder: NSCoder) {
        if aDecoder.containsValueForKey(CodingKeys.interceptedProcotols) {
            _interceptedProtocols =
                aDecoder.decodeObjectForKey(
                    CodingKeys.interceptedProcotols) as! [Protocol]
        } else {
            _interceptedProtocols = []
        }
        
        if aDecoder.containsValueForKey(CodingKeys.receiver) {
            receiver = aDecoder.decodeObjectForKey(
                CodingKeys.receiver) as? NSObject
        }
        
        if aDecoder.containsValueForKey(CodingKeys.middleMan) {
            middleMan = aDecoder.decodeObjectForKey(
                CodingKeys.middleMan) as? NSObject
        }
        
        for eachProtocol in _interceptedProtocols {
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(interceptedProtocols,
            forKey: CodingKeys.interceptedProcotols)
        aCoder.encodeObject(receiver,
            forKey: CodingKeys.interceptedProcotols)
        aCoder.encodeObject(middleMan,
            forKey: CodingKeys.interceptedProcotols)
    }
    
    public init(aProtocol: Protocol) {
        _interceptedProtocols = [aProtocol]
        super.init()
        if !class_conformsToProtocol(self.dynamicType, aProtocol) {
            class_addProtocol(self.dynamicType, aProtocol)
        }
    }
    
    public init(protocols: [Protocol]) {
        _interceptedProtocols = protocols
        super.init()
        for eachProtocol in protocols {
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    public init(protocols: Protocol ...) {
        _interceptedProtocols = protocols
        super.init()
        for eachProtocol in protocols {
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    private func doesSelectorBelongToAnyInterceptedProtocol(
        aSelector: Selector) -> Bool
    {
        for aProtocol in interceptedProtocols {
            return sel_belongsToProtocol(aSelector, aProtocol)
        }
        return false
    }
    
    public override func forwardingTargetForSelector(aSelector: Selector)
        -> AnyObject?
    {
        if middleMan?.respondsToSelector(aSelector) == true &&
            doesSelectorBelongToAnyInterceptedProtocol(aSelector)
        {
            return middleMan
        }
        
        if receiver?.respondsToSelector(aSelector) == true {
            return receiver
        }
        
        return super.forwardingTargetForSelector(aSelector)
    }
    
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        if middleMan?.respondsToSelector(aSelector) == true &&
            doesSelectorBelongToAnyInterceptedProtocol(aSelector)
        {
            return true
        }
        
        if receiver?.respondsToSelector(aSelector) == true {
            return true
        }
        
        return super.respondsToSelector(aSelector)
    }
}
