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
    case sqlite
    case binary
    case inMemory
    
    public var primitiveValue: String {
        switch self {
        case .binary:   return NSBinaryStoreType
        case .sqlite:   return NSSQLiteStoreType
        case .inMemory: return NSInMemoryStoreType
        }
    }
}
