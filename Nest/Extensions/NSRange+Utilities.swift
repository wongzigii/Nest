//
//  NSRange+Utilities.swift
//  Nest
//
//  Created by Manfred on 12/15/15.
//
//

import Foundation

extension NSRange: Equatable {
    
}

extension NSRange: Hashable {
    public var hashValue: Int {
        return NSStringFromRange(self).hashValue
    }
}

extension NSRange {
    public var max: Int {
        return NSMaxRange(self)
    }
    
    public static var zero: NSRange {
        return NSRange(location: 0, length: 0)
    }
}

extension NSRange {
    public func contains(_ otherRange: NSRange) -> Bool {
        return (otherRange.location >= location && otherRange.max <= max)
    }
    
    public func intersects(_ otherRange: NSRange) -> Bool {
        return !(location > otherRange.max && otherRange.max < location)
    }
}

extension NSRange {
    public init(string: String) {
        self = NSRange(
            location: 0,
            length: (string as NSString).length)
    }
    
    public init(attributedString: NSAttributedString) {
        self = NSRange(
            location: 0,
            length: attributedString.length)
    }
}

public func == (lhs: NSRange, rhs: NSRange) -> Bool {
    return lhs.location == rhs.location && lhs.length == rhs.length
}

extension NSRange: CustomStringConvertible {
    public var description: String {
        return "<\(type(of: self)); location = \(location); length = \(length)>"
    }
}
