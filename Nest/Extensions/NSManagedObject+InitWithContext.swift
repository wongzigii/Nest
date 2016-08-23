//
//  NSManagedObject+InitWithContext.swift
//  Nest
//
//  Created by Manfred on 8/21/16.
//
//

import CoreData

extension NSManagedObject {
    /// Offers the fallback entity name for init(managedObjectContext:)
    /// when work on iOS prior to 10.0, tvOS prior to 10.0, watchOS prior 
    /// to 3.0 and macOS prior to 10.12.
    @available(iOSApplicationExtension, introduced: 8.0, obsoleted: 10.0)
    @available(tvOSApplicationExtension, introduced: 9.0, obsoleted: 10.0)
    @available(watchOSApplicationExtension, introduced: 2.0, obsoleted: 3.0)
    @available(OSXApplicationExtension, introduced: 10.10, obsoleted: 10.12)
    public static var nest_entityName: String {
        return String(describing: self)
    }
    
    /// Initialize with an `NSManagedObjectContext`.
    ///
    /// - Notes: Before iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.12, 
    /// there is not built-in way to get `NSManagedObject`'s entity name. 
    /// So this initializer counts on your `NSManagedObject` subclass' 
    /// entity name being the same to its class name when it works on OSes 
    /// prior to those versions mentioned above. However, if your 
    /// `NSManagedObject` subclass' entity name is not the same to its 
    /// class name, there is a fallback - overriding `nest_entityName` and
    /// return your actual entity name in this function.
    public convenience init(
        managedObjectContext: NSManagedObjectContext
        )
    {
        if #available(
            iOSApplicationExtension 10.0,
            tvOSApplicationExtension 10.0,
            watchOSApplicationExtension 3.0,
            OSXApplicationExtension 10.12,
            *
            )
        {
            self.init(context: managedObjectContext)
        } else {
            let entityName = type(of: self).nest_entityName
            let entity = NSEntityDescription.entity(
                forEntityName: entityName,
                in: managedObjectContext
                )!
            self.init(
                entity: entity, insertInto: managedObjectContext
            )
        }
    }
}
