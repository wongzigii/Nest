//
//  NSString+RangesOfString.swift
//  Nest
//
//  Created by Manfred Lau on 1/4/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Foundation

extension NSString {
    /** 
    Finds and returns the range of all the occurrences of the given string 
    within the given range, which subject to given options, and using the
    specified locale.
    */
    public func rangesOfString(_ aString: String,
        options mask: NSString.CompareOptions,
        range: NSRange?,
        locale: Locale?) -> [NSRange]
    {
        var ranges = [NSRange]()
        
        var workingRange = (range == nil ?
            NSRange(location: 0, length: self.length) : range!
        )
        
        while (workingRange.length > 0) {
            // workingRange.endIndex = aString.endIndex - workingRange.startIndex
            let aRange = self.range(of: aString,
                options:mask,
                range:workingRange,
                locale: locale)
            
            if aRange.location != NSNotFound {
                // found an occurrence of the string! do stuff here
                ranges.append(aRange)
                
                let nextSearchStartLocation = (aRange.location +
                    aRange.length)
                
                workingRange = NSRange(
                    location: nextSearchStartLocation,
                    length: workingRange.length - nextSearchStartLocation)
            } else {
                // no more substring to find
                break;
            }
        }
        
        return ranges
    }
}
