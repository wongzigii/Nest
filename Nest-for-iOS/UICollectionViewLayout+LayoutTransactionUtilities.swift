//
//  UICollectionViewLayout+LayoutTransactionUtilities.swift
//  Nest
//
//  Created by Manfred on 10/20/15.
//
//

import UIKit
import SwiftExt

public let UICollectionViewLayoutAttributesMergeEqualityComparator = {
    (attributes1: UICollectionViewLayoutAttributes,
        attributes2: UICollectionViewLayoutAttributes)
    -> Bool in
    
    return (attributes1.representedElementKind ==
        attributes2.representedElementKind)
        && attributes1.indexPath.compare(attributes2.indexPath) == .OrderedSame
}

public let UICollectionViewLayoutAttributesMergeAscendingComparator = {
    (attributes1: UICollectionViewLayoutAttributes,
    attributes2: UICollectionViewLayoutAttributes)
    -> Bool in
    
    switch (attributes1.representedElementCategory,
        attributes2.representedElementCategory) {
    case (.Cell, .Cell):
        return attributes1.indexPath.compare(attributes2.indexPath)
            == .OrderedAscending
    case (.SupplementaryView, .SupplementaryView):
        return attributes1.indexPath.compare(attributes2.indexPath)
            == .OrderedAscending
    case (.DecorationView, .DecorationView):
        return attributes1.indexPath.compare(attributes2.indexPath)
            == .OrderedAscending
    case (.Cell, .SupplementaryView):
        return true
    case (.Cell, .DecorationView):
        return true
    case (.SupplementaryView, .DecorationView):
        return true
    case (.SupplementaryView, .Cell):
        return false
    case (.DecorationView, .Cell):
        return false
    case (.DecorationView, .SupplementaryView):
        return false
    }
}
