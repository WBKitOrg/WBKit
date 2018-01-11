//
//  UIView+Skinable.m
//  WBKit
//
//  Created by wangbo on 2018/1/9.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UIView+Skinable.h"
#import <objc/runtime.h>

static NSMutableDictionary *wb_skinableClassesBlock;

@implementation UIView (Skinable)

+ (NSMutableDictionary *)wb_skinableClassesBlock
{
    if (!wb_skinableClassesBlock) {
        wb_skinableClassesBlock = [NSMutableDictionary dictionary];
    }
    return wb_skinableClassesBlock;
}

+ (void)customizeForAppearance:(void (^)(UIView *appearance))customizeBlock
{
    [[self wb_skinableClassesBlock] setObject:customizeBlock forKey:NSStringFromClass([self class])];
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = self;
        SEL originalSelector = @selector(initWithFrame:);
        SEL swizzledSelector = @selector(wb_skinable_initWithFrame:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (instancetype)wb_skinable_initWithFrame:(CGRect)frame
{
    id inst = [self wb_skinable_initWithFrame:frame];
    void (^customizeBlock)(UIView *appearance) = [[self class] wb_skinableClassesBlock][NSStringFromClass([self class])];
    if (inst && customizeBlock) {
        customizeBlock(inst);
    }
    return inst;
}

- (void)ibDidInit
{
    void (^customizeBlock)(UIView *appearance) = [[self class] wb_skinableClassesBlock][NSStringFromClass([self class])];
    if (customizeBlock) {
        customizeBlock(self);
    }
}

@end
