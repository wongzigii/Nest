//
//  ObjCMultiCastDelegating.swift
//  Nest
//
//  Created by Manfred on 10/23/15.
//
//

import Foundation
import SwiftExt

public protocol ObjCMultiCastDelegating: class {
    associatedtype Delegate: AnyObject
    
    var delegates: [Delegate] { get }
}

private var weakDelegatesKey =
"com.WeZZard.Nest.ObjCMultiCastDelegatable.weakDelegatesKey"

extension ObjCMultiCastDelegating {
    public var delegates: [Delegate] {
        return _delegates.flatMap {$0.value}
    }
    
    private var _delegates: [Weak<Delegate>] {
        get {
            return (objc_getAssociatedObject(self, &weakDelegatesKey)
                as? ObjCAssociated<[Weak<Delegate>]>)?.value
                ?? []
        }
        set {
            objc_setAssociatedObject(self,
                &weakDelegatesKey,
                ObjCAssociated<[Weak<Delegate>]>(newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func add(delegate: Delegate) {
        let weakDelegate = Weak<Delegate>(delegate)
        if !_delegates.contains(weakDelegate) {
            _delegates.append(weakDelegate)
        }
    }
    
    public func remove(delegate: Delegate) {
        let weakDelegate = Weak<Delegate>(delegate)
        if let index = _delegates.index(of: weakDelegate) {
            _delegates.remove(at: index)
        }
    }
}
