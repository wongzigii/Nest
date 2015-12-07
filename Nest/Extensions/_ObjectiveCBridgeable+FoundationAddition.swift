//
//  _ObjectiveCBridgeable+FoundationAddition.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import Foundation

// Specialization for signed integer types
extension Int8: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSNumber
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public init(_ number: NSNumber) {
        self = number.charValue
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSNumber.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSNumber(char: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: Int8?)
    {
        result = x.charValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: Int8?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

extension Int16: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSNumber
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public init(_ number: NSNumber) {
        self = number.shortValue
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSNumber.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSNumber(short: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: Int16?)
    {
        result = x.shortValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: Int16?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

extension Int32: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSNumber
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public init(_ number: NSNumber) {
        self = number.intValue
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSNumber.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSNumber(int: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: Int32?)
    {
        result = x.intValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: Int32?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

extension Int64: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSNumber
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public init(_ number: NSNumber) {
        self = number.longLongValue
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSNumber.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSNumber(longLong: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: Int64?)
    {
        result = x.longLongValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: Int64?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

// Specialization for unsigned integer types
extension UInt8: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSNumber
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public init(_ number: NSNumber) {
        self = number.unsignedCharValue
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSNumber.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSNumber(unsignedChar: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: UInt8?)
    {
        result = x.unsignedCharValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: UInt8?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

extension UInt16: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSNumber
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public init(_ number: NSNumber) {
        self = number.unsignedShortValue
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSNumber.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSNumber(unsignedShort: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: UInt16?)
    {
        result = x.unsignedShortValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: UInt16?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

extension UInt32: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSNumber
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public init(_ number: NSNumber) {
        self = number.unsignedIntValue
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSNumber.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSNumber(unsignedInt: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: UInt32?)
    {
        result = x.unsignedIntValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: UInt32?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

extension UInt64: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSNumber
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public init(_ number: NSNumber) {
        self = number.unsignedLongLongValue
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSNumber.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSNumber(unsignedLongLong: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: UInt64?)
    {
        result = x.unsignedLongLongValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: UInt64?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}
