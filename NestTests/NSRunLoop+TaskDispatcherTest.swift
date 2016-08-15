//
//  NSRunLoop+TaskDispatcherTest.swift
//  Nest
//
//  Created by Manfred on 10/22/15.
//
//

import XCTest
import Nest

private typealias TimingSymbols = RunLoopTaskInvokeTiming

class NSRunLoop_TaskDispatcherTest: XCTestCase {
    private var timingSymbols: [TimingSymbols] = []
    
    /// Malfunctioned
    func testDispatchInvokeTiming() {
        
        let expectation = self.expectation(description: "testDispatchInvokeTiming")
        
        _ = RunLoop.current.perform {
            self.timingSymbols.append(.currentLoopEnded)
            }.forModes(.commonModes)
            .when(.currentLoopEnded)
        
        _ = RunLoop.current.perform {
            self.timingSymbols.append(.nextLoopBegan)
            }.forModes(.commonModes)
            .when(.nextLoopBegan)
        
        _ = RunLoop.current.perform {
            self.timingSymbols.append(.idle)
            
            }.forModes(.commonModes)
            .when(.idle)
        
        _ = RunLoop.current.perform {
            if self.timingSymbols
                == [.currentLoopEnded, .nextLoopBegan, .idle]
            {
                expectation.fulfill()
            }
            
            }.forModes(.commonModes)
            .when(.idle)
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
        
        waitForExpectations(timeout: 3) { (error) -> Void in
            if let error = error {
                XCTFail("Dispatch invoke timing test failed with error: \(error)")
            }
        }
    }
    
    private func doNothing() {
        print("Fuck")
    }
}
