//
//  ObjCPrimitiveCodingType+UIKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import UIKit

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
        encoder.encodeCGPoint(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CGPoint?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeCGPointForKey(key)
        }
        return nil
    }
}

extension CGSize: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCGSize(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CGSize?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeCGSizeForKey(key)
        }
        return nil
    }
}

extension CGRect: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCGRect(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CGRect?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeCGRectForKey(key)
        }
        return nil
    }
}

extension CGAffineTransform: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCGAffineTransform(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CGAffineTransform?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeCGAffineTransformForKey(key)
        }
        return nil
    }
}

extension UIEdgeInsets: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeUIEdgeInsets(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> UIEdgeInsets?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeUIEdgeInsetsForKey(key)
        }
        return nil
    }
}

extension UIOffset: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeUIOffset(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> UIOffset?
    {
        if decoder.containsValueForKey(key) {
            return decoder.decodeUIOffsetForKey(key)
        }
        return nil
    }
}
