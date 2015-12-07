//
//  ObjCPrimitiveCodingType.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

public protocol ObjCPrimitiveCodingType {
    func encodeTo(encoder: NSCoder, forKey key: String)
    static func decodeFrom(decoder: NSCoder, forKey key: String) -> Self?
}

// Specialization for signed integer types
extension Int: ObjCPrimitiveCodingType {
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

extension Int8: ObjCPrimitiveCodingType {
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

extension Int16: ObjCPrimitiveCodingType {
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

extension Int32: ObjCPrimitiveCodingType {
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

extension Int64: ObjCPrimitiveCodingType {
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
extension UInt: ObjCPrimitiveCodingType {
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

extension UInt8: ObjCPrimitiveCodingType {
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

extension UInt16: ObjCPrimitiveCodingType {
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

extension UInt32: ObjCPrimitiveCodingType {
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

extension UInt64: ObjCPrimitiveCodingType {
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
extension Float: ObjCPrimitiveCodingType {
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

extension Double: ObjCPrimitiveCodingType {
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

