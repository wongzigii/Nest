//
//  IndexPath+_ObjectiveCBridgeable.swift
//  Nest
//
//  Created by Manfred on 12/23/15.
//
//

import Foundation
import SwiftExt

extension IndexPath: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = NSIndexPath
    
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return _ObjectiveCType(indexes: indices, length: length)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(
        source: _ObjectiveCType,
        inout result: IndexPath?)
        -> Bool
    {
        result = IndexPath(source.indices)
        
        return true
    }
    
    public static func _forceBridgeFromObjectiveC(source: _ObjectiveCType,
        inout result: IndexPath?)
    {
        result = IndexPath(source.indices)
    }
    
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    public static func _getObjectiveCType() -> Any.Type {
        return NSIndexPath.self
    }
}
