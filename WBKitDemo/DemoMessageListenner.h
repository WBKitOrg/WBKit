//
//  DemoMessageListenner.h
//  WBKitDemo
//
//  Created by wangbo on 2018/1/4.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoMessageListenner : NSObject <WBMessageRequestListener>

+ (DemoMessageListenner *)sharedListenner;

@end
