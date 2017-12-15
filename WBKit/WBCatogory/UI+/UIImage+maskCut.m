//
//  UIImage+maskCut.m
//  WBKit
//
//  Created by wangbo on 2017/11/30.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "UIImage+maskCut.h"

@implementation UIImage (maskCut)

+ (UIImage *)cutImage:(UIImage *)sourceImage withMasks:(NSArray *)maskImages inMask:(BOOL)isIn
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [sourceImage drawInRect:CGRectMake(0,0, size.width, size.height)];
    
    UIImage *maskImage = [self combineImages:maskImages inRect:CGRectMake(0, 0, size.width, size.height)];
    [maskImage drawInRect:CGRectMake(0, 0, size.width, size.height) blendMode:isIn?kCGBlendModeDestinationIn:kCGBlendModeDestinationOut alpha:1];
    
    UIImage* retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (UIImage *)combineImages:(NSArray *)images inRect:(CGRect)rect
{
    if (images.count==0) {
        return nil;
    }
    if (images.count==1) {
        return images.firstObject;
    }
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    for (UIImage *image in images) {
        [image drawInRect:rect];
    }
    UIImage* retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

@end
