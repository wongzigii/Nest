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
    public func encode<T: ObjCCodingPrimitive>(
        _ value: T?,
        for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    //MARK: ObjCCodingPrimitive and _ObjectiveCBridgeable
    public func encode<
        T: ObjCCodingPrimitive & _ObjectiveCBridgeable
        >(
        _ value: T?, for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    //MARK: RawRepresentable with ObjCCodingPrimitive conformed RawValue
    public func encode<T: RawRepresentable>(
        _ value: T?,
        for key: String
        ) where
        T.RawValue: ObjCCodingPrimitive
    {
        value?.rawValue.encode(to: self, for: key)
    }
    
    //MARK: _ObjectiveCBridgeable Swift Value Types
    public func encode<T: _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        )
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: NSCoding Conformed _ObjectiveCBridgeable Dedicated Swift Objects
    public func encode<T: AnyObject & _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        ) where
        T._ObjectiveCType: NSCoding
        
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
    
    //MARK: NSCoding Conformed ObjCBridgeable Dedicated Swift Objects
    public func encode<T: AnyObject & ObjCBridgeable>(
        _ value: T?, for key: String
        ) where
        T._ObjectiveCType: NSCoding
        
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: ObjCBridgeable & _ObjectiveCBridgeable Swift Value Types
    public func encode<T: ObjCBridgeable & _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        )
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: NSCoding Conformed ObjCBridgeable & _ObjectiveCBridgeable Dedicated Swift Objects
    public func encode<T: AnyObject & ObjCBridgeable & _ObjectiveCBridgeable>(
        _ value: T?, for key: String
        ) where
        T._ObjectiveCType: NSCoding
        
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: NSObject and Its Descendants
    public func encode<T: NSObject>(_ value: T?, for key: String) {
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
    public func decodeOrThrow<T: ObjCCodingPrimitive>(for key: String)
        throws
        -> T!
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        return T.decode(from: self, for: key)
    }
    
    public func decodeOrThrow<
        T: ObjCCodingPrimitive & _ObjectiveCBridgeable
        >(for key: String)
        throws
        -> T!
        
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        return T.decode(from: self, for: key)
    }
    
    public func decodeOrThrow<T: RawRepresentable>(for key: String)
        throws
        -> T! where
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
    
    public func decodeOrThrow<T: _ObjectiveCBridgeable>(for key: String)
        throws
        -> T!
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
    
    public func decodeOrThrow<T: AnyObject & _ObjectiveCBridgeable>(
        for key: String
        )
        throws
        -> T! where
        T._ObjectiveCType: NSCoding
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
    
    public func decodeOrThrow<T: ObjCBridgeable>(for key: String)
        throws
        -> T!
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
    
    public func decodeOrThrow<T: AnyObject & ObjCBridgeable>(
        for key: String
        )
        throws
        -> T! where
        T._ObjectiveCType: NSCoding
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
    
    
    public func decodeOrThrow<
        T: ObjCBridgeable & _ObjectiveCBridgeable
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
    
    public func decodeOrThrow<
        T: AnyObject & ObjCBridgeable & _ObjectiveCBridgeable
        >(
        for key: String
        ) throws -> T! where
        T._ObjectiveCType: NSCoding
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
    
    public func decodeOrThrow<T: AnyObject>(for key: String)
        throws
        -> T!
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
    
    public func decodeOrThrow<T: NSObject>(for key: String)
        throws
        -> T! where T: NSCoding
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
    public func decode<T: ObjCCodingPrimitive>(for key: String)
        -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<
        T: ObjCCodingPrimitive & _ObjectiveCBridgeable
        >(for key: String)
        -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: RawRepresentable>(for key: String)
        -> T? where
        T.RawValue: ObjCCodingPrimitive
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: _ObjectiveCBridgeable>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<
        T: AnyObject & _ObjectiveCBridgeable
        >(
        for key: String
        ) -> T?  where
        T._ObjectiveCType: NSCoding
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: ObjCBridgeable>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<
        T: AnyObject & ObjCBridgeable
        >(
        for key: String
        ) -> T?
        where T._ObjectiveCType: NSCoding
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: ObjCBridgeable & _ObjectiveCBridgeable>(
        for key: String
        ) -> T?
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: AnyObject & ObjCBridgeable & _ObjectiveCBridgeable>(
        for key: String
        ) -> T? where
        T._ObjectiveCType: NSCoding
    {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: AnyObject>(for key: String) -> T? {
        return try? decodeOrThrow(for: key)
    }
    
    public func decode<T: NSObject>(for key: String)
        -> T? where
        T: NSCoding
    {
        return try? decodeOrThrow(for: key)
    }
}

//MARK: - Fallback-Able Decoding
extension NSCoder {
    public func decode<T: ObjCCodingPrimitive>(
        for key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: ObjCCodingPrimitive & _ObjectiveCBridgeable>(
        for key: String, fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: RawRepresentable>(
        for key: String,
        fallback: T
        )
        -> T where
        T.RawValue: ObjCCodingPrimitive
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: _ObjectiveCBridgeable>(
        for key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<
        T: AnyObject & _ObjectiveCBridgeable
        >(
        for key: String, fallback: T
        )
        -> T where
        T._ObjectiveCType: NSCoding
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: ObjCBridgeable>(
        for key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<
        T: AnyObject & ObjCBridgeable
        >(
        for key: String, fallback: T
        )
        -> T where
        T._ObjectiveCType: NSCoding
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: ObjCBridgeable & _ObjectiveCBridgeable>(
        for key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<
        T: AnyObject & ObjCBridgeable & _ObjectiveCBridgeable
        >(
        for key: String, fallback: T
        )
        -> T where
        T._ObjectiveCType: NSCoding
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: AnyObject>(for key: String, fallback: T)
        -> T
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
    
    public func decode<T: NSObject>(for key: String, fallback: T)
        -> T where T: NSCoding
    {
        do {
            return try decodeOrThrow(for: key)
        } catch _ {
            return fallback
        }
    }
}
