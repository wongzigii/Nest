//
//  NSIndexPath+IndexPathType.swift
//  Nest
//
//  Created by Manfred on 10/2/15.
//
//

import SwiftExt
import Foundation

extension NSIndexPath: HirarchicalIndexType {
    public typealias Index = Int
    
    public var indices: [Int] {
        var indices = [Int]()
        for position in 0..<length {
            indices.append(indexAtPosition(position))
        }
        return indices
    }
    
    public func predecessor() -> Self {
        guard let lastIndex = self.indices.last else {
            return self
        }
        
        var indices = self.indices
        indices.removeLast()
        indices += lastIndex.predecessor()
        
        return self.dynamicType.init(indexes: indices, length: indices.count)
    }
    
    public func successor() -> Self {
        guard let lastIndex = self.indices.last else {
            return self
        }
        
        var indices = self.indices
        indices.removeLast()
        indices += lastIndex.successor()
        
        return self.dynamicType.init(indexes: indices, length: indices.count)
    }
    
    public func umbrellas(indexPath: NSIndexPath) -> Bool {
        if length < indexPath.length {
            return indices[0] == indexPath.indices[0]
        }
        return false
    }
}
