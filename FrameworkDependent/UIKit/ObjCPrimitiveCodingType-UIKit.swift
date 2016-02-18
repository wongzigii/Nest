//
//  ObjCCodingPrimitiveType+UIKit.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import UIKit

extension UIEdgeInsets: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeUIEdgeInsets(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UIEdgeInsets
    {
        return decoder.decodeUIEdgeInsetsForKey(key)
    }
}

extension UIOffset: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeUIOffset(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> UIOffset
    {
        return decoder.decodeUIOffsetForKey(key)
    }
}
