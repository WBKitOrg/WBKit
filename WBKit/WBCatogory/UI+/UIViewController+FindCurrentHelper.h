//
//  UIViewController+FindCurrentHelper.h
//  WBKit
//
//  Created by wangbo on 2018/2/13.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FindCurrentHelper)

+ (UIViewController *)topViewController;
+ (UIViewController *)currentViewController;
+ (UIViewController *)currentViewControllerWithRootViewController:(UIViewController*)rootViewController;

@end
