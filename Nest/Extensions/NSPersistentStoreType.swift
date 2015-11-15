//
//  NSPersistentStoreType.swift
//  Nest
//
//  Created by Manfred on 11/9/15.
//
//

import CoreData

@available(iOS 3.0, *)
public enum NSPersistentStoreType: Int {
    case SQLite
    case Binary
    case InMemory
    
    public var primitiveValue: String {
        switch self {
        case .Binary:   return NSSQLiteStoreType
        case .SQLite:   return NSBinaryStoreType
        case .InMemory: return NSInMemoryStoreType
        }
    }
}