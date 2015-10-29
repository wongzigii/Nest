//
//  UICollectionViewLayoutAttributesCache.swift
//  Nest
//
//  Created by Manfred on 10/29/15.
//
//

import UIKit

public enum UICollectionViewLayoutAttributesUsage: Int {
    case InitialForAppearing
    case FinalForDisappearing
    case Layout
}

public class UICollectionViewLayoutAttributesForIndexPath {
    private var initialForAppearing =
    [NSIndexPath : UICollectionViewLayoutAttributes]()
    
    private var finalForDisappearing =
    [NSIndexPath : UICollectionViewLayoutAttributes]()
    
    private var permanent = [NSIndexPath : UICollectionViewLayoutAttributes]()
    
    public subscript(
        usage: UICollectionViewLayoutAttributesUsage,
        indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
        {
        get {
            switch usage {
            case .InitialForAppearing:
                return initialForAppearing[indexPath]
            case .FinalForDisappearing:
                return finalForDisappearing[indexPath]
            case .Layout:
                return permanent[indexPath]
            }
        }
        set {
            switch usage {
            case .InitialForAppearing:
                initialForAppearing[indexPath] = newValue
            case .FinalForDisappearing:
                finalForDisappearing[indexPath] = newValue
            case .Layout:
                permanent[indexPath] = newValue
            }
        }
    }
    
    public subscript(
        indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
        {
        get { return permanent[indexPath] }
        set { permanent[indexPath] = newValue }
    }
    
    public func removeAllTransient() {
        initialForAppearing.removeAll()
        finalForDisappearing.removeAll()
    }
    
    public func removeAllPermanent() {
        permanent.removeAll()
    }
    
    public func removeAll() {
        removeAllTransient()
        removeAllPermanent()
    }
}

public class UICollectionViewLayoutAttributesForIndexPathForKind {
    private(set) public var initialForAppearing =
    [String: [NSIndexPath : UICollectionViewLayoutAttributes]]()
    
    private(set) public var finalForDisappearing =
    [String: [NSIndexPath : UICollectionViewLayoutAttributes]]()
    
    private var permanent =
    [String: [NSIndexPath : UICollectionViewLayoutAttributes]]()
    
    public subscript(
        usage: UICollectionViewLayoutAttributesUsage,
        kind: String,
        indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
        {
        get {
            switch usage {
            case .InitialForAppearing:
                return initialForAppearing[kind]?[indexPath]
            case .FinalForDisappearing:
                return finalForDisappearing[kind]?[indexPath]
            case .Layout:
                return permanent[kind]?[indexPath]
            }
        }
        set {
            switch usage {
            case .InitialForAppearing:
                if var kindContainer = initialForAppearing[kind] {
                    kindContainer[indexPath] = newValue
                    initialForAppearing[kind] = kindContainer
                } else {
                    if let newValue = newValue {
                        initialForAppearing[kind] = [indexPath : newValue]
                    }
                }
            case .FinalForDisappearing:
                if var kindContainer = finalForDisappearing[kind] {
                    kindContainer[indexPath] = newValue
                    finalForDisappearing[kind] = kindContainer
                } else {
                    if let newValue = newValue {
                        finalForDisappearing[kind] = [indexPath : newValue]
                    }
                }
            case .Layout:
                if var kindContainer = permanent[kind] {
                    kindContainer[indexPath] = newValue
                    permanent[kind] = kindContainer
                } else {
                    if let newValue = newValue {
                        permanent[kind] = [indexPath : newValue]
                    }
                }
            }
        }
    }
    
    public subscript(
        kind: String, indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
        {
        get { return permanent[kind]?[indexPath] }
        set {
            if var kindContainer = permanent[kind] {
                kindContainer[indexPath] = newValue
                permanent[kind] = kindContainer
            } else {
                if let newValue = newValue {
                    permanent[kind] = [indexPath : newValue]
                }
            }
        }
    }
    
    public func removeAllTransient() {
        initialForAppearing.removeAll()
        finalForDisappearing.removeAll()
    }
    
    public func removeAllPermanent() {
        permanent.removeAll()
    }
    
    public func removeAll() {
        removeAllTransient()
        removeAllPermanent()
    }
}

public class UICollectionViewLayoutAttributesForCGRect {
    private var cached = [String : [UICollectionViewLayoutAttributes]]()
    
    public subscript(
        rect: CGRect)
        -> [UICollectionViewLayoutAttributes]?
        {
        get { return cached[NSStringFromCGRect(rect)] }
        set { cached[NSStringFromCGRect(rect)] = newValue }
    }
    
    public func removeAll() { cached.removeAll() }
}