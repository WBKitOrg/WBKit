//
//  UIColor+WBAdditions.h
//  WBKit
//
//  Created by wangbo on 2017/11/30.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WBAdditions)

+ (UIColor*)colorWithHexString:(NSString *)hexColorString;

+ (UIColor*)colorWithHexString:(NSString *)hexColorString alphaString:(NSString *)alphaString;

+ (UIColor*)colorWithHex:(NSInteger)hexValue;

+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;

+ (UIColor*)colorWithRGBString:(NSString *)rgbaString;

@end

#define COLOR(r,g,b)                                [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define COLOR_ALPHA(r,g,b,a)                        [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]


#define COLOR_HEX(hexValue)                         [UIColor colorWithHex:(hexValue)]

#define COLOR_ALPHA_HEX(hexValue, alphaValue)       [UIColor colorWithHex:(hexValue) alpha:(alphaValue)]


#define COLOR_HEXSTRING(hexString)                  [UIColor colorWithHexString:(hexString)]

#define COLOR_A_HEXSTRING(hexString, alphaString)   [UIColor colorWithHexString:(hexString) alphaString:(alphaString)]

#define UIColorFromHexString(hexString,alphaValue) [UIColor colorWithRed:((float)((strtoul([[hexString hasPrefix:@"0x"]?[hexString substringFromIndex:2]:hexString UTF8String],0,16) & 0xFF0000) >> 16))/255.0  green:((float)((strtoul([[hexString hasPrefix:@"0x"]?[hexString substringFromIndex:2]:hexString UTF8String],0,16) & 0x00FF00) >> 8))/255.0  blue:((float)(strtoul([[hexString hasPrefix:@"0x"]?[hexString substringFromIndex:2]:hexString UTF8String],0,16) & 0x0000FF))/255.0  alpha:(alphaValue)]


