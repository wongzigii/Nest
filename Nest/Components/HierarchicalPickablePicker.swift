//
//  HierarchicalPickablePicker.swift
//  Nest
//
//  Created by Manfred Lau on 5/19/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import SwiftExt

/**
Conform to `HierarchicalPickable` if you want your type to be able to be
recognized by `HierarchicalPickablePicker`
*/
public protocol HierarchicalPickable: Hashable {
    associatedtype ParentPickable = Self
    associatedtype Pickable = Self
    
    /// Parent
    var parentPickable: ParentPickable? {get}
    
    /// Child
    var childPickables: [Pickable]? {get}
    
    /// Title can be recognized by `HierarchicalPickablePicker`
    var pickableTitle: String {get}
}

extension HierarchicalPickable where
    ParentPickable: HierarchicalPickable,
    ParentPickable.Pickable == Self,
    Pickable == Self
{
    public typealias AncestorIterateHandler = (aParent: ParentPickable) -> Void
    
    public typealias DescendantIterateHandler = (aChild: Pickable) -> Void
    
    /// Get hierarchical ancestors
    public var hierarchicalAncestors: [ParentPickable] {
        var ancestors:[ParentPickable] = []
        
        getAncestorsOf(self, ancestors: &ancestors)
        
        return ancestors
    }
    
    /// Get hierarchical ancestors with handler
    /// The handler will be execute after every ancestor has been found
    public func getHierarchicalAncestorsWithHandler
        (handler: AncestorIterateHandler) -> [ParentPickable]
    {
        var ancestors:[ParentPickable] = []
        
        getAncestorsOf(self, ancestors: &ancestors, handler: handler)
        
        return ancestors
    }
    
    private func getAncestorsOf(node: Self,
        inout ancestors: [ParentPickable],
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
                assertionFailure("Type \"\(ParentPickable.self)\" is not a descandant of \"\(Pickable.self)\"")
            }
        }
    }
    
    /// Get hierarchical descendants
    public var hierarchicalDescendants: [Self] {
        var descendants:[Self] = []
        
        getDescendantsOf(self, descendants: &descendants)
        
        return descendants
    }
    
    /// Get hierarchical descendants with handler
    /// The handler will be execute after every descendants has been found
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

/**
A controller to pick `HierarchicalPickable`
*/
public class HierarchicalPickablePicker<P: HierarchicalPickable where
    P.ParentPickable: HierarchicalPickable,
    P.ParentPickable.Pickable == P,
    P.Pickable == P
> {
    public typealias Pickable = P
    public typealias ParentPickable = P.ParentPickable
    
    private var _hierarchicalPickedPickables = [Int: Set<Pickable>]()
    /// Returns the whole forest of `HierarchicalPickable`s
    public var hierarchicalPickedPickables: [Int: Set<Pickable>] {
        return _hierarchicalPickedPickables
    }
    
    /// Returns a level in the forest of `HierarchicalPickable`s
    public subscript (level: Int) -> [Pickable]? {
        if let setOfPickables = _hierarchicalPickedPickables[level] {
            return Array<Pickable>(setOfPickables)
        }
        return nil
    }
    
    /// Returns a flattened `HierarchicalPickable`s
    private var _flattenedPickedPickables = Set<Pickable>()
    public var flattenedPickedPickables: [Pickable] {
        return [Pickable](_flattenedPickedPickables)
    }
    
    public init() {}
    
    /// Pick a `HierarchicalPickable` to specified level.
    /// You also can pick its descendants at the same time.
    public func pick(aPickable: Pickable,
        toLevel level: Int,
        andItsDescendants pickDscendants: Bool = false)
    {
        if let container = _hierarchicalPickedPickables[level] {
            _hierarchicalPickedPickables[level] = container + aPickable
        } else {
            _hierarchicalPickedPickables[level] = [aPickable]
        }
        
        _flattenedPickedPickables.insert(aPickable)
        
        
        if pickDscendants {
            pickDescendantsOfHierarchicalPickables([aPickable],
                atLevel: level)
        }
    }
    
    /// Unpick a `HierarchicalPickable` from specified level
    /// You also can unpick its descendants at the same time
    public func unpick(aHierarchicalPickable: Pickable,
        fromLevel level: Int,
        andItsDescendants unpickDscendants: Bool = false) -> [Pickable]
    {
        var removed = [Pickable]()
        
        if var containerAtLevel = _hierarchicalPickedPickables[level] {
            if let index = containerAtLevel.indexOf(aHierarchicalPickable)
            {
                removed.append(containerAtLevel[index])
                containerAtLevel.removeAtIndex(index)
                _hierarchicalPickedPickables[level] = containerAtLevel
                
                _flattenedPickedPickables.remove(aHierarchicalPickable)
            }
        }
        
        if unpickDscendants {
            unpickDescendantsOfHierarchicalPickables(
                [aHierarchicalPickable],
                atLevel: level,
                removed: &removed)
        }
        
        return removed
    }
    
    //MARK: Privates
    private func pickDescendantsOfHierarchicalPickables(
        hierarchicalPickables: [Pickable],
        atLevel level: Int)
    {
        let descendantsLevel = level + 1
        var nextLevelPickables = [Pickable]()
        
        for eachHierarchicalPickable in hierarchicalPickables {
            if let descendants = eachHierarchicalPickable.childPickables {
                for eachDecsendant in descendants {
                    
                    if let container =
                        _hierarchicalPickedPickables[descendantsLevel]
                    {
                        _hierarchicalPickedPickables[descendantsLevel] =
                            container + eachDecsendant
                    } else {
                        _hierarchicalPickedPickables[descendantsLevel] =
                            [eachDecsendant]
                    }
                    
                    _flattenedPickedPickables.insert(eachDecsendant)
                    
                    nextLevelPickables += eachDecsendant
                }
            }
        }
        
        if nextLevelPickables.count > 0 {
            pickDescendantsOfHierarchicalPickables(nextLevelPickables,
                atLevel: descendantsLevel)
        }
    }
    
    private func unpickDescendantsOfHierarchicalPickables(
        hierarchicalPickables: [Pickable],
        atLevel level: Int,
        inout removed: [Pickable])
    {
        let descendantsLevel = level + 1
        var nextLevelPickables = [Pickable]()
        
        for eachHierarchicalPickable in hierarchicalPickables {
            if let descendants = eachHierarchicalPickable.childPickables {
                for eachDescendant in descendants {
                    if var descendantContainer =
                        _hierarchicalPickedPickables[descendantsLevel]
                    {
                        if let index =
                            descendantContainer.indexOf(eachDescendant)
                        {
                            removed.append(descendantContainer[index])
                            descendantContainer.removeAtIndex(index)
                        }
                        _hierarchicalPickedPickables[descendantsLevel] =
                            descendantContainer
                        
                        _flattenedPickedPickables.remove(eachDescendant)
                        
                        nextLevelPickables += eachDescendant
                    }
                }
            }
        }
        
        if nextLevelPickables.count > 0 {
            unpickDescendantsOfHierarchicalPickables(nextLevelPickables,
                atLevel: descendantsLevel,
                removed: &removed)
        }
    }
}

private class PickablePrintEntryPoint<P: HierarchicalPickable where
    P.ParentPickable: HierarchicalPickable,
    P.Pickable == P>
{
    typealias Pickable = P
    typealias ParentPickable = P.ParentPickable
    let pickable: Pickable
    let level: Int
    
    init(_ aPickable: Pickable, _ aLevel: Int) {
        pickable = aPickable
        level = aLevel
    }
}

//MARK: - Printable & DebugPrintable
private let Placeholder = "-(PLACEHOLDER)-"
extension HierarchicalPickablePicker: CustomStringConvertible,
    CustomDebugStringConvertible
{
    public var description: String {
        var pickedString = ""
        for each in _flattenedPickedPickables {
            if pickedString == "" {
                pickedString += renderedTitleForTitle(each.pickableTitle)
            } else {
                pickedString += ", \(renderedTitleForTitle(each.pickableTitle))"
            }
        }
        return "\(self.dynamicType), Pickable Type: \(Pickable.self), Parent Pickable Type: \(ParentPickable.self)\nPicked:\n\(pickedString)"
    }
    
    public var debugDescription: String {
        var pickedPickableString = ""
        
        if let initialPickables: Set<Pickable> =
            _hierarchicalPickedPickables[0]
        {
            var pendingStack = initialPickables.reverse().map{
                PickablePrintEntryPoint<Pickable>($0, 0)}
            var drawnStack = [PickablePrintEntryPoint<Pickable>]()
            var availableSiblingsMap = [ParentPickable: [Pickable]]()
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
                if pickedPickableString == "" {
                    pickedPickableString += lineOfString
                }
                else { pickedPickableString += "\n" + lineOfString }
                
                // Push drawn
                drawnStack.append(popped)
            }
        }
        
        return "\(self.dynamicType), Pickable Type: \(Pickable.self), Parent Pickable Type: \(ParentPickable.self)\nPicked:\n\(pickedPickableString)"
    }
    
    //MARK: Print Infrastructures
    private func renderedTitleForTitle(title: String) -> String {
        return "[" + title + "]"
    }
    
    private func getMaxTitleLengthForLevel(level: Int,
        inout maxTitleLengthDict: [Int: Int]) -> Int
    {
        if let maxTitleLength = maxTitleLengthDict[level] {
            return maxTitleLength
        } else {
            if let container = _hierarchicalPickedPickables[level] {
                var maxTitleLength = 0
                for each in container {
                    maxTitleLength = max(maxTitleLength,
                        renderedTitleForTitle(each.pickableTitle)
                            .characters.count)
                }
                maxTitleLengthDict[level] = maxTitleLength
                return maxTitleLength
            } else {
                let placeholderLength = renderedTitleForTitle(Placeholder)
                    .characters.count
                maxTitleLengthDict[level] = placeholderLength
                return placeholderLength
            }
        }
    }
    
    private func getAvailableSiblingsForPickable(pickable: Pickable,
        atLevel level: Int,
        inout availableSiblingsMap: [ParentPickable: [Pickable]],
        initialAvoidPickable: Pickable?) -> [Pickable]
    {
        if let parent = pickable.parentPickable {
            if let cached = availableSiblingsMap[parent] {
                return cached
            } else {
                if let siblings = parent.childPickables,
                    pickedAtLevel = _hierarchicalPickedPickables[level]
                {
                    var availableSiblings = siblings.intersect(
                        Array<Pickable>(pickedAtLevel))
                    if let initialAvoidPickable = initialAvoidPickable {
                        if let index =
                            availableSiblings.indexOf(
                                initialAvoidPickable)
                        {
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
    
    private func dequeueSibling(sibling: Pickable ,
        forPickable pickable: Pickable,
        atLevel level: Int,
        inout availableSiblingsMap: [ParentPickable: [Pickable]])
    {
        if let parent = pickable.parentPickable {
            var availableSiblings = getAvailableSiblingsForPickable(
                pickable,
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
        drawnStack: [PickablePrintEntryPoint<Pickable>]) -> String
    {
        var prefixString = ""
        
        for level in 0..<level {
            if drawnStack.filter({$0.level < level}).count == 0 {
                let maxTitleLengthInLevel = getMaxTitleLengthForLevel(
                    level,
                    maxTitleLengthDict: &maxTitleLengthDict)
                prefixString += "|" + maxTitleLengthInLevel * " "
            } else {
                prefixString += "+" + renderedTitleForTitle(Placeholder)
            }
        }
        
        return prefixString
    }
    
    private func getStringForPrintEntryPoint(
        entryPoint: PickablePrintEntryPoint<Pickable>,
        inout maxTitleLengthDict: [Int: Int],
        inout pendingStack: [PickablePrintEntryPoint<Pickable>],
        inout drawnStack: [PickablePrintEntryPoint<Pickable>],
        inout availableSiblingsMap: [ParentPickable: [Pickable]])
        -> String
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
    
    private func getStringAlongPickable(pickable: Pickable,
        level: Int,
        inout maxTitleLengthDict: [Int: Int],
        inout pendingStack: [PickablePrintEntryPoint<Pickable>],
        inout availableSiblingsMap: [ParentPickable: [Pickable]])
        -> String
    {
        let maxTitleLengthInLevel = getMaxTitleLengthForLevel(level,
            maxTitleLengthDict: &maxTitleLengthDict)
        let pickableTitle = renderedTitleForTitle(pickable.pickableTitle)
        var titleString = "+" + pickableTitle
        
        let availableSiblings = getAvailableSiblingsForPickable(pickable,
            atLevel: level,
            availableSiblingsMap: &availableSiblingsMap,
            initialAvoidPickable: pickable)
        
        
        // Push entry point if necessary
        if let nextEntryPointPickable = availableSiblings.first {
            dequeueSibling(nextEntryPointPickable,
                forPickable: pickable,
                atLevel: level,
                availableSiblingsMap: &availableSiblingsMap)
            
            let nextEntryPoint = PickablePrintEntryPoint<Pickable>(
                nextEntryPointPickable,
                level)
            pendingStack.append(nextEntryPoint)
        }
        
        // Generate string along the first child
        if let pickedAtNextLevel =
            _hierarchicalPickedPickables[level + 1],
            var childPickables = pickable.childPickables
        {
            if childPickables.count > 0 && pickedAtNextLevel.count > 0 {
                if let nextPickable = { () -> Pickable? in
                    var nextPickable: Pickable =
                        childPickables.removeLast()
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
                    let repeatTimes = maxTitleLengthInLevel -
                        pickableTitle.characters.count
                    titleString += repeatTimes * "-"
                    let nextString = getStringAlongPickable(nextPickable,
                        level: level + 1,
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