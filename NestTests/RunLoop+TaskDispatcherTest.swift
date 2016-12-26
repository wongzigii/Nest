//
//  NSRunLoop+TaskDispatcherTest.swift
//  Nest
//
//  Created by Manfred on 10/22/15.
//
//

import XCTest
import Nest

private typealias TimingSymbols = RunLoop.Timing

class RunLoop_TaskDispatcherTest: XCTestCase {
    private var timingSymbols: [TimingSymbols] = []
    
    /// Malfunctioned
    func testDispatchInvokeTiming() {
        
        let expectation = self.expectation(
            description: "testDispatchInvokeTiming"
        )
        
        RunLoop.current.schedule(in: .commonModes, when: .nextLoopBegan) {
            self.timingSymbols.append(.nextLoopBegan)
        }
        
        RunLoop.current.schedule(in: .commonModes, when: .idle) {
            self.timingSymbols.append(.idle)
        }
        
        RunLoop.current.schedule(in: .commonModes, when: .currentLoopEnded) {
            self.timingSymbols.append(.currentLoopEnded)
            
            RunLoop.current.schedule(in: .commonModes, when: .nextLoopBegan) {
                if self.timingSymbols
                    == [.nextLoopBegan, .idle, .currentLoopEnded]
                {
                    expectation.fulfill()
                } else {
                    print(self.timingSymbols)
                }
            }
        }
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let error = error {
                XCTFail("Dispatch invoke timing(\(self.timingSymbols)) test failed with error: \(error)")
            }
        }
    }
}
