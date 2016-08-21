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
    
    public enum State: Int {
        case notPrepared, preparing, ready, failed
    }
    
    // Managed object context used for fetching and update
    private let fetchingContext: NSManagedObjectContext
    
    // Managed object context used for saving
    private let savingContext: NSManagedObjectContext
    
    private var hasPendingSavingRequest: Bool = false
    private var pendingSavingCompletions: [(Bool) -> Void] = []
    public private(set) var saving: Bool = false
    
    private var state: State = .notPrepared
    
    private var preparationQueue: DispatchQueue = DispatchQueue(
        label: "com.WeZZard.Nest.PersistenceController.PreparationQueue"
    )
    
    public init(
        storeURL: URL,
        type: NSPersistentStoreType,
        modelName: String,
        modelExtension: String = "momd"
        )
    {
        state = .preparing
        
        fetchingContext = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType)
        
        savingContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType)
        
        fetchingContext.parent = savingContext
        
        preparationQueue.async { () -> Void in
            guard let modelURL = Bundle.main.url(
                forResource: modelName,
                withExtension:modelExtension
                ) else
            {
                self.state = .failed
                fatalError("Error loading model from bundle")
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
                    options: nil
                )
            } catch {
                self.state = .failed
                fatalError("Error migrating store: \(error)")
            }
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(
                    self.handleManagedObjectContextDidSave(_:)
                ),
                name: .NSManagedObjectContextDidSave,
                object: self.savingContext
            )
            
            self.savingContext.persistentStoreCoordinator
                = persistenStoreCoordinator
            
            self.state = .ready
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextDidSave,
            object: savingContext
        )
    }
    
    fileprivate func saveWithCompletionHandler(
        _ comletionHandler: ((_ success: Bool) -> Void)?)
    {
        perform { (managedObjectContext) -> Void in
            switch self.saving {
            case true:
                self.hasPendingSavingRequest = true
            case false:
                self.saving = true
                
                self.savingContext.perform { _ in
                    
                    do {
                        try self.savingContext.save()
                        
                    } catch let error {
                        comletionHandler?(false)
                        fatalError("\(error)")
                    }
                    
                    if let completion = comletionHandler {
                        self.pendingSavingCompletions.append(completion)
                    }
                }
            }
        }
    }
    
    public typealias DatabaseTransaction =
        (_ context: NSManagedObjectContext) -> Void
    
    public func perform(_ transaction: DatabaseTransaction) {
        switch state {
        case .ready:
            let context = fetchingContext
            fetchingContext.perform({ () -> Void in
                transaction(context)
            })
        case .notPrepared:
            preparationQueue.async(execute: { () -> Void in ()
                self.perform(transaction)
            })
        case .preparing:
            preparationQueue.async(execute: { () -> Void in ()
                self.perform(transaction)
            })
        case .failed:
            assertionFailure("Persistence controller initialization failed")
        }
    }
    
    public func performAndWait(_ transaction: DatabaseTransaction) {
        switch state {
        case .ready:
            let context = fetchingContext
            fetchingContext.performAndWait({ () -> Void in
                transaction(context)
            })
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
    
    dynamic
    private func handleManagedObjectContextDidSave(
        _ notification: Notification
        )
    {
        saving = false
        if hasPendingSavingRequest {
            hasPendingSavingRequest = false
            saveWithCompletionHandler(nil)
        } else {
            pendingSavingCompletions.forEach {$0(true)}
        }
    }
}

public protocol SingletonPersistenceControllerType: class {
    static var shared: Self { get }
}

extension SingletonPersistenceControllerType where
    Self: PersistenceController
{
    public static func launch() { shared.launch() }
    
    public static func save() {
        shared.saveWithCompletionHandler(nil)
    }
    
    public static func saveWithCompletionHandler(
        _ comletionHandler: ((_ success: Bool) -> Void)?
        )
    {
        shared.saveWithCompletionHandler(comletionHandler)
    }
    
    public static func perform(_ transaction: DatabaseTransaction) {
        shared.perform(transaction)
    }
    
    public static func performAndWait(_ transaction: DatabaseTransaction) {
        shared.performAndWait(transaction)
    }
}
