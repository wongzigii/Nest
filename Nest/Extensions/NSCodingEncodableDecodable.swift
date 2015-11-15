//
//  NSCodingEncodableDecodable.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

public protocol NSCodingEncodable {
    func encodeTo(encoder: NSCoder, forKey key: String)
}

public enum NSCodingDecodingError<T>: ErrorType {
    // Only occurrs when decoding objects and Swift strings
    case TypeCastingFailed(key: String, type: T.Type)
    case ValueOfTypeForKeyDoesNotExist(key: String, type: T.Type)
}

public protocol NSCodingDecodable {
    static func decodeFrom(decoder: NSCoder, forKey key: String) -> Self?
}

// Specialization for NSObject with NSCoding conformed to
extension NSCoding where Self: NSObject {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeObject(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Self?
    {
        guard decoder.containsValueForKey(key) else { return nil }
        
        guard let object = decoder.decodeObjectOfClass(self, forKey: key) else {
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

extension NSObject: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        fatalError("You should not use this abstract class directly")
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Self?
    {
        fatalError("You should not use this abstract class directly")
    }
}

// Specialization for integer types
extension Int: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInteger(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Int?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeIntegerForKey(key)
        }
        return nil
    }
}

extension Int8: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Int8?
    {
        if decoder.containsValueForKey(key) {
            return Int8(decoder.decodeInt32ForKey(key))
        }
        return nil
    }
}

extension Int16: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Int16?
    {
        if decoder.containsValueForKey(key) {
            return Int16(decoder.decodeInt32ForKey(key))
        }
        return nil
    }
}

extension Int32: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInt32(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Int32?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeInt32ForKey(key)
        }
        return nil
    }
}

extension Int64: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInt64(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Int64?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeInt64ForKey(key)
        }
        return nil
    }
}

// Specialization for unsigned integer types
extension UInt: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInteger(Int(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> UInt?
    {
        if decoder.containsValueForKey(key) {
            return UInt(decoder.decodeIntegerForKey(key))
        }
        return nil
    }
}

extension UInt8: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> UInt8?
    {
        if decoder.containsValueForKey(key) {
            return UInt8(decoder.decodeInt32ForKey(key))
        }
        return nil
    }
}

extension UInt16: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> UInt16?
    {
        if decoder.containsValueForKey(key) {
            return UInt16(decoder.decodeInt32ForKey(key))
        }
        return nil
    }
}

extension UInt32: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> UInt32?
    {
        if decoder.containsValueForKey(key) {
            return UInt32(decoder.decodeInt32ForKey(key))
        }
        return nil
    }
}

extension UInt64: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeInt64(Int64(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> UInt64?
    {
        if decoder.containsValueForKey(key) {
            return UInt64(decoder.decodeInt64ForKey(key))
        }
        return nil
    }
}

// Specialization for float point types
extension Float: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeFloat(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Float?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeFloatForKey(key)
        }
        return nil
    }
}

extension Double: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeDouble(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Double?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeDoubleForKey(key)
        }
        return nil
    }
}

extension String: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeObject(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> String?
    {
        guard decoder.containsValueForKey(key) else { return nil }
        
        guard let string = decoder.decodeObjectForKey(key) as? String else {
            return nil
        }
        return string
    }
}

// Specialization for collection types
extension Array: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        let validElememts = NSMutableArray()
        for each in self {
            switch each {
            case let encodable as NSCoding:
                validElememts.addObject(encodable)
            default:
                break
            }
        }
        encoder.encodeObject(validElememts, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Array<Element>?
    {
        guard decoder.containsValueForKey(key) else { return nil }
        
        guard let array = decoder.decodeObjectForKey(key)
            as? Array<Element> else
        {
            return nil
        }
        return array
    }
}

extension Dictionary: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        let validElememts = NSMutableDictionary()
        for (key, value) in self {
            switch (key, value) {
            case let (encodableKey as protocol<NSCoding, NSCopying>,
                encodableValue as NSCoding):
                validElememts[encodableKey] = encodableValue
            default:
                break
            }
        }
        encoder.encodeObject(validElememts, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Dictionary<Key, Value>?
    {
        guard decoder.containsValueForKey(key) else { return nil }
        
        guard let dictionary = decoder.decodeObjectForKey(key)
            as? Dictionary<Key, Value> else
        {
            return nil
        }
        return dictionary
    }
}

extension Set: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        let validElememts = NSMutableSet()
        for each in self {
            switch each {
            case let encodable as NSCoding:
                validElememts.addObject(encodable)
            default:
                break
            }
        }
        encoder.encodeObject(validElememts, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> Set<Element>?
    {
        guard decoder.containsValueForKey(key) else { return nil }
        
        guard let set = decoder.decodeObjectForKey(key) as? Set<Element> else {
            return nil
        }
        return set
    }
}

// Specialization for CoreMedia types
import AVFoundation

extension CMTime: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCMTime(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CMTime?
    {
        guard decoder.containsValueForKey(key) else { return nil }
        return decoder.decodeCMTimeForKey(key)
    }
}

extension CMTimeRange: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCMTimeRange(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CMTimeRange?
    {
        guard decoder.containsValueForKey(key) else { return nil }
        return decoder.decodeCMTimeRangeForKey(key)
    }
}

extension CMTimeMapping: NSCodingEncodable, NSCodingDecodable {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCMTimeMapping(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CMTimeMapping?
    {
        guard decoder.containsValueForKey(key) else { return nil }
        return decoder.decodeCMTimeMappingForKey(key)
    }
}


