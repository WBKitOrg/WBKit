//
//  UIImage+ClearImage.m
//  WBUtil
//
//  Created by wangbo on 16/11/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "UIImage+ClearImage.h"

@implementation UIImage (ClearImage)


+(UIImage *)clearImage{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
