//
//  Celebrity.h
//  Polymorph
//
//  Created by Tony Li on 1/17/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

@import Polymorph;

NS_ASSUME_NONNULL_BEGIN

@interface Celebrity : PLMModel

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSURL *avatar;

@end

NS_ASSUME_NONNULL_END
