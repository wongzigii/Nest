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

//MARK: Encoding
extension NSCoder {
    //MARK: - Objective-C Primitive Coding Types
    public func encode<T: ObjCCodingPrimitiveType>(
        _ value: T?,
        for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    //MARK: Overload for ObjCCodingPrimitiveType and _ObjectiveCBridgeable
    public func encode<
        T: ObjCCodingPrimitiveType where
        T: _ObjectiveCBridgeable
        >(
        _ value: T?,
        for key: String
        )
    {
        value?.encode(to: self, for: key)
    }
    
    //MARK: - RawRepresentable with Objective-C Primitive Coding Raw Type
    public func encode<
        T: RawRepresentable where
        T.RawValue: ObjCCodingPrimitiveType
        >(
        _ value: T?,
        for key: String
        )
    {
        value?.rawValue.encode(to: self, for: key)
    }
    
    //MARK: - Objective-C Bridgeable Swift Value Types
    public func encode<
        T: _ObjectiveCBridgeable
        >(
        _ value: T?,
        for key: String
        )
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: - NSCoding Conformed Objective-C Bridgable Pure Swift Objects
    public func encode<
        T: AnyObject where
        T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding
        >(
        _ value: T?,
        for key: String
        )
    {
        self.encode(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: - NSObject and Its Descendants
    public func encode<T: NSObject>(_ value: T?, for key: String) {
        self.encode(value, forKey: key)
    }
}

//MARK: Throwing Decoding
/** Throwing Decoding Accessors Design Notes:

- Because of a compiler bug existed from Swift 1.1 to Swift 2.1, Swift object 
 was unable to deinit partially initialized object, and you have to declare a
 class' encoddeable member property be of type `T` as `T!`.

 - Because Swift doesn't support coupling initialization(such as class A has a
 property of instance of class B and class B has a property of instance of class
 A), you must set the property at least after the first phase of initialization.
 That means the property be type of T have to be defined as `T!`.

 - To make the accessors to be compatible with both implicit unwrapped optional
 values and non-null values, the return value is wrapped with an
 `ImplicitUnwrappedOptional` container.
*/
extension NSCoder {
    public func decodeOrThrowFor<T: ObjCCodingPrimitiveType>(_ key: String)
        throws
        -> T!
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        return T.decode(from: self, for: key)
    }
    
    public func decodeOrThrowFor<
        T: ObjCCodingPrimitiveType where
        T: _ObjectiveCBridgeable
        >(
        _ key: String
        )
        throws
        -> T!
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        return T.decode(from: self, for: key)
    }
    
    public func decodeOrThrowFor<
        T: RawRepresentable where
        T.RawValue: ObjCCodingPrimitiveType
        >(
        _ key: String
        )
        throws
        -> T!
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
    
    public func decodeOrThrowFor<T: _ObjectiveCBridgeable>(_ key: String)
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
    
    public func decodeOrThrowFor<
        T: AnyObject where
        T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding
        >(
        _ key: String
        )
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
    
    public func decodeOrThrowFor<T: AnyObject>(_ key: String) throws -> T! {
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
    
    public func decodeOrThrowFor<T: NSObject where T: NSCoding>(_ key: String)
        throws
        -> T!
    {
        guard containsValue(forKey: key) else {
            throw NSCoderDecodingError.noValueForKey(key: key)
        }
        
        guard let object = decodeObject(of: T.self, forKey: key) else {
            // We don't need to check decoder's `requiresSecureCoding` property
            // because system throws exception on behalf of ourselves when
            // `requiresSecureCoding` responds to true but `NSSecureCoding` was
            // not implemented.
            // Once the program went to here, that meant it can only be a type
            // casting failure where decoder's `requiresSecureCoding` responded
            // to false.
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

//MARK: Maybe Decoding
extension NSCoder {
    public func decodeFor<T: ObjCCodingPrimitiveType>(_ key: String) -> T? {
        return try? decodeOrThrowFor(key)
    }
    
    public func decodeFor<
        T: ObjCCodingPrimitiveType where
        T: _ObjectiveCBridgeable
        >(
        _ key: String
        )
        -> T?
    {
        return try? decodeOrThrowFor(key)
    }
    
    public func decodeFor<
        T: RawRepresentable where
        T.RawValue: ObjCCodingPrimitiveType
        >(
        _ key: String
        )
        -> T?
    {
        return try? decodeOrThrowFor(key)
    }
    
    public func decodeFor<T: _ObjectiveCBridgeable>(_ key: String) -> T? {
        return try? decodeOrThrowFor(key)
    }
    
    public func decodeFor<
        T: AnyObject where
        T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding
        >(
        _ key: String
        )
        -> T?
    {
        return try? decodeOrThrowFor(key)
    }
    
    public func decodeFor<T: AnyObject>(_ key: String) -> T? {
        return try? decodeOrThrowFor(key)
    }
    
    public func decodeFor<T: NSObject where T: NSCoding>(_ key: String) -> T? {
        return try? decodeOrThrowFor(key)
    }
}

//MARK: Fallback Decoding
extension NSCoder {
    public func decodeFor<T: ObjCCodingPrimitiveType>(
        _ key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrowFor(key)
        } catch _ {
            return fallback
        }
    }
    
    public func decodeFor<
        T: ObjCCodingPrimitiveType where
        T: _ObjectiveCBridgeable
        >(
        _ key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrowFor(key)
        } catch _ {
            return fallback
        }
    }
    
    public func decodeFor<
        T: RawRepresentable where
        T.RawValue: ObjCCodingPrimitiveType
        >(
        _ key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrowFor(key)
        } catch _ {
            return fallback
        }
    }
    
    public func decodeFor<T: _ObjectiveCBridgeable>(
        _ key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrowFor(key)
        } catch _ {
            return fallback
        }
    }
    
    public func decodeFor<
        T: AnyObject where
        T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding
        >(
        _ key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrowFor(key)
        } catch _ {
            return fallback
        }
    }
    
    public func decodeFor<T: AnyObject>(
        _ key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrowFor(key)
        } catch _ {
            return fallback
        }
    }
    
    public func decodeFor<T: NSObject where T: NSCoding>(
        _ key: String,
        fallback: T
        )
        -> T
    {
        do {
            return try decodeOrThrowFor(key)
        } catch _ {
            return fallback
        }
    }
}
