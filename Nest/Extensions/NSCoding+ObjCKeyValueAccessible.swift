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
    public func couldDecodeForKeys(keys: [Key], from decoder: NSCoder) -> Bool {
        for eachKey in keys
            where !decoder.containsValueForKey(eachKey.rawValue)
        {
            return false
        }
        return true
    }
    
    public func couldDecodeForKey(key: Key, from decoder: NSCoder) -> Bool {
        return decoder.containsValueForKey(key.rawValue)
    }
    
    public func encode<T: ObjCEncodable>(value: T,
        forKey key: Key,
        to encoder: NSCoder)
    {
        let rawKey = key.rawValue
        value.encodeTo(encoder, forKey: rawKey)
    }
    
    public static func decodeForKey<T: ObjCDecodable>(key: Key,
        from decoder: NSCoder)
        -> T?
    {
        let rawKey = key.rawValue
        return T.decodeFrom(decoder, forKey: rawKey)
    }
    
    public func decodeForKey<T: ObjCDecodable>(key: Key,
        from decoder: NSCoder)
        -> T?
    {
        let rawKey = key.rawValue
        return T.decodeFrom(decoder, forKey: rawKey)
    }
    
    public func encode<T: NSCoding where T: NSObject>(value: T,
        forKey key: Key,
        to encoder: NSCoder)
    {
        let rawKey = key.rawValue
        encoder.encodeObject(self, forKey: rawKey)
    }
    
    public func decodeForKey<T: NSCoding where T: NSObject>(key: Key,
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
}