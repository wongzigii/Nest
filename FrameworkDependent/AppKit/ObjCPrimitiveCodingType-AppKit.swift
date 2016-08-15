//
//  ObjCCodingPrimitiveType-AppKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import AppKit

extension CGPoint: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGPoint
    {
        return decoder.decodePoint(forKey: key)
    }
}

extension CGSize: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGSize
    {
        return decoder.decodeSize(forKey: key)
    }
}

extension CGRect: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGRect
    {
        return decoder.decodeRect(forKey: key)
    }
}
