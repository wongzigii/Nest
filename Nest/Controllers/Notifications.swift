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
public class NotificationCenter {
    public static var shared = NotificationCenter()
    
    private init() {}
    
    private var subscriptions: [NotificationSubscriptionType] = []
    
    public func subscriber
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
    
    public func postNotification(notification: PrimitiveNotificationType) {
        for eachSubscription in NotificationCenter.shared.subscriptions {
            if eachSubscription.subscribedNotification(notification) {
                eachSubscription.subscriber.handleNotification(notification)
            } else {
                continue
            }
        }
    }
}

private protocol NotificationPostRequestType {
    var coalescing: NotificationQueue.Coalescing { get }
    var modes: NSRunLoopMode { get }
    var timestamp: NSTimeInterval { get }
    
    var poster: NotificationPosterType { get }
    var primitiveNotification: PrimitiveNotificationType { get }
}

extension NotificationPostRequestType {
    func isRequestingToPostNotification<N: NotificationType>(notification: N)
        -> Bool
    {
        switch self  {
        case is NotificationPostRequest<N>: return true
        default:                            return false
        }
    }
    
    func isRequestedByPosterOfNotification<N: NotificationType>(notification: N)
        -> Bool
    {
        switch self  {
        case let notificationPostRequest as NotificationPostRequest<N>:
            return notificationPostRequest.notification.poster
                === notification.poster
        default:
            return false
        }
    }
    
    func shouldCoalesce(postRequest: NotificationPostRequestType) -> Bool {
        if self.coalescing.contains(.OnType) {
            return self.dynamicType == postRequest.dynamicType
        }
        if self.coalescing.contains(.OnPoster) {
            return self.poster === postRequest.poster
        }
        return false
    }
}

private struct NotificationPostRequest<N: NotificationType>:
    NotificationPostRequestType
{
    typealias Notification = N
    
    let notification: Notification
    
    let coalescing: NotificationQueue.Coalescing
    let modes: NSRunLoopMode
    let timestamp: NSTimeInterval
    
    var poster: NotificationPosterType { return notification.poster }
    var primitiveNotification: PrimitiveNotificationType { return notification }
    
    init(notification: Notification,
        coalescing: NotificationQueue.Coalescing,
        modes: NSRunLoopMode)
    {
        self.notification = notification
        self.coalescing = coalescing
        self.modes = modes
        self.timestamp = NSDate.timeIntervalSinceReferenceDate()
    }
}

//MARK: - Notification Queue
public class NotificationQueue {
    private static var queues: [Weak<NSThread>: NotificationQueue] = [:]
    
    private let notificationCenter: NotificationCenter
    
    private var runLoopObserver: CFRunLoopObserverRef!
    
    private var ASAPQueue = [NotificationPostRequestType]()
    private var idleQueue = [NotificationPostRequestType]()
    
    public enum PostTiming: Int {
        case WhenIdle, ASAP, Now
    }
    
    public struct Coalescing: OptionSetType {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        
        public static let OnType    = Coalescing(rawValue: 1 << 0)
        public static let OnPoster  = Coalescing(rawValue: 1 << 1)
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
            if !modes.intersect(NSRunLoop.currentRunLoop().currentRunLoopMode)
                .isEmpty ||
                modes == []
            {
                notificationCenter.postNotification(notification)
            }
        case .ASAP:
            let postRequest = NotificationPostRequest(
                notification: notification,
                coalescing: coalesce, 
                modes: modes)
            ASAPQueue.append(postRequest)
        case .WhenIdle:
            let postRequest = NotificationPostRequest(
                notification: notification,
                coalescing: coalesce,
                modes: modes)
            idleQueue.append(postRequest)
        }
    }
    
    private func postNotificationsInQueue(
        inout queue: [NotificationPostRequestType],
        mode: NSRunLoopMode)
    {
        var coalescedPostRequest = [NotificationPostRequestType]()
        
        var unprocessedPostRequests = [NotificationPostRequestType]()
        
        // Coalescing
        for postRequest in queue {
            if postRequest.modes.contains(mode) {
                let shouldIgnorePostRequest: Bool = {
                    for eachCoalesced in coalescedPostRequest
                        where eachCoalesced.shouldCoalesce(postRequest)
                    {
                        return true
                    }
                    return false
                }()
                
                if !shouldIgnorePostRequest {
                    coalescedPostRequest.append(postRequest)
                }
            } else {
                unprocessedPostRequests.append(postRequest)
            }
        }
        
        queue = unprocessedPostRequests
        
        for postRequest in coalescedPostRequest {
            let primitiveNotification = postRequest.primitiveNotification
            
            for subscription in NotificationCenter.shared.subscriptions
                where subscription.queue === self &&
                    subscription.subscribedNotification(primitiveNotification)
            {
                notificationCenter.postNotification(primitiveNotification)
            }
        }
    }
    
    public func dequeueNotificationsMatching
        <N: NotificationType>
        (notification: N,
        coalesce: Coalescing = [])
    {
        var removedIndicesInASAPQueue = [Int]()
        var removedIndicesInIdleQueue = [Int]()
        
        let containsCoalescingOnType    = coalesce.contains(.OnType)
        let containsCoalescingOnPoster  = coalesce.contains(.OnPoster)
        
        guard containsCoalescingOnType || containsCoalescingOnPoster
            else { return }
        
        for (index, eachPostRequest) in ASAPQueue.enumerate() {
            if containsCoalescingOnType {
                if eachPostRequest
                    .isRequestingToPostNotification(notification)
                {
                    removedIndicesInASAPQueue.append(index)
                }
            }
            if containsCoalescingOnPoster {
                if eachPostRequest
                    .isRequestedByPosterOfNotification(notification)
                {
                    removedIndicesInASAPQueue.append(index)
                }
            }
        }
        
        for (index, eachPostRequest) in idleQueue.enumerate() {
            if containsCoalescingOnType {
                if eachPostRequest
                    .isRequestingToPostNotification(notification)
                {
                    removedIndicesInIdleQueue.append(index)
                }
            }
            if containsCoalescingOnPoster {
                if eachPostRequest
                    .isRequestedByPosterOfNotification(notification)
                {
                    removedIndicesInIdleQueue.append(index)
                }
            }
        }
        
        ASAPQueue.removeIndices(removedIndicesInASAPQueue)
        idleQueue.removeIndices(removedIndicesInIdleQueue)
    }
    
    private init(_ notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
        self.runLoopObserver = CFRunLoopObserverCreateWithHandler(
            kCFAllocatorDefault,
            CFRunLoopActivity.AllActivities.rawValue,
            true,
            0) { (observer, activity) -> Void in
                let rawRunloopMode =
                    CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent())
                let runLoopMode =
                    NSRunLoopMode(rawValue: rawRunloopMode as String)
                
                if activity.contains(.BeforeWaiting) {
                    self.postNotificationsInQueue(&self.idleQueue,
                        mode: runLoopMode)
                }
                if activity.contains(.Exit) {
                    self.postNotificationsInQueue(&self.ASAPQueue, 
                        mode: runLoopMode)
                }
        }
        CFRunLoopAddObserver(CFRunLoopGetCurrent(),
            runLoopObserver,
            kCFRunLoopCommonModes)
    }
    
    deinit {
        CFRunLoopRemoveObserver(CFRunLoopGetCurrent(),
            runLoopObserver,
            kCFRunLoopCommonModes)
    }
}

//MARK: - Notification Subscription Type
private protocol NotificationSubscriptionType: class {
    var subscriber: NotificationSubscriberType { get }
    var queue: NotificationQueue { get }
    
    func subscribedNotification
        (notification: PrimitiveNotificationType)
        -> Bool
}

//MARK: - Notification Subscription
private class NotificationSubscription<N: NotificationType>:
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
    
    func subscribedNotification
        (notification: PrimitiveNotificationType)
        -> Bool
    {
        return notification is Notification
    }
}

private func ==<N: PrimitiveNotificationType>
    (lhs: NotificationSubscription<N>,
    rhs: NotificationSubscription<N>)
    -> Bool
{
    return lhs.queue === rhs.queue &&
        lhs.subscriber === rhs.subscriber
}

//MARK: - Notification Center Manageable Type
public protocol PrimitiveNotificationType {
    
}

extension PrimitiveNotificationType {
    public var notificationName: String { return "\(self.dynamicType)" }
    
    private func isMatchingPosterOfNotification
        <N: NotificationType>
        (notification: N)
        -> Bool
    {
        switch self {
        case let aConcreteNotificationType as N:
            return aConcreteNotificationType.poster === notification.poster
        default: return false
        }
    }
}

//MARK: - Notification Type
public protocol NotificationType: PrimitiveNotificationType {
    typealias PosterType: NotificationPosterType
    var poster: PosterType {get}
}

//MARK: - Notification Subscriber Type
public protocol NotificationSubscriberType: class {
    func subscribeNotificationOfType
        <N: NotificationType>
        (notificationType: N.Type,
        onQueue queue: NotificationQueue)
    
    func handleNotification(notification: PrimitiveNotificationType)
}

extension NotificationSubscriberType {
    public func subscribeNotificationOfType
        <N: NotificationType>
        (notificationType: N.Type,
        onQueue queue: NotificationQueue = NotificationQueue.current)
    {
        NotificationCenter.shared.subscriber(self,
            subscribeNotificationOfType: notificationType,
            onQueue: queue)
    }
}

//MARK: - Notification Poster Type
public protocol NotificationPosterType: class {
    
}

extension NotificationPosterType {
    public func postNotification
        <N: NotificationType where N.PosterType == Self>
        (notification: N)
    {
        NotificationCenter.shared.postNotification(notification)
    }
}
