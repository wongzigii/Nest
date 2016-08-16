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
    internal private(set) var implSource: ObjCSelfAwareSwizzleImplSource
    
    @objc public var targetClass: AnyClass {
        switch implSource {
        case let .impl(targetClass, _, _, _):
            return targetClass
        case let .selector(targetClass, _, _):
            return targetClass
        }
    }
    
    @objc public var targetSelector: Selector {
        switch implSource {
        case let .impl(_, targetSelector, _, _):
            return targetSelector
        case let .selector(_, targetSelector, _):
            return targetSelector
        }
    }
    
    public let isMetaClass: Bool
    
    @nonobjc internal init(
        class: AnyClass,
        selector: Selector,
        originalPtr: UnsafeMutablePointer<IMP>,
        swizzled: IMP
        )
    {
        implSource = .impl(
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
        
        implSource = .selector(
            class: `class`,
            originalSelector: originalSelector,
            swizzledSelector: swizzledSelector
        )
        isMetaClass = class_isMetaClass(`class`)
        super.init()
    }
    
    public func perform(_ error: NSErrorPointer) -> Bool {
        var succeeded = false
        
        error?.pointee = NSError(
            domain: "com.WeZZard.Nest.ObjCSelfAwareSwizzle",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey
                    : "Duplicate performing of the same swizzle object: \(self.description)."
            ]
        )
        
        error?.pointee = nil
        
        switch implSource {
        case let .impl(
            targetClass,
            targetSelector,
            originalImplPtr,
            swizzledImpl
            ):
            
            let originalImpl = class_getMethodImplementation(
                targetClass,
                targetSelector
            )
            
            if originalImpl == nil {
                error?.pointee = NSError(
                    domain: "com.WeZZard.Nest.ObjCSelfAwareSwizzle",
                    code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey
                            : "Target class is nil: \(ObjCSelfAwareSwizzle.description)."
                    ]
                )
                break
            }
            
            originalImplPtr.pointee = originalImpl!
            
            let targetMethod = class_getInstanceMethod(
                targetClass,
                targetSelector
            )
            
            if targetMethod == nil {
                error?.pointee = NSError(
                    domain: "com.WeZZard.Nest.ObjCSelfAwareSwizzle",
                    code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey
                            : "The target class(\(targetClass)) or its superclasses do not contain an instance method with the specified selector: \(self.descriptionForSelector(targetSelector))."
                    ]
                )
                break
            }
            
            let encoding = method_getTypeEncoding(targetMethod);
            
            if encoding == nil {
                error?.pointee = NSError(
                    domain: "com.WeZZard.Nest.ObjCSelfAwareSwizzle",
                    code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey
                            : "Not type encoding for target method of selector: \(self.descriptionForSelector(targetSelector))."
                    ]
                )
                break
            }
            
            class_replaceMethod(
                targetClass,
                targetSelector,
                swizzledImpl,
                encoding
            )
            
            implSource = .impl(
                class: targetClass,
                selector: targetSelector,
                originalImplPointer: originalImplPtr,
                swizzledImpl: swizzledImpl
            )
            
            succeeded = true
            
        case let .selector(
            targetClass,
            originalSelector,
            swizzledSelector
            ):
            
            let originalMethod = class_getInstanceMethod(
                targetClass,
                originalSelector
            )
            
            if originalMethod == nil {
                error?.pointee = NSError(
                    domain: "com.WeZZard.Nest.ObjCSelfAwareSwizzle",
                    code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey
                            : "The target class(\(targetClass)) or its superclasses do not contain an instance method with the specified selector: \(self.descriptionForSelector(originalSelector))."
                    ]
                )
                break
            }
            
            let swizzledMethod = class_getInstanceMethod(
                targetClass,
                swizzledSelector
            )
            
            if swizzledMethod == nil {
                error?.pointee = NSError(
                    domain: "com.WeZZard.Nest.ObjCSelfAwareSwizzle",
                    code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey
                            : "The target class(\(targetClass)) or its superclasses do not contain an instance method with the specified selector: \(self.descriptionForSelector(swizzledSelector))."
                    ]
                )
                break
            }
            
            method_exchangeImplementations(originalMethod, swizzledMethod)
            
            succeeded = true
        }
        
        return succeeded
    }
    
    private func descriptionForSelector(_ selector: Selector) -> String {
        if isMetaClass {
            return "+\(selector)]"
        } else {
            return " -\(selector)]"
        }
    }
    
    public override var description: String {
        let objectAddress = Int(bitPattern: ObjectIdentifier(self))
        let prefix = "<\(type(of: self)): \(objectAddress); "
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
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let compared = object as? ObjCSelfAwareSwizzle {
            return targetClass === compared.targetClass
                && targetSelector == compared.targetSelector
                && isMetaClass == compared.isMetaClass
                && implSource == compared.implSource
        }
        return super.isEqual(object)
    }
}
