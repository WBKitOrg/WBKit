//
//  UIGestureRecognizer+BlockedAction.m
//  WBKit
//
//  Created by wangbo on 2018/3/9.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UIGestureRecognizer+BlockedAction.h"
#import <objc/runtime.h>

@interface WBGesturelistenner : NSObject
@property (nonatomic, copy) void (^gestureHandler)(void);
- (void)gestureAction:(id)ges;
@end

@implementation WBGesturelistenner

- (void)gestureAction:(id)ges{
    if (self.gestureHandler) {
        self.gestureHandler();
    }
}

@end

@implementation UIGestureRecognizer (BlockedAction)

- (instancetype)initWithHandler:(void (^)(void))handler
{
    WBGesturelistenner *listenner = [[WBGesturelistenner alloc] init];
    listenner.gestureHandler = handler;
    self = [self initWithTarget:listenner action:@selector(gestureAction:)];
    if (self) {
        objc_setAssociatedObject(self, @"gestureListenner", listenner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

@end
