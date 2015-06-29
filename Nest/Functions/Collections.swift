//
//  Collections.swift
//  Nest
//
//  Created by Manfred Lau on 1/21/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Foundation
import SwiftExt

extension CollectionType where Generator.Element: NSObjectProtocol {
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

extension ExtensibleCollectionType where
Generator.Element : NSObjectProtocol
{
    public func intersectedWithNSObjectProtocols(
        collection: Self) -> Self
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
    public typealias NSObjectProtocolCollectionElementComparator = (
        Generator.Element, Generator.Element) -> Bool
    
    public typealias NSObjectProtocolCollectionDiffHandler = (
        change: CollectionDiff,
        fromElement: (index: Index, element: Generator.Element)?,
        toElement: (index: Index, element: Generator.Element)?) -> Void
    
    public func diffWithNSObjectProtocols(
        comparedCollection: Self,
        differences: CollectionDiff,
        contentComparator:
        NSObjectProtocolCollectionElementComparator = {$0.isEqual($1)},
        withHandler diffHandler: NSObjectProtocolCollectionDiffHandler)
    {
        self.diff(comparedCollection,
            differences: differences,
            indexComparator: {$0.isEqual($1)},
            contentComparator: contentComparator,
            withHandler: diffHandler)
    }
}

extension RangeReplaceableCollectionType where
    Generator.Element : NSObjectProtocol,
    Index: protocol<Comparable, BidirectionalIndexType>
{
    public mutating func removeNSObjectProtocol(elements: Self) -> Self {
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
            let finalIndex = advance(eachIndex,
                distance(removed.endIndex, removed.startIndex))
            if let target = self[finalIndex] as? Generator.Element
            {
                removed.append(target)
                removedIndicesCount += 1
                removeAtIndex(finalIndex)
            }
        }
        
        return removed
    }
}

