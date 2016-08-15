//
//  ObjCCodingPrimitiveType+UIKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import UIKit

extension UIEdgeInsets: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UIEdgeInsets
    {
        return decoder.decodeUIEdgeInsets(forKey: key)
    }
}

extension UIOffset: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UIOffset
    {
        return decoder.decodeUIOffset(forKey: key)
    }
}

//MARK: CoreGraphics Primitive
extension CGVector: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGVector
    {
        return decoder.decodeCGVector(forKey: key)
    }
}

extension CGPoint: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGPoint
    {
        return decoder.decodeCGPoint(forKey: key)
    }
}

extension CGSize: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGSize
    {
        return decoder.decodeCGSize(forKey: key)
    }
}

extension CGRect: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGRect
    {
        return decoder.decodeCGRect(forKey: key)
    }
}

extension CGAffineTransform: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGAffineTransform
    {
        return decoder.decodeCGAffineTransform(forKey: key)
    }
}
