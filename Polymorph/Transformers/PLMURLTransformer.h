//
//  PLMURLTransformer.h
//  Polymorph
//
//  Created by Tony Li on 1/29/15.
//  Copyright (c) 2016 douban. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSValueTransformer *PLMURLTransformer();

/// Transformer that transform values between `NSString` and `NSURL`
FOUNDATION_EXTERN NSString * const PLMURLTransformerName;
