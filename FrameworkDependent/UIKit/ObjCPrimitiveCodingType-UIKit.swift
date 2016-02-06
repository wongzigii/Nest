//
//  ObjCPrimitiveCodingType+UIKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import UIKit

extension CGFloat: ObjCPrimitiveCodingType {
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

extension CGPoint: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGPoint(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGPoint
    {
        return decoder.decodeCGPointForKey(key)
    }
}

extension CGSize: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGSize(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGSize
    {
        return decoder.decodeCGSizeForKey(key)
    }
}

extension CGRect: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGRect(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGRect
    {
        return decoder.decodeCGRectForKey(key)
    }
}

extension CGAffineTransform: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGAffineTransform(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGAffineTransform
    {
        return decoder.decodeCGAffineTransformForKey(key)
    }
}

extension UIEdgeInsets: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeUIEdgeInsets(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UIEdgeInsets
    {
        return decoder.decodeUIEdgeInsetsForKey(key)
    }
}

extension UIOffset: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeUIOffset(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UIOffset
    {
        return decoder.decodeUIOffsetForKey(key)
    }
}
