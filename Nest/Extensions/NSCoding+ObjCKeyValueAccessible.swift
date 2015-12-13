//
//  NSCoding+ObjCKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 11/20/15.
//
//

import Foundation

public enum ObjCDecodingGroupedResult<K: ObjCKeyValueAccessibleKeyType> {
    public typealias Key = K
    case AllFailed
    case PartialFailed([Key])
    case AllSucceeded
}

extension NSCoding where Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String,
    Self: NSObject
{
    public func decodingResultForGroupOfKeys(keys: Key...)
        -> ObjCDecodingGroupedResult<Self.Key>
    {
        guard keys.count > 0 else { return .AllSucceeded }
        
        var failedKeys = [Key]()
        for eachKey in keys where self[eachKey] == nil {
            failedKeys.append(eachKey)
        }
        
        switch (failedKeys.count, keys.count) {
        case (0, 0):
            return .AllSucceeded
        case let (failedKeysCount, keysCount)
            where failedKeysCount == keysCount:
            return .AllFailed
        default:
            return .PartialFailed(failedKeys)
        }
        
    }
    
    public func decodingResultForKey(key: Key) -> Bool {
        return self[key] == nil
    }
}

extension NSCoding where Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    //MARK: - Objective-C Primitive Coding Types
    public func encode<T: ObjCPrimitiveCodingType>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        value?.encodeTo(encoder, forKey: key.rawValue)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType>(
        key: Key,
        from decoder: NSCoder)
        -> T?
    {
        return T.decodeFrom(decoder, forKey: key.rawValue)
    }
    
    //MARK: Overload for ObjCPrimitiveCodingType and _ObjectiveCBridgeable
    public func encode<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        value?.encodeTo(encoder, forKey: key.rawValue)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        key: Key,
        from decoder: NSCoder)
        -> T?
    {
        return T.decodeFrom(decoder, forKey: key.rawValue)
    }
    
    //MARK: - RawRepresentable with Objective-C Primitive Coding Raw Type
    public func encode<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        value?.rawValue.encodeTo(encoder, forKey: key.rawValue)
    }
    
    public func decodeForKey<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (key: Key,
        from decoder: NSCoder)
        -> T?
    {
        return T.RawValue.decodeFrom(decoder, forKey: key.rawValue)
            .flatMap { T(rawValue: $0) }
    }
    
    //MARK: - Objective-C Bridgeable Swift Value Types
    public func encode<T: _ObjectiveCBridgeable>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        encoder.encodeObject(value?._bridgeToObjectiveC(), forKey: key.rawValue)
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
    
    //MARK: - NSCoding Conformed Objective-C Bridgable Pure Swift Objects
    public func encode<T: AnyObject
        where T: _ObjectiveCBridgeable, T: NSCoding>
        (value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        encoder.encodeObject(value?._bridgeToObjectiveC(), forKey: key.rawValue)
    }
    
    public func decodeForKey<T: AnyObject
        where T: _ObjectiveCBridgeable, T: NSCoding>
        (key: Key,
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
    
    //MARK: - NSObject and Its Descendants
    public func encode<T: NSObject>(
        value: T?,
        forKey key: Key,
        to encoder: NSCoder)
    {
        encoder.encodeObject(value, forKey: key.rawValue)
    }
    
    public func decodeForKey<T: AnyObject>(key: Key, from decoder: NSCoder)
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
