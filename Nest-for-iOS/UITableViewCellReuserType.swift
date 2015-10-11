//
//  UITableViewCellReuserType.swift
//  Nest
//
//  Created by Manfred on 10/11/15.
//
//

import UIKit

public protocol UITableViewCellReuserType {
    typealias CellReuseIdentifier: RawRepresentable
}

extension UITableViewCellReuserType
    where CellReuseIdentifier.RawValue == String
{
    /// Used by the delegate to acquire an already allocated cell, in lieu of 
    /// allocating a new one.
    public func dequeueReusableCellWithIdentifier(
        identifier: CellReuseIdentifier,
        fromTableView tableView: UITableView)
        -> UITableViewCell?
    {
        return tableView.dequeueReusableCellWithIdentifier(identifier.rawValue)
    }
    
    /// newer dequeue method guarantees a cell is returned and resized properly, 
    /// assuming identifier is registered
    @available(iOS 6.0, *)
    public func dequeueReusableCellWithIdentifier(
        identifier: CellReuseIdentifier,
        forIndexPath indexPath: NSIndexPath,
        fromTableView tableView: UITableView)
        -> UITableViewCell
    {
        return tableView.dequeueReusableCellWithIdentifier(identifier.rawValue,
            forIndexPath: indexPath)
    }
    
    /// Beginning in iOS 6, clients can register a nib or class for each cell.
    /// If all reuse identifiers are registered, use the newer
    /// -dequeueReusableCellWithIdentifier:forIndexPath: to guarantee that a 
    /// cell instance is returned.
    /// Instances returned from the new dequeue method will also be properly 
    /// sized when they are returned.
    @available(iOS 5.0, *)
    public func registerNib(nib: UINib?,
        forCellReuseIdentifier identifier: CellReuseIdentifier,
        toTableView tableView: UITableView)
    {
        tableView.registerNib(nib,
            forCellReuseIdentifier: identifier.rawValue)
    }
    
    @available(iOS 6.0, *)
    public func registerClass(cellClass: UITableViewCell.Type,
        forCellReuseIdentifier identifier: CellReuseIdentifier,
        toTableView tableView: UITableView)
    {
        tableView.registerClass(cellClass,
            forCellReuseIdentifier: identifier.rawValue)
    }
}
