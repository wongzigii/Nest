//
//  ObjCKeyValueAccessibleKeyType.swift
//  Nest
//
//  Created by Manfred on 12/6/15.
//
//

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