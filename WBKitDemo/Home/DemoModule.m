//
//  DemoModule.m
//  WBKitDemo
//
//  Created by wangbo on 2017/12/29.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "DemoModule.h"

@implementation DemoModule

REGISTER_MODULE

+ (NSInteger)priority
{
    return WBModulePriorityVeryHigh;
}

- (void)moduleDidInit:(WBModuleManager *)manager
{
    //do some manager init
    
    [self registerRoutes];
}

- (void)registerRoutes
{
    [WBURLRoute registerPattern:@"demo/test?id=&time=" handler:^BOOL(NSDictionary *param, WBRouteCallback callback) {
        if ([param valueForKey:@"id"]) {
            NSLog(@"getRequestWith:id = %@",[param valueForKey:@"id"]);
        }
        if (callback) {
            callback(@{@"doneTime":[NSDate date]});
        }
        return YES;
    }];
}

@end
