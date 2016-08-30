//
//  ObjCProtocolMessageIntercepting.swift
//  Nest
//
//  Created by Manfred on 9/22/15.
//
//

import SwiftExt
import Foundation

/// By conforming `ObjCProtocolMessageIntercepting`, an object gained the 
/// ability of turning to be a proxy which intercepts specified protocols'
/// messages which originally intended to send to the object itself to the
/// latest appended dispatching destination. If all the dispatching 
/// destinations are not able to respond to the message, it will finally 
/// be dispatched back to the object itself. You are able to add 
/// dispatched protocols during the object's lifetime.
///
/// - Discussion: Where the `ObjCProtocolMessageIntercepting` is different 
/// from `ObjCProtocolMessageInterceptor` are:
///
/// 1. `ObjCProtocolMessageIntercepting` is a pre-implemented protocol but
/// `ObjCProtocolMessageInterceptor` is a class;
///
/// 2. The role of `ObjCProtocolMessageInterceptor`'s receiver is just the 
/// receiver itself but `ObjCProtocolMessageIntercepting` owns a fallback-
/// able receiver chain which is the `dispatchDestinations` array.
///
/// 3. You are allowed to add dispatched protocols to any object conforms 
/// to `ObjCProtocolMessageIntercepting` at runtime which
/// `ObjCProtocolMessageInterceptor` doesn't.
///
/// 4. You should manually override the conformee's `responds(to:)` and
/// `forwardTarget(for:)` function and call `nest_responds(to:)` and 
/// `nest_forwardTarget(for:)` inside it due to the principles of coding
/// protocol extensions.
public protocol ObjCProtocolMessageIntercepting: NSObjectProtocol {
    
}

extension ObjCProtocolMessageIntercepting {
    /// Returns interceptred protocols
    public var interceptedProtocols: [Protocol] {
        return _interceptredProtocols.allObjects
    }
    
    /// Returns registered protocol dispatching destination
    public var dispatchDestinations: [NSObjectProtocol] {
        return _destinations.flatMap { $0.value }
    }
}

extension ObjCProtocolMessageIntercepting {
    /// Returns the object to which unrecognized messages should first be
    /// directed.
    
    /// - Descusstion: Your should call this method in your class'
    /// `forwardingTarget(for:)`'s implementation. The reasons why you
    /// should do it this way are: 1) Protocol extension doesn't override
    /// existed implementation in any conformed type; 2) Extension shall 
    /// always extend new members and never override existed members.
    public func nest_forwardingTarget(for aSelector: Selector)
        -> AnyObject?
    {
        if let target = _dispatchAndCache(message: aSelector) {
            return target
        }
        
        return nil
    }
    
    /// Returns a Boolean value that indicates whether the receiver 
    /// implements or inherits a method that can respond to a specified 
    /// message.
     
    /// - Descusstion: Your should call this method in your class'
    /// `responds(to:)`'s implementation. The reasons why you should do in
    /// this way are: 1) Protocol extension doesn't override existed 
    /// implementation in any conformed type; 2) Extension shall always 
    /// extend new members and never override existed members.
    public func nest_responds(to aSelector: Selector) -> Bool {
        if _dispatchAndCache(message: aSelector) != nil {
            return true
        }
        
        return false
    }
    
    private func _dispatchAndCache(message: Selector)
        -> NSObjectProtocol?
    {
        let needsDispatch = _doesSelectorBelongToAnyDispatchedProtocol(
            message
        )
        
        let selString = NSStringFromSelector(message) as NSString
        
        var emptyDestinationIndices = [Int]()
        
        defer {
            _destinations.remove(indices: emptyDestinationIndices)
        }
        
        if needsDispatch {
            _invalidateDispatchTableIfNeeded()
            
            if let cachedDest = _dispatchTable.object(forKey: selString) {
                if cachedDest is NSNull {
                    return nil
                }
                return cachedDest
            }
            
            for (idx, destWrapper) in _destinations.enumerated() {
                if let dest = destWrapper.value {
                    if dest.responds(to: message) == true {
                        _dispatchTable.setObject(dest, forKey: selString)
                        return dest
                    }
                } else {
                    emptyDestinationIndices.append(idx)
                }
            }
            
            if class_respondsToSelector(type(of: self), message) {
                _dispatchTable.setObject(self, forKey: selString)
                return self
            }
            
            _dispatchTable.setObject(NSNull(), forKey: selString)
            return nil
        }
        
        return nil
    }
}

extension ObjCProtocolMessageIntercepting {
    /// Add an intercepted protocol.
    public func add(interceptedProtocol: Protocol) {
        if !_interceptredProtocols.contains(interceptedProtocol) {
            _interceptredProtocols.add(interceptedProtocol)
        }
        if !class_conformsToProtocol(
            type(of: self), interceptedProtocol
            )
        {
            class_addProtocol(type(of: self), interceptedProtocol)
        }
    }
    
    /// Add a series of intercepted protocols in varaible length.
    public func add(interceptedProtocols: Protocol...) {
        for eachProtocol in interceptedProtocols {
            if !_interceptredProtocols.contains(eachProtocol) {
                _interceptredProtocols.add(eachProtocol)
            }
            if !class_conformsToProtocol(type(of: self), eachProtocol) {
                class_addProtocol(type(of: self), eachProtocol)
            }
        }
    }
    
    /// Add a sequence of intercepted protocols.
    public func add<S: Sequence>(interceptedProtocols: S) where
        S.Iterator.Element == Protocol
    {
        for eachProtocol in interceptedProtocols {
            if !_interceptredProtocols.contains(eachProtocol) {
                _interceptredProtocols.add(eachProtocol)
            }
            if !class_conformsToProtocol(type(of: self), eachProtocol) {
                class_addProtocol(type(of: self), eachProtocol)
            }
        }
    }
}

extension ObjCProtocolMessageIntercepting {
    /// Append a protocol dispatch destination.
    public func append(dispatchDestination: NSObjectProtocol) {
        _destinations.append(Weak(dispatchDestination))
        _setNeedsInvalidateDispatchTable()
    }
    
    /// Append a protocol dispatch destination.
    public func append<S: Sequence>(dispatchDestinations: S) where
        S.Iterator.Element == NSObjectProtocol
    {
        _destinations.append(
            contentsOf: dispatchDestinations.map {Weak($0)}
        )
        _setNeedsInvalidateDispatchTable()
    }
    
    @discardableResult
    public func remove(dispatchDestination: NSObjectProtocol)
        -> NSObjectProtocol?
    {
        _setNeedsInvalidateDispatchTable()
        return _destinations.remove(Weak(dispatchDestination))?.value
    }
    
    @discardableResult
    public func remove(dispatchDestinationAt index: Int)
        -> NSObjectProtocol?
    {
        _setNeedsInvalidateDispatchTable()
        return _destinations.remove(at: index).value
    }
    
    public func insert(
        dispatchDestination: NSObjectProtocol, at index: Int
        )
    {
        _destinations.insert(Weak(dispatchDestination), at: index)
        _setNeedsInvalidateDispatchTable()
    }
}

private var interceptredProtocolsKey = "dispatchedProtocols"
private var destinationsKey = "destinations"
private var dispatchTableKey = "dispatchTable"
private var needsInvalidateDispatchTableKey = "needsInvalidateDispatchTable"

extension ObjCProtocolMessageIntercepting {
    fileprivate func _setNeedsInvalidateDispatchTable() {
        if !_needsInvalidateDispatchTable {
            RunLoop.main.schedule { [weak self] in
                self?._invalidateDispatchTableIfNeeded()
            }
        }
    }
    
    private var _needsInvalidateDispatchTable: Bool {
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
            let oldValue = _needsInvalidateDispatchTable
            if oldValue != newValue {
                objc_setAssociatedObject(
                    self,
                    &needsInvalidateDispatchTableKey,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
            
        }
    }
    
    fileprivate var _dispatchTable
        : NSMapTable<NSString, NSObjectProtocol> {
        get {
            if let value = objc_getAssociatedObject(
                self,
                &dispatchTableKey
                )
                as? NSMapTable<NSString, NSObjectProtocol>
            {
                return value
            } else {
                let initVal: NSMapTable<NSString, NSObjectProtocol>
                    = .strongToWeakObjects()
                objc_setAssociatedObject(
                    self,
                    &dispatchTableKey,
                    initVal,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return initVal
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
    
    fileprivate func _invalidateDispatchTableIfNeeded() {
        if _needsInvalidateDispatchTable {
            if _dispatchTable.count > 0 {
                _dispatchTable.removeAllObjects()
            }
            _needsInvalidateDispatchTable = false
        }
    }
    
    fileprivate var _interceptredProtocols: NSHashTable<Protocol> {
        get {
            if let protocols = objc_getAssociatedObject(
                self,
                &interceptredProtocolsKey
                )
                as? NSHashTable<Protocol>
            {
                return protocols
            } else {
                let initVal = NSHashTable<Protocol>()
                objc_setAssociatedObject(
                    self,
                    &interceptredProtocolsKey,
                    initVal,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return initVal
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &interceptredProtocolsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    fileprivate var _destinations: [Weak<NSObjectProtocol>] {
        get {
            if let destinations = objc_getAssociatedObject(
                self,
                &destinationsKey
                )
                as? [Weak<NSObjectProtocol>]
            {
                return destinations
            } else {
                let initVal = [Weak<NSObjectProtocol>]()
                objc_setAssociatedObject(
                    self,
                    &destinationsKey,
                    initVal,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return initVal
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &destinationsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    fileprivate func _doesSelectorBelongToAnyDispatchedProtocol(
        _ aSelector: Selector
        )
        -> Bool
    {
        for eachProtocol in interceptedProtocols
            where sel_belongsToProtocol(aSelector, eachProtocol)
        {
            return true
        }
        return false
    }
}
