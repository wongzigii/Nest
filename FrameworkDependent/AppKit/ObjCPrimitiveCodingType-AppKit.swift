//
//  ObjCCodingPrimitiveType-AppKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import AppKit

extension CGFloat: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        #if arch(x86_64) || arch(arm64)
            encoder.encodeDouble(Double(self), forKey: key)
        #else
            encoder.encodeFloat(Float(self), forKey: key)
        #endif
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGFloat
    {
        #if arch(x86_64) || arch(arm64)
            return CGFloat(decoder.decodeDoubleForKey(key))
        #else
            return CGFloat(decoder.decodeFloatForKey(key))
        #endif
    }
}

extension CGPoint: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodePoint(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGPoint
    {
        return decoder.decodePointForKey(key)
    }
}

extension CGSize: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeSize(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGSize
    {
        return decoder.decodeSizeForKey(key)
    }
}

extension CGRect: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeRect(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGRect
    {
        return decoder.decodeRectForKey(key)
    }
}