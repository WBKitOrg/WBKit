//
//  WBNavigationController.h
//  WBUtil
//
//  Created by wangbo on 16/9/19.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBNavigationController : UINavigationController

/**
 *  是否高亮statusBar,默认是no，样式是default
 */
@property (nonatomic,assign) BOOL statusBarLight;

/**
 *  是否支持屏幕旋转,默认是no，不支持旋转
 */
@property (nonatomic,assign) BOOL interfaceOrientationsOpen;

/**
 *  url启动vc以及返回vc，做到vc之间无耦合,并且不可互相使用参数
 */
- (void)openURL:(NSURL * _Nonnull)url withParams:(NSDictionary * _Nullable)params animate:(BOOL)animate;
- (nullable NSArray<__kindof UIViewController *> *)popToURL:(NSURL * _Nonnull)url animate:(BOOL)animate;
- (void)goToURL:(NSURL * _Nonnull)url withParams:(NSDictionary * _Nullable)params animate:(BOOL)animate;

/**
 *  同一个栈中vc之间相互通知
 */
//- (BOOL)requestURL:(NSURL * _Nonnull)url withParams:(id _Nullable)params complete:(void(^ _Nullable)(_Nullable id response))complete;

@end
