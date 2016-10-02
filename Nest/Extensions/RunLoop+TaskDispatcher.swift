//
//  RunLoop+TaskDispatcher.swift
//  Nest
//
//  Created by Manfred on 10/22/15.
//
//

import Foundation
import ObjectiveC
import SwiftExt

extension RunLoop {
    // MARK: Task Schedulers
    /// Schedule a task on the run-loop in the specified mode at the 
    /// specified time.
    ///
    /// - Parameter mode: The run-loop mode that the run-loop is in which
    /// can excute this task. `.defaultRunLoopMode` by default.
    ///
    /// - Parameter timing: The timing to dispatch the task. 
    /// `.nextLoopBegan` by default.
    ///
    /// - Parameter closure: The task
    public func schedule(
        in mode: RunLoopMode = .defaultRunLoopMode,
        when timing: ScheduleTiming = .nextLoopBegan,
        do closure: @escaping ()->Void
        )
    {
        schedule(in: [mode], when: timing, do: closure)
    }
    
    /// Schedule a task on the run-loop in the specified modes at the
    /// specified time.
    ///
    /// - Parameter mode: The run-loop modes that the run-loop is in which
    /// can excute this task.
    ///
    /// - Parameter timing: The timing to dispatch the task.
    /// `.nextLoopBegan` by default.
    ///
    /// - Parameter closure: The task
    public func schedule(
        in modes: RunLoopMode...,
        when timing: ScheduleTiming = .nextLoopBegan,
        do closure: @escaping ()->Void
        )
    {
        schedule(in: modes, when: timing, do: closure)
    }
    
    /// Schedule a task on the run-loop in the specified modes at the
    /// specified time.
    ///
    /// - Parameter mode: The run-loop modes that the run-loop is in which
    /// can excute this task.
    ///
    /// - Parameter timing: The timing to dispatch the task.
    /// `.nextLoopBegan` by default.
    ///
    /// - Parameter closure: The task
    public func schedule<Modes: Sequence>(
        in modes: Modes,
        when timing: ScheduleTiming = .nextLoopBegan,
        do closure: @escaping ()->Void
        ) where
        Modes.Iterator.Element == RunLoopMode
    {
        objc_sync_enter(self)
        _loadDispatchObserverIfNeeded()
        let task = _Task(self, Array(modes), timing, closure)
        _taskQueue.append(task)
        objc_sync_exit(self)
    }
    
    // MARK: Utilities
    private var _isDispatchObserverLoaded: Bool {
        return objc_getAssociatedObject(self, &dispatchObserverKey) != nil
    }
    
    private func _loadDispatchObserverIfNeeded() {
        if !_isDispatchObserverLoaded {
            let invokeTimings: [ScheduleTiming] = [
                .currentLoopEnded, .nextLoopBegan, .idle
            ]
            let activities = CFRunLoopActivity(
                invokeTimings.map {CFRunLoopActivity($0)}
            )
            
            let observer = CFRunLoopObserverCreateWithHandler(
                kCFAllocatorDefault,
                activities.rawValue,
                true, 0,
                _handleRunLoopActivity
            )
            
            let modes = CFRunLoopMode.commonModes
            
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, modes)
            
            let wrappedObserver = ObjCAssociated<CFRunLoopObserver>(
                observer!
            )
            
            objc_setAssociatedObject(self,
                &dispatchObserverKey,
                wrappedObserver,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    fileprivate var _dispatchObserver: CFRunLoopObserver {
        _loadDispatchObserverIfNeeded()
        let associatedObserver = objc_getAssociatedObject(
            self, &dispatchObserverKey
            ) as! ObjCAssociated<CFRunLoopObserver>
        return associatedObserver.value
    }
    
    private var _taskQueue: [_Task] {
        get {
            if let taskQueue = objc_getAssociatedObject(
                self,
                &taskQueueKey
                ) as? [_Task]
            {
                return taskQueue
            } else {
                let initialValue = [_Task]()
                
                objc_setAssociatedObject(
                    self,
                    &taskQueueKey,
                    initialValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                
                return initialValue
            }
        }
        set {
            objc_setAssociatedObject(self,
                &taskQueueKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    private func _handleRunLoopActivity(
        with observer: CFRunLoopObserver?,
        activity: CFRunLoopActivity
        )
        -> Void
    {
        var removedIndices = [Int]()
        
        let runLoopMode = currentMode
        
        for (index, eachTask) in _taskQueue.enumerated() {
            let expectedRunLoopModes = eachTask.modes
            let expectedActivitiy = CFRunLoopActivity(
                eachTask.timing
            )
            
            let isInCommonModes = runLoopMode == .commonModes
            let isCommonMode = expectedRunLoopModes.contains(.commonModes)
            let isInExpectedMode = runLoopMode.map{
                expectedRunLoopModes.contains($0)
            } ?? false
            
            let isInMode = isCommonMode || isInCommonModes
                || isInExpectedMode
            
            let inActivity = activity.contains(expectedActivitiy)
            
            if isInMode && inActivity {
                eachTask.closure()
                removedIndices.append(index)
            }
        }
        
        _taskQueue.remove(indices: removedIndices)
    }
    
    // MARK: Method Swizzling
    @objc
    private class func _ObjCSelfAwareSwizzle_dealloc()
        -> ObjCSelfAwareSwizzle
    {
        return swizzle(
            instanceSelector: NSSelectorFromString("dealloc"),
            on: self,
            recipe: _DeallocSwizzleRecipe.self
        )
    }
    
    // MARK: Nested Types
    public enum ScheduleTiming: Int {
        case nextLoopBegan
        case currentLoopEnded
        case idle
    }
    
    private struct _Task {
        fileprivate var timing: ScheduleTiming
        
        fileprivate var modes: [RunLoopMode]
        
        fileprivate let closure: () -> Void
        
        fileprivate init(
            _ runLoop: RunLoop,
            _ modes: [RunLoopMode],
            _ timing: ScheduleTiming,
            _ aClosure: @escaping () -> Void
            )
        {
            self.timing = timing
            self.modes = modes
            closure = aClosure
        }
    }
    
    private struct _DeallocSwizzleRecipe: ObjCSelfAwareSwizzleRecipe {
        fileprivate typealias FunctionPointer =
            @convention(c) (Unmanaged<RunLoop>, Selector) -> Void
        fileprivate static var original: FunctionPointer!
        fileprivate static let swizzled: FunctionPointer =  {
            (aSelf, aSelector) -> Void in
            
            let unretainedSelf = aSelf.takeUnretainedValue()
            
            if unretainedSelf._isDispatchObserverLoaded {
                let observer = unretainedSelf._dispatchObserver
                CFRunLoopObserverInvalidate(observer)
            }
            
            original(aSelf, aSelector)
        }
    }
}

extension CFRunLoopActivity {
    fileprivate init(_ invokeTiming: RunLoop.ScheduleTiming) {
        switch invokeTiming {
        case .nextLoopBegan:        self = .afterWaiting
        case .currentLoopEnded:     self = .beforeWaiting
        case .idle:                 self = .exit
        }
    }
}


// MARK: - Constants
private var dispatchObserverKey =
"com.WeZZard.Nest.RunLoop.TaskDispatcher.DispatchObserver"

private var taskQueueKey =
"com.WeZZard.Nest.RunLoop.TaskDispatcher.TaskQueue"
