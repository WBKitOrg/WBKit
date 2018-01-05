//
//  NSObject+MessageRequest.h
//  xuxian
//
//  Created by wangbo on 16/11/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBMessageRequestListener <NSObject>
/**
 *  接收事件通知方法
 */
@required
-(void)listenRequest:(id)requestParams response:(void(^)(id responseParams))responseBlock;
@end

@protocol WBMessageRequestCallbackDelegate <NSObject>
/**
 *  请求回调函数
 */
@optional
- (void (^)(id))needComplete;//获取请求的回调
- (void)setNeedComplete:(void (^)(id))needComplete;//设置请求的回调
@end


@interface NSObject (MessageRequest) <WBMessageRequestCallbackDelegate>

-(BOOL)wb_messageRequest_registeListenner;
-(void)wb_messageRequest_unRegisteListenner;    //dealloc方法中务调用必解注册

-(void)wb_messageRequest_request:(NSString *)recieverId params:(id)params complete:(void(^)(id response))complete;

@end
