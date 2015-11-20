//
//  NSCoding+ObjCKeyValueAccessible.swift
//  Nest
//
//  Created by Manfred on 11/20/15.
//
//

import Foundation

extension NSCoding where Self: ObjCKeyValueAccessible,
    Self.Key.RawValue == String
{
    public func encodeValue<T: ObjCEncodable>(value: T,
        forKey key: Key,
        to encoder: NSCoder)
    {
        let rawKey = key.rawValue
        value.encodeTo(encoder, forKey: rawKey)
    }
    
    public static func decodeValueForKey<T: ObjCDecodable>(key: Key,
        from decoder: NSCoder)
        -> T?
    {
        let rawKey = key.rawValue
        return T.decodeFrom(decoder, forKey: rawKey)
    }
    
    public func decodeValueForKey<T: ObjCDecodable>(key: Key,
        from decoder: NSCoder)
        -> T?
    {
        let rawKey = key.rawValue
        return T.decodeFrom(decoder, forKey: rawKey)
    }
    
    public func encodeValue<T: NSCoding where T: NSObject>(value: T,
        forKey key: Key,
        to encoder: NSCoder)
    {
        let rawKey = key.rawValue
        encoder.encodeObject(self, forKey: rawKey)
    }
    
    public static func decodeValueForKey<T: NSCoding where T: NSObject>(
        key: Key,
        from decoder: NSCoder)
        -> T?
    {
        let rawKey = key.rawValue
        guard decoder.containsValueForKey(rawKey) else { return nil }
        
        guard let object = decoder.decodeObjectOfClass(T.self,
            forKey: rawKey) else
        {
            // We don't need to check decoder's requiresSecureCoding property
            // because system throws exception on behalf of ourselves when
            // requiresSecureCoding responds to true but NSSecureCoding was not
            // implemented.
            // Once the program went to here, that meant it can only be a type
            // casting failure where decoder's requiresSecureCoding responded to
            // false.
            return nil
        }
        
        return object
    }
    
    public func decodeValueForKey<T: NSCoding where T: NSObject>(key: Key,
        from decoder: NSCoder)
        -> T?
    {
        return self.dynamicType.decodeValueForKey(key, from: decoder)
    }
}