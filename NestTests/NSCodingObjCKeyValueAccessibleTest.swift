//
//  NSCodingObjCKeyValueAccessibleTest.swift
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
    private typealias GestureRecognizer = UIGestureRecognizer
    private typealias GestureRecognizerDelegate = UIGestureRecognizerDelegate
#elseif os(OSX)
    private typealias View = NSView
    private typealias TextField = NSTextField
    private typealias GestureRecognizer = NSGestureRecognizer
    private typealias GestureRecognizerDelegate = NSGestureRecognizerDelegate
#endif

private class CustomView: View, ObjCKeyValueAccessible {
    struct Key: ObjCKeyValueAccessibleKeyType {
        typealias RawValue = String
        var rawValue: RawValue
        init(rawValue: RawValue) { self.rawValue = rawValue }
        
        static let outletEntity:   Key = "outletEntity"
        static let outletCollectionEntity:   Key = "outletCollectionEntity"
        static let scalarEntity:   Key = "scalarEntity"
        static let scalarGroupEntity:   Key = "scalarGroupEntity"
        static let implicitlyNSCodingConformedObject: Key =
        "implicitlyNSCodingConformedObject"
    }
    
    var outletEntity: TextField!
    var outletCollectionEntity: [TextField]!
    var implicitlyNSCodingConformedObject: GestureRecognizer!
    
    var scalarEntity: Int!
    var scalarGroupEntity: [Int]!
    
    private override init(frame: CGRect) {
        outletEntity = TextField(frame: frame)
        outletCollectionEntity = [TextField(frame: frame),
            TextField(frame: frame),
            TextField(frame: frame)]
        scalarEntity = 3
        scalarGroupEntity = [1, 9, 8, 4]
        implicitlyNSCodingConformedObject = GestureRecognizer()
        super.init(frame: frame)
        addSubview(outletEntity)
        for each in outletCollectionEntity { addSubview(each) }
    }
    
    private required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        outletEntity = decodeForKey(.outletEntity, from: aDecoder)
        outletCollectionEntity = decodeForKey(
            .outletCollectionEntity,
            from: aDecoder)
        scalarEntity = decodeForKey(.scalarEntity, from: aDecoder)
        scalarGroupEntity = decodeForKey(.scalarGroupEntity, from: aDecoder)
        implicitlyNSCodingConformedObject = decodeForKey(
            .implicitlyNSCodingConformedObject,
            from: aDecoder)
    }
    
    private override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        encode(outletEntity, forKey: .outletEntity, to: aCoder)
        encode(
            outletCollectionEntity,
            forKey: .outletCollectionEntity,
            to: aCoder)
        encode(scalarEntity, forKey: .scalarEntity, to: aCoder)
        encode(scalarGroupEntity, forKey: .scalarGroupEntity, to: aCoder)
        encode(
            implicitlyNSCodingConformedObject,
            forKey: .implicitlyNSCodingConformedObject,
            to: aCoder)
    }
}

class NSCodingObjCKeyValueAccessibleTest: XCTestCase,
    GestureRecognizerDelegate
{
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
        
        aCustomView.implicitlyNSCodingConformedObject.enabled = false
        
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
        
        XCTAssert(
            unarchivedCustomView.implicitlyNSCodingConformedObject.enabled
                == aCustomView.implicitlyNSCodingConformedObject.enabled,
            "Implicitly NSCoding conformed object encode and decode failed"
        )
        
    }
    
}
