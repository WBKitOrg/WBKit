//
//  WBSerialAction.h
//  WBKit
//
//  Created by wangbo on 2018/2/6.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBSerialActionHandler
- (void)start;
- (void)cancel;
- (void)setComplte:(void (^)(void))complete;
@end

@interface WBSerialAction : NSObject <WBSerialActionHandler>

+ (instancetype)sharedSerialAction;
- (WBSerialAction* (^)(void (^action)(void (^complete)(void))))addAction;

@end
