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
    /// specified time. This function is not thread safe.
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
        when timing: Timing = .nextLoopBegan,
        do closure: @escaping ()->Void
        )
    {
        schedule(in: [mode], when: timing, do: closure)
    }
    
    /// Schedule a task on the run-loop in the specified modes at the
    /// specified time. This function is not thread safe.
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
        when timing: Timing = .nextLoopBegan,
        do closure: @escaping ()->Void
        )
    {
        schedule(in: modes, when: timing, do: closure)
    }
    
    /// Schedule a task on the run-loop in the specified modes at the
    /// specified time. This function is not thread safe.
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
        when timing: Timing = .nextLoopBegan,
        do closure: @escaping ()->Void
        ) where
        Modes.Iterator.Element == RunLoopMode
    {
        let task = _Task(timing: timing, closure: closure)
        
        for eachMode in modes {
            if _isSchedulerExisted(for: eachMode) {
                _retainScheduler(for: eachMode)
            } else {
                _createScheduler(for: eachMode)
            }
            _schedule(task, for: eachMode)
        }
    }
    
    // MARK: Utilities
    private typealias Schedulers = [RunLoopMode : Unmanaged<_RunLoopScheduler>]
    
    private var _schedulers: Schedulers {
        get {
            if let assocObj = objc_getAssociatedObject(self, &schedulersKey) {
                return (assocObj as! ObjCAssociated<Schedulers>).value
            } else {
                return [:]
            }
        }
        set {
            if let assocObj = objc_getAssociatedObject(self, &schedulersKey) {
                (assocObj as! ObjCAssociated<Schedulers>).value = newValue
            } else {
                objc_setAssociatedObject(
                    self,
                    &schedulersKey,
                    ObjCAssociated(newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    private func _isSchedulerExisted(for mode: RunLoopMode) -> Bool {
        return _schedulers[mode] != nil
    }
    
    private func _createScheduler(for mode: RunLoopMode) {
        assert(_schedulers[mode] == nil)
        let scheduler = _RunLoopScheduler(runLoop: self, mode: mode)
        let unmanagedScheduler = Unmanaged.passRetained(scheduler)
        _schedulers[mode] = unmanagedScheduler
    }
    
    private func _retainScheduler(for mode: RunLoopMode) {
        assert(_schedulers[mode] != nil)
        _ = _schedulers[mode]!.retain()
    }
    
    private func _releaseScheduler(for mode: RunLoopMode) {
        assert(_schedulers[mode] != nil)
        _schedulers[mode]!.release()
    }
    
    private func _schedule(_ task: _Task, for mode: RunLoopMode) {
        assert(_schedulers[mode] != nil)
        _schedulers[mode]!.takeUnretainedValue().schedule(task)
    }
    
    // MARK: Method Swizzling
    
    // MARK: Nested Types
    public enum Timing: Int {
        case nextLoopBegan
        case currentLoopEnded
        case idle
    }
    
    private class _Task {
        fileprivate let timing: Timing
        
        fileprivate let main: () -> Void
        
        fileprivate var isExecuted: Bool = false
        
        fileprivate init(timing: Timing, closure: @escaping () -> Void) {
            self.timing = timing
            main = closure
        }
    }
    
    private class _RunLoopScheduler {
        private unowned let _runLoop: RunLoop
        private let _mode: RunLoopMode
        private var _observer: CFRunLoopObserver!
        private var _tasks: [_Task] = []
        
        fileprivate init(runLoop: RunLoop, mode: RunLoopMode) {
            _runLoop = runLoop
            _mode = mode
            
            let allTimings: [Timing] =
                [.currentLoopEnded, .nextLoopBegan, .idle]
            let neededActivities = CFRunLoopActivity(
                allTimings.map {CFRunLoopActivity(runLoopTiming: $0)}
            )
            _observer = CFRunLoopObserverCreateWithHandler(
                kCFAllocatorDefault,
                neededActivities.rawValue,
                true,
                0,
                _handleRunLoopActivity
            )
            CFRunLoopAddObserver(
                runLoop.getCFRunLoop(),
                _observer,
                CFRunLoopMode(runLoopMode: mode)
            )
        }
        
        deinit {
            CFRunLoopRemoveObserver(
                _runLoop.getCFRunLoop(),
                _observer,
                CFRunLoopMode(runLoopMode: _mode)
            )
        }
        
        fileprivate func schedule(_ task: _Task) {
            _tasks.append(task)
        }
        
        private func _handleRunLoopActivity(
            with observer: CFRunLoopObserver?,
            activity: CFRunLoopActivity
            )
            -> Void
        {
            var removedIndices = [Int]()
            
            for (index, task) in _tasks.enumerated() {
                
                if !task.isExecuted {
                    let taskActivity = CFRunLoopActivity(
                        runLoopTiming: task.timing
                    )
                    
                    let isActive = !activity.intersection(taskActivity).isEmpty
                    
                    if isActive {
                        task.main()
                        task.isExecuted = true
                    }
                }
                
                if task.isExecuted {
                    removedIndices.append(index)
                    _runLoop._releaseScheduler(for: _mode)
                }
            }
            
            _tasks.remove(indices: removedIndices)
        }
    }
}

extension CFRunLoopActivity {
    fileprivate init(runLoopTiming: RunLoop.Timing) {
        switch runLoopTiming {
        case .nextLoopBegan:        self = .afterWaiting
        case .currentLoopEnded:     self = .beforeWaiting
        case .idle:                 self = .exit
        }
    }
}

extension CFRunLoopMode {
    fileprivate init(runLoopMode: RunLoopMode) {
        self.rawValue = runLoopMode.rawValue as CFString
    }
}

// MARK: - Constants
private var schedulersKey =
"com.WeZZard.Nest.RunLoop.TaskDispatcher._schedulers"
