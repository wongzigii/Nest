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
        return _dispatchedProtocols.allObjects
    }
    
    /// Returns registered protocol dispatching destination
    public var dispatchDestinations: [NSObjectProtocol] {
        return _dispatchDestinations.allObjects
    }
}

extension ObjCProtocolDispatcherType {
    /** Returns the object to which unrecognized messages should first be
     directed.
    
    - Descusstion: Your should call this method in your class'es
     forwardingTarget(for:)'s implementation. The reasons why you should
     do in this way are: 1) Protocol extension doesn't override existed 
     implementation in any conformed type; 2) Extension shall always extend new
     members and never override existed members.
    */
    public func nest_forwardingTarget(for aSelector: Selector)
        -> AnyObject?
    {
        let needsDispatch = doesSelectorBelongToAnyDispatchedProtocol(aSelector)
        
        let selectorString = NSStringFromSelector(aSelector)
        
        if needsDispatch {
            invalidateDispatchTableIfNeeded()
            
            if let destination = dispatchTable.object(forKey: selectorString) {
                return destination
            }
            
            for eachDestination in
                _dispatchDestinations.objectEnumerator()
            {
                if eachDestination.responds(to: aSelector) == true {
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
     responds(to:)'s implementation. The reasons why you should do in
     this way are: 1) Protocol extension doesn't override existed implementation 
     in any conformed type; 2) Extension shall always extend new members and
     never override existed members.
     */
    public func nest_responds(to aSelector: Selector) -> Bool {
        let needsDispatch = doesSelectorBelongToAnyDispatchedProtocol(aSelector)
        
        let selectorString = NSStringFromSelector(aSelector)
        
        if needsDispatch {
            invalidateDispatchTableIfNeeded()
            
            let selectorString = NSStringFromSelector(aSelector)
            
            if dispatchTable.object(forKey: selectorString) != nil {
                return true
            }
            
            for eachDestination in
                _dispatchDestinations.objectEnumerator()
            {
                if eachDestination.responds(to: aSelector) == true {
                    dispatchTable.setObject(
                        eachDestination,
                        forKey: selectorString
                    )
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
    public func add(dispatchedProtocol aProtocol: Protocol) {
        if !_dispatchedProtocols.contains(aProtocol) {
            _dispatchedProtocols.add(aProtocol)
        }
        if !class_conformsToProtocol(self.dynamicType, aProtocol) {
            class_addProtocol(self.dynamicType, aProtocol)
        }
    }
    
    /// Add a variable length sort of dispatched protocols
    public func add(dispatchedProtocols protocols: Protocol...) {
        for eachProtocol in protocols {
            if !_dispatchedProtocols.contains(eachProtocol) {
                _dispatchedProtocols.add(eachProtocol)
            }
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    /// Add an array of dispatched protocols
    public func add(dispatchedProtocols protocols: [Protocol]) {
        for eachProtocol in protocols {
            if !_dispatchedProtocols.contains(eachProtocol) {
                _dispatchedProtocols.add(eachProtocol)
            }
            if !class_conformsToProtocol(self.dynamicType, eachProtocol) {
                class_addProtocol(self.dynamicType, eachProtocol)
            }
        }
    }
    
    /// Append a protocol dispatch destination. The last appended should be
    /// dispatched firstly.
    public func append(
        protocolDispatchDestination destination: NSObjectProtocol
        )
    {
        _dispatchDestinations.add(destination)
        needsInvalidateDispatchTable = true
    }
}

private var dispatchedProtocolsKey = "dispatchedProtocols"
private var dispatchDestinationsKey = "dispatchDestinations"
private var dispatchTableKey = "dispatchTable"
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
                    OperationQueue.main.addOperation {
                        () -> Void in
                        self.invalidateDispatchTableIfNeeded()
                    }
                }
            }
            
        }
    }
    
    private var dispatchTable: NSMapTable<NSString, AnyObject> {
        get {
            if let value = objc_getAssociatedObject(
                self,
                &dispatchTableKey
                )
                as? NSMapTable<NSString, AnyObject>
            {
                return value
            } else {
                let initialValue = NSMapTable<NSString, AnyObject>
                    .strongToWeakObjects()
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
    
    private var _dispatchedProtocols: NSHashTable<Protocol> {
        get {
            if let protocols = objc_getAssociatedObject(
                self,
                &dispatchTableKey
                )
                as? NSHashTable<Protocol>
            {
                return protocols
            } else {
                let initialValue = NSHashTable<Protocol>()
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
    
    private var _dispatchDestinations: NSHashTable<NSObjectProtocol> {
        get {
            if let destinations = objc_getAssociatedObject(
                self,
                &dispatchDestinationsKey
                )
                as? NSHashTable<NSObjectProtocol>
            {
                return destinations
            } else {
                let initialValue = NSHashTable<NSObjectProtocol>
                    .weakObjects()
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
        _ aSelector: Selector
        )
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
