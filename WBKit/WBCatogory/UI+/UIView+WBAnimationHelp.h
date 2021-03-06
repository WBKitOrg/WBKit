//
//  UIView+WBAnimationHelp.h
//  WBGameTest
//
//  Created by wangbo on 16/10/12.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WBAnimationHelp)

/*
 *  贝塞尔曲线运动，提供一个终点，一个控制点，一个时间，方法执行后view的center将被设置在position
 */
-(void)animationToPosition:(CGPoint)position controlPoint:(CGPoint)controlPoint duration:(float)duration;

/*
 *  贝塞尔交换
 */
-(void)ChangePositionToView:(UIView *)view duration:(float)du;

-(void)CommitflipAnimationFromLeftComplete:(void(^)(void))complete;
-(void)CommitflipAnimationFromRightComplete:(void(^)(void))complete;

@end
