//
//  Collections.swift
//  Nest
//
//  Created by Manfred Lau on 1/21/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Foundation
import SwiftExt

extension Sequence where Iterator.Element: NSObjectProtocol {
    /// Return `true` iff `x` is in `self`.
    public func contains(nsObjectProtocol element: Iterator.Element)
        -> Bool
    {
        for each in self {
            if each === element {
                return true
            } else {
                if each.isEqual(element) {
                    return true
                }
            }
        }
        return false
    }
}

extension Collection where Iterator.Element: NSObjectProtocol {
    /// Returns the first index where `value` appears in `self` or `nil` if
    /// `value` is not found.
    ///
    /// - Complexity: O(`self.count`).
    public func index(ofNSObjectProtocol value: Iterator.Element)
        -> Index?
    {
        return index(where: {value.isEqual($0)})
    }
}

extension RangeReplaceableCollection where
    Iterator.Element : NSObjectProtocol
{
    /// Return all the intersected elements
    public func intersected(withNSObjectProtocols collection: Self)
        -> Self
    {
        var newCollection = Self()
        
        for eachElement in self {
            if (!newCollection.contains(nsObjectProtocol: eachElement) &&
                collection.contains(nsObjectProtocol: eachElement))
            {
                newCollection.append(eachElement)
            }
        }
        
        return newCollection
    }
}

extension RangeReplaceableCollection where
    Iterator.Element : NSObjectProtocol,
    Index: Comparable
{
    /// Remove an `NSObjectProtocol` element
    public mutating func remove(nsObjectProtocols elements: Self)
        -> Self
    {
        var indices: [Index] = []
        
        for eachElement in elements {
            if let index = index(ofNSObjectProtocol: eachElement) {
                indices.append(index)
            }
        }
        
        var removed = Self()
        
        var removedIndicesCount = 0
        
        let sortedIndices = indices.sorted {$0 < $1}
        
        for eachIndex in sortedIndices {
            let finalIndex = index(
                eachIndex,
                offsetBy: removed.distance(
                    from: removed.endIndex, to: removed.startIndex
                )
            )
            let target = self[finalIndex]
            removed.append(target)
            removedIndicesCount += 1
            remove(at: finalIndex)
        }
        
        return removed
    }
}

