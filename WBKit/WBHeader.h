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

#define iOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define iOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)

#define isPad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad   ? YES : NO)
#define isPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO)
#define isRetina ([[UIScreen mainScreen] scale] > 1 ? YES : NO)

#ifndef IS_IPHONE_X
#define IS_IPHONE_X                 (fabs(MAX(kScreenWidth, kScreenHeight) - 812) < DBL_EPSILON)
#endif

#ifndef kNavigationBarHeight
#define kNavigationBarHeight        (IS_IPHONE_X ? (kScreenWidth > kScreenHeight ? 32 : 88) : 64)
#endif

#ifndef kUINavigationBarHeight
#define kUINavigationBarHeight      ((IS_IPHONE_X && (kScreenWidth > kScreenHeight)) ? 32 : 44)
#endif

#ifndef kStatusBarHeight
#define kStatusBarHeight            (IS_IPHONE_X?44:20)
#endif

#ifndef ScreenWidth
#define ScreenWidth        ([UIScreen mainScreen].bounds.size.width)
#endif

#ifndef ScreenHeight
#define ScreenHeight      ([UIScreen mainScreen].bounds.size.height)
#endif

#ifndef ScreenSmallSide
#define ScreenSmallSide   ([[UIScreen mainScreen] bounds].size.height>[[UIScreen mainScreen] bounds].size.width ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#endif

//键盘弹出动画
#define IOSAnimationcurve (long)7
#define IOSAnimationduration (double)0.25


#endif
