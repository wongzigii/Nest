//
//  objCTypeEncoding.swift
//  Nest
//
//  Created by Manfred on 12/6/15.
//
//

import Foundation

public protocol objCTypeEncoding {
    static var objCTypeEncoding: String { get }
}

//MARK: General Extension
extension objCTypeEncoding {
    public var objCTypeEncoding: String {
        return Self.objCTypeEncoding
    }
}

//MARK: - Specializaiton for Scalar Values
extension Int: objCTypeEncoding {
    public static var objCTypeEncoding: String {
        #if arch(x86_64) || arch(arm64)
            return "q"
        #else
            return "i"
        #endif
    }
}

extension Int8: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "c" }
}

extension Int16: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "s" }
}

extension Int32: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "i" }
}

extension Int64: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "q" }
}

// Specialization for unsigned integer types
extension UInt: objCTypeEncoding {
    public static var objCTypeEncoding: String {
        #if arch(x86_64) || arch(arm64)
            return "Q"
        #else
            return "I"
        #endif
    }
}

extension UInt8: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "C" }
}

extension UInt16: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "S" }
}

extension UInt32: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "I" }
}

extension UInt64: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "Q" }
}

// Specialization for floating point types
extension Float: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "f" }
}

extension Double: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "d" }
}

// Specialization for boolean types
extension Bool: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "B" }
}

extension ObjCBool: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "B" }
}

extension NSObject: objCTypeEncoding {
    public static var objCTypeEncoding: String { return "@" }
}

extension Selector: objCTypeEncoding {
    public static var objCTypeEncoding: String { return ":" }
}

// Specialization for Foundation structs
extension NSRange: objCTypeEncoding {
    public static var objCTypeEncoding: String {
        return "{name=_NSRange}"
    }
}
