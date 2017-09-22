//
//  Polymorph.h
//  Polymorph
//
//  Created by Tony Li on 1/15/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PLMRawDataProvider.h"
#import "PLMModel.h"
#import "PLMValueTransformer.h"
#import "PLMArrayTransformer.h"
#import "PLMURLTransformer.h"

#if __has_include(<libextobjc/metamacros.h>)
#include <libextobjc/metamacros.h>
#elif __has_include("metamacros.h")
#include "metamacros.h"
#endif

/**
 *  Associate property with field in dictionary.
 *
 *  Use this macro in class's implementation, like using `@dynamic` directive.
 *
 *      @implementation User
 *
 *      @plm_dynamic(name)
 *      @plm_dynamic(age)
 *
 *      @end
 *
 *
 *  It declares the property as `dynamic` property and generate accessor methods
 *  at runtime.
 *
 *  Following are a few prerequisites for using this macro:
 *  - Class should conform to `PLMRawDataProvider` protocol.
 *  - Class should invoke `plm_activate` before accessing it's property. `load`
 *    is a good place to do this.
 *  - Property name should follow Objective-C naming convention.
 *    - Use cammel case for property name. e.g. `fooBar`.
 *    - Getter name should be the same as property name. With only one exception,
 *      if it's a `BOOL` type, use `isFooBar` instead.
 *    - Setter name should be `setFooBar:`.
 *
 *
 *  Arguments:
 *  1. _Required_. Property name
 *  2. _Optional_. Dictionary field. Default value is property name in lower case.
 *  3. _Optional_. Name or instance of `NSValueTransformer`. The transformer
 *    represented by this argument will be used to transform dictionary value to
 *    instance of declared property type. Property with following type will be
 *    transformed automatically:
 *    - `NSString`, `NSNumber`, primitive types.
 *    - `NSURL`.
 *    - Class that conforms to `PLMRawDataProvider` protocol.
 *
 *
 *  Examples:
 *
 *  For property named `title` with `NSString` type, which reflect `title` in
 *  dictionary:
 *
 *      @plm_dynamic(title)
 *
 *  For property named `publishDate` with `NSDate` type, which reflect
 *  `publish_date` in dictionary:
 *
 *      @plm_dynamic(publishDate, @"publish_date", GMTDateTransformerName)
 *
 *  Please note that, arguments should be passed in the exactly order listed
 *  above. For example, if we have a `date` property with same field name, we
 *  should use following statement:
 *
 *      @plm_dynamic(date, @"date", GMTDateTransformerName)
 *
 *  instead of
 *
 *      @plm_dynamic(date, GMTDateTransformerName)
 *
 *  Note:
 *  1. Only plm_dynamic_nullable(...) and plm_dynamic_nullable_keypath(...) may return nil, the others will always
 *     return a nonnull value;
 *  2. plm_dynamic_nonnull(...) and plm_dynamic_nonnull_keypath(...) need to set an object value at the last argument as
       the default value when it is nil;
 *  3. plm_dynamic(...), plm_dynamic_keypath(...) and plm_dynamic_multi(...) will return a default value when the object is nil;
 *  4. It is recommended to use plm_dynamic_nullable_xxx for `nullable` property and plm_dynamic_nonnull_xxx for `nonnull` property.
 */
#define plm_dynamic(...)  _plm_dynamic_impl(metamacro_at(0, __VA_ARGS__), {_plm_dynamic_attr(__VA_ARGS__);})

#define plm_dynamic_nullable(...) \
  _plm_dynamic_impl(metamacro_at(0, __VA_ARGS__), { \
  NSDictionary *attrs = (NSDictionary *)_plm_dynamic_attr(__VA_ARGS__); \
  if (!attrs) { \
    attrs = [NSDictionary dictionary]; \
  } \
  NSMutableDictionary *mutAttrs = [attrs mutableCopy]; \
  mutAttrs[_PolymorphAttributeNullable] = @YES; \
  mutAttrs; \
  })

#define plm_dynamic_nonnull(...) \
  _plm_dynamic_impl(metamacro_at(0, __VA_ARGS__), { \
    NSDictionary *attrs = (NSDictionary *)_plm_dynamic_nonnull_attr(__VA_ARGS__); \
    if (!attrs) { \
      attrs = [NSDictionary dictionary]; \
    } \
    NSMutableDictionary *mutAttrs = [attrs mutableCopy]; \
    mutAttrs[_PolymorphAttributeNullable] = @NO; \
    mutAttrs; \
  })

/**
 *  Same arguments as `plm_dynamic`, except the field name specified by second
 *  arugment will be used as dictionary keypath.
 *
 *  Note that, this macro can only be used for readonly property.
 *
 */
#define plm_dynamic_keypath(...) \
  _plm_dynamic_impl(metamacro_at(0, __VA_ARGS__), { \
    NSMutableDictionary *attrs = [_plm_dynamic_attr(__VA_ARGS__) mutableCopy]; \
    attrs[_PolymorphAttributeKeypath] = @YES; \
    attrs; \
  })

#define plm_dynamic_nullable_keypath(...) \
  _plm_dynamic_impl(metamacro_at(0, __VA_ARGS__), { \
  NSMutableDictionary *attrs = [_plm_dynamic_attr(__VA_ARGS__) mutableCopy]; \
  attrs[_PolymorphAttributeKeypath] = @YES; \
  attrs[_PolymorphAttributeNullable] = @YES; \
  attrs; \
  })

#define plm_dynamic_nonnull_keypath(...) \
  _plm_dynamic_impl(metamacro_at(0, __VA_ARGS__), { \
    NSMutableDictionary *attrs = [_plm_dynamic_nonnull_attr(__VA_ARGS__) mutableCopy]; \
    attrs[_PolymorphAttributeKeypath] = @YES; \
    attrs[_PolymorphAttributeNullable] = @NO; \
    attrs; \
  })

/**
 *  `plm_dynamic` for many properties. Arguments are properties names list.
 *
 *      @plm_dynamic_multi(P1, P2, P3, ...)
 *
 *  is same as
 *
 *      @plm_dynamic(P1)
 *      @plm_dynamic(P2)
 *      @plm_dynamic(P3)
 *      ...
 *
 */
#define plm_dynamic_multi(...) metamacro_foreach(_plm_dynamic_multi_iter, @, __VA_ARGS__)

@interface NSObject (Polymorph)

/**
 *  Enable transforming properties for receiver and it's subclasses.
 *
 *  This message should be sent before accessing properties of this class's
 *  instances. One good place to do that is `load`:
 *
 *      + (void)load {
 *          @autorelease {
 *              [self plm_activate];
 *          }
 *      }
 *
 */
+ (void)plm_activate;

@end

#define _plm_dynamic_impl(PROPERTY, ...) \
  dynamic PROPERTY; \
  + (NSDictionary *) metamacro_concat(__plm_property_attr_, PROPERTY) { return (__VA_ARGS__); }

#define _plm_dynamic_multi_iter(INDEX, PROPERTY) plm_dynamic(PROPERTY)

#define _PolymorphAttributeJSONField     @"fd"
#define _PolymorphAttributeTransformer   @"tf"
#define _PolymorphAttributeKeypath       @"kp"
#define _PolymorphAttributeNullable      @"nb"
#define _PolymorphAttributeDefaultValue  @"dv"

#define _plm_dynamic_attr(...) metamacro_concat(_plm_dynamic_attr, metamacro_argcount(__VA_ARGS__))(__VA_ARGS__)
#define _plm_dynamic_nonnull_attr(...) metamacro_concat(_plm_dynamic_nonnull_attr, metamacro_argcount(__VA_ARGS__))(__VA_ARGS__)

#define _plm_dynamic_attr1(...) nil
#define _plm_dynamic_attr2(...) @{ \
    _PolymorphAttributeJSONField:   metamacro_at(1, __VA_ARGS__) \
  }
#define _plm_dynamic_attr3(...) @{ \
    _PolymorphAttributeJSONField:   metamacro_at(1, __VA_ARGS__), \
    _PolymorphAttributeTransformer: metamacro_at(2, __VA_ARGS__), \
  }
#define _plm_dynamic_attr4(...) @{ \
    _PolymorphAttributeJSONField:   metamacro_at(1, __VA_ARGS__), \
    _PolymorphAttributeTransformer: metamacro_at(2, __VA_ARGS__), \
    _PolymorphAttributeKeypath:     metamacro_at(3, __VA_ARGS__), \
  }

#pragma mark - plm_dynamic_nonnull()

#define _plm_dynamic_nonnull_attr2(...) @{ \
  _PolymorphAttributeDefaultValue: metamacro_at(1, __VA_ARGS__) \
}
#define _plm_dynamic_nonnull_attr3(...) @{ \
  _PolymorphAttributeJSONField:   metamacro_at(1, __VA_ARGS__), \
  _PolymorphAttributeDefaultValue: metamacro_at(2, __VA_ARGS__) \
}
#define _plm_dynamic_nonnull_attr4(...) @{ \
  _PolymorphAttributeJSONField:   metamacro_at(1, __VA_ARGS__), \
  _PolymorphAttributeTransformer: metamacro_at(2, __VA_ARGS__), \
  _PolymorphAttributeDefaultValue: metamacro_at(3, __VA_ARGS__) \
}
#define _plm_dynamic_nonnull_attr5(...) @{ \
  _PolymorphAttributeJSONField:   metamacro_at(1, __VA_ARGS__), \
  _PolymorphAttributeTransformer: metamacro_at(2, __VA_ARGS__), \
  _PolymorphAttributeKeypath:     metamacro_at(3, __VA_ARGS__), \
  _PolymorphAttributeDefaultValue: metamacro_at(4, __VA_ARGS__) \
}



