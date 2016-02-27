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

/** Returns the version of `ObjCCodingBase` subclass. The default implementaiton
 always returns 0.
 
 - Discussion: With the default implementation, the decoding would be failed if
 the decoded version is different from the value got in this method and any 
 value migration was failed.
 */
+ (NSInteger)version;

/** Offers a lightweight migration mechanism. Returns `NO` by default.
 
 @param     value           The value to migrate.
 
 @param     key             The key of the value to migrate. Set to nil to make
    the decoding ommitted this value.
 
 @param     fromVersion     The old archived binary version.
 
 @param     toVersion       Current class version.
 
 @return    A flag indicates the migration succeeded or failed.
 */
+ (BOOL)migrateValue:(id _Nullable * _Nonnull)value
              forKey:(NSString * _Nullable * _Nonnull)key
                from:(NSInteger)fromVersion
                  to:(NSInteger)toVersion;

- (instancetype)init;

/** Returns a fallback value for a non-migration decoding a property named
 `key`. */
+ (id __nullable)defaultValueForKey:(NSString *)key;

/** Primitive methods give access to the generic dictionary storage from 
 subclasses that implement explicit accessors like -setName/-name to add custom 
 document logic.
 */
- (id __nullable)primitiveValueForKey:(NSString *)key;
- (void)setPrimitiveValue:(id __nullable)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
