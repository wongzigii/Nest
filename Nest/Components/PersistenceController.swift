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
public class PersistenceController {
    
    public enum State: Int {
        case NotPrepared, Preparing, Ready, Failed
    }
    
    // Managed object context used for fetching and update
    private let fetchingContext: NSManagedObjectContext
    
    // Managed object context used for saving
    private let savingContext: NSManagedObjectContext
    
    private var hasPendingSavingRequest: Bool = false
    private var pendingSavingCompletions: [(Bool) -> Void] = []
    public private(set) var saving: Bool = false
    
    private var state: State = .NotPrepared
    
    private var preparationQueue: dispatch_queue_t =
    dispatch_queue_create(
        "com.WeZZard.Nest.PersistenceController.PreparationQueue",
        DISPATCH_QUEUE_SERIAL)
    
    public init(storeURL: NSURL,
        type: NSPersistentStoreType,
        modelName: String,
        modelExtension: String = "momd")
    {
        state = .Preparing
        
        fetchingContext = NSManagedObjectContext(
            concurrencyType: .MainQueueConcurrencyType)
        
        savingContext = NSManagedObjectContext(
            concurrencyType: .PrivateQueueConcurrencyType)
        
        fetchingContext.parentContext = savingContext
        
        dispatch_async(preparationQueue) { () -> Void in
            guard let modelURL = NSBundle.mainBundle()
                .URLForResource(modelName, withExtension:modelExtension) else
            {
                self.state = .Failed
                fatalError("Error loading model from bundle")
            }
            
            guard let managedObjectModel
                = NSManagedObjectModel(contentsOfURL: modelURL) else
            {
                self.state = .Failed
                fatalError("Error initializing model from: \(modelURL)")
            }
            
            let persistenStoreCoordinator = NSPersistentStoreCoordinator(
                managedObjectModel: managedObjectModel)
            
            do {
                guard let containingDir = storeURL
                    .URLByDeletingLastPathComponent else
                {
                    fatalError("Cannot get containing directory")
                }
                
                try NSFileManager.defaultManager()
                    .createDirectoryAtURL(containingDir,
                        withIntermediateDirectories: true,
                        attributes: nil)
                
                try persistenStoreCoordinator
                    .addPersistentStoreWithType(type.primitiveValue,
                        configuration: nil,
                        URL: storeURL,
                        options: nil)
            } catch {
                self.state = .Failed
                fatalError("Error migrating store: \(error)")
            }
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "handleManagedObjectContextDidSaveNotification:",
                name: NSManagedObjectContextDidSaveNotification,
                object: self.savingContext)
            
            self.savingContext.persistentStoreCoordinator
                = persistenStoreCoordinator
            
            self.state = .Ready
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: NSManagedObjectContextDidSaveNotification,
            object: savingContext)
    }
    
    private func saveWithCompletionHandler(
        comletionHandler: ((success: Bool) -> Void)?)
    {
        perform { (managedObjectContext) -> Void in
            switch self.saving {
            case true:
                self.hasPendingSavingRequest = true
            case false:
                self.saving = true
                
                self.savingContext.performBlock { _ in
                    
                    do {
                        try self.savingContext.save()
                        
                    } catch let error {
                        comletionHandler?(success: false)
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
        (context: NSManagedObjectContext) -> Void
    
    public func perform(transaction: DatabaseTransaction) {
        switch state {
        case .Ready:
            let context = fetchingContext
            fetchingContext.performBlock({ () -> Void in
                transaction(context: context)
            })
        case .NotPrepared:
            dispatch_async(preparationQueue, { () -> Void in ()
                self.perform(transaction)
            })
        case .Preparing:
            dispatch_async(preparationQueue, { () -> Void in ()
                self.perform(transaction)
            })
        case .Failed:
            assertionFailure("Persistence controller initialization failed")
        }
    }
    
    public func performAndWait(transaction: DatabaseTransaction) {
        switch state {
        case .Ready:
            let context = fetchingContext
            fetchingContext.performBlockAndWait({ () -> Void in
                transaction(context: context)
            })
        case .NotPrepared:
            while state == .Preparing || state == .NotPrepared {}
            performAndWait(transaction)
        case .Preparing:
            while state == .Preparing {}
            performAndWait(transaction)
        case .Failed:
            assertionFailure("Persistence controller initialization failed")
        }
    }
    
    private func launch() { /* Do nothing here */ }
    
    dynamic private func handleManagedObjectContextDidSaveNotification(
        notification: NSNotification)
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

extension SingletonPersistenceControllerType where Self: PersistenceController {
    public static func launch() { shared.launch() }
    
    public static func save() {
        shared.saveWithCompletionHandler(nil)
    }
    
    public static func saveWithCompletionHandler(
        comletionHandler: ((success: Bool) -> Void)?)
    {
        shared.saveWithCompletionHandler(comletionHandler)
    }
    
    public static func perform(transaction: DatabaseTransaction) {
        shared.perform(transaction)
    }
    
    public static func performAndWait(transaction: DatabaseTransaction) {
        shared.performAndWait(transaction)
    }
}