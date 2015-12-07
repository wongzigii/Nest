//
//  NSRunLoop+TaskDispatcherTest.swift
//  Nest
//
//  Created by Manfred on 10/22/15.
//
//

import XCTest
import Nest

private typealias TimingSymbols = NSRunLoopTaskInvokeTiming

class NSRunLoop_TaskDispatcherTest: XCTestCase {
    private var timingSymbols: [TimingSymbols] = []
    
    /// Malfunctioned
    func testDispatchInvokeTiming() {
        
        let expectation = expectationWithDescription("testDispatchInvokeTiming")
        
        NSRunLoop.currentRunLoop().perform {
            self.timingSymbols.append(.CurrentLoopEnded)
            }.forModes(.commonModes)
            .when(.CurrentLoopEnded)
        
        NSRunLoop.currentRunLoop().perform {
            self.timingSymbols.append(.NextLoopBegan)
            }.forModes(.commonModes)
            .when(.NextLoopBegan)
        
        NSRunLoop.currentRunLoop().perform {
            self.timingSymbols.append(.Idle)
            
            }.forModes(.commonModes)
            .when(.Idle)
        
        NSRunLoop.currentRunLoop().perform {
            if self.timingSymbols
                == [.CurrentLoopEnded, .NextLoopBegan, .Idle]
            {
                expectation.fulfill()
            }
            
            }.forModes(.commonModes)
            .when(.Idle)
        
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 1))
        
        waitForExpectationsWithTimeout(3) { (error) -> Void in
            if let error = error {
                XCTFail("Dispatch invoke timing test failed with error: \(error)")
            }
        }
    }
    
    private func doNothing() {
        print("Fuck")
    }
}