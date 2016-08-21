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
    public func encode<T: ObjCCodingPrimitiveType>(
        _ value: T?,
        to encoder: NSCoder,
        for key: Key
        )
    {
        encoder.encode(value, for: key.rawValue)
    }
    
    //MARK: Overload for ObjCCodingPrimitiveType and _ObjectiveCBridgeable
    public func encode<
        T: ObjCCodingPrimitiveType & _ObjectiveCBridgeable
        >(
        _ value: T?,
        to encoder: NSCoder,
        for key: Key
        )
    {
        encoder.encode(value, for: key.rawValue)
    }
    
    //MARK: - RawRepresentable with Objective-C Primitive Coding Raw Type
    public func encode<T: RawRepresentable>(
        _ value: T?,
        to encoder: NSCoder,
        for key: Key
        ) where
        T.RawValue: ObjCCodingPrimitiveType
    {
        encoder.encode(value, for: key.rawValue)
    }
    
    //MARK: - Objective-C Bridgeable Swift Value Types
    public func encode<T: _ObjectiveCBridgeable>(
        _ value: T?,
        to encoder: NSCoder,
        for key: Key
        )
    {
        encoder.encode(value, for: key.rawValue)
    }
    
    //MARK: - NSCoding Conformed Objective-C Bridgable Swift Objects
    public func encode<T: AnyObject & _ObjectiveCBridgeable>(
        _ value: T?,
        to encoder: NSCoder,
        for key: Key
        ) where
        T._ObjectiveCType: NSCoding
    {
        encoder.encode(value, for: key.rawValue)
    }
    
    //MARK: - NSObject and Its Descendants
    public func encode<T: NSObject>(
        _ value: T?,
        to encoder: NSCoder,
        for key: Key
        )
    {
        encoder.encode(value, for: key.rawValue)
    }
}

//MARK: Throwing Decoding
/// Throwing Decoding Design Notes
/// ==============================
///
/// `ImplicitlyUnwrappedOptional` wrapped value is ambivalent for
/// the non-optional's and the optional's. So all these function returns
/// an `ImplicitlyUnwrappedOptional` wrapped value so we don't need to
/// overload the `Optional` wrapped version.
extension NSCoding where
    Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func decodeOrThrow<T: ObjCCodingPrimitiveType>(
        _ decoder: NSCoder,
        for key: Key
        )
        throws
        -> T!
    {
        return try decoder.decodeOrThrow(for: key.rawValue)
    }
    
    public func decodeOrThrow<
        T: ObjCCodingPrimitiveType>(
        _ decoder: NSCoder,
        for key: Key
        )
        throws
        -> T! where
        T: _ObjectiveCBridgeable
    {
        return try decoder.decodeOrThrow(for: key.rawValue)
    }
    
    public func decodeOrThrow<
        T: RawRepresentable>(
        _ decoder: NSCoder,
        for key: Key
        )
        throws
        -> T! where
        T.RawValue: ObjCCodingPrimitiveType
        
    {
        return try decoder.decodeOrThrow(for: key.rawValue)
    }
    
    public func decodeOrThrow<T: _ObjectiveCBridgeable>(
        _ decoder: NSCoder,
        for key: Key
        )
        throws
        -> T!
    {
        return try decoder.decodeOrThrow(for: key.rawValue)
    }
    
    public func decodeOrThrow<
        T: AnyObject>(
        _ decoder: NSCoder,
        for key: Key
        )
        throws
        -> T! where
        T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding
        
    {
        return try decoder.decodeOrThrow(for: key.rawValue)
    }
    
    public func decodeOrThrow<T: AnyObject>(_ decoder: NSCoder, for key: Key)
        throws
        -> T!
    {
        return try decoder.decodeOrThrow(for: key.rawValue)
    }
    
    public func decodeOrThrow<T: NSObject>(
        _ decoder: NSCoder,
        for key: Key
        )
        throws
        -> T! where T: NSCoding
    {
        return try decoder.decodeOrThrow(for: key.rawValue)
    }
}

//MARK: Maybe Decoding
extension NSCoding where Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func decode<T: ObjCCodingPrimitiveType>(
        _ decoder: NSCoder,
        for key: Key
        )
        -> T?
    {
        return decoder.decode(for: key.rawValue)
    }
    
    public func decode<
        T: ObjCCodingPrimitiveType>(
        _ decoder: NSCoder,
        for key: Key
        )
        -> T? where
        T: _ObjectiveCBridgeable
        
    {
        return decoder.decode(for: key.rawValue)
    }
    
    public func decode<
        T: RawRepresentable>(
        _ decoder: NSCoder,
        for key: Key
        )
        -> T? where
        T.RawValue: ObjCCodingPrimitiveType
        
    {
        return decoder.decode(for: key.rawValue)
    }
    
    public func decode<T: _ObjectiveCBridgeable>(
        _ decoder: NSCoder,
        for key: Key
        )
        -> T?
    {
        return decoder.decode(for: key.rawValue)
    }
    
    public func decode<
        T: AnyObject>(
        _ decoder: NSCoder,
        for key: Key
        )
        -> T? where
        T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding
        
    {
        return decoder.decode(for: key.rawValue)
    }
    
    public func decode<T: AnyObject>(_ decoder: NSCoder, for key: Key)
        -> T?
    {
        return decoder.decode(for: key.rawValue)
    }
    
    public func decode<T: NSObject>(
        _ decoder: NSCoder,
        for key: Key
        )
        -> T? where T: NSCoding
    {
        return decoder.decode(for: key.rawValue)
    }
}

//MARK: Fallback Decoding
extension NSCoding where Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func decode<T: ObjCCodingPrimitiveType>(
        _ decoder: NSCoder,
        for key: Key,
        fallback: T
        )
        -> T
    {
        do {
            return try decoder.decodeOrThrow(for: key.rawValue)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<
        T: ObjCCodingPrimitiveType>(
        _ decoder: NSCoder,
        for key: Key,
        fallback: T
        )
        -> T where
        T: _ObjectiveCBridgeable
        
    {
        do {
            return try decoder.decodeOrThrow(for: key.rawValue)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<
        T: RawRepresentable>(
        _ decoder: NSCoder,
        for key: Key,
        fallback: T
        )
        -> T where
        T.RawValue: ObjCCodingPrimitiveType
        
    {
        do {
            return try decoder.decodeOrThrow(for: key.rawValue)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: _ObjectiveCBridgeable
        >(
        _ decoder: NSCoder,
        for key: Key,
        fallback: T
        )
        -> T
    {
        do {
            return try decoder.decodeOrThrow(for: key.rawValue)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<
        T: AnyObject>(
        _ decoder: NSCoder,
        for key: Key,
        fallback: T
        )
        -> T where
        T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding
        
    {
        do {
            return try decoder.decodeOrThrow(for: key.rawValue)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: AnyObject>(
        _ decoder: NSCoder,
        for key: Key,
        fallback: T
        )
        -> T
    {
        do {
            return try decoder.decodeOrThrow(for: key.rawValue)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: NSObject>(
        _ decoder: NSCoder,
        for key: Key,
        fallback: T
        )
        -> T where T: NSCoding
    {
        do {
            return try decoder.decodeOrThrow(for: key.rawValue)
        } catch _ {
            return fallback
        }
    }
}
