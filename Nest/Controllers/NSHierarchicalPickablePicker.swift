//
//  HierarchicalPickablePicker.swift
//  WZFoundation
//
//  Created by Manfred Lau on 5/19/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import SwiftExt

public protocol NSHierarchicalPickable: Hashable {
    typealias ParentPickableType = Self
    typealias PickableType = Self
    
    var parentPickable: ParentPickableType? {get}
    var childPickables: [PickableType]? {get}
    
    var pickableTitle: String {get}
}

public func NSAncestorsOfHierarchicalPickable<P: NSHierarchicalPickable where
    P.ParentPickableType: NSHierarchicalPickable,
    P.ParentPickableType.PickableType == P,
    P.PickableType == P>
    (aHierarchicalPickable: P, handler: ((aParent: P.ParentPickableType) -> Void)? = nil)
    -> [P.ParentPickableType]
{
    var ancestors:[P.ParentPickableType] = []
    
    NSGetAncestorsOf(aHierarchicalPickable, &ancestors, handler)
    
    return ancestors
}

private func NSGetAncestorsOf<P: NSHierarchicalPickable where
    P.ParentPickableType: NSHierarchicalPickable,
    P.ParentPickableType.PickableType == P,
    P.PickableType == P>
    (aHierarchicalPickable: P, inout ancestors: [P.ParentPickableType], handler: ((aParent: P.ParentPickableType) -> Void)?)
{
    if let parent = aHierarchicalPickable.parentPickable {
        handler?(aParent: parent)
        ancestors.append(parent)
        if let iteratableParent = parent as? P {
            NSGetAncestorsOf(iteratableParent, &ancestors, handler)
        } else {
            assertionFailure("Type \"\(P.ParentPickableType.self)\" is not a descandant of \"\(P.PickableType.self)\"")
        }
    }
}

public func NSDescendantsOfHierarchicalPickable<P: NSHierarchicalPickable where
    P.ParentPickableType: NSHierarchicalPickable,
    P.ParentPickableType.PickableType == P,
    P.PickableType == P>
    (aHierarchicalPickable: P, handler: ((aChild: P) -> Void)? = nil)
    -> [P]
{
    var descendants:[P] = []
    
    NSGetDescendantsOf(aHierarchicalPickable, &descendants, handler)
    
    return descendants
}

private func NSGetDescendantsOf<P: NSHierarchicalPickable where
    P.ParentPickableType: NSHierarchicalPickable,
    P.ParentPickableType.PickableType == P,
    P.PickableType == P>
    (aHierarchicalPickable: P, inout descendants: [P], handler: ((aChild: P) -> Void)?)
{
    if let children = aHierarchicalPickable.childPickables {
        for eachChild in children {
            handler?(aChild: eachChild)
            descendants.append(eachChild)
            NSGetDescendantsOf(eachChild, &descendants, handler)
        }
    }
}

public class NSHierarchicalPickablePicker<P: NSHierarchicalPickable where
    P.ParentPickableType: NSHierarchicalPickable,
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
            if let index = find(containerAtLevel, aHierarchicalPickable) {
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
                        if let index = find(descendantContainer, eachDescendant) {
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

private class NSPickablePrintEntryPoint<P: NSHierarchicalPickable where
    P.ParentPickableType: NSHierarchicalPickable,
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
extension NSHierarchicalPickablePicker: Printable, DebugPrintable {
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
            var pendingStack = Array<PickableType>(initialPickables).reverse().map{NSPickablePrintEntryPoint<PickableType>($0, 0)}
            var drawnStack = [NSPickablePrintEntryPoint<PickableType>]()
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
                    maxTitleLength = max(maxTitleLength, count(renderedTitleForTitle(each.pickableTitle)))
                }
                maxTitleLengthDict[level] = maxTitleLength
                return maxTitleLength
            } else {
                let placeholderLength = count(renderedTitleForTitle(Placeholder))
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
                    var availableSiblings = intersected(siblings, Array<PickableType>(pickedAtLevel))
                    if let initialAvoidPickable = initialAvoidPickable {
                        if let index = find(availableSiblings, initialAvoidPickable) {
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
            
            if let index = find(availableSiblings, sibling) {
                availableSiblings.removeAtIndex(index)
            }
            availableSiblingsMap[parent] = availableSiblings
        }
    }
    
    private func prefixStringForLevel(level: Int,
        inout maxTitleLengthDict: [Int: Int],
        drawnStack: [NSPickablePrintEntryPoint<PickableType>]) -> String
    {
        var prefixString = ""
        
        let drawnLevel = drawnStack.map {$0.level}
        
        for level in 0..<level {
            if drawnStack.filter({$0.level < level}).count == 0 {
                let maxTitleLengthInLevel = getMaxTitleLengthForLevel(level, maxTitleLengthDict: &maxTitleLengthDict)
                prefixString += "|" + maxTitleLengthInLevel * " "
            } else {
                let maxTitleLengthInLevel = getMaxTitleLengthForLevel(level, maxTitleLengthDict: &maxTitleLengthDict)
                prefixString += "+" + renderedTitleForTitle(Placeholder)
            }
        }
        
        return prefixString
    }
    
    private func getStringForPrintEntryPoint(entryPoint: NSPickablePrintEntryPoint<PickableType>,
        inout maxTitleLengthDict: [Int: Int],
        inout pendingStack: [NSPickablePrintEntryPoint<PickableType>],
        inout drawnStack: [NSPickablePrintEntryPoint<PickableType>],
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
        inout pendingStack: [NSPickablePrintEntryPoint<PickableType>],
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
            pendingStack.append(NSPickablePrintEntryPoint<PickableType>(nextEntryPointPickable, level))
        }
        
        // Generate string along the first child
        if let pickedAtNextLevel = _hierarchicalPickedPickables[level + 1],
            var childPickables = pickable.childPickables
        {
            if childPickables.count > 0 && pickedAtNextLevel.count > 0 {
                if let nextPickable = { () -> PickableType? in
                    var nextPickable: PickableType = childPickables.removeLast()
                    while !contains(pickedAtNextLevel, nextPickable) {
                        if childPickables.count > 0 {
                            nextPickable = childPickables.removeLast()
                        } else {
                            return nil
                        }
                    }
                    return nextPickable
                    }()
                {
                    titleString += (maxTitleLengthInLevel - count(pickableTitle)) * "-"
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