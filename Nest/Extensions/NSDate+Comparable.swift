//
//  NSDate+Comparable.swift
//  Nest
//
//  Created by Manfred Lau on 10/1/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation

extension NSDate : Comparable {}

public func < (this: NSDate, that: NSDate) -> Bool {
    return this.compare(that) == .OrderedAscending
}

public func <= (this: NSDate, that: NSDate) -> Bool {
    return this.compare(that) != .OrderedDescending
}

public func > (this: NSDate, that: NSDate) -> Bool {
    return this.compare(that) == .OrderedDescending
}

public func >= (this: NSDate, that: NSDate) -> Bool {
    return this.compare(that) != .OrderedAscending
}

public func == (this: NSDate, that: NSDate) -> Bool {
    return this.compare(that) == .OrderedSame
}
