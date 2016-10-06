//
//  ObjCProtocolMessageInterceptor.swift
//  Nest
//
//  Created by Manfred Lau on 11/28/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation
import SwiftExt

/// `ObjCProtocolMessageInterceptor` is a proxy which intercepts messages 
/// which originally intended to be sent to the receiver to the middle 
/// men.
///
/// - Notes: `ObjCProtocolMessageInterceptor` is a class cluster which 
/// dynamically subclasses itself to conform to the intercepted protocols 
/// at the runtime.
///
/// - See Also: ObjCProtocolMessageIntercepting
public final class ObjCProtocolMessageInterceptor: NSObject {
    @objc
    private init(interceptedProtocols: [Protocol]) {
        self.interceptedProtocols = interceptedProtocols
        _dispatchTable = NSMapTable.strongToWeakObjects()
    }
    
    //MARK: Create ObjCProtocolMessageInterceptor
    /// Creates a protocol interceptor which intercepts an Objective-C 
    /// protocol.
    ///
    /// - Parameter     protocol:  An Objective-C protocol, such as 
    /// `UITableViewDelegate.self`.
    public class func make(protocol: Protocol ...)
        -> ObjCProtocolMessageInterceptor
    {
        return make(protocols: `protocol`)
    }
    
    /// Creates a protocol interceptor which intercepts a series of 
    /// Objective-C protocols in variable length.
    ///
    /// - Parameter     protocols:  A variable length sort of Objective-C 
    /// protocol, such as `UITableViewDelegate.self`.
    public class func make(protocols: Protocol ...)
        -> ObjCProtocolMessageInterceptor
    {
        return make(protocols: protocols)
    }
    
    /// Creates a protocol interceptor which intercepts a sequence of
    /// Objecitve-C protocols.
    ///
    /// - Parameter     protocols:  A sequence of Objective-C protocols,
    /// such as [UITableViewDelegate.self].
    public class func make<S: Sequence>(protocols: S)
        -> ObjCProtocolMessageInterceptor where
        S.Iterator.Element == Protocol
    {
        let protocolNames = protocols.map { NSStringFromProtocol($0) }
        let sortedProtocolNames = protocolNames.sorted()
        let concatenatedProtocolsName = sortedProtocolNames
            .joined(separator: ",")
        
        let concreteClass = _concreteClass(
            with: protocols,
            concatenatedProtocolsName: concatenatedProtocolsName
        )
        
        let protocolInterceptor = concreteClass
            .perform(NSSelectorFromString("alloc"))
            .takeUnretainedValue()
            .perform(
                #selector(self.init(interceptedProtocols:)),
                with: Array(protocols)
        )
        
        return protocolInterceptor!.takeUnretainedValue()
            as! ObjCProtocolMessageInterceptor
    }
    
    /// Returns a subclass of `ObjCProtocolMessageInterceptor` which 
    /// conforms to specified protocols.
    ///
    /// - Parameter protocols: An sequence of Objective-C protocols.
    /// The subclass returned from this function will conform to these 
    /// protocols.
    ///
    /// - Parameter concatenatedProtocolsName: A string which came from
    /// concatenating names of `protocols`.
    ///
    /// - Parameter salt: A `UInt` number appended to the class name which
    /// used for distinguishing the class name itself from the duplicated.
    private class func _concreteClass<S: Sequence>(
        with protocols: S,
        concatenatedProtocolsName: String,
        salt: UInt? = nil
        )
        -> ObjCProtocolMessageInterceptor.Type where
        S.Iterator.Element == Protocol
    {
        let className: String = {
            let basicClassName =
                NSStringFromClass(ObjCProtocolMessageInterceptor.self)
                    + "_"
                    + concatenatedProtocolsName
            
            if let salt = salt { return basicClassName + "_\(salt)" }
                else { return basicClassName }
        }()
        
        let nextSalt = salt.map {$0 + 1}
        
        if let aClass = NSClassFromString(className) {
            switch aClass {
            case let anInterceptorClass
                as ObjCProtocolMessageInterceptor.Type:
                let isClassConformsToAllProtocols: Bool = {
                    // Check if the found class conforms to the protocols
                    for eachProtocol in protocols
                        where !class_conformsToProtocol(
                            anInterceptorClass,
                            eachProtocol
                        )
                    {
                        return false
                    }
                    return true
                    }()
                
                if isClassConformsToAllProtocols {
                    return anInterceptorClass
                } else {
                    return _concreteClass(
                        with: protocols,
                        concatenatedProtocolsName:
                        concatenatedProtocolsName,
                        salt: nextSalt
                    )
                }
            default:
                return _concreteClass(
                    with: protocols,
                    concatenatedProtocolsName: concatenatedProtocolsName,
                    salt: nextSalt
                )
            }
        } else {
            let subclass = objc_allocateClassPair(
                ObjCProtocolMessageInterceptor.self,
                className,
                0
                )
                as! ObjCProtocolMessageInterceptor.Type
            
            for eachProtocol in protocols {
                class_addProtocol(subclass, eachProtocol)
            }
            
            objc_registerClassPair(subclass)
            
            return subclass
        }
    }
    
    //MARK: Message Dsiaptching
    /// Returns the object to which unrecognized messages should first be
    /// directed.
    public override func forwardingTarget(for aSelector: Selector)
        -> Any?
    {
        if let target = _dispatchAndCache(message: aSelector) {
            #if DEBUG
                if shouldLogMessageForwarding {
                    print(#function, aSelector, "->", target)
                }
            #endif
            return target
        }
        
        let target = super.forwardingTarget(for: aSelector)
        #if DEBUG
            if shouldLogMessageForwarding {
                print(#function, aSelector, "->", target)
            }
        #endif
        return target
    }
    
    /// Returns a Boolean value that indicates whether the receiver
    /// implements or inherits a method that can respond to a specified
    /// message.
    public override func responds(to aSelector: Selector) -> Bool {
        if _dispatchAndCache(message: aSelector) != nil {
            #if DEBUG
                if shouldLogMessageResponding {
                    print(#function, aSelector, "->", true)
                }
            #endif
            return true
        }
        
        let isRespond = super.responds(to: aSelector)
        #if DEBUG
            if shouldLogMessageResponding {
                print(#function, aSelector, "->", isRespond)
            }
        #endif
        return isRespond
    }
    
    //MARK: Manage Middle Men
    public func containsMiddleMan(_ middleMan: NSObject) -> Bool {
        for each in _middleMen where each.value === middleMan {
            return true
        }
        return false
    }
    
    /// Append a middle man which intercepts the intercepted protocols.
    public func appendMiddleMan(_ middleMan: NSObject) {
        _middleMen.append(Weak(middleMan))
        _setNeedsInvalidateDispatchTable()
    }
    
    /// Append middle men which intercept the intercepted protocols.
    public func appendMiddleMen<S: Sequence>(_ middleMen: S) where
        S.Iterator.Element == NSObjectProtocol
    {
        _middleMen.append(contentsOf: middleMen.map {Weak($0)})
        _setNeedsInvalidateDispatchTable()
    }
    
    /// Insert a middle man which intercepts the intercepted protocols.
    public func insertMiddleMan(
        _ middleMan: NSObjectProtocol, at index: Int
        )
    {
        _middleMen.insert(Weak(middleMan), at: index)
        _setNeedsInvalidateDispatchTable()
    }
    
    /// Insert middle men which intercept the intercepted protocols.
    public func insertMiddleMen<S: Sequence>(
        _ middleMen: S, at index: Int
        ) where S.Iterator.Element == NSObjectProtocol
    {
        _middleMen.insert(contentsOf: middleMen.map{Weak($0)}, at: index)
        _setNeedsInvalidateDispatchTable()
    }
    
    /// Remove a middle man which intercepts the intercepted protocols.
    @discardableResult
    public func removeMiddleMan(
        _ middleMan: NSObjectProtocol
        ) -> NSObjectProtocol?
    {
        if let index = _middleMen.index(of: Weak(middleMan)) {
            _setNeedsInvalidateDispatchTable()
            return _middleMen.remove(at: index).value
        }
        return nil
    }
    
    /// Remove middle men which intercepts the intercepted protocols.
    public func removeMiddleMan<S: Sequence>(
        _ middleMen: S
        ) where S.Iterator.Element == NSObjectProtocol
    {
        middleMen.forEach { removeMiddleMan($0) }
    }
    
    /// Remove a middle man which intercepts the intercepted protocols.
    @discardableResult
    public func removeMiddleMan(
        at index: Int
        ) -> NSObjectProtocol?
    {
        _setNeedsInvalidateDispatchTable()
        return _middleMen.remove(at: index).value
    }
    
    //MARK: Invalidate Disaptch Table
    private func _setNeedsInvalidateDispatchTable() {
        if !_needsInvalidateDispatchTable {
            _needsInvalidateDispatchTable = true
            RunLoop.main.schedule { [weak self] in
                self?._invaldiateDispatchTableIfNeeded()
            }
        }
    }
    
    private func _invaldiateDispatchTableIfNeeded() {
        if _needsInvalidateDispatchTable {
            invaldiateDispatchTableIfNeeded()
        }
    }
    
    private func invaldiateDispatchTableIfNeeded() {
        _dispatchTable.removeAllObjects()
        _needsInvalidateDispatchTable = false
    }
    
    //MARK: Utilities
    private func _doesSelectorBelongToAnyInterceptedProtocol(
        _ aSelector: Selector
        )
        -> Bool
    {
        for aProtocol in interceptedProtocols
            where sel_belongsToProtocol(aSelector, aProtocol)
        {
            return true
        }
        return false
    }
    
    private func _dispatchAndCache(message: Selector)
        -> NSObjectProtocol?
    {
        var emptyMiddleManWrappersIndices = [Int]()
        
        defer {
            _middleMen.remove(indices: emptyMiddleManWrappersIndices)
        }
        
        let needsDisaptch = _doesSelectorBelongToAnyInterceptedProtocol(
            message
        )
        
        let msgKey = NSStringFromSelector(message) as NSString
        
        if needsDisaptch {
            if let cached = _dispatchTable.object(forKey: msgKey) {
                if cached is NSNull {
                    return nil
                } else {
                    return cached
                }
            }
            
            for (idx, middleManWrapper) in _middleMen.enumerated() {
                if let middleMan = middleManWrapper.value {
                    if middleMan.responds(to: message) {
                        _dispatchTable.setObject(
                            middleMan, forKey: msgKey
                        )
                        #if DEBUG
                            if shouldLogMessageDispatching {
                                print("\(self) dispatched \"\(NSStringFromSelector(message))\" to middle man: \(middleMan).")
                            }
                        #endif
                        return middleMan
                    }
                } else {
                    emptyMiddleManWrappersIndices.append(idx)
                }
            }
            
            if let receiver = receiver,
                receiver.responds(to: message) == true
            {
                _dispatchTable.setObject(receiver, forKey: msgKey)
                #if DEBUG
                    if shouldLogMessageDispatching {
                        print("\(self) dispatched \"\(NSStringFromSelector(message))\" to receiver: \(receiver).")
                    }
                #endif
                return receiver
            }
            
            _dispatchTable.setObject(NSNull(), forKey: msgKey)
            #if DEBUG
                if shouldLogMessageDispatching {
                    print("\(self) dispatched \"\(NSStringFromSelector(message))\" to nil.")
                }
            #endif
            return nil
        }
        
        
        return nil
    }
    
    //MARK: Computed Properties
    /// The middle men intercept messages. The first middle man receives
    /// messages firstly.
    public var middleMen: [NSObjectProtocol] {
        return _middleMen.flatMap {$0.value}
    }
    
    //MARK: Stored Properties
    /// Returns the intercepted protocols.
    public let interceptedProtocols: [Protocol]
    
    /// The receiver receives messages.
    public weak var receiver: NSObjectProtocol?
    
    #if DEBUG
    public var shouldLogMessageDispatching: Bool = false
    public var shouldLogMessageForwarding: Bool = false
    public var shouldLogMessageResponding: Bool = false
    #endif
    
    private var _middleMen: [Weak<NSObjectProtocol>] = []
    
    private var _needsInvalidateDispatchTable: Bool = false
    
    private var _dispatchTable: NSMapTable<NSString, NSObjectProtocol>
    
}
