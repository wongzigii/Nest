//
//  NSObject+That.swift
//  Nest
//
//  Created by Manfred on 9/15/16.
//
//

import SwiftExt
import Foundation

extension NSObject: That {
    public typealias InstanceType = NSObject
}

extension OperationQueue {
    public typealias InstanceType = OperationQueue
}
