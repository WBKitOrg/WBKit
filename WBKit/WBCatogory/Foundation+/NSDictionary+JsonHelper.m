//
//  NSDictionary+JsonHelper.m
//  WBKit
//
//  Created by wangbo on 2018/1/22.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "NSDictionary+JsonHelper.h"

@implementation NSDictionary (JsonHelper)

+ (id)dictionaryWithJsonData:(NSData*)data
{
    if(!data)
    {
        NSLog(@"error: data is nil");
        return nil;
    }
    
    NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if(ret && ![ret isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"error: data not a NSDictionary json");
        return nil;
    }
    
    return ret;
}

+ (id)dictionaryWithJsonString:(NSString *)string
{
    return [NSDictionary dictionaryWithJsonData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData*)toJsonData
{
    return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
}

- (NSString*)toJsonString
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    
    return jsonString;
}

@end
