//
//  ObjCBridgeable-QuartzCore.swift
//  Nest
//
//  Created by Manfred on 9/1/16.
//
//

import QuartzCore

extension CATransform3D: ObjCBridgeable {
    
    public typealias _ObjectiveCType = NSValue
    
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return NSValue(caTransform3D: self)
    }
    
    public static func _forceBridgeFromObjectiveC(
        _ source: _ObjectiveCType,
        result: inout CATransform3D?
        )
    {
        result = source.caTransform3DValue
    }
    
    @discardableResult
    public static func _conditionallyBridgeFromObjectiveC(
        _ source: _ObjectiveCType,
        result: inout CATransform3D?
        ) -> Bool
    {
        result = source.caTransform3DValue
        
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(
        _ source: _ObjectiveCType?
        ) -> CATransform3D
    {
        return source?.caTransform3DValue ?? .init()
    }
}
