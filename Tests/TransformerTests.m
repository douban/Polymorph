//
//  TransformerTests.m
//  Polymorph
//
//  Created by Tony Li on 1/29/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PLMURLTransformer.h"

@interface TransformerTests : XCTestCase

@end

@implementation TransformerTests

- (void)testURL
{
  NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:PLMURLTransformerName];

  XCTAssertTrue([[[transformer transformedValue:@"https://www.douban.com/search?q=中文"] absoluteString] hasSuffix:@"q=%E4%B8%AD%E6%96%87"]);

  NSString *urlstr = @"https://erebor.douban.com/redirect/?ad=189044&uid=&bid=f3aa3b12cf59557048928413ec6dcc91d952f545&unit=dale_dacp_test&crtr=&mark=&hn=jolly2&sig=7acf0b8aa310b5dafb0242c18d245056ea39a448708f59285bd8a9ad88663952d3f5f7d57d9bb4f07cfabccdd4b6dc921b294d730388e2a48f3a9892ec6c8318&pid=debug_7866656cbcdc56ed2e96111f21f798c10d54a21b&target=aHR0cDovL2NsaWNrLnRhbnguY29tL3RmP2U9NXVEU1h2YUJ6UVVIY3JDNm5IMlFWbnVJWU9KNmM1QWZ4Zk5WYVFaNXl3cFpxJTJiZVZPMTZwM1hTQzJuNkhFNmtOZ2x2elBocHhvZ2tURDF5R21MY3V1S2dvZDk2ejd4JTJiZjJ1RWUlMmJTNmtiVTMzV2RibnRhTjlrWDB4V2x3WnUzUFRYcUdtQjVUcDBrV2JrNzcySVhvcDlpWE51NUxORjB6N3VPSUtOM3klMmZvY2NEZ1QzM1ZkZVBadm1MJTJiRVpjeWplOEdKZHNjM3JLd3NITUg1cUl1NEFBQTdnSlI4TG5wMHh1eWdkaGMxOFRPdCUyYmlPSzlDdmVjY0kzdkI2QU9PcHR6aEJVY2VZcFU5TVRhJTJiMkJja3lOa0JJZyUzZCUzZCZ1PWh0dHBzJTNhJTJmJTJmd3d3LmFsaXRyaXAuY29tJTNmZGZfc2lkJTNkMGJiNDgyMGEwMDAwMzAwMDU5Y2M3NWMwMDA0NmFkNTMlMjZiY19mbF9zcmMlM2R0YW54X2RmXzYxODIwODg0JTI2cmVzb3VyY2VfaWQlM2QxMDE3MSZrPTI4MA==";

  XCTAssertEqual([[transformer transformedValue:urlstr] absoluteString], urlstr);
}

@end
