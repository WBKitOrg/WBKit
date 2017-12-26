//
//  NSMutableArray+Unretain.m
//  WBKit
//
//  Created by wangbo on 2017/12/26.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "NSMutableArray+Unretain.h"

@implementation NSMutableArray (Unretain)

+ (NSMutableArray *)unretainedArray {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    return (__bridge_transfer NSMutableArray *) CFArrayCreateMutable(0, 0, &callbacks);
}

@end
