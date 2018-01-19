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
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:[propertyValue propertyList] forKey:propertyName];
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
            id valueToSet;
            if ([[dictionary objectForKey:keyName] isKindOfClass:[NSDictionary class]]) {
                unsigned int outCount, i;
                objc_property_t *properties = class_copyPropertyList([self class], &outCount);
                for (i = 0; i<outCount; i++)
                {
                    objc_property_t property = properties[i];
                    const char* char_f =property_getName(property);
                    NSString *propertyName = [NSString stringWithUTF8String:char_f];
                    if ([propertyName isEqualToString:keyName]) {
                        const char * type = property_getAttributes(property);
                        NSString * typeString = [NSString stringWithUTF8String:type];
                        NSArray * attributes = [typeString componentsSeparatedByString:@","];
                        NSString * typeAttribute = [attributes objectAtIndex:0];
                        if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1) {
                            NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];
                            Class typeClass = NSClassFromString(typeClassName);
                            if (typeClass != nil) {
                                valueToSet = [[typeClass alloc] initWithDictionary:[dictionary objectForKey:keyName]];
                            }
                        }
                        break;
                    }
                }
            } else {
                valueToSet = [dictionary objectForKey:keyName];
            }
            if (valueToSet) {
                [self setValue:valueToSet forKey:keyName];
            }
        }//end for
        return self;
    }//end if
    return nil;
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
