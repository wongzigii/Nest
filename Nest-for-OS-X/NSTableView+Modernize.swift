//
//  NSTableView+Modernize.swift
//  Nest
//
//  Created by Manfred on 10/6/15.
//
//

import Cocoa

extension NSTableColumn {
    public convenience init
        <I: RawRepresentable where I.RawValue == String>
        (identifier: I)
    {
        self.init(identifier: identifier.rawValue)
    }
}
