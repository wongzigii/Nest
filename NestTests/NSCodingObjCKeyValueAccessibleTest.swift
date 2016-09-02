//
//  NSCodingObjCKeyValueAccessibleTest.swift
//  Nest
//
//  Created by Manfred on 12/7/15.
//
//

import XCTest
import Nest

// FIXME: An unkown compiler bug causes a segmentation fault in SIL emitting.

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
    fileprivate struct Key: ObjCKeyValueAccessibleKeying {
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
    
    fileprivate var outletEntity: TextField!
    fileprivate var outletCollectionEntity: [TextField]!
    fileprivate var implicitlyNSCodingConformedObject: GestureRecognizer!
    
    fileprivate var scalarEntity: Int!
    fileprivate var scalarGroupEntity: [Int]!
    
    fileprivate override init(frame: CGRect) {
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
    
    fileprivate required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        do {
            outletEntity = try aDecoder.decodeOrThrowFor("outletEntity")
            outletCollectionEntity = try aDecoder.decodeOrThrowFor("outletCollectionEntity")
            scalarEntity = try aDecoder.decodeOrThrowFor("scalarEntity")
            scalarGroupEntity = try aDecoder.decodeOrThrowFor("scalarGroupEntity")
            implicitlyNSCodingConformedObject = try aDecoder.decodeOrThrowFor("implicitlyNSCodingConformedObject")
        } catch _ {
            return nil
        }
    }
    
    fileprivate override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        encode(outletEntity, to: aCoder, for: .outletEntity)
        encode(
            outletCollectionEntity,
            to: aCoder,
            for: .outletCollectionEntity)
        encode(scalarEntity, to: aCoder, for: .scalarEntity)
        encode(scalarGroupEntity, to: aCoder, for: .scalarGroupEntity)
        encode(
            implicitlyNSCodingConformedObject,
            to: aCoder,
            for: .implicitlyNSCodingConformedObject)
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
        
        aCustomView.implicitlyNSCodingConformedObject.isEnabled = false
        
        let archivedCustomView = NSKeyedArchiver
            .archivedData(withRootObject: aCustomView)
        
        let unarchivedCustomView = NSKeyedUnarchiver
            .unarchiveObject(with: archivedCustomView) as! CustomView
        
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
            unarchivedCustomView.implicitlyNSCodingConformedObject.isEnabled
                == aCustomView.implicitlyNSCodingConformedObject.isEnabled,
            "Implicitly NSCoding conformed object encode and decode failed"
        )
        
    }
    
}
