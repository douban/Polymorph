//
//  PolymorphTests.m
//  PolymorphTests
//
//  Created by Tony Li on 1/15/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <objc/runtime.h>

#import "Polymorph.h"
#import "PLMModel.h"
#import "PLMArrayTransformer.h"
#import "NSValueTransformer+TransformerKit.h"

static NSString * const DoubleValueTransformerName = @"DoubleValueTransformerName";

#define PRIMITIVE_TYPES char, int, short, long, float, double

@interface _TypesObject : PLMModel

#define decl_type_iter(INDEX, TYPE) @property (nonatomic, assign) TYPE metamacro_concat(TYPE, Value);
metamacro_foreach(decl_type_iter,, PRIMITIVE_TYPES)

@property (nonatomic, assign) NSComparisonResult result;

@property (nonatomic, strong) NSString *str;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) _TypesObject *object;

@property (nonatomic, copy) NSArray *objects;

@property (nonatomic, assign) BOOL isVoted;
@property (nonatomic, readonly) BOOL keyPathBool;

@property (nonatomic, strong) NSNumber *isSue;
@property (nonatomic, strong) NSString *sue;

@property (nonatomic, assign) NSInteger doubleIt;

@end

@implementation _TypesObject

#define dynamic_type_iter(INDEX, TYPE) \
@plm_dynamic(metamacro_concat(TYPE, Value), \
@ metamacro_stringify(metamacro_concat(TYPE, Value)));
metamacro_foreach(dynamic_type_iter,, PRIMITIVE_TYPES)

@plm_dynamic_multi(result, url, str, object, isSue, sue);
@plm_dynamic(isVoted, @"is_voted");

@plm_dynamic(objects, @"objects", PLMArrayTransformerNameForClass([_TypesObject class]));

@plm_dynamic_keypath(keyPathBool, @"key.path");

@plm_dynamic(doubleIt, @"double_it", DoubleValueTransformerName);

@end

@interface PolymorphTests : XCTestCase

@end

@implementation PolymorphTests

+ (void)load
{
  @autoreleasepool {
    [NSValueTransformer registerValueTransformerWithName:DoubleValueTransformerName
                                   transformedValueClass:[NSNumber class]
                      returningTransformedValueWithBlock:^id(id value) { return @([value integerValue] * 2); }
                  allowingReverseTransformationWithBlock:^id(id value) { return @([value integerValue] / 2); }];
  }
}

- (void)testPrimitiveTypes
{

#define decl_type_value_iter(INDEX, VAL, TYPE) \
@ metamacro_stringify(metamacro_concat(TYPE, Value)) : @( VAL ) ,

  NSDictionary *json = @{
                         metamacro_foreach_cxt(decl_type_value_iter,, 100, PRIMITIVE_TYPES)
                         };

  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:json];

#define assertion_iter(INDEX, TYPE) XCTAssertEqual([object metamacro_concat(TYPE, Value)], 100)
  metamacro_foreach(assertion_iter, ;, PRIMITIVE_TYPES);

  object.intValue = 200;
  XCTAssertEqual(object.intValue, 200);
}

- (void)testPrimitiveTransform
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"double_it": @100}];
  XCTAssertEqual(object.doubleIt, 200);
  object.doubleIt = 500;
  XCTAssertEqual(object.doubleIt, 500);
}

- (void)testObjectTypes
{
  NSDictionary *json = @{@"url": @"http://douban.com"};
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:json];
  XCTAssertTrue([object.url isKindOfClass:[NSURL class]]);
  XCTAssertEqual(object.url.absoluteString, json[@"url"]);
}

- (void)testStoreObjectValues
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"object": @{}}];

  _TypesObject *sub = object.object;
  XCTAssertTrue([sub isKindOfClass:[_TypesObject class]]);
  XCTAssertTrue(object.object == sub);

  _TypesObject *newSub = [[_TypesObject alloc] initWithDictionary:@{@"intValue": @100}];
  object.object = newSub;
  XCTAssertTrue(object.object == newSub);
  XCTAssertEqual(newSub.intValue, 100);
}

- (void)testCopy
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"objects": @[]}];
  XCTAssertNotNil(object.objects);
  XCTAssertEqual(object.objects.count, 0);

  NSArray *objs = [NSMutableArray arrayWithObject:[[_TypesObject alloc] initWithDictionary:@{@"intValue": @100}]];
  object.objects = objs;
  XCTAssertTrue(object.objects != objs);
  XCTAssertEqual([object.objects.firstObject intValue], 100);
}

- (void)testUnconventionalNames
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"issue": @(100), @"sue": @"Blah"}];
  XCTAssertTrue([object.isSue isKindOfClass:[NSNumber class]]);
  XCTAssertEqual(object.isSue.integerValue, 100);
  XCTAssertTrue([object.sue isKindOfClass:[NSString class]]);
  XCTAssertEqual(object.sue, @"Blah");
}

- (void)testRuntime
{
#define sel_should_exist(SEL) XCTAssert(class_getInstanceMethod([_TypesObject class], @selector(SEL)) != nil)
  sel_should_exist(intValue);
  sel_should_exist(setIntValue:);
  sel_should_exist(setStr:);
}

- (void)testKVC
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:nil];
  [object setValue:@100 forKey:@"intValue"];
  [object setValue:@"abc" forKey:@"str"];
  XCTAssertEqual(object.intValue, 100);
  XCTAssertEqual(object.str, @"abc");
}

- (void)testEnum
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"result": @(NSOrderedDescending)}];
  XCTAssertEqual(object.result, NSOrderedDescending);

  object.result = NSOrderedAscending;
  XCTAssertEqual(object.result, NSOrderedAscending);
  XCTAssertEqual(object.dictionary[@"result"], @(NSOrderedAscending));
}

- (void)testNonConvention
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"is_voted": @YES}];
  XCTAssertEqual(object.isVoted, YES);
  XCTAssertEqual([object isVoted], YES);

  object.isVoted = NO;
  XCTAssertEqual(object.isVoted, NO);
  XCTAssertEqual([object isVoted], NO);
}

- (void)testNull
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"is_voted": [NSNull null], @"url": [NSNull null]}];
  XCTAssertEqual(object.isVoted, NO);
  XCTAssertNil(object.url);
}

- (void)testKeypath
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"key": @{@"path": @YES}}];
  XCTAssertEqual(object.keyPathBool, YES);
}

- (void)testInvalidData
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"is_voted": @"yes", @"str": @1000}];
  XCTAssertThrows(object.isVoted);
  XCTAssertThrows(object.str);
}

- (void)testUnkownAccessor
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

  _TypesObject *object = [_TypesObject new];
  XCTAssertThrows([object performSelector:NSSelectorFromString(@"abslksielwsdf")]);
  XCTAssertThrows([object performSelector:NSSelectorFromString(@"setAbslksielwsdf:")]);

#pragma clang diagnostic pop
}

- (void)testArray
{
  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"objects": @[@{@"url": @"http://www.douban.com"}, @{}]}];
  XCTAssertTrue(object.objects.count > 0);
  XCTAssertTrue([object.objects[0] isMemberOfClass:[_TypesObject class]]);
  XCTAssertEqual([object.objects[0] url].absoluteString, @"http://www.douban.com");

  NSMutableArray *objects = [NSMutableArray array];
  for (int i = 0; i < 10; ++i) {
    [objects addObject:[[_TypesObject alloc] initWithDictionary:@{@"url": @"http://www.douban.com"}]];
  }
  object.objects = objects;
  XCTAssertEqual(object.objects.count, objects.count);
  XCTAssertTrue([object.dictionary[@"objects"] isKindOfClass:[NSArray class]]);
  XCTAssertEqual([object.dictionary[@"objects"] count], objects.count);
  XCTAssertTrue([[object.dictionary[@"objects"] firstObject] isKindOfClass:[NSDictionary class]]);
  XCTAssertEqual([object.dictionary[@"objects"] firstObject][@"url"], @"http://www.douban.com");
}

- (void)testMultipleActivation
{
  [_TypesObject plm_activate];

  _TypesObject *object = [[_TypesObject alloc] initWithDictionary:@{@"url": @"http://www.douban.com"}];
  XCTAssertEqual(object.url.absoluteString, @"http://www.douban.com");
}

@end
