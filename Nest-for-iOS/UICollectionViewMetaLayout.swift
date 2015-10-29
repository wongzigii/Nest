//
//  UICollectionViewMetaLayout.swift
//  Nest
//
//  Created by Manfred on 10/29/15.
//
//

import UIKit
import CoreGraphicsExt

public enum UICollectionViewMetaLayoutCellIndexPathValidationError: ErrorType {
    case NoSuchSection(section: Int, sectionRange: Range<Int>)
    case SectionItemMapCorrupted(section: Int, sectionItemMap: [Int: Int])
    case NoSuchItem(section: Int, item: Int, itemRange: Range<Int>)
}

public protocol UICollectionViewLayoutSiblingTransitioning: NSObjectProtocol {
    var sourceLayout: UICollectionViewLayout? { get }
    var destinationLayout: UICollectionViewLayout? { get }
}

public protocol UICollectionViewLayoutAttributesSpecific {
    typealias LayoutAttributes: UICollectionViewLayoutAttributes
}

public protocol UICollectionViewLayoutInvalidationContextSpecific {
    typealias InvalidationContext: UICollectionViewLayoutInvalidationContext
}

public class UICollectionViewTransientLayoutAttributesUsage {
    public enum Initial: Int {
        case Insertion
        case AnimatedBoundsChange
        case TransitionIn
    }
    
    public enum Final: Int {
        case Deletion
        case AnimatedBoundsChange
        case TransitionOut
    }
}

public class UICollectionViewMetaLayout<A: UICollectionViewLayoutAttributes,
    C: UICollectionViewLayoutInvalidationContext>:
    UICollectionViewLayout,
    UICollectionViewLayoutSiblingTransitioning,
    UICollectionViewLayoutAttributesSpecific,
    UICollectionViewLayoutInvalidationContextSpecific
{
    public typealias LayoutAttributes = A
    public typealias InvalidationContext = C
    
    public let layoutAttributesForItem =
    UICollectionViewLayoutAttributesForIndexPath()
    
    public let layoutAttributesForSupplementary =
    UICollectionViewLayoutAttributesForIndexPathForKind()
    
    public let layoutAttributesForDecoration =
    UICollectionViewLayoutAttributesForIndexPathForKind()
    
    public let layoutAttributesForRect =
    UICollectionViewLayoutAttributesForCGRect()
    
    private(set) public var itemCount: Int = 0
    private(set) public var sectionCount: Int = 0
    private(set) public var sectionItemMap: [Int: Int] = [:]
    private(set) public var contentSize: CGSize = .zero
    
    override public func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    public override class func invalidationContextClass() -> AnyClass {
        return InvalidationContext.self
    }
    
    public override class func layoutAttributesClass() -> AnyClass {
        return LayoutAttributes.self
    }
    
    override public init() { super.init() }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
    }
    
    //MARK: Layout Attributes Creater
    public func createLayoutAttributesForCellWithIndexPath(
        indexPath: NSIndexPath)
        -> LayoutAttributes
    {
        let layoutAttributes = LayoutAttributes(
            forCellWithIndexPath: indexPath)
        return layoutAttributes
    }
    
    public func createLayoutAttributesForSupplementaryViewOfKind(kind: String,
        withIndexPath indexPath: NSIndexPath)
        -> LayoutAttributes
    {
        return LayoutAttributes(forSupplementaryViewOfKind: kind,
            withIndexPath: indexPath)
    }
    
    public func createLayoutAttributesForDecorationViewOfKind(kind: String,
        withIndexPath indexPath: NSIndexPath)
        -> LayoutAttributes
    {
        return LayoutAttributes(forDecorationViewOfKind: kind,
            withIndexPath: indexPath)
    }
    
    //MARK: Preparation and Invalidation
    private(set) public var isLayoutPrepared: Bool = false
    
    public override func prepareLayout() {
        super.prepareLayout()
        
        if !isLayoutPrepared {
            (itemCount, sectionCount, sectionItemMap)
                = calculateDataSourceCount()
            contentSize = calculateContentSizeWithItemCount(itemCount,
                sectionCount: sectionCount,
                sectionItemMap: sectionItemMap)
            isLayoutPrepared = true
        }
    }
    
    override public func invalidationContextForBoundsChange(newBounds: CGRect)
        -> UICollectionViewLayoutInvalidationContext
    {
        let context = super.invalidationContextForBoundsChange(newBounds)
        
        if newBounds.size != collectionView?.bounds.size {
            let oldContentSize = contentSize
            let newContentSize = calculateContentSizeWithItemCount(itemCount,
                sectionCount: sectionCount,
                sectionItemMap: sectionItemMap)
            
            let contentSizeDelta = newContentSize - oldContentSize
            
            context.contentSizeAdjustment = contentSizeDelta
        }
        
        return context
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect)
        -> Bool
    {
        let context = invalidationContextForBoundsChange(newBounds)
        invalidateLayoutWithContext(context)
        return newBounds.size != collectionView?.bounds.size
    }
    
    override public func invalidateLayoutWithContext(
        context: UICollectionViewLayoutInvalidationContext)
    {
        layoutAttributesForRect.removeAll()
        
        if context.invalidateDataSourceCounts || context.invalidateEverything {
            (itemCount, sectionCount, sectionItemMap)
                = calculateDataSourceCount()
            contentSize = calculateContentSizeWithItemCount(itemCount,
                sectionCount: sectionCount,
                sectionItemMap: sectionItemMap)
            
            layoutAttributesForItem.removeAll()
            layoutAttributesForSupplementary.removeAll()
            layoutAttributesForDecoration.removeAll()
        } else {
            if let invalidatedItemIndexPaths =
                context.invalidatedItemIndexPaths
            {
                for each in invalidatedItemIndexPaths {
                    layoutAttributesForItem[each] = nil
                }
            }
            
            if let invalidatedSupplementaryIndexPaths =
                context.invalidatedSupplementaryIndexPaths
            {
                for (eachKind, indexPaths) in
                    invalidatedSupplementaryIndexPaths
                {
                    for eachIndexPath in indexPaths {
                        layoutAttributesForSupplementary[eachKind,
                            eachIndexPath] = nil
                    }
                }
            }
            
            if let invalidatedDecorationIndexPaths =
                context.invalidatedDecorationIndexPaths
            {
                for (eachKind, indexPaths) in
                    invalidatedDecorationIndexPaths
                {
                    for eachIndexPath in indexPaths {
                        layoutAttributesForDecoration[eachKind,
                            eachIndexPath] = nil
                    }
                }
            }
            
            guard let collectionView = self.collectionView else {
                fatalError("Collection view not found!")
            }
            
            // Handle content size adjustment
            let adjustedSize = contentSize + context.contentSizeAdjustment
            contentSize = CGSize(width: collectionView.bounds.width,
                height: max(adjustedSize.height, collectionView.bounds.height))
        }
        
        super.invalidateLayoutWithContext(context)
    }
    
    public override func invalidateLayout() {
        isLayoutPrepared = false
        
        layoutAttributesForRect.removeAll()
        layoutAttributesForItem.removeAll()
        layoutAttributesForSupplementary.removeAll()
        layoutAttributesForDecoration.removeAll()
        
        super.invalidateLayout()
    }
    
    //MARK: Layout Cycle
    public override func layoutAttributesForElementsInRect(rect: CGRect)
        -> [UICollectionViewLayoutAttributes]?
    {
        if let cached = layoutAttributesForRect[rect] {
            return cached
        } else {
            let layoutAttributesForElementsInRect =
            calculateLayoutAttributesForElementsInRect(rect)
            
            layoutAttributesForRect[rect] = layoutAttributesForElementsInRect
            
            return layoutAttributesForElementsInRect
        }
    }
    
    //MARK: Layout Attributes for Cell
    override public func
        layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
//        print("\(self): Getting layout attributes for item at index path: \(indexPath)")
        do {
            try validateCellIndexPath(indexPath)
            
            if let cached = layoutAttributesForItem[indexPath] {
                return cached
            } else {
                let layoutAttributes =
                calculateLayoutAttributesForItemAtIndexPath(indexPath)
                
                layoutAttributesForItem[indexPath] = layoutAttributes
                
                return layoutAttributes
            }
            
        } catch let UICollectionViewMetaLayoutCellIndexPathValidationError
            .NoSuchSection(section,
            sectionRange)
        {
            assertionFailure("No such section(\(section)). Range of section: \(sectionRange)")
        } catch let UICollectionViewMetaLayoutCellIndexPathValidationError
            .NoSuchItem(section,
            item,
            itemRange)
        {
            assertionFailure("No such item(\(item)) in section(\(section)). Range of item: \(itemRange)")
        } catch let UICollectionViewMetaLayoutCellIndexPathValidationError
            .SectionItemMapCorrupted(section,
            sectionItemMap)
        {
            assertionFailure("Section item map corrupted. Section: \(section). Section Item Map: \(sectionItemMap)")
        } catch _ {
            
        }
        
        return nil
    }
    
    override public func initialLayoutAttributesForAppearingItemAtIndexPath(
        itemIndexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
//        print("\(self): Getting initial layout attributes for appearing item at index path: \(itemIndexPath)")
        if let cached
            = layoutAttributesForItem[.InitialForAppearing, itemIndexPath]
        {
            return cached
        }
        return nil
    }
    
    override public func finalLayoutAttributesForDisappearingItemAtIndexPath(
        itemIndexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
//        print("\(self): Getting final layout attributes for disappearing item at index path: \(itemIndexPath)")
        if let cached
            = layoutAttributesForItem[.FinalForDisappearing, itemIndexPath]
        {
            return cached
        }
        return nil
    }
    
    //MARK: Layout Attributes for Supplementary View
    
    override public func layoutAttributesForSupplementaryViewOfKind(
        elementKind: String,
        atIndexPath indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        if let cached = layoutAttributesForSupplementary[elementKind,
            indexPath]
        {
            return cached
        } else {
            let layoutAttributes =
            calculateLayoutAttributesForSupplementaryViewOfKind(elementKind,
                atIndexPath: indexPath)
            
            layoutAttributesForSupplementary[elementKind, indexPath]
                = layoutAttributes
            
            return layoutAttributes
        }
    }
    
    override public func
        initialLayoutAttributesForAppearingSupplementaryElementOfKind(
        elementKind: String,
        atIndexPath elementIndexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        if let cached
            = layoutAttributesForSupplementary[.InitialForAppearing,
                elementKind, elementIndexPath]
        {
            return cached
        }
        return nil
    }
    
    override public func
        finalLayoutAttributesForDisappearingSupplementaryElementOfKind
        (elementKind: String,
        atIndexPath elementIndexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        if let cached
            = layoutAttributesForSupplementary[.FinalForDisappearing,
                elementKind, elementIndexPath]
        {
            return cached
        }
        return nil
    }
    
    //MARK: Layout Update
    override public func prepareForCollectionViewUpdates(
        updateItems: [UICollectionViewUpdateItem])
    {
        super.prepareForCollectionViewUpdates(updateItems)
        
        for each in updateItems {
            switch (each.updateAction,
                each._indexPathBeforeUpdate,
                each._indexPathAfterUpdate)
            {
            case let (.Insert, .Some(indexPath), nil):
                let initialLayoutAttributes =
                calculateInitialLayoutAttributesForAppearingItemAtIndexPath(
                    indexPath,
                    forUsage: .Insertion)
                layoutAttributesForItem[.InitialForAppearing, indexPath] =
                initialLayoutAttributes
            case let (.Delete, nil, .Some(indexPath)):
                let finalLayoutAttributes =
                calculateFinalLayoutAttributesForDisappearingItemAtIndexPath(
                    indexPath,
                    forUsage: .Deletion)
                layoutAttributesForItem[.FinalForDisappearing, indexPath] =
                finalLayoutAttributes
            default: break
            }
        }
    }
    
    override public func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        layoutAttributesForItem.removeAllTransient()
    }
    
    //MARK: Layout-to-Layout Transition
    
    override public func prepareForTransitionFromLayout(
        oldLayout: UICollectionViewLayout)
    {
        super.prepareForTransitionFromLayout(oldLayout)
        
        sourceLayout = oldLayout
        if let siblingTransitioningOldLayout = oldLayout
            as? UICollectionViewLayoutSiblingTransitioning
        {
            siblingTransitioningOldLayout.destinationLayout = self
        }
        
        guard let collectionView = self.collectionView else {
            fatalError("Collection view is expected here!")
        }
        
        let currentBounds = collectionView.bounds
        
        guard let new = layoutAttributesForElementsInRect(currentBounds) else {
            fatalError("Cannot fetch new layout attributes")
        }
        
        for each in new {
            let indexPath = each.indexPath
            let category = each.representedElementCategory
            let kind = each.representedElementKind
            switch (category, kind) {
            case (.Cell, nil):
                let initialLayoutAttributes = oldLayout
                    .layoutAttributesForItemAtIndexPath(indexPath) ??
                    layoutAttributesForItemAtIndexPath(indexPath)
//                    calculateInitialLayoutAttributesForAppearingItemAtIndexPath(
//                        indexPath,
//                        forUsage: .TransitionIn)
                
                layoutAttributesForItem[.InitialForAppearing, indexPath]
                    = initialLayoutAttributes
                
            case let (.SupplementaryView, .Some(kind)):
                let initialLayoutAttributes = oldLayout
                    .layoutAttributesForSupplementaryViewOfKind(kind,
                        atIndexPath: indexPath) ??
                    layoutAttributesForSupplementaryViewOfKind(kind,
                        atIndexPath: indexPath)
//                    calculateInitialLayoutAttributesForAppearingSupplementaryViewOfKind(kind,
//                        atIndexPath: indexPath,
//                        forUsage: .TransitionIn)
                
                layoutAttributesForSupplementary[.InitialForAppearing,
                    kind, indexPath] = initialLayoutAttributes
            case let (.DecorationView, .Some(kind)):
                let initialLayoutAttributes = oldLayout
                    .layoutAttributesForDecorationViewOfKind(kind,
                        atIndexPath: indexPath) ??
                    layoutAttributesForDecorationViewOfKind(kind,
                        atIndexPath: indexPath)
//                    calculateInitialLayoutAttributesForAppearingDecorationViewOfKind(kind,
//                        atIndexPath: indexPath,
//                        forUsage: .TransitionIn)
                
                layoutAttributesForDecoration[.InitialForAppearing,
                    kind, indexPath] = initialLayoutAttributes
            default:
                break
            }
        }
    }
    
    override public func prepareForTransitionToLayout(
        newLayout: UICollectionViewLayout)
    {
        super.prepareForTransitionToLayout(newLayout)
        
        destinationLayout = newLayout
        if let siblingTransitioningNewLayout = newLayout
            as? UICollectionViewLayoutSiblingTransitioning
        {
            siblingTransitioningNewLayout.sourceLayout = self
        }
        
        guard let collectionView = self.collectionView else {
            fatalError("Collection view is expected here!")
        }
        
        let currentBounds = collectionView.bounds
        
        guard let
            old = layoutAttributesForElementsInRect(currentBounds)
            else
        {
            fatalError("Cannot fetch old or new layout attributes")
        }
        
        for each in old {
            let indexPath = each.indexPath
            let category = each.representedElementCategory
            let kind = each.representedElementKind
            switch (category, kind) {
            case (.Cell, nil):
                let finalLayoutAttributes = newLayout
                    .layoutAttributesForItemAtIndexPath(indexPath) ??
                    layoutAttributesForItemAtIndexPath(indexPath)
//                    calculateFinalLayoutAttributesForDisappearingItemAtIndexPath(
//                        indexPath,
//                        forUsage: .TransitionOut)
                
                layoutAttributesForItem[.FinalForDisappearing, indexPath]
                    = finalLayoutAttributes
                
            case let (.SupplementaryView, .Some(kind)):
                let finalLayoutAttributes = newLayout
                    .layoutAttributesForSupplementaryViewOfKind(kind,
                        atIndexPath: indexPath) ??
                    layoutAttributesForSupplementaryViewOfKind(kind,
                        atIndexPath: indexPath)
//                    calculateFinalLayoutAttributesForDisappearingSupplementaryViewOfKind(kind,
//                        atIndexPath: indexPath,
//                        forUsage: .TransitionOut)
                
                layoutAttributesForSupplementary[.FinalForDisappearing,
                    kind, indexPath] = finalLayoutAttributes
                
            case let (.DecorationView, .Some(kind)):
                let finalLayoutAttributes = newLayout
                    .layoutAttributesForDecorationViewOfKind(kind,
                        atIndexPath: indexPath) ??
                    layoutAttributesForDecorationViewOfKind(kind,
                        atIndexPath: indexPath)
//                    calculateFinalLayoutAttributesForDisappearingDecorationViewOfKind(kind,
//                        atIndexPath: indexPath,
//                        forUsage: .TransitionOut)
                
                layoutAttributesForDecoration[.FinalForDisappearing,
                    kind, indexPath] = finalLayoutAttributes
            default:
                break
            }
        }
    }
    
    override public func finalizeLayoutTransition() {
        super.finalizeLayoutTransition()
        
        layoutAttributesForItem.removeAllTransient()
        layoutAttributesForSupplementary.removeAllTransient()
        layoutAttributesForDecoration.removeAllTransient()
    }
    
    //MARK: Animated Bounds Change
    
    override public func prepareForAnimatedBoundsChange(oldBounds: CGRect) {
        super.prepareForAnimatedBoundsChange(oldBounds)
    }
    
    override public func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
    }
    
    //MARK: Calculation Utilities
    
    public func calculateLayoutAttributesForElementsInRect(rect: CGRect)
        -> [UICollectionViewLayoutAttributes]
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func calculateLayoutAttributesForItemAtIndexPath(
        indexPath: NSIndexPath)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func calculateInitialLayoutAttributesForAppearingItemAtIndexPath(
        indexPath: NSIndexPath,
        forUsage usage: UICollectionViewTransientLayoutAttributesUsage.Initial)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func calculateFinalLayoutAttributesForDisappearingItemAtIndexPath(
        indexPath: NSIndexPath,
        forUsage usage: UICollectionViewTransientLayoutAttributesUsage.Final)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func calculateLayoutAttributesForSupplementaryViewOfKind(
        kind: String,
        atIndexPath indexPath: NSIndexPath)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func
        calculateInitialLayoutAttributesForAppearingSupplementaryViewOfKind(
        kind: String,
        atIndexPath indexPath: NSIndexPath,
        forUsage usage: UICollectionViewTransientLayoutAttributesUsage.Initial)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func
        calculateFinalLayoutAttributesForDisappearingSupplementaryViewOfKind(
        kind: String,
        atIndexPath indexPath: NSIndexPath,
        forUsage usage: UICollectionViewTransientLayoutAttributesUsage.Final)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func calculateLayoutAttributesForDecorationViewOfKind(kind: String,
        atIndexPath indexPath: NSIndexPath)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func
        calculateInitialLayoutAttributesForAppearingDecorationViewOfKind(
        kind: String,
        atIndexPath indexPath: NSIndexPath,
        forUsage usage: UICollectionViewTransientLayoutAttributesUsage.Initial)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func
        calculateFinalLayoutAttributesForDisappearingDecorationViewOfKind(
        kind: String,
        atIndexPath indexPath: NSIndexPath,
        forUsage usage: UICollectionViewTransientLayoutAttributesUsage.Final)
        -> LayoutAttributes
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    public func calculateContentSizeWithItemCount(itemCount: Int,
        sectionCount: Int,
        sectionItemMap: [Int: Int])
        -> CGSize
    {
        fatalError("\(self)You should not use this abstract class directly")
    }
    
    private func calculateDataSourceCount()
        -> (itemCount: Int, sectionCount: Int, sectionItemMap: [Int: Int])
    {
        guard let collectionView = self.collectionView else {
            fatalError("Collection view not found!")
        }
        
        let numberOfSections = collectionView.numberOfSections()
        
        var numberOfItems = 0
        
        var sectionItemMap = [Int: Int]()
        for section in 0..<numberOfSections {
            let itemsInSection = collectionView.numberOfItemsInSection(section)
            sectionItemMap[section] = itemsInSection
            numberOfItems += itemsInSection
        }
        
        return (numberOfItems, numberOfSections, sectionItemMap)
    }
    
    //MARK: Validation Utilities
    
    private func validateCellIndexPath(indexPath: NSIndexPath) throws {
        prepareLayout()
        
        let section = indexPath.section
        let item = indexPath.item
        
        let sectionRange = 0..<1
        if !sectionRange.contains(section) {
            throw UICollectionViewMetaLayoutCellIndexPathValidationError
                .NoSuchSection(section: section,
                sectionRange: sectionRange)
        }
        
        guard let itemCountInSection = sectionItemMap[section] else {
            throw UICollectionViewMetaLayoutCellIndexPathValidationError
                .SectionItemMapCorrupted(
                section: section,
                sectionItemMap: sectionItemMap)
        }
        
        let itemRange = 0..<itemCountInSection
        if !itemRange.contains(item) {
            throw UICollectionViewMetaLayoutCellIndexPathValidationError
                .NoSuchItem(section: section,
                item: item,
                itemRange: itemRange)
        }
    }
}

private var sourceLayoutKey = "sourceLayoutKey"
private var destinationLayoutKey = "destinationLayoutKey"
extension UICollectionViewLayoutSiblingTransitioning {
    private(set) public weak var sourceLayout: UICollectionViewLayout? {
        get {
            return objc_getAssociatedObject(self, &sourceLayoutKey)
                as? UICollectionViewLayout
        }
        set {
            objc_setAssociatedObject(self,
                &sourceLayoutKey,
                newValue,
                .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    private(set) public weak var destinationLayout: UICollectionViewLayout? {
        get {
            return objc_getAssociatedObject(self, &destinationLayoutKey)
                as? UICollectionViewLayout
        }
        set {
            objc_setAssociatedObject(self,
                &destinationLayoutKey,
                newValue,
                .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}