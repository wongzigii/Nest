//
//  NSIndexPath+IndexPathType.swift
//  Nest
//
//  Created by Manfred on 10/2/15.
//
//

import SwiftExt
import Foundation

extension NSIndexPath {
    public convenience init(indexPath: IndexPath) {
        self.init(indexes: indexPath.indices, length: indexPath.length)
    }
}

extension IndexPath {
    public init(NSIndexPath: Foundation.NSIndexPath) {
        let indices = UnsafeMutablePointer<Int>.alloc(NSIndexPath.length)
        NSIndexPath.getIndexes(indices)
        let arrayOfIndices = [Index](head: indices, length: NSIndexPath.length)
        self = IndexPath(arrayOfIndices)
        indices.destroy()
        indices.dealloc(NSIndexPath.length)
    }
}






