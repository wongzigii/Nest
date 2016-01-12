//
//  NSIndexPath+IndexPathType.swift
//  Nest
//
//  Created by Manfred on 10/2/15.
//
//

import SwiftExt
import Foundation

extension NSIndexPath: HierarchicalIndexType {
    public typealias Index = Int
    
    public var indices: [Int] {
        let indices = UnsafeMutablePointer<Int>.alloc(length)
        getIndexes(indices)
        return Array<Int>(head: indices, length: length)
    }
    
    public func parent() -> Self {
        guard length > 0 else {
            fatalError("Cannot get parent from a zero-length index path.")
        }
        
        let parentLength = max(0, length - 1)
        let indices = UnsafeMutablePointer<Int>.alloc(parentLength)
        getIndexes(indices, range: NSRange(location: 0, length: parentLength))
        
        return self.dynamicType.init(indexes: indices, length: parentLength)
    }
    
    public func childWith(index: Index) -> Self {
        
        let childLength = max(0, length + 1)
        let indices = UnsafeMutablePointer<Int>.alloc(childLength)
        getIndexes(indices)
        indices[max(0, childLength - 1)] = index
        
        return self.dynamicType.init(indexes: indices, length: childLength)
    }
    
    public func predecessor() -> Self {
        guard length > 0 else { return self }
        
        let indices = UnsafeMutablePointer<Int>.alloc(length)
        getIndexes(indices)
        let last = max(0, length - 1)
        let lastIndex = indices[last]
        indices[last] = lastIndex - 1
        
        return self.dynamicType.init(indexes: indices, length: length)
    }
    
    public func successor() -> Self {
        guard length > 0 else { return self }
        
        let indices = UnsafeMutablePointer<Int>.alloc(length)
        getIndexes(indices)
        let last = max(0, length - 1)
        let lastIndex = indices[last]
        indices[last] = lastIndex + 1
        
        return self.dynamicType.init(indexes: indices, length: length)
    }
    
    public func umbrellas(indexPath: NSIndexPath) -> Bool {
        if length < indexPath.length && length > 0 {
            return indices[0] == indexPath.indices[0]
        }
        return false
    }
}






