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

/*
This enum shall not be a nested type, or, in Xcode Test, it's symbols would not
be found.
*/
public enum RunLoopTaskInvokeTiming: Int {
    case nextLoopBegan
    case currentLoopEnded
    case idle
}

private struct DeallocSwizzleRecipe: ObjCSelfAwareSwizzleRecipeType {
    fileprivate typealias FunctionPointer =
        @convention(c) (Unmanaged<RunLoop>, Selector) -> Void
    fileprivate static var original: FunctionPointer!
    fileprivate static let swizzled: FunctionPointer =  {
        (aSelf, aSelector) -> Void in
        
        let unretainedSelf = aSelf.takeUnretainedValue()
        
        if unretainedSelf.isDispatchObserverLoaded {
            let observer = unretainedSelf.dispatchObserver
            CFRunLoopObserverInvalidate(observer)
        }
        
        DeallocSwizzleRecipe.original(aSelf, aSelector)
    }
}

extension RunLoop {
    @discardableResult
    public func perform(_ closure: @escaping ()->Void) -> Task {
        objc_sync_enter(self)
        loadDispatchObserverIfNeeded()
        let task = Task(self, closure)
        taskQueue.append(task)
        objc_sync_exit(self)
        return task
    }
    
    @objc private class func _ObjCSelfAwareSwizzle_dealloc()
        -> ObjCSelfAwareSwizzle
    {
        return swizzle(
            instanceSelector: NSSelectorFromString("dealloc"),
            on: self,
            recipe: DeallocSwizzleRecipe.self
        )
    }
    
    public final class Task {
        private let weakRunLoop: Weak<RunLoop>
        
        private var _invokeTiming: RunLoopTaskInvokeTiming
        fileprivate var invokeTiming: RunLoopTaskInvokeTiming {
            var theInvokeTiming: RunLoopTaskInvokeTiming = .nextLoopBegan
            guard let amendQueue = weakRunLoop.value?.taskAmendQueue else {
                fatalError("Accessing a dealloced run loop")
            }
            amendQueue.sync { () -> Void in
                theInvokeTiming = self._invokeTiming
            }
            return theInvokeTiming
        }
        
        private var _modes: RunLoopMode
        fileprivate var modes: RunLoopMode {
            var theModes: RunLoopMode!
            guard let amendQueue = weakRunLoop.value?.taskAmendQueue else {
                fatalError("Accessing a dealloced run loop")
            }
            amendQueue.sync { () -> Void in
                theModes = self._modes
            }
            return theModes
        }
        
        fileprivate let closure: () -> Void
        
        fileprivate init(_ runLoop: RunLoop, _ aClosure: @escaping () -> Void) {
            weakRunLoop = Weak<RunLoop>(runLoop)
            _invokeTiming = .nextLoopBegan
            _modes = .defaultRunLoopMode
            closure = aClosure
        }
        
        @discardableResult
        public func forModes(_ modes: RunLoopMode) -> Task {
            if let amendQueue = weakRunLoop.value?.taskAmendQueue {
                amendQueue.async { [weak self] () -> Void in
                    self?._modes = modes
                }
            }
            return self
        }
        
        @discardableResult
        public func when(_ invokeTiming: RunLoopTaskInvokeTiming) -> Task {
            if let amendQueue = weakRunLoop.value?.taskAmendQueue {
                amendQueue.async { [weak self] () -> Void in
                    self?._invokeTiming = invokeTiming
                }
            }
            return self
        }
    }
    
    fileprivate var isDispatchObserverLoaded: Bool {
        return objc_getAssociatedObject(self, &dispatchObserverKey) != nil
    }
    
    private func loadDispatchObserverIfNeeded() {
        if !isDispatchObserverLoaded {
            let invokeTimings: [RunLoopTaskInvokeTiming] =
            [.currentLoopEnded, .nextLoopBegan, .idle]
            let activities = CFRunLoopActivity(
                invokeTimings.map{ CFRunLoopActivity($0) }
            )
            
            let observer = CFRunLoopObserverCreateWithHandler(
                kCFAllocatorDefault,
                activities.rawValue,
                true, 0,
                handleRunLoopActivityWithObserver
            )
            
            let modes = CFRunLoopMode.commonModes
            
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, modes)
            
            let wrappedObserver = ObjCAssociated<CFRunLoopObserver>(
                observer!
            )
            
            objc_setAssociatedObject(self,
                &dispatchObserverKey,
                wrappedObserver,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var dispatchObserver: CFRunLoopObserver {
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
    
    private var taskAmendQueue: DispatchQueue {
        if let taskQueue = objc_getAssociatedObject(self,
            &taskAmendQueueKey)
            as? DispatchQueue
        {
            return taskQueue
        } else {
            let initialValue = DispatchQueue(
                label: "com.WeZZard.Nest.NSRunLoop.TaskDispatcher.TaskAmendQueue"
            )
            
            objc_setAssociatedObject(self,
                &taskAmendQueueKey,
                initialValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return initialValue
        }
    }
    
    private func handleRunLoopActivityWithObserver(
        _ observer: CFRunLoopObserver?,
        activity: CFRunLoopActivity
        )
        -> Void
    {
        var removedIndices = [Int]()
        
        let runLoopMode = currentMode
        
        for (index, eachTask) in taskQueue.enumerated() {
            let expectedRunLoopModes = eachTask.modes
            let expectedActivitiy =
            CFRunLoopActivity(eachTask.invokeTiming)
            
            let inCommon = runLoopMode == .commonModes
            let isCommon = expectedRunLoopModes == .commonModes
            let inExpected = runLoopMode == expectedRunLoopModes
            
            let modeMatches = isCommon || inCommon || inExpected
            
            let activityMatches = activity.contains(expectedActivitiy)
            
            if modeMatches && activityMatches {
                eachTask.closure()
                removedIndices.append(index)
            }
        }
        
        taskQueue.remove(indices: removedIndices)
    }
}

extension CFRunLoopActivity {
    fileprivate init(_ invokeTiming: RunLoopTaskInvokeTiming) {
        switch invokeTiming {
        case .nextLoopBegan:        self = .afterWaiting
        case .currentLoopEnded:     self = .beforeWaiting
        case .idle:                 self = .exit
        }
    }
}
