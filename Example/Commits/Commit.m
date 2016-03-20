//
//  Commit.m
//  Polymorph
//
//  Created by Tony Li on 1/25/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import "Commit.h"

@implementation Commit

+ (NSValueTransformer *)dateTransformer
{
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
  formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  return [PLMValueTransformer
          transformerUsingForwardBlock:^id(id value) { return [formatter dateFromString:value]; }
          reverseBlock:^id(id value) { return [formatter stringFromDate:value]; }];
}

@plm_dynamic(sha)
@plm_dynamic_keypath(message, @"commit.message")
@plm_dynamic_keypath(date, @"commit.committer.date", [self dateTransformer])
@plm_dynamic(diffURL, @"html_url")

@end
