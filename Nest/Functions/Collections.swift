//
//  Collections.swift
//  Nest
//
//  Created by Manfred Lau on 1/21/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Foundation
import SwiftExt

public func NSContains<C where C: CollectionType, C.Generator.Element: NSObjectProtocol>(domain: C, element: C.Generator.Element) -> Bool {
    for each in domain {
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

public func NSFind<C : CollectionType where C.Generator.Element: NSObjectProtocol>(domain: C, value: C.Generator.Element) -> C.Index? {
    if count(domain) > 0 {
        var index = domain.startIndex
        for each in domain {
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

public func NSIntersected<C : ExtensibleCollectionType where C.Generator.Element : NSObjectProtocol>(collectionA: C, collectionB: C) -> C {
    var newCollection = C()
    
    for eachElement in collectionA {
        if !NSContains(newCollection, eachElement) && NSContains(collectionB, eachElement) {
            newCollection.append(eachElement)
        }
    }
    
    return newCollection
}

public func NSDiff<Seq: SequenceType where Seq.Generator.Element: NSObjectProtocol>
    (from fromSequence: Seq?, to toSequence: Seq?,
    #differences: SequenceDifference,
    unchangedComparator: ((Seq.Generator.Element, Seq.Generator.Element)->Bool) = {$0.isEqual($1)},
    usingClosure changesHandler: (change: SequenceDifference, fromElement: (index: Int, element: Seq.Generator.Element)?, toElement: (index: Int, element: Seq.Generator.Element)?) -> Void)
{
    diff(from: fromSequence, to: toSequence, differences: differences, equalComparator: {$0.isEqual($1)}, unchangedComparator: unchangedComparator, usingClosure: changesHandler)
}

private func NSGetAffectedIndex<I: protocol<Comparable, BidirectionalIndexType>>
    (originalIndex: I, removedIndicesCount: Int)
    -> I
{
    var affectedIndex = originalIndex
    for _ in 0..<removedIndicesCount {
        affectedIndex = affectedIndex.predecessor()
    }
    return affectedIndex
}

public func NSRemove<C : RangeReplaceableCollectionType where
    C.Generator.Element : NSObjectProtocol,
    C.Index: protocol<Comparable, BidirectionalIndexType>>
    (inout collection: C, elements: C)
    -> C
{
    var indices = [Any]()
    
    for eachElement in elements {
        if let index = NSFind(collection, eachElement) {
            indices.append(index)
        }
    }
    
    var removed = C()
    
    var removedIndicesCount = 0
    
    let sortedIndices = indices.sorted {
        if let index1 = $0 as? C.Index,
            let index2 = $1 as? C.Index{
                return index1 < index2
        }
        return true
        } as! [C.Index]
    
    for eachIndex in sortedIndices {
        let finalIndex = NSGetAffectedIndex(eachIndex, removedIndicesCount)
        let target = collection[finalIndex]
        removed.append(target)
        removedIndicesCount += 1
        collection.removeAtIndex(finalIndex)
    }
    
    return removed
}