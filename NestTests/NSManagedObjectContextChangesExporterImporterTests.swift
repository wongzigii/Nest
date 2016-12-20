//
//  NSManagedObjectContextChangesExporterImporterTests.swift
//  Nest
//
//  Created by Manfred on 03/11/2016.
//
//

import XCTest

@testable
import Nest

import CoreData

internal class ManagedObject: NSManagedObject {
    @NSManaged
    internal var id: Int32
}

@available(
iOSApplicationExtension 9.0,
OSXApplicationExtension 10.11,
tvOS 9.0,
watchOS 2.0,
*)
class NSManagedObjectContextChangesExporterImporterTests: XCTestCase,
    NSManagedObjectContextChangesExporterDelegate,
    NSManagedObjectContextChangesImporterDelegate
{
    
    internal var exportPersistentController: PersistentController!
    internal var importPersistentController: PersistentController!
    
    internal var didImporterCallDelegateDidImport: XCTestExpectation!
    
    internal var persistentStoreURL: URL {
        
        let userDocDirs = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        )
        
        let dir = URL(fileURLWithPath: userDocDirs[0])
        
        let url = dir.appendingPathComponent("UserData.sqlite")
        
        return url
    }
    
    override func setUp() {
        super.setUp()
        
        let url = persistentStoreURL
        
        self.exportPersistentController = PersistentController(
            store: .sqlite(url: url),
            modelBundle: Bundle(for: type(of: self)),
            modelName: "NSManagedObjectContextChangesExporterImporterTests"
        )
        exportPersistentController.name = "export"
        
        self.importPersistentController = PersistentController(
            store: .sqlite(url: url),
            modelBundle: Bundle(for: type(of: self)),
            modelName: "NSManagedObjectContextChangesExporterImporterTests"
        )
        importPersistentController.name = "import"
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        let url = persistentStoreURL
        
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch let error {
            NSException(
                name: .internalInconsistencyException,
                reason: error.localizedDescription,
                userInfo: nil
                ).raise()
        }
        
    }
    
    func testExportAndImport() {
        self.didImporterCallDelegateDidImport = expectation(
            description: "Importer did call delegate's did import."
        )
        let isExportedContentImported = expectation(
            description: "Exported content is imported."
        )
        let isExportedContentImportedCorrectly = expectation(
            description: "Exported content is imported correctly."
        )
        
        // Export
        self.exportPersistentController.performAndWait { (ctx) in
            // Setup exporter
            let exporter = NSManagedObjectContextChangesExporter(context: ctx)
            ctx.changesExporter = exporter
            exporter.delegate = self
            
            // Make chagnes
            for idx in 0..<_changesAmount {
                let anObject = ManagedObject(managedObjectContext: ctx)
                anObject.id = idx
            }
            
            self.exportPersistentController.save(with: { (errorOrNil) in
                if let error = errorOrNil {
                    NSException(
                        name: .internalInconsistencyException,
                        reason: "\(error.localizedDescription)",
                        userInfo: nil
                        ).raise()
                }
                
                // Import
                let fetchRequest = NSFetchRequest<ManagedObject>(
                    entityName: "ManagedObject"
                )
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(key: "id", ascending: true)
                ]
                
                self.importPersistentController.performAndWait { (ctx) in
                    // Seutp importer
                    let importer = NSManagedObjectContextChangesImporter(
                        context: ctx
                    )
                    importer.delegate = self
                    importer.`import`()
                    
                    do {
                        let result = try ctx.fetch(fetchRequest)
                        
                        let isCountCorrect = result.count == Int(_changesAmount)
                        
                        let isContentCorrect = result.enumerated().reduce(true){
                            return $0 && $1.offset == Int($1.element.id)
                        }
                        
                        if isCountCorrect {
                            isExportedContentImported.fulfill()
                        }
                        
                        if isContentCorrect {
                            isExportedContentImportedCorrectly.fulfill()
                        }
                        
                    } catch let error {
                        NSException(
                            name: .internalInconsistencyException,
                            reason: "\(error.localizedDescription)",
                            userInfo: nil
                            ).raise()
                    }
                }
            })
        }
        
        waitForExpectations(timeout: 5) { (errorOrNil) in
            if let error = errorOrNil {
                NSLog(error.localizedDescription)
            }
        }
    }
    
    // MARK: - NSManagedObjectContextChangesExporterDelegate
    @nonobjc
    func persistentUserDefault(
        for managedObjectContextChangesExporter:
        NSManagedObjectContextChangesExporter
        ) -> UserDefaults
    {
        return UserDefaults.standard
    }
    
    @nonobjc
    func managedObjectContextChangesExporter(
        _ sender: NSManagedObjectContextChangesExporter,
        exportIdentifierFor persistentUserDefault: UserDefaults
        ) -> String
    {
        return _chagnesKey
    }
    
    // MARK: - NSManagedObjectContextChangesImporterDelegate
    @nonobjc
    func persistentUserDefault(
        for managedObjectContextChangesImporter:
        NSManagedObjectContextChangesImporter
        ) -> UserDefaults
    {
        return UserDefaults.standard
    }
    
    @nonobjc
    func managedObjectContextChangesImporter(
        _ sender: NSManagedObjectContextChangesImporter,
        importIdentifierFor persistentUserDefault: UserDefaults
        ) -> String
    {
        return _chagnesKey
    }
    
    @nonobjc
    func managedObjectContextChangesImporterDidImport(
        _ sender: NSManagedObjectContextChangesImporter
        )
    {
        didImporterCallDelegateDidImport.fulfill()
    }
}

private let _changesAmount: Int32 = 4096

private let _chagnesKey = "com.WeZZard.Nest.NSManagedObjectContextChangesExporterImporterTestsChanges"
