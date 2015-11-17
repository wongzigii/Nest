//
//  NSRunLoop+TaskDispatcher.swift
//  Nest
//
//  Created by Manfred on 10/22/15.
//
//

import Foundation
import ObjectiveC
import SwiftExt

private var dispatchObserverKey =
"com.WeZZard.Nest.NSRunLoop.TaskDispatcher.DispatchObserver"

private var taskQueueKey =
"com.WeZZard.Nest.NSRunLoop.TaskDispatcher.TaskQueue"

private var taskAmendQueueKey =
"com.WeZZard.Nest.NSRunLoop.TaskDispatcher.TaskAmendQueue"

private typealias DeallocFunctionPointer =
    @convention(c) (Unmanaged<NSRunLoop>, Selector) -> Void

private var original_dealloc_imp: IMP?

private let swizzled_dealloc_imp: DeallocFunctionPointer = {
    (aSelf: Unmanaged<NSRunLoop>,
    aSelector: Selector)
    -> Void in
    
    let unretainedSelf = aSelf.takeUnretainedValue()
    
    if unretainedSelf.isDispatchObserverLoaded {
        let observer = unretainedSelf.dispatchObserver
        CFRunLoopObserverInvalidate(observer)
    }
    
    if let original_dealloc_imp = original_dealloc_imp {
        let originalDealloc = unsafeBitCast(original_dealloc_imp,
            DeallocFunctionPointer.self)
        originalDealloc(aSelf, aSelector)
    } else {
        fatalError("The original implementation of dealloc for NSRunLoop cannot be found!")
    }
}

public enum NSRunLoopTaskInvokeTiming: Int {
    case NextLoopBegan
    case CurrentLoopEnded
    case Idle
}

extension NSRunLoop {
    
    public func perform(closure: ()->Void) -> Task {
        objc_sync_enter(self)
        loadDispatchObserverIfNeeded()
        let task = Task(self, closure)
        taskQueue.append(task)
        objc_sync_exit(self)
        return task
    }
    
    public override class func initialize() {
        super.initialize()
        
        struct Static {
            static var token: dispatch_once_t = 0
        }
        // make sure this isn't a subclass
        if self !== NSRunLoop.self {
            return
        }
        
        dispatch_once(&Static.token) {
            let selectorDealloc: Selector = "dealloc"
            original_dealloc_imp =
                class_getMethodImplementation(self, selectorDealloc)
            
            let swizzled_dealloc = unsafeBitCast(swizzled_dealloc_imp, IMP.self)
            
            class_replaceMethod(self, selectorDealloc, swizzled_dealloc, "@:")
        }
    }
    
    public final class Task {
        private let weakRunLoop: Weak<NSRunLoop>
        
        private var _invokeTiming: NSRunLoopTaskInvokeTiming
        private var invokeTiming: NSRunLoopTaskInvokeTiming {
            var theInvokeTiming: NSRunLoopTaskInvokeTiming = .NextLoopBegan
            guard let amendQueue = weakRunLoop.value?.taskAmendQueue else {
                fatalError("Accessing a dealloced run loop")
            }
            dispatch_sync(amendQueue) { () -> Void in
                theInvokeTiming = self._invokeTiming
            }
            return theInvokeTiming
        }
        
        private var _modes: NSRunLoopMode
        private var modes: NSRunLoopMode {
            var theModes: NSRunLoopMode = []
            guard let amendQueue = weakRunLoop.value?.taskAmendQueue else {
                fatalError("Accessing a dealloced run loop")
            }
            dispatch_sync(amendQueue) { () -> Void in
                theModes = self._modes
            }
            return theModes
        }
        
        private let closure: () -> Void
        
        private init(_ runLoop: NSRunLoop, _ aClosure: () -> Void) {
            weakRunLoop = Weak<NSRunLoop>(runLoop)
            _invokeTiming = .NextLoopBegan
            _modes = .defaultMode
            closure = aClosure
        }
        
        public func forModes(modes: NSRunLoopMode) -> Task {
            if let amendQueue = weakRunLoop.value?.taskAmendQueue {
                dispatch_async(amendQueue) { [weak self] () -> Void in
                    self?._modes = modes
                }
            }
            return self
        }
        
        public func when(invokeTiming: NSRunLoopTaskInvokeTiming) -> Task {
            if let amendQueue = weakRunLoop.value?.taskAmendQueue {
                dispatch_async(amendQueue) { [weak self] () -> Void in
                    self?._invokeTiming = invokeTiming
                }
            }
            return self
        }
    }
    
    private var isDispatchObserverLoaded: Bool {
        return objc_getAssociatedObject(self, &dispatchObserverKey) !== nil
    }
    
    private func loadDispatchObserverIfNeeded() {
        if !isDispatchObserverLoaded {
            let invokeTimings: [NSRunLoopTaskInvokeTiming] =
            [.CurrentLoopEnded, .NextLoopBegan, .Idle]
            
            let activities =
            CFRunLoopActivity(invokeTimings.map{ CFRunLoopActivity($0) })
            
            let observer = CFRunLoopObserverCreateWithHandler(
                kCFAllocatorDefault,
                activities.rawValue,
                true, 0,
                handleRunLoopActivityWithObserver)
            
            let modes = kCFRunLoopCommonModes
            
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, modes)
            
            let wrappedObserver = ObjCAssociated<CFRunLoopObserver>(observer)
            
            objc_setAssociatedObject(self,
                &dispatchObserverKey,
                wrappedObserver,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var dispatchObserver: CFRunLoopObserver {
        loadDispatchObserverIfNeeded()
        return (objc_getAssociatedObject(self, &dispatchObserverKey)
            as! ObjCAssociated<CFRunLoopObserver>)
            .value
    }
    
    private var taskQueue: [Task] {
        get {
            if let taskQueue = objc_getAssociatedObject(self,
                &taskQueueKey)
                as? [Task]
            {
                return taskQueue
            } else {
                let initialValue = [Task]()
                
                objc_setAssociatedObject(self,
                    &taskQueueKey,
                    initialValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return initialValue
            }
        }
        set {
            objc_setAssociatedObject(self,
                &taskQueueKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
    }
    
    private var taskAmendQueue: dispatch_queue_t {
        if let taskQueue = objc_getAssociatedObject(self,
            &taskAmendQueueKey)
            as? dispatch_queue_t
        {
            return taskQueue
        } else {
            let initialValue =
            dispatch_queue_create(
                "com.WeZZard.Nest.NSRunLoop.TaskDispatcher.TaskAmendQueue",
                DISPATCH_QUEUE_SERIAL)
            
            objc_setAssociatedObject(self,
                &taskAmendQueueKey,
                initialValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return initialValue
        }
    }
    
    private func handleRunLoopActivityWithObserver(observer: CFRunLoopObserver!,
        activity: CFRunLoopActivity)
        -> Void
    {
        var removedIndices = [Int]()
        
        let runLoopMode: NSRunLoopMode = currentRunLoopMode
        
        for (index, eachTask) in taskQueue.enumerate() {
            let expectedRunLoopModes = eachTask.modes
            let expectedRunLoopActivitiy =
            CFRunLoopActivity(eachTask.invokeTiming)
            
            let runLoopModesMatches = expectedRunLoopModes.contains(runLoopMode)
                || expectedRunLoopModes.contains(.commonModes)
            
            let runLoopActivityMatches =
            activity.contains(expectedRunLoopActivitiy)
            
            if runLoopModesMatches && runLoopActivityMatches {
                eachTask.closure()
                removedIndices.append(index)
            }
        }
        
        taskQueue.removeIndicesInPlace(removedIndices)
    }
}

extension CFRunLoopActivity {
    private init(_ invokeTiming: NSRunLoopTaskInvokeTiming) {
        switch invokeTiming {
        case .NextLoopBegan:        self = .AfterWaiting
        case .CurrentLoopEnded:     self = .BeforeWaiting
        case .Idle:                 self = .Exit
        }
    }
}
