//
//  UIGestureRecognizer+BlockedAction.h
//  WBKit
//
//  Created by wangbo on 2018/3/9.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (BlockedAction)

- (instancetype)initWithHandler:(void (^)(void))handler;

@end

