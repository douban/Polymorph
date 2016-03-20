//
//  MovieResult.m
//  Polymorph
//
//  Created by Tony Li on 1/17/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import "MovieResult.h"
#import "PLMArrayTransformer.h"
#import "Movie.h"

@implementation MovieResult

@plm_dynamic_multi(start, count, total)
@plm_dynamic(movies, @"subjects", PLMArrayTransformerForClass([Movie class]))

@end
