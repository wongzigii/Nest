//
//  UIViewController+PrintViewHierarchy.swift
//  Nest
//
//  Created by Manfred on 10/21/15.
//
//

import UIKit

extension UIViewController {
    public var viewHierarchy: String? {
        if isViewLoaded() {
            return view.viewHierarchy
        }
        return nil
    }
}
