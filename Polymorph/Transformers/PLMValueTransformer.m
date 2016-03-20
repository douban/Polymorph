//
//  PLMValueTransformer.m
//  Polymorph
//
//  Created by Tony Li on 3/20/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import "PLMValueTransformer.h"

@interface PLMValueTransformer ()

@property (nonatomic, copy, readonly) PLMValueTransformerBlock forwardBlock;
@property (nonatomic, copy, readonly) PLMValueTransformerBlock reverseBlock;

@end

@implementation PLMValueTransformer

+ (instancetype)transformerUsingForwardBlock:(PLMValueTransformerBlock)forwardBlock
                                reverseBlock:(PLMValueTransformerBlock)reverseBlock
{
  return [[self alloc] initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

- (instancetype)init
{
  return [self initWithForwardBlock:nil reverseBlock:nil];
}

- (id)initWithForwardBlock:(PLMValueTransformerBlock)forwardBlock
              reverseBlock:(PLMValueTransformerBlock)reverseBlock
{
  NSParameterAssert(forwardBlock != nil);
  NSParameterAssert(reverseBlock != nil);

  if ( (self = [super init]) ) {
    _forwardBlock = [forwardBlock copy];
    _reverseBlock = [reverseBlock copy];
  }
  return self;
}

+ (BOOL)allowsReverseTransformation
{
  return YES;
}

+ (Class)transformedValueClass
{
  return [NSObject class];
}

- (id)transformedValue:(id)value
{
  return self.forwardBlock(value);
}

- (id)reverseTransformedValue:(id)value
{
  return self.reverseBlock(value);
}

@end
