//
//  ObjCPrimitiveCodingType+AVFoundation.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import AVFoundation
import Foundation

// Specialization for CoreMedia types
extension CMTime: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCMTime(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CMTime
    {
        return decoder.decodeCMTimeForKey(key)
    }
}

extension CMTimeRange: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCMTimeRange(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CMTimeRange
    {
        return decoder.decodeCMTimeRangeForKey(key)
    }
}

extension CMTimeMapping: ObjCPrimitiveCodingType {
    public func encodeTo(encoder: NSCoder, forKey key: String) {
        encoder.encodeCMTimeMapping(self, forKey: key)
    }
    
    public static func decodeFrom(decoder: NSCoder, forKey key: String)
        -> CMTimeMapping
    {
        return decoder.decodeCMTimeMappingForKey(key)
    }
}
