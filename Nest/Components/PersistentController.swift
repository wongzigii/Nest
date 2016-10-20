//
//  PersistentController.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation
import CoreData

@available(iOS 3.0, *)
open class PersistentController {
    public init(
        bundle: Bundle,
        storeURL: URL,
        type: NSPersistentStoreType,
        modelName: String,
        modelExtension: String = "momd"
        )
    {
        _fetchingContext = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType
        )
        
        _savingContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType
        )
        
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
        
        guard let modelURL = bundle.url(
            forResource: modelName, withExtension:modelExtension
            ) else
        {
            fatalError("Cannot get managed object model file from bundle: \(bundle)")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(
            contentsOf: modelURL
            ) else
        {
            fatalError("Cannot initialize managed object model from: \(modelURL)")
        }
        
        _managedObjectModel = managedObjectModel
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(
            managedObjectModel: managedObjectModel
        )
        
        _savingContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        _fetchingContext.parent = _savingContext
        
        _operationQueue.async {
            do {
                let containingDir = storeURL.deletingLastPathComponent()
                
                try FileManager.default.createDirectory(
                    at: containingDir,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                
            } catch let error {
                fatalError("Cannot create persistent store's containing directory: \(error)")
            }
            
            do {
                try persistentStoreCoordinator.addPersistentStore(
                    ofType: type.primitiveValue,
                    configurationName: nil,
                    at: storeURL,
                    options: [
                        NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true,
                        NSSQLitePragmasOption: ["journal_mode":"DELETE"]
                    ]
                )
            } catch let error {
                fatalError("Cannot migrate persistent store: \(error)")
            }
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
        
        _operationQueue.sync {
            _fetchingContext.performAndWait {
                if self._fetchingContext.hasChanges {
                    do {
                        try self._fetchingContext.save()
                    } catch let error {
                        errorOrNil = error
                    }
                }
            }
            
            if errorOrNil != nil {
                completionHandler?(errorOrNil)
            } else {
                _savingContext.perform { _ in
                    if self._savingContext.hasChanges {
                        do {
                            try self._savingContext.save()
                            
                            completionHandler?(nil)
                        } catch let error {
                            errorOrNil = error
                            completionHandler?(errorOrNil)
                        }
                    } else {
                        completionHandler?(nil)
                    }
                }
            }
        }
    }
    
    public func perform(
        _ transaction: @escaping (NSManagedObjectContext) -> Void
        )
    {
        let context = _fetchingContext
        _operationQueue.async {
            context.perform {
                transaction(context)
            }
        }
    }
    
    public func performAndWait<R>(
        _ transaction: @escaping (NSManagedObjectContext) -> R
        ) -> R
    {
        var returnValue: R!
        _operationQueue.sync {
            _fetchingContext.performAndWait {
                returnValue = transaction(self._fetchingContext)
            }
        }
        return returnValue
        
    }
    
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
    
    public func fetchRequestFromTemplate(
        named name: String, substitutionVariables: [String: Any]
        ) -> NSFetchRequest<NSFetchRequestResult>?
    {
        return _managedObjectModel.fetchRequestFromTemplate(
            withName: name, substitutionVariables: substitutionVariables
        )
    }
    
    // MARK: Stored Properties
    
    // Managed object context used for fetching and update. Not fully
    // initialized simultaneously with the object.
    private let _fetchingContext: NSManagedObjectContext
    
    // Managed object context used for saving. Corresponds to the
    // persistent store. Not fully initialized simultaneously with the
    // object.
    private let _savingContext: NSManagedObjectContext
    
    /// All operations happen in this serial queue.
    ///
    /// - Notes: Dispatching all operations in one queue could simply make them
    /// synchronized.
    private var _operationQueue: DispatchQueue = DispatchQueue(
        label: "com.WeZZard.Nest.PersistentController.OperationQueue"
    )
    
    private unowned let _managedObjectModel: NSManagedObjectModel
    
    // MARK: Nested Type
    public enum Context {
        case forFetching(NSManagedObjectContext)
        case forSaving(NSManagedObjectContext)
    }
    
    public typealias ManagedObjectChanges
        = [NSManagedObjectChangeKey: Set<NSManagedObject>]
}

extension Notification {
    fileprivate typealias ManagedObjectChanges
        = PersistentController.ManagedObjectChanges
    fileprivate typealias ManagedObjectChangeKey
        = NSManagedObjectChangeKey
    
    fileprivate func _extractManagedObjectChanges() -> ManagedObjectChanges {
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

public protocol SingletonPersistentController: class {
    static var shared: Self { get }
}

extension SingletonPersistentController where
    Self: PersistentController
{
    public static func launch() { _ = shared }
    
    public static func save(
        with comletionHandler: ((_ error: Error?) -> Void)? = nil
        )
    {
        shared.save(with: comletionHandler)
    }
    
    public static func perform(
        _ transaction: @escaping (NSManagedObjectContext) -> Void
        )
    {
        shared.perform(transaction)
    }
    
    public static func performAndWait<R>(
        _ transaction: @escaping (NSManagedObjectContext) -> R
        ) -> R
    {
        return shared.performAndWait(transaction)
    }
    
    public static func fetchRequestFromTemplate(
        named name: String, substitutionVariables: [String: Any]
        ) -> NSFetchRequest<NSFetchRequestResult>?
    {
        return shared.fetchRequestFromTemplate(
            named: name, substitutionVariables: substitutionVariables
        )
    }
}

