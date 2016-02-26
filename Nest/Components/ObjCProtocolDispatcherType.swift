//
//  ObjCProtocolDispatcherType.swift
//  Nest
//
//  Created by Manfred on 9/22/15.
//
//

import SwiftExt
import Foundation

/**
 By conforming `ObjCProtocolDispatcherType`, an object gained the ability to 
 turn to be a proxy which intercepts messages which originally intended to send 
 to the object itself to the last appended dispatching destination. If all the
 dispatching destinations are not able to respond the message, it will finally 
 be dispatched back to the object itself. You are able to add dispatched 
 protocols during the object's lifetime.

 - Discussion: Where the `ObjCProtocolDispatcherType` is different from 
 `ObjCProtocolInterceptor` are:
 
 1. `ObjCProtocolDispatcherType` is a pre-implemented protocol but
 `ObjCProtocolInterceptor` is a class;
 
 2. The role of `ObjCProtocolInterceptor`'s receiver is just the receiver itself
 but `ObjCProtocolDispatcherType` could have multiple fallback-able receivers;
 
 3. You are allowed to add dispatched protocols to any object conforms to
 `ObjCProtocolDispatcherType` at runtime which `ObjCProtocolInterceptor` 
 doesn't.
*/
public protocol ObjCProtocolDispatcherType: NSObjectProtocol {
    
}

extension ObjCProtocolDispatcherType {
    /// Returns dispatched protocols
    public var dispatchedProtocols: [Protocol] {
        return _dispatchedProtocols.allObjects as! [Protocol]
    }
    
    /// Returns registered protocol dispatching destination
    public var dispatchDestinations: [NSObjectProtocol] {
        return _dispatchDestinations.allObjects
            as! [NSObjectProtocol]
    }
}

extension ObjCProtocolDispatcherType {
    /** Returns the object to which unrecognized messages should first be
     directed.
    
    - Descusstion: Your should call this method in your class'es
     forwardingTargetForSelector(:)'s implementation. The reasons why you should
     do in this way are: 1) Protocol extension doesn't override existed 
     implementation in any conformed type; 2) Extension shall always extend new
     members and never override existed members.
    */
    public func nest_forwardingTargetForSelector(aSelector: Selector)
        -> AnyObject?
    {
        let needsDispatch = doesSelectorBelongToAnyDispatchedProtocol(aSelector)
        
        let selectorString = NSStringFromSelector(aSelector)
        
        if needsDispatch {
            invalidateDispatchTableIfNeeded()
            
            if let destination = dispatchTable.objectForKey(selectorString) {
                return destination
            }
            
            for eachDestination in
                _dispatchDestinations.objectEnumerator()
            {
                if eachDestination.respondsToSelector(aSelector) == true {
                    dispatchTable.setObject(eachDestination,
                        forKey: NSStringFromSelector(aSelector))
                    return eachDestination
                }
            }
        }
        
        
        if class_respondsToSelector(self.dynamicType, aSelector) {
            if needsDispatch {
                dispatchTable.setObject(self, forKey: selectorString)
            }
            return self
        }
        
        if needsDispatch {
            dispatchTable.setObject(nil, forKey: selectorString)
        }
        return nil
    }
    
    /** Returns a Boolean value that indicates whether the receiver implements
     or inherits a method that can respond to a specified message.
     
     - Descusstion: Your should call this method in your class'es 
     respondsToSelector(:)'s implementation. The reasons why you should do in
     this way are: 1) Protocol extension doesn't override existed implementation 
     in any conformed type; 2) Extension shall always extend new members and
     never override existed members.
     */
    public func nest_respondsToSelector(aSelector: Selector) -> Bool {
        let needsDispatch = doesSelectorBelongToAnyDispatchedProtocol(aSelector)
        
        let selectorString = NSStringFromSelector(aSelector)
        
        if needsDispatch {
            invalidateDispatchTableIfNeeded()
            
            let selectorString = NSStringFromSelector(aSelector)
            
            if dispatchTable.objectForKey(selectorString) != nil {
                return true
            }
            
            for eachDestination in
                _dispatchDestinations.objectEnumerator()
            {
                if eachDestination.respondsToSelector(aSelector) == true {
                    dispatchTable.setObject(eachDestination,
                        forKey: selectorString)
                    return true
                }
            }
        }
        
        if class_respondsToSelector(self.dynamicType, aSelector) {
            if needsDispatch {
                dispatchTable.setObject(self, forKey: selectorString)
            }
            return true
        }
        
        if needsDispatch {
            dispatchTable.setObject(nil, forKey: selectorString)
        }
        return false
    }
}

extension ObjCProtocolDispatcherType {
    /// Add a dispatched protocol
    public func addDispatchedProtocol(aProtocol: Protocol) {
        if !_dispatchedProtocols.containsObject(aProtocol) {
            _dispatchedProtocols.addObject(aProtocol)
        }
        if !class_conformsToProtocol(self.dynamicType, aProtocol) {
            class_addProtocol(self.dynamicType, aProtocol)
        }
    }
    
    /// Add a variable length sort of dispatched protocols
    public func addDispatchedProtocols(protocols: Protocol...) {
        for eachProtocol in protocols {
            if !_dispatchedProtocols.containsObject(eachProtocol) {
                _dispatchedProtocols.addObject(eachProtocol)
            }
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    /// Add an array of dispatched protocols
    public func addDispatchedProtocols(protocols: [Protocol]) {
        for eachProtocol in protocols {
            if !_dispatchedProtocols.containsObject(eachProtocol) {
                _dispatchedProtocols.addObject(eachProtocol)
            }
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    /// Append a protocol dispatch destination. The last appended should be
    /// dispatched firstly.
    public func appendProtocolDispatchDestination(
        destination: NSObjectProtocol
        )
    {
        _dispatchDestinations.addObject(destination)
        needsInvalidateDispatchTable = true
    }
}

private var dispatchedProtocolsKey = "_dispatchedProtocols"
private var dispatchDestinationsKey = "_dispatchDestinations"
private var dispatchTableKey = "messageDispatchTable"
private var needsInvalidateDispatchTableKey = "needsInvalidateDispatchTable"

extension ObjCProtocolDispatcherType {
    private var needsInvalidateDispatchTable: Bool {
        get {
            if let value = objc_getAssociatedObject(
                self,
                &needsInvalidateDispatchTableKey
                )
                as? Bool
            {
                return value
            } else {
                return false
            }
        }
        set {
            let oldValue = needsInvalidateDispatchTable
            
            if oldValue != newValue {
                objc_setAssociatedObject(
                    self,
                    &needsInvalidateDispatchTableKey,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                
                if newValue {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        () -> Void in
                        self.invalidateDispatchTableIfNeeded()
                    }
                }
            }
            
        }
    }
    
    private var dispatchTable: NSMapTable {
        get {
            if let value = objc_getAssociatedObject(
                self,
                &dispatchTableKey
                )
                as? NSMapTable
            {
                return value
            } else {
                let initialValue = NSMapTable.strongToWeakObjectsMapTable()
                objc_setAssociatedObject(self,
                    &dispatchTableKey,
                    initialValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return initialValue
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &dispatchTableKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    private func invalidateDispatchTableIfNeeded() {
        if needsInvalidateDispatchTable {
            if dispatchTable.count > 0 {
                dispatchTable.removeAllObjects()
            }
            needsInvalidateDispatchTable = false
        }
    }
    
    private var _dispatchedProtocols: NSHashTable {
        get {
            if let protocols = objc_getAssociatedObject(
                self,
                &dispatchedProtocolsKey
                )
                as? NSHashTable
            {
                return protocols
            } else {
                let initialValue = NSHashTable()
                objc_setAssociatedObject(
                    self,
                    &dispatchedProtocolsKey,
                    initialValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return initialValue
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &dispatchedProtocolsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    private var _dispatchDestinations: NSHashTable {
        get {
            if let destinations = objc_getAssociatedObject(
                self,
                &dispatchDestinationsKey
                )
                as? NSHashTable
            {
                return destinations
            } else {
                let initialValue = NSHashTable.weakObjectsHashTable()
                objc_setAssociatedObject(
                    self,
                    &dispatchDestinationsKey,
                    initialValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return initialValue
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &dispatchDestinationsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
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