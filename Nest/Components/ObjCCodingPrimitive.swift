//
//  ObjCCodingPrimitive.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

public protocol ObjCCodingPrimitive {
    func encode(to encoder: NSCoder, for key: String)
    static func decode(from decoder: NSCoder, for key: String) -> Self
}

// Specialization for signed integer types
extension Int: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> Int
    {
        return decoder.decodeInteger(forKey: key)
    }
}

extension Int8: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> Int8
    {
        return Int8(decoder.decodeInt32(forKey: key))
    }
}

extension Int16: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> Int16
    {
        return Int16(decoder.decodeInt32(forKey: key))
    }
}

extension Int32: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> Int32
    {
        return decoder.decodeInt32(forKey: key)
    }
}

extension Int64: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> Int64
    {
        return decoder.decodeInt64(forKey: key)
    }
}

// Specialization for unsigned integer types
extension UInt: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UInt
    {
        return UInt(decoder.decodeInteger(forKey: key))
    }
}

extension UInt8: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UInt8
    {
        return UInt8(decoder.decodeInt32(forKey: key))
    }
}

extension UInt16: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UInt16
    {
        return UInt16(decoder.decodeInt32(forKey: key))
    }
}

extension UInt32: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UInt32
    {
        return UInt32(decoder.decodeInt32(forKey: key))
    }
}

extension UInt64: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int64(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UInt64
    {
        return UInt64(decoder.decodeInt64(forKey: key))
    }
}

// Specialization for float point types
extension Float: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> Float
    {
        return decoder.decodeFloat(forKey: key)
    }
}

extension Double: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> Double
    {
        return decoder.decodeDouble(forKey: key)
    }
}
