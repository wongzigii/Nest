//
//  NSManagedObject+ObjCKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 12/1/15.
//
//

import Foundation
import CoreData

extension ObjCKeyValueAccessible where Self: NSManagedObject,
    Self.Key.RawValue == String
{
    public func primitiveValueForKey<T>(key: Key) -> T? {
        return primitiveValueForKey(key.rawValue) as? T
    }
    
    public func setPrimitiveValue(value: AnyObject?, forKey key: Key) {
        setPrimitiveValue(value, forKey: key.rawValue)
    }
}
