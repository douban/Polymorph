//
//  PLMArrayTransformer.m
//  Polymorph
//
//  Created by Tony Li on 1/15/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#include <objc/runtime.h>

#import "PLMArrayTransformer.h"
#import "PLMValueTransformer.h"
#import "Polymorph.h"

static NSArray *transform_array(NSArray *array, NSValueTransformer *transformer, BOOL reverse)
{
  NSMutableArray *results = [NSMutableArray array];
  for (id value in array) {
    id ret = reverse ? [transformer reverseTransformedValue:value] : [transformer transformedValue:value];
    if (ret) {
      [results addObject:ret];
    }
  }
  return results;
}

FOUNDATION_EXTERN NSValueTransformer *PLMArrayTransformer(NSValueTransformer *elementTransformer)
{
  return [PLMValueTransformer transformerUsingForwardBlock:^id(NSArray *array) {
    return transform_array(array, elementTransformer, NO);
  } reverseBlock:^id(NSArray *array) {
    return transform_array(array, elementTransformer, YES);
  }];
}

FOUNDATION_EXTERN NSValueTransformer *PLMArrayTransformerForClass(Class clazz)
{
  NSCParameterAssert([clazz conformsToProtocol:@protocol(PLMRawDataProvider)]);

  NSValueTransformer *transformer =
    [PLMValueTransformer transformerUsingForwardBlock:^id(id value) {
      NSCParameterAssert([value isKindOfClass:[NSDictionary class]]);
      return [clazz objectWithPolymorphRawData:[value mutableCopy]];
    } reverseBlock:^id(id value) {
      return [value polymorphRawData];
    }];
  return PLMArrayTransformer(transformer);
}

NSString *PLMArrayTransformerName(NSString *elementTransformerName)
{
  NSString *name = [NSString stringWithFormat:@"PLMArrayTransformer_%@", elementTransformerName];
  if ([NSValueTransformer valueTransformerForName:name]) {
    return name;
  }

  NSValueTransformer *transformer = PLMArrayTransformer([NSValueTransformer valueTransformerForName:elementTransformerName]);
  [NSValueTransformer setValueTransformer:transformer forName:name];

  return name;
}

NSString *PLMArrayTransformerNameForClass(Class clazz)
{
  NSCParameterAssert([clazz conformsToProtocol:@protocol(PLMRawDataProvider)]);

  NSString *name = [@"PLMTransformer" stringByAppendingString:NSStringFromClass(clazz)];

  if ([NSValueTransformer valueTransformerForName:name] == nil) {
    [NSValueTransformer setValueTransformer:PLMArrayTransformerForClass(clazz) forName:name];
  }

  return PLMArrayTransformerName(name);
}
