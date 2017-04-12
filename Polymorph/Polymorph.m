//
//  Polymorph.m
//  Polymorph
//
//  Created by Tony Li on 1/15/16.
//  Copyright © 2016 Douban Inc. All rights reserved.
//

#include <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#include <objc/runtime.h>
#import <libextobjc/EXTRuntimeExtensions.h>
#import <libextobjc/EXTScope.h>

#import "Polymorph.h"
#import "PLMURLTransformer.h"

#define PLMLog NSLog

#define safety_type_check(VAR, CLASS)  \
  if (VAR && ![VAR isKindOfClass:(CLASS)]) { \
    NSCAssert(NO, @"value should be %@", NSStringFromClass(CLASS)); \
    VAR = nil; \
  }

/**
 *  Parse property name from getter method name.
 *
 *  @param buff                 Buffer to store parse result.
 *  @param selector             Getter method name.
 *  @param boolGetterConvention Does getter method name following naming
 *                              convention for `BOOL` getter method.
 */
static void property_from_getter(char *buff,
                                 const char *selector,
                                 BOOL boolGetterConvention)
{
  unsigned long selLength = strlen(selector);
  if (boolGetterConvention
      && selLength > 2
      && strncmp(selector, "is", 2) == 0
      && isupper(selector[2])) {
    // BOOL property getter: 'isXxx'
    strncpy(buff, &selector[2], selLength - 2);
    buff[0] = (char)tolower(buff[0]);
    buff[selLength - 2] = '\0';
  } else {
    // Getter name is the property name
    strncpy(buff, &selector[0], selLength);
    buff[selLength] = '\0';
  }
}

/**
 *  Try to parse property name from setter method name.
 *
 *  @param buff     Buffer to store parse result.
 *  @param selector Setter method name
 *
 *  @return YES if success, otherwise NO.
 */
static BOOL property_from_setter(char *buff,
                                 const char *selector,
                                 BOOL lower)
{
  unsigned long selLength = strlen(selector);
  if (selLength > 3 && strncmp(selector, "set", 3) == 0 && isupper(selector[3])) {
    // remove 'set' & ':'
    strncpy(buff, &selector[3], selLength - 4);
    if (lower) { buff[0] = (char)tolower(buff[0]); }
    buff[selLength - 4] = '\0';
    return YES;
  }
  return NO;
}

/**
 *  Get property from accessor method name.
 */
static ext_propertyAttributes *copy_property_attrs(Class cls,
                                                   SEL accessor,
                                                   BOOL *outGetter,
                                                   objc_property_t *outProperty)
{
  NSCParameterAssert(cls != NULL && accessor != NULL && outGetter != NULL && outProperty != NULL);

  ext_propertyAttributes *attrs = NULL;
  const char *selName = sel_getName(accessor);
  char buff[strlen(selName) + 1];
  *outGetter = strchr(selName, ':') == NULL;

#define build_attrs(ACCESSOR) \
  do { \
    *outProperty = class_getProperty(cls, buff); \
    if (*outProperty) { \
      attrs = ext_copyPropertyAttributes(*outProperty); \
      if (attrs) { \
        if (!sel_isEqual(attrs->ACCESSOR, accessor)) { \
          free(attrs); \
          attrs = NULL; \
        } \
      } \
    } \
    if (attrs == NULL) { \
      *outProperty = NULL; \
    } \
  } while(0)

  if (*outGetter) {
    property_from_getter(buff, selName, YES);
    build_attrs(getter);

    if (attrs == NULL) {
      property_from_getter(buff, selName, NO);
      build_attrs(getter);
    }
  } else {
    property_from_setter(buff, selName, YES);
    build_attrs(setter);

    if (attrs == NULL) {
      property_from_setter(buff, selName, NO);
      build_attrs(setter);
    }
  }

#undef build_attrs

  return attrs;
}

FOUNDATION_STATIC_INLINE NSValueTransformer *default_transformer(Class targetClass)
{
  if ([targetClass isSubclassOfClass:[NSURL class]]) {
    return PLMURLTransformer();
  } else if ([targetClass conformsToProtocol:@protocol(PLMRawDataProvider)]) {
    return [PLMValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value) {
      return [value isKindOfClass:[NSDictionary class]]
        ? [targetClass objectWithPolymorphRawData:[value mutableCopy]]
        : nil;
    } reverseBlock:^id (id<PLMRawDataProvider> value) {
      return [value respondsToSelector:@selector(polymorphRawData)] ? value.polymorphRawData : nil;
    }];
  }
  return nil;
}

static id getter_impl(NSObject<PLMRawDataProvider> *self,
                      NSString *jsonField,
                      NSValueTransformer *transformer,
                      Class targetClass,
                      BOOL useKeypath,
                      const void *key)
{
  id value = objc_getAssociatedObject(self, key);
  if (value) {
    return value;
  }

  value = useKeypath ? [self.polymorphRawData valueForKeyPath:jsonField] : self.polymorphRawData[jsonField];

  if (value == [NSNull null]) {
    value = nil;
  }

  if (transformer) {
    value = [transformer transformedValue:value];
  }

  safety_type_check(value, targetClass);

  objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  return value;
}

static BOOL inject_getter(Class cls,
                          ext_propertyAttributes *attrs,
                          NSString *jsonFieldName,
                          NSValueTransformer *transformer,
                          BOOL useKeypath)
{
  NSCParameterAssert(attrs != nil && jsonFieldName != nil);

  id getter = nil;

#define PRIMITIVE_GETTER_1(TYPE) \
  else if (strcmp(attrs->type, @encode(TYPE)) == 0) { \
    getter = ^TYPE (NSObject<PLMRawDataProvider> *self_) {

#define PRIMITIVE_GETTER_0(SELECTOR) \
      id value = useKeypath \
        ? [self_.polymorphRawData valueForKeyPath:jsonFieldName] \
        : self_.polymorphRawData[jsonFieldName]; \
      if (value == [NSNull null]) { value = nil; } \
      if (transformer) { value = [transformer transformedValue:value]; } \
      safety_type_check(value, [NSValue class]); \
      return [value SELECTOR]; \
    }; \
  }

#define PRIMITIVE_GETTERS(...) metamacro_foreach(PRIMITIVE_GETTERS_ITER,, __VA_ARGS__)
#define PRIMITIVE_GETTERS_ITER(INDEX, VAL) metamacro_concat(PRIMITIVE_GETTER_, metamacro_is_even(INDEX))(VAL)

  if (attrs->type[0] == '@') {
    SEL name = attrs->getter;
    Class targetClass = attrs->objectClass;
    getter = ^(NSObject<PLMRawDataProvider> *self_) {
      return getter_impl(self_, jsonFieldName, transformer, targetClass, useKeypath, name);
    };
  }
  PRIMITIVE_GETTERS(char, charValue, int, intValue, short, shortValue,
                    long, longValue, long long, longLongValue)
  PRIMITIVE_GETTERS(unsigned char, unsignedCharValue, unsigned int, unsignedIntValue,
                    unsigned short, unsignedShortValue, unsigned long, unsignedLongValue,
                    unsigned long long, unsignedLongLongValue)
  PRIMITIVE_GETTERS(float, floatValue, double, doubleValue, BOOL, boolValue)

  PRIMITIVE_GETTERS(NSRange, rangeValue)

#if TARGET_OS_MAC && ! TARGET_OS_IPHONE
  PRIMITIVE_GETTERS(CGPoint, pointValue, CGSize, sizeValue, CGRect, rectValue,
                    NSEdgeInsets, edgeInsetsValue)
#else
  PRIMITIVE_GETTERS(CGPoint, CGPointValue, CGSize, CGSizeValue, CGRect, CGRectValue,
                    CGVector, CGVectorValue, CGAffineTransform, CGAffineTransformValue,
                    UIEdgeInsets, UIEdgeInsetsValue, UIOffset, UIOffsetValue)
#endif /* TARGET_OS_MAC && ! TARGET_OS_IPHONE */

  NSCAssert(getter != nil, @"Getter should be generated");

  NSCAssert(strlen(attrs->type) < 250, @"Property type name should not be that long.");

  char types[4] = "*@:";
  types[0] = attrs->type[0];
  return class_addMethod(cls, attrs->getter, imp_implementationWithBlock(getter), types);
}

static void setter_impl(NSObject<PLMRawDataProvider> *self,
                        NSString *jsonField,
                        id value,
                        NSValueTransformer *transformer,
                        const void *key)
{
  objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  if (transformer) {
    value = [transformer reverseTransformedValue:value];
  }

  [self.polymorphRawData setValue:value forKey:jsonField];
}

static BOOL inject_setter(Class cls,
                          ext_propertyAttributes *attrs,
                          NSString *jsonFieldName,
                          NSValueTransformer *transformer)
{
  id setter = nil;

#define PRIMITIVE_SETTER_ITER(INDEX, TYPE) \
  else if (strcmp(attrs->type, @encode(TYPE)) == 0) { \
    setter = ^(NSObject<PLMRawDataProvider> *self_, TYPE value) { \
      NSNumber *number = @(value); \
      if (transformer) { number = [transformer reverseTransformedValue:number]; } \
      self_.polymorphRawData[jsonFieldName] = number; \
    }; \
  }

#define PRIMITIVE_SETTERS(...) metamacro_foreach(PRIMITIVE_SETTER_ITER,, __VA_ARGS__)

#define STRUCT_SETTER_1(TYPE) \
  else if (strcmp(attrs->type, @encode(TYPE)) == 0) { \
    setter = ^(NSObject<PLMRawDataProvider> *self_, TYPE value) {

#define STRUCT_SETTER_0(SELECTOR) \
      NSValue *result = [NSValue SELECTOR:value]; \
      if (transformer) { result = [transformer reverseTransformedValue:result]; } \
      self_.polymorphRawData[jsonFieldName] = result; \
    }; \
  }

#define NSVALUE_SETTERS(...) metamacro_foreach(NSVALUE_SETTERS_ITER,, __VA_ARGS__)
#define NSVALUE_SETTERS_ITER(INDEX, VAL) metamacro_concat(STRUCT_SETTER_, metamacro_is_even(INDEX))(VAL)

  if (attrs->type[0] == '@') {
    ext_propertyMemoryManagementPolicy mmp = attrs->memoryManagementPolicy;
    SEL name = attrs->getter;
    setter = ^(NSObject<PLMRawDataProvider> *self_, id value) {
      value = mmp == ext_propertyMemoryManagementPolicyCopy ? [value copy] : value;
      return setter_impl(self_, jsonFieldName, value, transformer, name);
    };
  }
  PRIMITIVE_SETTERS(         char,          int,          short,          long,          long long,
                    unsigned char, unsigned int, unsigned short, unsigned long, unsigned long long,
                    float,       double,
                    BOOL)
  NSVALUE_SETTERS(NSRange, valueWithRange)

#if TARGET_OS_MAC && ! TARGET_OS_IPHONE
  NSVALUE_SETTERS(CGPoint, valueWithPoint, CGSize, valueWithSize, CGRect, valueWithRect,
                  NSEdgeInsets, valueWithEdgeInsets)
#else
  NSVALUE_SETTERS(CGPoint, valueWithCGPoint, CGSize, valueWithCGSize, CGRect, valueWithCGRect,
                  CGVector, valueWithCGVector, CGAffineTransform, valueWithCGAffineTransform,
                  UIEdgeInsets, valueWithUIEdgeInsets, UIOffset, valueWithUIOffset)
#endif

  NSCAssert(setter != nil, @"Setter should be generated");

  NSCAssert(strlen(attrs->type) < 250, @"Class name should not be that long.");

  char types[5] = "v@:*";
  types[3] = attrs->type[0];
  return class_addMethod(cls, attrs->setter, imp_implementationWithBlock(setter), types);
}

#ifdef DEBUG

// If `class` activated Polymorph, it should not implement getter or setter for
// properties declared with `plm_dynamic`. This method will be used in DEBUG
// configuration to check that.
static void check_accessor(Class class)
{
  const char *ATTR_METHOD_PREFIX = "__plm_property_attr_";

  unsigned int index = 0;
  unsigned int count = 0;
  Class cls = class;
  Class *classes = ext_copySubclassList(class, &count);
  do {
    unsigned int methodsCount;
    Method *methods = class_copyMethodList(object_getClass(cls), &methodsCount);
    for (unsigned int index = 0; index < methodsCount; ++index) {
      const char *methodName = sel_getName(method_getName(methods[index]));
      if (strncmp(methodName, ATTR_METHOD_PREFIX, strlen(ATTR_METHOD_PREFIX)) == 0) {
        const char *propertyName = methodName + strlen(ATTR_METHOD_PREFIX);
        ext_propertyAttributes *attrs = ext_copyPropertyAttributes(class_getProperty(cls, propertyName));
        if (attrs) {
          NSCAssert(ext_getImmediateInstanceMethod(cls, attrs->getter) == nil,
                    @"Class `%s` use polymorph for property `%s`, it should not implement getter `%s`.",
                    class_getName(cls), propertyName, sel_getName(attrs->getter));
          NSCAssert(ext_getImmediateInstanceMethod(cls, attrs->setter) == nil,
                    @"Class `%s` use polymorph for property `%s`, it should not implement setter `%s`.",
                    class_getName(cls), propertyName, sel_getName(attrs->setter));

          free(attrs);
        }
      }
    }

    if (methods) {
      free(methods);
    }

    cls = index < count ? classes[index] : nil;
    ++index;
  } while (cls != nil);

  if (classes) {
    free(classes);
  }
}

#endif /* defined DEBUG */

@implementation NSObject (Polymorph)

+ (void)plm_activate
{
  NSCParameterAssert([self conformsToProtocol:@protocol(PLMRawDataProvider)]);

  // Find the root class that implements `PLMRawDataProvider` protocol,
  // we only need to swizzle the root class's method implemenation.
  Class polymorphRootClass = self;
  while ([class_getSuperclass(polymorphRootClass) conformsToProtocol:@protocol(PLMRawDataProvider)]) {
    polymorphRootClass = class_getSuperclass(polymorphRootClass);
  }

  @synchronized(polymorphRootClass) {
    // Check if we have already swizzled implementation.
    static const void *activationKey = &activationKey;
    if ([objc_getAssociatedObject(polymorphRootClass, activationKey) boolValue]) {
      PLMLog(@"Already swizzled.");
      return;
    }

#ifdef DEBUG
    check_accessor(polymorphRootClass);
#endif /* defined DEBUG */

    objc_setAssociatedObject(polymorphRootClass, activationKey, @(YES), OBJC_ASSOCIATION_RETAIN);

    Class metaCls = object_getClass((id)polymorphRootClass);
    NSCAssert(class_isMetaClass(metaCls), @"Should be a meta class.");

    SEL original = @selector(resolveInstanceMethod:);
    SEL replacement = @selector(plm_resolveInstanceMethod:);
    class_addMethod(metaCls, original,
                    class_getMethodImplementation(metaCls, original),
                    method_getTypeEncoding(class_getInstanceMethod(metaCls, original)));
    class_addMethod(metaCls, replacement,
                    class_getMethodImplementation(metaCls, replacement),
                    method_getTypeEncoding(class_getInstanceMethod(metaCls, replacement)));
    method_exchangeImplementations(class_getInstanceMethod(metaCls, original),
                                   class_getInstanceMethod(metaCls, replacement));
  }
}

+ (BOOL)plm_resolveInstanceMethod:(SEL)sel
{
  if ([self plm_resolveInstanceMethod:sel]) {
    return YES;
  }

  NSCAssert([self conformsToProtocol:@protocol(PLMRawDataProvider)],
            @"This message should only be sent to classes that conform to `PLMRawDataProvider` protocol");

  BOOL getter = NO;
  objc_property_t property = NULL;
  ext_propertyAttributes *attrs = copy_property_attrs(self, sel, &getter, &property);
  if (attrs == NULL) {
    // NO property found
    return NO;
  }

  @onExit { free(attrs); };

  if (!attrs->dynamic) { return NO; }

  SEL dpAttrsSel = NSSelectorFromString([NSString stringWithFormat:@"__plm_property_attr_%s",
                                         property_getName(property)]);
  if (![self respondsToSelector:dpAttrsSel]) {
    return NO;
  }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  NSDictionary *dpAttrs = [self performSelector:dpAttrsSel];
#pragma clang diagnostic pop

  NSString *jsonField = dpAttrs[_PolymorphAttributeJSONField]
    ?: [[NSString stringWithUTF8String:property_getName(property)] lowercaseString];

  id transformerAttr = dpAttrs[_PolymorphAttributeTransformer];
  NSValueTransformer *transformer = nil;
  if ([transformerAttr isKindOfClass:[NSString class]]) {
    transformer = [NSValueTransformer valueTransformerForName:transformerAttr];
  } else if ([transformerAttr isKindOfClass:[NSValueTransformer class]]) {
    transformer = transformerAttr;
  }
  if (attrs->objectClass && transformer == nil) {
    transformer = default_transformer(attrs->objectClass);
  }

  BOOL useKeypath = [dpAttrs[_PolymorphAttributeKeypath] boolValue];

  if (useKeypath) {
    NSCAssert(attrs->readonly, @"keypath accessor only support readonly property");
  }

  return getter
    ? inject_getter(self, attrs, jsonField, transformer, useKeypath)
    : inject_setter(self, attrs, jsonField, transformer);
}

@end
