//
//  NSObject+InitConveniences.swift
//  Nest
//
//  Created by Manfred Lau on 11/13/14.
//  Copyright (c) 2014 WeZZard. All rights reserved.
//

import SwiftExt
import CoreData

extension NSError {
    public convenience init(error: NSError?, anotherError: NSError?) {
        var userInfo = [NSObject: AnyObject]()
        var errors = [NSError]()
        
        if let secondError = anotherError {
            errors += secondError
        }
        
        if let firstError = error {
            if firstError.code == NSValidationMultipleErrorsError {
                userInfo += firstError.userInfo
                
                if let detailErrors = userInfo[NSDetailedErrorsKey] as? Array<NSError> {
                    errors += detailErrors
                }
            } else {
                errors += firstError
            }
        }
        
        userInfo[NSDetailedErrorsKey] = errors
        
        self.init(domain: NSCocoaErrorDomain, code: NSValidationMultipleErrorsError, userInfo: userInfo)
    }
    
    public convenience init(errorPointer: NSErrorPointer, secondError: NSError?) {
        var userInfo = [NSObject: AnyObject]()
        var errors = [NSError]()
        
        if let secondError = secondError {
            errors += secondError
        }
        
        if errorPointer.memory != nil {
            let firstError = errorPointer.memory!
            if firstError.code == NSValidationMultipleErrorsError {
                userInfo += firstError.userInfo
                
                if let detailErrors = userInfo[NSDetailedErrorsKey] as? Array<NSError> {
                    errors += detailErrors
                }
            } else {
                errors += firstError
            }
        }
        
        userInfo[NSDetailedErrorsKey] = errors
        
        self.init(domain: NSCocoaErrorDomain, code: NSValidationMultipleErrorsError, userInfo: userInfo)
    }
    
    public convenience init(errors: [NSError]) {
        var userInfo = [NSObject: AnyObject]()
        userInfo[NSDetailedErrorsKey] = errors
        self.init(domain: NSCocoaErrorDomain, code: NSValidationMultipleErrorsError, userInfo: userInfo)
    }
}