//
//  WBAppHelper.m
//  FlyClip
//
//  Created by wangbo on 2017/5/4.
//  Copyright © 2017年 tongboshu. All rights reserved.
//

#import "WBAppHelper.h"

@implementation WBAppHelper

+ (NSString*)getLocalAppVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString*)getBundleID
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString*)getAppName
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    return appName;
}

@end
