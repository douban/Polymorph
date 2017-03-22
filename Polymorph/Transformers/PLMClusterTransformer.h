//
//  PLMClusterTransformer.h
//  Frodo
//
//  Created by hao on 17/03/2017.
//  Copyright © 2017 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLMModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLMClusterMember <NSObject>

+ (BOOL)canInstantiateWithDictionary:(nullable NSDictionary *)dictionary;

@end

@interface PLMClusterTransformer : NSObject

+ (instancetype)sharedInstance;

- (void)registerSubClass:(Class<PLMClusterMember>)subClass forClass:(Class)superClass;
- (NSValueTransformer *)transformerForClass:(Class)clz;

@end

NS_ASSUME_NONNULL_END
