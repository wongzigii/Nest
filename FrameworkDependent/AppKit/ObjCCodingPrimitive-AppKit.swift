//
//  ObjCCodingPrimitive-AppKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import AppKit

extension CGPoint: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGPoint
    {
        return decoder.decodePoint(forKey: key)
    }
}

extension CGSize: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGSize
    {
        return decoder.decodeSize(forKey: key)
    }
}

extension CGRect: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGRect
    {
        return decoder.decodeRect(forKey: key)
    }
}
