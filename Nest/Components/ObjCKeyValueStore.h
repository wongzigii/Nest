//
//  ObjCKeyValueStore.h
//  Nest
//
//  Created by Manfred on 3/3/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjCKeyValueStore : NSObject<NSCopying>
/** Primitive methods give access to the internal storage to implement 
 explicit accessors like -setName:/-name.
 */
- (id __nullable)primitiveValueForKey:(NSString *)key;
- (void)setPrimitiveValue:(id __nullable)value forKey:(NSString *)key;

- (instancetype)init;

- (void)setValue:(nullable id)value forKey:(NSString *)key;

- (id)valueForKey:(NSString *)key;

+ (BOOL)resolveInstanceMethod:(SEL)sel;
@end

NS_ASSUME_NONNULL_END
