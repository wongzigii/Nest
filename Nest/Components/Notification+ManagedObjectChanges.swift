//
//  Notification+ManagedObjectChanges.swift
//  Nest
//
//  Created by Manfred on 03/11/2016.
//
//

import CoreData

extension Notification {
    internal typealias ManagedObjectChanges
        = PersistentController.ManagedObjectChanges
    internal typealias ManagedObjectChangeKey
        = NSManagedObjectChangeKey
    
    internal func _extractManagedObjectChanges() -> ManagedObjectChanges {
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
