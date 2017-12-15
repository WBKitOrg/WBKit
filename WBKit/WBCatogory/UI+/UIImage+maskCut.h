//
//  UIImage+maskCut.h
//  WBKit
//
//  Created by wangbo on 2017/11/30.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (maskCut)

/**
 *  按比mask切图片
 *
 *  @param sourceImage 原始图片
 *  @param maskImages  遮罩图片数组
 *  @param isIn mask内部分还是mask外部分
 *
 *  @return 切后的图片
 */

+ (UIImage *)cutImage:(UIImage *)sourceImage withMasks:(NSArray *)maskImages inMask:(BOOL)isIn;

@end
