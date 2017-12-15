//
//  UIViewController+WBUrlInit.m
//  WBUtil
//
//  Created by wangbo on 16/9/19.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "UIViewController+WBUrlInit.h"
#import "WBNavigationController.h"
#import "NSObject+MessageRequest.h"
#import <objc/runtime.h>

@implementation UIViewController (WBUrlInit)

static char WBUrlinitParamsKey;
static char WBUrlinitUrlKey;
static char WBUrlinitNavigationKey;
//static char WBUrlinitNeedCompishKey;

#pragma mark - Function - setter & getter

- (void)setParams:(NSDictionary *)params
{
    objc_setAssociatedObject(self, &WBUrlinitParamsKey, params,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)params
{
    return objc_getAssociatedObject(self, &WBUrlinitParamsKey);
}

- (void)setNav:(WBNavigationController *)nav
{
    objc_setAssociatedObject(self, &WBUrlinitNavigationKey, nav, OBJC_ASSOCIATION_ASSIGN);
}

- (WBNavigationController *)nav
{
    WBNavigationController *definedNav = objc_getAssociatedObject(self, &WBUrlinitNavigationKey);
    if (definedNav) {
        return definedNav;
    }else if ([self.navigationController isKindOfClass:[WBNavigationController class]]){
        return (WBNavigationController *)self.navigationController;
    }
    return nil;
}

- (void)setUrl:(NSURL *)url
{
    objc_setAssociatedObject(self, &WBUrlinitUrlKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    /**
     *  注册url后需要做通知的注册，实现解藕传输
     */
    [self registerWBNotification];
}

- (NSURL *)url
{
    return objc_getAssociatedObject(self, &WBUrlinitUrlKey);
}

//- (void)setNeedCompish:(void (^)(id))NeedCompish
//{
//    objc_setAssociatedObject(self, &WBUrlinitNeedCompishKey, NeedCompish, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (void (^)(id))NeedCompish
//{
//    return objc_getAssociatedObject(self, &WBUrlinitNeedCompishKey);
//}

#pragma mark - Function - init 

+(instancetype)viewControllerWithUrl:(NSURL *)url params:(NSDictionary *)params{
    Class wantclass;
    if ([url.scheme hasPrefix:@"http"]) {
        wantclass = NSClassFromString(@"WBWebViewController");
    }else{
        //这里如果需要路由的话可以加入路由表功能
        wantclass = NSClassFromString(url.host);
    }
    UIViewController *viewController = [[wantclass alloc] init];
    viewController.url = url;
    viewController.params = params;
    
    NSLog(@"WB初始化:url = %@,VC = %@",url.absoluteString,self);
    return viewController;
}

-(void)registerWBNotification{
    [self WB_registeListennerWithIdurl:self.url.absoluteString];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveWBNotification:)
//                                                 name:self.url.absoluteString object:nil];
}

#pragma mark - Function - dealloc

+(void)load{
    [super load];
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc")), class_getInstanceMethod(self.class, @selector(WB_Dealloc)));
}

-(void)WB_Dealloc{
    NSLog(@"WB释放:VC = %@",self);
    [self WB_removeFromMessageTransferStation];
    //        [[NSNotificationCenter defaultCenter] removeObserver:self];
    //        [[WBMessageTransferStation sharedStation] remove:self ForUrl:self.url.absoluteString];
    [self WB_Dealloc];
}

#pragma mark - Function - request &listenner

//-(void)postMessage:(id)message messageType:(WBNotifyMessageType)type from:(NSURL *)fromUrl to:(NSURL *)toUrl{
//    
//    NSMutableDictionary *notifyData = [NSMutableDictionary dictionary];
//    if (message) {
//        [notifyData setValue:message forKey:@"message"];
//    }
//    if (type == WBNotifyMessageTypeSend) {
//        [notifyData setValue:@"send" forKey:@"type"];
//    }else{
//        [notifyData setValue:@"response" forKey:@"type"];
//    }
//    [notifyData setValue:fromUrl forKey:@"from"];
//    
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:toUrl.absoluteString object:nil userInfo:notifyData];
//}
//
//-(void)didReceiveWBNotification:(NSNotification *)notification{
//    if ([[notification.userInfo valueForKey:@"type"] isEqualToString:@"send"]) {//对方发送给当前类，需要当前类回复
//        __weak typeof (self) weakSelf = self;
//        
//        [self listenRequest:[notification.userInfo valueForKey:@"message"] response:^(id responseParams) {
//            [weakSelf postMessage:responseParams messageType:WBNotifyMessageTypeResponse from:weakSelf.url to:[notification.userInfo valueForKey:@"from"]];
//        }];
//    }
//    else if([[notification.userInfo valueForKey:@"type"] isEqualToString:@"response"]){
//        
//        self.NeedCompish([notification.userInfo valueForKey:@"message"]);
//        self.NeedCompish = nil;
//    }
//}
//
//-(void)requestURL:(NSURL *)url withParams:(id)params complete:(void(^)(id response))complete{
//    if ([self.nav respondsToSelector:@selector(requestURL:withParams:complete:)]) {
//        if (![self.nav requestURL:url?url:[NSURL URLWithString:@""] withParams:params complete:complete]) {
//            //设置回调函数
//            self.NeedCompish = complete;
//            //以通知形式发送
//            [self postMessage:params messageType:WBNotifyMessageTypeSend from:self.url to:url];
//        }
//    }else{
//        //设置回调函数
//        self.NeedCompish = complete;
//        //以通知形式发送
//        [self postMessage:params messageType:WBNotifyMessageTypeSend from:self.url to:url];
//    }
//}
//
//-(void)listenRequest:(id)requestParams response:(void(^)(id responseParams))responseBlock{
//    
//}

@end
