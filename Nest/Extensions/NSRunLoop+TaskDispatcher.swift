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

extension NSRunLoop {
    public func perform(closure: ()->Void) -> Task {
        objc_sync_enter(self)
        loadDispatchObserverIfNeeded()
        let task = Task(self, closure)
        taskQueue.append(task)
        objc_sync_exit(self)
        return task
    }
    
    @objc private class func _ObjCSelfAwareSwizzle_dealloc()
        -> ObjCSelfAwareSwizzleContext
    {
        class SwizzleRecipe {
            typealias FunctionPointer =
                @convention(c) (Unmanaged<NSRunLoop>, Selector) -> Void
            static var original: FunctionPointer!
            static let swizzled: FunctionPointer =  {
                (aSelf, aSelector) -> Void in
                
                let unretainedSelf = aSelf.takeUnretainedValue()
                
                if unretainedSelf.isDispatchObserverLoaded {
                    let observer = unretainedSelf.dispatchObserver
                    CFRunLoopObserverInvalidate(observer)
                }
                
                SwizzleRecipe.original(aSelf, aSelector)
            }
        }
        
        return withObjCSelfAwareSwizzleContext(
            forInstanceMethodSelector: "dealloc",
            onClass: self,
            original: &SwizzleRecipe.original,
            swizzled: SwizzleRecipe.swizzled)
    }
    
    public final class Task {
        public enum InvokeTiming: Int {
            case NextLoopBegan
            case CurrentLoopEnded
            case Idle
        }
    
        
        private let weakRunLoop: Weak<NSRunLoop>
        
        private var _invokeTiming: InvokeTiming
        private var invokeTiming: InvokeTiming {
            var theInvokeTiming: InvokeTiming = .NextLoopBegan
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
        
        public func when(invokeTiming: InvokeTiming) -> Task {
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
            let invokeTimings: [Task.InvokeTiming] =
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
    private init(_ invokeTiming: NSRunLoop.Task.InvokeTiming) {
        switch invokeTiming {
        case .NextLoopBegan:        self = .AfterWaiting
        case .CurrentLoopEnded:     self = .BeforeWaiting
        case .Idle:                 self = .Exit
        }
    }
}
