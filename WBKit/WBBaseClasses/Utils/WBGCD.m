//
//  WBGCD.m
//  WBUtil
//
//  Created by wangbo on 16/11/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "WBGCD.h"

/**
 *  静态变量线程池
 */
static WBGCD *WB_mainQueue;
static WBGCD *WB_globalQueue;
static WBGCD *WB_highPriorityGlobalQueue;
static WBGCD *WB_lowPriorityGlobalQueue;
static WBGCD *WB_backgroundPriorityGlobalQueue;

@interface WBGCD()

@property (strong, nonatomic) dispatch_queue_t wb_dispatch_queue;

@end


@implementation WBGCD


+ (void)initialize {
    
    if (self == [WBGCD self])  {
        
        WB_mainQueue                     = [WBGCD new];
        WB_mainQueue.wb_dispatch_queue                     = dispatch_get_main_queue();
        
        WB_globalQueue                   = [WBGCD new];
        WB_globalQueue.wb_dispatch_queue                   = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        WB_highPriorityGlobalQueue       = [WBGCD new];
        WB_highPriorityGlobalQueue.wb_dispatch_queue       = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        WB_lowPriorityGlobalQueue        = [WBGCD new];
        WB_lowPriorityGlobalQueue.wb_dispatch_queue        = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        
        WB_backgroundPriorityGlobalQueue = [WBGCD new];
        WB_backgroundPriorityGlobalQueue.wb_dispatch_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

    }
}

+(WBGCD *)WB_mainQueue {
    return WB_mainQueue;
}
+(WBGCD *)WB_globalQueue {
    return WB_globalQueue;
}
+(WBGCD *)WB_highPriorityGlobalQueue {
    return WB_highPriorityGlobalQueue;
}
+(WBGCD *)WB_lowPriorityGlobalQueue {
    return WB_lowPriorityGlobalQueue;
}
+(WBGCD *)WB_backgroundPriorityGlobalQueue {
    return WB_backgroundPriorityGlobalQueue;
}


#pragma mark - 暴露方法

+(void)dispatchInMainQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec {
    if (block) {
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), WB_mainQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInGlobalQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec {
    if (block) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), WB_globalQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInHighPriorityGlobalQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec {
    if (block) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), WB_highPriorityGlobalQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInLowPriorityGlobalQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec {
    if (block) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), WB_lowPriorityGlobalQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInBackgroundPriorityGlobalQueue:(dispatch_block_t)block afterDelay:(NSTimeInterval)sec {
    if (block) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), WB_backgroundPriorityGlobalQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInMainQueue:(dispatch_block_t)block {
    if (block) {
        dispatch_async(WB_mainQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInGlobalQueue:(dispatch_block_t)block {
    if (block) {
        dispatch_async(WB_globalQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInHighPriorityGlobalQueue:(dispatch_block_t)block {
    if (block) {
        dispatch_async(WB_highPriorityGlobalQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInLowPriorityGlobalQueue:(dispatch_block_t)block {
    if (block) {
        dispatch_async(WB_lowPriorityGlobalQueue.wb_dispatch_queue, block);
    }
}

+(void)dispatchInBackgroundPriorityGlobalQueue:(dispatch_block_t)block {
    if (block) {
        dispatch_async(WB_backgroundPriorityGlobalQueue.wb_dispatch_queue, block);
    }
}


#pragma mark - 如果自定义一个线程池，那么这里提供自定义线程池的使用

#pragma mark 初始化方法
//serially
-(instancetype)init {
    self = [super init];
    if (self) {
        self.wb_dispatch_queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(instancetype)initSerialWithLabel:(NSString *)label {
    self = [super init];
    if (self){
        self.wb_dispatch_queue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(instancetype)initConcurrent {
    self = [super init];
    if (self) {
        self.wb_dispatch_queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(instancetype)initConcurrentWithLabel:(NSString *)label {
    self = [super init];
    if (self) {
        self.wb_dispatch_queue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(void)dispatch:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(self.wb_dispatch_queue, block);
}

-(void)dispatch:(dispatch_block_t)block afterDelay:(float)delay {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), self.wb_dispatch_queue, block);
}

/**
 *  这个方法是同步的，尽量在自己定义的线程池中使用，避免阻塞主线程
 */
-(void)syncDispatch:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_sync(self.wb_dispatch_queue, block);
}

-(void)barrierDispatch:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_barrier_async(self.wb_dispatch_queue, block);
}
/**
 *  这个方法是同步的，尽量在自己定义的线程池中使用，避免阻塞主线程
 */
-(void)syncBarrierDispatch:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_barrier_sync(self.wb_dispatch_queue, block);
}


-(void)suspend {
    dispatch_suspend(self.wb_dispatch_queue);
}
-(void)resume {
    dispatch_resume(self.wb_dispatch_queue);
}


@end
