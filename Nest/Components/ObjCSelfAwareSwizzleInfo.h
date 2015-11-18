//
//  ObjCSelfAwareSwizzleInfo.h
//  Nest
//
//  Created by Manfred on 11/18/15.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef IMP _Nonnull (^ImplementationExchange) (IMP);

@interface ObjCSelfAwareSwizzleInfo : NSObject
@property (nonatomic, strong, readonly) Class targetClass;
@property (nonatomic, assign, readonly) SEL targetSelector;
@property (nonatomic, strong, readonly) ImplementationExchange implementationExchange;

- (instancetype)initWithTargetClass:(Class)targetClass
                           selector:(SEL)selector
             implementationExchange:(ImplementationExchange)implementationExchange;
@end

NS_ASSUME_NONNULL_END