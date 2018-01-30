//
//  WBStaticTableViewHelper.m
//  WBKit
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "WBStaticTableViewHelper.h"
#import "UITableViewCell+StaticHelper.h"

@interface WBStaticTableViewHelper()

@property (nonatomic, strong) NSArray *sections;

@end

@implementation WBStaticTableViewHelper

- (instancetype)initWithSections:(NSArray *)sections
{
    self = [super init];
    if (self) {
        self.sections = sections;
    }
    return self;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *cells = self.sections[section];
    return cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cells = self.sections[indexPath.section];
    UITableViewCell *cell = cells[indexPath.row];
    return cell.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cells = self.sections[indexPath.section];
    UITableViewCell *cell = cells[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cells = self.sections[indexPath.section];
    UITableViewCell *cell = cells[indexPath.row];
    cell.cellDidSelect();
}

@end
