//
//  ObjCAssociated.swift
//  Nest
//
//  Created by Manfred on 10/10/15.
//
//

import Foundation

public final class ObjCAssociated<T>: NSObject, NSCopying {
    public typealias Type = T
    public let value: Type
    
    public init(_ value: Type) { self.value = value }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(value)
    }
}

extension ObjCAssociated where T: NSCopying {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(value.copyWithZone(zone) as! Type)
    }
}
