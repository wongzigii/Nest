//
//  ObjCPrimitiveCodingType-CoreGraphics.swift
//  Nest
//
//  Created by Manfred on 2/16/16.
//
//

import CoreGraphics

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

extension CGVector: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGVector(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGVector
    {
        return decoder.decodeCGVectorForKey(key)
    }
}

extension CGPoint: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGPoint(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGPoint
    {
        return decoder.decodeCGPointForKey(key)
    }
}

extension CGSize: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGSize(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGSize
    {
        return decoder.decodeCGSizeForKey(key)
    }
}

extension CGRect: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGRect(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGRect
    {
        return decoder.decodeCGRectForKey(key)
    }
}

extension CGAffineTransform: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCGAffineTransform(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CGAffineTransform
    {
        return decoder.decodeCGAffineTransformForKey(key)
    }
}
