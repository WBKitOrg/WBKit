//
//  UIViewController+WBUrlInit.h
//  WBUtil
//
//  Created by wangbo on 16/9/19.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBNavigationController;


//typedef enum{
//    WBNotifyMessageTypeSend = 0,
//    WBNotifyMessageTypeResponse,
//}WBNotifyMessageType;


//@protocol WBViewControllerActionListener <NSObject>
///**
// *  接收事件通知方法
// */
//@required
//-(void)listenRequest:(id)requestParams response:(void(^)(id responseParams))responseBlock;
//
//@end

//@protocol WBViewControllerActionRequest <NSObject>
///**
// * 发送消息方法
// */
//@optional
//-(void)requestURL:(NSURL *)url withParams:(id)params complete:(void(^)(id response))complete;
//
//@end


@interface UIViewController (WBUrlInit)


////<WBViewControllerActionListener,WBViewControllerActionRequest>

/**
 * 拓展属性
 */
@property (nonatomic,retain) NSURL *url;//vc的url，根据这个url找到对应vc
@property (nonatomic,retain) NSDictionary *params;//vc接收参数的字典
@property (nonatomic,retain) WBNavigationController *nav;//返回一个多控制功能的自定义navigation
//@property (nonatomic , copy) void(^NeedCompish)(id response);//返回回调
/**
 * 关键方法,ps:初始化url是协议后面的url
 */
+(instancetype)viewControllerWithUrl:(NSURL *)url params:(NSDictionary *)params;



@end

