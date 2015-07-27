//
//  Notifications.swift
//  Nest
//
//  Created by Manfred on 7/26/15.
//
//

import SwiftExt
import Foundation

//MARK: - Notification Center
class NotificationCenter {
    static var shared = NotificationCenter()
    
    private init() {}
    
    private var subscriptions: [NotificationSubscriptionType] = []
    
    func subscriber
        <N: NotificationType>
        (subscriber: NotificationSubscriberType,
        subscribeNotificationOfType notificationType: N.Type,
        onQueue queue: NotificationQueue = NotificationQueue.current)
    {
        let notificationSubscription = NotificationSubscription<N>(
            notificationType: notificationType,
            subscriber: subscriber,
            queue: queue)
        
        var alreadySubscribed = false
        for each in subscriptions {
            switch each {
            case let existed as NotificationSubscription<N>:
                if existed == notificationSubscription {
                    alreadySubscribed = true
                    break
                }
            default: continue
            }
        }
        
        if !alreadySubscribed {
            subscriptions.append(notificationSubscription)
        }
    }
    
    func postNotification(notification: NotificationCenterManageableType) {
        for eachSubscription in NotificationCenter.shared.subscriptions {
            if eachSubscription.isSubscribedNotification(notification) {
                eachSubscription.subscriber.handleNotification(notification)
            } else {
                continue
            }
        }
    }
}

//MARK: - Notification Queue
public class NotificationQueue {
    private static var queues: [Weak<NSThread>: NotificationQueue] = [:]
    
    private let notificationCenter: NotificationCenter
    
    private var ASAPQueue = [NotificationCenterManageableType]()
    private var idleQueue = [NotificationCenterManageableType]()
    
    public enum PostTiming: Int {
        case WhenIdle, ASAP, Now
    }
    
    public struct Coalescing: OptionSetType {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        
        public static let CoalescingOnName      = Coalescing(rawValue: 1 << 0)
        public static let CoalescingOnSender    = Coalescing(rawValue: 1 << 1)
    }
    
    public class var current: NotificationQueue {
        let threadWrapper = Weak<NSThread>(NSThread.currentThread())
        if let currentQueue =
            queues[threadWrapper]
        {
            return currentQueue
        } else {
            let newQueue = NotificationQueue(NotificationCenter.shared)
            queues[threadWrapper] = newQueue
            return newQueue
        }
    }
    
    public func enqueueNotification
        <N: NotificationType>
        (notification: N,
        timing: PostTiming, 
        coalesce: Coalescing = [],
        forModes modes: NSRunLoopMode = NSRunLoopMode.defaultMode)
    {
        switch timing {
        case .Now:
            if modes.contains(NSRunLoop.currentRunLoop().currentRunLoopMode) ||
                modes == []
            {
                notificationCenter.postNotification(notification)
            }
        case .ASAP:
            ASAPQueue.append(notification)
            NSRunLoop.currentRunLoop().performSelector(
                "postNotificationsInASAPQueue",
                target: self,
                argument: nil,
                order: 0,
                modes: modes.rawValues)
        case .WhenIdle:
            idleQueue.append(notification)
            NSRunLoop.currentRunLoop().performSelector(
                "postNotificationsInIdleQueue",
                target: self,
                argument: nil,
                order: 0,
                modes: modes.rawValues)
        }
    }
    
    dynamic func postNotificationsInASAPQueue() {
        for each in ASAPQueue {
            for eachSubscription in NotificationCenter.shared.subscriptions {
                if eachSubscription.isSubscribedNotification(each) {
                    notificationCenter.postNotification(each)
                }
            }
        }
        
    }
    
    dynamic func postNotificationsInIdleQueue() {
        
    }
    
    public func dequeueNotificationsMatching
        <N: NotificationType>
        (notification: N,
        coalesce: Coalescing = [])
    {
        var removedIndicesInASAPQueue = [Int]()
        var removedIndicesInIdleQueue = [Int]()
        
        let containsCoalescingOnName    = coalesce.contains(.CoalescingOnName)
        let containsCoalescingOnSender  = coalesce.contains(.CoalescingOnSender)
        
        guard containsCoalescingOnName || containsCoalescingOnSender
            else { return }
        
        for (index, each) in ASAPQueue.enumerate() {
            if containsCoalescingOnName {
                if each.isNotificationMatchingName(notification) {
                    removedIndicesInASAPQueue.append(index)
                }
            }
            if containsCoalescingOnSender {
                if each.isNotificationMatchingSender(notification) {
                    removedIndicesInASAPQueue.append(index)
                }
            }
        }
        
        for (index, each) in idleQueue.enumerate() {
            if containsCoalescingOnName {
                if each.isNotificationMatchingName(notification) {
                    removedIndicesInIdleQueue.append(index)
                }
            }
            if containsCoalescingOnSender {
                if each.isNotificationMatchingSender(notification) {
                    removedIndicesInIdleQueue.append(index)
                }
            }
        }
        
        ASAPQueue.removeIndices(removedIndicesInASAPQueue)
        idleQueue.removeIndices(removedIndicesInIdleQueue)
    }
    
    private init(_ notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }
}

//MARK: - Notification Subscription Type
protocol NotificationSubscriptionType: class {
    var subscriber: NotificationSubscriberType { get }
    var queue: NotificationQueue { get }
    
    func isSubscribedNotification
        (notification: NotificationCenterManageableType)
        -> Bool
}

//MARK: - Notification Subscription
class NotificationSubscription<N: NotificationCenterManageableType>:
    NotificationSubscriptionType, Equatable
{
    typealias Notification = N
    
    let subscriber: NotificationSubscriberType
    
    let queue: NotificationQueue
    
    init<N: NotificationType>
        (notificationType: N.Type,
        subscriber: NotificationSubscriberType,
        queue: NotificationQueue)
    {
        self.subscriber = subscriber
        self.queue = queue
    }
    
    func isSubscribedNotification
        (notification: NotificationCenterManageableType)
        -> Bool
    {
        return notification is Notification
    }
}

func ==<N: NotificationCenterManageableType>
    (lhs: NotificationSubscription<N>,
    rhs: NotificationSubscription<N>)
    -> Bool
{
    return lhs.queue === rhs.queue &&
        lhs.subscriber === rhs.subscriber
}

//MARK: - Notification Center Manageable Type
public protocol NotificationCenterManageableType {
    static var name: String {get}
}

extension NotificationCenterManageableType {
    private func isNotificationMatchingName
        <N: NotificationType>
        (notification: N)
        -> Bool
    {
        return N.name == self.dynamicType.name
    }
    
    private func isNotificationMatchingSender
        <N: NotificationType>
        (notification: N)
        -> Bool
    {
        switch self {
        case let aConcreteNotificationType as N:
            return aConcreteNotificationType.sender === notification.sender
        default: return false
        }
    }
}

//MARK: - Notification Type
public protocol NotificationType: NotificationCenterManageableType {
    typealias SenderType: NotificationPosterType
    var sender: SenderType {get}
}

//MARK: - Notification Subscriber Type
public protocol NotificationSubscriberType: class {
    func subscribeNotificationOfType
        <N: NotificationType>
        (notificationType: N.Type)
    
    func subscribeNotificationOfType
        <N: NotificationType>
        (notificationType: N.Type,
        onQueue queue: NotificationQueue)
    
    func handleNotification(notification: NotificationCenterManageableType)
}

extension NotificationSubscriberType {
    public func subscribeNotificationOfType
        <N: NotificationType>
        (notificationType: N.Type)
    {
        NotificationCenter.shared.subscriber(self,
            subscribeNotificationOfType: notificationType)
    }
    
    public func subscribeNotificationOfType
        <N: NotificationType>
        (notificationType: N.Type,
        onQueue queue: NotificationQueue)
    {
        NotificationCenter.shared.subscriber(self,
            subscribeNotificationOfType: notificationType,
            onQueue: queue)
    }
}

//MARK: - Notification Poster Type
public protocol NotificationPosterType: class {
    func postNotification
        <N: NotificationType where N.SenderType == Self>
        (notification: N)
}

extension NotificationPosterType {
    public func postNotification
        <N: NotificationType where N.SenderType == Self>
        (notification: N)
    {
        NotificationCenter.shared.postNotification(notification)
    }
}


