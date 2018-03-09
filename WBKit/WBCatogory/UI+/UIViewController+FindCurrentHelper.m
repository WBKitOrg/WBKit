//
//  UIViewController+FindCurrentHelper.m
//  WBKit
//
//  Created by wangbo on 2018/2/13.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UIViewController+FindCurrentHelper.h"

@implementation UIViewController (FindCurrentHelper)

#pragma mark - 工具方法找到当前的vc

+ (UIViewController *)topViewController
{
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
}

+ (UIViewController *)currentViewController
{
    return [[self class] currentViewControllerWithRootViewController:[[self class] topViewController]];
}

+ (UIViewController*)currentViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self currentViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self currentViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self currentViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
