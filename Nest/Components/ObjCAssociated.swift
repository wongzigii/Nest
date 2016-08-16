//
//  ObjCAssociated.swift
//  Nest
//
//  Created by Manfred on 10/10/15.
//
//

import Foundation

public final class ObjCAssociated<T>: NSObject, NSCopying {
    public typealias AssociatedValue = T
    public var value: AssociatedValue
    
    public init(_ value: AssociatedValue) { self.value = value }
    
    public func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(value)
    }
}

extension ObjCAssociated where T: NSCopying {
    public func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return type(of: self).init(
            value.copy(with: zone) as! AssociatedValue
        )
    }
}
