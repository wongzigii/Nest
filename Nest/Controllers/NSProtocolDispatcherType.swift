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
By conforming `NSProtocolDispatcherType`, an object turned to be a proxy which
intercepts messages, which originally intended to send to the object itself, to
the last appended dispatching destination. If all the dispatching destination
are not able to respond the message, it will be finally intercepts to the object
itself. You are able to add dispatched protocols at runtime.

- Discussion: Where `NSProtocolDispatcherType` is different to
`NSProtocolInterceptor` is: 1) The role of receiver of `NSProtocolInterceptor`
is just itself; 2) `NSProtocolDispatcherType` is a pre-implemented protocol but
`NSProtocolInterceptor` is a class; 3) You are able to add dispatched protocols
to any object conforms to `NSProtocolDispatcherType` at runtime which 
`NSProtocolInterceptor` not.
*/
public protocol NSProtocolDispatcherType: NSObjectProtocol {
    
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
}

extension NSProtocolDispatcherType {
    /** Returns the object to which unrecognized messages should first be
    directed.
    
    - Descusstion: Your should call this method in your class'es
    forwardingTargetForSelector(:Selector)'s implementation. The reasons why you
    should do in this way are: 1) Protocol extension doesn't override existed
    implementation in any conformed type; 2) Extension shall always extend new
    members and never override existed members.
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
    respondsToSelector(:Selector)'s implementation. The reasons why you should
    do in this way are: 1) Protocol extension doesn't override existed
    implementation in any conformed type; 2) Extension shall always extend new
    members and never override existed members.
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
    /// Add a dispatched protocol
    public func addDispatchedProtocol(aProtocol: Protocol) {
        _dispatchedProtocols.addObject(aProtocol)
        if !class_conformsToProtocol(self.dynamicType, aProtocol) {
            class_addProtocol(self.dynamicType, aProtocol)
        }
    }
    
    /// Add a variable length sort of dispatched protocols
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
        let nonretainedWrapper = NSValue(nonretainedObject: destination)
        _protocolDispatchingDestinations.append(nonretainedWrapper)
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
    
    /**
    - Discussion: Because Associated Object is a concept in Objective-C but not
    Swift and the `Weak` struct in SwiftExt is not convertible to AnyObject, the
    Objective-C native type - `NSValue` is required here to store nonretained
    objects.
    */
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