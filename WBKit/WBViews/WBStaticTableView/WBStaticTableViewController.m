//
//  WBStaticTableViewController.m
//  WBKit
//
//  Created by wangbo on 2018/7/9.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "WBStaticTableViewController.h"
#import "WBStaticTableViewHelper.h"
#import <objc/runtime.h>


@interface WBStaticTableViewController ()

@property (nonatomic, strong) WBStaticTableViewHelper *helper;

@end

@implementation WBStaticTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - DefaultDelegateSetting

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.helper wb_staticTable_tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.helper wb_staticTable_tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.helper wb_staticTable_numberOfSectionsInTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.helper wb_staticTable_tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.helper wb_staticTable_tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - propertys

static char sectionsKey;

- (void)setSections:(NSMutableArray *)sections
{
    self.helper = [[WBStaticTableViewHelper alloc] initWithSections:sections];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
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

@end
