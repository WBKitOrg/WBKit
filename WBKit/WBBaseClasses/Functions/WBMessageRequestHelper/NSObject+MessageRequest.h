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
-(void)WB_listenRequest:(id)requestParams response:(void(^)(id responseParams))responseBlock;
@end

@protocol WBMessageRequestCallbackDelegate <NSObject>
/**
 *  请求回调函数
 */
@optional
- (void (^)(id))WB_NeedCompish;//获取请求的回调
- (void)setWB_NeedCompish:(void (^)(id))NeedCompish;//设置请求的回调
@end


@interface NSObject (MessageRequest)

@property (nonatomic , strong)NSString *WB_idurl;

-(BOOL)WB_registeListennerWithIdurl:(NSString *)url;
-(void)WB_removeFromMessageTransferStation;

-(void)WB_requestURL:(NSString *)url withParams:(id)params complete:(void(^)(id response))complete;

@end
