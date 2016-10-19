//
//  FetchRequestTemplating.swift
//  Nest
//
//  Created by Manfred on 19/10/2016.
//
//

import CoreData

public protocol FetchRequestTemplating {
    associatedtype FetchRequestResult: NSFetchRequestResult
    
    associatedtype Variable: RawRepresentable, Hashable
    
    var name: String { get }
    
    var primitiveSubstitutionVariables: [Variable : Any] { get }
    
    var sortDescriptors: [NSSortDescriptor] { get }
}

extension FetchRequestTemplating where Variable.RawValue == String {
    public func toRequest(
        presistentController: PersistentController
        ) -> NSFetchRequest<FetchRequestResult>
    {
        return presistentController.fetchRequest(for: self)
    }
}

extension PersistentController {
    public func fetchRequest<Template: FetchRequestTemplating>(
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
        
        return fetchRequest
    }
}

extension SingletonPersistentController where Self: PersistentController {
    public static func fetchRequest<Template: FetchRequestTemplating>(
        for template: Template
        ) -> NSFetchRequest<Template.FetchRequestResult> where
        Template.Variable.RawValue == String
    {
        return shared.fetchRequest(for: template)
    }
}
