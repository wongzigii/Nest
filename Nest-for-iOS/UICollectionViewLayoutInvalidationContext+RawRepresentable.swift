//
//  UICollectionViewLayoutInvalidationContext+RawRepresentable.swift
//  Nest
//
//  Created by Manfred on 10/19/15.
//
//

import UIKit

extension UICollectionViewLayoutInvalidationContext {
    @available(iOS 8.0, *)
    public func invalidateSupplementaryElementsOfKind
        <E: RawRepresentable where E.RawValue == String>
        (elementKind: E,
        atIndexPaths indexPaths: [NSIndexPath])
    {
        invalidateSupplementaryElementsOfKind(elementKind.rawValue,
            atIndexPaths: indexPaths)
    }
    
    @available(iOS 8.0, *)
    public func invalidateDecorationElementsOfKind
        <E: RawRepresentable where E.RawValue == String>
        (elementKind: E,
        atIndexPaths indexPaths: [NSIndexPath])
    {
        invalidateDecorationElementsOfKind(elementKind.rawValue,
            atIndexPaths: indexPaths)
    }
}