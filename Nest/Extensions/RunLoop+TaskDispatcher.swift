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
        when timings: Timings = .nextLoopBegan,
        do closure: @escaping ()->Void
        )
    {
        schedule(in: [mode], when: timings, do: closure)
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
        when timings: Timings = .nextLoopBegan,
        do closure: @escaping ()->Void
        )
    {
        schedule(in: modes, when: timings, do: closure)
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
        when timings: Timings = .nextLoopBegan,
        do closure: @escaping ()->Void
        ) where Modes.Iterator.Element == RunLoopMode
    {
        let task = _Task(timings: timings, closure: closure)
        
        // Use Set to ensure uniqueness, which avoiding redundant retaining.
        for mode in Set(modes) {
            if let scheduler = _schedulers[mode] {
                scheduler.schedule(task)
            } else {
                let scheduler = _Scheduler(runLoop: self, mode: mode)
                _schedulers[mode] = scheduler
                scheduler.schedule(task)
                
            }
        }
    }
    
    // MARK: Utilities
    private typealias Schedulers = [RunLoopMode : _Scheduler]
    
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
    public struct Timings: OptionSet, CustomStringConvertible,
        CustomDebugStringConvertible
    {
        public typealias RawValue = UInt
        public var rawValue: RawValue
        public init(rawValue: RawValue) { self.rawValue = rawValue }
        
        public static let nextLoopBegan = Timings(rawValue: 1 << 0)
        public static let idle = Timings(rawValue: 1 << 1)
        public static let currentLoopEnded = Timings(rawValue: 1 << 2)
        
        public static let oncePossible: Timings = all
        
        public static let all: Timings =
            [.currentLoopEnded, .nextLoopBegan, .idle]
        
        public var description: String {
            var descriptions = [String]()
            if contains(.nextLoopBegan) {
                descriptions.append("Next Loop Began")
            }
            if contains(.idle) {
                descriptions.append("Idle")
            }
            if contains(.currentLoopEnded) {
                descriptions.append("Current Loop Ended")
            }
            return descriptions.joined(separator: ", ")
        }
        
        public var debugDescription: String {
            return "<\(type(of: self)); \(description)>"
        }
    }
    
    private class _Task {
        fileprivate init(timings: Timings, closure: @escaping () -> Void) {
            expectedActivities = CFRunLoopActivity(runLoopTimings: timings)
            isExecuted = false
            _closure = closure
        }
        
        fileprivate func execute() {
            _closure()
            isExecuted = true
        }
        
        fileprivate let expectedActivities: CFRunLoopActivity
        
        fileprivate private(set) var isExecuted: Bool
        
        private let _closure: () -> Void
    }
    
    private class _Scheduler {
        private unowned let _runLoop: RunLoop
        private var _tasks: [_Task] = []
        private let _mode: RunLoopMode
        
        private var _context: CFRunLoopObserverContext!
        private var _observer: CFRunLoopObserver!
        
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
            
            let requiredActivities = CFRunLoopActivity(runLoopTimings: .all)
            
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
        }
        
        fileprivate func schedule(_ task: _Task) {
            _tasks.append(task)
        }
        
        fileprivate func invalidate() {
            CFRunLoopObserverInvalidate(_observer)
        }
        
        private func _runTasks(activity: CFRunLoopActivity) {
            var removedIndices = [Int]()
            
            for (index, task) in _tasks.enumerated() {
                if !task.isExecuted {
                    if !task.expectedActivities.isDisjoint(with: activity) {
                        task.execute()
                    }
                }
                
                if task.isExecuted {
                    removedIndices.append(index)
                }
            }
            
            _tasks.remove(indices: removedIndices)
        }
        
        private static let _handleRunLoopActivity: CFRunLoopObserverCallBack = {
            (observer, activity, info) -> Void in
            
            let unmanagedScheduler: Unmanaged<RunLoop._Scheduler> =
                .fromOpaque(UnsafeRawPointer(info)!)
            
            let scheduler = unmanagedScheduler.takeUnretainedValue()
            
            scheduler._runTasks(activity: activity)
        }
    }
    
    private struct _DeallocSwizzleRecipe: ObjCSelfAwareSwizzleRecipe {
        fileprivate typealias FunctionPointer =
            @convention(c) (Unmanaged<RunLoop>, Selector) -> Void
        fileprivate static var original: FunctionPointer!
        fileprivate static let swizzled: FunctionPointer =  {
            (aSelf, aSelector) -> Void in
            
            let unretainedSelf = aSelf.takeUnretainedValue()
            
            for (_, scheduler) in unretainedSelf._schedulers {
                scheduler.invalidate()
            }
            
            original(aSelf, aSelector)
        }
    }
    
    // MARK: Method Swizzling
    @objc
    private class func _ObjCSelfAwareSwizzle_dealloc() -> ObjCSelfAwareSwizzle {
        return swizzle(
            instanceSelector: NSSelectorFromString("dealloc"),
            on: self,
            recipe: _DeallocSwizzleRecipe.self
        )
    }
}

extension CFRunLoopActivity {
    fileprivate init(runLoopTimings: RunLoop.Timings) {
        self = []
        if runLoopTimings.contains(.nextLoopBegan) {
            insert(.beforeTimers)
        }
        if runLoopTimings.contains(.idle) {
            insert(.beforeWaiting)
        }
        if runLoopTimings.contains(.currentLoopEnded) {
            insert(.afterWaiting)
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
