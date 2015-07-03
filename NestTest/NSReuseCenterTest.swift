//
//  ReuseCenterTest.swift
//  Nest
//
//  Created by Manfred Lau on 6/6/15.
//
//

import Foundation
import XCTest
import Nest

private let ReuseIdentifier1 = "ReuseIdentifier1"
private let ReuseIdentifier2 = "ReuseIdentifier2"
private let ReuseIdentifier3 = "ReuseIdentifier3"
private let ReuseIdentifier4 = "ReuseIdentifier4"

private let unused1: [ParticularReusable] = ["Test1,ReuseIdentifier1", "Test2,ReuseIdentifier1", "Test3,ReuseIdentifier1", "Test4,ReuseIdentifier1", "Test5,ReuseIdentifier1", "Test6,ReuseIdentifier1"]
private let unused2: [ParticularReusable] = ["Test1,ReuseIdentifier2", "Test2,ReuseIdentifier2", "Test3,ReuseIdentifier2", "Test4,ReuseIdentifier2", "Test5,ReuseIdentifier2", "Test6,ReuseIdentifier2"]
private let unused3: [ParticularReusable] = ["Test1,ReuseIdentifier3", "Test2,ReuseIdentifier3", "Test3,ReuseIdentifier3", "Test4,ReuseIdentifier3", "Test5,ReuseIdentifier3", "Test6,ReuseIdentifier3"]
private let unused4: [ParticularReusable] = ["Test1,ReuseIdentifier4", "Test2,ReuseIdentifier4", "Test3,ReuseIdentifier4", "Test4,ReuseIdentifier4", "Test5,ReuseIdentifier4", "Test6,ReuseIdentifier4"]

private let testCombinations = [
    ReuseIdentifier1: unused1,
    ReuseIdentifier2: unused2,
    ReuseIdentifier3: unused3,
    ReuseIdentifier4: unused4
]

class ReuseCenterTest: XCTestCase {
    
    var reuseCenter = ReuseCenter<ParticularReusable>()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func enqueueTestCombination(testCombination: [String: [ParticularReusable]], handler: (reuseCenter: ReuseCenter<ParticularReusable>,reuseIdentifier: String, unused: [ParticularReusable])->Void) {
        for (reuseIdentifier, unused) in testCombination {
            for eachUnused in unused {
                reuseCenter.enqueueUnused(eachUnused)
            }
            handler(reuseCenter: reuseCenter, reuseIdentifier: reuseIdentifier, unused: unused)
        }
    }
    
    func testPrepareForReuse() {
        var preparedForReuse = true
        
        enqueueTestCombination(testCombinations, handler: { (reuseCenter, reuseIdentifier, unused) -> Void in
            while let dequeued = reuseCenter.dequeueReusableWithReuseIdentifier(ReuseIdentifier1) {
                if dequeued.contentString != "" {
                    preparedForReuse = false
                    break
                }
            }
        })
        
        XCTAssert(preparedForReuse, "Pass")
    }

    func testEnqueue() {
        var enqueueSuccess = true
        enqueueTestCombination(testCombinations, handler: { (reuseCenter, reuseIdentifier, unused) -> Void in
            if let enqueued = reuseCenter.reusableForReuseIdentifier(reuseIdentifier) {
                enqueueSuccess = enqueueSuccess && enqueued == unused
            }
        })
        XCTAssert(enqueueSuccess, "Pass")
    }

    func testDequeue() {
        var dequeueSuccess = true
        
        enqueueTestCombination(testCombinations, handler: { (reuseCenter, reuseIdentifier, unused) -> Void in
            var dequeuedCount = 0
            
            while let _ = reuseCenter.dequeueReusableWithReuseIdentifier(reuseIdentifier) {
                dequeuedCount += 1
            }
            
            dequeueSuccess = dequeueSuccess && (dequeuedCount == unused.count)
        })
        
        XCTAssert(dequeueSuccess, "Pass")
    }

}

class ParticularReusable: NSObject, NSReusable, StringLiteralConvertible {
    let reuseIdentifier: String
    
    var contentString = ""
    
    func prepareForReuse() {
        contentString = ""
    }
    
    init(reuseIdentifier anIdentifier: String) {
        reuseIdentifier = anIdentifier
    }
    
    init(_ aContentString: String) {
        contentString = aContentString
        reuseIdentifier = ReuseIdentifier1
    }
    
    required init(stringLiteral value: String) {
        let splits = split(value.characters, isSeparator: {$0 == ","}).map { String($0) }
        contentString = splits.first!
        reuseIdentifier = splits.last!
    }
    
    required init(extendedGraphemeClusterLiteral value: String) {
        let splits = split(value.characters, isSeparator: {$0 == ","}).map { String($0) }
        contentString = splits.first!
        reuseIdentifier = splits.last!
    }
    
    required init(unicodeScalarLiteral value: String) {
        let splits = split(value.characters, isSeparator: {$0 == ","}).map { String($0) }
        contentString = splits.first!
        reuseIdentifier = splits.last!
    }
}
