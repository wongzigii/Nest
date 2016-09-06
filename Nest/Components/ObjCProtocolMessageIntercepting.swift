//
//  ObjCProtocolMessageIntercepting.swift
//  Nest
//
//  Created by Manfred on 9/22/15.
//
//

import SwiftExt
import Foundation

/// By conforming `ObjCProtocolMessageIntercepting`, an object gains the
/// ability of turning to be a proxy which intercepts messages of 
/// specified protocols, which originally intended to send to the object
/// itself, to the latest appended dispatching destination. If all the 
/// dispatching destinations are not able to respond to the message, it 
/// will finally be dispatched back to the object itself. You are able to 
/// add dispatched protocols during the object's lifetime. But since 
/// Objective-C have no mechanism to remove the conformance to a protocol
/// of a class at runtime, you're not able to remove it after added.
///
/// - Discussion: Where the `ObjCProtocolMessageIntercepting` is different 
/// from `ObjCProtocolMessageInterceptor` are:
///
/// 1. `ObjCProtocolMessageIntercepting` is a pre-implemented protocol but
/// `ObjCProtocolMessageInterceptor` is a class;
///
/// 2. `ObjCProtocolMessageInterceptor` employs the middle-men to be a 
/// fallback-able message responder chain, and the `receiver` property of 
/// it is the last stop. `ObjCProtocolMessageIntercepting` employs the 
/// `dispatchDestinations` property to be a fallback-able message 
/// responder chain and the conformed object itself is the last stop.
///
/// 3. You are allowed to add dispatched protocols to any object conforms 
/// to `ObjCProtocolMessageIntercepting` at runtime which
/// `ObjCProtocolMessageInterceptor` doesn't.
///
/// 4. You should manually override the conformee's `responds(to:)` and
/// `forwardTarget(for:)` function and call `nest_responds(to:)` and 
/// `nest_forwardTarget(for:)` inside it due to the principles of protocol
/// extensions.
public protocol ObjCProtocolMessageIntercepting: NSObjectProtocol {
    
}

extension ObjCProtocolMessageIntercepting {
    /// Returns registered intercepted protocols
    public var interceptedProtocols: [Protocol] {
        return _interceptedProtocols.allObjects
    }
    
    /// Returns registered protocol dispatching destination
    public var dispatchDestinations: [NSObjectProtocol] {
        return _destinations.flatMap { $0.value }
    }
    
    /// Returns the object to which unrecognized messages should firstly 
    /// be directed.
    
    /// - Descusstion: Your should call this method in your class'
    /// `forwardingTarget(for:)`'s implementation. The reasons why you
    /// should do it this way are: 1) Protocol extension doesn't override
    /// existed implementation in any conformed type; 2) Extension shall 
    /// always extend new members and never override existed members.
    public func nest_forwardingTarget(for aSelector: Selector)
        -> AnyObject?
    {
        if let target = _dispatchAndCacheMessage(aSelector) {
            return target
        }
        
        if class_respondsToSelector(type(of: self), aSelector) {
            return self
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
        if _dispatchAndCacheMessage(aSelector) != nil {
            return true
        }
        
        return class_respondsToSelector(type(of: self), aSelector)
    }
    
    /// Add an intercepted protocol.
    public func addInterceptedProtocol(_ interceptedProtocol: Protocol) {
        if !_interceptedProtocols.contains(interceptedProtocol) {
            _interceptedProtocols.add(interceptedProtocol)
        }
        if !class_conformsToProtocol(
            type(of: self), interceptedProtocol
            )
        {
            class_addProtocol(type(of: self), interceptedProtocol)
        }
    }
    
    /// Add a series of intercepted protocols in varaible length.
    public func addInterceptedProtocols(
        _ interceptedProtocols: Protocol...
        )
    {
        for eachProtocol in interceptedProtocols {
            if !_interceptedProtocols.contains(eachProtocol) {
                _interceptedProtocols.add(eachProtocol)
            }
            if !class_conformsToProtocol(type(of: self), eachProtocol) {
                class_addProtocol(type(of: self), eachProtocol)
            }
        }
    }
    
    /// Add a sequence of intercepted protocols.
    public func addInterceptedProtocols<S: Sequence>(
        _ interceptedProtocols: S
        ) where S.Iterator.Element == Protocol
    {
        for eachProtocol in interceptedProtocols {
            if !_interceptedProtocols.contains(eachProtocol) {
                _interceptedProtocols.add(eachProtocol)
            }
            if !class_conformsToProtocol(type(of: self), eachProtocol) {
                class_addProtocol(type(of: self), eachProtocol)
            }
        }
    }
    
    /// Append a protocol dispatch destination.
    public func appendDispatchDestination(
        _ dispatchDestination: NSObjectProtocol
        )
    {
        _destinations.append(Weak(dispatchDestination))
        _setNeedsInvalidateDispatchTable()
    }
    
    /// Append a protocol dispatch destination.
    public func appendDispatchDestinations<S: Sequence>(
        _ dispatchDestinations: S
        ) where S.Iterator.Element == NSObjectProtocol
    {
        _destinations.append(
            contentsOf: dispatchDestinations.map {Weak($0)}
        )
        _setNeedsInvalidateDispatchTable()
    }
    
    @discardableResult
    public func removeDispatchDestination(
        _ dispatchDestination: NSObjectProtocol
        )
        -> NSObjectProtocol?
    {
        _setNeedsInvalidateDispatchTable()
        return _destinations.remove(Weak(dispatchDestination))?.value
    }
    
    @discardableResult
    public func removeDispatchDestination(at index: Int)
        -> NSObjectProtocol?
    {
        _setNeedsInvalidateDispatchTable()
        return _destinations.remove(at: index).value
    }
    
    public func insertDispatchDestination(
        _ dispatchDestination: NSObjectProtocol, at index: Int
        )
    {
        _destinations.insert(Weak(dispatchDestination), at: index)
        _setNeedsInvalidateDispatchTable()
    }
    
    // MARK: Dispatch the Message
    private func _dispatchAndCacheMessage(_ message: Selector)
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
    
    private func _setNeedsInvalidateDispatchTable() {
        if !_needsInvalidateDispatchTable {
            _needsInvalidateDispatchTable = true
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
    
    private func _invalidateDispatchTableIfNeeded() {
        if _needsInvalidateDispatchTable {
            if _dispatchTable.count > 0 {
                _dispatchTable.removeAllObjects()
            }
            _needsInvalidateDispatchTable = false
        }
    }
    
    // MARK: Stored Properties
    private var _interceptedProtocols: NSHashTable<Protocol> {
        get {
            if let protocols = objc_getAssociatedObject(
                self,
                &interceptedProtocolsKey
                )
                as? NSHashTable<Protocol>
            {
                return protocols
            } else {
                let initVal = NSHashTable<Protocol>()
                objc_setAssociatedObject(
                    self,
                    &interceptedProtocolsKey,
                    initVal,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return initVal
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &interceptedProtocolsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    private var _destinations: [Weak<NSObjectProtocol>] {
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
    
    private var _dispatchTable: NSMapTable<NSString, NSObjectProtocol> {
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
    
    // MARK: Utilities
    private func _doesSelectorBelongToAnyDispatchedProtocol(
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

private var interceptedProtocolsKey = "dispatchedProtocols"
private var destinationsKey = "destinations"
private var dispatchTableKey = "dispatchTable"
private var needsInvalidateDispatchTableKey = "needsInvalidateDispatchTable"
