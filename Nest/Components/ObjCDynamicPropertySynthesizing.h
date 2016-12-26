//
//  ObjCDynamicPropertySynthesizing.h
//  Nest
//
//  Created by Manfred on 24/12/2016.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ObjCDynamicPropertySynthesizing <NSObject>
- (void)setPrimitiveValue:(nullable id)primitiveValue forKey:(NSString *)key;
- (nullable id)primitiveValueForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
