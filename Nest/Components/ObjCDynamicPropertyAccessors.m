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

#pragma mark - id
@ObjCDynamicPropertyGetter(id, RETAIN) {
    id retVal = nil;
    @synchronized (self) {
        retVal = [self primitiveValueForKey:_prop];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(id, RETAIN) {
    @synchronized (self) {
        [self setPrimitiveValue:newValue forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(id, WEAK) {
    id retVal = nil;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] weakObjectValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(id, WEAK) {
    @synchronized (self) {
        [self setPrimitiveValue:[[ObjCDynamicPropertyWeakContainer alloc] initWithWeakObjectValue:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(id, COPY) {
    id retVal = nil;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] copy];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(id, COPY) {
    @synchronized (self) {
        [self setPrimitiveValue:[newValue copy] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(id, RETAIN, NONATOMIC) {
    return [self primitiveValueForKey:_prop];
};

@ObjCDynamicPropertySetter(id, RETAIN, NONATOMIC) {
    [self setPrimitiveValue:newValue forKey:_prop];
};

@ObjCDynamicPropertyGetter(id, WEAK, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] weakObjectValue];
};

@ObjCDynamicPropertySetter(id, WEAK, NONATOMIC) {
    [self setPrimitiveValue:[[ObjCDynamicPropertyWeakContainer alloc] initWithWeakObjectValue:newValue] forKey:_prop];
};

@ObjCDynamicPropertyGetter(id, COPY, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] copy];
};

@ObjCDynamicPropertySetter(id, COPY, NONATOMIC) {
    [self setPrimitiveValue:[newValue copy] forKey:_prop];
};

#pragma mark - SEL
@ObjCDynamicPropertyGetter(SEL) {
    SEL retVal = 0;
    @synchronized (self) {
        retVal = NSSelectorFromString([self primitiveValueForKey:_prop]);
    }
    return retVal;
};

@ObjCDynamicPropertySetter(SEL) {
    @synchronized (self) {
        [self setPrimitiveValue:NSStringFromSelector(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(SEL, NONATOMIC) {
    return NSSelectorFromString([self primitiveValueForKey:_prop]);
};

@ObjCDynamicPropertySetter(SEL, NONATOMIC) {
    [self setPrimitiveValue:NSStringFromSelector(newValue) forKey:_prop];
};

#pragma mark - void *
@ObjCDynamicPropertyGetter(void *) {
    void * retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] pointerValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(void *) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithPointer:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(void *, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] pointerValue];
};

@ObjCDynamicPropertySetter(void *, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithPointer:newValue] forKey:_prop];
};

#pragma mark - char
@ObjCDynamicPropertyGetter(char) {
    char retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] charValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(char) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(char, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] charValue];
};

@ObjCDynamicPropertySetter(char, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - int
@ObjCDynamicPropertyGetter(int) {
    int retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] intValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(int) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(int, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] intValue];
};

@ObjCDynamicPropertySetter(int, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - short
@ObjCDynamicPropertyGetter(short) {
    short retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] shortValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(short) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(short, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] shortValue];
};

@ObjCDynamicPropertySetter(short, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - long
#if !__LP64__
@ObjCDynamicPropertyGetter(long) {
    long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] longValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(long, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] longValue];
};

@ObjCDynamicPropertySetter(long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};
#endif

#pragma mark - long long
@ObjCDynamicPropertyGetter(long long) {
    long long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] longLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(long long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(long long, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] longLongValue];
};

@ObjCDynamicPropertySetter(long long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - unsigned char
@ObjCDynamicPropertyGetter(unsigned char) {
    unsigned char retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] unsignedCharValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned char) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(unsigned char, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] unsignedCharValue];
};

@ObjCDynamicPropertySetter(unsigned char, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - unsigned int
@ObjCDynamicPropertyGetter(unsigned int) {
    unsigned int retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] unsignedIntValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned int) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(unsigned int, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] unsignedIntValue];
};

@ObjCDynamicPropertySetter(unsigned int, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - unsigned short
@ObjCDynamicPropertyGetter(unsigned short) {
    unsigned short retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] unsignedShortValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned short) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(unsigned short, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] unsignedShortValue];
};

@ObjCDynamicPropertySetter(unsigned short, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - unsigned long
#if !__LP64__
@ObjCDynamicPropertyGetter(unsigned long) {
    unsigned long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] unsignedLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(unsigned long, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] unsignedLongValue];
};

@ObjCDynamicPropertySetter(unsigned long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};
#endif

#pragma mark - unsigned long long
@ObjCDynamicPropertyGetter(unsigned long long) {
    unsigned long long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] unsignedLongLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned long long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(unsigned long long, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] unsignedLongLongValue];
};

@ObjCDynamicPropertySetter(unsigned long long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - float
@ObjCDynamicPropertyGetter(float) {
    float retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] floatValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(float) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(float, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] floatValue];
};

@ObjCDynamicPropertySetter(float, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - double
@ObjCDynamicPropertyGetter(double) {
    double retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] doubleValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(double) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(double, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] doubleValue];
};

@ObjCDynamicPropertySetter(double, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - BOOL
#if __LP64__
@ObjCDynamicPropertyGetter(BOOL) {
    double retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] boolValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(BOOL) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(BOOL, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] boolValue];
};

@ObjCDynamicPropertySetter(BOOL, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};
#endif

#pragma mark - _Bool
@ObjCDynamicPropertyGetter(_Bool) {
    double retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] boolValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(_Bool) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(_Bool, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] boolValue];
};

@ObjCDynamicPropertySetter(_Bool, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_prop];
};

#pragma mark - NSRange
@ObjCDynamicPropertyGetter(NSRange) {
    NSRange retVal = {};
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_prop] rangeValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(NSRange) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithRange:newValue] forKey:_prop];
    }
};

@ObjCDynamicPropertyGetter(NSRange, NONATOMIC) {
    return [[self primitiveValueForKey:_prop] rangeValue];
};

@ObjCDynamicPropertySetter(NSRange, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithRange:newValue] forKey:_prop];
};

