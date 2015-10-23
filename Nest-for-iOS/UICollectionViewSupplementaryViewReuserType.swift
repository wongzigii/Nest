//
//  UICollectionViewSupplementaryViewReuserType.swift
//  Nest
//
//  Created by Manfred on 10/11/15.
//
//

import UIKit

public protocol UICollectionViewSupplementaryViewKindOfferType {
    typealias SupplementaryViewKind: HashableRawRepresentable
}

public protocol UICollectionViewSupplementaryViewReuserType {
    typealias SupplementaryViewKindOffer:
    UICollectionViewSupplementaryViewKindOfferType
    
    typealias SupplementaryViewReuseIdentifier: HashableRawRepresentable
    
    func reuseIdentifierForSupplementaryViewOfKind(kind: SupplementaryViewKind,
        atIndexPath indexPath: NSIndexPath)
        -> SupplementaryViewReuseIdentifier
    
    static var supplementaryViewReuseIdentifierToClassMap :
        [SupplementaryViewKindOffer.SupplementaryViewKind:
        [SupplementaryViewReuseIdentifier: UICollectionReusableView.Type]] {get}
}

extension UICollectionViewSupplementaryViewReuserType
    where SupplementaryViewKindOffer.SupplementaryViewKind.RawValue == String,
    SupplementaryViewReuseIdentifier.RawValue == String
{
    typealias SupplementaryViewKind =
        SupplementaryViewKindOffer.SupplementaryViewKind
    
    public func registerClass(viewClass: UICollectionReusableView.Type,
        forSupplementaryViewOfKind elementKind: SupplementaryViewKind,
        withReuseIdentifier identifier: SupplementaryViewReuseIdentifier,
        toCollectionView collectionView: UICollectionView)
    {
        collectionView.registerClass(viewClass,
            forSupplementaryViewOfKind: elementKind.rawValue,
            withReuseIdentifier: identifier.rawValue)
    }
    
    public func registerNib(nib: UINib?,
        forSupplementaryViewOfKind kind: SupplementaryViewKind,
        withReuseIdentifier identifier: SupplementaryViewReuseIdentifier,
        toCollectionView collectionView: UICollectionView)
    {
        collectionView.registerNib(nib,
            forSupplementaryViewOfKind: kind.rawValue,
            withReuseIdentifier: identifier.rawValue)
    }
    
    public func dequeueReusableSupplementaryViewOfKind(
        elementKind: SupplementaryViewKind,
        withReuseIdentifier identifier: SupplementaryViewReuseIdentifier,
        forIndexPath indexPath: NSIndexPath,
        fromCollectionView collectionView: UICollectionView)
        -> UICollectionReusableView
    {
        return collectionView.dequeueReusableSupplementaryViewOfKind(
            elementKind.rawValue,
            withReuseIdentifier: identifier.rawValue,
            forIndexPath: indexPath)
    }
    
    public func registerSupplementaryViewReuseInfoToCollectionView(
        collectionView: UICollectionView)
    {
        
        for (kind, reuseIdentifierClassMap) in
            self.dynamicType.supplementaryViewReuseIdentifierToClassMap
        {
            for (reuseIdentifier, aClass) in reuseIdentifierClassMap {
                registerClass(aClass,
                    forSupplementaryViewOfKind: kind,
                    withReuseIdentifier: reuseIdentifier,
                    toCollectionView: collectionView)
            }
        }
    }
}
