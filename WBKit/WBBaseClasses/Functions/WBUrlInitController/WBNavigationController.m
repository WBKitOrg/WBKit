//
//  WBNavigationController.m
//  WBUtil
//
//  Created by wangbo on 16/9/19.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "WBNavigationController.h"
#import "UIViewController+WBUrlInit.h"
#import "NSObject+MessageRequest.h"

@interface WBNavigationController ()

@end

@implementation WBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Function - setter & getter

-(void)setStatusBarLight:(BOOL)statusBarLight{
    _statusBarLight = statusBarLight;
    [self setNeedsStatusBarAppearanceUpdate];
}



#pragma mark - Function - statusbar相关

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (!_statusBarLight) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

#pragma mark - Function - 旋转相关

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.interfaceOrientationsOpen) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Function - Navigation

- (void)openURL:(NSURL *)url withParams:(NSDictionary *)params animate:(BOOL)animate{
    UIViewController * vc = [UIViewController viewControllerWithUrl:url params:params];
    vc.nav = self;
    [self pushViewController:vc animated:animate];
}

- (nullable NSArray<__kindof UIViewController *> *)popToURL:(NSURL *)url animate:(BOOL)animate{
    UIViewController * viewController = nil;
    Class class = NSClassFromString(url.host);
    for (UIViewController * vc in self.viewControllers) {
        if ([vc isKindOfClass:class]) {
            viewController = vc;
        }
    }
    if (viewController) {
        return [self popToViewController:viewController animated:animate];
    }
    return nil;
}

- (void)goToURL:(NSURL * _Nonnull)url withParams:(NSDictionary * _Nullable)params animate:(BOOL)animate{
    Class class = NSClassFromString(url.host);
    for (UIViewController<WBMessageRequestListener> * vc in self.viewControllers) {
        if ([vc isKindOfClass:class] && [vc.url isEqual:url]) {//找到url对应的vc
            //如果监听事件，发送消息
            if ([vc respondsToSelector:@selector(WB_listenRequest:response:)]) {
                [vc WB_listenRequest:params response:^(id responseParams) {
                }];
            }
            //退到这个页面
            [self popToViewController:vc animated:animate];
            return;
        }
    }
    //没找到走到这里
    UIViewController * vc = [UIViewController viewControllerWithUrl:url params:params];
    vc.nav = self;
    [self pushViewController:vc animated:animate];
}

-(WBNavigationController *)nav{
    return self;
}

#pragma mark - Function - Request

//- (BOOL)requestURL:(NSURL * _Nonnull)url withParams:(id _Nullable)params complete:(void(^ _Nullable)(_Nullable id response))complete{
////    UIViewController<WBViewControllerActionListener> * viewController = nil;
//    Class class = NSClassFromString(url.host);
//    for (UIViewController<WBViewControllerActionListener> * vc in self.viewControllers) {
//        if ([vc isKindOfClass:class] && [vc.url isEqual:url]) {//找到url对应的vc
//            if ([vc respondsToSelector:@selector(listenRequest:response:)]) {
//                [vc listenRequest:params response:complete];
//                return YES;
//            }
//        }
//    }
//    return NO;
//}


@end
