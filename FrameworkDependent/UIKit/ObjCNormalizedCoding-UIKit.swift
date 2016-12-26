//
//  ObjCNormalizedCoding+UIKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import UIKit

extension UIEdgeInsets: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> UIEdgeInsets
    {
        return decoder.decodeUIEdgeInsets(forKey: key)
    }
}

extension UIOffset: ObjCNormalizedCoding {
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
extension CGVector: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGVector
    {
        return decoder.decodeCGVector(forKey: key)
    }
}

extension CGPoint: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGPoint
    {
        return decoder.decodeCGPoint(forKey: key)
    }
}

extension CGSize: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGSize
    {
        return decoder.decodeCGSize(forKey: key)
    }
}

extension CGRect: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGRect
    {
        return decoder.decodeCGRect(forKey: key)
    }
}

extension CGAffineTransform: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGAffineTransform
    {
        return decoder.decodeCGAffineTransform(forKey: key)
    }
}
