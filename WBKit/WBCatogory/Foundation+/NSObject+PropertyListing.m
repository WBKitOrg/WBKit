//
//  NSObject+PropertyListing.m
//  WBUtil
//
//  Created by Wang Bo. on 14-1-23.
//  Copyright (c) 2014年 Wang Bo. All rights reserved.
//

#import "NSObject+PropertyListing.h"
#import <objc/runtime.h>

@implementation NSObject (PropertyListing)

#pragma mark - PropertyRedirect

+ (NSDictionary *)keyNameForPropertyName
{
    return nil;
}

#pragma mark -获取所有对象方法
-(NSArray *)methodList
{
    NSMutableArray *methods = [NSMutableArray array];
    unsigned int mothCout_f =0;
    Method* mothList_f = class_copyMethodList([self class],&mothCout_f);
    for(int i=0;i<mothCout_f;i++)
    {
        Method temp_f = mothList_f[i];
        [methods addObject:CFBridgingRelease(temp_f)];
    }
    free(mothList_f);
    return methods;
}

#pragma mark -获取所有属性
- (id)propertyList
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:propertyName];
        NSString *redirectedKeyName;
        if ([[[self class] keyNameForPropertyName] valueForKey:propertyName]) {
            redirectedKeyName = [[[self class] keyNameForPropertyName] valueForKey:propertyName];
        }
        if (propertyValue) {
            if ([propertyValue isKindOfClass:[NSString class]]) {
                [props setObject:propertyValue forKey:redirectedKeyName.length>0?redirectedKeyName:propertyName];
            } else {
                [props setObject:[propertyValue propertyList] forKey:redirectedKeyName.length>0?redirectedKeyName:propertyName];
            }
        }
    }
    free(properties);
    if (props.allKeys.count>0) {
        return props;
    } else if ([self isKindOfClass:[NSArray class]]) {
        //数组单独处理
        NSMutableArray *array = [NSMutableArray array];
        [self enumberateContainedObjects:^(NSInteger index, id object) {
            [array addObject:[object propertyList]];
        }];
        return array;
    } else {
        return self;
    }
}

#pragma mark -字典转换为对象返回，这里没有类型验证，可以配合isKindOfData同时使用
-(id)initWithDictionary:(NSDictionary *)dictionary{
    if ([[self class] isKindOfClass:[NSDictionary class]]) {
        return dictionary;
    }
    self = [self init];
    if (dictionary && self) {
        for (NSString *keyName in [dictionary allKeys]) {
            id valueToSet = [self propertyValueForDictionaryKey:keyName inDictionary:dictionary];
            if (valueToSet) {
                NSString *redirectedPropertyName = [[[[self class] keyNameForPropertyName] allKeysForObject:keyName] firstObject];
                [self setValue:valueToSet forKey:(redirectedPropertyName.length>0?redirectedPropertyName:keyName)];
            }
        }//end for
        return self;
    }//end if
    return nil;
}

- (id)propertyValueForDictionaryKey:(NSString *)dictKey inDictionary:(NSDictionary *)dictionary
{
    id valueToSet;
    NSString *redirectedPropertyName = [[[[self class] keyNameForPropertyName] allKeysForObject:dictKey] firstObject];
    if ([[dictionary objectForKey:dictKey] isKindOfClass:[NSDictionary class]]) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (i = 0; i<outCount; i++) {
            objc_property_t property = properties[i];
            const char* char_f =property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            if ([propertyName isEqualToString:(redirectedPropertyName.length>0?redirectedPropertyName:dictKey)]) {
                //找到对应的属性
                const char * type = property_getAttributes(property);
                NSString * typeString = [NSString stringWithUTF8String:type];
                NSArray * attributes = [typeString componentsSeparatedByString:@","];
                NSString * typeAttribute = [attributes objectAtIndex:0];
                if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1) {
                    NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];
                    Class typeClass = NSClassFromString(typeClassName);
                    if (typeClass != nil) {
                        valueToSet = [[typeClass alloc] initWithDictionary:[dictionary objectForKey:dictKey]];
                    }
                } else {
                    //不是对象类型
                    valueToSet = [dictionary objectForKey:dictKey];
                }
                break;
            } else {
                //没找到对应属性
            }
        }
        free(properties);
    } else if ([[dictionary objectForKey:dictKey] isKindOfClass:[NSArray class]]) {
        NSArray *valueArray = [dictionary objectForKey:dictKey];
        NSMutableArray *translatedArray = [NSMutableArray array];
        [self enumberateArray:valueArray containedObjects:^(__unsafe_unretained Class type, id object) {
            [translatedArray addObject:object];
        }];
        valueToSet = translatedArray;
    } else {
        //统一处理
        valueToSet = [dictionary objectForKey:dictKey];
    }
    return valueToSet;
}


#pragma mark - 判断是否是一种model

-(BOOL)isKindOfData:(id)classtype{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return NO;
    }else if ([self isKindOfClass:classtype]){
        return YES;
    }
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(classtype, &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
        else [props setObject:[NSNull null] forKey:propertyName];
    }
    free(properties);
    
    for (NSString *key in [(NSDictionary *)self allKeys]) {
        if (![props valueForKey:key]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 遍历

- (void)enumberateContainedObjects:(void (^)(NSInteger index, id object))block
{
    if (![self isKindOfClass:[NSArray class]]) {
        block(0, self);
    } else {
        NSInteger count = ((NSArray *)self).count;
        for (NSInteger index = 0; index < count; ++index) {
            id subObject = ((NSArray *)self)[index];
            block(index, subObject);
        }
    }
}

- (void)enumberateArray:(NSArray *)array containedObjects:(void (^)(Class type, id object))block
{
    [array enumberateContainedObjects:^(NSInteger index, id object) {
        id model;
        if ([[self class] respondsToSelector:@selector(subModelsInArrayPropertis)]) {
            for (Class type in [[self class] subModelsInArrayPropertis]) {
                if ([object isKindOfData:type]) {
                    model = [[type alloc] initWithDictionary:object];
                    break;
                }
            }
        }
        if (!model) {
            model = object;
        }
        block([model class], model);
    }];
}

#pragma mark - 重写方法

//该方法不适合放在catogory中，应该放在model父类中重写
//- (NSUInteger)hash {
//    NSUInteger value = 0;
//
//    unsigned int outCount, i;
//    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
//    for (i = 0; i<outCount; i++)
//    {
//        objc_property_t property = properties[i];
//        const char* char_f =property_getName(property);
//        NSString *propertyName = [NSString stringWithUTF8String:char_f];
//        id propertyValue = [self valueForKey:(NSString *)propertyName];
//        value ^= [propertyValue hash];
//    }
//    free(properties);
//    
//    return value;
//}

@end
