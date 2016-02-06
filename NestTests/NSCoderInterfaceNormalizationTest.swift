//
//  NSCoderModernizationTest.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import XCTest
import Nest

#if os(iOS) || os(tvOS)
    private typealias View = UIView
    private typealias TextField = UITextField
#elseif os(OSX)
    private typealias View = NSView
    private typealias TextField = NSTextField
#endif

private class CustomView: View {
    let outletEntity: TextField
    let outletCollectionEntity: [TextField]
    
    var scalarEntity: Int
    var scalarGroupEntity: [Int]
    
    private override init(frame: CGRect) {
        outletEntity = TextField(frame: frame)
        outletCollectionEntity = [TextField(frame: frame),
            TextField(frame: frame),
            TextField(frame: frame)]
        scalarEntity = 3
        scalarGroupEntity = [1, 9, 8, 4]
        super.init(frame: frame)
        addSubview(outletEntity)
        for each in outletCollectionEntity { addSubview(each) }
    }
    
    private required init?(coder aDecoder: NSCoder) {
        outletEntity = aDecoder.decodeFor("outletEntity")!
        outletCollectionEntity = aDecoder.decodeFor("outletCollectionEntity")!
        scalarEntity = aDecoder.decodeFor("scalarEntity")!
        scalarGroupEntity = aDecoder.decodeFor("scalarGroupEntity")!
        super.init(coder: aDecoder)
    }
    
    private override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encode(outletEntity, for: "outletEntity")
        aCoder.encode(outletCollectionEntity, for: "outletCollectionEntity")
        aCoder.encode(scalarEntity, for: "scalarEntity")
        aCoder.encode(scalarGroupEntity, for: "scalarGroupEntity")
    }
}

class NSCoderModernizationTest: XCTestCase {
    func testEncodeAndDecode() {
        let customViewFrame = CGRect(origin: .zero,
            size: CGSize(width: 100, height: 100))
        let aCustomView = CustomView(frame: customViewFrame)
        
        let textFieldSampleText = "Sample Text"
        
        aCustomView.scalarEntity = 0
        
        aCustomView.scalarGroupEntity = [0]
        
        #if os(iOS) || os(tvOS)
            aCustomView.outletEntity.text = textFieldSampleText
            
            aCustomView.outletCollectionEntity.forEach
                {$0.text = textFieldSampleText}
        #elseif os(OSX)
            aCustomView.outletEntity.stringValue = textFieldSampleText
            
            aCustomView.outletCollectionEntity.forEach
                {$0.stringValue = textFieldSampleText}
        #endif
        
        let archivedCustomView = NSKeyedArchiver
            .archivedDataWithRootObject(aCustomView)
        
        let unarchivedCustomView = NSKeyedUnarchiver
            .unarchiveObjectWithData(archivedCustomView) as! CustomView
        
        XCTAssert(
            unarchivedCustomView.scalarEntity == 0,
            "Scalar entity encode and decode failed"
        )
        
        XCTAssert(
            unarchivedCustomView.scalarGroupEntity == [0],
            "Scalar group entity encode and decode failed"
        )
        
        #if os(iOS) || os(tvOS)
            XCTAssert(
                unarchivedCustomView.outletEntity.text == textFieldSampleText,
                "Outlet entity encode and decode failed"
            )
            
            XCTAssert(
                unarchivedCustomView.outletCollectionEntity.reduce(true)
                    { $0 && $1.text == textFieldSampleText },
                "Outlet collection entity encode and decode failed"
            )
        #elseif os(OSX)
            XCTAssert(
                unarchivedCustomView.outletEntity.stringValue
                    == textFieldSampleText,
                "Outlet entity encode and decode failed"
            )
            
            XCTAssert(
                unarchivedCustomView.outletCollectionEntity.reduce(true)
                    { $0 && $1.stringValue == textFieldSampleText },
                "Outlet collection entity encode and decode failed"
            )
        #endif
        
    }
    
}