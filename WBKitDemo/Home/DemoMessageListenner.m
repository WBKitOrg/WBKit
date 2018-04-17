//
//  DemoMessageListenner.m
//  WBKitDemo
//
//  Created by wangbo on 2018/1/4.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "DemoMessageListenner.h"

@implementation DemoMessageListenner

+ (DemoMessageListenner *)sharedListenner
{
    static dispatch_once_t onceToken;
    static DemoMessageListenner *sharedListenner = nil;
    dispatch_once(&onceToken, ^{
        sharedListenner = [[DemoMessageListenner alloc] init];
        [sharedListenner wb_messageRequest_registeListenner];
    });
    return sharedListenner;
}

-(void)listenRequest:(id)requestParams response:(void (^)(id))responseBlock
{
    NSLog(@"recieve request:%@",requestParams);
    responseBlock(@"I heared");
}

@end
