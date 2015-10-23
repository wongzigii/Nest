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
