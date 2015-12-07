//
//  NSCoder+InterfaceNormalization.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import Foundation

extension NSCoder {
    public func encode<T: ObjCPrimitiveCodingType>(
        value: T?,
        forKey key: String)
    {
        value?.encodeTo(self, forKey: key)
    }
    
    public func encode<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        value: T?,
        forKey key: String)
    {
        value?.encodeTo(self, forKey: key)
    }
    
    public func encode<T: _ObjectiveCBridgeable>(
        value: T?,
        forKey key: String)
    {
        encodeObject(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    public func encode<T: AnyObject>(
        value: T?,
        forKey key: String)
    {
        encodeObject(value, forKey: key)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType>(key: String) -> T? {
        return T.decodeFrom(self, forKey: key)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        key: String)
        -> T?
    {
        return T.decodeFrom(self, forKey: key)
    }
    
    public func decodeForKey<T: _ObjectiveCBridgeable>(key: String) -> T? {
        guard containsValueForKey(key) else { return nil }
        
        guard let object = decodeObjectForKey(key) else { return nil }
        
        var value: T?
        
        T._forceBridgeFromObjectiveC(
            object as! T._ObjectiveCType,
            result: &value)
        
        return value
    }
    
    public func decodeForKey<T: NSObject>(key: String) -> T? {
        guard containsValueForKey(key) else { return nil }
        
        guard let object = decodeObjectForKey(key) else { return nil }
        
        return object as? T
    }
    
    public func decodeForKey<T: NSObject where T: NSCoding>(key: String) -> T? {
        guard containsValueForKey(key) else { return nil }
        
        guard let object = decodeObjectOfClass(T.self, forKey: key) else {
            // We don't need to check decoder's requiresSecureCoding property
            // because system throws exception on behalf of ourselves when
            // requiresSecureCoding responds to true but NSSecureCoding was not
            // implemented.
            // Once the program went to here, that meant it can only be a type
            // casting failure where decoder's requiresSecureCoding responded to
            // false.
            return nil
        }
        
        return object
    }
}