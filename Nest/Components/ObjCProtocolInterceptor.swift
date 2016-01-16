//
//  ObjCProtocolInterceptor.swift
//  Nest
//
//  Created by Manfred Lau on 11/28/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation
import SwiftExt

/** `ObjCProtocolInterceptor` is a proxy which intercepts messages to the middle
 man which originally intended to be sent to the receiver.
 
 - Discussion: `ObjCProtocolInterceptor` is a class cluster which dynamically
 subclasses itself to conform to the intercepted protocols at the runtime.
 */
public final class ObjCProtocolInterceptor: NSObject {
    /// Returns the intercepted protocols.
    public var interceptedProtocols: [Protocol] { return _interceptedProtocols }
    private var _interceptedProtocols: [Protocol] = []
    
    /// The receiver receives messages.
    public weak var receiver: NSObject?
    
    /// The middle men intercepts messages. The last middle appended man 
    /// receives messages firstly.
    private var _middleMen: [Weak<NSObject>] = []
    public var middleMen: [NSObject] {
        return _middleMen.flatMap {$0.value}
    }
    
    public func addMiddleMan(middleMan: NSObject) {
        _middleMen.append(weakify(middleMan))
    }
    
    public func removeMiddleMan(middleMan: NSObject) -> NSObject? {
        if let index = _middleMen.indexOf(weakify(middleMan)) {
            return _middleMen.removeAtIndex(index).value
        }
        return nil
    }
    
    public func containsMiddleMan(middleMan: NSObject) -> Bool {
        for each in _middleMen where each.value === middleMan { return true }
        return false
    }
    
    private func doesSelectorBelongToAnyInterceptedProtocol(aSelector: Selector)
        -> Bool
    {
        for aProtocol in _interceptedProtocols
            where sel_belongsToProtocol(aSelector, aProtocol)
        {
            return true
        }
        return false
    }
    
    /// Returns the object to which unrecognized messages should first be 
    /// directed.
    public override func forwardingTargetForSelector(aSelector: Selector)
        -> AnyObject?
    {
        var emptyMiddleManWrappersIndices = [Int]()
        
        defer {
            _middleMen.removeIndicesInPlace(emptyMiddleManWrappersIndices)
        }
        
        for (index, middleManWrapper) in _middleMen.reverse().enumerate() {
            if middleManWrapper.value?.respondsToSelector(aSelector) == true &&
                doesSelectorBelongToAnyInterceptedProtocol(aSelector)
            {
                return middleManWrapper.value
            } else if middleManWrapper.value == nil {
                emptyMiddleManWrappersIndices.append(index)
            }
        }
        
        if receiver?.respondsToSelector(aSelector) == true {
            return receiver
        }
        
        return super.forwardingTargetForSelector(aSelector)
    }
    
    /// Returns a Boolean value that indicates whether the receiver implements 
    /// or inherits a method that can respond to a specified message.
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        var emptyMiddleManWrappersIndices = [Int]()
        
        defer {
            _middleMen.removeIndicesInPlace(emptyMiddleManWrappersIndices)
        }
        
        for (index, eachMiddleMan) in _middleMen.reverse().enumerate() {
            if eachMiddleMan.value?.respondsToSelector(aSelector) == true &&
                doesSelectorBelongToAnyInterceptedProtocol(aSelector)
            {
                return true
            } else if eachMiddleMan.value == nil {
                emptyMiddleManWrappersIndices.append(index)
            }
        }
        
        if receiver?.respondsToSelector(aSelector) == true {
            return true
        }
        
        return super.respondsToSelector(aSelector)
    }
    
    /**
     Creates a protocol interceptor which intercepts a single Objecitve-C
     protocol.
     
     - Parameter     protocols:  An Objective-C protocol, such as
     UITableViewDelegate.self.
    */
    public class func againstProtocol(aProtocol: Protocol)
        -> ObjCProtocolInterceptor
    {
        return againstProtocols([aProtocol])
    }
    
    /**
     Creates a protocol interceptor which intercepts a variable-length sort of
     Objecitve-C protocols.
     
     - Parameter     protocols:  A variable length sort of Objective-C protocol,
     such as UITableViewDelegate.self.
    */
    public class func againstProtocols(protocols: Protocol ...)
        -> ObjCProtocolInterceptor
    {
        return againstProtocols(protocols)
    }
    
    /**
     Creates a protocol interceptor which intercepts an array of Objecitve-C
     protocols.
     
     - Parameter     protocols:  An array of Objective-C protocols, such as
     [UITableViewDelegate.self].
    */
    public class func againstProtocols(protocols: [Protocol])
        -> ObjCProtocolInterceptor
    {
        let protocolNames = protocols.map { NSStringFromProtocol($0) }
        let sortedProtocolNames = protocolNames.sort()
        let concatenatedProtocolsName = sortedProtocolNames
            .joinWithSeparator(",")
        
        let theConcreteClass = concreteClassWithProtocols(protocols,
            concatenatedProtocolsName: concatenatedProtocolsName)
        
        let protocolInterceptor = theConcreteClass.init()
            as! ObjCProtocolInterceptor
        protocolInterceptor._interceptedProtocols = protocols
        
        return protocolInterceptor
    }
    
    /**
    Returns a subclass of `ObjCProtocolInterceptor` which conforms to specified
     protocols.
     
     - Parameter     protocols:                 An array of Objective-C 
     protocols. The subclass returned from this function will conform to these
     protocols.
     
     - Parameter     concatenatedProtocolsName: A string which came from
     concatenating names of `protocols`.
     
     - Parameter     salt:                      A UInt number appended to the
     class name which used for distinguishing the class name itself from the
     duplicated.
     
     - Discussion: The return value type of this function can only be
     `NSObject.Type`, because if you return with `ObjCProtocolInterceptor.Type`,
     you can only init the returned class to be a `ObjCProtocolInterceptor` but
     not its subclass.
    */
    private class func concreteClassWithProtocols(protocols: [Protocol],
        concatenatedProtocolsName: String,
        salt: UInt? = nil)
        -> NSObject.Type
    {
        let className: String = {
            let basicClassName = NSStringFromClass(ObjCProtocolInterceptor.self)
                + "_"
                + concatenatedProtocolsName
            
            if let salt = salt { return basicClassName + "_\(salt)" }
                else { return basicClassName }
        }()
        
        let nextSalt = salt.map {$0 + 1}
        
        if let theClass = NSClassFromString(className) {
            switch theClass {
            case let anInterceptorClass as ObjCProtocolInterceptor.Type:
                let isClassConformsToAllProtocols: Bool = {
                    // Check if the found class conforms to the protocols
                    for eachProtocol in protocols
                        where !class_conformsToProtocol(anInterceptorClass,
                            eachProtocol)
                    {
                        return false
                    }
                    return true
                    }()
                
                if isClassConformsToAllProtocols {
                    return anInterceptorClass
                } else {
                    return concreteClassWithProtocols(protocols,
                        concatenatedProtocolsName: concatenatedProtocolsName,
                        salt: nextSalt)
                }
            default:
                return concreteClassWithProtocols(protocols,
                    concatenatedProtocolsName: concatenatedProtocolsName,
                    salt: nextSalt)
            }
        } else {
            let subclass = objc_allocateClassPair(ObjCProtocolInterceptor.self,
                className,
                0)
                as! NSObject.Type
            
            for eachProtocol in protocols {
                class_addProtocol(subclass, eachProtocol)
            }
            
            objc_registerClassPair(subclass)
            
            return subclass
        }
    }
}
