//
//  NSIndexPath+PrimitiveIndexPathType.swift
//  Nest
//
//  Created by Manfred on 10/2/15.
//
//

import SwiftExt
import Foundation

extension NSIndexPath: PrimitiveIndexPathType {
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
    
    public class func withPrimitiveIndexPath<I: PrimitiveIndexPathType>(
        primitiveIndexPath: I)
        -> Self
    {
        return self.init(
            indexes: primitiveIndexPath.indices.map { Index($0.toIntMax()) },
            length: primitiveIndexPath.indices.count)
    }
}
