//
//  UIView+Skinable.h
//  WBKit
//
//  Created by wangbo on 2018/1/9.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBIBSkinable <NSObject>

@optional
-(void)ibDidInit;

@end

@interface UIView (Skinable) <WBIBSkinable>

+ (void)customizeForAppearance:(void (^)(UIView *appearance))customizeBlock;

@end
