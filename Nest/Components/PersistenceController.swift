//
//  PersistenceController.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import Foundation
import CoreData

@available(iOS 3.0, *)
open class PersistenceController {
    public enum State {
        case notPrepared, preparing, ready, failed
    }
    
    // Managed object context used for fetching and update. Not fully
    // initialized simultaneously with the object
    private let fetchingContext: NSManagedObjectContext
    
    // Managed object context used for saving. Corresponds to the
    // persistent store. Not fully initialized simultaneously with the
    // object.
    private let savingContext: NSManagedObjectContext
    
    public private(set) var saving: Bool = false
    
    private var state: State = .notPrepared
    
    private var preparationQueue: DispatchQueue = DispatchQueue(
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
        state = .preparing
        
        fetchingContext = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType
        )
        
        savingContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType
        )
        
        fetchingContext.parent = savingContext
        
        preparationQueue.async {
            guard let modelURL = bundle.url(
                forResource: modelName, withExtension:modelExtension
                ) else
            {
                self.state = .failed
                fatalError("Error loading model from bundle: \(bundle)")
            }
            
            guard let managedObjectModel = NSManagedObjectModel(
                contentsOf: modelURL
                ) else
            {
                self.state = .failed
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
                self.state = .failed
                fatalError("Error migrating store: \(error)")
            }
            
            self.savingContext.persistentStoreCoordinator
                = persistenStoreCoordinator
            
            self.state = .ready
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(
                _handleFetchingContextObjectDidChange(_:)
            ),
            name: .NSManagedObjectContextObjectsDidChange,
            object: fetchingContext
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_handleSavingContextWillSave(_:)),
            name: .NSManagedObjectContextWillSave,
            object: fetchingContext
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_handleSavingContextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: fetchingContext
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextObjectsDidChange,
            object: fetchingContext
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextWillSave,
            object: fetchingContext
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextDidSave,
            object: fetchingContext
        )
    }
    
    public func save(
        with comletionHandler: ((_ success: Bool) -> Void)? = nil
        )
    {
        guard fetchingContext.hasChanges || savingContext.hasChanges
            else
        {
            comletionHandler?(true)
            return
        }
        
        performAndWait { (fetchingContext) -> Void in
            self.saving = true
            
            do {
                try fetchingContext.save()
            } catch let error {
                fatalError("\(error)")
            }
            
            self.savingContext.perform { _ in
                do {
                    try self.savingContext.save()
                    self.saving = false
                    
                    comletionHandler?(true)
                } catch let error {
                    self.saving = false
                    
                    comletionHandler?(false)
                    assertionFailure("\(error)")
                }
            }
        }
    }
    
    public typealias Transaction =
        (_ context: NSManagedObjectContext) -> Void
    
    public func perform(_ transaction: Transaction) {
        switch state {
        case .ready:
            let context = fetchingContext
            fetchingContext.perform {
                transaction(context)
            }
        case .notPrepared:
            preparationQueue.async {
                self.perform(transaction)
            }
        case .preparing:
            preparationQueue.async {
                self.perform(transaction)
            }
        case .failed:
            assertionFailure("Persistence controller initialization failed")
        }
    }
    
    public func performAndWait(_ transaction: Transaction) {
        switch state {
        case .ready:
            let context = fetchingContext
            fetchingContext.performAndWait {
                transaction(context)
            }
        case .notPrepared:
            while state == .preparing || state == .notPrepared {}
            performAndWait(transaction)
        case .preparing:
            while state == .preparing {}
            performAndWait(transaction)
        case .failed:
            assertionFailure("Persistence controller initialization failed")
        }
    }
    
    fileprivate func launch() { /* Do nothing here */ }
    
    @objc
    private func _handleFetchingContextObjectDidChange(
        _ notification: Notification
        )
    {
        assert((notification.object as? NSManagedObjectContext) === fetchingContext)
        objectsDidChange(notification: notification)
    }
    
    @objc
    private func _handleSavingContextWillSave(
        _ notification: Notification
        )
    {
        assert((notification.object as? NSManagedObjectContext) === fetchingContext)
        willSave(notification: notification)
    }
    
    @objc
    private func _handleSavingContextDidSave(
        _ notification: Notification
        )
    {
        assert((notification.object as? NSManagedObjectContext) === fetchingContext)
        didSave(notification: notification)
    }
    
    open func objectsDidChange(notification: Notification) {
        
    }
    
    open func willSave(notification: Notification) {
        
    }
    
    open func didSave(notification: Notification) {
        
    }
}

public protocol SingletonPersistenceControllerType: class {
    static var shared: Self { get }
}

extension SingletonPersistenceControllerType where
    Self: PersistenceController
{
    public static func launch() { shared.launch() }
    
    public static func save(
        with comletionHandler: ((_ success: Bool) -> Void)? = nil
        )
    {
        shared.save(with: comletionHandler)
    }
    
    public static func perform(_ transaction: Transaction) {
        shared.perform(transaction)
    }
    
    public static func performAndWait(_ transaction: Transaction) {
        shared.performAndWait(transaction)
    }
}
