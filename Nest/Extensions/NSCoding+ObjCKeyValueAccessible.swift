//
//  NSCoding+ObjCKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 11/20/15.
//
//

import Foundation

extension NSCoding where Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    //MARK: - Objective-C Primitive Coding Types
    public func encode<T: ObjCPrimitiveCodingType>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    public func decode<T: ObjCPrimitiveCodingType>(
        decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeForKey(key.rawValue)
    }
    
    //MARK: Overload for ObjCPrimitiveCodingType and _ObjectiveCBridgeable
    public func encode<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    public func decode<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeForKey(key.rawValue)
    }
    
    //MARK: - RawRepresentable with Objective-C Primitive Coding Raw Type
    public func encode<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    public func decode<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeForKey(key.rawValue)
    }
    
    //MARK: - Objective-C Bridgeable Swift Value Types
    public func encode<T: _ObjectiveCBridgeable>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    public func decode<T: _ObjectiveCBridgeable>(
        decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeForKey(key.rawValue)
    }
    
    //MARK: - NSCoding Conformed Objective-C Bridgable Pure Swift Objects
    public func encode<T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    public func decode<T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeForKey(key.rawValue)
    }
    
    //MARK: - NSObject and Its Descendants
    public func encode<T: NSObject>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    public func decode<T: AnyObject>(decoder: NSCoder, forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeForKey(key.rawValue)
    }
    
    public func decode<T: NSObject where T: NSCoding>(
        decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeForKey(key.rawValue)
    }
}
