//
//  NSRange+Equatable.swift
//  Nest
//
//  Created by Manfred on 11/16/15.
//
//

import Foundation

extension NSRange: Equatable {
    
}

public func == (lhs: NSRange, rhs: NSRange) -> Bool {
    return lhs.location == rhs.location && lhs.length == rhs.length
}
