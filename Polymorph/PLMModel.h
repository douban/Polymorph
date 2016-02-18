//
//  PLMModel.h
//  Polymorph
//
//  Created by Tony Li on 1/15/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Polymorph.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLMModel : NSObject

@property (nonatomic, readonly) NSDictionary *dictionary;

/**
 *  `dictionary` as JSON string.
 */
@property (nonatomic, readonly) NSString *string;

/**
 *  `dictionary` as JSON data with UTF8 encoding.
 */
@property (nonatomic, readonly) NSData *data;

- (instancetype)initWithDictionary:(nullable NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end

@interface PLMModel (Polymorph) <PLMRawDataProvider>
@end

NS_ASSUME_NONNULL_END
