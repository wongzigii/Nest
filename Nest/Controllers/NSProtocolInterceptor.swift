//
//  NSProtocolInterpreter.swift
//  Nest
//
//  Created by Manfred Lau on 11/28/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation

/**
`NSProtocolInterceptor` is a proxy which intercepts messages to the middle man 
which originally intended to send to the receiver.

`NSProtocolInterceptor` is a class cluster which dynamically creates a class 
which conforms to the intercepted protocols at the runtime.
*/
public final class NSProtocolInterceptor: NSObject {
    /// Intercepted protocols
    private var _interceptedProtocols: [Protocol] = []
    public var interceptedProtocols: [Protocol] { return _interceptedProtocols }
    
    /// Messages receiver
    public weak var receiver: NSObjectProtocol?
    
    /// Messages middle man
    public weak var middleMan: NSObjectProtocol?
    
    private func doesSelectorBelongToAnyInterceptedProtocol(
        aSelector: Selector) -> Bool
    {
        for aProtocol in _interceptedProtocols
            where sel_belongsToProtocol(aSelector, aProtocol)
        {
            return true
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
    
    /// Use this method to create a protocol interceptor which intercepts
    /// a single Objecitve-C protocol
    public class func interceptorWithProtocol(aProtocol: Protocol)
        -> NSProtocolInterceptor
    {
        return interceptorWithProtocols([aProtocol])
    }
    
    /// Use this method to create a protocol interceptor which intercepts
    /// variant Objecitve-C protocols
    public class func interceptorWithProtocols(protocols: Protocol ...)
        -> NSProtocolInterceptor
    {
        return interceptorWithProtocols(protocols)
    }
    
    /// Use this method to create a protocol interceptor which intercepts
    /// an array of Objecitve-C protocols
    public class func interceptorWithProtocols(protocols: [Protocol])
        -> NSProtocolInterceptor
    {
        let protocolNames = protocols.map { NSStringFromProtocol($0) as String }
        let sortedProtocolNames = protocolNames.sort()
        let concatenatedName = "_".join(sortedProtocolNames)
        
        let theClass = concreteInterceptorClassWithProtocols(
            protocols,
            concatenatedName: concatenatedName,
            slat: nil)
        
        let protocolInterceptor = theClass.new()
        protocolInterceptor._interceptedProtocols = protocols
        
        return protocolInterceptor
    }
    
    private class func concreteInterceptorClassWithProtocols(
        protocols: [Protocol],
        concatenatedName: String,
        slat: Int?)
        -> NSProtocolInterceptor.Type
    {
        let basicClassName = "_" + NSStringFromClass(self)
            + "_" + concatenatedName
        let className = (slat == nil ?
            basicClassName :basicClassName + "_\(slat!)")
        
        let nextSlat = slat == nil ? 0 : (slat! + 1)
        
        if let theClass = NSClassFromString(className) {
            switch theClass {
            case let aProtocolInterceptorType as NSProtocolInterceptor.Type:
                let theClassConformsToAllProtocol: Bool = {
                    for eachProtocol in protocols
                        where !class_conformsToProtocol(
                            aProtocolInterceptorType,
                            eachProtocol)
                    {
                        return false
                    }
                    return true
                    }()
                
                if theClassConformsToAllProtocol {
                    return aProtocolInterceptorType
                } else {
                    return concreteInterceptorClassWithProtocols(protocols,
                        concatenatedName: concatenatedName,
                        slat: nextSlat)
                }
            default:
                return concreteInterceptorClassWithProtocols(protocols,
                    concatenatedName: concatenatedName,
                    slat: nextSlat)
            }
        } else {
            let theProtocolInterceptorType = objc_allocateClassPair(
                NSProtocolInterceptor.self,
                className,
                0)
                as! NSProtocolInterceptor.Type
            
            for eachProtocol in protocols {
                class_addProtocol(theProtocolInterceptorType, eachProtocol)
            }
            
            objc_registerClassPair(theProtocolInterceptorType)
            
            NSLog("class name: \(className)")
            NSLog("class: \(theProtocolInterceptorType)")
            NSLog("super class: \(theProtocolInterceptorType.superclass())")
            NSLog("class name from system: \(NSStringFromClass(theProtocolInterceptorType))")
            NSLog("class from systemname: \(NSClassFromString(NSStringFromClass(theProtocolInterceptorType)))")
            
            return theProtocolInterceptorType
        }
    }
}
