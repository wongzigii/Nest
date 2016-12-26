//
//  ObjCDynamicCoderTests.swift
//  Nest
//
//  Created by Manfred on 26/12/2016.
//
//

import XCTest
import Foundation
import Nest

import CoreGraphics
#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#endif

#if os(iOS) || os(OSX) || os(tvOS)
    import AVFoundation
#endif

private enum ArchivableEnum {
    case objectAccessor(AnyObject)
    case selectorAccessor(Selector)
    case integerAccessor(
        Int8,
        Int16,
        Int32,
        Int64,
        UInt8,
        UInt16,
        UInt32,
        UInt64,
        Bool
    )
    case foundationAccessor(NSRange)
    case floatingPointAccessor(Double, Float)
    case cgAccessor(CGPoint, CGVector, CGSize, CGRect, CGAffineTransform)
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    case uiKitAccessor(UIOffset, UIEdgeInsets)
    #endif
    
    #if os(iOS) || os(OSX) || os(tvOS)
    case quartzCoreAccessor(CATransform3D)
    case avFoundationAccessor(CMTime, CMTimeRange, CMTimeMapping)
    #endif
}

class ObjCDynamicCoderTests: XCTestCase {
    func testIntegerAccessor() {
        let anEnumCase: ArchivableEnum = .integerAccessor(
            1,
            9,
            8,
            4,
            1,
            9,
            8,
            4,
            false
        )
        
        let anObject = ArchivableObject(anEnumCase)
        
        let archivedArbitraryObject = NSKeyedArchiver
            .archivedData(withRootObject: anObject)
        
        let unarchivedArbitraryObject = NSKeyedUnarchiver
            .unarchiveObject(with: archivedArbitraryObject)
        
        if let unarchivedArbitraryObject
            = unarchivedArbitraryObject as? ArchivableObject
        {
            switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
            case let (
                .integerAccessor(
                    int8Original,
                    int16Original,
                    int32Original,
                    int64Original,
                    uint8Original,
                    uint16Original,
                    uint32Original,
                    uint64Original,
                    booleanOriginal
                ),
                .integerAccessor(
                    int8Unarchived,
                    int16Unarchived,
                    int32Unarchived,
                    int64Unarchived,
                    uint8Unarchived,
                    uint16Unarchived,
                    uint32Unarchived,
                    uint64Unarchived,
                    booleanUnarchived
                )
                ):
                
                XCTAssert(int8Original == int8Unarchived, "\(int8Unarchived)")
                XCTAssert(int16Original == int16Unarchived, "\(int16Unarchived)")
                XCTAssert(int32Original == int32Unarchived, "\(int32Unarchived)")
                XCTAssert(int64Original == int64Unarchived, "\(int64Unarchived)")
                XCTAssert(uint8Original == uint8Unarchived, "\(uint8Unarchived)")
                XCTAssert(uint16Original == uint16Unarchived, "\(uint16Unarchived)")
                XCTAssert(uint32Original == uint32Unarchived, "\(uint32Unarchived)")
                XCTAssert(uint64Original == uint64Unarchived, "\(uint64Unarchived)")
                XCTAssert(booleanOriginal == booleanUnarchived, "\(booleanUnarchived)")
                
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testObjectAccessor() {
        let anEnumCase: ArchivableEnum = .objectAccessor(
            "String as object to test" as AnyObject
        )
        
        let anObject = ArchivableObject(anEnumCase)
        
        let archivedArbitraryObject = NSKeyedArchiver
            .archivedData(withRootObject: anObject)
        
        let unarchivedArbitraryObject = NSKeyedUnarchiver
            .unarchiveObject(with: archivedArbitraryObject)
        
        if let unarchivedArbitraryObject
            = unarchivedArbitraryObject as? ArchivableObject
        {
            switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
            case let (
                .objectAccessor(
                    objectOriginal as String
                ),
                .objectAccessor(
                    objectUnarchived as String
                )
                ):
                
                XCTAssert(objectOriginal == objectUnarchived)
                
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testSelectorAccessor() {
        let anEnumCase: ArchivableEnum = .selectorAccessor(
            #selector(testSelectorAccessor)
        )
        
        let anObject = ArchivableObject(anEnumCase)
        
        let archivedArbitraryObject = NSKeyedArchiver
            .archivedData(withRootObject: anObject)
        
        let unarchivedArbitraryObject = NSKeyedUnarchiver
            .unarchiveObject(with: archivedArbitraryObject)
        
        if let unarchivedArbitraryObject
            = unarchivedArbitraryObject as? ArchivableObject
        {
            switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
            case let (
                .selectorAccessor(
                    selectorOriginal
                ),
                .selectorAccessor(
                    selectorUnarchived
                )
                ):
                
                XCTAssert(selectorOriginal == selectorUnarchived)
                
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testFloatingPointAccessor() {
        let anEnumCase: ArchivableEnum = .floatingPointAccessor(
            3.14, 1.7
        )
        
        let anObject = ArchivableObject(anEnumCase)
        
        let archivedArbitraryObject = NSKeyedArchiver
            .archivedData(withRootObject: anObject)
        
        let unarchivedArbitraryObject = NSKeyedUnarchiver
            .unarchiveObject(with: archivedArbitraryObject)
            as! ArchivableObject
        
        switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
        case let (
            .floatingPointAccessor(
                doubleOriginal, floatOriginal
            ),
            .floatingPointAccessor(
                doubleUnarchived, floatUnarchived
            )
            ):
            
            XCTAssert(doubleOriginal == doubleUnarchived, "original \(doubleOriginal), unarchived: \(doubleUnarchived)")
            XCTAssert(floatOriginal == floatUnarchived, "original \(floatOriginal), unarchived: \(floatUnarchived)")
            
            break
        default:
            XCTFail()
        }
    }
    
    
    
    func testFoundationAccessor() {
        let anEnumCase: ArchivableEnum = .foundationAccessor(
            NSRange(location: 19, length: 84)
        )
        
        let anObject = ArchivableObject(anEnumCase)
        
        let archivedArbitraryObject = NSKeyedArchiver
            .archivedData(withRootObject: anObject)
        
        let unarchivedArbitraryObject = NSKeyedUnarchiver
            .unarchiveObject(with: archivedArbitraryObject)
        
        if let unarchivedArbitraryObject
            = unarchivedArbitraryObject as? ArchivableObject
        {
            switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
            case let (
                .foundationAccessor(
                    rangeOriginal
                ),
                .foundationAccessor(
                    rangeUnarchived
                )
                ):
                
                XCTAssert(rangeOriginal == rangeUnarchived)
                
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testCGAccessors() {
        let anEnumCase: ArchivableEnum = .cgAccessor(
            CGPoint(x: 1, y: 1),
            CGVector(dx: 2, dy: 2),
            CGSize(width: 3, height: 3),
            CGRect(x: 4, y: 4, width: 4, height: 4),
            CGAffineTransform.identity
        )
        
        let anObject = ArchivableObject(anEnumCase)
        
        let archivedArbitraryObject = NSKeyedArchiver
            .archivedData(withRootObject: anObject)
        
        let unarchivedArbitraryObject = NSKeyedUnarchiver
            .unarchiveObject(with: archivedArbitraryObject)
        
        if let unarchivedArbitraryObject
            = unarchivedArbitraryObject as? ArchivableObject
        {
            switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
            case let (
                .cgAccessor(
                    pointOriginal, vectorOriginal, sizeOriginal, rectOriginal, trasnformOriginal
                ),
                .cgAccessor(
                    pointUnarchived, vectorUnarchived, sizeUnarchived, rectUnarchived, trasnformUnarchived
                )
                ):
                
                XCTAssert(pointOriginal == pointUnarchived)
                XCTAssert(vectorOriginal == vectorUnarchived)
                XCTAssert(sizeOriginal == sizeUnarchived)
                XCTAssert(rectOriginal == rectUnarchived)
                XCTAssert(trasnformOriginal == trasnformUnarchived)
                
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testUIKitAccessors() {
        #if os(iOS) || os(watchOS) || os(tvOS)
            let anEnumCase: ArchivableEnum = .uiKitAccessor(
                UIOffset(horizontal: 1, vertical: 1),
                UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
            )
            
            let anObject = ArchivableObject(anEnumCase)
            
            let archivedArbitraryObject = NSKeyedArchiver
                .archivedData(withRootObject: anObject)
            
            let unarchivedArbitraryObject = NSKeyedUnarchiver
                .unarchiveObject(with: archivedArbitraryObject)
            
            if let unarchivedArbitraryObject
                = unarchivedArbitraryObject as? ArchivableObject
            {
                switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
                case let (
                    .uiKitAccessor(
                        offsetOriginal, edgeInsetsOriginal
                    ),
                    .uiKitAccessor(
                        offsetUnarchived, edgeInsetsUnarchived
                    )
                    ):
                    
                    XCTAssert(offsetOriginal == offsetUnarchived)
                    XCTAssert(edgeInsetsOriginal == edgeInsetsUnarchived)
                    break
                default:
                    XCTFail()
                }
            }
        #endif
    }
    
    
    func testQuartzCoreAccessors() {
        #if os(iOS) || os(OSX) || os(tvOS)
            let anEnumCase: ArchivableEnum = .quartzCoreAccessor(
                CATransform3DIdentity
            )
            
            let anObject = ArchivableObject(anEnumCase)
            
            let archivedArbitraryObject = NSKeyedArchiver
                .archivedData(withRootObject: anObject)
            
            let unarchivedArbitraryObject = NSKeyedUnarchiver
                .unarchiveObject(with: archivedArbitraryObject)
            
            if let unarchivedArbitraryObject
                = unarchivedArbitraryObject as? ArchivableObject
            {
                switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
                case let (
                    .quartzCoreAccessor(transform3DOriginal),
                    .quartzCoreAccessor(transform3DUnarchived)
                    ):
                    
                    XCTAssert(CATransform3DEqualToTransform(transform3DOriginal, transform3DUnarchived))
                    break
                default:
                    XCTFail()
                }
            }
        #endif
    }
    
    
    func testAVFoundationAccessors() {
        #if os(iOS) || os(OSX) || os(tvOS)
            let anEnumCase: ArchivableEnum = .avFoundationAccessor(
                CMTime(seconds: 1, preferredTimescale: 1),
                CMTimeRange(
                    start: CMTime(seconds: 1, preferredTimescale: 10),
                    duration: CMTime(seconds: 10, preferredTimescale: 10)
                ),
                CMTimeMapping(
                    source: CMTimeRange(
                        start: CMTime(seconds: 0, preferredTimescale: 10),
                        duration: CMTime(seconds: 10, preferredTimescale: 10)
                    ),
                    target: CMTimeRange(
                        start: CMTime(seconds: 0, preferredTimescale: 100),
                        duration: CMTime(seconds: 1, preferredTimescale: 100)
                    )
                )
            )
            
            let anObject = ArchivableObject(anEnumCase)
            
            let archivedArbitraryObject = NSKeyedArchiver
                .archivedData(withRootObject: anObject)
            
            let unarchivedArbitraryObject = NSKeyedUnarchiver
                .unarchiveObject(with: archivedArbitraryObject)
            
            if let unarchivedArbitraryObject
                = unarchivedArbitraryObject as? ArchivableObject
            {
                switch (anEnumCase, unarchivedArbitraryObject.archivableEnum) {
                case let (
                    .avFoundationAccessor(
                        timeOriginal,
                        timeRangeOriginal,
                        timeMappingOriginal
                    ),
                    .avFoundationAccessor(
                        timeUnarchived,
                        timeRangeUnarchived,
                        timeMappingUnarchived)
                    ):
                    
                    XCTAssert(timeOriginal == timeUnarchived)
                    XCTAssert(timeRangeOriginal == timeRangeUnarchived)
                    XCTAssert(
                        timeMappingOriginal.source == timeMappingUnarchived.source
                            && timeMappingOriginal.target == timeMappingUnarchived.target
                    )
                    break
                default:
                    XCTFail()
                }
            }
        #endif
    }
}

private class ArchivableObject: NSObject, NSCoding {
    fileprivate var archivableEnum: ArchivableEnum
    
    fileprivate init(_ archivableEnum: ArchivableEnum) {
        self.archivableEnum = archivableEnum
        super.init()
    }
    
    @objc fileprivate required init?(coder aDecoder: NSCoder) {
        do {
            archivableEnum = try aDecoder.decodeOrThrow(for: "archivableEnum")
            super.init()
        } catch _ {
            return nil
        }
    }
    
    @objc fileprivate func encode(with aCoder: NSCoder) {
        aCoder.encode(archivableEnum, for: "archivableEnum")
    }
}

extension ArchivableEnum: _ObjectiveCBridgeable {
    fileprivate typealias _ObjectiveCType = _ArchivableEnumObjCBridged
    
    fileprivate static func _getObjectiveCType() -> Any.Type {
        return _ObjectiveCType.self
    }
    
    fileprivate static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    fileprivate func _bridgeToObjectiveC() -> _ObjectiveCType {
        if case let .objectAccessor(object) = self {
            let bridged = _ArchivableEnumObjectAccessorObjCBridged()
            bridged.objectValue = object
            return bridged
        }
        
        if case let .selectorAccessor(selector) = self {
            let bridged = _ArchivableEnumSelectorAccessorObjCBridged()
            bridged.selector = selector
            return bridged
        }
        
        if case let .integerAccessor(
            int8, int16, int32, int64, uint8, uint16, uint32, uint64, boolean)
            = self
        {
            let bridged = _ArchivableEnumIntegerAccessorObjCBridged()
            bridged.Int8Value = int8
            bridged.Int16Value = int16
            bridged.Int32Value = int32
            bridged.Int64Value = int64
            bridged.UInt8Value = uint8
            bridged.UInt16Value = uint16
            bridged.UInt32Value = uint32
            bridged.UInt64Value = uint64
            bridged.BoolValue = boolean
            return bridged
        }
        
        if case let .floatingPointAccessor(double, float) = self {
            let bridged = _ArchivableEnumFloatingPointAccessorObjCBridged()
            bridged.floatValue = float
            bridged.doubleValue = double
            return bridged
        }
        
        if case let .foundationAccessor(range) = self {
            let bridged = _ArchivableEnumFoundationAccessorObjCBridged()
            bridged.rangeValue = range
            return bridged
        }
        
        if case let .cgAccessor(point, vector, size, rect, transform) = self {
            let bridged = _ArchivableEnumCGAccessorObjCBridged()
            bridged.CGPointValue = point
            bridged.CGVectorValue = vector
            bridged.CGSizeValue = size
            bridged.CGRectValue = rect
            bridged.CGAffineTransformValue = transform
            return bridged
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
            if case let .uiKitAccessor(offset, edgeInsets) = self {
                let bridged = _ArchivableEnumUIKitAccessorObjCBridged()
                
                bridged.offset = offset
                bridged.edgeInsets = edgeInsets
                
                return bridged
            }
        #endif
        
        #if os(iOS) || os(OSX) || os(tvOS)
            if case let .quartzCoreAccessor(transform3D) = self {
                let bridged = _ArchivableEnumQuartzCoreAccessorObjCBridged()
                
                bridged.CATransform3DValue = transform3D
                
                return bridged
            }
            
            if case let .avFoundationAccessor(time, timeRange, timeMapping)
                = self
            {
                let bridged = _ArchivableEnumAVFoundationAccessorObjCBridged()
                
                bridged.CMTimeValue = time
                bridged.CMTimeRangeValue = timeRange
                bridged.CMTimeMappingValue = timeMapping
                
                return bridged
            }
        #endif
        
        fatalError("This function needs to be implemented!")
    }
    
    fileprivate static func _forceBridgeFromObjectiveC(
        _ source: _ObjectiveCType,
        result: inout ArchivableEnum?
        )
    {
        if let selectorAccessor = source
            as? _ArchivableEnumSelectorAccessorObjCBridged
        {
            result = .selectorAccessor(selectorAccessor.selector)
        }
        
        if let objectAccessor = source
            as? _ArchivableEnumObjectAccessorObjCBridged
        {
            result = .objectAccessor(objectAccessor.objectValue)
        }
        
        if let integerAccessor = source
            as? _ArchivableEnumIntegerAccessorObjCBridged
        {
            result = .integerAccessor(
                integerAccessor.Int8Value,
                integerAccessor.Int16Value,
                integerAccessor.Int32Value,
                integerAccessor.Int64Value,
                integerAccessor.UInt8Value,
                integerAccessor.UInt16Value,
                integerAccessor.UInt32Value,
                integerAccessor.UInt64Value,
                integerAccessor.BoolValue
            )
        }
        
        if let floatingPointAccessor = source
            as? _ArchivableEnumFloatingPointAccessorObjCBridged
        {
            result = .floatingPointAccessor(
                floatingPointAccessor.doubleValue,
                floatingPointAccessor.floatValue
            )
        }
        
        if let rangeAccessor = source
            as? _ArchivableEnumFoundationAccessorObjCBridged
        {
            result = .foundationAccessor(
                rangeAccessor.rangeValue
            )
        }
        
        if let CGAccessor = source as? _ArchivableEnumCGAccessorObjCBridged {
            result = .cgAccessor(
                CGAccessor.CGPointValue,
                CGAccessor.CGVectorValue,
                CGAccessor.CGSizeValue,
                CGAccessor.CGRectValue,
                CGAccessor.CGAffineTransformValue
            )
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
            if let UIKitAccessor = source
                as? _ArchivableEnumUIKitAccessorObjCBridged
            {
                result = .uiKitAccessor(
                    UIKitAccessor.offset,
                    UIKitAccessor.edgeInsets
                )
            }
        #endif
        
        #if os(iOS) || os(OSX) || os(tvOS)
            if let QuartzCoreAccessor = source
                as? _ArchivableEnumQuartzCoreAccessorObjCBridged
            {
                result = .quartzCoreAccessor(
                    QuartzCoreAccessor.CATransform3DValue
                )
            }
            
            if let AVFoundationAccessor = source
                as? _ArchivableEnumAVFoundationAccessorObjCBridged
            {
                result = .avFoundationAccessor(
                    AVFoundationAccessor.CMTimeValue,
                    AVFoundationAccessor.CMTimeRangeValue,
                    AVFoundationAccessor.CMTimeMappingValue
                )
            }
        #endif
    }
    
    fileprivate static func _conditionallyBridgeFromObjectiveC(
        _ source: _ObjectiveCType,
        result: inout ArchivableEnum?
        )
        -> Bool
    {
        _forceBridgeFromObjectiveC(source, result: &result)
        return result != nil
    }
    
    fileprivate static func _unconditionallyBridgeFromObjectiveC(
        _ source: _ObjectiveCType?
        )
        -> ArchivableEnum
    {
        var result: ArchivableEnum?
        _forceBridgeFromObjectiveC(source!, result: &result)
        return result!
    }
}

private class _ArchivableEnumObjCBridged: ObjCDynamicCoder {
    
}

private final class _ArchivableEnumObjectAccessorObjCBridged:
    _ArchivableEnumObjCBridged
{
    @NSManaged
    fileprivate var objectValue: AnyObject
}

private final class _ArchivableEnumIntegerAccessorObjCBridged:
    _ArchivableEnumObjCBridged
{
    @NSManaged
    fileprivate var Int8Value: Int8
    
    @NSManaged
    fileprivate var Int16Value: Int16
    
    @NSManaged
    fileprivate var Int32Value: Int32
    
    @NSManaged
    fileprivate var Int64Value: Int64
    
    @NSManaged
    fileprivate var UInt8Value: UInt8
    
    @NSManaged
    fileprivate var UInt16Value: UInt16
    
    @NSManaged
    fileprivate var UInt32Value: UInt32
    
    @NSManaged
    fileprivate var UInt64Value: UInt64
    
    @NSManaged
    fileprivate var BoolValue: Bool
}

private final class _ArchivableEnumSelectorAccessorObjCBridged:
    _ArchivableEnumObjCBridged
{
    @NSManaged
    fileprivate var selector: Selector
}

private final class _ArchivableEnumFloatingPointAccessorObjCBridged:
    _ArchivableEnumObjCBridged
{
    @NSManaged
    fileprivate var doubleValue: Double
    
    @NSManaged
    fileprivate var floatValue: Float
}

private final class _ArchivableEnumFoundationAccessorObjCBridged:
    _ArchivableEnumObjCBridged
{
    @NSManaged
    fileprivate var rangeValue: NSRange
}

private final class _ArchivableEnumCGAccessorObjCBridged:
    _ArchivableEnumObjCBridged
{
    @NSManaged
    fileprivate var CGPointValue: CGPoint
    
    @NSManaged
    fileprivate var CGVectorValue: CGVector
    
    @NSManaged
    fileprivate var CGSizeValue: CGSize
    
    @NSManaged
    fileprivate var CGRectValue: CGRect
    
    @NSManaged
    fileprivate var CGAffineTransformValue: CGAffineTransform
}

#if os(iOS) || os(watchOS) || os(tvOS)
    private final class _ArchivableEnumUIKitAccessorObjCBridged:
        _ArchivableEnumObjCBridged
    {
        @NSManaged
        fileprivate var offset: UIOffset
        
        @NSManaged
        fileprivate var edgeInsets: UIEdgeInsets
    }
#endif

#if os(iOS) || os(OSX) || os(tvOS)
    private final class _ArchivableEnumQuartzCoreAccessorObjCBridged:
        _ArchivableEnumObjCBridged
    {
        @NSManaged
        fileprivate var CATransform3DValue: CATransform3D
    }
    
    private final class _ArchivableEnumAVFoundationAccessorObjCBridged:
        _ArchivableEnumObjCBridged
    {
        @NSManaged
        fileprivate var CMTimeValue: CMTime
        
        @NSManaged
        fileprivate var CMTimeRangeValue: CMTimeRange
        
        @NSManaged
        fileprivate var CMTimeMappingValue: CMTimeMapping
    }
#endif
