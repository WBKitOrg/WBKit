//
//  WBWebSocketMessage.m
//  xuxian60
//
//  Created by wangbo on 16/9/8.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "WBWebSocketMessage.h"

@implementation WBWebSocketMessage

-(instancetype)init{
    self = [super init];
    if (self) {
        //开启自身计时器 30秒自毁
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.ErrorBlcok) {
                NSError *err = [NSError errorWithDomain:@"WBWebSocketMessage发送失败" code:1 userInfo:nil];
                self.ErrorBlcok(err);
                [self destory];
            }
        });
    }
    return self;
}


-(void)destory{
    self.MessageBody = nil;
    self.timeInterval = 0;
    self.SuccessBlock = nil;
    self.ErrorBlcok = nil;
}

@end
