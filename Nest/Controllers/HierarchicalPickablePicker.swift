//
//  HierarchicalPickablePicker.swift
//  Nest
//
//  Created by Manfred Lau on 5/19/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Swift
import SwiftExt

public protocol HierarchicalPickable: Hashable {
    typealias ParentPickableType = Self
    typealias PickableType = Self
    
    var parentPickable: ParentPickableType? {get}
    var childPickables: [PickableType]? {get}
    
    var pickableTitle: String {get}
}

extension HierarchicalPickable where
    ParentPickableType: HierarchicalPickable,
    ParentPickableType.PickableType == Self,
    PickableType == Self
{
    public typealias AncestorIterateHandler =
        (aParent: ParentPickableType) -> Void
    
    public typealias DescendantIterateHandler =
        (aChild: PickableType) -> Void
    
    public var hierarchicalAncestors: [ParentPickableType] {
        var ancestors:[ParentPickableType] = []
        
        getAncestorsOf(self, ancestors: &ancestors)
        
        return ancestors
    }
    
    public func getHierarchicalAncestorsWithHandler
        (handler: AncestorIterateHandler) -> [ParentPickableType]
    {
        var ancestors:[ParentPickableType] = []
        
        getAncestorsOf(self, ancestors: &ancestors, handler: handler)
        
        return ancestors
    }
    
    private func getAncestorsOf(node: Self,
        inout ancestors: [ParentPickableType],
        handler: AncestorIterateHandler? = nil)
    {
        if let parent = node.parentPickable {
            handler?(aParent: parent)
            ancestors.append(parent)
            if let iteratableParent = parent as? Self {
                getAncestorsOf(iteratableParent,
                    ancestors: &ancestors,
                    handler: handler)
            } else {
                assertionFailure("Type \"\(ParentPickableType.self)\" is not a descandant of \"\(PickableType.self)\"")
            }
        }
    }
    
    public var hierarchicalDescendants: [Self] {
        var descendants:[Self] = []
        
        getDescendantsOf(self, descendants: &descendants)
        
        return descendants
    }
    
    public func getHierarchicalDescendantsWithHandler
        (handler: DescendantIterateHandler) -> [Self]
    {
        var descendants:[Self] = []
        
        getDescendantsOf(self,
            descendants: &descendants,
            handler: handler)
        
        return descendants
    }
    
    
    private func getDescendantsOf(node: Self,
        inout descendants: [Self],
        handler: DescendantIterateHandler? = nil)
    {
        if let children = node.childPickables {
            for eachChild in children {
                handler?(aChild: eachChild)
                descendants.append(eachChild)
                getDescendantsOf(eachChild,
                    descendants: &descendants,
                    handler: handler)
            }
        }
    }
}

public class HierarchicalPickablePicker<P: HierarchicalPickable where
    P.ParentPickableType: HierarchicalPickable,
    P.ParentPickableType.PickableType == P,
    P.PickableType == P
> {
    public typealias PickableType = P
    public typealias ParentPickableType = P.ParentPickableType
    
    private var _hierarchicalPickedPickables = [Int: Set<PickableType>]()
    public var hierarchicalPickedPickables: [Int: Set<PickableType>] {
        return _hierarchicalPickedPickables
    }
    
    public subscript (level: Int) -> [PickableType]? {
        if let setOfPickables = _hierarchicalPickedPickables[level] {
            return Array<PickableType>(setOfPickables)
        }
        return nil
    }
    
    private var _flattenedPickedPickables = Set<PickableType>()
    public var flattenedPickedPickables: [PickableType] { return Array<PickableType>(_flattenedPickedPickables) }
    
    public init() {
        
    }
    
    public func pick(aHierarchicalPickable: PickableType, atLevel level: Int, andItsDescendants pickDscendants: Bool) {
        if let containerAtLevel = _hierarchicalPickedPickables[level] {
            _hierarchicalPickedPickables[level] = containerAtLevel + aHierarchicalPickable
        } else {
            _hierarchicalPickedPickables[level] = [aHierarchicalPickable]
        }
        
        _flattenedPickedPickables.insert(aHierarchicalPickable)
        
        
        if pickDscendants {
            pickDescendantsOfHierarchicalPickables([aHierarchicalPickable], atLevel: level)
        }
    }
    
    public func unpick(aHierarchicalPickable: PickableType, atLevel level: Int, andItsDescendants unpickDscendants: Bool) -> [PickableType] {
        var removed = [PickableType]()
        
        if var containerAtLevel = _hierarchicalPickedPickables[level] {
            if let index = containerAtLevel.indexOf(aHierarchicalPickable) {
                removed.append(containerAtLevel[index])
                containerAtLevel.removeAtIndex(index)
                _hierarchicalPickedPickables[level] = containerAtLevel
                
                _flattenedPickedPickables.remove(aHierarchicalPickable)
            }
        }
        
        if unpickDscendants {
            unpickDescendantsOfHierarchicalPickables([aHierarchicalPickable], atLevel: level, removed: &removed)
        }
        
        return removed
    }
    
    //MARK: Privates
    private func pickDescendantsOfHierarchicalPickables(hierarchicalPickables: [PickableType], atLevel level: Int) {
        let descendantsLevel = level + 1
        var nextLevelPickables = [PickableType]()
        
        for eachHierarchicalPickable in hierarchicalPickables {
            if let descendants = eachHierarchicalPickable.childPickables {
                for eachDecsendant in descendants {
                    
                    if let descendantContainer = _hierarchicalPickedPickables[descendantsLevel] {
                        _hierarchicalPickedPickables[descendantsLevel] = descendantContainer + eachDecsendant
                    } else {
                        _hierarchicalPickedPickables[descendantsLevel] = [eachDecsendant]
                    }
                    
                    _flattenedPickedPickables.insert(eachDecsendant)
                    
                    nextLevelPickables += eachDecsendant
                }
            }
        }
        
        if nextLevelPickables.count > 0 {
            pickDescendantsOfHierarchicalPickables(nextLevelPickables, atLevel: descendantsLevel)
        }
    }
    
    private func unpickDescendantsOfHierarchicalPickables(hierarchicalPickables: [PickableType], atLevel level: Int, inout removed: [PickableType]) {
        let descendantsLevel = level + 1
        var nextLevelPickables = [PickableType]()
        
        for eachHierarchicalPickable in hierarchicalPickables {
            if let descendants = eachHierarchicalPickable.childPickables {
                for eachDescendant in descendants {
                    if var descendantContainer = _hierarchicalPickedPickables[descendantsLevel] {
                        if let index = descendantContainer.indexOf(eachDescendant) {
                            removed.append(descendantContainer[index])
                            descendantContainer.removeAtIndex(index)
                        }
                        _hierarchicalPickedPickables[descendantsLevel] = descendantContainer
                        
                        _flattenedPickedPickables.remove(eachDescendant)
                        
                        nextLevelPickables += eachDescendant
                    }
                }
            }
        }
        
        if nextLevelPickables.count > 0 {
            unpickDescendantsOfHierarchicalPickables(nextLevelPickables, atLevel: descendantsLevel, removed: &removed)
        }
    }
}

private class PickablePrintEntryPoint<P: HierarchicalPickable where
    P.ParentPickableType: HierarchicalPickable,
    P.PickableType == P>
{
    typealias PickableType = P
    typealias ParentPickableType = P.ParentPickableType
    let pickable: PickableType
    let level: Int
    
    init(_ aPickable: PickableType, _ aLevel: Int) {
        pickable = aPickable
        level = aLevel
    }
}

//MARK: - Printable & DebugPrintable
private let Placeholder = "-(PLACEHOLDER)-"
extension HierarchicalPickablePicker: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        var pickedString = ""
        for each in _flattenedPickedPickables {
            if pickedString == "" {
                pickedString += renderedTitleForTitle(each.pickableTitle)
            } else {
                pickedString += ", \(renderedTitleForTitle(each.pickableTitle))"
            }
        }
        return "\(self.dynamicType), Pickable Type: \(PickableType.self), Parent Pickable Type: \(ParentPickableType.self)\nPicked:\n\(pickedString)"
    }
    
    public var debugDescription: String {
        var pickedPickableString = ""
        
        if let initialPickables: Set<PickableType> = _hierarchicalPickedPickables[0] {
            var pendingStack = Array(Array<PickableType>(initialPickables).reverse()).map{PickablePrintEntryPoint<PickableType>($0, 0)}
            var drawnStack = [PickablePrintEntryPoint<PickableType>]()
            var availableSiblingsMap = [ParentPickableType: [PickableType]]()
            var maxTitleLengthDict: [Int: Int] = [:]
            
            while pendingStack.last != nil {
                // Pop pending
                let popped = pendingStack.removeLast()
                
                // Get string for entry point
                let lineOfString = getStringForPrintEntryPoint(popped,
                    maxTitleLengthDict: &maxTitleLengthDict,
                    pendingStack: &pendingStack,
                    drawnStack: &drawnStack,
                    availableSiblingsMap: &availableSiblingsMap)
                
                // Append string
                if pickedPickableString == "" { pickedPickableString += lineOfString }
                else { pickedPickableString += "\n" + lineOfString }
                
                // Push drawn
                drawnStack.append(popped)
            }
        }
        
        return "\(self.dynamicType), Pickable Type: \(PickableType.self), Parent Pickable Type: \(ParentPickableType.self)\nPicked:\n\(pickedPickableString)"
    }
    
    //MARK: Print Infrastructures
    private func renderedTitleForTitle(title: String) -> String {
        return "[" + title + "]"
    }
    
    private func getMaxTitleLengthForLevel(level: Int, inout maxTitleLengthDict: [Int: Int]) -> Int {
        if let maxTitleLength = maxTitleLengthDict[level] {
            return maxTitleLength
        } else {
            if let container = _hierarchicalPickedPickables[level] {
                var maxTitleLength = 0
                for each in container {
                    maxTitleLength = max(maxTitleLength, renderedTitleForTitle(each.pickableTitle).characters.count)
                }
                maxTitleLengthDict[level] = maxTitleLength
                return maxTitleLength
            } else {
                let placeholderLength = renderedTitleForTitle(Placeholder).characters.count
                maxTitleLengthDict[level] = placeholderLength
                return placeholderLength
            }
        }
    }
    
    private func getAvailableSiblingsForPickable(pickable: PickableType,
        atLevel level: Int,
        inout availableSiblingsMap: [ParentPickableType: [PickableType]],
        initialAvoidPickable: PickableType?) -> [PickableType]
    {
        if let parent = pickable.parentPickable {
            if let cached = availableSiblingsMap[parent] {
                return cached
            } else {
                if let siblings = parent.childPickables,
                    pickedAtLevel = _hierarchicalPickedPickables[level]
                {
                    var availableSiblings = siblings.intersected(Array<PickableType>(pickedAtLevel))
                    if let initialAvoidPickable = initialAvoidPickable {
                        if let index = availableSiblings.indexOf(initialAvoidPickable) {
                            availableSiblings.removeAtIndex(index)
                        }
                    }
                    availableSiblingsMap[parent] = availableSiblings
                    return availableSiblings
                } else {
                    availableSiblingsMap[parent] = []
                    return []
                }
            }
        }
        
        return []
    }
    
    private func dequeueSibling(sibling: PickableType ,forPickable pickable: PickableType,
        atLevel level: Int,
        inout availableSiblingsMap: [ParentPickableType: [PickableType]])
    {
        if let parent = pickable.parentPickable {
            var availableSiblings = getAvailableSiblingsForPickable(pickable,
                atLevel: level,
                availableSiblingsMap: &availableSiblingsMap,
                initialAvoidPickable: nil)
            
            if let index = availableSiblings.indexOf(sibling) {
                availableSiblings.removeAtIndex(index)
            }
            availableSiblingsMap[parent] = availableSiblings
        }
    }
    
    private func prefixStringForLevel(level: Int,
        inout maxTitleLengthDict: [Int: Int],
        drawnStack: [PickablePrintEntryPoint<PickableType>]) -> String
    {
        var prefixString = ""
        
        for level in 0..<level {
            if drawnStack.filter({$0.level < level}).count == 0 {
                let maxTitleLengthInLevel = getMaxTitleLengthForLevel(level, maxTitleLengthDict: &maxTitleLengthDict)
                prefixString += "|" + maxTitleLengthInLevel * " "
            } else {
                prefixString += "+" + renderedTitleForTitle(Placeholder)
            }
        }
        
        return prefixString
    }
    
    private func getStringForPrintEntryPoint(entryPoint: PickablePrintEntryPoint<PickableType>,
        inout maxTitleLengthDict: [Int: Int],
        inout pendingStack: [PickablePrintEntryPoint<PickableType>],
        inout drawnStack: [PickablePrintEntryPoint<PickableType>],
        inout availableSiblingsMap: [ParentPickableType: [PickableType]]) -> String
    {
        let level = entryPoint.level
        
        let prefixString = prefixStringForLevel(level,
            maxTitleLengthDict: &maxTitleLengthDict,
            drawnStack: drawnStack)
        
        let pickableString = getStringAlongPickable(entryPoint.pickable,
            level: entryPoint.level,
            maxTitleLengthDict: &maxTitleLengthDict,
            pendingStack: &pendingStack,
            availableSiblingsMap: &availableSiblingsMap)
        
        return prefixString + pickableString
    }
    
    private func getStringAlongPickable(pickable: PickableType,
        level: Int,
        inout maxTitleLengthDict: [Int: Int],
        inout pendingStack: [PickablePrintEntryPoint<PickableType>],
        inout availableSiblingsMap: [ParentPickableType: [PickableType]]) -> String
    {
        let maxTitleLengthInLevel = getMaxTitleLengthForLevel(level, maxTitleLengthDict: &maxTitleLengthDict)
        let pickableTitle = renderedTitleForTitle(pickable.pickableTitle)
        var titleString = "+" + pickableTitle
        
        let availableSiblings = getAvailableSiblingsForPickable(pickable,
            atLevel: level,
            availableSiblingsMap: &availableSiblingsMap,
            initialAvoidPickable: pickable)
        
        
        // Push entry point if necessary
        if let nextEntryPointPickable = availableSiblings.first {
            dequeueSibling(nextEntryPointPickable, forPickable: pickable, atLevel: level, availableSiblingsMap: &availableSiblingsMap)
            pendingStack.append(PickablePrintEntryPoint<PickableType>(nextEntryPointPickable, level))
        }
        
        // Generate string along the first child
        if let pickedAtNextLevel = _hierarchicalPickedPickables[level + 1],
            var childPickables = pickable.childPickables
        {
            if childPickables.count > 0 && pickedAtNextLevel.count > 0 {
                if let nextPickable = { () -> PickableType? in
                    var nextPickable: PickableType = childPickables.removeLast()
                    while !pickedAtNextLevel.contains(nextPickable) {
                        if childPickables.count > 0 {
                            nextPickable = childPickables.removeLast()
                        } else {
                            return nil
                        }
                    }
                    return nextPickable
                    }()
                {
                    titleString += (maxTitleLengthInLevel - pickableTitle.characters.count) * "-"
                    let nextString = getStringAlongPickable(nextPickable, level: level + 1,
                        maxTitleLengthDict: &maxTitleLengthDict,
                        pendingStack: &pendingStack,
                        availableSiblingsMap: &availableSiblingsMap)
                    return titleString + nextString
                }
            }
        }
        
        return titleString
    }
}