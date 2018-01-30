//
//  UITableViewCell+StaticHelper.m
//  WBKit
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UITableViewCell+StaticHelper.h"
#import <objc/runtime.h>

@implementation UITableViewCell (StaticHelper)

static char cellHeightKey;
static char cellDidSelectKey;

- (void)setCellHeight:(CGFloat)cellHeight
{
    objc_setAssociatedObject(self, &cellHeightKey, @(cellHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cellHeight{
    NSNumber *ch = objc_getAssociatedObject(self, &cellHeightKey);
    return [ch floatValue];
}

- (void)setCellDidSelect:(void (^)(void))cellDidSelect
{
    objc_setAssociatedObject(self, &cellDidSelectKey, cellDidSelect, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))cellDidSelect
{
    return objc_getAssociatedObject(self, &cellDidSelectKey);
}

@end
