//
//  UICollectionViewSupplementaryViewReuserType.swift
//  Nest
//
//  Created by Manfred on 10/11/15.
//
//

import UIKit

public protocol UICollectionViewSupplementaryViewReuserType {
    typealias SupplementaryViewKind: RawRepresentable
    typealias SupplementaryViewReuseIdentifier: RawRepresentable
}

extension UICollectionViewSupplementaryViewReuserType
    where SupplementaryViewKind.RawValue == String,
    SupplementaryViewReuseIdentifier.RawValue == String
{
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
}
