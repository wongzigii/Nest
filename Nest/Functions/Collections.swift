//
//  Collections.swift
//  Nest
//
//  Created by Manfred Lau on 1/21/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Foundation
import SwiftExt

extension SequenceType where Generator.Element: NSObjectProtocol {
    /// Return `true` iff `x` is in `self`.
    public func containsNSObjectProtocol(element: Generator.Element)
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

extension CollectionType where Generator.Element: NSObjectProtocol {
    
    /// Returns the first index where `value` appears in `self` or `nil` if
    /// `value` is not found.
    ///
    /// - Complexity: O(`self.count`).
    public func indexOfNSObjectProtocol(value: Generator.Element)
        -> Index?
    {
        if count > 0 {
            var index = startIndex
            for each in self {
                if each === value {
                    return index
                } else {
                    if each.isEqual(value) {
                        return index
                    }
                }
                index = index.successor()
            }
        }
        
        return nil
    }
}

extension RangeReplaceableCollectionType where
    Generator.Element : NSObjectProtocol
{
    /// Return all the intersected elements
    public func intersectedWithNSObjectProtocols(collection: Self) -> Self
    {
        var newCollection = Self()
        
        for eachElement in self {
            if (!newCollection.containsNSObjectProtocol(eachElement) &&
                collection.containsNSObjectProtocol(eachElement))
            {
                newCollection.append(eachElement)
            }
        }
        
        return newCollection
    }
}

extension CollectionType where Generator.Element: NSObjectProtocol {
    /// Diff with an `NSObjectProtocol` collection
    public var diffNSObjectProtocolsAndHandle: CollectionDiffer<Self> {
        let differ = self.diffAndHandle
        differ.withEqualityComparator {$0.isEqual($1)}
        differ.withContentComparator {$0.isEqual($1)}
        return differ
    }
}

extension RangeReplaceableCollectionType where
    Generator.Element : NSObjectProtocol,
    Index: protocol<Comparable, BidirectionalIndexType>
{
    /// Remove an `NSObjectProtocol` element
    public mutating func removeNSObjectProtocols(elements: Self) -> Self {
        var indices: [Index] = []
        
        for eachElement in elements {
            if let index = indexOfNSObjectProtocol(eachElement) {
                indices.append(index)
            }
        }
        
        var removed = Self()
        
        var removedIndicesCount = 0
        
        let sortedIndices = indices.sort {$0 < $1}
        
        for eachIndex in sortedIndices {
            let finalIndex = eachIndex.advancedBy(
                removed.endIndex.distanceTo(removed.startIndex))
            let target = self[finalIndex]
            removed.append(target)
            removedIndicesCount += 1
            removeAtIndex(finalIndex)
        }
        
        return removed
    }
}

