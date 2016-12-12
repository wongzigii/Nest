//
//  ObjCGraftProtocolImplementation.swift
//  Nest
//
//  Created by Manfred on 22/10/2016.
//
//

import Foundation
import ObjectiveC
import SwiftExt

extension NSObject {
    @objc(nest_graftProtocolImplementationOfProtocol:onGraftingClass:)
    public func nest_graftProtocolImplementation(
        of aProtocol: Protocol,
        on GraftingClass: AnyClass
        )
    {
        ObjCGraftProtocolImplementation(of: aProtocol, on: GraftingClass, to: self)
    }
    
    @objc(nest_graftProtocolImplementationOfProtocol:onGraftingObject:)
    public func nest_graftProtocolImplementation(
        of aProtocol: Protocol,
        on graftingObject: AnyObject
        )
    {
        ObjCGraftProtocolImplementation(of: aProtocol, on: graftingObject, to: self)
    }
    
    @objc
    public func nest_ungraftAllProtocolImplementations() {
        ObjCUngraftProtocolImplementationsAll(on: self)
    }
}

//MARK: - Graft
/// Grafts the implementation of a protocol on a class to another object.
public func ObjCGraftProtocolImplementation(
    of aProtocol: Protocol,
    on GraftingClass: AnyClass,
    to graftedObject: AnyObject
    )
{
    ObjCGraftProtocolImplementation(
        with: [aProtocol: GraftingClass], to: graftedObject
    )
}

/// Grafts the implementation of a protocol on an object to another object.
public func ObjCGraftProtocolImplementation(
    of aProtocol: Protocol,
    on graftingObject: AnyObject,
    to graftedObject: AnyObject
    )
{
    ObjCGraftProtocolImplementation(
        with: [aProtocol: type(of: graftingObject)], to: graftedObject
    )
}

public func ObjCGraftProtocolImplementation(
    with graftingTable: ObjCProtocolImplementationGraftingTable,
    to graftedObject: AnyObject
    )
{
    let GraftedObject: AnyClass = type(of: graftedObject)
    
    for (unownedProtocol, GraftingClass) in graftingTable._content {
        let `protocol` = unownedProtocol.value
        // class_conformsToProtocol only checks on current class.
        precondition(class_conformsToProtocol(GraftedObject, `protocol`))
        // [NSObject +conformsToProtocol:] checks the whole class hierarchy.
        precondition(GraftingClass.conforms(to: `protocol`))
    }
    
    let graftBundle = _ObjCProtocolImplementationGraftedClass(
        for: GraftedObject, with: graftingTable
    )
    
    let GraftedClass: AnyClass = graftBundle.graftedClass
    let finalGraftingTable = graftBundle.graftingTable
    
    if (GraftedObject.self != GraftedClass.self) {
        object_setClass(graftedObject, GraftedClass)
        
        for (unownedProtocol, GraftingClass) in finalGraftingTable._content {
            let `protocol` = unownedProtocol.value
            _ObjCGraftImplementation(
                of: `protocol`, on: GraftingClass, to: graftedObject
            )
        }
        
    } else {
        assert(finalGraftingTable._content.isEmpty)
    }
}

private func _ObjCGraftImplementation(
    of aProtocol: Protocol,
    on GraftingClass: AnyClass,
    to graftedObject: AnyObject
    )
{
    let GraftedClass: AnyClass = type(of: graftedObject)
    let MetaGraftedClass: AnyClass = objc_getMetaClass(
        NSStringFromClass(GraftedClass)
        ) as! AnyClass
    
    let GraftingClass: AnyClass = GraftingClass
    let MetaGraftingClass: AnyClass = objc_getMetaClass(
        NSStringFromClass(GraftingClass)
        ) as! AnyClass
    
    // Graft protocol's property members
    if #available(
        iOSApplicationExtension 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *
        )
    {
        for flag in 0...0b11 {
            let isRequired = (flag & 0b01) != 0
            let isInstance = (flag & 0b10) != 0
            
            let grafted: AnyClass = isInstance ? GraftedClass : MetaGraftedClass
            let grafting: AnyClass = isInstance ?
                GraftingClass : MetaGraftingClass
            
            var propertyCount: UInt32 = 0
            if let propertyList = protocol_copyPropertyList2(
                aProtocol, &propertyCount, isRequired, isInstance
                )
            {
                for idx in 0..<Int(propertyCount) {
                    let property = propertyList[idx]!
                    _ObjCGraftProperty(
                        property,
                        isRequired: isRequired,
                        isInstance: isInstance,
                        on: grafting,
                        to: grafted
                    )
                }
                
                propertyList.deallocate(capacity: Int(propertyCount))
            }
        }
    } else {
        var propertyCount: UInt32 = 0
        if let propertyList = protocol_copyPropertyList(
            aProtocol, &propertyCount
            )
        {
            for idx in 0..<Int(propertyCount) {
                let property = propertyList[idx]!
                _ObjCGraftProperty(
                    property,
                    isRequired: true,
                    isInstance: true,
                    on: GraftingClass,
                    to: GraftedClass
                )
            }
            
            propertyList.deallocate(capacity: Int(propertyCount))
        }
    }
    
    // Graft protocol's method members
    for flag in 0...0b11 {
        let isRequired = (flag & 0b01) != 0
        let isInstance = (flag & 0b10) != 0
        
        let grafted: AnyClass = isInstance ? GraftedClass : MetaGraftedClass
        let grafting: AnyClass = isInstance ? GraftingClass : MetaGraftingClass
        
        var methodDescCount: UInt32 = 0
        if let methodDescList = protocol_copyMethodDescriptionList(
            aProtocol, isRequired, isInstance, &methodDescCount
            )
        {
            for idx in 0..<Int(methodDescCount) {
                let methodDesc = methodDescList[idx]
                
                assert(methodDesc.name != nil)
                assert(methodDesc.types != nil)
                
                let selectorName = methodDesc.name
                let types = methodDesc.types
                
                if let graftingImpl
                    = class_getMethodImplementation(grafting, selectorName)
                {
                    if let graftedImpl = class_getMethodImplementation(
                        grafted, selectorName
                        )
                    {
                        if graftingImpl != graftedImpl {
                            class_replaceMethod(
                                grafted, selectorName, graftingImpl, types
                            )
                        }
                    } else {
                        class_addMethod(
                            grafted, selectorName, graftingImpl, types
                        )
                    }
                }
            }
            
            methodDescList.deallocate(capacity: Int(methodDescCount))
        }
    }
}

private func _ObjCGraftProperty(
    _ property: objc_property_t,
    isRequired: Bool,
    isInstance: Bool,
    on Grafting: AnyClass,
    to Grafted: AnyClass
    )
{
    if let getter = property_copyAttributeValue(property, _getterSelector) {
        let getterNameLength = Int(strlen(getter))
        
        let getterName = NSString(utf8String: getter)! as String
        
        let getterSel = NSSelectorFromString(getterName)
        
        _ObjCGraftSelector(getterSel, on: Grafting, to: Grafted)
        
        getter.deallocate(capacity: getterNameLength)
    }
    
    if let setter = property_copyAttributeValue(property, _setterSelector) {
        let setterNameLength = Int(strlen(setter))
        
        let setterName = NSString(utf8String: setter)! as String
        
        let setterSel = NSSelectorFromString(setterName)
        
        _ObjCGraftSelector(setterSel, on: Grafting, to: Grafted)
        
        setter.deallocate(capacity: setterNameLength)
    }
}

private func _ObjCGraftSelector(
    _ selector: Selector,
    on Grafting: AnyClass,
    to Grafted: AnyClass
    )
{
    if let graftingImpl = class_getMethodImplementation(Grafting, selector) {
        if let graftedImpl = class_getMethodImplementation(Grafted, selector) {
            if graftingImpl != graftedImpl {
                let method = class_getInstanceMethod(Grafted, selector)
                method_setImplementation(method, graftingImpl)
            }
        } else {
            let method = class_getInstanceMethod(Grafting, selector)
            let methodType = method_getTypeEncoding(method)
            class_addMethod(Grafted, selector, graftingImpl, methodType)
        }
    }
}

public struct ObjCProtocolImplementationGraftingTable:
    ExpressibleByDictionaryLiteral
{
    public typealias Key = Protocol
    public typealias Value = AnyClass
    
    fileprivate let _content: [Unowned<Protocol>: AnyClass]
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        var content = [(Unowned<Protocol>) : AnyClass]()
        for (key, value) in elements {
            content[Unowned(key)] = value
        }
        _content = content
    }
    
    fileprivate init(graftingPairs: [Unowned<Protocol>: AnyClass]) {
        _content = graftingPairs
    }
    
    fileprivate var _graftingPairStrings: [String] {
        return _content.map {
            let `protocol` = $0.value
            let protocolName = NSStringFromProtocol(`protocol`)
            let className = NSStringFromClass($1)
            // "->" is illegal for source file but valid in Objective-C runtime.
            return "\(protocolName)->\(className)"
        }
    }
}

private func _ObjCProtocolImplementationGraftedClass(
    for class: AnyClass,
    with graftingTable: ObjCProtocolImplementationGraftingTable
    ) -> (
    graftedClass: AnyClass,
    graftingTable: ObjCProtocolImplementationGraftingTable
    )
{
    
    if let graftedClass = `class` as? _ObjCProtocolImplementationGrafted.Type {
        let existedGraftingPairs = graftedClass._graftingPairs
        let wantedGraftingPairs = graftingTable._content
        if existedGraftingPairs.contains(
            wantedGraftingPairs, 
            predicate: {$0.0 == $1.0 && $0.1 == $1.1}
            )
        {
            return (`class`, [:])
        } else {
            var newGraftingPairs = existedGraftingPairs
            for (key, value) in wantedGraftingPairs {
                newGraftingPairs[key] = value
            }
            let newGraftingTable = ObjCProtocolImplementationGraftingTable(
                graftingPairs: newGraftingPairs
            )
            return (_ObjCCreateProtocolImplementationGraftedClass(
                for: class_getSuperclass(`class`),
                with: newGraftingTable
            ), newGraftingTable)
        }
    } else {
        return (_ObjCCreateProtocolImplementationGraftedClass(
            for: `class`, with: graftingTable
        ), graftingTable)
    }
}

private func _ObjCCreateProtocolImplementationGraftedClass(
    for class: AnyClass,
    with graftingTable: ObjCProtocolImplementationGraftingTable
    ) -> AnyClass
{
    precondition(!(`class` is _ObjCProtocolImplementationGrafted))
    
    let className = "ObjCProtocolImplementationGrafted_"
        + NSStringFromClass(`class`)
        + "|"
        + graftingTable._graftingPairStrings.joined(separator: "|")
    let Subclass: AnyClass = objc_allocateClassPair(`class`, className, 0)!
    
    class_addProtocol(Subclass, _ObjCProtocolImplementationGrafted.self)
    
    objc_registerClassPair(Subclass)
    
    return Subclass
}

@objc
private protocol _ObjCProtocolImplementationGrafted: class {
    
}

extension _ObjCProtocolImplementationGrafted {
    fileprivate static var _graftingPairs: [Unowned<Protocol>: AnyClass] {
        let className = NSStringFromClass(self)
        let components = className.components(separatedBy: "|")
        assert((components.count & 0b1) == 0 && components.count > 1)
        let validComponents = components.dropFirst().map {
            (component) -> (Unowned<Protocol>, AnyClass) in
            let paired = component.components(separatedBy: "->")
            assert(paired.count == 2)
            let `protocol` = NSProtocolFromString(paired[0])!
            let `class`: AnyClass = NSClassFromString(paired[1])!
            return (Unowned(`protocol`), `class`)
        }
        var dictionary = [(Unowned<Protocol>) : AnyClass]()
        for (key, value) in validComponents {
            dictionary[key] = value
        }
        return dictionary
    }
}

//MARK: - Ungraft
@discardableResult
public func ObjCUngraftProtocolImplementationsAll<Grafted: AnyObject>(
    on graftedObject: Grafted
    ) -> Grafted
{
    if graftedObject is _ObjCProtocolImplementationGrafted {
        let original: AnyClass = class_getSuperclass(type(of: graftedObject))
        object_setClass(graftedObject, original)
    }
    return graftedObject
}

//MARK: - Constant
private let _getterSelector = NSString(format: "G").utf8String!
private let _setterSelector = NSString(format: "S").utf8String!
