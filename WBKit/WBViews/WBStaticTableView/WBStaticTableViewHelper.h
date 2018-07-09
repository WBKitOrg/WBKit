//
//  WBStaticTableViewHelper.h
//  WBKit
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBStaticTableViewDatasourceProtocol <NSObject>

- (NSInteger)wb_staticTable_numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)wb_staticTable_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)wb_staticTable_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)wb_staticTable_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)wb_staticTable_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface WBStaticTableViewHelper : NSObject <WBStaticTableViewDatasourceProtocol>

- (instancetype)initWithSections:(NSArray *)sections;

@end
