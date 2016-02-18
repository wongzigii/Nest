//
//  ObjCPrimitiveCodingType-QuartzCore.swift
//  Nest
//
//  Created by Manfred on 2/16/16.
//
//

import QuartzCore

extension CATransform3D: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSValue
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSValue.self
    }
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSValue(CATransform3D: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        source: _ObjectiveCType,
        inout result: CATransform3D?
        )
    {
        result = source.CATransform3DValue
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        source: _ObjectiveCType,
        inout result: CATransform3D?
        )
        -> Bool
    {
        result = source.CATransform3DValue
        return true
    }
}
