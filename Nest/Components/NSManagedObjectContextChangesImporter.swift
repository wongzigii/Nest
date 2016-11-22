//
//  NSManagedObjectContextChangesImporter.swift
//  Review
//
//  Created by Manfred on 9/19/16.
//
//

import CoreData

@available(
iOSApplicationExtension 9.0,
OSXApplicationExtension 10.11,
tvOS 9.0,
watchOS 2.0,
*)
public protocol NSManagedObjectContextChangesImporterDelegate: class {
    func persistentUserDefault(
        for managedObjectContextChangesImporter:
        NSManagedObjectContextChangesImporter
    ) -> UserDefaults
    
    func managedObjectContextChangesImporter(
        _ sender: NSManagedObjectContextChangesImporter,
        importIdentifierFor persistentUserDefault: UserDefaults
    ) -> String
    
    func managedObjectContextChangesImporterDidImport(
        _ sender: NSManagedObjectContextChangesImporter
    )
    
}

@available(
iOSApplicationExtension 9.0,
OSXApplicationExtension 10.11,
tvOS 9.0,
watchOS 2.0,
*)
public class NSManagedObjectContextChangesImporter: NSObject {
    public init(context: NSManagedObjectContext) {
        _context = context
        super.init()
    }
    
    public func `import`() {
        guard let userDefaults = delegate?.persistentUserDefault(for: self)
            else
        {
            #if DEBUG
                NSLog("\(self): No delegate set.")
            #endif
            return
        }
        
        guard let key = delegate?.managedObjectContextChangesImporter(
            self,
            importIdentifierFor: userDefaults
            )
            else
        {
            #if DEBUG
                NSLog("\(self): No delegate set.")
            #endif
            return
        }
        
        let extensionObjectChagnes = userDefaults.object(forKey: key)
            .flatMap {$0 as? Data}
            .map {NSKeyedUnarchiver.unarchiveObject(with: $0)}
            .flatMap {$0 as? [[AnyHashable : [URL]]]}
        
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
        
        if let extensionObjectChagnes = extensionObjectChagnes {
            _retainedSelf = self
            
            let importContext = NSManagedObjectContext(
                concurrencyType: .privateQueueConcurrencyType
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector:
                #selector(_handle(managedObjectContextDidSave:)),
                name: .NSManagedObjectContextDidSave,
                object: importContext
            )
            
            importContext.parent = _context
            
            importContext.perform {
                for eachChange in extensionObjectChagnes {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: eachChange,
                        into: [importContext]
                    )
                }
                do {
                    try importContext.save()
                } catch let error {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    @objc(_handleManagedObjectContextDidSave:)
    private func _handle(managedObjectContextDidSave: Notification) {
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextDidSave,
            object: managedObjectContextDidSave.object
        )
        _retainedSelf = nil
        delegate?.managedObjectContextChangesImporterDidImport(self)
    }
    
    public weak var delegate: NSManagedObjectContextChangesImporterDelegate?
    
    private let _context: NSManagedObjectContext
    
    private var _retainedSelf: NSManagedObjectContextChangesImporter?
}

