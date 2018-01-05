//
//  WBMessageTransferStation.h
//  xuxian
//
//  Created by wangbo on 16/11/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBMessageTransferStation : NSObject

+ (WBMessageTransferStation *) sharedStation;

-(BOOL)registe:(id)listenner wb_id:(NSString *)identification;
-(BOOL)remove:(id)listenner wb_id:(NSString *)identification;

-(void)postMessage:(id)message from:(NSString *)fromId to:(NSString *)toId;

@end
