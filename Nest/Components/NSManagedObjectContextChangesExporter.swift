//
//  NSManagedObjectContextChangesExporter.swift
//  Review
//
//  Created by Manfred on 03/11/2016.
//
//

import CoreData

@available(
iOSApplicationExtension 9.0,
OSXApplicationExtension 10.11,
tvOS 9.0,
watchOS 2.0,
*)
public protocol NSManagedObjectContextChangesExporterDelegate: class {
    func persistentUserDefault(
        for managedObjectContextChangesExporter:
        NSManagedObjectContextChangesExporter
    ) -> UserDefaults
    
    func managedObjectContextChangesExporter(
        _ sender: NSManagedObjectContextChangesExporter,
        exportIdentifierFor persistentUserDefault: UserDefaults
    ) -> String
}

@available(
iOSApplicationExtension 9.0,
OSXApplicationExtension 10.11,
tvOS 9.0,
watchOS 2.0,
*)
public class NSManagedObjectContextChangesExporter: NSObject {
    public init(
        context: NSManagedObjectContext
        )
    {
        _context = context
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_handle(managedObjectContextDidSave:)),
            name: .NSManagedObjectContextDidSave,
            object: context
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextDidSave,
            object: _context
        )
    }
    
    @objc(_handleManagedObjectContextDidSave:)
    private func _handle(managedObjectContextDidSave: Notification) {
        
        guard let userDefaults = delegate?.persistentUserDefault(for: self)
            else
        {
            #if DEBUG
                NSLog("\(self): No delegate set.")
            #endif
            return
        }
        
        guard let key = delegate?.managedObjectContextChangesExporter(
            self,
            exportIdentifierFor: userDefaults
            )
            else
        {
            #if DEBUG
                NSLog("\(self): No delegate set.")
            #endif
            return
        }
        
        var newChanges = [AnyHashable : [URL]]()
        
        let changes = managedObjectContextDidSave._extractManagedObjectChanges()
        
        for (k, v) in changes {
            let uris = v.map {$0.objectID.uriRepresentation()}
            newChanges[k.rawValue] = uris
        }
        
        let oldChanges = userDefaults.object(forKey: key)
            .flatMap { $0  as? Data }
            .map {NSKeyedUnarchiver.unarchiveObject(with: $0)}
            .flatMap { $0 as? [[AnyHashable : [URL]]] }
        
        let oldNewChanges = (oldChanges ?? []).appending(newChanges)
        
        let archivedData = NSKeyedArchiver.archivedData(
            withRootObject: oldNewChanges
        )
        
        userDefaults.set(archivedData, forKey: key)
        
        userDefaults.synchronize()
    }
    
    public weak var delegate: NSManagedObjectContextChangesExporterDelegate?
    
    private let _context: NSManagedObjectContext
}

extension NSManagedObjectContext {
    @available(
    iOSApplicationExtension 9.0,
    OSXApplicationExtension 10.11,
    tvOS 9.0, 
    watchOS 2.0,
    *)
    public var changesExporter: NSManagedObjectContextChangesExporter? {
        get {
            return objc_getAssociatedObject(self, &changesExporterKey)
                as! NSManagedObjectContextChangesExporter?
        }
        set {
            objc_setAssociatedObject(
                self,
                &changesExporterKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

private var changesExporterKey = "com.WeZZard.Nest.NSManagedObjectContextChangesExporter.NSManagedObjectContext.changesExporter"
