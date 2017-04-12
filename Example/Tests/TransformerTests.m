//
//  TransformerTests.m
//  Polymorph
//
//  Created by Tony Li on 1/29/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

@import XCTest;
@import Polymorph;

@interface TransformerTests : XCTestCase

@end

@implementation TransformerTests

- (void)testURL
{
  NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:PLMURLTransformerName];

  XCTAssertTrue([[[transformer transformedValue:@"https://www.douban.com/search?q=中文"] absoluteString] hasSuffix:@"q=%E4%B8%AD%E6%96%87"]);
}

@end
