//
//  ObjCNormalizedCoding.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

public enum ObjCNormalizedCodingDecodeError: Error {
    case noValueForKey(key: String)
    
    case invalidRawValue(key: String, rawValue: Any, type: Any.Type)
    
    case bridgingFailed(key: String, objectiveCValue: Any, type: Any.Type)
    
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

public protocol ObjCNormalizedCoding {
    func encode(to encoder: NSCoder, for key: String)
    static func decode(from decoder: NSCoder, for key: String) throws -> Self
}

// Extension for Signed Integer Types
extension Int: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Int {
        if decoder.containsValue(forKey: key) {
            return decoder.decodeInteger(forKey: key)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension Int8: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Int8 {
        if decoder.containsValue(forKey: key) {
            return Int8(decoder.decodeInt32(forKey: key))
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension Int16: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Int16 {
        if decoder.containsValue(forKey: key) {
            return Int16(decoder.decodeInt32(forKey: key))
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension Int32: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Int32 {
        if decoder.containsValue(forKey: key) {
            return decoder.decodeInt32(forKey: key)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension Int64: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Int64 {
        if decoder.containsValue(forKey: key) {
            return decoder.decodeInt64(forKey: key)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

// Extension for Unsigned Integer Types
extension UInt: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> UInt {
        if decoder.containsValue(forKey: key) {
            return UInt(decoder.decodeInteger(forKey: key))
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension UInt8: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> UInt8 {
        if decoder.containsValue(forKey: key) {
            return UInt8(decoder.decodeInt32(forKey: key))
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension UInt16: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> UInt16 {
        if decoder.containsValue(forKey: key) {
            return UInt16(decoder.decodeInt32(forKey: key))
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension UInt32: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int32(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> UInt32 {
        if decoder.containsValue(forKey: key) {
            return UInt32(decoder.decodeInt32(forKey: key))
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension UInt64: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(Int64(self), forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> UInt64 {
        if decoder.containsValue(forKey: key) {
            return UInt64(decoder.decodeInt64(forKey: key))
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

// Extension for Floating Point Types
extension Float: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Float {
        if decoder.containsValue(forKey: key) {
            return decoder.decodeFloat(forKey: key)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

extension Double: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Double {
        if decoder.containsValue(forKey: key) {
            return decoder.decodeDouble(forKey: key)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

// Extension for NSObject
extension NSObject: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Self {
        if decoder.containsValue(forKey: key) {
            guard let decoded = decoder.decodeObject(forKey: key) else {
                throw ObjCNormalizedCodingDecodeError.internalInconsistency(
                    key: key,
                    explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
                )
            }
            
            let asAnyObject = decoded as AnyObject
            
            // Casting between two object references always successes.
            return unsafeBitCast(asAnyObject, to: self)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

// Extension for UnsafeMutableBufferPointer
extension UnsafeMutableBufferPointer: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        let length = self.count * MemoryLayout<Element>.size
        let base = UnsafeRawPointer(baseAddress)
        encoder.encodeBytes(base, length: length)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> UnsafeMutableBufferPointer<Element> {
        if decoder.containsValue(forKey: key) {
            var length: Int = 0
            
            guard let bytes = decoder.decodeBytes(
                forKey: key, returnedLength: &length
                ) else {
                throw ObjCNormalizedCodingDecodeError.internalInconsistency(
                    key: key,
                    explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
                )
            }
            
            let capacity = length / MemoryLayout<Element>.size
            let elements = bytes.withMemoryRebound(
                to: Element.self, capacity: capacity, {$0}
            )
            let baseAddress = UnsafeMutablePointer(mutating: elements)
            return UnsafeMutableBufferPointer(start: baseAddress, count: capacity)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

// Extension for UnsafeBufferPointer
extension UnsafeBufferPointer: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        let length = self.count * MemoryLayout<Element>.size
        let base = UnsafeRawPointer(baseAddress)
        encoder.encodeBytes(base, length: length)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> UnsafeBufferPointer {
        if decoder.containsValue(forKey: key) {
            var length: Int = 0
            
            guard let bytes = decoder.decodeBytes(
                forKey: key, returnedLength: &length
                ) else {
                    throw ObjCNormalizedCodingDecodeError.internalInconsistency(
                        key: key,
                        explanation: "The decoder hints it contains value for key(\"\(key)\") but resulted in a nil decoded value."
                    )
            }
            
            let capacity = length / MemoryLayout<Element>.size
            let elements = bytes.withMemoryRebound(
                to: Element.self, capacity: capacity, {$0}
            )
            let baseAddress = UnsafeMutablePointer(mutating: elements)
            return UnsafeBufferPointer(start: baseAddress, count: capacity)
        } else {
            throw ObjCNormalizedCodingDecodeError.noValueForKey(key: key)
        }
    }
}

// Helper for _ObjectiveCBridgeable
extension _ObjectiveCBridgeable where Self._ObjectiveCType: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        let objcValue = _bridgeToObjectiveC()
        objcValue.encode(to: encoder, for: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Self {
        let objcValue = try _ObjectiveCType.decode(from: decoder, for: key)
        if let value = objcValue as? Self {
            return value
        } else {
            throw ObjCNormalizedCodingDecodeError.bridgingFailed(
                key: key, objectiveCValue: objcValue, type: self
            )
        }
    }
}

extension _ObjectiveCBridgeable where Self: RawRepresentable,
    Self._ObjectiveCType: ObjCNormalizedCoding
{
    public func encode(to encoder: NSCoder, for key: String) {
        let objcValue = _bridgeToObjectiveC()
        objcValue.encode(to: encoder, for: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Self {
        let objcValue = try _ObjectiveCType.decode(from: decoder, for: key)
        if let value = objcValue as? Self {
            return value
        } else {
            throw ObjCNormalizedCodingDecodeError.bridgingFailed(
                key: key, objectiveCValue: objcValue, type: self
            )
        }
    }
}

// Helper for RawRepresentable
extension RawRepresentable where Self.RawValue: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        rawValue.encode(to: encoder, for: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Self {
        let rawValue = try RawValue.decode(from: decoder, for: key)
        if let value = Self(rawValue: rawValue) {
            return value
        } else {
            throw ObjCNormalizedCodingDecodeError.invalidRawValue(
                key: key, rawValue: rawValue, type: self
            )
        }
    }
}

extension RawRepresentable where Self: _ObjectiveCBridgeable,
    Self.RawValue: ObjCNormalizedCoding
{
    public func encode(to encoder: NSCoder, for key: String) {
        rawValue.encode(to: encoder, for: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Self {
        let rawValue = try RawValue.decode(from: decoder, for: key)
        if let value = Self(rawValue: rawValue) {
            return value
        } else {
            throw ObjCNormalizedCodingDecodeError.invalidRawValue(
                key: key, rawValue: rawValue, type: self
            )
        }
    }
}

// Helper for RawRepresentable & _ObjectiveCBridgeable
extension RawRepresentable where Self: _ObjectiveCBridgeable,
    Self.RawValue: ObjCNormalizedCoding,
    Self._ObjectiveCType: ObjCNormalizedCoding
{
    public func encode(to encoder: NSCoder, for key: String) {
        rawValue.encode(to: encoder, for: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String) throws -> Self {
        let rawValue = try RawValue.decode(from: decoder, for: key)
        if let value = Self(rawValue: rawValue) {
            return value
        } else {
            throw ObjCNormalizedCodingDecodeError.invalidRawValue(
                key: key, rawValue: rawValue, type: self
            )
        }
    }
}
