//
//  NSProtocolDispatcherType.swift
//  Nest
//
//  Created by Manfred on 9/22/15.
//
//

import SwiftExt
import Foundation

/**
`NSProtocolDispatcherType` is a proxy which intercepts messages to the 
last appended dispatching destination which originally intended to send to 
itself. If all the dispatching destination are not able to respond the message,
it will be finally intercepts to the `NSProtocolDispatcherType` itself. You are
able to add dispatched protocols at the runtime.

- Discussion: `NSProtocolDispatcherType` is different to 
`NSProtocolInterceptor`, where the role of receiver of `NSProtocolInterceptor`
is just itself.
*/
public protocol NSProtocolDispatcherType: NSObjectProtocol {
    
}

extension NSProtocolDispatcherType {
    /** Returns the object to which unrecognized messages should first be
    directed.
    
    - Descusstion: Your should call this method in your class'es
    forwardingTargetForSelector(:Selector)'s implementation. The reason why you
    should do in this way is: 1) Protocol extension doesn't override existed
    implementation in any conformed type; 2) Extension shall always extend and
    never override.
    */
    public func nest_forwardingTargetForSelector(aSelector: Selector)
        -> AnyObject?
    {
        var nilIndices = [Int]()
        
        defer {
            _protocolDispatchingDestinations.removeIndicesInPlace(nilIndices)
        }
        
        for (index, eachWrapper) in
            _protocolDispatchingDestinations.reverse().enumerate()
        {
            let eachDestination = eachWrapper.nonretainedObjectValue
                as? NSObjectProtocol
            if eachDestination?.respondsToSelector(aSelector) == true &&
                doesSelectorBelongToAnyDispatchedProtocol(aSelector)
            {
                return eachDestination
            } else if eachDestination == nil {
                nilIndices.append(index)
            }
        }
        
        if class_respondsToSelector(self.dynamicType, aSelector) {
            return self
        }
        
        return nil
    }
    
    /** Returns a Boolean value that indicates whether the receiver implements
    or inherits a method that can respond to a specified message.
    
    - Descusstion: Your should call this method in your class'es
    respondsToSelector(:Selector)'s implementation. The reason why you should
    do in this way are: 1) Protocol extension doesn't override existed
    implementation in any conformed type; 2) Extension shall always extend and
    never override.
    */
    public func nest_respondsToSelector(aSelector: Selector) -> Bool {
        var nilIndices = [Int]()
        
        defer {
            _protocolDispatchingDestinations.removeIndicesInPlace(nilIndices)
        }
        
        for (index, eachWrapper) in
            _protocolDispatchingDestinations.reverse().enumerate()
        {
            let eachDestination = eachWrapper.nonretainedObjectValue
                as? NSObjectProtocol
            if eachDestination?.respondsToSelector(aSelector) == true &&
                doesSelectorBelongToAnyDispatchedProtocol(aSelector)
            {
                return true
            } else if eachDestination == nil {
                nilIndices.append(index)
            }
        }
        
        return class_respondsToSelector(self.dynamicType, aSelector)
    }
}

extension NSProtocolDispatcherType {
    /// Returns dispatched protocols
    public var dispatchedProtocols: [Protocol] {
        return _dispatchedProtocols.allObjects as! [Protocol]
    }
    
    /// Returns registered protocol dispatching destination
    public var protocolDispatchingDestinations: [NSObjectProtocol] {
        return _protocolDispatchingDestinations.flatMap
            {$0.nonretainedObjectValue as? NSObjectProtocol}
    }
    
    /// Add a dispatched protocol
    public func addDispatchedProtocol(aProtocol: Protocol) {
        _dispatchedProtocols.addObject(aProtocol)
        if !class_conformsToProtocol(self.dynamicType, aProtocol) {
            class_addProtocol(self.dynamicType, aProtocol)
        }
    }
    
    /// Add a variant sort of dispatched protocols
    public func addDispatchedProtocols(protocols: Protocol...) {
        for eachProtocol in protocols {
            _dispatchedProtocols.addObject(eachProtocol)
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    /// Add an array of dispatched protocols
    public func addDispatchedProtocols(protocols: [Protocol]) {
        for eachProtocol in protocols {
            _dispatchedProtocols.addObject(eachProtocol)
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    /// Append a protocol dispatch destination. The last appended should be
    /// dispatched firstly.
    public func appendProtocolDispatchDestination(
        destination: NSObjectProtocol)
    {
        let nonRetainedWrapper = NSValue(nonretainedObject: destination)
        _protocolDispatchingDestinations.append(nonRetainedWrapper)
    }
}

private var dispatchedProtocolsKey = "_dispatchedProtocols"
private var _protocolDispatchingDestinationsProtocolsKey
= "_protocolDispatchingDestinations"

extension NSProtocolDispatcherType {
    private var _dispatchedProtocols: NSMutableSet {
        get {
            if let protocols = objc_getAssociatedObject(self,
                &dispatchedProtocolsKey)
                as? NSMutableSet
            {
                return protocols
            } else {
                let initialValue = NSMutableSet()
                objc_setAssociatedObject(self,
                    &dispatchedProtocolsKey,
                    initialValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return initialValue
            }
        }
        set {
            objc_setAssociatedObject(self,
                &dispatchedProtocolsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var _protocolDispatchingDestinations: [NSValue] {
        get {
            if let destinations = objc_getAssociatedObject(self,
                &_protocolDispatchingDestinationsProtocolsKey)
                as? [NSValue]
            {
                return destinations
            } else {
                let initialValue = [NSValue]()
                objc_setAssociatedObject(self,
                    &_protocolDispatchingDestinationsProtocolsKey,
                    initialValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return initialValue
            }
        }
        set {
            objc_setAssociatedObject(self,
                &_protocolDispatchingDestinationsProtocolsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func doesSelectorBelongToAnyDispatchedProtocol(
        aSelector: Selector)
        -> Bool
    {
        for eachProtocol in dispatchedProtocols
            where sel_belongsToProtocol(aSelector, eachProtocol)
        {
            return true
        }
        return false
    }
}