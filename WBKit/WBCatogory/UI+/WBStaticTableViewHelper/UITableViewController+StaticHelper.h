//
//  UITableViewController+StaticHelper.h
//  WBKit
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+StaticHelper.h"

@interface UITableViewController (StaticHelper)

/** @brief example:
 *  NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:3];
 *  [section1 addObject:[self firstCell]];
 *  [section1 addObject:[self secondCell]];
 *  [section1 addObject:[self thirdCell]];
 *  [self.sections addObject:section1];
 *
 *  NSMutableArray *section2 = [NSMutableArray arrayWithCapacity:2];
 *  [section2 addObject:[self forthCell]];
 *  [section2 addObject:[self fifthCell]];
 *  [self.sections addObject:section2];
 */
@property (nonatomic, strong) NSMutableArray *sections;

@end
