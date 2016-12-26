//
//  ObjCPrimitiveCodingType-CoreGraphics.swift
//  Nest
//
//  Created by Manfred on 2/16/16.
//
//

import Foundation
import CoreGraphics

extension CGFloat: ObjCNormalizedCoding {
    public func encode(to encoder: NSCoder, for key: String) {
        #if arch(x86_64) || arch(arm64)
            encoder.encode(Double(self), forKey: key)
        #else
            encoder.encode(Float(self), forKey: key)
        #endif
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CGFloat
    {
        #if arch(x86_64) || arch(arm64)
            return CGFloat(decoder.decodeDouble(forKey: key))
        #else
            return CGFloat(decoder.decodeFloat(forKey: key))
        #endif
    }
}
