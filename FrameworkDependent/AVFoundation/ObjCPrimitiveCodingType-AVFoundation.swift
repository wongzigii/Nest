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
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCMTime(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CMTime
    {
        return decoder.decodeCMTimeForKey(key)
    }
}

extension CMTimeRange: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCMTimeRange(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CMTimeRange
    {
        return decoder.decodeCMTimeRangeForKey(key)
    }
}

extension CMTimeMapping: ObjCCodingPrimitiveType {
    public func encodeTo(encoder: NSCoder, for key: String) {
        encoder.encodeCMTimeMapping(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, for key: String)
        -> CMTimeMapping
    {
        return decoder.decodeCMTimeMappingForKey(key)
    }
}
