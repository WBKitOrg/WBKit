//
//  UIViewController+WBLefeCircleEventManagement.m
//  xuxian
//
//  Created by wangbo on 16/11/11.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "UIViewController+WBLefeCircleEventManagement.h"
#import <objc/runtime.h>

@implementation UIViewController (WBLefeCircleEventManagement)

static char WBLifeCircleViewWillAppearKey;
static char WBLifeCircleViewDidAppearKey;
static char WBLifeCircleViewWillDisappearKey;
static char WBLifeCircleViewDidDisappearKey;

+ (void)load
{
    Method orimvw = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method myimvw = class_getInstanceMethod(self, @selector(WBviewWillAppear:));
    method_exchangeImplementations(orimvw, myimvw);
    
    Method orimvd = class_getInstanceMethod(self, @selector(viewDidAppear:));
    Method myimvd = class_getInstanceMethod(self, @selector(WBviewDidAppear:));
    method_exchangeImplementations(orimvd, myimvd);
    
    Method orimvwd = class_getInstanceMethod(self, @selector(viewWillDisappear:));
    Method myimvwd = class_getInstanceMethod(self, @selector(WBviewWillDisappear:));
    method_exchangeImplementations(orimvwd, myimvwd);
    
    Method orimvdd = class_getInstanceMethod(self, @selector(viewDidDisappear:));
    Method myimvdd = class_getInstanceMethod(self, @selector(WBviewDidDisappear:));
    method_exchangeImplementations(orimvdd, myimvdd);
}


#pragma mark - implement myselfLifecircle

-(void)WBviewWillAppear:(BOOL)animated{
    [self WBviewWillAppear:animated];
    //do what I want in viewWillAppear
    for (void(^event)() in self.willAppearEvents) {
        event();
    }
    //清空数组
    [self.willAppearEvents removeAllObjects];
}

-(void)WBviewDidAppear:(BOOL)animated{
    [self WBviewDidAppear:animated];
    //do what I want in viewDidAppear
    for (void(^event)() in self.didAppearEvents) {
        event();
    }
    //清空数组
    [self.didAppearEvents removeAllObjects];
}

-(void)WBviewWillDisappear:(BOOL)animated{
    [self WBviewWillDisappear:animated];
    //do what I want in viewWillDisappear
    for (void(^event)() in self.willDisappearEvents) {
        event();
    }
    //清空数组
    [self.willDisappearEvents removeAllObjects];
}

-(void)WBviewDidDisappear:(BOOL)animated{
    [self WBviewDidDisappear:animated];
    //do what I want in viewDidDisappear
    for (void(^event)() in self.didDisappearEvents) {
        event();
    }
    //清空数组
    [self.didDisappearEvents removeAllObjects];
}


#pragma mark - addEventFunction

-(void (^)(WBLifeCircle lc,void(^event)()))addEventInLifeCircle{
    return ^ (WBLifeCircle lc,void(^event)()){
        //添加事件进入对应数组
        switch (lc) {
            case WBLifeCircleViewWillAppear:
                [self.willAppearEvents addObject:event];
                break;
            case WBLifeCircleViewDidAppear:
                [self.didAppearEvents addObject:event];
                break;
            case WBLifeCircleViewWillDisappear:
                [self.willDisappearEvents addObject:event];
                break;
            case WBLifeCircleViewDidDisappear:
                [self.didDisappearEvents addObject:event];
                break;
            default:
                break;
        }
    };
}



#pragma mark - 属性添加

//willappear
- (void)setWillAppearEvents:(NSMutableArray *)events
{
    objc_setAssociatedObject(self, &WBLifeCircleViewWillAppearKey, events,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)willAppearEvents
{
    NSMutableArray *events = objc_getAssociatedObject(self, &WBLifeCircleViewWillAppearKey);
    if (!events) {
        events = [NSMutableArray array];
        [self setWillAppearEvents:events];
    }
    return events;
}

//didappear
- (void)setDidAppearEvents:(NSMutableArray *)events
{
    objc_setAssociatedObject(self, &WBLifeCircleViewDidAppearKey, events,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)didAppearEvents
{
    NSMutableArray *events = objc_getAssociatedObject(self, &WBLifeCircleViewDidAppearKey);
    if (!events) {
        events = [NSMutableArray array];
        [self setDidAppearEvents:events];
    }
    return events;
}

//willdisappear
- (void)setWillDisappearEvents:(NSMutableArray *)events
{
    objc_setAssociatedObject(self, &WBLifeCircleViewWillDisappearKey, events,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)willDisappearEvents
{
    NSMutableArray *events = objc_getAssociatedObject(self, &WBLifeCircleViewWillDisappearKey);
    if (!events) {
        events = [NSMutableArray array];
        [self setWillDisappearEvents:events];
    }
    return events;
}

//diddisappear
- (void)setDidDisappearEvents:(NSMutableArray *)events
{
    objc_setAssociatedObject(self, &WBLifeCircleViewDidDisappearKey, events,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)didDisappearEvents
{
    NSMutableArray *events = objc_getAssociatedObject(self, &WBLifeCircleViewDidDisappearKey);
    if (!events) {
        events = [NSMutableArray array];
        [self setDidDisappearEvents:events];
    }
    return events;
}

@end
