//
//  NSObject+IdentifyHelper.m
//  WBKit
//
//  Created by wangbo on 2018/1/4.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "NSObject+IdentifyHelper.h"
#import <objc/runtime.h>

@implementation NSObject (IdentifyHelper)

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

- (void)setWb_id:(NSString *)wb_id
{
    objc_setAssociatedObject(self, @"wb_id_key", wb_id, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)wb_id
{
    NSString *wb_id = objc_getAssociatedObject(self, @"wb_id_key");
    if (wb_id.length==0) {
        wb_id = [NSString stringWithFormat:@"%@/%lld",NSStringFromClass([self class]),[self generateId]];
        [self setWb_id:wb_id];
    }
    return wb_id;
}

@end
