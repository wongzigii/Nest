//
//  NSTextField+SubsequentSetupInitializers.swift
//  Nest
//
//  Created by Manfred on 10/6/15.
//
//

import Cocoa

extension NSTextField {
    public convenience init(
        subsequentSetup: (theTextField: NSTextField) -> Void)
    {
        self.init()
        subsequentSetup(theTextField: self)
    }
    
    public convenience init(frame frameRect: NSRect,
        subsequentSetup: (theTextField: NSTextField) -> Void)
    {
        self.init(frame: frameRect)
        subsequentSetup(theTextField: self)
    }
}

extension NSView {
    public convenience init(frame frameRect: NSRect,
        subsequentSetup: (theView: NSView) -> Void)
    {
        self.init(frame: frameRect)
        subsequentSetup(theView: self)
    }
}

extension NSTableView {
    public convenience init(frame frameRect: NSRect,
        subsequentSetup: (theTableView: NSTableView) -> Void)
    {
        self.init(frame: frameRect)
        subsequentSetup(theTableView: self)
    }
}

extension NSTableColumn {
    public convenience init(identifier: String,
        subsequentSetup: (theTableColumn: NSTableColumn) -> Void)
    {
        self.init(identifier: identifier)
        subsequentSetup(theTableColumn: self)
    }
    
    public convenience init
        <I: RawRepresentable where I.RawValue == String>
        (identifier: I,
        subsequentSetup: (theTableColumn: NSTableColumn) -> Void)
    {
        self.init(identifier: identifier.rawValue)
        subsequentSetup(theTableColumn: self)
    }
}

extension NSWindow {
    public convenience init(contentRect: NSRect,
        styleMask aStyle: Int,
        backing bufferingType: NSBackingStoreType,
        `defer` flag: Bool,
        subsequentSetup: (theWindow: NSWindow) -> Void)
    {
        self.init(contentRect: contentRect,
            styleMask: aStyle,
            backing: bufferingType,
            `defer`: flag)
        subsequentSetup(theWindow: self)
    }
    
    public convenience init(contentRect: NSRect,
        styleMask aStyle: Int,
        backing bufferingType: NSBackingStoreType,
        `defer` flag: Bool,
        screen: NSScreen?,
        subsequentSetup: (theWindow: NSWindow) -> Void)
    {
        self.init(contentRect: contentRect,
            styleMask: aStyle,
            backing: bufferingType,
            `defer`: flag,
            screen: screen)
        subsequentSetup(theWindow: self)
    }
}
