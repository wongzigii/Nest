//
//  NSObject+SubsequentSetupInitializable.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation

public protocol SubsequentSetupInitializable {
    
}

extension SubsequentSetupInitializable where Self: NSObject {
    public init(subsequentSetup: ((Self) -> Void)?) {
        self.init()
        subsequentSetup?(self)
    }
}

extension NSObject: SubsequentSetupInitializable {}
