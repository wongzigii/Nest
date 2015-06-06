//
//  NSReuseCenter.swift
//  Nest
//
//  Created by Manfred Lau on 12/17/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import SwiftExt
import Foundation

public final class NSReuseCenter<R: NSReusable> {
    public typealias ReusableType = R
    private var reusablesDict: [String: [ReusableType]] = [:]
    
    public func reusableForReuseIdentifier(reuseIdentifier: String) -> [ReusableType]? {
        return reusablesDict[reuseIdentifier]
    }
    
    public func dequeueReusableWithReuseIdentifier(reuseIdentifier: String) -> ReusableType? {
        if var reusables = reusablesDict[reuseIdentifier] {
            if reusables.count > 0 {
                let reusable = reusables.removeLast()
                reusable.prepareForReuse()
                
                reusablesDict[reuseIdentifier] = reusables
                
                return reusable
            }
        }
        
        return nil
    }
    
    public func enqueueUnused(unused: ReusableType) {
        let reuseIdentifier = unused.reuseIdentifier
        if let reusables = reusablesDict[reuseIdentifier] {
            reusablesDict[reuseIdentifier] = reusables + unused
        } else {
            reusablesDict[reuseIdentifier] = [unused]
        }
    }
    
    public init() {
        
    }
}