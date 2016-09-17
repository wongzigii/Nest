//
//  ObjCKeyValueStoreSubclass.h
//  Nest
//
//  Created by Manfred on 9/15/16.
//
//

@import Foundation;

#import <Nest/Nest.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjCKeyValueStore (Subclass)
@property (nonatomic, readonly, strong) NSMutableDictionary<NSString *, id> * internalStorage;
@end

NS_ASSUME_NONNULL_END
