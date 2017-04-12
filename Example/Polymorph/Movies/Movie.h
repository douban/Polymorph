//
//  Movie.h
//  Polymorph
//
//  Created by Tony Li on 1/17/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

@import Polymorph;

@class Celebrity;

NS_ASSUME_NONNULL_BEGIN

@interface Movie : PLMModel

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *year;
@property (nonatomic, readonly) NSString *subtype;
@property (nonatomic, readonly) float rating;
@property (nonatomic, readonly) NSArray<Celebrity *> *directors;
@property (nonatomic, readonly) NSArray<Celebrity *> *casts;
@property (nonatomic, readonly) NSURL *poster;
@property (nonatomic, readonly) NSURL *link;

@end

NS_ASSUME_NONNULL_END
