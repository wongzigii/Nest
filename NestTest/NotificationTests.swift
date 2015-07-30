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
    typealias PosterType = ANotificationPoster
    
    let poster: PosterType
    
    var notifiedValue = 3.0
    
    init(poster: PosterType) {
        self.poster = poster
    }
}

class NotificationTests: XCTestCase {
    let aPoster = ANotificationPoster()
    
    var notifiedValue: Double?
    
    override func setUp() {
        super.setUp()
        notifiedValue = nil
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        notifiedValue = nil
    }
    
    func testNotificationPost() {
        subscribeNotificationOfType(Notification.self)
        
        let notification = Notification(poster: aPoster)
        aPoster.postNotification(notification)
        
        XCTAssert(notifiedValue == notification.notifiedValue,
            "Notification has not been delivered!")
    }
    
    func testNotificationPostASAP() {
        subscribeNotificationOfType(Notification.self)
        
        let notification = Notification(poster: aPoster)
        NotificationQueue.current.enqueueNotification(notification,
            timing: .ASAP)
        
        XCTAssert(notifiedValue == nil,
            "Notification has been delivered!")
    }
    
    func testNotificationPostWhenIdle() {
        subscribeNotificationOfType(Notification.self)
        
        let notification = Notification(poster: aPoster)
        NotificationQueue.current.enqueueNotification(notification,
            timing: .WhenIdle)
        
        XCTAssert(notifiedValue == nil,
            "Notification has been delivered!")
    }
}

extension NotificationTests: NotificationSubscriberType {
    func handleNotification(notification: PrimitiveNotificationType) {
        switch notification {
        case let aNotification as Notification:
            notifiedValue = aNotification.notifiedValue
            NSLog("Notified value: \(aNotification.notifiedValue)")
        default: break
        }
    }
}