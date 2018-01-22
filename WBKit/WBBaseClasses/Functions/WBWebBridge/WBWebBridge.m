//
//  WBWebBridge.m
//  WBKit
//
//  Created by wangbo on 2018/1/22.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "WBWebBridge.h"
#import "NSDictionary+JsonHelper.h"


@interface WBWebBridge ()<WKScriptMessageHandler>

@property (nonatomic, strong) NSMutableDictionary *handlers;
@property (nonatomic, weak) WKWebView *webView;

@end

@interface WBWebBridgeHandlerCallback ()

@property (nonatomic, weak) WBWebBridge *bridge;
@property (nonatomic, copy) NSString *callId;

- (instancetype)initWithBridge:(WBWebBridge *)bridge callId:(NSString *)callId;

@end

@implementation WBWebBridge

+ (instancetype)sharedWebBridge
{
    static dispatch_once_t onceToken;
    static id bridge = nil;
    dispatch_once(&onceToken, ^{
        bridge = [[WBWebBridge alloc] init];
    });
    return bridge;
}

- (instancetype)initWithWebView:(WKWebView *)webView
{
    self = [super init];
    if (self) {
        self.webView = webView;
        self.handlers = [NSMutableDictionary dictionaryWithCapacity:10];
        [self install];
    }
    return self;
}

#pragma mark -- public
- (void)install
{
    WKUserContentController *controller = self.webView.configuration.userContentController;
    [controller addScriptMessageHandler:self name:self.dataSource.localBridgeName];
}

- (void)registHandler:(WBWebBridgeHandler)handler key:(NSString *)key
{
    self.handlers[key] = handler;
}

- (void)unregisterHandler:(WBWebBridgeHandler)handler key:(NSString *)key
{
    [self.handlers removeObjectForKey:key];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (![message.name isEqualToString:self.dataSource.localBridgeName] || ![self.dataSource canBridge:message]) {
        return;
    }
    NSString *uniqueKey = [self.dataSource methodKeyWithScriptMessage:message];
    WBWebBridgeHandler handler = self.handlers[uniqueKey];
    WBWebBridgeHandlerCallback *callback = [[WBWebBridgeHandlerCallback alloc] initWithBridge:self callId:[self.dataSource callIdWithScriptMessage:message]];
    if (handler) {
        handler(message.body, callback);
    } else {
        [callback unSupport];
    }
}

- (void)notifyCallbackCallId:(NSString *)callId data:(NSDictionary *)data error:(NSError *)error
{
    NSString *jsFormat = [self.dataSource.jsBridgeName stringByAppendingString:@".%@(%@)"];
    NSDictionary *ret;
    if (error) {
        NSInteger code = error.code;
        NSString *domain = error.domain;
        NSDictionary *userInfo = error.userInfo;
        NSDictionary *errorDict = @{@"code": @(code),
                                  @"domain": domain,
                                @"userInfo": userInfo};
        ret = @{@"error": errorDict, @"callId": callId};
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        if (data) {
            dict[@"data"] = data;
        }
        dict[@"callId"] = callId;
        ret = dict;
    }
    NSString *js = [NSString stringWithFormat:jsFormat, [ret toJsonString]];

    [self.webView evaluateJavaScript:js completionHandler:^(id ret, NSError * error) {
        NSLog(@"evaluateJavaScript completion: ret:%@, error: %@", ret, error);
    }];
}

@end

@implementation WBWebBridgeHandlerCallback

- (instancetype)initWithBridge:(WBWebBridge *)bridge callId:(NSString *)callId
{
    self = [super init];
    if (self) {
        self.bridge = bridge;
        self.callId = callId;
    }
    return self;
}

- (void)success:(NSDictionary *)data
{
    [self.bridge notifyCallbackCallId:self.callId data:data error:nil];
}

- (void)failure:(NSError *)error
{
    [self.bridge notifyCallbackCallId:self.callId data:nil error:error];
}

- (void)unSupport
{
    NSError *error = [[NSError alloc] initWithDomain:@"core" code:1 userInfo:@{@"errorMessage":@"not support"}];
    [self failure:error];
}

@end

