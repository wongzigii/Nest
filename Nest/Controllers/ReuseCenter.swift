//
//  ReuseCenter.swift
//  Nest
//
//  Created by Manfred Lau on 12/17/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import SwiftExt
import Foundation

/**
`ReuseCenter` is designed to make reusing convenient. It can enqueue and dequeue
objects by reuse identifier which confrom to `ReusableType` protocol and call
`prepareForReuse()` during the dequeueing.
*/
public final class ReuseCenter<R: ReusableType> {
    public typealias Reusable = R
    private var reusablesDict: [String: [Reusable]] = [:]
    
    /// Get all reusables for specified reuse identifier. This will not remove
    /// them from the queue.
    public func reusableForReuseIdentifier(reuseIdentifier: String) ->
        [Reusable]?
    {
        return reusablesDict[reuseIdentifier]
    }
    
    /// Dequeue a reusable object by matching the reuse identifier
    public func dequeueReusableWithReuseIdentifier(
        reuseIdentifier: String) -> Reusable?
    {
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
    
    /// Enqueue a reusable object
    public func enqueueUnused(unused: Reusable) {
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