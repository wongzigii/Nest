//
//  ObjCDynamicCoder.h
//  Nest
//
//  Created by Manfred on 26/12/2016.
//
//

#import <Nest/ObjCDynamicObject.h>

/// `ObjCDynamicCoder` understands how to encode and decode its @dynamic
/// properties.
@interface ObjCDynamicCoder : ObjCDynamicObject<NSCoding>

@end
