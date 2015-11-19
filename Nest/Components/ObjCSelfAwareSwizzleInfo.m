//
//  ObjCSelfAwareSwizzleInfo.m
//  Nest
//
//  Created by Manfred on 11/18/15.
//
//

@import ObjectiveC;
@import Foundation;

#import "ObjCSelfAwareSwizzleInfo.h"

#import "SelfAwareSwizzleUtilities.h"

#pragma mark - ObjCSelfAwareSwizzleInfo
@implementation ObjCSelfAwareSwizzleInfo
- (instancetype)initWithTargetClass:(Class)targetClass
                           selector:(SEL)selector
             implementationExchange:(ImplementationExchange)implementationExchange
{
    self = [super init];
    if (self) {
        _targetClass = targetClass;
        _targetSelector = selector;
        _implementationExchange = implementationExchange;
    }
    return self;
}

+ (void)load {
    OCSASSwizzleAllPossibleProcessDelegates();
}
@end
