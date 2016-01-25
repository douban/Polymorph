//
//  PLMURLTransformer.m
//  Polymorph
//
//  Created by Tony Li on 1/29/15.
//  Copyright (c) 2015 douban. All rights reserved.
//

#import "NSValueTransformer+TransformerKit.h"

#import "PLMURLTransformer.h"

NSString * const PLMURLTransformerName = @"PLMURLTransformerName";

@implementation PLMURLTransformer

+ (void)load
{
  [NSValueTransformer registerValueTransformerWithName:PLMURLTransformerName
                                 transformedValueClass:[NSURL class]
                    returningTransformedValueWithBlock:^id(NSString *value) {
                      if (![value isKindOfClass:[NSString class]] || value.length == 0) {
                        return nil;
                      }

                      NSURL * __block url = nil;
                      NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
                      [linkDetector enumerateMatchesInString:value
                                                     options:0
                                                       range:NSMakeRange(0, value.length)
                                                  usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                    url = result.URL;
                                                    *stop = url != nil;
                                                  }];
                      return url;
                    }
                allowingReverseTransformationWithBlock:^id(NSURL *value) {
                  return [value absoluteString];
                }];
}

@end