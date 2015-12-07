//
//  NSCoding+ObjCKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 11/20/15.
//
//

import Foundation

extension NSCoding where Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String,
    Self: NSObject
{
    public func areValuesNilForKeys(keys: Key...) -> Bool {
        for eachKey in keys where self[eachKey] == nil {
            return true
        }
        return false
    }
    
    public func isValueNilForKey(key: Key) -> Bool {
        return self[key] == nil
    }
}

extension NSCoding where Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func encode<T: ObjCPrimitiveCodingType>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        value?.encodeTo(encoder, forKey: key.rawValue)
    }
    
    public func encode<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        value?.encodeTo(encoder, forKey: key.rawValue)
    }
    
    public func encode<T: _ObjectiveCBridgeable>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        encoder.encodeObject(value?._bridgeToObjectiveC(), forKey: key.rawValue)
    }
    
    public func encode<T: NSObject>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        encoder.encodeObject(value, forKey: key.rawValue)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType>(
        key: Key,
        from decoder: NSCoder)
        -> T?
    {
        return T.decodeFrom(decoder, forKey: key.rawValue)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        key: Key,
        from decoder: NSCoder)
        -> T?
    {
        return T.decodeFrom(decoder, forKey: key.rawValue)
    }
    
    public func decodeForKey<T: _ObjectiveCBridgeable>(
        key: Key,
        from decoder: NSCoder)
        -> T?
    {
        guard decoder.containsValueForKey(key.rawValue) else { return nil }
        
        guard let object = decoder.decodeObjectForKey(key.rawValue)
            else { return nil }
        
        var value: T?
        
        T._forceBridgeFromObjectiveC(
            object as! T._ObjectiveCType,
            result: &value)
        
        return value
    }
    
    public func decodeForKey<T: NSObject>(key: Key, from decoder: NSCoder)
        -> T?
    {
        guard decoder.containsValueForKey(key.rawValue) else { return nil }
        
        guard let object = decoder.decodeObjectForKey(key.rawValue) else {
            return nil
        }
        
        return object as? T
    }
    
    public func decodeForKey<T: NSObject where T: NSCoding>(
        key: Key,
        from decoder: NSCoder)
        -> T?
    {
        guard decoder.containsValueForKey(key.rawValue) else { return nil }
        
        guard let object = decoder.decodeObjectOfClass(T.self,
            forKey: key.rawValue) else
        {
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
