//
//  ObjectiveCTest.swift
//  Nest
//
//  Created by Manfred on 11/20/15.
//
//

@testable
import Nest

import SwiftExt

import XCTest

class ObjectiveCTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_sel_belongsToProtocol() {
        
        let matchedPairs: [Selector: Protocol] = [
            #selector(URLSessionDelegate.urlSession(_:didBecomeInvalidWithError:)):
                URLSessionDelegate.self,
            #selector(URLSessionDelegate.urlSession(_:didReceive:completionHandler:)):
                URLSessionDelegate.self,
            #selector(URLSessionDelegate.urlSessionDidFinishEvents(forBackgroundURLSession:)):
                URLSessionDelegate.self
        ]
        
        let mismatchedPairs: [String: Protocol] = [
            "fileManager:shouldMoveItemAtURL:toURL:": XMLParserDelegate.self,
            "parserDidStartDocument:": FileManagerDelegate.self
        ]
        
        for (aSelector, aProtocol) in matchedPairs {
            XCTAssert(sel_belongsToProtocol(aSelector, aProtocol),
                "\(NSStringFromSelector(aSelector)) shall be a member of \(NSStringFromProtocol(aProtocol))")
        }
        
        for (selString, aProtocol) in mismatchedPairs {
            XCTAssert(!sel_belongsToProtocol(Selector(selString), aProtocol),
                "\(selString) shall not be a member of \(NSStringFromProtocol(aProtocol))")
        }
        
        
    }

}
