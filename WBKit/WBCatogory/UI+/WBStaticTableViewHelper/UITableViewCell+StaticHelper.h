//
//  UITableViewCell+StaticHelper.h
//  WBKit
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (StaticHelper)

@property (nonatomic      ) CGFloat cellHeight;
@property (nonatomic, copy) void (^cellDidSelect)(void);

@end
