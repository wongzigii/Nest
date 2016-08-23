//
//  Bundle.swift
//  Nest
//
//  Created by Manfred on 8/23/16.
//
//

import Foundation

extension Bundle {
    public var isAppExtension: Bool {
        return executablePath?.contains(".appex/") == true
    }
}
