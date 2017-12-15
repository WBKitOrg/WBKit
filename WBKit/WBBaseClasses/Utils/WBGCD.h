//
//  WBGCD.h
//  WBUtil
//
//  Created by wangbo on 16/11/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBGCD : NSObject

+(WBGCD *)WB_mainQueue;
+(WBGCD *)WB_globalQueue;
+(WBGCD *)WB_highPriorityGlobalQueue;
+(WBGCD *)WB_lowPriorityGlobalQueue;
+(WBGCD *)WB_backgroundPriorityGlobalQueue;

+(void)dispatchInMainQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec;

+(void)dispatchInGlobalQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec;

+(void)dispatchInHighPriorityGlobalQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec;

+(void)dispatchInLowPriorityGlobalQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec;

+(void)dispatchInBackgroundPriorityGlobalQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec;

+(void)dispatchInMainQueue:(dispatch_block_t)block;

+(void)dispatchInGlobalQueue:(dispatch_block_t)block;

+(void)dispatchInHighPriorityGlobalQueue:(dispatch_block_t)block;

+(void)dispatchInLowPriorityGlobalQueue:(dispatch_block_t)block;

+(void)dispatchInBackgroundPriorityGlobalQueue:(dispatch_block_t)block;


#pragma mark - 对单独使用的支持
- (instancetype)init;
- (instancetype)initSerial;
- (instancetype)initSerialWithLabel:(NSString *)label;
- (instancetype)initConcurrent;
- (instancetype)initConcurrentWithLabel:(NSString *)label;


-(void)dispatch:(dispatch_block_t)block;
-(void)dispatch:(dispatch_block_t)block afterDelay:(float)delay;
-(void)syncDispatch:(dispatch_block_t)block;
-(void)barrierDispatch:(dispatch_block_t)block;
-(void)syncBarrierDispatch:(dispatch_block_t)block;
-(void)suspend;
-(void)resume;

@end
