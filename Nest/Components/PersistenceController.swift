//
//  PersistenceController.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation
import CoreData
import SwiftExt

@available(iOS 3.0, *)
open class PersistenceController {
    
    public enum Context {
        case forFetching(NSManagedObjectContext)
        case forSaving(NSManagedObjectContext)
    }
    
    public typealias ManagedObjectChanges
        = [NSManagedObjectChangeKey: Set<NSManagedObject>]
    
    public enum State {
        case notPrepared, preparing, ready, failed
    }
    
    // Managed object context used for fetching and update. Not fully
    // initialized simultaneously with the object
    private let _fetchingContext: NSManagedObjectContext
    
    // Managed object context used for saving. Corresponds to the
    // persistent store. Not fully initialized simultaneously with the
    // object.
    private let _savingContext: NSManagedObjectContext
    
    public private(set) var saving: Bool = false
    
    private var _state: State = .notPrepared
    
    private var _preparationQueue: DispatchQueue = DispatchQueue(
        label: "com.WeZZard.Nest.PersistenceController.PreparationQueue"
    )
    
    public init(
        bundle: Bundle,
        storeURL: URL,
        type: NSPersistentStoreType,
        modelName: String,
        modelExtension: String = "momd"
        )
    {
        _state = .preparing
        
        _fetchingContext = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType
        )
        
        _savingContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType
        )
        
        _fetchingContext.parent = _savingContext
        
        #if DEBUG
            if #available(
                iOSApplicationExtension 10.0,
                OSXApplicationExtension 10.12,
                *
                )
            {
                _fetchingContext.shouldDeleteInaccessibleFaults = false
                _savingContext.shouldDeleteInaccessibleFaults = false
            }
        #endif
        
        _preparationQueue.async {
            guard let modelURL = bundle.url(
                forResource: modelName, withExtension:modelExtension
                ) else
            {
                self._state = .failed
                fatalError("Error loading model from bundle: \(bundle)")
            }
            
            guard let managedObjectModel = NSManagedObjectModel(
                contentsOf: modelURL
                ) else
            {
                self._state = .failed
                fatalError("Error initializing model from: \(modelURL)")
            }
            
            let persistenStoreCoordinator = NSPersistentStoreCoordinator(
                managedObjectModel: managedObjectModel
            )
            
            do {
                let containingDir = storeURL.deletingLastPathComponent()
                
                try FileManager.default.createDirectory(
                    at: containingDir,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                
                try persistenStoreCoordinator.addPersistentStore(
                    ofType: type.primitiveValue,
                    configurationName: nil,
                    at: storeURL,
                    options: [
                        NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true,
                        NSSQLitePragmasOption: ["journal_mode":"DELETE"]
                    ]
                )
            } catch {
                self._state = .failed
                fatalError("Error migrating store: \(error)")
            }
            
            self._savingContext.persistentStoreCoordinator
                = persistenStoreCoordinator
            
            self._state = .ready
        }
    
        NotificationCenter.default.addObserver(
            self,
            selector:
            #selector(_handleFetchingContextObjects(didChange:)),
            name: .NSManagedObjectContextObjectsDidChange,
            object: _fetchingContext
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_handleFetchingContext(willSave:)),
            name: .NSManagedObjectContextWillSave,
            object: _fetchingContext
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_handleFetchingContext(didSave:)),
            name: .NSManagedObjectContextDidSave,
            object: _fetchingContext
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_handleSavingContextObjects(didChange:)),
            name: .NSManagedObjectContextObjectsDidChange,
            object: _savingContext
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_handleSavingContext(willSave:)),
            name: .NSManagedObjectContextWillSave,
            object: _savingContext
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_handleSavingContext(didSave:)),
            name: .NSManagedObjectContextDidSave,
            object: _savingContext
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextObjectsDidChange,
            object: _fetchingContext
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextWillSave,
            object: _fetchingContext
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextDidSave,
            object: _fetchingContext
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextObjectsDidChange,
            object: _savingContext
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextWillSave,
            object: _savingContext
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextDidSave,
            object: _savingContext
        )
    }
    
    public func save(
        with completionHandler: ((_ error: Error?) -> Void)? = nil
        )
    {
        var errorOrNil: Error?
        
        performAndWait { (fetchingContext) -> Void in
            self.saving = true
            
            if fetchingContext.hasChanges {
                do {
                    try fetchingContext.save()
                } catch let error {
                    errorOrNil = error
                }
            }
            
            if errorOrNil != nil {
                completionHandler?(errorOrNil)
            } else {
                self._savingContext.perform { _ in
                    if self._savingContext.hasChanges {
                        do {
                            try self._savingContext.save()
                            self.saving = false
                            
                            completionHandler?(nil)
                        } catch let error {
                            self.saving = false
                            errorOrNil = error
                            completionHandler?(errorOrNil)
                        }
                    } else {
                        self.saving = false
                        completionHandler?(nil)
                    }
                }
            }
        }
    }
    
    public typealias Transaction =
        (_ context: NSManagedObjectContext) -> Void
    
    public func perform(_ transaction: @escaping Transaction) {
        switch _state {
        case .ready:
            let context = _fetchingContext
            _fetchingContext.perform {
                transaction(context)
            }
        case .notPrepared:
            _preparationQueue.async {
                self.perform(transaction)
            }
        case .preparing:
            _preparationQueue.async {
                self.perform(transaction)
            }
        case .failed:
            assertionFailure("Persistence controller initialization failed")
        }
    }
    
    public func performAndWait(_ transaction: @escaping Transaction) {
        switch _state {
        case .ready:
            let context = _fetchingContext
            _fetchingContext.performAndWait {
                transaction(context)
            }
        case .notPrepared:
            while _state == .preparing || _state == .notPrepared {}
            performAndWait(transaction)
        case .preparing:
            while _state == .preparing {}
            performAndWait(transaction)
        case .failed:
            assertionFailure("Persistence controller initialization failed")
        }
    }
    
    fileprivate func _launch() { /* Do nothing here */ }
    
    @objc(_handleFetchingContextDidChange:)
    private func _handleFetchingContextObjects(didChange: Notification) {
        let sender = (didChange.object as? NSManagedObjectContext)
        assert(sender === _fetchingContext)
        context(
            .forFetching(_fetchingContext),
            objectsDidChange: didChange._extractManagedObjectChanges()
        )
    }
    
    @objc(_handleFetchingContextWillSave:)
    private func _handleFetchingContext(willSave: Notification) {
        let sender = (willSave.object as? NSManagedObjectContext)
        assert(sender === _fetchingContext)
        context(
            .forFetching(_fetchingContext),
            willSave: willSave._extractManagedObjectChanges()
        )
    }
    
    @objc(_handleFetchingContextDidSave:)
    private func _handleFetchingContext(didSave: Notification) {
        let sender = (didSave.object as? NSManagedObjectContext)
        assert(sender === _fetchingContext)
        context(
            .forFetching(_fetchingContext),
            didSave: didSave._extractManagedObjectChanges()
        )
    }
    
    @objc(_handleSavingContextDidChange:)
    private func _handleSavingContextObjects(didChange: Notification) {
        let sender = (didChange.object as? NSManagedObjectContext)
        assert(sender === _savingContext)
        context(
            .forSaving(_savingContext),
            objectsDidChange: didChange._extractManagedObjectChanges()
        )
    }
    
    @objc(_handleSavingContextWillSave:)
    private func _handleSavingContext(willSave: Notification) {
        let sender = (willSave.object as? NSManagedObjectContext)
        assert(sender === _savingContext)
        context(
            .forSaving(_savingContext),
            willSave: willSave._extractManagedObjectChanges()
        )
    }
    
    @objc(_handleSavingContextDidSave:)
    private func _handleSavingContext(didSave: Notification) {
        let sender = (didSave.object as? NSManagedObjectContext)
        assert(sender === _savingContext)
        context(
            .forSaving(_savingContext),
            didSave: didSave._extractManagedObjectChanges()
        )
    }
    
    open func context(
        _ context: Context,
        objectsDidChange changes: ManagedObjectChanges
        )
    {
        
    }
    
    open func context(
        _ context: Context,
        willSave changes: ManagedObjectChanges
        )
    {
        
    }
    
    open func context(
        _ context: Context,
        didSave changes: ManagedObjectChanges
        )
    {
        
    }
}

extension Notification {
    fileprivate typealias ManagedObjectChanges
        = PersistenceController.ManagedObjectChanges
    fileprivate typealias ManagedObjectChangeKey
        = NSManagedObjectChangeKey
    
    fileprivate func _extractManagedObjectChanges()
        -> ManagedObjectChanges
    {
        assert(name == .NSManagedObjectContextDidSave
            || name == .NSManagedObjectContextWillSave
            || name == .NSManagedObjectContextObjectsDidChange
        )
        
        var changes = ManagedObjectChanges()
        
        for (k, v) in userInfo ?? [:] {
            guard let managedObjects = v as? Set<NSManagedObject> else {
                continue
            }
            
            let changeKey = NSManagedObjectChangeKey(
                rawValue: k.base as! String
            )
            changes[changeKey] = managedObjects
        }
        
        return changes
    }
}

public protocol SingletonPersistenceControllerType: class {
    static var shared: Self { get }
}

extension SingletonPersistenceControllerType where
    Self: PersistenceController
{
    public static func launch() { shared._launch() }
    
    public static func save(
        with comletionHandler: ((_ error: Error?) -> Void)? = nil
        )
    {
        shared.save(with: comletionHandler)
    }
    
    public static func perform(_ transaction: @escaping Transaction) {
        shared.perform(transaction)
    }
    
    public static func performAndWait(
        _ transaction: @escaping Transaction
        )
    {
        shared.performAndWait(transaction)
    }
}
