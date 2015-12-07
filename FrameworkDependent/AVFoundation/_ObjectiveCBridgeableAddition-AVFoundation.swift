//
//  _ObjectiveCBridgeableAddition+AVFoundation.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import Foundation
import CoreMedia

// Specialization for CoreMedia types
extension CMTime: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSValue
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return _ObjectiveCType.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSValue(CMTime: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: CMTime?)
    {
        result = x.CMTimeValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: CMTime?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

extension CMTimeRange: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSValue
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return _ObjectiveCType.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSValue(CMTimeRange: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: CMTimeRange?)
    {
        result = x.CMTimeRangeValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: CMTimeRange?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}

extension CMTimeMapping: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSValue
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return _ObjectiveCType.self
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSValue(CMTimeMapping: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: CMTimeMapping?)
    {
        result = x.CMTimeMappingValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        x: _ObjectiveCType,
        inout result: CMTimeMapping?)
        -> Bool
    {
        self._forceBridgeFromObjectiveC(x, result: &result)
        return true
    }
}
