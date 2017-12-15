//
//  WBHeader.h
//  WBUtil
//
//  Created by wangbo on 16/10/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#ifndef WBHeader_h
#define WBHeader_h


#endif /* WBHeader_h */

#ifdef __OBJC__

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif


//适配iphone6 以及plus 的屏幕设置两个参数
#ifndef ScreenWidth
#define ScreenWidth        ([UIScreen mainScreen].bounds.size.width)
#endif

#ifndef ScreenHeight
#define ScreenHeight      ([UIScreen mainScreen].bounds.size.height)
#endif

#ifndef ScreenSmallSide
#define ScreenSmallSide   ([[UIScreen mainScreen] bounds].size.height>[[UIScreen mainScreen] bounds].size.width ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#endif

#define iOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define iOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)

#define isPad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad   ? YES : NO)
#define isPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO)
#define isRetina ([[UIScreen mainScreen] scale] > 1 ? YES : NO)


//键盘弹出动画
#define IOSAnimationcurve (long)7
#define IOSAnimationduration (double)0.25


/**
 * 6.1 王博添加根据16进制数得到UIColor值
 */

#define UIColorFromHexString(hexString,alphaValue) [UIColor colorWithRed:((float)((strtoul([[hexString hasPrefix:@"0x"]?[hexString substringFromIndex:2]:hexString UTF8String],0,16) & 0xFF0000) >> 16))/255.0  green:((float)((strtoul([[hexString hasPrefix:@"0x"]?[hexString substringFromIndex:2]:hexString UTF8String],0,16) & 0x00FF00) >> 8))/255.0  blue:((float)(strtoul([[hexString hasPrefix:@"0x"]?[hexString substringFromIndex:2]:hexString UTF8String],0,16) & 0x0000FF))/255.0  alpha:(alphaValue)]



#endif
