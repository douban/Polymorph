//
//  Celebrity.m
//  Polymorph
//
//  Created by Tony Li on 1/17/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import "Celebrity.h"

@implementation Celebrity

@plm_dynamic(name);
@plm_dynamic_keypath(avatar, @"avatar.small")

@end
