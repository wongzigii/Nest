//
//  ObjCMultiCastDelegatable.swift
//  Nest
//
//  Created by Manfred on 10/23/15.
//
//

import Foundation
import SwiftExt

public protocol ObjCMultiCastDelegatable: class {
    typealias Delegate: AnyObject
    
    var delegates: [Delegate] { get }
}

private var weakDelegatesKey =
"com.WeZZard.Nest.MultiCastDelegateHosterType.weakDelegatesKey"

extension ObjCMultiCastDelegatable {
    public var delegates: [Delegate] { return weakDelegates.flatMap {$0.value} }
    
    private var weakDelegates: [Weak<Delegate>] {
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
    
    public func addDelegate(delegate: Delegate) {
        let weakDelegate = Weak<Delegate>(delegate)
        if !weakDelegates.contains(weakDelegate) {
            weakDelegates.append(weakDelegate)
        }
    }
    
    public func removeDelegate(delegate: Delegate) {
        let weakDelegate = Weak<Delegate>(delegate)
        if let index = weakDelegates.indexOf(weakDelegate) {
            weakDelegates.removeAtIndex(index)
        }
    }
}