//
//  NSCoder+InterfaceNormalization.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import Foundation

public enum NSCoderDecodingError: ErrorType {
    case NoValueForKey(key: String)
    
    case InvalidRawValue(key: String, rawValue: Any, type: Any.Type)
    
    case BridgingFailed(key: String, value: Any, type: Any.Type)
    
    case TypeCastingFailed(key: String, value: Any, type: Any.Type)
    
    case InternalInconsistency(key: String)
    
    public var key: String {
        switch self {
        case let .NoValueForKey(key):           return key
        case let .InvalidRawValue(key, _, _):   return key
        case let .TypeCastingFailed(key, _, _): return key
        case let .BridgingFailed(key, _, _):    return key
        case let .InternalInconsistency(key):   return key
        }
    }
}

//MARK: Encoding
extension NSCoder {
    //MARK: - Objective-C Primitive Coding Types
    public func encode<T: ObjCPrimitiveCodingType>(
        value: T?,
        forKey key: String)
    {
        value?.encodeTo(self, forKey: key)
    }
    
    //MARK: Overload for ObjCPrimitiveCodingType and _ObjectiveCBridgeable
    public func encode<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>
        (value: T?,
        forKey key: String)
    {
        value?.encodeTo(self, forKey: key)
    }
    
    //MARK: - RawRepresentable with Objective-C Primitive Coding Raw Type
    public func encode<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (value: T?,
        forKey key: String)
    {
        value?.rawValue.encodeTo(self, forKey: key)
    }
    
    //MARK: - Objective-C Bridgeable Swift Value Types
    public func encode<T: _ObjectiveCBridgeable>(
        value: T?,
        forKey key: String)
    {
        encodeObject(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: - NSCoding Conformed Objective-C Bridgable Pure Swift Objects
    public func encode<T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (value: T?,
        forKey key: String)
    {
        encodeObject(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    //MARK: - NSObject and Its Descendants
    public func encode<T: NSObject>(value: T?, forKey key: String) {
        encodeObject(value, forKey: key)
    }
}

//MARK: Throwing Decoding
/** Throwing Decoding Accessors Design Notes:

- Because of a compiler bug existed from Swift 1.1 to Swift 2.1, Swift object is
not able to deinit partial initialized object, and you must declare all
encoddeable properties in a class to be type of ImplicitUnwrappedOptional<T>.

- Because Swift doesn't support coupling initialization(such as class A has a 
property of instance of class B and class B has a property of instance of class
A), you must set the property at least after the first phase of initialization.
That mean the property must to be defined as ImplicitUnwrappedOptional value.

- To make the accessors to be compatible with both implicit unwrapped optional 
values and non-null values, the return value is wrapped with an 
`ImplicitUnwrappedOptional` container.
*/
extension NSCoder {
    public func decodeOrThrowForKey<T: ObjCPrimitiveCodingType>(key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodingError.NoValueForKey(key: key)
        }
        
        return T.decodeFrom(self, forKey: key)
    }
    
    public func decodeOrThrowForKey<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodingError.NoValueForKey(key: key)
        }
        
        return T.decodeFrom(self, forKey: key)
    }
    
    public func decodeOrThrowForKey<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodingError.NoValueForKey(key: key)
        }
        
        let rawValue = T.RawValue.decodeFrom(self, forKey: key)
        guard let value = T(rawValue: rawValue) else {
            throw NSCoderDecodingError.InvalidRawValue(
                key: key,
                rawValue: rawValue,
                type: T.self)
        }
        
        return value
    }
    
    public func decodeOrThrowForKey<T: _ObjectiveCBridgeable>(key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodingError.NoValueForKey(key: key)
        }
        
        guard let object = decodeObjectForKey(key) else {
            throw NSCoderDecodingError.InternalInconsistency(key: key)
        }
        
        var value: T?
        
        T._forceBridgeFromObjectiveC(
            object as! T._ObjectiveCType,
            result: &value)
        
        guard let concreteValue = value  else {
            throw NSCoderDecodingError.BridgingFailed(
                key: key,
                value: object,
                type: T.self)
        }
        
        return concreteValue
    }
    
    public func decodeOrThrowForKey<T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodingError.NoValueForKey(key: key)
        }
        
        guard let object = decodeObjectForKey(key) else {
            throw NSCoderDecodingError.InternalInconsistency(key: key)
        }
        
        var value: T?
        
        T._forceBridgeFromObjectiveC(
            object as! T._ObjectiveCType,
            result: &value)
        
        guard let concreteValue = value  else {
            throw NSCoderDecodingError.BridgingFailed(
                key: key,
                value: object,
                type: T.self)
        }
        
        return concreteValue
    }
    
    public func decodeOrThrowForKey<T: AnyObject>(key: String) throws -> T! {
        guard containsValueForKey(key) else {
            throw NSCoderDecodingError.NoValueForKey(key: key)
        }
        
        guard let object = decodeObjectForKey(key) else {
            throw NSCoderDecodingError.InternalInconsistency(key: key)
        }
        
        guard let objectAsSpecifiedType = object as? T else {
            throw NSCoderDecodingError.TypeCastingFailed(
                key: key,
                value: object,
                type: T.self)
        }
        
        return objectAsSpecifiedType
    }
    
    public func decodeOrThrowForKey<T: NSObject where T: NSCoding>(key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodingError.NoValueForKey(key: key)
        }
        
        guard let object = decodeObjectOfClass(T.self, forKey: key) else {
            // We don't need to check decoder's requiresSecureCoding property
            // because system throws exception on behalf of ourselves when
            // requiresSecureCoding responds to true but NSSecureCoding was not
            // implemented.
            // Once the program went to here, that meant it can only be a type
            // casting failure where decoder's requiresSecureCoding responded to
            // false.
            guard let object = decodeObjectForKey(key) else {
                fatalError("The decoder hints it contains value for key(\"\(key)\") but resulted in decoded with a nil value")
            }
            
            throw NSCoderDecodingError.TypeCastingFailed(
                key: key,
                value: object,
                type: T.self)
        }
        
        return object
    }
}

//MARK: Maybe Decoding
extension NSCoder {
    public func decodeForKey<T: ObjCPrimitiveCodingType>(key: String)
        -> T?
    {
        return try? decodeOrThrowForKey(key)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        key: String)
        -> T?
    {
        return try? decodeOrThrowForKey(key)
    }
    
    public func decodeForKey<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (key: String)
        -> T?
    {
        return try? decodeOrThrowForKey(key)
    }
    
    public func decodeForKey<T: _ObjectiveCBridgeable>(key: String)
        -> T?
    {
        return try? decodeOrThrowForKey(key)
    }
    
    public func decodeForKey<T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (key: String)
        -> T?
    {
        return try? decodeOrThrowForKey(key)
    }
    
    public func decodeForKey<T: AnyObject>(key: String) -> T? {
        return try? decodeOrThrowForKey(key)
    }
    
    public func decodeForKey<T: NSObject where T: NSCoding>(key: String)
        -> T?
    {
        return try? decodeOrThrowForKey(key)
    }
}

//MARK: Fallback Decoding
extension NSCoder {
    public func decodeForKey<T: ObjCPrimitiveCodingType>
        (key: String,
        @noescape fallBack: (error: NSCoderDecodingError) throws -> T)
        rethrows
        -> T
    {
        do {
            return try decodeOrThrowForKey(key)
        } catch let codeError as NSCoderDecodingError {
            return try fallBack(error: codeError)
        } catch let error {
            fatalError("Unexpected Error: \(error)")
        }
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>
        (key: String,
        @noescape fallBack: (error: NSCoderDecodingError) throws -> T)
        rethrows
        -> T
    {
        do {
            return try decodeOrThrowForKey(key)
        } catch let codeError as NSCoderDecodingError {
            return try fallBack(error: codeError)
        } catch let error {
            fatalError("Unexpected Error: \(error)")
        }
    }
    
    public func decodeForKey<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (key: String,
        @noescape fallBack: (error: NSCoderDecodingError) throws -> T)
        rethrows
        -> T
    {
        do {
            return try decodeOrThrowForKey(key)
        } catch let codeError as NSCoderDecodingError {
            return try fallBack(error: codeError)
        } catch let error {
            fatalError("Unexpected Error: \(error)")
        }
    }
    
    public func decodeForKey<T: _ObjectiveCBridgeable>
        (key: String,
        @noescape fallBack: (error: NSCoderDecodingError) throws -> T)
        rethrows
        -> T
    {
        do {
            return try decodeOrThrowForKey(key)
        } catch let codeError as NSCoderDecodingError {
            return try fallBack(error: codeError)
        } catch let error {
            fatalError("Unexpected Error: \(error)")
        }
    }
    
    public func decodeForKey<T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (key: String,
        @noescape fallBack: (error: NSCoderDecodingError) throws -> T)
        rethrows
        -> T
    {
        do {
            return try decodeOrThrowForKey(key)
        } catch let codeError as NSCoderDecodingError {
            return try fallBack(error: codeError)
        } catch let error {
            fatalError("Unexpected Error: \(error)")
        }
    }
    
    public func decodeForKey<T: AnyObject>
        (key: String,
        @noescape fallBack: (error: NSCoderDecodingError) throws -> T)
        rethrows
        -> T
    {
        do {
            return try decodeOrThrowForKey(key)
        } catch let codeError as NSCoderDecodingError {
            return try fallBack(error: codeError)
        } catch let error {
            fatalError("Unexpected Error: \(error)")
        }
    }
    
    public func decodeForKey<T: NSObject where T: NSCoding>
        (key: String,
        @noescape fallBack: (error: NSCoderDecodingError) throws -> T)
        rethrows
        -> T
    {
        do {
            return try decodeOrThrowForKey(key)
        } catch let codeError as NSCoderDecodingError {
            return try fallBack(error: codeError)
        } catch let error {
            fatalError("Unexpected Error: \(error)")
        }
    }
}