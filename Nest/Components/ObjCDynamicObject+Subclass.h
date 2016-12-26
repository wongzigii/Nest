//
//  ObjCDynamicObject+Subclass.h
//  Nest
//
//  Created by Manfred on 26/12/2016.
//
//

#import <Nest/ObjCDynamicObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjCDynamicObject (Subclass)
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSString *, id> * internalStorage;
@end

NS_ASSUME_NONNULL_END
