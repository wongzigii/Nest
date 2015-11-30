//
//  NSIndexPath+IndexPathType.swift
//  Nest
//
//  Created by Manfred on 10/2/15.
//
//

import SwiftExt
import Foundation

extension NSIndexPath: IndexPathType {
    public var indices: [Int] {
        var indices = [Int]()
        for position in 0..<length {
            indices.append(indexAtPosition(position))
        }
        return indices
    }
    
    public typealias Index = Int
    
    public func predecessor() -> Self {
        guard let lastIndex = self.indices.last else {
            fatalError("No index")
        }
        
        var indices = self.indices
        indices.removeLast()
        indices += lastIndex.predecessor()
        
        return self.dynamicType.init(indexes: indices, length: indices.count)
    }
    
    public func successor() -> Self {
        guard let lastIndex = self.indices.last else {
            fatalError("No index")
        }
        
        var indices = self.indices
        indices.removeLast()
        indices += lastIndex.successor()
        
        return self.dynamicType.init(indexes: indices, length: indices.count)
    }
    
    public static func withIndexPath<I : IndexPathType>(indexPath: I)
        -> Self
    {
        return self.init(indexes: indexPath.indices.map { Index($0.toIntMax())},
            length: indexPath.indices.count)
    }
}
