//
//  ObjCAssociated.swift
//  Nest
//
//  Created by Manfred on 10/10/15.
//
//

import Foundation

public class ObjCAssociated<T>: NSObject,
    NSCopying,
    NSMutableCopying
{
    public typealias AssociatedValue = T
    public var value: AssociatedValue
    
    public required init(_ value: AssociatedValue) {
        self.value = value
        super.init()
    }
    
    public func copy(with zone: NSZone?) -> Any {
        if let valueToCopy = value as? NSCopying {
            return type(of: self).init(valueToCopy.copy() as! T)
        } else {
            return type(of: self).init(value)
        }
    }
    
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        if let valueToCopy = value as? NSMutableCopying {
            return type(of: self).init(valueToCopy.mutableCopy() as! T)
        } else {
            return type(of: self).init(value)
        }
    }
}
