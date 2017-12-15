//
//  WBWebSocketManager.h
//
//  Created by wangbo on 16/9/7.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "WBWebSocketMessage.h"


@protocol WBWebSocketMessageDelegate <NSObject>

-(void)DidMessageNeedParse:(id)msg;//给需要单独处理message的类使用

@end


@interface WBWebSocketManager : NSObject<SRWebSocketDelegate>

#pragma mark - 属性

@property (nonatomic , assign)BOOL reconnectable;//是否尝试重连
///message处理代理
@property (weak)id<WBWebSocketMessageDelegate> delegate;
#pragma mark - 单独回调

/**
 *  这两个方法只负责重连的回调
 */
@property (copy)void (^DidReconnectSuccess)(BOOL ifsuccess);//重连成功回调
@property (copy)void (^DidReconnectError)(NSError *err);//重连失败或者链接断开回调

/**
 *  获取到后台发给客户端的消息
 */
@property (copy)void (^DidRecieveMessage)(id Data);


#pragma mark - 方法

+ (WBWebSocketManager *) sharedManager;//单例方法
/**
 *  连接服务器方法
 */
- (void)connectUrl:(NSURL *)url success:(void(^)(BOOL isconnect)) success fail:(void(^)(NSError *err)) error;
/**
 *  断开服务器方法
 */
- (void)disConnect;
/**
 *  发送消息方法
 */
- (void)sendMessage:(NSDictionary *)params success:(void(^)(id)) success fail:(void(^)(NSError *)) error;

@end
