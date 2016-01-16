//
//  NSCoding+ObjCKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 11/20/15.
//
//

import Foundation

//MARK: Encoding
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
    
    //MARK: Overload for ObjCPrimitiveCodingType and _ObjectiveCBridgeable
    public func encode<
        T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    //MARK: - RawRepresentable with Objective-C Primitive Coding Raw Type
    public func encode<
        T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    //MARK: - Objective-C Bridgeable Swift Value Types
    public func encode<T: _ObjectiveCBridgeable>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    //MARK: - NSCoding Conformed Objective-C Bridgable Pure Swift Objects
    public func encode<
        T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
    
    //MARK: - NSObject and Its Descendants
    public func encode<T: NSObject>(
        value: T?,
        to encoder: NSCoder,
        forKey key: Key)
    {
        encoder.encode(value, forKey: key.rawValue)
    }
}

//MARK: Throwing Decoding
/** Throwing Decoding Accessors Design Notes:

- Because of a compiler bug existed from Swift 1.1 to Swift 2.1, Swift object is
not able to deinit partial initialized object, and you must declare all
encoddeable properties in a class to be type of `ImplicitUnwrappedOptional<T>`.

- Because Swift doesn't support coupling initialization(such as class A has a
property of instance of class B and class B has a property of instance of class
A), you must set the property at least after the first phase of initialization.
That mean the property must to be defined as ImplicitUnwrappedOptional value.

- To make the accessors to be compatible with both implicit unwrapped optional
values and non-null values, the return value is wrapped with an
`ImplicitUnwrappedOptional` container.
*/
extension NSCoding where
    Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func decodeOrThrow<T: ObjCPrimitiveCodingType>(
        decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeOrThrowForKey(key.rawValue)
    }
    
    public func decodeOrThrow<
        T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeOrThrowForKey(key.rawValue)
    }
    
    public func decodeOrThrow<
        T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeOrThrowForKey(key.rawValue)
    }
    
    public func decodeOrThrow<T: _ObjectiveCBridgeable>(
        decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeOrThrowForKey(key.rawValue)
    }
    
    public func decodeOrThrow<
        T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeOrThrowForKey(key.rawValue)
    }
    
    public func decodeOrThrow<T: AnyObject>(decoder: NSCoder, forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeOrThrowForKey(key.rawValue)
    }
    
    public func decodeOrThrow<T: NSObject where T: NSCoding>(
        decoder: NSCoder,
        forKey key: Key)
        throws
        -> T!
    {
        return try decoder.decodeOrThrowForKey(key.rawValue)
    }
}

//MARK: Maybe Decoding
extension NSCoding where
    Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func decode<T: ObjCPrimitiveCodingType>(
        decoder: NSCoder,
        forKey key: Key)
        -> T?
    {
        return decoder.decodeForKey(key.rawValue)
    }
    
    public func decode<
        T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        decoder: NSCoder,
        forKey key: Key)
        -> T?
    {
        return decoder.decodeForKey(key.rawValue)
    }
    
    public func decode<
        T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (decoder: NSCoder,
        forKey key: Key)
        -> T?
    {
        return decoder.decodeForKey(key.rawValue)
    }
    
    public func decode<T: _ObjectiveCBridgeable>(
        decoder: NSCoder,
        forKey key: Key)
        -> T?
    {
        return decoder.decodeForKey(key.rawValue)
    }
    
    public func decode<
        T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (decoder: NSCoder,
        forKey key: Key)
        -> T?
    {
        return decoder.decodeForKey(key.rawValue)
    }
    
    public func decode<T: AnyObject>(decoder: NSCoder, forKey key: Key)
        -> T?
    {
        return decoder.decodeForKey(key.rawValue)
    }
    
    public func decode<T: NSObject where T: NSCoding>(
        decoder: NSCoder,
        forKey key: Key)
        -> T?
    {
        return decoder.decodeForKey(key.rawValue)
    }
}

//MARK: Fallback Decoding
extension NSCoding where
    Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func decode<T: ObjCPrimitiveCodingType>
        (decoder: NSCoder,
        forKey key: Key,
        @autoclosure fallback: () -> T)
        -> T
    {
        do {
            return try decoder.decodeOrThrowForKey(key.rawValue)
        } catch _ {
            return fallback()
        }
    }
    
    public func decode<
        T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>
        (decoder: NSCoder,
        forKey key: Key,
        @autoclosure fallback: () -> T)
        -> T
    {
        do {
            return try decoder.decodeOrThrowForKey(key.rawValue)
        } catch _ {
            return fallback()
        }
    }
    
    public func decode<
        T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (decoder: NSCoder,
        forKey key: Key,
        @autoclosure fallback: () -> T)
        -> T
    {
        do {
            return try decoder.decodeOrThrowForKey(key.rawValue)
        } catch _ {
            return fallback()
        }
    }
    
    public func decode<T: _ObjectiveCBridgeable>
        (decoder: NSCoder,
        forKey key: Key,
        @autoclosure fallback: () -> T)
        -> T
    {
        do {
            return try decoder.decodeOrThrowForKey(key.rawValue)
        } catch _ {
            return fallback()
        }
    }
    
    public func decode<
        T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (decoder: NSCoder,
        forKey key: Key,
        @autoclosure fallback: () -> T)
        -> T
    {
        do {
            return try decoder.decodeOrThrowForKey(key.rawValue)
        } catch _ {
            return fallback()
        }
    }
    
    public func decode<T: AnyObject>
        (decoder: NSCoder,
        forKey key: Key,
        @autoclosure fallback: () -> T)
        -> T
    {
        do {
            return try decoder.decodeOrThrowForKey(key.rawValue)
        } catch _ {
            return fallback()
        }
    }
    
    public func decode<T: NSObject where T: NSCoding>
        (decoder: NSCoder,
        forKey key: Key,
        @autoclosure fallback: () -> T)
        -> T
    {
        do {
            return try decoder.decodeOrThrowForKey(key.rawValue)
        } catch _ {
            return fallback()
        }
    }
}
