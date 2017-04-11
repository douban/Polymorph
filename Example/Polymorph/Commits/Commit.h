//
//  Commit.h
//  Polymorph
//
//  Created by Tony Li on 1/25/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

@import Polymorph;

NS_ASSUME_NONNULL_BEGIN

@interface Commit : PLMModel

@property (nonatomic, readonly) NSString *sha;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSURL *diffURL;

@end

NS_ASSUME_NONNULL_END
