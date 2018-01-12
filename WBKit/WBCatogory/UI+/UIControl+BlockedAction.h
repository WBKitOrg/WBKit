//
//  UIControl+BlockedAction.h
//  WBKit
//
//  Created by wangbo on 2018/1/12.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (BlockedAction)

- (void)addAction:(void (^)(void))actionBlock forControlEvents:(UIControlEvents)controlEvents;

@end
