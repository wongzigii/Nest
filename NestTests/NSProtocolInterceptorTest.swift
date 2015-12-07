//
//  ObjCProtocolInterceptorTest.swift
//  Nest
//
//  Created by Manfred Lau on 6/6/15.
//
//

import Foundation
import XCTest
import Nest

private protocol MessagePool: class {
    func pushMessage(message: String)
}

private let ReceiverToken = "Receiver received message"
private let MiddleManToken = "Middle man received message"

@objc private protocol OperatorDelegate: NSObjectProtocol {
    optional func operatorDidSendMessageToMiddleMan()
    optional func operatorDidSendMessageToReceiver()
}

private class RealDelegate: NSObject, OperatorDelegate {
    weak var messagePool: MessagePool?
    
    @objc func operatorDidSendMessageToReceiver() {
        messagePool?.pushMessage(ReceiverToken)
    }
    
    @objc func operatorDidSendMessageToMiddleMan() {
        messagePool?.pushMessage(MiddleManToken)
    }
}

//MARK: - Test Cases
class ObjCProtocolInterceptorTest: XCTestCase, MessagePool {
    private var onceToken: dispatch_once_t = 0
    
    private weak var delegate: OperatorDelegate?
    private var realDelegate: RealDelegate!
    private var protocolInterceptor: ObjCProtocolInterceptor!
    
    private var messagePool: [String] = []
    
    private func pushMessage(message: String) {
        messagePool.append(message)
    }
    
    private func sendMessageIfNecessary() {
        dispatch_once(&onceToken) {
            self.delegate?.operatorDidSendMessageToMiddleMan?()
            self.delegate?.operatorDidSendMessageToReceiver?()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        let aRealDelegate = RealDelegate()
        aRealDelegate.messagePool = self
        realDelegate = aRealDelegate
        
        let aProtocolInterceptor = ObjCProtocolInterceptor
            .againstProtocol(OperatorDelegate.self)
        aProtocolInterceptor.receiver = aRealDelegate
        aProtocolInterceptor.containsMiddleMan(self)
        protocolInterceptor = aProtocolInterceptor
        
        delegate = aProtocolInterceptor as? OperatorDelegate
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testProtocolInterceptorAssignment() {
        NSLog("delegate: \(delegate)")
        XCTAssert(delegate is ObjCProtocolInterceptor, "Protocol interceptor assignment not pass")
    }
    
    func testReceiverMessageForwarding() {
        sendMessageIfNecessary()
        
        let hasOnlyOneReceiverToken = messagePool.filter
            { $0 == ReceiverToken }.count == 1
        XCTAssert(hasOnlyOneReceiverToken, "Receiver message forwarding not pass")
    }

    func testMiddleMenMessageForwarding() {
        sendMessageIfNecessary()
        
        let hasOnlyOneMiddleMenToken = messagePool.filter
            { $0 == MiddleManToken }.count == 1
        
        XCTAssert(hasOnlyOneMiddleMenToken, "Middle men forwarding not pass")
    }
}

//MARK: - OperatorDelegate
extension ObjCProtocolInterceptorTest: OperatorDelegate {
    @objc func operatorDidSendMessageToMiddleMan() {
        pushMessage(MiddleManToken)
    }
}
