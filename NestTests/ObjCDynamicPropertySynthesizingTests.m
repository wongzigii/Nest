//
//  ObjCDynamicPropertySynthesizingTests.m
//  Nest
//
//  Created by Manfred on 24/12/2016.
//
//

@import XCTest;
@import Nest;

NS_ASSUME_NONNULL_BEGIN

@interface ObjCDynamicPropertySynthesizingTestObject : NSObject<ObjCDynamicPropertySynthesizing> {
    NSMutableDictionary<NSString *, id> * _storage;
}
@property (strong) id __nullable object;
@property (copy) id __nullable objectCopy;
@property (weak) id __nullable objectWeak;

@property (nonatomic, strong) id __nullable objectNonatomic;
@property (nonatomic, copy) id __nullable objectCopyNonatomic;
@property (nonatomic, weak) id __nullable objectWeakNonatomic;

@property (nonatomic, assign) char charValueNonatomic;
@property (nonatomic, assign) int intValueNonatomic;
@property (nonatomic, assign) short shortValueNonatomic;
@property (nonatomic, assign) long longValueNonatomic;
@property (nonatomic, assign) long long longLongValueNonatomic;

@property (nonatomic, assign) float floatValueNonatomic;
@property (nonatomic, assign) double doubleValueNonatomic;

@property (nonatomic, assign) BOOL boolValueNonatomic;

@property (nonatomic, assign) NSRange rangeValueNonatomic;

@property (assign) char charValue;
@property (assign) int intValue;
@property (assign) short shortValue;
@property (assign) long longValue;
@property (assign) long long longLongValue;

@property (assign) float floatValue;
@property (assign) double doubleValue;

@property (assign) BOOL boolValue;

@property (assign) NSRange rangeValue;
@end

@interface ObjCDynamicPropertySynthesizingTests : XCTestCase
@property (nonatomic, strong) ObjCDynamicPropertySynthesizingTestObject * __nullable dynamicObject;
@end

@implementation ObjCDynamicPropertySynthesizingTests

- (void)setUp {
    [super setUp];
    self.dynamicObject = [[ObjCDynamicPropertySynthesizingTestObject alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.dynamicObject = nil;
}

- (void)testKVCAccessors {
    NSString * sampleString = [[NSString alloc] initWithFormat:@"sample string"];
    self.dynamicObject.object = sampleString;
    XCTAssert([self.dynamicObject valueForKey:@"object"] == sampleString);
    
    self.dynamicObject.intValue = 6;
    XCTAssert([[self.dynamicObject valueForKey:@"intValue"] isEqual:@(6)]);
}

- (void)testAtomicObjectAccessors {
    NSString * sampleString = [[NSString alloc] initWithFormat:@"sample string"];
    
    XCTAssert(self.dynamicObject.object == nil);
    self.dynamicObject.object = sampleString;
    XCTAssert(self.dynamicObject.object == sampleString);
    sampleString = nil;
    XCTAssert(self.dynamicObject.object != nil);
}

- (void)testAtomicWeakObjectAccessors {
    @autoreleasepool {
        NSString * sampleString = [[NSString alloc] initWithFormat:@"sample string"];
        XCTAssert(self.dynamicObject.objectWeak == nil);
        self.dynamicObject.objectWeak = sampleString;
        XCTAssert(self.dynamicObject.objectWeak == sampleString);
    }
    
    XCTAssert(self.dynamicObject.objectWeak == nil);
}

- (void)testAtomicCopyObjectAccessors {
    NSString * sampleString = [[NSString alloc] initWithFormat:@"sample string"];
    
    XCTAssert(self.dynamicObject.objectCopy == nil);
    self.dynamicObject.objectCopy = sampleString;
    XCTAssert(self.dynamicObject.objectCopy != nil);
    XCTAssert([self.dynamicObject.objectCopy isEqualToString:sampleString]);
}

- (void)testNonatomicObjectAccessors {
    NSString * sampleString = [[NSString alloc] initWithFormat:@"sample string"];
    
    XCTAssert(self.dynamicObject.objectNonatomic == nil);
    self.dynamicObject.objectNonatomic = sampleString;
    XCTAssert(self.dynamicObject.objectNonatomic == sampleString);
    sampleString = nil;
    XCTAssert(self.dynamicObject.objectNonatomic != nil);
}

- (void)testNonatomicWeakObjectAccessors {
    @autoreleasepool {
        NSString * sampleString = [[NSString alloc] initWithFormat:@"sample string"];
        XCTAssert(self.dynamicObject.objectWeakNonatomic == nil);
        self.dynamicObject.objectWeakNonatomic = sampleString;
        XCTAssert(self.dynamicObject.objectWeakNonatomic == sampleString);
        sampleString = nil;
    }
    
    XCTAssert(self.dynamicObject.objectWeakNonatomic == nil);
}

- (void)testNonatomicCopyObjectAccessors {
    NSString * string = @"sample string";
    
    XCTAssert(self.dynamicObject.objectCopyNonatomic == nil);
    self.dynamicObject.objectCopyNonatomic = string;
    XCTAssert(self.dynamicObject.objectCopyNonatomic != nil);
    XCTAssert([self.dynamicObject.objectCopyNonatomic isEqualToString:string]);
}

- (void)testAtomicIntegerAccessors {
    XCTAssert(self.dynamicObject.charValue == 0);
    XCTAssert(self.dynamicObject.intValue == 0);
    XCTAssert(self.dynamicObject.shortValue == 0);
    XCTAssert(self.dynamicObject.longValue == 0);
    XCTAssert(self.dynamicObject.longLongValue == 0);
    
    self.dynamicObject.charValue = 4;
    self.dynamicObject.intValue = 5;
    self.dynamicObject.shortValue = 6;
    self.dynamicObject.longValue = 7;
    self.dynamicObject.longLongValue = 8;
    
    XCTAssert(self.dynamicObject.charValue == 4, @"Property charValue is %@", @(self.dynamicObject.charValue));
    XCTAssert(self.dynamicObject.intValue == 5, @"Property intValue is %@", @(self.dynamicObject.intValue));
    XCTAssert(self.dynamicObject.shortValue == 6, @"Property shortValue is %@", @(self.dynamicObject.shortValue));
    XCTAssert(self.dynamicObject.longValue == 7, @"Property longValue is %@", @(self.dynamicObject.longValue));
    XCTAssert(self.dynamicObject.longLongValue == 8, @"Property longLongValue is %@", @(self.dynamicObject.longLongValue));
}

- (void)testNonatomicIntegerAccessors {
    XCTAssert(self.dynamicObject.charValueNonatomic == 0);
    XCTAssert(self.dynamicObject.intValueNonatomic == 0);
    XCTAssert(self.dynamicObject.shortValueNonatomic == 0);
    XCTAssert(self.dynamicObject.longValueNonatomic == 0);
    XCTAssert(self.dynamicObject.longLongValueNonatomic == 0);
    
    self.dynamicObject.charValueNonatomic = 4;
    self.dynamicObject.intValueNonatomic = 5;
    self.dynamicObject.shortValueNonatomic = 6;
    self.dynamicObject.longValueNonatomic = 7;
    self.dynamicObject.longLongValueNonatomic = 8;
    
    
    XCTAssert(self.dynamicObject.charValueNonatomic == 4, @"Property charValueNonatomic is %@", @(self.dynamicObject.charValueNonatomic));
    XCTAssert(self.dynamicObject.intValueNonatomic == 5, @"Property intValueNonatomic is %@", @(self.dynamicObject.intValueNonatomic));
    XCTAssert(self.dynamicObject.shortValueNonatomic == 6, @"Property shortValueNonatomic is %@", @(self.dynamicObject.shortValueNonatomic));
    XCTAssert(self.dynamicObject.longValueNonatomic == 7, @"Property longValueNonatomic is %@", @(self.dynamicObject.longValueNonatomic));
    XCTAssert(self.dynamicObject.longLongValueNonatomic == 8, @"Property longLongValueNonatomic is %@", @(self.dynamicObject.longLongValueNonatomic));
}

- (void)testFloatingPointAccessors {
    XCTAssert(self.dynamicObject.floatValue == 0);
    XCTAssert(self.dynamicObject.doubleValue == 0);
    XCTAssert(self.dynamicObject.floatValueNonatomic == 0);
    XCTAssert(self.dynamicObject.doubleValueNonatomic == 0);
    
    self.dynamicObject.floatValue = 4;
    self.dynamicObject.doubleValue = 5;
    self.dynamicObject.floatValueNonatomic = 4;
    self.dynamicObject.doubleValueNonatomic = 5;
    
    XCTAssert(self.dynamicObject.floatValue == 4, @"Property floatValue is %@", @(self.dynamicObject.floatValue));
    XCTAssert(self.dynamicObject.doubleValue == 5, @"Property doubleValue is %@", @(self.dynamicObject.doubleValue));
    XCTAssert(self.dynamicObject.floatValueNonatomic == 4, @"Property floatValueNonatomic is %@", @(self.dynamicObject.floatValueNonatomic));
    XCTAssert(self.dynamicObject.doubleValueNonatomic == 5, @"Property doubleValueNonatomic is %@", @(self.dynamicObject.doubleValueNonatomic));
}

- (void)testBOOLAccessors {
    XCTAssert(self.dynamicObject.boolValue == NO);
    XCTAssert(self.dynamicObject.boolValueNonatomic == NO);
    
    self.dynamicObject.boolValue = YES;
    self.dynamicObject.boolValueNonatomic = YES;
    
    XCTAssert(self.dynamicObject.boolValue == YES, @"Property boolValue is %@", @(self.dynamicObject.boolValue));
    XCTAssert(self.dynamicObject.boolValueNonatomic == YES, @"Property boolValueNonatomic is %@", @(self.dynamicObject.boolValueNonatomic));
}

- (void)testNSRangeAccessors {
    XCTAssert(NSRangeEqualToRange(self.dynamicObject.rangeValue, NSRangeMake(0, 0)));
    XCTAssert(NSRangeEqualToRange(self.dynamicObject.rangeValueNonatomic, NSRangeMake(0, 0)));
    
    self.dynamicObject.rangeValue = NSRangeMake(0, 100);
    self.dynamicObject.rangeValueNonatomic = NSRangeMake(0, 100);
    
    XCTAssert(NSRangeEqualToRange(self.dynamicObject.rangeValue, NSRangeMake(0, 100)), @"Property rangeValue is %@", [NSValue valueWithRange:self.dynamicObject.rangeValue]);
    XCTAssert(NSRangeEqualToRange(self.dynamicObject.rangeValueNonatomic, NSRangeMake(0, 100)), @"Property rangeValueNonatomic is %@", [NSValue valueWithRange:self.dynamicObject.rangeValueNonatomic]);
}
@end

@implementation ObjCDynamicPropertySynthesizingTestObject
@dynamic object;
@dynamic objectCopy;
@dynamic objectWeak;

@dynamic objectNonatomic;
@dynamic objectCopyNonatomic;
@dynamic objectWeakNonatomic;

@dynamic charValueNonatomic;
@dynamic intValueNonatomic;
@dynamic shortValueNonatomic;
@dynamic longValueNonatomic;
@dynamic longLongValueNonatomic;

@dynamic floatValueNonatomic;
@dynamic doubleValueNonatomic;

@dynamic boolValueNonatomic;
@dynamic rangeValueNonatomic;

@dynamic charValue;
@dynamic intValue;
@dynamic shortValue;
@dynamic longValue;
@dynamic longLongValue;

@dynamic floatValue;
@dynamic doubleValue;

@dynamic boolValue;
@dynamic rangeValue;

- (NSMutableDictionary<NSString *,id> *)storage {
    if (_storage == nil) {
        _storage = [[NSMutableDictionary alloc] init];
    }
    return _storage;
}

- (void)setPrimitiveValue:(nullable id)primitiveValue forKey:(NSString *)key {
    self.storage[key] = primitiveValue;
}

- (nullable id)primitiveValueForKey:(NSString *)key {
    return self.storage[key];
}
@end

NS_ASSUME_NONNULL_END
