//
//  UIView+PrintViewHierarchy.swift
//  Nest
//
//  Created by Manfred on 10/21/15.
//
//

import UIKit

extension UIView {
    private var viewDepth: Int {
        return (superview?.viewDepth ?? -1) + 1
    }
    
    public var viewHierarchy: String {
        var indent = ""
        let depth = viewDepth
        
        for _ in 0..<depth {
            indent = indent.stringByAppendingString("    ");
        }
        
        var viewHierarchy = "\n\(indent)\(description)"
        
        for each in subviews {
            viewHierarchy = viewHierarchy.stringByAppendingString(each.viewHierarchy)
        }
        
        return viewHierarchy
    }
}
