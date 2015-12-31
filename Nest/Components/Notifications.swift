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
/**
`NotificationCenter` is a strong typed, type value supported notification 
system.

- Discussion: And it works almost the same to `NSNotificationCenter` in
Foundation. But doesn't like `NSNotificationCenter`, it maintains a `weak`
relationship between itself and the notification subscriber. That means there is
no need to unsubscribe as necessary as possible.
*/
public class NotificationCenter {
    /// Get the shared notification center.
    /// - Discussion: There is only one notification center exist in your app.
    public static let shared = NotificationCenter()
    
    private var instanceInterfaceSpinLock: OSSpinLock = 0
    
    private init() {}
    
    private var subscriptions: [NotificationSubscriptionType] = []
    
    /** 
    Subscribe a notification.
    
    - Parameter     subscriber:         The subscriber itself
    
    - Parameter     notificationType:   Type of the notification to subscribe
    
    - Parameter     queue:              Specifies posting notification queue
    */
    public func addSubscriber<N: NotificationType>
        (subscriber: NotificationSubscriberType,
        notificationType: N.Type,
        onQueue queue: NotificationQueue = NotificationQueue.current)
    {
        while OSSpinLockTry(&instanceInterfaceSpinLock) {}
        
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
        
        OSSpinLockUnlock(&instanceInterfaceSpinLock)
    }
    
    public func removeSubscriber<N: NotificationType>
        (subscriber: NotificationSubscriberType,
        notificationType: N.Type)
    {
        while OSSpinLockTry(&instanceInterfaceSpinLock) {}
        var unnecessarySubscriptionIndices = [Int]()
        for (index, eachSubscription) in subscriptions.enumerate()
        {
            if eachSubscription.subscriber === subscriber {
                if eachSubscription.subscribedNotificationType(notificationType)
                {
                    unnecessarySubscriptionIndices.append(index)
                }
            }
        }
        subscriptions.removeIndicesInPlace(unnecessarySubscriptionIndices)
        OSSpinLockUnlock(&instanceInterfaceSpinLock)
    }
    
    public func removeSubscriber(subscriber: NotificationSubscriberType) {
        while OSSpinLockTry(&instanceInterfaceSpinLock) {}
        var unnecessarySubscriptionIndices = [Int]()
        for (index, eachSubscription) in subscriptions.enumerate()
        {
            if eachSubscription.subscriber === subscriber {
                unnecessarySubscriptionIndices.append(index)
            }
        }
        subscriptions.removeIndicesInPlace(unnecessarySubscriptionIndices)
        OSSpinLockUnlock(&instanceInterfaceSpinLock)
    }
    
    /** 
    Post a notification immediately on the specified notification queue
    
    - Parameter     notification:       The notification to post
    
    - Parameter     queue:              The posting notification queue
    
    - Discussion: If a subscriber subscribed the notification to post but 
    specified to receive notification on another queue, it will not be notified.
    */
    public func postNotification(notification: PrimitiveNotificationType,
        onQueue queue: NotificationQueue = NotificationQueue.current)
    {
        while OSSpinLockTry(&instanceInterfaceSpinLock) {}
        var unnecessarySubscriptionIndices = [Int]()
        for (index, eachSubscription) in subscriptions.enumerate()
        {
            if eachSubscription.subscribedNotification(notification) {
                guard let subscriber = eachSubscription.subscriber,
                    subscribedQueue = eachSubscription.queue else
                {
                    unnecessarySubscriptionIndices.append(index)
                    continue
                }
                
                if subscribedQueue === queue {
                    subscriber.handleNotification(notification)
                }
            } else {
                continue
            }
        }
        subscriptions.removeIndicesInPlace(unnecessarySubscriptionIndices)
        OSSpinLockUnlock(&instanceInterfaceSpinLock)
    }
}

private protocol NotificationPostRequestType {
    var coalescing: NotificationQueue.Coalescing { get }
    var modes: NSRunLoopMode { get }
    
    var poster: NotificationPosterType? { get }
    var primitiveNotification: PrimitiveNotificationType { get }
}

extension NotificationPostRequestType {
    func isRequestedToPostNotification<N: NotificationType>(notification: N)
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
            return notificationPostRequest.notification.notificationPoster
                === notification.notificationPoster
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
    
    var poster: NotificationPosterType?
        { return notification.notificationPoster.value }
    var primitiveNotification: PrimitiveNotificationType { return notification }
    
    init(notification: Notification,
        coalescing: NotificationQueue.Coalescing,
        modes: NSRunLoopMode)
    {
        self.notification = notification
        self.coalescing = coalescing
        self.modes = modes
    }
}

//MARK: - Notification Queue
/**
NotificationQueue objects act as buffers for notification centers (instances of
NotificationCenter). Whereas a notification center distributes notifications
when posted, notifications placed into the queue can be delayed until the end of
the current pass through the run loop or until the run loop is idle. Duplicate
notifications can also be coalesced so that only one notification is sent 
although multiple notifications are posted. A notification queue maintains
notifications (instances conforms to NotificationType) generally in a first in
first out (FIFO) order. When a notification rises to the front of the queue, 
the queue posts it to the notification center, which in turn dispatches the
notification to all subscribed subscribers.
*/
public class NotificationQueue {
    private static var queues: [Weak<NSThread>: NotificationQueue] = [:]
    
    private let notificationCenter: NotificationCenter
    
    private var runLoopObserver: CFRunLoopObserverRef!
    
    private var ASAPQueue = [NotificationPostRequestType]()
    private var idleQueue = [NotificationPostRequestType]()
    
    private static var classInterfaceSpinLock: OSSpinLock = 0
    private var instanceInterfaceSpinLock: OSSpinLock = 0
    
    /// These constants specify when notifications are posted.
    public enum PostTiming: Int {
        /// The notification is posted when the run loop is idle.
        case WhenIdle
        /// The notification is posted at the end of the current notification 
        /// callout or timer.
        case ASAP
        /// The notification is posted immediately after coalescing.
        case Now
    }
    
    /// This option set specifies how notifications are coalesced.
    public struct Coalescing: OptionSetType {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        
        /// Coalesce notifications with the same type.
        public static let OnType    = Coalescing(rawValue: 1 << 0)
        /// Coalesce notifications with the same poster.
        public static let OnPoster  = Coalescing(rawValue: 1 << 1)
    }
    
    /// Returns the default notification queue for the current thread.
    public class var current: NotificationQueue {
        while OSSpinLockTry(&classInterfaceSpinLock) {}
        defer { OSSpinLockUnlock(&classInterfaceSpinLock) }
        
        let currentThread = NSThread.currentThread()
        let weakCurrentThread = Weak<NSThread>(currentThread)
        
        if let currentQueue: NotificationQueue = {
            for (weakEachThread, eachQueue) in queues {
                if let eachThread = weakEachThread.value {
                    if eachThread === currentThread {
                        return eachQueue
                    }
                } else {
                    queues[weakEachThread] = nil
                }
            }
            return nil
            }()
        {
            return currentQueue
        } else {
            let newQueue = NotificationQueue(NotificationCenter.shared)
            queues[weakCurrentThread] = newQueue
            return newQueue
        }
    }
    
    /// Adds a notification to the notification queue with a specified post 
    /// timing, criteria for coalescing, and runloop mode.
    public func enqueueNotification
        <N: NotificationType>
        (notification: N,
        timing: PostTiming, 
        coalesce: Coalescing = [],
        forModes modes: NSRunLoopMode = .defaultMode)
    {
        while OSSpinLockTry(&instanceInterfaceSpinLock) {}
        switch timing {
        case .Now:
            let currentRunLoopMode =
            NSRunLoop.currentRunLoop().currentRunLoopMode
            if !modes.intersect(currentRunLoopMode).isEmpty || modes == [] {
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
        OSSpinLockUnlock(&instanceInterfaceSpinLock)
    }
    
    private func postNotificationsInQueue(
        inout queue: [NotificationPostRequestType],
        mode: NSRunLoopMode)
    {
        var coalescedPostRequest = [NotificationPostRequestType]()
        
        var unprocessedPostRequests = [NotificationPostRequestType]()
        
        // Coalescing
        // Reverse the qeuue to ensure posting the newest notification
        for postRequest in queue.reverse() {
            if postRequest.modes.contains(mode) || postRequest.modes == [] {
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
            NotificationCenter.shared.postNotification(
                postRequest.primitiveNotification,
                onQueue: self)
        }
    }
    
    /// Removes all notifications from the queue that match a provided 
    /// notification using provided matching criteria.
    public func dequeueNotificationsMatching
        <N: NotificationType>
        (notification: N,
        coalesce: Coalescing = [])
    {
        while OSSpinLockTry(&instanceInterfaceSpinLock) {}
        defer { OSSpinLockUnlock(&instanceInterfaceSpinLock) }
        
        var removedIndicesInASAPQueue = [Int]()
        var removedIndicesInIdleQueue = [Int]()
        
        let containsCoalescingOnType    = coalesce.contains(.OnType)
        let containsCoalescingOnPoster  = coalesce.contains(.OnPoster)
        
        guard containsCoalescingOnType || containsCoalescingOnPoster
            else { return }
        
        for (index, eachPostRequest) in ASAPQueue.enumerate() {
            if containsCoalescingOnType {
                if eachPostRequest
                    .isRequestedToPostNotification(notification)
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
                    .isRequestedToPostNotification(notification)
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
        
        ASAPQueue.removeIndicesInPlace(removedIndicesInASAPQueue)
        idleQueue.removeIndicesInPlace(removedIndicesInIdleQueue)
    }
    
    private init(_ notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
        let observedActivities: CFRunLoopActivity = [.AfterWaiting, .Exit]
        self.runLoopObserver = CFRunLoopObserverCreateWithHandler(
            kCFAllocatorDefault,
            observedActivities.rawValue,
            true,
            0,
            handleRunLoopObserver)
        
        CFRunLoopAddObserver(CFRunLoopGetCurrent(),
            runLoopObserver,
            kCFRunLoopCommonModes)
    }
    
    private func handleRunLoopObserver(observer: CFRunLoopObserver!,
        activity: CFRunLoopActivity)
    {
        print("\(activity.debugDescription)")
        let rawRunloopMode =
        CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent())
        let runLoopMode =
        NSRunLoopMode(rawValue: rawRunloopMode as String)
        
        if activity.contains(.AfterWaiting) {
            postNotificationsInQueue(&ASAPQueue, mode: runLoopMode)
        }
        if activity.contains(.Exit) {
            postNotificationsInQueue(&idleQueue, mode: runLoopMode)
        }
    }
    
    deinit {
        CFRunLoopRemoveObserver(CFRunLoopGetCurrent(),
            runLoopObserver,
            kCFRunLoopCommonModes)
    }
}

//MARK: - Notification Subscription Type
private protocol NotificationSubscriptionType: class {
    var subscriber: NotificationSubscriberType? { get }
    var queue: NotificationQueue? { get }
    
    func subscribedNotification
        (notification: PrimitiveNotificationType)
        -> Bool
    
    func subscribedNotificationType<N: NotificationType>
        (notificationType: N.Type)
        -> Bool
}

//MARK: - Notification Subscription
private class NotificationSubscription<N: NotificationType>:
    NotificationSubscriptionType, Equatable
{
    typealias Notification = N
    
    weak var subscriber: NotificationSubscriberType?
    
    weak var queue: NotificationQueue?
    
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
    
    func subscribedNotificationType<S : NotificationType>
        (notificationType: S.Type)
        -> Bool
    {
        return Notification.self == S.self
    }
}

private func ==<N: PrimitiveNotificationType>
    (lhs: NotificationSubscription<N>,
    rhs: NotificationSubscription<N>)
    -> Bool
{
    return lhs.queue === rhs.queue && lhs.subscriber === rhs.subscriber
}

//MARK: - Notification Center Manageable Type
/**
PrimitiveNotificationType
*/
public protocol PrimitiveNotificationType {
    
}

extension PrimitiveNotificationType {
    /// Returns the notification name
    public var notificationName: String { return "\(self.dynamicType)" }
}

//MARK: - Notification Type
/**
All the notification should conforms to `NotificationType`
*/
public protocol NotificationType: PrimitiveNotificationType {
    typealias NotificationPoster: NotificationPosterType
    var notificationPoster: Weak<NotificationPoster> {get}
}

//MARK: - Notification Subscriber Type
/**
All the notification subscribers should conforms to `NotificationSubscriberType`
*/
public protocol NotificationSubscriberType: class {
    /// Handle notifications in this function
    func handleNotification(notification: PrimitiveNotificationType)
}

extension NotificationSubscriberType {
    /// Convenience to subscribe notifications of specific type on specified
    /// type
    public func subscribeNotificationOfType
        <N: NotificationType>
        (notificationType: N.Type,
        onQueue queue: NotificationQueue = NotificationQueue.current)
    {
        NotificationCenter.shared.addSubscriber(self,
            notificationType: notificationType,
            onQueue: queue)
    }
    
    public func unsubscribeNotificationOfType
        <N: NotificationType>
        (notificationType: N.Type)
    {
        NotificationCenter.shared.removeSubscriber(self,
            notificationType: notificationType)
    }
    
    public func unsubscribeNotifications() {
        NotificationCenter.shared.removeSubscriber(self)
    }
}

//MARK: - Notification Poster Type
/**
All the notification posters should conforms to `NotificationPosterType`
*/
public protocol NotificationPosterType: class {
    
}

extension NotificationPosterType {
    /// Convenience to post a notification
    public func postNotification
        <N: NotificationType where N.NotificationPoster == Self>
        (notification: N)
    {
        NotificationCenter.shared.postNotification(notification)
    }
}
