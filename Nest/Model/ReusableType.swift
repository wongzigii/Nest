//
//  Reusable.swift
//  Nest
//
//  Created by Manfred Lau on 12/17/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation

/**
Conforming to `ReusableType` makes an object to be manageable by `ReuseCenter`
*/
public protocol ReusableType: class {
    /// Reuse identifier
    var reuseIdentifier: String { get }
    
    /// This function will be called before dequeueing
    func prepareForReuse()
}