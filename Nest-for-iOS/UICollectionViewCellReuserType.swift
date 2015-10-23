//
//  UICollectionViewCellReuserType.swift
//  Nest
//
//  Created by Manfred on 10/11/15.
//
//

import UIKit

public typealias HashableRawRepresentable = protocol<RawRepresentable, Hashable>

public protocol UICollectionViewCellReuserType {
    typealias CellReuseIdentifier: HashableRawRepresentable
    
    func reuseIdentifierForItemAtIndexPath(indexPath: NSIndexPath)
        -> CellReuseIdentifier
    
    static var cellReuseIdentifierToClassMap:
        [CellReuseIdentifier: UICollectionViewCell.Type] {get}
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
    
    public func registerCellReuseInfoToCollectionView(
        collectionView: UICollectionView)
    {
        for (reuseIdentifier, aClass) in
            self.dynamicType.cellReuseIdentifierToClassMap
        {
            registerClass(aClass,
                forCellReuseIdentifier: reuseIdentifier,
                toCollectionView: collectionView)
        }
    }
}
