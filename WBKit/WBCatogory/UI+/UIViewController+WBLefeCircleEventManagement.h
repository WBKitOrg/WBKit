//
//  UIViewController+WBLefeCircleEventManagement.h
//  xuxian
//
//  Created by wangbo on 16/11/11.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    WBLifeCircleViewWillAppear = 0,
    WBLifeCircleViewDidAppear,
    WBLifeCircleViewWillDisappear,
    WBLifeCircleViewDidDisappear,
}WBLifeCircle;

@interface UIViewController (WBLefeCircleEventManagement)

/**
 * 添加的事件链属性
 */

@property (nonatomic , retain)NSMutableArray *willAppearEvents;
@property (nonatomic , retain)NSMutableArray *didAppearEvents;
@property (nonatomic , retain)NSMutableArray *willDisappearEvents;
@property (nonatomic , retain)NSMutableArray *didDisappearEvents;

/**
 * @brief 使用方式:    self.addEventInLifeCircle(WBLifeCircleViewWillAppear,^{});
 */
-(void (^)(WBLifeCircle lc,void(^event)()))addEventInLifeCircle;

@end
