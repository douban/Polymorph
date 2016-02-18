//
//  PLMURLTransformer.m
//  Polymorph
//
//  Created by Tony Li on 1/29/15.
//  Copyright (c) 2016 douban. All rights reserved.
//

#import "NSValueTransformer+TransformerKit.h"

#import "PLMURLTransformer.h"

NSString * const PLMURLTransformerName = @"PLMURLTransformerName";

@implementation PLMURLTransformer

+ (void)load
{
  @autoreleasepool {
    [NSValueTransformer registerValueTransformerWithName:PLMURLTransformerName
                                   transformedValueClass:[NSURL class]
                      returningTransformedValueWithBlock:^id(NSString *value) {
                        if (![value isKindOfClass:[NSString class]] || value.length == 0) {
                          return nil;
                        }

                        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
                        return [[linkDetector firstMatchInString:value options:0 range:NSMakeRange(0, value.length)] URL];
                      }
                  allowingReverseTransformationWithBlock:^id(NSURL *value) {
                    return [value absoluteString];
                  }];
  }
}

@end
