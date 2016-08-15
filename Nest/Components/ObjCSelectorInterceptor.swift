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
    
    public func addMiddleMan(_ middleMan: NSObject) {
        _middleMen.append(Weak(middleMan))
    }
    
    public func removeMiddleMan(_ middleMan: NSObject) -> NSObject? {
        if let index = _middleMen.index(of: Weak(middleMan)) {
            return _middleMen.remove(at: index).value
        }
        return nil
    }
    public func containsMiddleMan(_ middleMan: NSObject) -> Bool {
        for each in _middleMen where each.value === middleMan { return true }
        return false
    }
    
    private func doesSelectorBelongToAnyInterceptedSelector(_ aSelector: Selector)
        -> Bool
    {
        return interceptedSelectors.contains(aSelector)
    }
    
    /// Returns the object to which unrecognized messages should first be
    /// directed.
    public override func forwardingTarget(for aSelector: Selector)
        -> AnyObject?
    {
        var emptyMiddleManWrappersIndices = [Int]()
        
        defer {
            _middleMen.remove(indices: emptyMiddleManWrappersIndices)
        }
        
        for (index, middleManWrapper) in _middleMen.reversed().enumerated() {
            if middleManWrapper.value?.responds(to: aSelector) == true &&
                doesSelectorBelongToAnyInterceptedSelector(aSelector)
            {
                return middleManWrapper.value
            } else if middleManWrapper.value == nil {
                emptyMiddleManWrappersIndices.append(index)
            }
        }
        
        if receiver?.responds(to: aSelector) == true {
            return receiver
        }
        
        return super.forwardingTarget(for: aSelector)
    }
    
    /// Returns a Boolean value that indicates whether the receiver implements
    /// or inherits a method that can respond to a specified message.
    public override func responds(to aSelector: Selector) -> Bool {
        var emptyMiddleManWrappersIndices = [Int]()
        
        defer {
            _middleMen.remove(indices: emptyMiddleManWrappersIndices)
        }
        
        for (index, eachMiddleMan) in _middleMen.reversed().enumerated() {
            if eachMiddleMan.value?.responds(to: aSelector) == true &&
                doesSelectorBelongToAnyInterceptedSelector(aSelector)
            {
                return true
            } else if eachMiddleMan.value == nil {
                emptyMiddleManWrappersIndices.append(index)
            }
        }
        
        if receiver?.responds(to: aSelector) == true {
            return true
        }
        
        return super.responds(to: aSelector)
    }
}
