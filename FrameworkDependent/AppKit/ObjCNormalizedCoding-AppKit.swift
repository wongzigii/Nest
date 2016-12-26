//
//  ObjCNormalizedCoding-AppKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import AppKit

extension NSPoint: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> NSPoint
    {
        return decoder.decodePoint(forKey: key)
    }
}

extension NSSize: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> NSSize
    {
        return decoder.decodeSize(forKey: key)
    }
}

extension NSRect: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> NSRect
    {
        return decoder.decodeRect(forKey: key)
    }
}
