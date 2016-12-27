//
//  NSCoder+InterfaceNormalization.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import Foundation

//MARK: - Encoding
extension NSCoder {
    // MARK: No Specialization
    public func encode(_ value: NSCoding?, for key: String) {
        encode(value, forKey: key)
    }
    
    // MARK: With Specialization
    // C(3, 1)
    // MARK: ObjCNormalizedCoding
    public func encode<T: ObjCNormalizedCoding>(
        _ value: T?, for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    // MARK: _ObjectiveCBridgeable
    public func encode<T: _ObjectiveCBridgeable>(_ value: T?, for key: String)
        where T._ObjectiveCType: ObjCNormalizedCoding
    {
        value?.encode(to: self, for: key)
    }
    
    // MARK: RawRepresentable
    public func encode<T: RawRepresentable>(_ value: T?, for key: String) where
        T.RawValue: ObjCNormalizedCoding
    {
        value?.encode(to: self, for: key)
    }
    
    // C(3, 2)
    // MARK: ObjCNormalizedCoding & _ObjectiveCBridgeable
    public func encode<T: ObjCNormalizedCoding & _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    // MARK: ObjCNormalizedCoding & RawRepresentable
    public func encode<T: ObjCNormalizedCoding & RawRepresentable>(
        _ value: T?, for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    // MARK: _ObjectiveCBridgeable & RawRepresentable
    public func encode<T: _ObjectiveCBridgeable & RawRepresentable>(
        _ value: T?, for key: String
    ) where T._ObjectiveCType: ObjCNormalizedCoding
    {
        value?.encode(to: self, for: key)
    }
    
    public func encode<T: _ObjectiveCBridgeable & RawRepresentable>(
        _ value: T?, for key: String
        ) where T.RawValue: ObjCNormalizedCoding
    {
        value?.encode(to: self, for: key)
    }
    
    public func encode<T: _ObjectiveCBridgeable & RawRepresentable>(
        _ value: T?, for key: String
        ) where
        T._ObjectiveCType: ObjCNormalizedCoding,
        T.RawValue: ObjCNormalizedCoding
    {
        value?.encode(to: self, for: key)
    }
    
    // C(3, 3)
    // MARK: ObjCNormalizedCoding & _ObjectiveCBridgeable & RawRepresentable
    public func encode<
        T: ObjCNormalizedCoding & _ObjectiveCBridgeable & RawRepresentable
        >(
        _ value: T?, for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
}

//MARK: - Throwing Decoding
/// Throwing Decoding Design Notes
/// ==============================
///
/// `ImplicitlyUnwrappedOptional` wrapped value is interchangeable for
/// the non-optionals and the optionals. Following functions return an 
/// `ImplicitlyUnwrappedOptional` wrapped value so that we don't have to 
/// overload them for dedicated treating of `Optional`, non-`Optional` and
/// `ImplicitlyUnwrappedOptional`.
extension NSCoder {
    // MARK: With Specialization
    // C(3, 1)
    // MARK: ObjCNormalizedCoding
    public func decodeOrThrow<T: ObjCNormalizedCoding>(
        for key: String
        ) throws -> T!
    {
        return try T.decode(from: self, for: key)
    }
    
    // MARK: _ObjectiveCBridgeable
    public func decodeOrThrow<T: _ObjectiveCBridgeable>(for key: String) throws
        -> T! where T._ObjectiveCType: ObjCNormalizedCoding
    {
        return try T.decode(from: self, for: key)
    }
    
    // MARK: RawRepresentable
    public func decodeOrThrow<T: RawRepresentable>(for key: String) throws -> T!
        where T.RawValue: ObjCNormalizedCoding
    {
        return try T.decode(from: self, for: key)
    }
    
    // C(3, 2)
    // MARK: ObjCNormalizedCoding & _ObjectiveCBridgeable
    public func decodeOrThrow<
        T: ObjCNormalizedCoding & _ObjectiveCBridgeable
        >(
        for key: String
        ) throws -> T!
    {
        return try T.decode(from: self, for: key)
    }
    
    // MARK: ObjCNormalizedCoding & RawRepresentable
    public func decodeOrThrow<T: ObjCNormalizedCoding & RawRepresentable>(
        for key: String
        ) throws -> T!
    {
        return try T.decode(from: self, for: key)
    }
    
    // MARK: _ObjectiveCBridgeable & RawRepresentable
    public func decodeOrThrow<T: _ObjectiveCBridgeable & RawRepresentable>(
        for key: String
        ) throws -> T! where T._ObjectiveCType: ObjCNormalizedCoding
    {
        return try T.decode(from: self, for: key)
    }
    
    public func decodeOrThrow<T: _ObjectiveCBridgeable & RawRepresentable>(
        for key: String
        ) throws -> T! where T.RawValue: ObjCNormalizedCoding
    {
        return try T.decode(from: self, for: key)
    }
    
    public func decodeOrThrow<T: _ObjectiveCBridgeable & RawRepresentable>(
        for key: String
        ) throws -> T! where
        T._ObjectiveCType: ObjCNormalizedCoding,
        T.RawValue: ObjCNormalizedCoding
    {
        return try T.decode(from: self, for: key)
    }
    
    // C(3, 3)
    // MARK: ObjCNormalizedCoding & _ObjectiveCBridgeable & RawRepresentable
    public func decodeOrThrow<
        T: ObjCNormalizedCoding & _ObjectiveCBridgeable & RawRepresentable
        >(
        for key: String
        ) throws -> T!
    {
        return try T.decode(from: self, for: key)
    }
    
    // MARK: Special Treatment for Secure Coding
    public func decodeOrThrow<T: NSObject>(for key: String) throws -> T! where
        T: NSCoding
    {
        if containsValue(forKey: key) {
            guard let decoded = decodeObject(of: T.self, forKey: key) else {
                throw ObjCNormalizedCodingDecodeError.internalInconsistency(
                    key: key,
                    explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
                )
            }
            
            return decoded
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
    
    public func decodeOrThrow<T: NSObject>(
        for key: String, with classes: AnyClass...
        ) throws -> T! where T: NSCoding
    {
        return try decodeOrThrow(for: key, with: classes)
    }
    
    public func decodeOrThrow<T: NSObject>(
        for key: String, with classes: [AnyClass]
        ) throws -> T! where T: NSCoding
    {
        if containsValue(forKey: key) {
            guard let decoded = decodeObject(of: classes, forKey: key) else {
                throw ObjCNormalizedCodingDecodeError.internalInconsistency(
                    key: key,
                    explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
                )
            }
            let asAnyObject = decoded as AnyObject
            return unsafeBitCast(asAnyObject, to: T.self)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

//MARK: - Maybe Decoding
extension NSCoder {
    // MARK: With Specialization
    // C(3, 1)
    // MARK: ObjCNormalizedCoding
    public func decode<T: ObjCNormalizedCoding>(for key: String) -> T? {
        return try? T.decode(from: self, for: key)
    }
    
    // MARK: _ObjectiveCBridgeable
    public func decode<T: _ObjectiveCBridgeable>(for key: String)
        -> T? where T._ObjectiveCType: ObjCNormalizedCoding
    {
        return try? T.decode(from: self, for: key)
    }
    
    // MARK: RawRepresentable
    public func decode<T: RawRepresentable>(for key: String) -> T?
        where T.RawValue: ObjCNormalizedCoding
    {
        return try? T.decode(from: self, for: key)
    }
    
    // C(3, 2)
    // MARK: ObjCNormalizedCoding & _ObjectiveCBridgeable
    public func decode<T: ObjCNormalizedCoding & _ObjectiveCBridgeable>(
        for key: String
        ) -> T?
    {
        return try? T.decode(from: self, for: key)
    }
    
    // MARK: ObjCNormalizedCoding & RawRepresentable
    public func decode<T: ObjCNormalizedCoding & RawRepresentable>(
        for key: String
        ) -> T?
    {
        return try? T.decode(from: self, for: key)
    }
    
    // MARK: _ObjectiveCBridgeable & RawRepresentable
    public func decode<T: _ObjectiveCBridgeable & RawRepresentable>(
        for key: String
        ) -> T? where T._ObjectiveCType: ObjCNormalizedCoding
    {
        return try? T.decode(from: self, for: key)
    }
    
    public func decode<T: _ObjectiveCBridgeable & RawRepresentable>(
        for key: String
        ) -> T? where T.RawValue: ObjCNormalizedCoding
    {
        return try? T.decode(from: self, for: key)
    }
    
    public func decode<T: _ObjectiveCBridgeable & RawRepresentable>(
        for key: String
        ) -> T? where
        T._ObjectiveCType: ObjCNormalizedCoding,
        T.RawValue: ObjCNormalizedCoding
    {
        return try? T.decode(from: self, for: key)
    }
    
    // C(3, 3)
    // MARK: ObjCNormalizedCoding & _ObjectiveCBridgeable & RawRepresentable
    public func decode<
        T: ObjCNormalizedCoding & _ObjectiveCBridgeable & RawRepresentable
        >(
        for key: String
        ) -> T?
    {
        return try? T.decode(from: self, for: key)
    }
    
    // MARK: Special Treatment for Secure Coding
    public func decode<T: NSObject>(for key: String) -> T? where T: NSCoding {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: NSObject>(
        for key: String, with classes: AnyClass...
        ) -> T? where T: NSCoding
    {
        return try? decodeOrThrow(for: key, with: classes)
    }
    
    public func decode<T: NSObject>(
        for key: String, with classes: [AnyClass]
        ) -> T? where T: NSCoding
    {
        return try? decodeOrThrow(for: key, with: classes)
    }
}
