//
//  ObjCCodingBaseTest.swift
//  Nest
//
//  Created by Manfred on 2/5/16.
//
//

import XCTest
import Foundation

import Nest

class ObjCCodingBaseTest: XCTestCase {
    
    func testCoding() {
        let case1value1 = "hehe"
        let case1value2 = true
        let case1value3 = 1
        let case1value4: Float = 1.23
        let case1value5: Double = 5.67890123456789012345678901234567890
        
        let anArbitraryObject = ArbitraryObject(
            .Case1(
                case1value1,
                case1value2,
                case1value3,
                case1value4,
                case1value5
            )
        )
        
        let archivedArbitraryObject = NSKeyedArchiver
            .archivedDataWithRootObject(anArbitraryObject)
        
        let unarchivedArbitraryObject = NSKeyedUnarchiver
            .unarchiveObjectWithData(archivedArbitraryObject)
        
        if let unarchivedArbitraryObject
            = unarchivedArbitraryObject as? ArbitraryObject
        {
            if case let .Case1(value1, value2, value3, value4, value5)
                = unarchivedArbitraryObject.arbitraryEnum
            {
                XCTAssert(case1value1 == value1, "String: \"\(value1)\"")
                XCTAssert(case1value2 == value2, "Bool: \"\(value2)\"")
                XCTAssert(case1value3 == value3, "Int: \"\(value3)\"")
                XCTAssert(case1value4 == value4, "Float: \"\(value4)\"")
                XCTAssert(case1value5 == value5, "Double: \"\(value5)\"")
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
        
    }
}

internal class ArbitraryObject: NSObject, NSCoding {
    var arbitraryEnum: ArbitraryEnum
    
    init(_ arbitraryEnum: ArbitraryEnum) {
        self.arbitraryEnum = arbitraryEnum
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        do {
            arbitraryEnum = try aDecoder.decodeOrThrowFor("arbitraryEnum")
            super.init()
        } catch _ {
            return nil
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encode(arbitraryEnum, for: "arbitraryEnum")
    }
}

internal enum ArbitraryEnum: _ObjectiveCBridgeable {
    case Case1(String, Bool, Int, Float, Double)
    case Case2(Bool)
    
    internal typealias _ObjectiveCType = _ArbitraryEnumObjectiveCBridged
    
    internal func _bridgeToObjectiveC() -> _ObjectiveCType {
        switch self {
        case let .Case1(value1, value2, value3, value4, value5):
            return _ArbitraryEnumCase1ObjectiveCBridged(
                value1: value1,
                value2: value2,
                value3: value3,
                value4: value4,
                value5: value5
            )
        case let .Case2(value1):
            return _ArbitraryEnumCase2ObjectiveCBridged(
                value1: value1
            )
        }
    }
    
    internal static func _getObjectiveCType() -> Any.Type {
        return _ArbitraryEnumObjectiveCBridged.self
    }
    
    internal static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    internal static func _forceBridgeFromObjectiveC(
        source: _ObjectiveCType,
        inout result: ArbitraryEnum?
        )
    {
        if let case1Source = source as? _ArbitraryEnumCase1ObjectiveCBridged {
            result = .Case1(
                case1Source.value1,
                case1Source.value2,
                case1Source.value3,
                case1Source.value4,
                case1Source.value5
            )
        } else if let case2Source = source
            as? _ArbitraryEnumCase2ObjectiveCBridged
        {
            result = .Case2(case2Source.value1)
        } else {
            fatalError()
        }
    }
    
    internal static func _conditionallyBridgeFromObjectiveC(
        source: _ObjectiveCType,
        inout result: ArbitraryEnum?
        )
        -> Bool
    {
        if let case1Source = source as? _ArbitraryEnumCase1ObjectiveCBridged {
            result = .Case1(
                case1Source.value1,
                case1Source.value2,
                case1Source.value3,
                case1Source.value4,
                case1Source.value5
            )
            return true
        } else if let case2Source = source
            as? _ArbitraryEnumCase2ObjectiveCBridged
        {
            result = .Case2(case2Source.value1)
            return true
        } else {
            return false
        }
    }
}

internal class _ArbitraryEnumObjectiveCBridged: ObjCCodingBase {
    
}

internal final class _ArbitraryEnumCase1ObjectiveCBridged:
    _ArbitraryEnumObjectiveCBridged
{
    @NSManaged internal var value1: String
    @NSManaged internal var value2: Bool
    @NSManaged internal var value3: Int
    @NSManaged internal var value4: Float
    @NSManaged internal var value5: Double
    
    internal init(
        value1: String,
        value2: Bool,
        value3: Int,
        value4: Float,
        value5: Double
        )
    {
        super.init()
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
        self.value4 = value4
        self.value5 = value5
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

internal final class _ArbitraryEnumCase2ObjectiveCBridged:
    _ArbitraryEnumObjectiveCBridged
{
    @NSManaged internal var value1: Bool
    
    internal init(value1: Bool) {
        super.init()
        self.value1 = value1
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

