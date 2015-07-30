//
//  NotificationDeliveryTest.swift
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

struct NowNotification: NotificationType {
    typealias PosterType = ANotificationPoster
    
    let poster: PosterType
    
    var notifiedValue = "Now"
    
    init(poster: PosterType) {
        self.poster = poster
    }
}

struct ASAPNotification: NotificationType {
    typealias PosterType = ANotificationPoster
    
    let poster: PosterType
    
    var notifiedValue = "ASAP"
    
    init(poster: PosterType) {
        self.poster = poster
    }
}

struct IdleNotification: NotificationType {
    typealias PosterType = ANotificationPoster
    
    let poster: PosterType
    
    var notifiedValue = "Idle"
    
    init(poster: PosterType) {
        self.poster = poster
    }
}

class NotificationDeliveryTest: XCTestCase {
    let aPoster = ANotificationPoster()
    
    lazy var aNowNotification: NowNotification = {NowNotification(poster: self.aPoster)}()
    lazy var anASAPNotification: ASAPNotification = {ASAPNotification(poster: self.aPoster)}()
    lazy var anIdleNotification: IdleNotification = {IdleNotification(poster: self.aPoster)}()
    
    var nowNotifiedValue: String?
    var ASAPNotifiedValue: String?
    var idleNotifiedValue: String?
    
    override func setUp() {
        super.setUp()
        
        subscribeNotificationOfType(NowNotification.self)
        subscribeNotificationOfType(ASAPNotification.self)
        subscribeNotificationOfType(IdleNotification.self)
        
        aPoster.postNotification(aNowNotification)
        aPoster.postNotification(anASAPNotification)
        aPoster.postNotification(anIdleNotification)
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    func testNotificationDelivery() {
        XCTAssert(nowNotifiedValue == aNowNotification.notifiedValue,
            "Post-Now Notification has not been delivered: \(nowNotifiedValue)")
        XCTAssert(ASAPNotifiedValue == anASAPNotification.notifiedValue,
            "Post-ASAP Notification has not been delivered: \(ASAPNotifiedValue)")
        XCTAssert(idleNotifiedValue == anIdleNotification.notifiedValue,
            "Post-When-Idle notification has not been delivered: \(idleNotifiedValue)")
    }
}

extension NotificationDeliveryTest: NotificationSubscriberType {
    func handleNotification(notification: PrimitiveNotificationType) {
        switch notification {
        case let aNotification as NowNotification:
            nowNotifiedValue = aNotification.notifiedValue
        case let aNotification as ASAPNotification:
            ASAPNotifiedValue = aNotification.notifiedValue
        case let aNotification as IdleNotification:
            idleNotifiedValue = aNotification.notifiedValue
        default: break
        }
    }
}