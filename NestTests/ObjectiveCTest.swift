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
        
        let matchedPairs: [String: Protocol] = [
            "URLSession:didBecomeInvalidWithError:":
                NSURLSessionDelegate.self,
            "URLSession:didReceiveChallenge:completionHandler:":
                NSURLSessionDelegate.self,
            "URLSessionDidFinishEventsForBackgroundURLSession:":
                NSURLSessionDelegate.self
        ]
        
        let mismatchedPairs: [String: Protocol] = [
            "fileManager:shouldMoveItemAtURL:toURL:": NSXMLParserDelegate.self,
            "parserDidStartDocument:": NSFileManagerDelegate.self
        ]
        
        for (aSelector, aProtocol) in matchedPairs {
            XCTAssert(sel_belongsToProtocol(Selector(aSelector), aProtocol),
                "\(aSelector) shall be a member of \(NSStringFromProtocol(aProtocol))")
        }
        
        for (aSelector, aProtocol) in mismatchedPairs {
            XCTAssert(!sel_belongsToProtocol(Selector(aSelector), aProtocol),
                "\(aSelector) shall not be a member of \(NSStringFromProtocol(aProtocol))")
        }
        
        
    }

}
