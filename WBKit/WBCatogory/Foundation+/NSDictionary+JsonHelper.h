//
//  NSDictionary+JsonHelper.h
//  WBKit
//
//  Created by wangbo on 2018/1/22.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JsonHelper)

+ (id)dictionaryWithJsonData:(NSData *)data;
+ (id)dictionaryWithJsonString:(NSString *)string;

- (NSData *)toJsonData;
- (NSString *)toJsonString;

@end
