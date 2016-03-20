//
//  PLMURLTransformer.m
//  Polymorph
//
//  Created by Tony Li on 1/29/15.
//  Copyright (c) 2016 douban. All rights reserved.
//

#import "PLMValueTransformer.h"
#import "PLMURLTransformer.h"

NSString * const PLMURLTransformerName = @"PLMURLTransformerName";

__attribute__((constructor))
static void register_url_transformer()
{
  @autoreleasepool {
    PLMValueTransformer *transformer =
      [PLMValueTransformer
       transformerUsingForwardBlock:^id(NSString *value) {
         if (![value isKindOfClass:[NSString class]] || value.length == 0) {
           return nil;
         }

         NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
         return [[linkDetector firstMatchInString:value options:0 range:NSMakeRange(0, value.length)] URL];
       }
       reverseBlock:^id(NSURL *value) {
         return [value absoluteString];
       }];
    [NSValueTransformer setValueTransformer:transformer forName:PLMURLTransformerName];
  }
}

NSValueTransformer *PLMURLTransformer()
{
  return [NSValueTransformer valueTransformerForName:PLMURLTransformerName];
}
