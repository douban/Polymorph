//
//  PLMClusterTransformer.m
//  Frodo
//
//  Created by hao on 17/03/2017.
//  Copyright © 2017 Douban Inc. All rights reserved.
//

#import "PLMClusterTransformer.h"
#import "PLMValueTransformer.h"

@interface PLMClusterTransformer()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet<Class> *> *transformers; // Dictionary stores registerd superclass and subclasses bindings. Key: superclass name. Value: Mutableset of subclasses

@end

@implementation PLMClusterTransformer

+ (instancetype)sharedInstance
{
  static PLMClusterTransformer *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[[self class] alloc] init];
  });
  return instance;
}

- (instancetype)init
{
  if (self = [super init]) {
    _transformers = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)registerSubClass:(Class)subClass forClass:(Class)superClass
{
  if (!subClass || !superClass) {
    return;
  }
  NSMutableSet *set = [self.transformers objectForKey:NSStringFromClass(superClass)];
  if (!set) {
    set = [NSMutableSet set];
    [self.transformers setObject:set forKey:NSStringFromClass(superClass)];
  }
  [set addObject:subClass];
}

- (NSValueTransformer *)transformerForClass:(Class)clz
{
  NSMutableSet *concreteClasses = [self.transformers objectForKey:NSStringFromClass(clz)];
  return [PLMValueTransformer transformerUsingForwardBlock:^id (NSDictionary *value) {
    if (![value isKindOfClass:[NSDictionary class]]) {
      return nil;
    }

    Class concrete = clz;
    for (Class class in concreteClasses) {
      NSCAssert([class conformsToProtocol:@protocol(PLMClusterMember)],
                @"Concrete class `%@` should conform to `PLMClusterMember` protocol.", NSStringFromClass(class));
      if ([class canInstantiateWithDictionary:value]) {
        concrete = class;
        break;
      }
    }
    return [[concrete alloc] initWithDictionary:value];
  } reverseBlock:^id (id value) {
    return [value conformsToProtocol:@protocol(PLMClusterMember)] ? [value dictionary] : nil;
  }];
}

@end
