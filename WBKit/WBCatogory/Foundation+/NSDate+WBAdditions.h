//
//  NSDate+WBAdditions.h
//  WBKit
//
//  Created by wangbo on 2017/12/25.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    WBDateFormatDefault = 0,    //Use default time formatter as "yyyy-MM-dd HH:mm:ss"
    WBDateFormatGMT,            //GMT string for china eg:"星期二 十二月 19 10:26:16 GMT 2017"
    WBDateFormatGMTEN,          //GMT string for en  eg: "Thu, 28 Dec 2017 22:03:51 GMT+0800" || "Fri, 12 Jan 2018 09:21:38 GMT"
}WBDateFormat;

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

/*! @brief 将字符串根据自定义的GMTFormat进行转化的方法
 *
 * @param gmtString 需要转换的string
 * @param format 转换的规定格式
 * @note 无formatType参数的方法会自动判断需要使用的format
 * @see WBDateFormat 
 */
+ (NSDate *)dateFromFormattedString:(NSString *)gmtString formatType:(WBDateFormat)format;
+ (NSDate *)dateFromFormattedString:(NSString *)dateString;

@end
