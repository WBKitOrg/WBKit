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

#pragma mark -获取所有属性
- (NSDictionary *)propertyList
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
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
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

#pragma mark -字典转换为对象返回，这里没有类型验证，可以配合isKindOfData同时使用
-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [self init];
    if (dictionary && self) {
        
        for (NSString *keyName in [dictionary allKeys]) {
            //构建出属性的set方法
            NSString *UpFirstKeyName = [NSString stringWithFormat:@"%@%@",[[keyName substringToIndex:1] uppercaseString],[keyName substringFromIndex:1]];//大写首字母，因为存在_所以无法使用capitalizedString
            NSString *destMethodName = [NSString stringWithFormat:@"set%@:",UpFirstKeyName]; //capitalizedString返回每个单词首字母大写的字符串（每个单词的其余字母转换为小写）
            SEL destMethodSelector = NSSelectorFromString(destMethodName);
            
            if ([self respondsToSelector:destMethodSelector]) {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:destMethodSelector withObject:[dictionary objectForKey:keyName]];
#pragma clang diagnostic pop
                
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
