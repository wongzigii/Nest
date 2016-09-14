//
//  NSRange+CollectionType.swift
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

import Foundation

extension NSRange: Collection {
    public typealias Element = Int
    public typealias Index = Int
    public typealias IndexDistance = Int
    public typealias Iterator = IndexingIterator<CountableRange<Int>>
    
    public func makeIterator() -> Iterator {
        let range = location..<(location + length)
        return range.makeIterator()
    }
    
    public var count: IndexDistance { return length }
    
    public var startIndex: Index { return location }
    
    public var endIndex: Index { return location + length }
    
    public subscript(position: Index) -> Element {
        precondition(position < length)
        return startIndex + position
    }
    
    public typealias SubSequence = NSRange
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        precondition(bounds.lowerBound >= 0)
        precondition(bounds.upperBound < length)
        return SubSequence(
            location: bounds.lowerBound + location,
            length: bounds.count
        )
    }
    
    public func index(after i: Index) -> Index {
        precondition(i < endIndex)
        return i + 1
    }
    
    public func formIndex(after i: inout Index) {
        precondition(i < endIndex)
        i += 1
    }
}
