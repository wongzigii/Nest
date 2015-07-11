//
//  Reusable.swift
//  Nest
//
//  Created by Manfred Lau on 12/17/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import Foundation

public protocol Reusable: NSObjectProtocol {
    var reuseIdentifier: String { get }
    
    func prepareForReuse()
}