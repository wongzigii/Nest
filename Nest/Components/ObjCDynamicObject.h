//
//  ObjCDynamicObject.h
//  Nest
//
//  Created by Manfred on 26/12/2016.
//
//

#import <Foundation/Foundation.h>
#import <Nest/ObjCDynamicPropertySynthesizing.h>

NS_ASSUME_NONNULL_BEGIN

/// `ObjCDynamicObject` automatically synthesizes all the @dynamic properties.
@interface ObjCDynamicObject : NSObject<
    ObjCDynamicPropertySynthesizing
>

@end

NS_ASSUME_NONNULL_END
