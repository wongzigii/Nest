//
//  ObjCAssociated.swift
//  Nest
//
//  Created by Manfred on 10/10/15.
//
//

import Foundation

public final class ObjCAssociated<T>: NSObject,
    NSCopying,
    NSMutableCopying
{
    public typealias AssociatedValue = T
    public var value: AssociatedValue
    
    public init(_ value: AssociatedValue) { self.value = value }
    
    public func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(value)
    }
    
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(value)
    }
    
    public override func copy() -> Any {
        let copied = super.copy() as! ObjCAssociated<T>
        
        if let copiedValue = value as? NSCopying {
            copied.value = copiedValue.copy() as! T
        } else {
            copied.value = value
        }
        return copied
    }
    
    public override func mutableCopy() -> Any {
        let copied = super.mutableCopy() as! ObjCAssociated<T>
        
        if let copiedValue = value as? NSMutableCopying {
            copied.value = copiedValue.mutableCopy() as! T
        } else {
            copied.value = value
        }
        return copied
    }
}
