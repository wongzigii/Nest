//
//  ObjCKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

public protocol ObjCKeyValueAccessible {
    associatedtype Key: ObjCKeyValueAccessibleKeyType
}

extension ObjCKeyValueAccessible where Self: NSObject,
    Self.Key.RawValue == String
{
    public subscript (key: Key) -> AnyObject? {
        get { return valueForKey(key.rawValue) }
        mutating set { setValue(newValue, forKey: key.rawValue) }
    }
    
    public subscript (keys: Key...) -> [Key: AnyObject] {
        get {
            var results = [Key: AnyObject]()
            for each in keys { results[each] = self[each] }
            return results
        }
        mutating set { for (key, value) in newValue { self[key] = value } }
    }
    
    public subscript (keys: [Key]) -> [Key: AnyObject] {
        get {
            var results = [Key: AnyObject]()
            for each in keys { results[each] = self[each] }
            return results
        }
        mutating set { for (key, value) in newValue { self[key] = value } }
    }
}