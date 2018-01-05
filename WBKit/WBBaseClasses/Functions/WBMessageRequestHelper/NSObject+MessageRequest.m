//
//  NSObject+MessageRequest.m
//  xuxian
//
//  Created by wangbo on 16/11/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "NSObject+MessageRequest.h"
#import "NSObject+IdentifyHelper.h"
#import "WBMessageTransferStation.h"
#import <objc/runtime.h>

@implementation NSObject (MessageRequest)

/**
 *  @brief 注册与解注册方法
 */
-(BOOL)wb_messageRequest_registeListenner{
    return [[WBMessageTransferStation sharedStation] registe:self wb_id:self.wb_id];
}
-(void)wb_messageRequest_unRegisteListenner{
    [[WBMessageTransferStation sharedStation] remove:self wb_id:self.wb_id];
}

-(void)wb_messageRequest_request:(NSString *)recieverId params:(id)params complete:(void(^)(id response))complete{
    [self setNeedComplete:complete];
    [[WBMessageTransferStation sharedStation] postMessage:params from:self.wb_id to:recieverId];
}

#pragma mark - 设置属性

- (void)setNeedComplete:(void (^)(id))needComplete
{
    objc_setAssociatedObject(self, @"wb_messageRquest_needComplete_key", needComplete, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(id))needComplete
{
    return objc_getAssociatedObject(self, @"wb_messageRquest_needComplete_key");
}

@end
