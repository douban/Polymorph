//
//  PLMArrayTransformer.m
//  Polymorph
//
//  Created by Tony Li on 1/15/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#include <objc/runtime.h>

#import "PLMArrayTransformer.h"
#import "NSValueTransformer+TransformerKit.h"
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

NSString *PLMArrayTransformerName(NSString *elementTransformerName)
{
  NSString *name = [NSString stringWithFormat:@"PLMArrayTransformer_%@", elementTransformerName];
  NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:elementTransformerName];

  id (^reverse)(NSArray *) = nil;

  if ([[transformer class] allowsReverseTransformation]) {
    reverse = ^id(NSArray *array) {
      return transform_array(array, transformer, YES);
    };
  }
  [NSValueTransformer registerValueTransformerWithName:name
                                 transformedValueClass:[NSArray class]
                    returningTransformedValueWithBlock:^id(NSArray *array) {
                      return transform_array(array, transformer, NO);
                    }
                allowingReverseTransformationWithBlock:reverse];

  return name;
}

NSString *PLMArrayTransformerNameForClass(Class clazz)
{
  NSCParameterAssert([clazz conformsToProtocol:@protocol(PLMRawDataProvider)]);

  NSString *name = [@"PLMTransformer" stringByAppendingString:NSStringFromClass(clazz)];

  [NSValueTransformer registerValueTransformerWithName:name
                                 transformedValueClass:clazz
                    returningTransformedValueWithBlock:^id(id value) {
                      NSCParameterAssert([value isKindOfClass:[NSDictionary class]]);
                      return [clazz objectWithPolymorphRawData:[value mutableCopy]];
                    }
                allowingReverseTransformationWithBlock:^id(id value) {
                  return [value polymorphRawData];
                }];

  return PLMArrayTransformerName(name);
}
