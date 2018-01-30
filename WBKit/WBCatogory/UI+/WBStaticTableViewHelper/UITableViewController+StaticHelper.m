//
//  UITableViewController+StaticHelper.m
//  WBKit
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UITableViewController+StaticHelper.h"
#import "WBStaticTableViewHelper.h"
#import <objc/runtime.h>

@interface UITableViewController()

@property (nonatomic, strong) WBStaticTableViewHelper *helper;

@end

@implementation UITableViewController (StaticHelper)

#pragma mark - propertys

static char sectionsKey;
static char helperKey;

- (void)setSections:(NSMutableArray *)sections
{
    self.helper = [[WBStaticTableViewHelper alloc] initWithSections:sections];
    self.tableView.delegate = self.helper;
    self.tableView.dataSource = self.helper;
    objc_setAssociatedObject(self, &sectionsKey, sections, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)sections
{
    NSMutableArray *secs = objc_getAssociatedObject(self, &sectionsKey);
    if (!secs) {
        secs = [NSMutableArray array];
        [self setSections:secs];
    }
    return secs;
}

- (void)setHelper:(WBStaticTableViewHelper *)helper
{
    objc_setAssociatedObject(self, &helperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WBStaticTableViewHelper *)helper
{
    return objc_getAssociatedObject(self, &helperKey);
}

@end
