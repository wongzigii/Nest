//
//  ObjCCodingPrimitive+UIKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import UIKit

extension UIEdgeInsets: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UIEdgeInsets
    {
        return decoder.decodeUIEdgeInsets(forKey: key)
    }
}

extension UIOffset: ObjCCodingPrimitive {
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
extension CGVector: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGVector
    {
        return decoder.decodeCGVector(forKey: key)
    }
}

extension CGPoint: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGPoint
    {
        return decoder.decodeCGPoint(forKey: key)
    }
}

extension CGSize: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGSize
    {
        return decoder.decodeCGSize(forKey: key)
    }
}

extension CGRect: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGRect
    {
        return decoder.decodeCGRect(forKey: key)
    }
}

extension CGAffineTransform: ObjCCodingPrimitive {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGAffineTransform
    {
        return decoder.decodeCGAffineTransform(forKey: key)
    }
}
