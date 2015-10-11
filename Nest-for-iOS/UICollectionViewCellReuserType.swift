//
//  UICollectionViewCellReuserType.swift
//  Nest
//
//  Created by Manfred on 10/11/15.
//
//

import UIKit

public protocol UICollectionViewCellReuserType {
    typealias CellReuseIdentifier: RawRepresentable
}

extension UICollectionViewCellReuserType
    where CellReuseIdentifier.RawValue == String
{
    public func dequeueReusableCellWithIdentifier(
        identifier: CellReuseIdentifier,
        forIndexPath indexPath: NSIndexPath,
        fromCollectionView collectionView: UICollectionView)
        -> UICollectionViewCell
    {
        return collectionView.dequeueReusableCellWithReuseIdentifier(
            identifier.rawValue,
            forIndexPath: indexPath)
    }
    
    public func registerNib(nib: UINib?,
        forCellReuseIdentifier identifier: CellReuseIdentifier,
        toCollectionView collectionView: UICollectionView)
    {
        collectionView.registerNib(nib,
            forCellWithReuseIdentifier: identifier.rawValue)
    }
    
    public func registerClass(cellClass: UICollectionViewCell.Type,
        forCellReuseIdentifier identifier: CellReuseIdentifier,
        toCollectionView collectionView: UICollectionView)
    {
        collectionView.registerClass(cellClass,
            forCellWithReuseIdentifier: identifier.rawValue)
    }
}
