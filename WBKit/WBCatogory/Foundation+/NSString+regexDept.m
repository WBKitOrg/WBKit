//
//  NSString+regexDept.m
//  WBUtil
//
//  Created by wangbo on 2017/5/16.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "NSString+regexDept.h"

@implementation NSString (regexDept)

#pragma mark--
#pragma mark 判断全中文
- (BOOL)wb_deptNameInputShouldChinese
{
    NSString *regex = @"[\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if (![pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}


#pragma mark--
#pragma mark 判断全数字
- (BOOL)wb_deptNumInputShouldNumber
{
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if (![pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}


#pragma mark--
#pragma mark 判断全字母
- (BOOL)wb_deptPassInputShouldAlpha
{
    NSString *regex =@"[a-zA-Z]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if (![pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}


#pragma mark--
#pragma mark 判断仅输入字母或数字
- (BOOL)wb_deptIdInputShouldAlphaNum
{
    NSString *regex =@"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if (![pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}


@end
