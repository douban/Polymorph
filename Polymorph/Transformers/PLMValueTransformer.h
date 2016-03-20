//
//  PLMValueTransformer.h
//  Polymorph
//
//  Created by Tony Li on 3/20/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^PLMValueTransformerBlock)(id _Nullable value);

@interface PLMValueTransformer : NSValueTransformer

+ (instancetype)transformerUsingForwardBlock:(PLMValueTransformerBlock)forwardBlock
                                reverseBlock:(PLMValueTransformerBlock)reverseBlock;

@end

NS_ASSUME_NONNULL_END
