//
//  NSRange+NSRangeMake.swift
//  Nest
//
//  Created by Manfred Lau on 1/4/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Foundation

public func NSRangeMake(location: Int, length: Int) -> NSRange {
    return NSMakeRange(location, length)
}