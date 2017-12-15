//
//  WBWebSocketMessage.h
//  xuxian60
//
//  Created by wangbo on 16/9/8.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBWebSocketMessage : NSDictionary
///消息体
@property (nonatomic , retain)NSString *MessageBody;
///发送时间标示符
@property (nonatomic , assign)NSInteger timeInterval;

/**
 *  回调
 */
@property (copy) void(^SuccessBlock)(id response);
@property (copy) void(^ErrorBlcok)(NSError *err);//30秒默认失败超时

-(void)destory;

@end
