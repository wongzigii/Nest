//
//  ObjCCodingPrimitiveType+AVFoundation.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import AVFoundation
import Foundation

// Specialization for CoreMedia types
extension CMTime: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CMTime
    {
        return decoder.decodeTime(forKey: key)
    }
}

extension CMTimeRange: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CMTimeRange
    {
        return decoder.decodeTimeRange(forKey: key)
    }
}

extension CMTimeMapping: ObjCCodingPrimitiveType {
    public func encode(to encoder: NSCoder, for key: String) {
        encoder.encode(self, forKey: key)
    }
    
    public static func decode(from decoder: NSCoder, for key: String)
        -> CMTimeMapping
    {
        return decoder.decodeTimeMapping(forKey: key)
    }
}
