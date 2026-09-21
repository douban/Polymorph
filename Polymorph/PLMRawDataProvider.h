//
//  PLMRawDataProvider.h
//  Polymorph
//
//  Created by Tony Li on 1/18/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Provide dictionary to Polymorph.
 *
 *  Class that use `plm_dynamic` macro should conform to this protocol, and
 *  invoke `plm_activate` before accessing its properties, which can be done
 *  in `load` class method of that class.
 */
@protocol PLMRawDataProvider <NSObject>

@property (nonatomic, readonly) NSMutableDictionary *polymorphRawData;

+ (instancetype)objectWithPolymorphRawData:(NSMutableDictionary *)data;

@end

NS_ASSUME_NONNULL_END
