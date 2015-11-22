//
//  ObjCSelfAwareSwizzle.swift
//  Nest
//
//  Created by Manfred on 11/22/15.
//
//

import Foundation
import ObjectiveC

public typealias ObjCSelfAwareSwizzling = (IMP) -> IMP

public func withObjCSelfAwareSwizzleContext<F>(
    forClassMethodSelector aSelector: Selector,
    onClass aClass: AnyClass,
    original: UnsafeMutablePointer<F>,
    swizzled: F)
    -> ObjCSelfAwareSwizzleContext
{
    let className = class_getName(aClass)
    let metaClass = objc_getMetaClass(className)
    return withObjCSelfAwareSwizzleContext(forInstanceMethodSelector: aSelector,
        onClass: metaClass as! AnyClass,
        original: original,
        swizzled: swizzled)
}

public func withObjCSelfAwareSwizzleContext<F>(
    forInstanceMethodSelector aSelector: Selector,
    onClass aClass: AnyClass,
    original originalPtr:  UnsafeMutablePointer<F>,
    swizzled: F)
    -> ObjCSelfAwareSwizzleContext
{
    return ObjCSelfAwareSwizzleContext(targetClass: aClass,
        targetSelector: aSelector,
        isMetaClass: class_isMetaClass(aClass),
        originalPtr: unsafeBitCast(originalPtr, UnsafeMutablePointer<IMP>.self),
        swizzled: unsafeBitCast(swizzled, IMP.self))
}

@objc
final public class ObjCSelfAwareSwizzleContext: NSObject {
    public let targetClass: AnyClass
    public let targetSelector: Selector
    public let isMetaClass: Bool
    private let originalPtr: UnsafePointer<IMP>
    private let swizzled: IMP
    private var onceToken: dispatch_once_t = 0
    
    private init(targetClass: AnyClass,
        targetSelector: Selector,
        isMetaClass: Bool,
        originalPtr: UnsafeMutablePointer<IMP>,
        swizzled: IMP)
    {
        self.targetClass = targetClass
        self.targetSelector = targetSelector
        self.isMetaClass = isMetaClass
        self.originalPtr = UnsafePointer<IMP>(originalPtr)
        self.swizzled = swizzled
        super.init()
    }
    
    public func perform(original: IMP) -> IMP {
        var swizzled: IMP = nil
        dispatch_once(&onceToken) { () -> Void in
            let mutableOriginalPtr = UnsafeMutablePointer<IMP>(self.originalPtr)
            mutableOriginalPtr.memory = original
            swizzled = self.swizzled
        }
        return swizzled
    }
    
    public override var description: String {
        let objectAddress = unsafeAddressOf(self)
        let prefix = "<\(self.dynamicType): \(objectAddress); "
        let contextInfo: String = {
            if isMetaClass {
                return "[\(targetClass) "
                    + "+\(targetSelector)]"
            } else {
                return "[\(targetClass)"
                    + " -\(targetSelector)]"
            }
        }()
        return prefix + contextInfo + ">"
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let compared = object as? ObjCSelfAwareSwizzleContext {
            return targetClass === compared.targetClass
                && targetSelector == compared.targetSelector
                && isMetaClass == compared.isMetaClass
                && swizzled == compared.swizzled
        }
        return super.isEqual(object)
    }
}

