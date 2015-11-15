//
//  NSCoding+NSKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

extension NSCoding where Self: NSKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func encodeValue<T: NSCodingEncodable>(value: T,
        forKey key: Key,
        to encoder: NSCoder)
    {
        let rawKey = key.rawValue
        value.encodeTo(encoder, forKey: rawKey)
    }
    
    public static func decodeValueForKey<T: NSCodingDecodable>(key: Key,
        from decoder: NSCoder)
        -> T?
    {
        let rawKey = key.rawValue
        return T.decodeFrom(decoder, forKey: rawKey)
    }
    
    public func decodeValueForKey<T: NSCodingDecodable>(key: Key,
        from decoder: NSCoder)
        -> T?
    {
        let rawKey = key.rawValue
        return T.decodeFrom(decoder, forKey: rawKey)
    }
}
