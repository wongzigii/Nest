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
}

extension NSRange {
    public func contains(otherRange: NSRange) -> Bool {
        return otherRange.location <= location && otherRange.length <= length
    }
    
    public func intersects(otherRange: NSRange) -> Bool {
        return !(location > otherRange.max && otherRange.max < location)
    }
}

extension NSRange {
    public init(_ string: String) {
        self = NSRange(
            location: 0,
            length: (string as NSString).length)
    }
    
    
    public init(_ attriutedString: NSAttributedString) {
        self = NSRange(
            location: 0,
            length: attriutedString.length)
    }
}

public func == (lhs: NSRange, rhs: NSRange) -> Bool {
    return lhs.location == rhs.location && lhs.length == rhs.length
}