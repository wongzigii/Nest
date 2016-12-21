//
//  NSRange+RandomAccessCollection.swift
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

import Foundation

extension NSRange: RandomAccessCollection {
    public typealias Element = Int
    public typealias Index = Int
    public typealias IndexDistance = Int
    
    public var startIndex: Index { return location }
    
    public var endIndex: Index { return location + length + 1 }
    
    public subscript(position: Index) -> Element {
        precondition(position < length)
        return startIndex + position
    }
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
    public func index(before i: Int) -> Int {
        return i - 1
    }
    
    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return i + n
    }
    
    public func distance(from start: Int, to end: Int) -> Int {
        return end - start
    }
}
