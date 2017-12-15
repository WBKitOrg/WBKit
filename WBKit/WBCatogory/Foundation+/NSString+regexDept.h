//
//  NSString+regexDept.h
//  WBUtil
//
//  Created by wangbo on 2017/5/16.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (regexDept)

- (BOOL)wb_deptNameInputShouldChinese;
- (BOOL)wb_deptNumInputShouldNumber;
- (BOOL)wb_deptPassInputShouldAlpha;
- (BOOL)wb_deptIdInputShouldAlphaNum;

@end
