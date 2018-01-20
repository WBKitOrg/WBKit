//
//  DemoModel.m
//  WBKitDemo
//
//  Created by wangbo on 2018/1/18.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "DemoModel.h"


@implementation DemoSubModel

@end

@implementation DemoSubModelInArray

@end

@implementation DemoModel

+ (NSDictionary *)keyNameForPropertyName
{
    return @{
             @"ID": @"id",
             };
}

+ (NSArray *)subModelsInArrayPropertis
{
    return @[[DemoSubModelInArray class]];
}

@end

