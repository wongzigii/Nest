//
//  CFRunLoopActivity+CustomDebugStringConvertible.swift
//  Nest
//
//  Created by Manfred on 11/3/15.
//
//

import CoreFoundation

extension CFRunLoopActivity: CustomDebugStringConvertible {
    public var debugDescription: String {
        var activities = [String]()
        if self.contains(.Entry) {
            activities.append("Entry")
        }
        if self.contains(.BeforeTimers) {
            activities.append("Before Timers")
        }
        if self.contains(.BeforeSources) {
            activities.append("Before Sources")
        }
        if self.contains(.BeforeWaiting) {
            activities.append("Before Waiting")
        }
        if self.contains(.AfterWaiting) {
            activities.append("After Waiting")
        }
        if self.contains(.Exit) {
            activities.append("Exit")
        }
        return "<\(self.dynamicType): "
            + activities.joinWithSeparator(",")
            + ">"
    }
}