//
//  NotificationTests.swift
//  Nest
//
//  Created by Manfred on 7/27/15.
//
//

@testable
import Nest
import XCTest

class ANotificationPoster: NotificationPosterType {
    
}

struct Notification: NotificationType {
    static let name = "A Notification Name"
    
    typealias SenderType = ANotificationPoster
    
    let sender: SenderType
    
    var notifiedValue = 3.0
    
    init(sender: SenderType) {
        self.sender = sender
    }
}

class NotificationTests: XCTestCase {
    let aPoster = ANotificationPoster()
    
    var notifiedValue: Double?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNotification() {
        self.subscribeNotificationOfType(Notification.self)
        
        let notification = Notification(sender: aPoster)
        aPoster.postNotification(notification)
        
        XCTAssert(notifiedValue == notification.notifiedValue,
            "Notification has not been delivered!")
    }
}

extension NotificationTests: NotificationSubscriberType {
    func handleNotification(notification: NotificationCenterManageableType) {
        switch notification {
        case let aNotification as Notification:
            notifiedValue = aNotification.notifiedValue
            NSLog("Notified value: \(aNotification.notifiedValue)")
        default: break
        }
    }
}