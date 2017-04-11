//
//  Movie.m
//  Polymorph
//
//  Created by Tony Li on 1/17/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import "Movie.h"
#import "Celebrity.h"
#import "PLMArrayTransformer.h"

@implementation Movie

// Property `identifier` comes from `id` field。
@plm_dynamic(identifier, @"id")

// Property `title` comes from field with same name `title`.
@plm_dynamic(title)

// `year` and `subtype` comes from fields with same names.
@plm_dynamic_multi(year, subtype)

// `rating` comes from `rating.average` keypath. Field value will be transformed
// to `float` as it's declared.
@plm_dynamic_keypath(rating, @"rating.average")

// `directors` comes from `directors` field, the object array will be transformed
// to NSArray with Celebrity instance。
@plm_dynamic(directors, @"directors", PLMArrayTransformerForClass([Celebrity class]))

// `casts` comes from `casts` field. Field value, which is an object array, will
// be transformed to NSArray with Celebrity instance.
@plm_dynamic(casts, @"casts", PLMArrayTransformerForClass([Celebrity class]))

// `poster` comes from `images.small` keypath. Field value will be transformed
// to `NSURL` automatically.
@plm_dynamic_keypath(poster, @"images.small")

// `link` comes from `alt` field。
@plm_dynamic(link, @"alt")

@end
