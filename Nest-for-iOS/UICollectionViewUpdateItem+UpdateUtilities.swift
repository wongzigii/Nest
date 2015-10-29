//
//  UICollectionViewUpdateItem+UpdateUtilities.swift
//  Nest
//
//  Created by Manfred on 10/29/15.
//
//

import UIKit

extension UICollectionViewUpdateItem {
    public var _indexPathBeforeUpdate: NSIndexPath?
        { return indexPathBeforeUpdate }
    
    public var _indexPathAfterUpdate: NSIndexPath?
        { return indexPathAfterUpdate }
    
    public func isReversedUpdateItem(updateItem: UICollectionViewUpdateItem)
        -> Bool
    {
        switch (updateItem.updateAction,
            updateItem._indexPathBeforeUpdate,
            updateItem._indexPathAfterUpdate)
        {
        case let (.Insert, .Some(indexPath), nil):
            return self.updateAction == .Delete &&
                self._indexPathAfterUpdate?.section == indexPath.section &&
                self._indexPathAfterUpdate?.row == indexPath.row
        case let (.Delete, nil, .Some(indexPath)):
            return self.updateAction == .Insert &&
                self._indexPathBeforeUpdate?.section == indexPath.section &&
                self._indexPathBeforeUpdate?.row == indexPath.row
        case let (.Move, .Some(fromIndexPath), .Some(toIndexPath)):
            return self.updateAction == .Move &&
                self._indexPathBeforeUpdate?.section == toIndexPath.section &&
                self._indexPathBeforeUpdate?.row == toIndexPath.row &&
                self._indexPathAfterUpdate?.section == fromIndexPath.section &&
                self._indexPathAfterUpdate?.row == fromIndexPath.row
        default: return false
        }
    }
    
    public class func extractDimensionAlteringUpdateItems(
        updateItems: [UICollectionViewUpdateItem])
        -> [UICollectionViewUpdateItem]
    {
        let reference = updateItems
        
        var removed = [UICollectionViewUpdateItem]()
        
        for eachReference in reference {
            if eachReference.updateAction == .Reload {
                removed.append(eachReference)
            } else {
                for eachUpdateItem in updateItems {
                    if eachUpdateItem.isReversedUpdateItem(eachReference) {
                        removed.append(eachReference)
                        removed.append(eachUpdateItem)
                    }
                }
            }
        }
        
        var dimensionAlteringUpdateItems = [UICollectionViewUpdateItem]()
        for eachRemoved in removed {
            if let index = dimensionAlteringUpdateItems.indexOf(eachRemoved) {
                dimensionAlteringUpdateItems.removeAtIndex(index)
            }
        }
        return dimensionAlteringUpdateItems
    }
}