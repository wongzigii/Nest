//
//  ObjCSelectorInterceptor.swift
//  Nest
//
//  Created by Manfred on 12/28/15.
//
//

import Foundation
import SwiftExt

public final class ObjCSelectorInterceptor: NSObject {
    /// Returns the intercepted selectors.
    public let interceptedSelectors: [Selector]
    
    /// The receiver receives messages.
    public weak var receiver: NSObject?
    
    /// The middle men intercepts messages. The last middle appended man
    /// receives messages firstly.
    private var _middleMen: [Weak<NSObject>] = []
    public var middleMen: [NSObject] {
        return _middleMen.flatMap {$0.value}
    }
    
    public init(selector: Selector) { interceptedSelectors = [selector] }
    
    public init(selectors: Selector...) { interceptedSelectors = selectors }
    
    public init(selectors: [Selector]) { interceptedSelectors = selectors }
    
    public init(_ selectorLiteral: String) {
        interceptedSelectors = [Selector(selectorLiteral)]
    }
    
    public init(_ selectorLiterals: String...) {
        interceptedSelectors = selectorLiterals.map { Selector($0) }
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
    
    private func doesSelectorBelongToAnyInterceptedSelector(aSelector: Selector)
        -> Bool
    {
        return interceptedSelectors.contains(aSelector)
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
                doesSelectorBelongToAnyInterceptedSelector(aSelector)
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
                doesSelectorBelongToAnyInterceptedSelector(aSelector)
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
}
