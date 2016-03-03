//
//  NSRange+CollectionType.swift
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

import Foundation

extension NSRange: CollectionType {
    public typealias Element = Int
    
    public typealias Generator = RangeGenerator<Int>
    
    public func generate() -> Generator {
        let range = location..<(location + length)
        return range.generate()
    }
}

extension NSRange: Indexable {
    public typealias Index = Int
    
    public var startIndex: Index { return location }
    
    public var endIndex: Index { return location + length }
    
    public subscript(position: Int) -> Index {
        precondition(position < length)
        return startIndex + position
    }
}
