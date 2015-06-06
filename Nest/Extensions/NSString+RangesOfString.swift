//
//  NSString+RangesOfString.swift
//  Nest
//
//  Created by Manfred Lau on 1/4/15.
//  Copyright (c) 2015 WeZZard. All rights reserved.
//

import Foundation

extension NSString {
    /// Finds and returns the range of all the occurrences of a
    /// given string within a given range of the `String`, subject to
    /// given options, using the specified locale, if any.
    public func rangesOfString(aString: String, options mask: NSStringCompareOptions, range: NSRange?, locale: NSLocale?) -> [NSRange] {
        var ranges = [NSRange]()
        
        var workingRange = (range == nil ? NSRange(location: 0, length: self.length) : range!)
        
        while (workingRange.length > 0) {
            // workingRange.endIndex = aString.endIndex - workingRange.startIndex
            let aRange = self.rangeOfString(aString, options:mask, range:workingRange, locale: locale)
            if aRange.location != NSNotFound {
                // found an occurrence of the string! do stuff here
                ranges.append(aRange)
                
                let nextSearchStartLocation = (aRange.location + aRange.length)
                workingRange = NSRangeMake(nextSearchStartLocation, workingRange.length - nextSearchStartLocation)
            } else {
                // no more substring to find
                break;
            }
        }
        
        return ranges
    }
}