//
//  WBSerialAction.m
//  WBKit
//
//  Created by wangbo on 2018/2/6.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "WBSerialAction.h"

@interface WBActionInSerial : NSObject

@property (nonatomic, copy) void (^actionBlock)(void);
@property (nonatomic, copy) void (^completeBlock)(void);

@end

@implementation WBActionInSerial

@end


@interface WBSerialAction ()

@property (nonatomic, strong) NSMutableArray *actionList;
@property (nonatomic, copy  ) void (^serialCompleteBlock)(void);

@property (nonatomic        ) BOOL running;
@property (nonatomic        ) BOOL canceled;

@end

@implementation WBSerialAction

+ (instancetype)sharedSerialAction
{
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (WBSerialAction* (^)(void (^action)(void (^complete)(void))))addAction
{
    return ^WBSerialAction*(void (^action)(void (^complete)(void))){
        WBActionInSerial *actionItem = [[WBActionInSerial alloc] init];
        __weak typeof (WBActionInSerial) *weakItem = actionItem;
        actionItem.actionBlock = ^{
            action(weakItem.completeBlock);
        };
        [self.actionList addObject:actionItem];
        return self;
    };
}

- (void)actionInSerial
{
    if (self.canceled == YES) {
        self.running = NO;
        return;
    }
    self.running = YES;
    if (self.actionList.count>0) {
        WBActionInSerial *actionItem = [self.actionList firstObject];
        __weak typeof (self) weakSelf = self;
        __weak typeof (WBActionInSerial) *weakItem = actionItem;
        actionItem.completeBlock = ^{
            [weakSelf.actionList removeObject:weakItem];
            [weakSelf actionInSerial];
        };
        actionItem.actionBlock();
    } else {
        self.running = NO;
        if (self.serialCompleteBlock) {
            self.serialCompleteBlock();
        }
    }
}

#pragma mark - lazyLoad

- (NSMutableArray *)actionList
{
    if (!_actionList) {
        _actionList = [NSMutableArray array];
    }
    return _actionList;
}


#pragma mark - handler

- (void)start
{
    self.canceled = NO;
    if (self.running) {
        return;
    }
    [self actionInSerial];
}

- (void)cancel
{
    self.canceled = YES;
}

- (void)setComplte:(void (^)(void))complete
{
    self.serialCompleteBlock = complete;
}

@end
