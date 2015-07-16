//
//  NSRange+NSRangeMake.swift
//  Nest
//
//  Created by Manfred Lau on 1/4/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Foundation

@available(iOS, introduced=8.0, deprecated=9.0, message="Use the designated initializer instead")
public func NSRangeMake(location: Int, _ length: Int) -> NSRange {
    return NSMakeRange(location, length)
}