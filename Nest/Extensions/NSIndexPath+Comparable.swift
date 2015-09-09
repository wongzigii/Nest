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
    var lhsIndices = [Int]()
    var rhsIndices = [Int]()
    lhs.getIndexes(&lhsIndices)
    rhs.getIndexes(&rhsIndices)
    return lhsIndices == rhsIndices
}

public func <(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    var lhsIndices = [Int]()
    var rhsIndices = [Int]()
    lhs.getIndexes(&lhsIndices)
    rhs.getIndexes(&rhsIndices)
    
    repeat {
        let lhsFirst = lhsIndices.removeFirst()
        let rhsFirst = rhsIndices.removeFirst()
        
        if lhsFirst == rhsFirst {
            continue
        } else {
            return lhsFirst < rhsFirst
        }
    } while lhsIndices.count > 0 && rhsIndices.count > 0
    
    return lhsIndices.count < rhsIndices.count
}
