//
//  NSDate+Comparable.swift
//  Nest
//
//  Created by Manfred Lau on 10/1/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation

extension NSDate : Comparable {}

/**
Returns `true` when the `lhs` is ascending to the `rhs`
*/
public func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

/**
Returns `true` when the `lhs` is not descending to the `rhs`
*/
public func <= (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) != .OrderedDescending
}

/**
Returns `true` when the `lhs` is descending to the `rhs`
*/
public func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

/**
Returns `true` when the `lhs` is not ascending to the `rhs`
*/
public func >= (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) != .OrderedAscending
}

/**
Returns `true` when the `lhs` is equal to the `rhs`
*/
public func == (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}
