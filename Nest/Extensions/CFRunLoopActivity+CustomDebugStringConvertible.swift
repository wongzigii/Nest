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
        if self.contains(.entry) {
            activities.append("Entry")
        }
        if self.contains(.beforeTimers) {
            activities.append("Before Timers")
        }
        if self.contains(.beforeSources) {
            activities.append("Before Sources")
        }
        if self.contains(.beforeWaiting) {
            activities.append("Before Waiting")
        }
        if self.contains(.afterWaiting) {
            activities.append("After Waiting")
        }
        if self.contains(.exit) {
            activities.append("Exit")
        }
        return "<\(self.dynamicType): "
            + activities.joined(separator: ",")
            + ">"
    }
}
