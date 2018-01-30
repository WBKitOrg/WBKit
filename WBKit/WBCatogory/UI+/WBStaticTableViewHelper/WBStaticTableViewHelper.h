//
//  WBStaticTableViewHelper.h
//  WBKit
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBStaticTableViewHelper : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithSections:(NSArray *)sections;

@end
