//
//  UIView+BadgeHelper.h
//  WBKit
//
//  Created by wangbo on 2018/2/1.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WBBadgePosition) {
    WBBadgePositionTopRight    = 0,
    WBBadgePositionTopLeft     = 1,
    WBBadgePositionBottomRight   = 2,
    WBBadgePositionBottomLeft    = 3
};

@interface UIView (BadgeHelper)

@property (nonatomic        ) CGFloat wb_badgeFontSize;
@property (nonatomic        ) CGFloat wb_badgeInset;
@property (nonatomic        ) CGFloat wb_borderInset;
@property (nonatomic, strong) UIColor *wb_badgeColor;
@property (nonatomic, strong) UIColor *wb_badgeContentColor;

- (void)wb_addBadgeDot;
- (void)wb_addBadgeAtPosition:(WBBadgePosition)position;

// 目前animated为YES无效果
- (void)wb_showBadgeWithContent:(NSString *)content animated:(BOOL)animated;
- (void)wb_hideBadgeAnimated:(BOOL)animated;

@end
