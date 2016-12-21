//
//  LegacyUtilities.m
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

#import "LegacyUtilities.h"

static NSString * kStringYes = @"YES";
static NSString * kStringNo = @"NO";

NSString * NSStringFromBOOL(BOOL booleanValue) {
    return booleanValue ? kStringYes : kStringNo;
}

NSRange NSRangeMake(NSUInteger location, NSUInteger length) {
    return NSMakeRange(location, length);
}
