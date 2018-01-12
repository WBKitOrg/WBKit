//
//  NSDate+WBAdditions.h
//  WBKit
//
//  Created by wangbo on 2017/12/25.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (WBAdditions)

- (NSDateComponents *)componentsOfDay;

- (NSUInteger)year;

- (NSUInteger)month;

- (NSUInteger)day;

- (NSUInteger)hour;

- (NSUInteger)minute;

- (NSUInteger)second;

// 获得NSDate对应的星期 (1: 周日, 2: 周一, ...)
- (NSUInteger)weekday;

- (NSString *)normalizedDay;

- (NSString*)weekdayName;

// 返回day天后的日期(若day为负数,则为|day|天前的日期)
- (NSDate *)dateAfterDay:(int)day;

// 返回两个日期间的时间元素组件
+ (NSDateComponents*)fromStartDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;
+ (NSInteger)daysFromStartDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;
- (NSInteger)daysFromDate:(NSDate*)startDate;

- (NSInteger)daysToDate:(NSDate*)endDate;

// 前一天
- (NSDate *)previousDay;

// 下一天
- (NSDate *)followingDay;

// 判断与某一天是否为同一天
- (BOOL)sameDayWithDate:(NSDate *)otherDate;

// 判断与某一天是否为同一周
- (BOOL)sameWeekWithDate:(NSDate *)otherDate;

// 判断与某一天是否为同一月
- (BOOL)sameMonthWithDate:(NSDate *)otherDate;

// 是否是今天
- (BOOL)isToday;
#pragma mark  -- GMT string for china eg:"星期二 十二月 19 10:26:16 GMT 2017"
+ (NSDate *)dateTransformFromGMTString:(NSString *)gmtTime;
#pragma mark  -- GMT string for en  eg: "Thu, 28 Dec 2017 22:03:51 GMT+0800" || "Fri, 12 Jan 2018 09:21:38 GMT"
+ (NSDate *)dateTransformFromEnGMTString:(NSString *)gmtStr_en;

@end
