//
//  NSCollectionViewSupplementaryViewReuserType.swift
//  Nest
//
//  Created by Manfred on 10/11/15.
//
//

import Cocoa

//MARK: - NSCollectionViewSupplementaryViewReusingType
@available(OSX 10.11, *)
public protocol NSCollectionViewSupplementaryViewReuserType: NSObjectProtocol {
    typealias SupplementaryViewReuseIdentifier: RawRepresentable
    typealias SupplementaryViewKind: RawRepresentable
}

@available(OSXApplicationExtension 10.11, *)
extension NSCollectionViewSupplementaryViewReuserType where
    SupplementaryViewKind.RawValue == String,
    SupplementaryViewReuseIdentifier.RawValue == String
{
    /** For each supplementary view identifier that the collection view will
    use, register either a nib or class from which to instantiate a view, or
    provide a nib file or class whose name matches the identifier you plan to
    use.  If a nib is registered, it must contain exactly one top-level view,
    that conforms to the NSCollectionViewElement protocol.  If a class is
    registered instead of a nib, it will be instantiated via
    alloc/initWithFrame:.
    */
    @available(OSX 10.11, *)
    public func registerClass
        (viewClass: AnyClass?,
        forSupplementaryViewOfKind kind: SupplementaryViewKind,
        withIdentifier identifier: SupplementaryViewReuseIdentifier,
        toCollectionView collectionView: NSCollectionView)
    {
        collectionView.registerClass(viewClass,
            forSupplementaryViewOfKind: kind.rawValue,
            withIdentifier: identifier.rawValue)
    }
    
    @available(OSX 10.11, *)
    public func registerNib
        (nib: NSNib?,
        forSupplementaryViewOfKind kind: SupplementaryViewKind,
        withIdentifier identifier: SupplementaryViewReuseIdentifier,
        toCollectionView collectionView: NSCollectionView)
    {
        collectionView.registerNib(nib,
            forSupplementaryViewOfKind: kind.rawValue,
            withIdentifier: identifier.rawValue)
    }
    
    /** Call this method from your data source object when asked to provide a
    new supplementary view for the collection view.  This method dequeues an
    existing view if one is available or creates a new one based on the nib file
    or class you previously registered.  If you have not registered a nib file
    or class for the given identifier, CollectionView will try to load a nib
    file named identifier.nib, or (failing that) find and instantiate an NSView
    subclass named "identifier".
    
    If a new view must be created from a class, this method initializes the view
    by invoking its -initWithFrame: method. For nib-based views, this method
    loads the view from the provided nib file.  If an existing view was
    available for reuse, this method invokes the view's -prepareForReuse method
    instead.
    */
    @available(OSX 10.11, *)
    public func makeSupplementaryViewOfKind
        (elementKind: SupplementaryViewKind,
        withIdentifier identifier: SupplementaryViewReuseIdentifier,
        forIndexPath indexPath: NSIndexPath,
        byCollectionView collectionView: NSCollectionView)
        -> NSView
    {
        return collectionView.makeSupplementaryViewOfKind(elementKind.rawValue,
            withIdentifier: identifier.rawValue,
            forIndexPath: indexPath)
    }
}