//
//  NSCoder+InterfaceNormalization.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import Foundation

public enum NSCoderDecodingError: Error {
    case noValueForKey(key: String)
    
    case invalidRawValue(key: String, rawValue: Any, type: Any.Type)
    
    case bridgingFailed(key: String, value: Any, type: Any.Type)
    
    case typeCastingFailed(key: String, value: Any, type: Any.Type)
    
    case internalInconsistency(key: String, explanation: String)
    
    public var key: String {
        switch self {
        case let .noValueForKey(key):               return key
        case let .invalidRawValue(key, _, _):       return key
        case let .typeCastingFailed(key, _, _):     return key
        case let .bridgingFailed(key, _, _):        return key
        case let .internalInconsistency(key, _):    return key
        }
    }
}

//MARK: - Encoding
extension NSCoder {
    //MARK: ObjCCodingPrimitive
    public func encode(
        _ value: ObjCCodingPrimitive?,
        for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    //MARK: _ObjectiveCBridgeable Swift Value Types
    public func encode<T: _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        )
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: ObjCBridgeable Swift Value Types
    public func encode<T: ObjCBridgeable>(
        _ value: T?, for key: String
        )
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: NSCoding
    public func encode(_ value: NSCoding?, for key: String) {
        self.encode(value, forKey: key)
    }
    
    //MARK: ObjCCodingPrimitive & _ObjectiveCBridgeable & ObjCBridgeable
    public func encode<T: ObjCCodingPrimitive & _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    public func encode<T: ObjCCodingPrimitive & ObjCBridgeable>(
        _ value: T?, for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    public func encode<
        T: ObjCCodingPrimitive & ObjCBridgeable & _ObjectiveCBridgeable
        >(
        _ value: T?, for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    //MARK: RawRepresentable conformed types
    public func encode<T: RawRepresentable>(
        _ value: T?,
        for key: String
        ) where
        T.RawValue: ObjCCodingPrimitive
    {
        value?.rawValue.encode(to: self, for: key)
    }
    
    public func encode<T: RawRepresentable>(
        _ value: T?,
        for key: String
        ) where
        T.RawValue == String
    {
        self.encode(value?.rawValue._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: ObjCBridgeable & _ObjectiveCBridgeable
    public func encode<T: ObjCBridgeable & _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        )
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: ObjCBridgeable & _ObjectiveCBridgeable & NSCoding Swift Types
    public func encode<T: NSCoding & _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        )
    {
        self.encode(value, forKey: key)
    }
    
    public func encode<T: NSCoding & ObjCBridgeable>(
        _ value: T?, for key: String
        )
    {
        self.encode(value, forKey: key)
    }
    
    public func encode<T: NSCoding & ObjCBridgeable & _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        )
    {
        self.encode(value, forKey: key)
    }
    
    //MARK: NSObject and Its Descendants
    public func encode<T: NSObject>(_ value: T?, for key: String) {
        self.encode(value, forKey: key)
    }
    
    public func encode<T: NSObject>(_ value: T?, for key: String) where
        T: NSCoding
    {
        self.encode(value, forKey: key)
    }
}

//MARK: - Throwing Decoding
/// Throwing Decoding Design Notes
/// ==============================
///
/// `ImplicitlyUnwrappedOptional` wrapped value is ambivalent for 
/// the non-optional's and the optional's. So all these functions return
/// an `ImplicitlyUnwrappedOptional` wrapped value so that we don't have
/// to overload them for the `Optional` wrapped version.
extension NSCoder {
    //MARK: ObjCCodingPrimitive
    public func decodeOrThrow<T: ObjCCodingPrimitive>(for key: String)
        throws
        -> T!
    {
        return try decodeOrThrowObjCCodingPrimitive(for: key)
    }
    
    //MARK: _ObjectiveCBridgeable Swift Value Types
    public func decodeOrThrow<T: _ObjectiveCBridgeable>(for key: String)
        throws
        -> T!
    {
        return try decodeOrThrowObjectiveCBridgeable(for: key)
    }
    
    //MARK: ObjCBridgeable Swift Value Types
    public func decodeOrThrow<T: ObjCBridgeable>(for key: String) throws -> T! {
        return try decodeOrThrowObjCBridgeable(for: key)
    }
    
    //MARK: NSCoding
    public func decodeOrThrow<T: NSCoding>(for key: String) throws -> T! {
        return try decodeOrThrowNSCoding(for: key)
    }
    
    //MARK: ObjCCodingPrimitive & _ObjectiveCBridgeable & ObjCBridgeable
    public func decodeOrThrow<T: ObjCCodingPrimitive & _ObjectiveCBridgeable>(
        for key: String
        ) throws -> T!
    {
        return try decodeOrThrowObjCCodingPrimitive(for: key)
    }
    
    public func decodeOrThrow<T: ObjCCodingPrimitive & ObjCBridgeable>(
        for key: String
        ) throws -> T!
    {
        return try decodeOrThrowObjCCodingPrimitive(for: key)
    }
    
    public func decodeOrThrow<
        T: ObjCCodingPrimitive & ObjCBridgeable & _ObjectiveCBridgeable
        >(
        for key: String
        ) throws -> T!
    {
        return try decodeOrThrowObjCCodingPrimitive(for: key)
    }
    
    //MARK: RawRepresentable
    public func decodeOrThrow<T: RawRepresentable>(for key: String) throws
        -> T! where
        T.RawValue: ObjCCodingPrimitive
    {
        return try decodeOrThrowRawRepresentableOfObjCCodingPrimitive(for: key)
    }
    
    public func decodeOrThrow<T: RawRepresentable>(for key: String) throws
        -> T! where
        T.RawValue == String
    {
        return try decodeOrThrowRawRepresentableOfObjectiveCBridgeable(
            for: key
        )
    }
    
    //MARK: ObjCBridgeable & _ObjectiveCBridgeable Swift Types
    public func decodeOrThrow<T: ObjCBridgeable & _ObjectiveCBridgeable>(
        for key: String
        ) throws -> T!
    {
        return try decodeOrThrowObjectiveCBridgeable(for: key)
    }
    
    //MARK: NSCoding & ObjCBridgeable & _ObjectiveCBridgeable Swift Types
    public func decodeOrThrow<T: NSCoding & _ObjectiveCBridgeable>(
        for key: String
        ) throws -> T!
    {
        return try decodeOrThrowNSCoding(for: key)
    }
    
    public func decodeOrThrow<T: NSCoding & ObjCBridgeable>(
        for key: String
        ) throws -> T!
    {
        return try decodeOrThrowNSCoding(for: key)
    }
    
    
    public func decodeOrThrow<
        T: NSCoding & _ObjectiveCBridgeable & ObjCBridgeable
        >(
        for key: String
        ) throws -> T!
    {
        return try decodeOrThrowNSCoding(for: key)
    }
    
    //MARK: NSObject and Its Descendants
    public func decodeOrThrow<T: NSObject>(for key: String) throws -> T! {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        guard let object = decodeObject(forKey: key) else {
            throw NSCoderDecodingError.internalInconsistency(
                key: key,
                explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
            )
        }
        
        guard let objectAsSpecifiedType = object as? T else {
            throw NSCoderDecodingError.typeCastingFailed(
                key: key,
                value: object,
                type: T.self
            )
        }
        
        return objectAsSpecifiedType
    }
    
    public func decodeOrThrow<T: NSObject>(for key: String) throws -> T! where
        T: NSCoding
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        guard let object = decodeObject(of: T.self, forKey: key) else {
            // We don't need to check the decoder's `requiresSecureCoding`
            // property because system throws exception on behalf of
            // ourselves when `requiresSecureCoding` responds to true but
            // `NSSecureCoding` was not implemented.
            // Once the program went to be here, it only means a type
            // casting failure where decoder's `requiresSecureCoding`
            // responded to false.
            guard let object = decodeObject(forKey: key) else {
                throw NSCoderDecodingError.internalInconsistency(
                    key: key,
                    explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
                )
            }
            
            throw NSCoderDecodingError.typeCastingFailed(
                key: key,
                value: object,
                type: T.self
            )
        }
        
        return object
    }
}

//MARK: - Maybe Decoding
extension NSCoder {
    //MARK: ObjCCodingPrimitive
    public func decode<T: ObjCCodingPrimitive>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    //MARK: _ObjectiveCBridgeable Swift Value Types
    public func decode<T: _ObjectiveCBridgeable>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    //MARK: ObjCBridgeable Swift Value Types
    public func decode<T: ObjCBridgeable>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    //MARK: NSCoding
    public func decode<T: NSCoding>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    //MARK: ObjCCodingPrimitive & _ObjectiveCBridgeable & ObjCBridgeable
    public func decode<T: ObjCCodingPrimitive & _ObjectiveCBridgeable>(
        for key: String
        ) -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: ObjCCodingPrimitive & ObjCBridgeable>(
        for key: String
        ) -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<
        T: ObjCCodingPrimitive & ObjCBridgeable & _ObjectiveCBridgeable
        >(
        for key: String
        ) -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    //MARK: RawRepresentable
    public func decode<T: RawRepresentable>(for key: String)
        -> T? where
        T.RawValue: ObjCCodingPrimitive
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: RawRepresentable>(for key: String) -> T? where
        T.RawValue == String
    {
        return try? decodeOrThrow(for: key)
    }
    
    //MARK: ObjCBridgeable & _ObjectiveCBridgeable Swift Types
    public func decode<T: ObjCBridgeable & _ObjectiveCBridgeable>(
        for key: String
        ) -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    //MARK: NSCoding & ObjCBridgeable & _ObjectiveCBridgeable Swift Types
    public func decode<T: NSCoding & _ObjectiveCBridgeable>(for key: String)
        -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: NSCoding & ObjCBridgeable>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: NSCoding & _ObjectiveCBridgeable & ObjCBridgeable>(
        for key: String
        ) -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    //MARK: NSObject and Its Descendants
    public func decode<T: NSObject>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: NSObject>(for key: String) -> T? where T: NSCoding {
        return try? decodeOrThrow(for: key)
    }
}

// MARK: - Decoding Utilities
extension NSCoder {
    public func decodeOrThrowObjCCodingPrimitive<T: ObjCCodingPrimitive>(
        for key: String
        ) throws -> T!
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        return T.decode(from: self, for: key)
    }
    
    public func decodeOrThrowObjectiveCBridgeable<
        T: _ObjectiveCBridgeable
        >(
        for key: String
        ) throws -> T!
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        guard let object = decodeObject(forKey: key) else {
            throw NSCoderDecodingError.internalInconsistency(
                key: key,
                explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
            )
        }
        
        var value: T?
        
        T._forceBridgeFromObjectiveC(
            object as! T._ObjectiveCType,
            result: &value
        )
        
        guard let bridgedValue = value  else {
            throw NSCoderDecodingError.bridgingFailed(
                key: key,
                value: object,
                type: T.self
            )
        }
        
        return bridgedValue
    }
    
    public func decodeOrThrowObjCBridgeable<T: ObjCBridgeable>(
        for key: String
        ) throws -> T!
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        guard let object = decodeObject(forKey: key) else {
            throw NSCoderDecodingError.internalInconsistency(
                key: key,
                explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
            )
        }
        
        var value: T?
        
        T._forceBridgeFromObjectiveC(
            object as! T._ObjectiveCType,
            result: &value
        )
        
        guard let bridgedValue = value  else {
            throw NSCoderDecodingError.bridgingFailed(
                key: key,
                value: object,
                type: T.self
            )
        }
        
        return bridgedValue
    }
    
    public func decodeOrThrowNSCoding<T: NSCoding>(
        for key: String
        ) throws -> T!
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        guard let object = decodeObject(forKey: key) else {
            throw NSCoderDecodingError.internalInconsistency(
                key: key,
                explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
            )
        }
        
        guard let objectAsSpecifiedType = object as? T else {
            throw NSCoderDecodingError.typeCastingFailed(
                key: key,
                value: object,
                type: T.self
            )
        }
        
        return objectAsSpecifiedType
    }
    
    public func decodeOrThrowRawRepresentableOfObjCCodingPrimitive<
        T: RawRepresentable
        >(
        for key: String
        ) throws -> T! where
        T.RawValue: ObjCCodingPrimitive
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        let rawValue = T.RawValue.decode(from: self, for: key)
        guard let value = T(rawValue: rawValue) else {
            throw NSCoderDecodingError.invalidRawValue(
                key: key,
                rawValue: rawValue,
                type: T.self
            )
        }
        
        return value
    }
    
    public func decodeOrThrowRawRepresentableOfObjectiveCBridgeable<
        T: RawRepresentable
        >(
        for key: String
        ) throws -> T! where
        T.RawValue: _ObjectiveCBridgeable
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        guard let object = decodeObject(forKey: key) else {
            throw NSCoderDecodingError.internalInconsistency(
                key: key,
                explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
            )
        }
        
        var rawValue: T.RawValue?
        
        T.RawValue._forceBridgeFromObjectiveC(
            object as! T.RawValue._ObjectiveCType,
            result: &rawValue
        )
        
        guard let bridgedRawValue = rawValue  else {
            throw NSCoderDecodingError.bridgingFailed(
                key: key,
                value: object,
                type: T.self
            )
        }
        
        guard let value = T(rawValue: bridgedRawValue) else {
            throw NSCoderDecodingError.invalidRawValue(
                key: key,
                rawValue: bridgedRawValue,
                type: T.self
            )
        }
        
        return value
    }
    
    public func decodeOrThrowRawRepresentableOfObjCBridgeable<
        T: RawRepresentable
        >(
        for key: String
        ) throws -> T! where
        T.RawValue: ObjCBridgeable
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        guard let object = decodeObject(forKey: key) else {
            throw NSCoderDecodingError.internalInconsistency(
                key: key,
                explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
            )
        }
        
        var rawValue: T.RawValue?
        
        T.RawValue._forceBridgeFromObjectiveC(
            object as! T.RawValue._ObjectiveCType,
            result: &rawValue
        )
        
        guard let bridgedRawValue = rawValue  else {
            throw NSCoderDecodingError.bridgingFailed(
                key: key,
                value: object,
                type: T.self
            )
        }
        
        guard let value = T(rawValue: bridgedRawValue) else {
            throw NSCoderDecodingError.invalidRawValue(
                key: key,
                rawValue: bridgedRawValue,
                type: T.self
            )
        }
        
        return value
    }
}
