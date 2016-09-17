//
//  objCTypeEncoding.swift
//  Nest
//
//  Created by Manfred on 12/6/15.
//
//

import Foundation

public protocol ObjCTypeEncoding {
    static var objCTypeEncoding: String { get }
}

//MARK: General Extension
extension ObjCTypeEncoding {
    public var objCTypeEncoding: String {
        return Self.objCTypeEncoding
    }
}

//MARK: - Specializaiton for Scalar Values
extension Int: ObjCTypeEncoding {
    public static var objCTypeEncoding: String {
        #if arch(x86_64) || arch(arm64)
            return "q"
        #else
            return "i"
        #endif
    }
}

extension Int8: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "c" }
}

extension Int16: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "s" }
}

extension Int32: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "i" }
}

extension Int64: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "q" }
}

// Specialization for unsigned integer types
extension UInt: ObjCTypeEncoding {
    public static var objCTypeEncoding: String {
        #if arch(x86_64) || arch(arm64)
            return "Q"
        #else
            return "I"
        #endif
    }
}

extension UInt8: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "C" }
}

extension UInt16: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "S" }
}

extension UInt32: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "I" }
}

extension UInt64: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "Q" }
}

// Specialization for floating point types
extension Float: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "f" }
}

extension Double: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "d" }
}

// Specialization for boolean types
extension Bool: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "B" }
}

extension ObjCBool: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "B" }
}

extension NSObject: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return "@" }
}

extension Selector: ObjCTypeEncoding {
    public static var objCTypeEncoding: String { return ":" }
}

// Specialization for Foundation structs
extension NSRange: ObjCTypeEncoding {
    public static var objCTypeEncoding: String {
        return "{name=_NSRange}"
    }
}
