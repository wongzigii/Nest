//
//  NSManagedObject+Transient.swift
//  Nest
//
//  Created by Manfred on 07/11/2016.
//
//

import CoreData

/// `Transient` represents a fault for CoreData transient property.
public enum Transient<Wrapped> {
    case fulfilled(Wrapped)
    case fault
    
    public var isFault: Bool {
        if case .fault = self {
            return true
        }
        return false
    }
    
    public var isTransient: Bool {
        if case .fulfilled = self {
            return true
        }
        return false
    }
    
    public func map<R>(_ closure: (Wrapped) throws -> R) rethrows -> R? {
        switch self {
        case let .fulfilled(element):
            return try closure(element)
        case .fault:
            return nil
        }
    }
    
    public func flatMap<R>(_ closure: (Wrapped) throws -> R?) rethrows
        -> R?
    {
        switch self {
        case let .fulfilled(element):
            return try closure(element)
        case .fault:
            return nil
        }
    }
    
    public func forEach(_ closure: (Wrapped) throws -> Void) rethrows {
        switch self {
        case let .fulfilled(element):
            try closure(element)
        case .fault:
            break
        }
    }
}
