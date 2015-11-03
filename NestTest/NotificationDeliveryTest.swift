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
import SwiftExt

enum NotificationTimingToken: String {
    case Now = "Now"
    case ASAP = "ASAP"
    case WhenIdle = "WhenIdle"
}

class ANotificationPoster: NotificationPosterType {
    
}

struct NowNotification: NotificationType {
    typealias NotificationPoster = ANotificationPoster
    
    let notificationPoster: Weak<NotificationPoster>
    
    var notifiedValue = "Now"
    
    init(poster: NotificationPoster) {
        self.notificationPoster = Weak<NotificationPoster>(poster)
    }
}

struct ASAPNotification: NotificationType {
    typealias NotificationPoster = ANotificationPoster
    
    let notificationPoster: Weak<NotificationPoster>
    
    var notifiedValue = "ASAP"
    
    init(poster: NotificationPoster) {
        self.notificationPoster = Weak<NotificationPoster>(poster)
    }
}

struct IdleNotification: NotificationType {
    typealias NotificationPoster = ANotificationPoster
    
    let notificationPoster: Weak<NotificationPoster>
    
    var notifiedValue = "Idle"
    
    init(poster: NotificationPoster) {
        self.notificationPoster = Weak<NotificationPoster>(poster)
    }
}

class NotificationDeliveryTest: XCTestCase {
    
    let aPoster = ANotificationPoster()
    
    lazy var aNowNotification: NowNotification
    = {NowNotification(poster: self.aPoster)}()
    lazy var anASAPNotification: ASAPNotification
    = {ASAPNotification(poster: self.aPoster)}()
    lazy var anIdleNotification: IdleNotification
    = {IdleNotification(poster: self.aPoster)}()
    
    var notificationTimingSymbol: [NotificationTimingToken] = []
    
    override func setUp() {
        super.setUp()
        
        subscribeNotificationOfType(NowNotification.self)
        subscribeNotificationOfType(ASAPNotification.self)
        subscribeNotificationOfType(IdleNotification.self)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    var globalExpectation: XCTestExpectation?
    
    func testNotificationDelivery() {
        globalExpectation =
            expectationWithDescription("testNotificationDelivery")
        
        NotificationQueue.current.enqueueNotification(aNowNotification,
            timing: .Now, forModes: [])
        NotificationQueue.current.enqueueNotification(anASAPNotification,
            timing: .ASAP, forModes: [])
        NotificationQueue.current.enqueueNotification(anIdleNotification,
            timing: .WhenIdle, forModes: [])
        
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 5))
        
        waitForExpectationsWithTimeout(10) { (error) -> Void in
            if let error = error {
                XCTFail("Dispatch invoke timing test failed with error: \(error)")
            }
        }
    }
}

extension NotificationDeliveryTest: NotificationSubscriberType {
    func handleNotification(notification: PrimitiveNotificationType) {
        print("\(notification)")
        switch notification {
        case is NowNotification:
            notificationTimingSymbol.append(.Now)
        case is ASAPNotification:
            notificationTimingSymbol.append(.ASAP)
        case is IdleNotification:
            notificationTimingSymbol.append(.WhenIdle)
            
            if notificationTimingSymbol == [.Now, .ASAP, .WhenIdle] {
                globalExpectation?.fulfill()
            }
        default: break
        }
    }
}