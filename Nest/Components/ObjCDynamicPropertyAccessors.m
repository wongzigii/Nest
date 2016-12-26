//
//  ObjCDynamicPropertyAccessors.mm
//  Nest
//
//  Created by Manfred on 25/12/2016.
//
//

#import <Nest/ObjCDynamicPropertySynthesizer.h>
#import <Nest/ObjCDynamicPropertySynthesizing.h>

@interface ObjCDynamicPropertyWeakContainer: NSObject
@property (nonatomic, weak) id weakObjectValue;
- (instancetype)initWithWeakObjectValue:(id)objectValue;
@end

@implementation ObjCDynamicPropertyWeakContainer: NSObject
- (instancetype)initWithWeakObjectValue:(id)objectValue {
    self = [super init];
    if (self) {
        _weakObjectValue = objectValue;
    }
    return self;
}
@end

#pragma mark - Getters
// For id
@ObjCDynamicPropertyGetter(id, RETAIN) {
    id retVal = nil;
    @synchronized (self) {
        retVal = [self primitiveValueForKey:_key];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(id, WEAK) {
    id retVal = nil;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] weakObjectValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(id, COPY) {
    id retVal = nil;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] copy];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(id, RETAIN, NONATOMIC) {
    return [self primitiveValueForKey:_key];
};

@ObjCDynamicPropertyGetter(id, WEAK, NONATOMIC) {
    return [[self primitiveValueForKey:_key] weakObjectValue];
};

@ObjCDynamicPropertyGetter(id, COPY, NONATOMIC) {
    return [[self primitiveValueForKey:_key] copy];
};

// For integers
@ObjCDynamicPropertyGetter(char) {
    char retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] charValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(char, NONATOMIC) {
    return [[self primitiveValueForKey:_key] charValue];
};

@ObjCDynamicPropertyGetter(int) {
    int retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] intValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(int, NONATOMIC) {
    return [[self primitiveValueForKey:_key] intValue];
};

@ObjCDynamicPropertyGetter(short) {
    short retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] shortValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(short, NONATOMIC) {
    return [[self primitiveValueForKey:_key] shortValue];
};

#if !__LP64__
@ObjCDynamicPropertyGetter(long) {
    long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] longValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(long, NONATOMIC) {
    return [[self primitiveValueForKey:_key] longValue];
};
#endif

@ObjCDynamicPropertyGetter(long long) {
    long long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] longLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(long long, NONATOMIC) {
    return [[self primitiveValueForKey:_key] longLongValue];
};

// For unsigned integers
@ObjCDynamicPropertyGetter(unsigned char) {
    unsigned char retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedCharValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(unsigned char, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedCharValue];
};

@ObjCDynamicPropertyGetter(unsigned int) {
    unsigned int retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedIntValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(unsigned int, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedIntValue];
};

@ObjCDynamicPropertyGetter(unsigned short) {
    unsigned short retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedShortValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(unsigned short, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedShortValue];
};

#if !__LP64__
@ObjCDynamicPropertyGetter(unsigned long) {
    unsigned long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(unsigned long, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedLongValue];
};
#endif

@ObjCDynamicPropertyGetter(unsigned long long) {
    unsigned long long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedLongLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(unsigned long long, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedLongLongValue];
};

// For floating point
@ObjCDynamicPropertyGetter(float) {
    float retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] floatValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(float, NONATOMIC) {
    return [[self primitiveValueForKey:_key] floatValue];
};

@ObjCDynamicPropertyGetter(double) {
    double retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] doubleValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(double, NONATOMIC) {
    return [[self primitiveValueForKey:_key] doubleValue];
};

// For BOOL
@ObjCDynamicPropertyGetter(BOOL) {
    double retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] boolValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(BOOL, NONATOMIC) {
    return [[self primitiveValueForKey:_key] boolValue];
};

// For NSRange
@ObjCDynamicPropertyGetter(NSRange) {
    NSRange retVal = {};
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] rangeValue];
    }
    return retVal;
};

@ObjCDynamicPropertyGetter(NSRange, NONATOMIC) {
    return [[self primitiveValueForKey:_key] rangeValue];
};

#pragma mark - Setters
// For id
@ObjCDynamicPropertySetter(id, RETAIN) {
    @synchronized (self) {
        [self setPrimitiveValue:newValue forKey:_key];
    }
};

@ObjCDynamicPropertySetter(id, WEAK) {
    @synchronized (self) {
        [self setPrimitiveValue:[[ObjCDynamicPropertyWeakContainer alloc] initWithWeakObjectValue:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertySetter(id, COPY) {
    @synchronized (self) {
        [self setPrimitiveValue:[newValue copy] forKey:_key];
    }
};

@ObjCDynamicPropertySetter(id, RETAIN, NONATOMIC) {
    [self setPrimitiveValue:newValue forKey:_key];
};

@ObjCDynamicPropertySetter(id, WEAK, NONATOMIC) {
    [self setPrimitiveValue:[[ObjCDynamicPropertyWeakContainer alloc] initWithWeakObjectValue:newValue] forKey:_key];
};

@ObjCDynamicPropertySetter(id, COPY, NONATOMIC) {
    [self setPrimitiveValue:[newValue copy] forKey:_key];
};

// For integers
@ObjCDynamicPropertySetter(char) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(char, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

@ObjCDynamicPropertySetter(int) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(int, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

@ObjCDynamicPropertySetter(short) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(short, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

@ObjCDynamicPropertySetter(long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#if !__LP64__
@ObjCDynamicPropertySetter(long long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(long long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};
#endif

// For unsigned integers
@ObjCDynamicPropertySetter(unsigned char) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(unsigned char, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

@ObjCDynamicPropertySetter(unsigned int) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(unsigned int, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

@ObjCDynamicPropertySetter(unsigned short) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(unsigned short, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#if !__LP64__
@ObjCDynamicPropertySetter(unsigned long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(unsigned long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};
#endif

@ObjCDynamicPropertySetter(unsigned long long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(unsigned long long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

// For floating point
@ObjCDynamicPropertySetter(float) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(float, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

@ObjCDynamicPropertySetter(double) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(double, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

// For BOOL
@ObjCDynamicPropertySetter(BOOL) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertySetter(BOOL, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

// For NSRange
@ObjCDynamicPropertySetter(NSRange) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithRange:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertySetter(NSRange, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithRange:newValue] forKey:_key];
};
