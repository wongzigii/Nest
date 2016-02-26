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

+ (id __nullable)defaultValueForKey:(NSString *)key;

// primitive methods give access to the generic dictionary storage from subclasses that implement explicit accessors like -setName/-name to add custom document logic
- (id __nullable)primitiveValueForKey:(NSString *)key;
- (void)setPrimitiveValue:(id __nullable)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
