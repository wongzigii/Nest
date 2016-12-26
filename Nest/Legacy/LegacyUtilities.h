//
//  LegacyUtilities.h
//  Nest
//
//  Created by Manfred on 2/25/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * NSStringFromBOOL(BOOL booleanValue)
NS_SWIFT_UNAVAILABLE("Use string interpolation or the description property of a Bool value instead.");

FOUNDATION_EXPORT NSRange NSRangeMake(NSUInteger location, NSUInteger length)
NS_SWIFT_UNAVAILABLE("Use NSRange(location: Int, length: Int) instead.");

FOUNDATION_EXPORT BOOL NSRangeEqualToRange(NSRange range1, NSRange range2)
NS_SWIFT_UNAVAILABLE("Use == instead.");

NS_ASSUME_NONNULL_END
