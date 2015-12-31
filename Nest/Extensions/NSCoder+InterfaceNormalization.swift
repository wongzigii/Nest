//
//  NSCoder+InterfaceNormalization.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import Foundation

public enum NSCoderDecodeError: ErrorType {
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

extension NSCoder {
    //MARK: - Objective-C Primitive Coding Types
    public func encode<T: ObjCPrimitiveCodingType>(
        value: T?,
        forKey key: String)
    {
        value?.encodeTo(self, forKey: key)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType>(key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodeError.NoValueForKey(key: key)
        }
        
        return T.decodeFrom(self, forKey: key)
    }
    
    //MARK: Overload for ObjCPrimitiveCodingType and _ObjectiveCBridgeable
    public func encode<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>
        (value: T?,
        forKey key: String)
    {
        value?.encodeTo(self, forKey: key)
    }
    
    public func decodeForKey<T: ObjCPrimitiveCodingType
        where T: _ObjectiveCBridgeable>(
        key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodeError.NoValueForKey(key: key)
        }
        
        return T.decodeFrom(self, forKey: key)
    }
    
    //MARK: - RawRepresentable with Objective-C Primitive Coding Raw Type
    public func encode<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (value: T?,
        forKey key: String)
    {
        value?.rawValue.encodeTo(self, forKey: key)
    }
    
    public func decodeForKey<T: RawRepresentable
        where T.RawValue: ObjCPrimitiveCodingType>
        (key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodeError.NoValueForKey(key: key)
        }
        
        let rawValue = T.RawValue.decodeFrom(self, forKey: key)
        guard let value = T(rawValue: rawValue) else {
            throw NSCoderDecodeError.InvalidRawValue(
                key: key,
                rawValue: rawValue,
                type: T.self)
        }
        
        return value
    }
    
    //MARK: - Objective-C Bridgeable Swift Value Types
    public func encode<T: _ObjectiveCBridgeable>(
        value: T?,
        forKey key: String)
    {
        encodeObject(value?._bridgeToObjectiveC(), forKey: key)
    }
    
    public func decodeForKey<T: _ObjectiveCBridgeable>(key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodeError.NoValueForKey(key: key)
        }
        
        guard let object = decodeObjectForKey(key) else {
            throw NSCoderDecodeError.InternalInconsistency(key: key)
        }
        
        var value: T?
        
        T._forceBridgeFromObjectiveC(
            object as! T._ObjectiveCType,
            result: &value)
        
        guard let concreteValue = value  else {
            throw NSCoderDecodeError.BridgingFailed(
                key: key,
                value: object,
                type: T.self)
        }
        
        return concreteValue
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
    
    public func decodeForKey<T: AnyObject
        where T: _ObjectiveCBridgeable,
        T._ObjectiveCType: NSCoding>
        (key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodeError.NoValueForKey(key: key)
        }
        
        guard let object = decodeObjectForKey(key) else {
            throw NSCoderDecodeError.InternalInconsistency(key: key)
        }
        
        var value: T?
        
        T._forceBridgeFromObjectiveC(
            object as! T._ObjectiveCType,
            result: &value)
        
        guard let concreteValue = value  else {
            throw NSCoderDecodeError.BridgingFailed(
                key: key,
                value: object,
                type: T.self)
        }
        
        return concreteValue
    }
    
    //MARK: - NSObject and Its Descendants
    public func encode<T: NSObject>(value: T?, forKey key: String) {
        encodeObject(value, forKey: key)
    }
    
    public func decodeForKey<T: AnyObject>(key: String) throws -> T! {
        guard containsValueForKey(key) else {
            throw NSCoderDecodeError.NoValueForKey(key: key)
        }
        
        guard let object = decodeObjectForKey(key) else {
            throw NSCoderDecodeError.InternalInconsistency(key: key)
        }
        
        guard let objectAsSpecifiedType = object as? T else {
            throw NSCoderDecodeError.TypeCastingFailed(
                key: key,
                value: object,
                type: T.self)
        }
        
        return objectAsSpecifiedType
    }
    
    public func decodeForKey<T: NSObject where T: NSCoding>(key: String)
        throws
        -> T!
    {
        guard containsValueForKey(key) else {
            throw NSCoderDecodeError.NoValueForKey(key: key)
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
            
            throw NSCoderDecodeError.TypeCastingFailed(
                key: key,
                value: object,
                type: T.self)
        }
        
        return object
    }
}
