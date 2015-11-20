//
//  ObjCKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

public protocol ObjCKeyValueAccessibleKeyType:
    RawRepresentable,
    StringLiteralConvertible,
    Hashable
{
    typealias ExtendedGraphemeClusterLiteralType = String
    typealias UnicodeScalarLiteralType = String
    typealias StringLiteralType = String
    typealias RawValue = String
    init(rawValue: Self.RawValue)
}

public protocol ObjCKeyValueAccessible {
    typealias Key: ObjCKeyValueAccessibleKeyType
}

extension ObjCKeyValueAccessible where Self: NSObject,
    Self.Key.RawValue == String
{
    public subscript (key: Key) -> AnyObject? {
        get { return valueForKey(key.rawValue) }
        mutating set { setValue(newValue, forKey: key.rawValue) }
    }
    
    public subscript (keys: Key...) -> [Key: AnyObject] {
        get {
            var results = [Key: AnyObject]()
            for each in keys { results[each] = self[each] }
            return results
        }
        set { for (key, value) in newValue { self[key] = value } }
    }
}

extension ObjCKeyValueAccessibleKeyType where RawValue == String,
    ExtendedGraphemeClusterLiteralType == String,
    UnicodeScalarLiteralType == String,
    StringLiteralType == String
{
    public init(extendedGraphemeClusterLiteral
        value: Self.ExtendedGraphemeClusterLiteralType)
    {
        self.init(rawValue: value)
    }
    
    public init(unicodeScalarLiteral value: Self.UnicodeScalarLiteralType) {
        self.init(rawValue: value)
    }
    
    public init(stringLiteral value: Self.StringLiteralType) {
        self.init(rawValue: value)
    }
    
    public var hashValue: Int { return rawValue.hashValue }
}