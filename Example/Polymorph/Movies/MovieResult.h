//
//  MovieResult.h
//  Polymorph
//
//  Created by Tony Li on 1/17/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

@import Polymorph;

@class Movie;

NS_ASSUME_NONNULL_BEGIN

@interface MovieResult : PLMModel

@property (nonatomic, readonly) NSUInteger start;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger total;
@property (nonatomic, readonly) NSArray<Movie *> *movies;

@end

NS_ASSUME_NONNULL_END
