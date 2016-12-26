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
        retVal = [self primitiveValueForKey:_key];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(id, RETAIN) {
    @synchronized (self) {
        [self setPrimitiveValue:newValue forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(id, WEAK) {
    id retVal = nil;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] weakObjectValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(id, WEAK) {
    @synchronized (self) {
        [self setPrimitiveValue:[[ObjCDynamicPropertyWeakContainer alloc] initWithWeakObjectValue:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(id, COPY) {
    id retVal = nil;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] copy];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(id, COPY) {
    @synchronized (self) {
        [self setPrimitiveValue:[newValue copy] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(id, RETAIN, NONATOMIC) {
    return [self primitiveValueForKey:_key];
};

@ObjCDynamicPropertySetter(id, RETAIN, NONATOMIC) {
    [self setPrimitiveValue:newValue forKey:_key];
};

@ObjCDynamicPropertyGetter(id, WEAK, NONATOMIC) {
    return [[self primitiveValueForKey:_key] weakObjectValue];
};

@ObjCDynamicPropertySetter(id, WEAK, NONATOMIC) {
    [self setPrimitiveValue:[[ObjCDynamicPropertyWeakContainer alloc] initWithWeakObjectValue:newValue] forKey:_key];
};

@ObjCDynamicPropertyGetter(id, COPY, NONATOMIC) {
    return [[self primitiveValueForKey:_key] copy];
};

@ObjCDynamicPropertySetter(id, COPY, NONATOMIC) {
    [self setPrimitiveValue:[newValue copy] forKey:_key];
};

#pragma mark - SEL
@ObjCDynamicPropertyGetter(SEL) {
    SEL retVal = 0;
    @synchronized (self) {
        retVal = NSSelectorFromString([self primitiveValueForKey:_key]);
    }
    return retVal;
};

@ObjCDynamicPropertySetter(SEL) {
    @synchronized (self) {
        [self setPrimitiveValue:NSStringFromSelector(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(SEL, NONATOMIC) {
    return NSSelectorFromString([self primitiveValueForKey:_key]);
};

@ObjCDynamicPropertySetter(SEL, NONATOMIC) {
    [self setPrimitiveValue:NSStringFromSelector(newValue) forKey:_key];
};

#pragma mark - void *
@ObjCDynamicPropertyGetter(void *) {
    void * retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] pointerValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(void *) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithPointer:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(void *, NONATOMIC) {
    return [[self primitiveValueForKey:_key] pointerValue];
};

@ObjCDynamicPropertySetter(void *, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithPointer:newValue] forKey:_key];
};

#pragma mark - char
@ObjCDynamicPropertyGetter(char) {
    char retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] charValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(char) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(char, NONATOMIC) {
    return [[self primitiveValueForKey:_key] charValue];
};

@ObjCDynamicPropertySetter(char, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - int
@ObjCDynamicPropertyGetter(int) {
    int retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] intValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(int) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(int, NONATOMIC) {
    return [[self primitiveValueForKey:_key] intValue];
};

@ObjCDynamicPropertySetter(int, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - short
@ObjCDynamicPropertyGetter(short) {
    short retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] shortValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(short) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(short, NONATOMIC) {
    return [[self primitiveValueForKey:_key] shortValue];
};

@ObjCDynamicPropertySetter(short, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - long
#if !__LP64__
@ObjCDynamicPropertyGetter(long) {
    long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] longValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(long, NONATOMIC) {
    return [[self primitiveValueForKey:_key] longValue];
};

@ObjCDynamicPropertySetter(long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};
#endif

#pragma mark - long long
@ObjCDynamicPropertyGetter(long long) {
    long long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] longLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(long long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(long long, NONATOMIC) {
    return [[self primitiveValueForKey:_key] longLongValue];
};

@ObjCDynamicPropertySetter(long long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - unsigned char
@ObjCDynamicPropertyGetter(unsigned char) {
    unsigned char retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedCharValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned char) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(unsigned char, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedCharValue];
};

@ObjCDynamicPropertySetter(unsigned char, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - unsigned int
@ObjCDynamicPropertyGetter(unsigned int) {
    unsigned int retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedIntValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned int) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(unsigned int, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedIntValue];
};

@ObjCDynamicPropertySetter(unsigned int, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - unsigned short
@ObjCDynamicPropertyGetter(unsigned short) {
    unsigned short retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedShortValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned short) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(unsigned short, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedShortValue];
};

@ObjCDynamicPropertySetter(unsigned short, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - unsigned long
#if !__LP64__
@ObjCDynamicPropertyGetter(unsigned long) {
    unsigned long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(unsigned long, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedLongValue];
};

@ObjCDynamicPropertySetter(unsigned long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};
#endif

#pragma mark - unsigned long long
@ObjCDynamicPropertyGetter(unsigned long long) {
    unsigned long long retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] unsignedLongLongValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(unsigned long long) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(unsigned long long, NONATOMIC) {
    return [[self primitiveValueForKey:_key] unsignedLongLongValue];
};

@ObjCDynamicPropertySetter(unsigned long long, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - float
@ObjCDynamicPropertyGetter(float) {
    float retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] floatValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(float) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(float, NONATOMIC) {
    return [[self primitiveValueForKey:_key] floatValue];
};

@ObjCDynamicPropertySetter(float, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - double
@ObjCDynamicPropertyGetter(double) {
    double retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] doubleValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(double) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(double, NONATOMIC) {
    return [[self primitiveValueForKey:_key] doubleValue];
};

@ObjCDynamicPropertySetter(double, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - BOOL
#if __LP64__
@ObjCDynamicPropertyGetter(BOOL) {
    double retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] boolValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(BOOL) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(BOOL, NONATOMIC) {
    return [[self primitiveValueForKey:_key] boolValue];
};

@ObjCDynamicPropertySetter(BOOL, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};
#endif

#pragma mark - _Bool
@ObjCDynamicPropertyGetter(_Bool) {
    double retVal = 0;
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] boolValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(_Bool) {
    @synchronized (self) {
        [self setPrimitiveValue:@(newValue) forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(_Bool, NONATOMIC) {
    return [[self primitiveValueForKey:_key] boolValue];
};

@ObjCDynamicPropertySetter(_Bool, NONATOMIC) {
    [self setPrimitiveValue:@(newValue) forKey:_key];
};

#pragma mark - NSRange
@ObjCDynamicPropertyGetter(NSRange) {
    NSRange retVal = {};
    @synchronized (self) {
        retVal = [[self primitiveValueForKey:_key] rangeValue];
    }
    return retVal;
};

@ObjCDynamicPropertySetter(NSRange) {
    @synchronized (self) {
        [self setPrimitiveValue:[NSValue valueWithRange:newValue] forKey:_key];
    }
};

@ObjCDynamicPropertyGetter(NSRange, NONATOMIC) {
    return [[self primitiveValueForKey:_key] rangeValue];
};

@ObjCDynamicPropertySetter(NSRange, NONATOMIC) {
    [self setPrimitiveValue:[NSValue valueWithRange:newValue] forKey:_key];
};

