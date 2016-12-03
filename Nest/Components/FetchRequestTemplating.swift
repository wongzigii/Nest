//
//  FetchRequestTemplate.swift
//  Nest
//
//  Created by Manfred on 19/10/2016.
//
//

import CoreData

public protocol FetchRequestTemplate {
    associatedtype FetchRequestResult: NSFetchRequestResult
    
    associatedtype Variable: RawRepresentable, Hashable
    
    var name: String { get }
    
    var primitiveSubstitutionVariables: [Variable : Any] { get }
    
    var sortDescriptors: [NSSortDescriptor] { get }
    
    var fetchLimit: Int { get }
    
    var fetchOffset: Int { get }
    
    var fetchBatchSize: Int { get }
}

extension FetchRequestTemplate {
    public var sortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    public var fetchLimit: Int {
        return 0
    }
    
    public var fetchOffset: Int {
        return 0
    }
    
    public var fetchBatchSize: Int {
        return 0
    }
}

extension FetchRequestTemplate where Variable.RawValue == String {
    public func toRequest(
        presistentController: PersistentController
        ) -> NSFetchRequest<FetchRequestResult>
    {
        return presistentController.fetchRequest(for: self)
    }
}

extension PersistentController {
    public func fetchRequest<Template: FetchRequestTemplate>(
        for template: Template
        ) -> NSFetchRequest<Template.FetchRequestResult> where
        Template.Variable.RawValue == String
    {
        var substitutionVariables = [String : Any]()
        for (name, value) in template.primitiveSubstitutionVariables {
            substitutionVariables[name.rawValue] = value
        }
        
        let fetchRequest = fetchRequestFromTemplate(
            named: template.name,
            substitutionVariables: substitutionVariables
            )! as! NSFetchRequest<Template.FetchRequestResult>
        
        fetchRequest.sortDescriptors = template.sortDescriptors
        if template.fetchLimit != 0 {
            fetchRequest.fetchLimit = template.fetchLimit
        }
        if template.fetchOffset != 0 {
            fetchRequest.fetchOffset = template.fetchOffset
        }
        if template.fetchBatchSize != 0 {
            fetchRequest.fetchBatchSize = template.fetchBatchSize
        }
        
        return fetchRequest
    }
}

extension SingletonPersistentController where Self: PersistentController {
    public static func fetchRequest<Template: FetchRequestTemplate>(
        for template: Template
        ) -> NSFetchRequest<Template.FetchRequestResult> where
        Template.Variable.RawValue == String
    {
        return shared.fetchRequest(for: template)
    }
}
