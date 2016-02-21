//
//  ObjCSelfAwareSwizzle.swift
//  Nest
//
//  Created by Manfred on 2/21/16.
//
//

import Foundation
import ObjectiveC

@objc
final public class ObjCSelfAwareSwizzle: NSObject {
    internal private(set) var source: ObjCSelfAwareSwizzleSource
    
    @objc public var targetClass: AnyClass {
        switch source {
        case let .Implementation(targetClass, _, _, _):
            return targetClass
        case let .Selector(targetClass, _, _):
            return targetClass
        }
    }
    
    @objc public var targetSelector: Selector {
        switch source {
        case let .Implementation(_, targetSelector, _, _):
            return targetSelector
        case let .Selector(_, targetSelector, _):
            return targetSelector
        }
    }
    
    public let isMetaClass: Bool
    
    private var onceToken: dispatch_once_t = 0
    
    @nonobjc internal init(
        `class`: AnyClass,
        selector: Selector,
        originalPtr: UnsafeMutablePointer<IMP>,
        swizzled: IMP
        )
    {
        source = .Implementation(
            class: `class`,
            selector: selector,
            originalImplPointer: originalPtr,
            swizzledImpl: swizzled
        )
        isMetaClass = class_isMetaClass(`class`)
        super.init()
    }
    
    @nonobjc internal init(
        class: AnyClass,
        originalSelector: Selector,
        swizzledSelector: Selector
        )
    {
        assert(
            originalSelector != swizzledSelector,
            "Selector to swizzle(\(originalSelector)) shall not be same to the swizzling selector(\(swizzledSelector))."
        )
        
        source = .Selector(
            class: `class`,
            originalSelector: originalSelector,
            swizzledSelector: swizzledSelector
        )
        isMetaClass = class_isMetaClass(`class`)
        super.init()
    }
    
    public func perform(error: NSErrorPointer) -> Bool {
        var succeeded = false
        
        error.memory = NSError(
            domain: "com.WeZZard.Nest.ObjCSelfAwareSwizzle",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey
                    : "Duplicate performing of swizzle: \(self.description)."
            ]
        )
        
        dispatch_once(&onceToken) { () -> Void in
            error.memory = nil
            
            switch self.source {
            case let .Implementation(
                targetClass,
                targetSelector,
                originalImplPtr,
                swizzledImpl
                ):
                
                let originalImpl = class_getMethodImplementation(
                    targetClass,
                    targetSelector
                )
                
                originalImplPtr.memory = originalImpl
                
                let targetMethod = class_getInstanceMethod(
                    targetClass,
                    targetSelector
                )
                
                let encoding = method_getTypeEncoding(targetMethod);
                
                class_replaceMethod(
                    targetClass,
                    targetSelector,
                    swizzledImpl,
                    encoding
                )
                
                self.source = .Implementation(
                    class: targetClass,
                    selector: targetSelector,
                    originalImplPointer: originalImplPtr,
                    swizzledImpl: swizzledImpl
                )
                
            case let .Selector(
                targetClass, 
                originalSelector, 
                swizzledSelector
                ):
                
                let originalMethod = class_getInstanceMethod(
                    targetClass,
                    originalSelector
                )
                
                let swizzledMethod = class_getInstanceMethod(
                    targetClass,
                    swizzledSelector
                )
                
                method_exchangeImplementations(originalMethod, swizzledMethod)
                
                break
            }
            
            
            succeeded = true
        }
        /*
         
         */
        return succeeded
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
        if let compared = object as? ObjCSelfAwareSwizzle {
            return targetClass === compared.targetClass
                && targetSelector == compared.targetSelector
                && isMetaClass == compared.isMetaClass
                && source == compared.source
        }
        return super.isEqual(object)
    }
}
