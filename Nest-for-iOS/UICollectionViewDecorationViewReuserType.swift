//
//  UICollectionViewDecorationViewReuserType.swift
//  Nest
//
//  Created by Manfred on 10/11/15.
//
//

import UIKit

public protocol UICollectionViewDecorationViewKindOfferType {
    typealias DecorationViewKind: HashableRawRepresentable
}

extension UICollectionViewDecorationViewKindOfferType
    where Self: UICollectionViewLayoutAttributesSpecific,
    Self.DecorationViewKind.RawValue == String
{
    public func createLayoutAttributesForDecorationViewOfKind(
        kind: DecorationViewKind,
        withIndexPath indexPath: NSIndexPath)
        -> LayoutAttributes
    {
        return LayoutAttributes(
            forDecorationViewOfKind: kind.rawValue,
            withIndexPath: indexPath)
    }
}

extension UICollectionViewDecorationViewKindOfferType
    where Self: UICollectionViewLayout,
    Self.DecorationViewKind.RawValue == String
{
    public func layoutAttributesForDecorationViewOfKind(
        elementKind: DecorationViewKind,
        atIndexPath indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        return layoutAttributesForDecorationViewOfKind(elementKind.rawValue,
            atIndexPath: indexPath)
    }
    
    public func initialLayoutAttributesForAppearingDecorationElementOfKind(
        elementKind: DecorationViewKind,
        atIndexPath elementIndexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        return initialLayoutAttributesForAppearingDecorationElementOfKind(
            elementKind.rawValue,
            atIndexPath: elementIndexPath)
    }
    
    public func finalLayoutAttributesForDisappearingDecorationElementOfKind(
        elementKind: DecorationViewKind,
        atIndexPath elementIndexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        return finalLayoutAttributesForDisappearingDecorationElementOfKind(
            elementKind.rawValue,
            atIndexPath: elementIndexPath)
    }
}

extension UICollectionViewDecorationViewKindOfferType
    where Self: UICollectionViewLayoutInvalidationContextSpecific,
    Self.DecorationViewKind.RawValue == String
{
    @available(iOS 8.0, *)
    public func invalidateDecorationElementsOfKind
        (elementKind: DecorationViewKind,
        atIndexPaths indexPaths: [NSIndexPath],
        withContext context: InvalidationContext)
    {
        context.invalidateDecorationElementsOfKind(elementKind.rawValue,
            atIndexPaths: indexPaths)
    }
}

public protocol UICollectionViewDecorationViewReuserType {
    typealias DecorationViewKindOffer:
    UICollectionViewDecorationViewKindOfferType
    
    static var decorationViewKindToClassMap :
        [DecorationViewKindOffer.DecorationViewKind:
        UICollectionReusableView.Type] {get}
}

extension UICollectionViewDecorationViewReuserType
    where DecorationViewKindOffer.DecorationViewKind.RawValue == String
{
    typealias DecorationViewKind =
        DecorationViewKindOffer.DecorationViewKind
    
    public func registerClass(viewClass: UICollectionReusableView.Type,
        forDecorationViewOfKind elementKind: DecorationViewKind,
        toCollectionViewLayout collectionViewLayout: UICollectionViewLayout)
    {
        collectionViewLayout.registerClass(viewClass,
            forDecorationViewOfKind: elementKind.rawValue)
    }
    
    public func registerNib(nib: UINib?,
        forDecorationViewOfKind kind: DecorationViewKind,
        toCollectionViewLayout collectionViewLayout: UICollectionViewLayout)
    {
        collectionViewLayout.registerNib(nib,
            forDecorationViewOfKind: kind.rawValue)
    }
    
    public func registerDecorationViewReuseInfoToCollectionView(
        collectionViewLayout: UICollectionViewLayout)
    {
        
        for (kind, aClass) in self.dynamicType.decorationViewKindToClassMap {
            registerClass(aClass,
                forDecorationViewOfKind: kind,
                toCollectionViewLayout: collectionViewLayout)
        }
    }
}