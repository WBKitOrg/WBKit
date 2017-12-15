//
//  WBWebViewController.h
//  WBUtilDemoProject
//
//  Created by wangbo on 16/9/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "UIViewController+WBUrlInit.h"


@protocol WBWebViewControllerActionListener <NSObject>

/**
 *  接收事件通知方法
 */
@required
-(void)listenFunction:(NSString *)functionName args:(id)message;

@end


@interface WBWebViewController : UIViewController


@property (nonatomic , retain)WKWebView *webView;

///request
@property (nonatomic , retain)NSURLRequest *req;

/// javascript上下文
@property (nonatomic , retain)JSContext *context;


///是否使用官方navigationbar的功能。默认是no
@property (nonatomic , assign)BOOL navigationBarUsage;//default is no

///js事件监听者代理
@property (nonatomic , assign)id<WBWebViewControllerActionListener> JSActionListenner;
///所接受的js事件名集合,这个地方在wkwebview中被替换了
//@property (nonatomic , retain)NSMutableArray *JSActionNames;
///屏蔽的host
@property (nonatomic , retain)NSString *bandHost;

@end
