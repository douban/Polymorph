//
//  PLMArrayTransformer.h
//  Polymorph
//
//  Created by Tony Li on 1/15/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSValueTransformer *PLMArrayTransformer(NSValueTransformer *elementTransformer);

FOUNDATION_EXTERN NSValueTransformer *PLMArrayTransformerForClass(Class clazz);

FOUNDATION_EXTERN NSString *PLMArrayTransformerName(NSString *elementTransformerName)
  DEPRECATED_MSG_ATTRIBUTE("use `PLMArrayTransformer` instead");

FOUNDATION_EXTERN NSString *PLMArrayTransformerNameForClass(Class clazz)
  DEPRECATED_MSG_ATTRIBUTE("use `PLMArrayTransformerForClass` instead");
