//
//  LegacyUtilities.m
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

#import "LegacyUtilities.h"

static NSString * stringYes = @"YES";
static NSString * stringNo = @"NO";

NSString * NSStringFromBOOL(BOOL booleanValue) {
    return booleanValue ? stringYes : stringNo;
}
