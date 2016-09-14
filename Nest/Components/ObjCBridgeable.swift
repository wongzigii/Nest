//
//  ObjCBridgeable.swift
//  Nest
//
//  Created by Manfred on 9/1/16.
//
//

/// Nest members convert some non-Objective-C objects into Objective-C 
/// objects with `ObjCBridgeable`.
///
/// - Notes: Since Swift 3 forbids implementing `_ObjectiveCBridgeable` 
/// outside the module defined the conforming type and Apple did forgot to
/// make some types as `_ObjectiveCBridgeable`, Nest uses this protocol to 
/// convert those forgot types.
public protocol ObjCBridgeable {
    associatedtype _ObjectiveCType: AnyObject
    
    /// Convert `self` to Objective-C.
    func _bridgeToObjectiveC() -> _ObjectiveCType
    
    /// Bridge from an Objective-C object of the bridged class type to a
    /// value of the Self type.
    ///
    /// This bridging operation is used for forced downcasting (e.g.,
    /// via as), and may defer complete checking until later. For
    /// example, when bridging from `NSArray` to `Array<Element>`, we can defer
    /// the checking for the individual elements of the array.
    ///
    /// - parameter result: The location where the result is written. The optional
    ///   will always contain a value.
    static func _forceBridgeFromObjectiveC(
        _ source: _ObjectiveCType,
        result: inout Self?
    )
    
    /// Try to bridge from an Objective-C object of the bridged class
    /// type to a value of the Self type.
    ///
    /// This conditional bridging operation is used for conditional
    /// downcasting (e.g., via as?) and therefore must perform a
    /// complete conversion to the value type; it cannot defer checking
    /// to a later time.
    ///
    /// - parameter result: The location where the result is written.
    ///
    /// - Returns: `true` if bridging succeeded, `false` otherwise. This redundant
    ///   information is provided for the convenience of the runtime's `dynamic_cast`
    ///   implementation, so that it need not look into the optional representation
    ///   to determine success.
    @discardableResult
    static func _conditionallyBridgeFromObjectiveC(
        _ source: _ObjectiveCType,
        result: inout Self?
        ) -> Bool
    
    /// Bridge from an Objective-C object of the bridged class type to a
    /// value of the Self type.
    ///
    /// This bridging operation is used for unconditional bridging when
    /// interoperating with Objective-C code, either in the body of an
    /// Objective-C thunk or when calling Objective-C code, and may
    /// defer complete checking until later. For example, when bridging
    /// from `NSArray` to `Array<Element>`, we can defer the checking
    /// for the individual elements of the array.
    ///
    /// \param source The Objective-C object from which we are
    /// bridging. This optional value will only be `nil` in cases where
    /// an Objective-C method has returned a `nil` despite being marked
    /// as `_Nonnull`/`nonnull`. In most such cases, bridging will
    /// generally force the value immediately. However, this gives
    /// bridging the flexibility to substitute a default value to cope
    /// with historical decisions, e.g., an existing Objective-C method
    /// that returns `nil` to for "empty result" rather than (say) an
    /// empty array. In such cases, when `nil` does occur, the
    /// implementation of `Swift.Array`'s conformance to
    /// `_ObjectiveCBridgeable` will produce an empty array rather than
    /// dynamically failing.
    static func _unconditionallyBridgeFromObjectiveC(
        _ source: _ObjectiveCType?
        ) -> Self
}

