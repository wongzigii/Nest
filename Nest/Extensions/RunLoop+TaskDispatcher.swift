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
        ) where Modes.Iterator.Element == RunLoopMode
    {
        let task = _Task(timing: timing, closure: closure)
        
        // Use Set to ensure uniqueness, which avoiding redundant retaining.
        for mode in Set(modes) {
            if _schedulers[mode] == nil {
                let scheduler = _Scheduler(runLoop: self, mode: mode)
                let unmanagedScheduler = Unmanaged.passUnretained(scheduler)
                _schedulers[mode] = unmanagedScheduler
            }
            _schedulers[mode]!.takeUnretainedValue().schedule(task)
        }
    }
    
    // MARK: Utilities
    private typealias Schedulers = [RunLoopMode : Unmanaged<_Scheduler>]
    
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
    
    // MARK: Nested Types
    public enum Timing: Int {
        case nextLoopBegan
        case currentLoopEnded
        case idle
        
        fileprivate static let _all: [Timing] =
            [.currentLoopEnded, .nextLoopBegan, .idle]
    }
    
    private class _Task {
        fileprivate let timing: Timing
        
        fileprivate let main: () -> Void
        
        fileprivate var isExecuted: Bool
        
        fileprivate init(timing: Timing, closure: @escaping () -> Void) {
            self.timing = timing
            main = closure
            isExecuted = false
        }
    }
    
    private class _Scheduler {
        private unowned let _runLoop: RunLoop
        private var _tasks: [_Task] = []
        private let _mode: RunLoopMode
        
        private var _context: CFRunLoopObserverContext!
        private var _observer: CFRunLoopObserver!
        
        private var _retainedSelf: _Scheduler?
        
        fileprivate init(runLoop: RunLoop, mode: RunLoopMode) {
            _runLoop = runLoop
            _mode = mode
            
            _context = CFRunLoopObserverContext(
                version: 0,
                info: Unmanaged.passUnretained(self).toOpaque(),
                retain: nil,
                release: nil,
                copyDescription: nil
            )
            
            let requiredActivities = CFRunLoopActivity(
                Timing._all.map({CFRunLoopActivity(runLoopTiming: $0)})
            )
            
            _observer = CFRunLoopObserverCreate(
                kCFAllocatorDefault,
                requiredActivities.rawValue,
                true,
                0,
                _Scheduler._handleRunLoopActivity,
                withUnsafeMutablePointer(to: &_context!, {$0})
            )
            
            CFRunLoopAddObserver(
                runLoop.getCFRunLoop(),
                _observer,
                CFRunLoopMode(runLoopMode: mode)
            )
            
            _retainedSelf = self
        }
        
        deinit {
            CFRunLoopRemoveObserver(
                _runLoop.getCFRunLoop(),
                _observer,
                CFRunLoopMode(runLoopMode: _mode)
            )
            _runLoop._schedulers[_mode] = nil
        }
        
        fileprivate func schedule(_ task: _Task) {
            _tasks.append(task)
        }
        
        private func _runTasks(activity: CFRunLoopActivity) {
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
                }
            }
            
            _tasks.remove(indices: removedIndices)
            
            if _tasks.count == 0 {
                _retainedSelf = nil
            }
        }
        
        private static let _handleRunLoopActivity: CFRunLoopObserverCallBack = {
            (observer, activity, info) -> Void in
            
            let unmanagedScheduler: Unmanaged<RunLoop._Scheduler> =
                .fromOpaque(UnsafeRawPointer(info)!)
            
            let scheduler = unmanagedScheduler.takeUnretainedValue()
            
            scheduler._runTasks(activity: activity)
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
