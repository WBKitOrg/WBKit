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
        if (propertyValue) [props setObject:[propertyValue propertyList] forKey:redirectedKeyName.length>0?redirectedKeyName:propertyName];
    }
    free(properties);
    if (props.allKeys.count>0) {
        return props;
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

@end
