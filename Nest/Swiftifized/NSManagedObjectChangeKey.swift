//
//  NSManagedObjectChangeKey.swift
//  Nest
//
//  Created by Manfred on 8/24/16.
//
//

import CoreData

public enum NSManagedObjectChangeKey: Hashable {
    case inserted
    case deleted
    case updated
    case refreshed
    case invalidated
    case managedObjectContextQueryGeneration
    case invalidatedAllObjects
    case unkown(String)
    
    public var rawValue: String {
        switch self {
        case .inserted: return NSInsertedObjectsKey
        case .deleted: return NSDeletedObjectsKey
        case .updated: return NSUpdatedObjectsKey
        case .refreshed: return NSRefreshedObjectsKey
        case .invalidated: return NSInvalidatedObjectsKey
        case .managedObjectContextQueryGeneration:
            if #available(
                iOSApplicationExtension 10.0,
                OSXApplicationExtension 10.12,
                *
                )
            {
                return NSManagedObjectContextQueryGenerationKey
            } else {
                fatalError("OS version lower than the minimum available version for using .managedObjectContextQueryGeneration.")
            }
        case .invalidatedAllObjects: return NSInvalidatedAllObjectsKey
        case let .unkown(rawKey):
            return rawKey
        }
    }
    
    internal init(rawValue: String) {
        if #available(
            iOSApplicationExtension 10.0,
            OSXApplicationExtension 10.12,
            *
            )
        {
            switch (rawValue) {
            case NSInsertedObjectsKey: self = .inserted
            case NSDeletedObjectsKey: self = .deleted
            case NSUpdatedObjectsKey: self = .updated
            case NSRefreshedObjectsKey: self = .refreshed
            case NSInvalidatedObjectsKey: self = .invalidated
            case NSManagedObjectContextQueryGenerationKey:
                self = .managedObjectContextQueryGeneration
            default: self = .unkown(rawValue)
            }
        } else {
            switch (rawValue) {
            case NSInsertedObjectsKey: self = .inserted
            case NSDeletedObjectsKey: self = .deleted
            case NSUpdatedObjectsKey: self = .updated
            case NSRefreshedObjectsKey: self = .refreshed
            case NSInvalidatedObjectsKey: self = .invalidated
            default: self = .unkown(rawValue)
            }
        }
    }
    
    public var hashValue: Int {
        switch self {
        case .inserted: return 0
        case .deleted: return 1
        case .updated: return 2
        case .refreshed: return 3
        case .invalidated: return 4
        case .managedObjectContextQueryGeneration: return 5
        case .invalidatedAllObjects: return 6
        case let .unkown(str): return str.hashValue
        }
    }
}

public func == (
    lhs: NSManagedObjectChangeKey,
    rhs: NSManagedObjectChangeKey
    ) -> Bool
{
    switch (lhs, rhs) {
    case (.inserted, .inserted): return true
    case (.deleted, .deleted): return true
    case (.updated, .updated): return true
    case (.refreshed, .refreshed): return true
    case (.invalidated, .invalidated): return true
    case (.invalidatedAllObjects, .invalidatedAllObjects): return true
    case (.managedObjectContextQueryGeneration,
          .managedObjectContextQueryGeneration):
        return true
    case let (.unkown(lhsRawKey), .unkown(rhsRawKey)):
        return lhsRawKey == rhsRawKey
    default: return false
    }
}
