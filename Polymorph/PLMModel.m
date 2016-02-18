//
//  PLMModel.m
//  Polymorph
//
//  Created by Tony Li on 1/15/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import "PLMModel.h"
#import "Polymorph.h"

@implementation PLMModel {
  NSMutableDictionary *_dictionary;
}

- (instancetype)init
{
  return [self initWithDictionary:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
  if ( (self = [super init]) ) {
    _dictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
  }
  return self;
}

- (NSString *)string
{
  return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (NSData *)data
{
  return [NSJSONSerialization dataWithJSONObject:_dictionary options:0 error:nil];
}

@end

@implementation PLMModel (Polymorph)

+ (void)load
{
  @autoreleasepool { [self plm_activate]; }
}

- (NSMutableDictionary *)polymorphRawData
{
  return _dictionary;
}

+ (instancetype)objectWithPolymorphRawData:(NSMutableDictionary *)data
{
  return [[self alloc] initWithDictionary:data];
}

@end
