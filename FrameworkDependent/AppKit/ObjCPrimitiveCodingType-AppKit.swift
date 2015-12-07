//
//  ObjCPrimitiveCodingType-AppKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import AppKit

extension CGFloat: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        #if arch(x86_64) || arch(arm64)
            encoder.encodeDouble(Double(self), forKey: key)
        #else
            encoder.encodeFloat(Float(self), forKey: key)
        #endif
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CGFloat?
    {
        if decoder.containsValueForKey(key) {
            #if arch(x86_64) || arch(arm64)
                return CGFloat(decoder.decodeDoubleForKey(key))
            #else
                return CGFloat(decoder.decodeFloatForKey(key))
            #endif
        }
        return nil
    }
}

extension CGPoint: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodePoint(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CGPoint?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodePointForKey(key)
        }
        return nil
    }
}

extension CGSize: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeSize(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CGSize?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeSizeForKey(key)
        }
        return nil
    }
}

extension CGRect: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeRect(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CGRect?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeRectForKey(key)
        }
        return nil
    }
}