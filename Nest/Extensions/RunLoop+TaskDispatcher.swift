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

private var dispatchObserverKey =
"com.WeZZard.Nest.RunLoop.TaskDispatcher.DispatchObserver"

private var taskQueueKey =
"com.WeZZard.Nest.RunLoop.TaskDispatcher.TaskQueue"

private var taskAmendQueueKey =
"com.WeZZard.Nest.RunLoop.TaskDispatcher.TaskAmendQueue"

private struct DeallocSwizzleRecipe: ObjCSelfAwareSwizzleRecipeType {
    fileprivate typealias FunctionPointer =
        @convention(c) (Unmanaged<RunLoop>, Selector) -> Void
    fileprivate static var original: FunctionPointer!
    fileprivate static let swizzled: FunctionPointer =  {
        (aSelf, aSelector) -> Void in
        
        let unretainedSelf = aSelf.takeUnretainedValue()
        
        if unretainedSelf.isDispatchObserverLoaded {
            let observer = unretainedSelf._dispatchObserver
            CFRunLoopObserverInvalidate(observer)
        }
        
        DeallocSwizzleRecipe.original(aSelf, aSelector)
    }
}

extension RunLoop {
    /*
     This enum shall not be a nested type, or, in Xcode Test, it's symbols would not
     be found.
     */
    public enum ScheduleTiming: Int {
        case nextLoopBegan
        case currentLoopEnded
        case idle
    }
    
    @discardableResult
    public func schedule(
        in mode: RunLoopMode = .defaultRunLoopMode,
        when timing: ScheduleTiming = .nextLoopBegan,
        do closure: @escaping ()->Void
        )
    {
        schedule(in: [mode], when: timing, do: closure)
    }
    
    @discardableResult
    public func schedule(
        in modes: RunLoopMode...,
        when timing: ScheduleTiming = .nextLoopBegan,
        do closure: @escaping ()->Void
        )
    {
        schedule(in: modes, when: timing, do: closure)
    }
    
    @discardableResult
    public func schedule<R: Sequence>(
        in modes: R,
        when timing: ScheduleTiming = .nextLoopBegan,
        do closure: @escaping ()->Void
        ) where
        R.Iterator.Element == RunLoopMode
    {
        objc_sync_enter(self)
        _loadDispatchObserverIfNeeded()
        let task = ScheduledTask(self, Array(modes), timing, closure)
        _taskQueue.append(task)
        objc_sync_exit(self)
    }
    
    @objc
    private class func _ObjCSelfAwareSwizzle_dealloc()
        -> ObjCSelfAwareSwizzle
    {
        return swizzle(
            instanceSelector: NSSelectorFromString("dealloc"),
            on: self,
            recipe: DeallocSwizzleRecipe.self
        )
    }
    
    private struct ScheduledTask {
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
    
    fileprivate var isDispatchObserverLoaded: Bool {
        return objc_getAssociatedObject(self, &dispatchObserverKey) != nil
    }
    
    private func _loadDispatchObserverIfNeeded() {
        if !isDispatchObserverLoaded {
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
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var _dispatchObserver: CFRunLoopObserver {
        _loadDispatchObserverIfNeeded()
        let associatedObserver = objc_getAssociatedObject(
            self, &dispatchObserverKey
            ) as! ObjCAssociated<CFRunLoopObserver>
        return associatedObserver.value
    }
    
    private var _taskQueue: [ScheduledTask] {
        get {
            if let taskQueue = objc_getAssociatedObject(
                self,
                &taskQueueKey
                ) as? [ScheduledTask]
            {
                return taskQueue
            } else {
                let initialValue = [ScheduledTask]()
                
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
            
            let inCommon = runLoopMode == .commonModes
            let isCommon = expectedRunLoopModes.contains(.commonModes)
            let inExpected = runLoopMode.map{
                expectedRunLoopModes.contains($0)
            } ?? false
            
            let inMode = isCommon || inCommon || inExpected
            
            let inActivity = activity.contains(expectedActivitiy)
            
            if inMode && inActivity {
                eachTask.closure()
                removedIndices.append(index)
            }
        }
        
        _taskQueue.remove(indices: removedIndices)
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
