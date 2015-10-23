//
//  NSRunLoop+TaskDispatcherTest.swift
//  Nest
//
//  Created by Manfred on 10/22/15.
//
//

@testable
import Nest
import XCTest

class NSRunLoop_TaskDispatcherTest: XCTestCase {
    func testDispatchInvokeTiming() {
        let expectation = expectationWithDescription("testDispatchInvokeTiming")
        
        var timingSymbols: [NSRunLoopTaskInvokeTiming] = []
        
        NSRunLoop.currentRunLoop().perform {
            timingSymbols.append(.CurrentLoopEnded)
            }.forModes(.commonModes)
            .when(.CurrentLoopEnded)
        
        NSRunLoop.currentRunLoop().perform {
            timingSymbols.append(.NextLoopBegan)
            }.forModes(.commonModes)
            .when(.NextLoopBegan)
        
        NSRunLoop.currentRunLoop().perform {
            timingSymbols.append(.Idle)
            }.forModes(.commonModes)
            .when(.Idle)
        
        NSRunLoop.currentRunLoop().perform {
            if timingSymbols == [.CurrentLoopEnded, .NextLoopBegan, .Idle] {
                expectation.fulfill()
            }
            
            }.forModes(.commonModes)
            .when(.Idle)
        
        waitForExpectationsWithTimeout(10) { (error) -> Void in
            if let error = error {
                XCTFail("Dispatch invoke timing test failed with error: \(error)")
            }
        }
    }
}