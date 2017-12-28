//
//  WBModule.h
//  WBKit
//
//  Created by wangbo on 2017/12/27.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WBModuleManager;

typedef NS_ENUM(NSInteger, WBModulePriority) {
    WBModulePriorityDefault = 0,
    WBModulePriorityLow = -100,
    WBModulePriorityHigh = 100,
    WBModulePriorityVeryHigh = 10000,
    WBModulePriorityCore    = (1<<30),
};

@protocol WBModule <NSObject>

@optional

+ (NSInteger)priority;

/// 模块即将开始初始化, 在主线程被调用, 各个模块可以做些轻量级的事情, 例如: 生成对象，初始化对象等内存操作
- (void)moduleDidInit:(WBModuleManager *)manager;

/// 模块在后台线程初始化, 一些重量的操作，例如: 文件IO, 数据库操作等
- (void)moduleLaunchInBackground:(WBModuleManager *)manager;

/// 模块初始化完成, 在主线程被调用, 可以在这里发出网络请求等
- (void)moduleDidLaunchFinished:(WBModuleManager *)manager;

/// App进入后台, 模块需保存状态, 清除不必要的内存等
- (void)moduleDidEnterBackground:(WBModuleManager *)manager;

/// App即将进入前台, 参数为app距离上次切换到后台的时长
- (void)moduleWillEnterForeground:(WBModuleManager *)manager invisibleDuration:(NSTimeInterval)duration;

@end
