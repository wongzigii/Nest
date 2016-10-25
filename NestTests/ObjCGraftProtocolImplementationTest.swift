//
//  ObjCGraftProtocolImplementationTest.swift
//  Nest
//
//  Created by Manfred on 22/10/2016.
//
//

@testable
import Nest

import XCTest

internal struct AccessSource: OptionSet {
    internal typealias RawValue = Int
    internal let rawValue: Int
    internal init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    internal static let objectA = AccessSource(rawValue: 1)
    internal static let objectB = AccessSource(rawValue: 1 << 1)
}

internal class ObjectA: NSObject, AProtocol {
    internal var intValue: Int {
        get {
            getSource.insert(.objectA)
            return _intValue_
        }
        set {
            setSource.insert(.objectA)
            _intValue_ = newValue
        }
    }
    
    internal func instanceMethod() {
        instanceMethodSource.insert(.objectA)
    }
    
    internal class func classMethod() {
        classMethodSource.insert(.objectA)
    }
    
    internal var getSource: AccessSource = []
    
    internal var setSource: AccessSource = []
    
    internal var instanceMethodSource: AccessSource = []
    
    internal static var classMethodSource: AccessSource = []
    
    private var _intValue_: Int = 0
}

internal class ObjectB: ObjectA {
    internal override var intValue: Int {
        get {
            getSource.insert(.objectB)
            return super.intValue
        }
        set {
            setSource.insert(.objectB)
            super.intValue = newValue
        }
    }
    
    internal override func instanceMethod() {
        instanceMethodSource.insert(.objectB)
        super.instanceMethod()
    }
    
    internal override class func classMethod() {
        classMethodSource.insert(.objectB)
        super.classMethod()
    }
}

class ObjCGraftProtocolImplementationTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testObjCGraftProtocolImplementation() {
        
        let objectA = ObjectA()
        
        let grafted: AProtocol = objectA
        
        grafted.intValue = 3
        _ = grafted.intValue
        
        grafted.instanceMethod()
        type(of: grafted).classMethod()
        
        ObjCGraftProtocolImplementation(of: AProtocol.self, on: ObjectB.self, to: grafted)
        
        grafted.intValue = 4
        _ = grafted.intValue
        
        grafted.instanceMethod()
        type(of: grafted).classMethod()
        
        XCTAssert(objectA.getSource.contains(.objectA) && objectA.getSource.contains(.objectB))
        XCTAssert(objectA.setSource.contains(.objectA) && objectA.setSource.contains(.objectB))
        XCTAssert(objectA.instanceMethodSource.contains(.objectA) && objectA.instanceMethodSource.contains(.objectB))
        XCTAssert(type(of: objectA).classMethodSource.contains(.objectA) && type(of: objectA).classMethodSource.contains(.objectB))
        
        XCTAssert(grafted is ObjectA)
        XCTAssert(!(grafted is ObjectB))
    }
}
