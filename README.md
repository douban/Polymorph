# Polymorph

[![License](https://img.shields.io/cocoapods/l/Polymorph.svg)](https://github.com/douban/Polymorph/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/p/Polymorph.svg)](https://cocoapods.org/pods/Polymorph)
[![CocoaPods](https://img.shields.io/cocoapods/v/Polymorph.svg)](https://cocoapods.org/pods/Polymorph)
[![Build Status](https://travis-ci.org/douban/Polymorph.svg)](https://travis-ci.org/douban/Polymorph)
[![Codecov](https://img.shields.io/codecov/c/github/douban/Polymorph.svg)](https://codecov.io/github/douban/Polymorph)

> [Polymorph](http://wowwiki.wikia.com/wiki/Polymorph) transforms the enemy into a sheep.

Transform value of dictionary to property of Objective-C class, by using a `@dynamic` like directive.


## Usage

Say we have a `Movie` class.

```objc
@interface Movie : PLMModel

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *year;
@property (nonatomic, readonly) NSString *subtype;
@property (nonatomic, readonly) float rating;
@property (nonatomic, readonly) NSArray<Celebrity *> *casts;

@end
```

Instead of implementing accessor methods for each property, we can use `plm_dynamic` macro to generate getter and setter automatically.

```objc
@implementation Movie

// Property `identifier` comes from `id` field。
@plm_dynamic(identifier, @"id")

// Property `title` comes from field with same name `title`.
@plm_dynamic(title)

// `year` and `subtype` comes from fields with same names.
@plm_dynamic_multi(year, subtype)

// `rating` comes from `rating.average` keypath. Field value will be transformed to `float` as it's declared.
@plm_dynamic_keypath(rating, @"rating.average")

// `casts` comes from `casts` field. Field value, which is an object array, will be transformed to NSArray with Celebrity instance.
@plm_dynamic(casts, @"casts", PLMArrayTransformerNameForClass([Celebrity class]))

@end
```

`plm_dynamic` macro associate property and dictionary field, use `NSValueTransformer` to transform dictionary value to declared type. See comments in `Polymorph.h` for detailed usage.


### Without inheritance

You can also use Polymorph without extending `PLMModel`. Conform to `PLMRawDataProvider` protocol, invoke `plm_activate`, and you are ready to go.


## License

Polymorph is released under BSD license. See [LICENSE](https://github.com/douban/Polymorph/blob/master/LICENSE) for more.
