//
//  NSObject+MessageRequest.m
//  xuxian
//
//  Created by wangbo on 16/11/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "NSObject+MessageRequest.h"
#import "WBMessageTransferStation.h"
#import <objc/runtime.h>

@implementation NSObject (MessageRequest)

/**
 *  @brief 如果需要使用这里注册的url,使用idurl
 */
-(BOOL)WB_registeListennerWithIdurl:(NSString *)url{
    NSString *IdWithUrl = [NSString stringWithFormat:@"%@/%lld",url,[self generateId]];
    [self setWB_idurl:IdWithUrl];
    return [[WBMessageTransferStation sharedStation] registe:self WithIdurl:IdWithUrl];
}

static int64_t lastId = 0;
- (int64_t)generateId
{
    @synchronized (self) {
        NSDate *date = [NSDate date];
        int64_t t = ((int64_t)([date timeIntervalSince1970] * 1000));
        if (t > (lastId >> 10)) {
            lastId = (t << 10);//低10位递增，高53位表示毫秒数,
            return lastId;
        }
        
        ++lastId;
        return lastId;
    }
}

-(void)WB_removeFromMessageTransferStation{
    [[WBMessageTransferStation sharedStation] remove:self ForUrl:self.WB_idurl];
}

-(void)WB_requestURL:(NSString *)url withParams:(id)params complete:(void(^)(id response))complete{
    [self setWB_NeedCompish:complete];
    [[WBMessageTransferStation sharedStation] postMessage:params from:self.WB_idurl to:url];
}


#pragma mark - 设置属性
- (void)setWB_idurl:(NSString *)url
{
    objc_setAssociatedObject(self, @"idurl", url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)WB_idurl
{
    return objc_getAssociatedObject(self, @"idurl");
}

- (void)setWB_NeedCompish:(void (^)(id))NeedCompish
{
    objc_setAssociatedObject(self, @"reqcomplete", NeedCompish, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(id))WB_NeedCompish
{
    return objc_getAssociatedObject(self, @"reqcomplete");
}

@end
