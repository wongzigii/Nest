//
//  NSRunLoopMode.swift
//  Nest
//
//  Created by Manfred on 7/27/15.
//
//

import SwiftExt
import Foundation

/**
`NSRunLoopMode` is a convenience for modes of `NSRunLoop`
*/
public struct NSRunLoopMode: OptionSetType {
    public typealias Element = NSRunLoopMode
    
    public var rawValue: String = ""
    public init(rawValue: String) { self.rawValue = rawValue }
    
    public static let defaultMode =
    NSRunLoopMode(rawValue: "kCFRunLoopDefaultMode")
    
    public static let commonModes =
    NSRunLoopMode(rawValue: "kCFRunLoopCommonModes")
    
    var rawValues: [RawValue] {
        let elements = (self.rawValue.componentsSeparatedByString(","))
        var rawValues = [RawValue]()
        for each in elements {
            rawValues.append(each)
        }
        return rawValues
    }
}

public func==(lhs: NSRunLoopMode, rhs: NSRunLoopMode) -> Bool {
    let lhsElements = Set<String>(lhs.rawValue.componentsSeparatedByString(","))
    let rhsElements = Set<String>(rhs.rawValue.componentsSeparatedByString(","))
    return lhsElements == rhsElements
}

extension NSRunLoop {
    /// Performs one pass through the run loop in the specified mode and returns 
    /// the date at which the next timer is scheduled to fire.
    public func limitDateForMode(mode: NSRunLoopMode) -> NSDate? {
        return limitDateForMode(mode.rawValue)
    }
    
    /// Registers a given timer with a given input mode.
    public func addTimer(timer: NSTimer, forMode mode: NSRunLoopMode) {
        addTimer(timer, forMode: mode.rawValue)
    }
    
    /// Adds a port as an input source to the specified mode of the run loop.
    public func addPort(aPort: NSPort, forMode mode: NSRunLoopMode) {
        addPort(aPort, forMode: mode.rawValue)
    }
    
    /// Removes a port from the specified input mode of the run loop.
    public func removePort(aPort: NSPort, forMode mode: NSRunLoopMode) {
        removePort(aPort, forMode: mode.rawValue)
    }
    
    /// Runs the loop once, blocking for input in the specified mode until a 
    /// given date.
    public func runMode(mode: NSRunLoopMode, beforeDate limitDate: NSDate)
        -> Bool
    {
        return runMode(mode.rawValue, beforeDate: limitDate)
    }
    
    /// Runs the loop once or until the specified date, accepting input only for
    /// the specified mode.
    public func acceptInputForMode(mode: NSRunLoopMode,
        beforeDate limitDate: NSDate)
    {
        return acceptInputForMode(mode.rawValue, beforeDate: limitDate)
    }
    
    /// Schedules the sending of a message on the current run loop.
    public func performSelector(aSelector: Selector,
        target: AnyObject,
        argument arg: AnyObject?,
        order: Int,
        modes: NSRunLoopMode)
    {
        performSelector(aSelector,
            target: target,
            argument: arg,
            order: order,
            modes: modes.rawValues)
    }
    
    /// The receiver's current input mode. (read-only)
    public var currentRunLoopMode: NSRunLoopMode {
        guard let currentModeRawValue = currentMode else { return [] }
        return NSRunLoopMode(rawValue: currentModeRawValue)
    }
}
