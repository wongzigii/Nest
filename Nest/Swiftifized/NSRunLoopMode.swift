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
    
    public static let defaultMode = NSRunLoopMode(rawValue: "kCFRunLoopDefaultMode")
    public static let commonModes = NSRunLoopMode(rawValue: "kCFRunLoopCommonModes")
    
    public init() {}
    
    var rawValues: [RawValue] {
        let elements = (self.rawValue.componentsSeparatedByString(","))
        var rawValues = [RawValue]()
        for each in elements {
            rawValues.append(each)
        }
        return rawValues
    }
    
    public func contains(member: Element) -> Bool {
        let otherElements   = (member.rawValue
            .componentsSeparatedByString(","))
        let elements        = (self.rawValue
            .componentsSeparatedByString(","))
        
        var excluded = [String]()
        
        for eachInOtherElements in otherElements {
            for eachInElement in elements {
                if eachInOtherElements != eachInElement {
                    excluded.append(eachInOtherElements)
                }
            }
        }
        
        return excluded.isEmpty
    }
    
    public func union(other: NSRunLoopMode) -> NSRunLoopMode {
        let otherElements   = Set<String>(other.rawValue
            .componentsSeparatedByString(","))
        let elements        = Set<String>(self.rawValue
            .componentsSeparatedByString(","))
        let union = otherElements.union(elements)
        
        let joined = union.joinWithSeparator(",")
        
        return NSRunLoopMode(rawValue: joined)
    }
    
    public func intersect(other: NSRunLoopMode) -> NSRunLoopMode {
        let otherElements   = Set<String>(other.rawValue
            .componentsSeparatedByString(","))
        let elements        = Set<String>(self.rawValue
            .componentsSeparatedByString(","))
        let intersected = otherElements.intersect(elements)
        
        let joined = intersected.joinWithSeparator(",")
        
        return NSRunLoopMode(rawValue: joined)
    }
    
    public func exclusiveOr(other: NSRunLoopMode) -> NSRunLoopMode {
        let otherElements   = Set<String>(other.rawValue
            .componentsSeparatedByString(","))
        let elements        = Set<String>(self.rawValue
            .componentsSeparatedByString(","))
        let exclusiveOr = otherElements.exclusiveOr(elements)
        
        let joined = exclusiveOr.joinWithSeparator(",")
        
        return NSRunLoopMode(rawValue: joined)
    }
    
    public mutating func insert(member: Element) {
        let memberElements  = Set<String>(member.rawValue
            .componentsSeparatedByString(","))
        let elements        = Set<String>(self.rawValue
            .componentsSeparatedByString(","))
        let union = memberElements.union(elements)
        
        let joined = union.joinWithSeparator(",")
        
        rawValue = joined
    }
    
    public mutating func remove(member: Element) -> Element? {
        let elements        = Set<String>(self.rawValue
            .componentsSeparatedByString(","))
        let memberElements  = Set<String>(member.rawValue
            .componentsSeparatedByString(","))
        
        let afterRemoving = elements.subtract(memberElements)
        let removed = elements.subtract(afterRemoving)
        let joined = afterRemoving.joinWithSeparator(",")
        
        rawValue = joined
        
        return NSRunLoopMode(rawValue: removed.joinWithSeparator(","))
    }
    
    public mutating func unionInPlace(other: NSRunLoopMode) {
        let otherElements   = Set<String>(other.rawValue
            .componentsSeparatedByString(","))
        let elements        = Set<String>(self.rawValue
            .componentsSeparatedByString(","))
        let union = otherElements.union(elements)
        
        let joined = union.joinWithSeparator(",")
        
        rawValue = joined
    }
    
    public mutating func intersectInPlace(other: NSRunLoopMode) {
        let otherElements   = Set<String>(other.rawValue
            .componentsSeparatedByString(","))
        let elements        = Set<String>(self.rawValue
            .componentsSeparatedByString(","))
        let intersected = otherElements.intersect(elements)
        
        let joined = intersected.joinWithSeparator(",")
        
        rawValue = joined
    }
    
    public mutating func exclusiveOrInPlace(other: NSRunLoopMode) {
        let otherElements   = Set<String>(other.rawValue
            .componentsSeparatedByString(","))
        let elements        = Set<String>(self.rawValue
            .componentsSeparatedByString(","))
        let exclusiveOr = otherElements.exclusiveOr(elements)
        
        let joined = exclusiveOr.joinWithSeparator(",")
        
        rawValue = joined
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
