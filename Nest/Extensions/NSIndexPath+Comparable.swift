//
//  NSIndexPath+Comparable.swift
//  Nest
//
//  Created by Manfred on 9/8/15.
//
//

import Foundation

extension NSIndexPath: Comparable {
}

public func ==(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func >(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}
