//
//  Boolean+BooleanLiteralConvertible.swift
//  Nest
//
//  Created by Manfred on 7/29/15.
//
//

import Foundation

extension Boolean: BooleanLiteralConvertible {
    public typealias BooleanLiteralType = Bool
    
    /// Create an instance initialized to `value`.
    public init(booleanLiteral value: Bool) {
        self = value ? 1 : 0
    }
}
