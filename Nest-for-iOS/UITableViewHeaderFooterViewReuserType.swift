//
//  UITableViewHeaderFooterViewReuserType.swift
//  Nest
//
//  Created by Manfred on 10/11/15.
//
//

import UIKit

public protocol UITableViewHeaderFooterViewReuserType {
    typealias HeaderFooterViewReuseIdentifier: RawRepresentable
}

extension UITableViewHeaderFooterViewReuserType
    where HeaderFooterViewReuseIdentifier.RawValue == String
{
    /// like dequeueReusableCellWithIdentifier:, but for headers/footers
    public func dequeueReusableHeaderFooterViewWithIdentifier(
        identifier: HeaderFooterViewReuseIdentifier,
        fromTableView tableView: UITableView)
        -> UITableViewHeaderFooterView?
    {
        return tableView.dequeueReusableHeaderFooterViewWithIdentifier(
            identifier.rawValue)
    }
    
    @available(iOS 6.0, *)
    public func registerNib(nib: UINib?,
        forHeaderFooterViewReuseIdentifier
        identifier: HeaderFooterViewReuseIdentifier,
        toTableView tableView: UITableView)
    {
        tableView.registerNib(nib,
            forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
    
    @available(iOS 6.0, *)
    public func registerClass(aClass: UITableViewHeaderFooterView.Type,
        forHeaderFooterViewReuseIdentifier
        identifier: HeaderFooterViewReuseIdentifier,
        toTableView tableView: UITableView)
    {
        tableView.registerClass(aClass,
            forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
}