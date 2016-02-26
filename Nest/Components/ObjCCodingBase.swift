//
//  ObjCCodingBase.swift
//  Nest
//
//  Created by Manfred on 2/26/16.
//
//

import Foundation

public class ObjCCodingBase: NSObject, NSCoding {
    private var internalStorage: NSMutableDictionary
    
    
    public override init() {
        internalStorage = NSMutableDictionary()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        internalStorage = NSMutableDictionary()
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
    }
}
