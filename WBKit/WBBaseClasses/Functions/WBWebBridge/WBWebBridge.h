//
//  WBWebBridge.h
//  WBKit
//
//  Created by wangbo on 2018/1/22.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WBWebBridgeHandlerCallback : NSObject
- (void)success:(NSDictionary *)data;
- (void)failure:(NSError *)error;
- (void)unSupport;
@end


@protocol WBWebBridgeDelegate <NSObject>


@end

@protocol WBWebBridgeDataSource <NSObject>

@required
///本地controlBridge名称，供js调用
- (NSString *)localBridgeName;
///本地注册回调名称
- (NSString *)methodKeyWithScriptMessage:(WKScriptMessage *)message;
///js单次调用bridge的方法id
- (NSString *)callIdWithScriptMessage:(WKScriptMessage *)message;

///js中iosBridge名称，供ios原生代码调用
- (NSString *)jsBridgeName;
///回调js代码方法名
- (NSString *)jsResponseFunctionName;

- (BOOL)canBridge:(WKScriptMessage *)message;

@end

typedef void (^WBWebBridgeHandler)(id messageBody, WBWebBridgeHandlerCallback *callback);

@interface WBWebBridge : NSObject

@property (nonatomic, assign) id <WBWebBridgeDelegate> delegate;
@property (nonatomic, assign) id <WBWebBridgeDataSource> dataSource;

- (instancetype)initWithWebView:(WKWebView *)webView;

- (void)registHandler:(WBWebBridgeHandler)handler key:(NSString *)key;

- (void)unregisterHandler:(WBWebBridgeHandler)handler key:(NSString *)key;

@end
