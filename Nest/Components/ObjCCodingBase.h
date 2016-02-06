//
//  ObjCCodingBase.h
//  Nest
//
//  Created by Manfred on 2/5/16.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface ObjCCodingBase : NSObject<NSCoding>
- (instancetype)init;
+ (id _Nullable)defaultValueForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
