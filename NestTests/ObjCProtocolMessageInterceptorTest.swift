//
//  ObjCProtocolMessageInterceptorTest.swift
//  Nest
//
//  Created by Manfred Lau on 6/6/15.
//
//

import Foundation
import XCTest
import Nest

private protocol MessagePool: class {
    func pushMessage(_ message: String)
}

private let ReceiverToken = "Receiver received message"
private let MiddleManToken = "Middle man received message"

@objc private protocol OperatorDelegate: NSObjectProtocol {
    @objc optional func operatorDidSendMessageToMiddleMan()
    @objc optional func operatorDidSendMessageToReceiver()
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
class ObjCProtocolMessageInterceptorTest: XCTestCase, MessagePool {
    private lazy var __once: () = {
            self.delegate?.operatorDidSendMessageToMiddleMan?()
            self.delegate?.operatorDidSendMessageToReceiver?()
        }()
    
    private weak var delegate: OperatorDelegate?
    private var realDelegate: RealDelegate!
    private var protocolInterceptor: ObjCProtocolMessageInterceptor!
    
    private var messagePool: [String] = []
    
    fileprivate func pushMessage(_ message: String) {
        messagePool.append(message)
    }
    
    private func sendMessageIfNecessary() {
        _ = self.__once
    }
    
    override func setUp() {
        super.setUp()
        
        let aRealDelegate = RealDelegate()
        aRealDelegate.messagePool = self
        realDelegate = aRealDelegate
        
        let aProtocolInterceptor = ObjCProtocolMessageInterceptor
            .make(protocol: OperatorDelegate.self)
        aProtocolInterceptor.receiver = aRealDelegate
        _ = aProtocolInterceptor.containsMiddleMan(self)
        protocolInterceptor = aProtocolInterceptor
        
        delegate = aProtocolInterceptor as? OperatorDelegate
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testProtocolInterceptorAssignment() {
        XCTAssert(delegate is ObjCProtocolMessageInterceptor, "Protocol interceptor assignment not pass")
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
extension ObjCProtocolMessageInterceptorTest: OperatorDelegate {
    @objc func operatorDidSendMessageToMiddleMan() {
        pushMessage(MiddleManToken)
    }
}
