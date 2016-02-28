//
//  ObjCPrimitiveCodingType-CoreGraphics.swift
//  Nest
//
//  Created by Manfred on 2/16/16.
//
//

import Foundation
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