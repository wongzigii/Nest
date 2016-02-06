//
//  ObjCPrimitiveCodingType.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

public protocol ObjCPrimitiveCodingType {
    func encodeTo(encoder: NSCoder, for key: String)
    static func decodeFrom(decoder: NSCoder, for key: String) -> Self
}

// Specialization for signed integer types
extension Int: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInteger(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> Int
    {
        return decoder.decodeIntegerForKey(key)
    }
}

extension Int8: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> Int8
    {
        return Int8(decoder.decodeInt32ForKey(key))
    }
}

extension Int16: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> Int16
    {
        return Int16(decoder.decodeInt32ForKey(key))
    }
}

extension Int32: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInt32(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> Int32
    {
        return decoder.decodeInt32ForKey(key)
    }
}

extension Int64: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInt64(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> Int64
    {
        return decoder.decodeInt64ForKey(key)
    }
}

// Specialization for unsigned integer types
extension UInt: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInteger(Int(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UInt
    {
        return UInt(decoder.decodeIntegerForKey(key))
    }
}

extension UInt8: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UInt8
    {
        return UInt8(decoder.decodeInt32ForKey(key))
    }
}

extension UInt16: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UInt16
    {
        return UInt16(decoder.decodeInt32ForKey(key))
    }
}

extension UInt32: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInt32(Int32(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UInt32
    {
        return UInt32(decoder.decodeInt32ForKey(key))
    }
}

extension UInt64: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeInt64(Int64(self), forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UInt64
    {
        return UInt64(decoder.decodeInt64ForKey(key))
    }
}

// Specialization for float point types
extension Float: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeFloat(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> Float
    {
        return decoder.decodeFloatForKey(key)
    }
}

extension Double: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeDouble(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> Double
    {
        return decoder.decodeDoubleForKey(key)
    }
}

