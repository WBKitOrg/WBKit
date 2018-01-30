//
//  SkinModule.m
//  WBKitDemo
//
//  Created by wangbo on 2018/1/9.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "SkinModule.h"
#import "DemoIbView.h"

@implementation SkinModule

REGISTER_MODULE

+ (NSInteger)priority
{
    return WBModulePriorityVeryHigh;
}

- (void)moduleDidInit:(WBModuleManager *)manager
{
    //do some manager init
    
    [self setupDefaultButtonSkin];
}

- (void)setupDefaultButtonSkin
{
    [UIButton customizeForAppearance:^(UIView *appearance) {
        UIButton *button = (UIButton *)appearance;
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [button.layer setBorderColor:COLOR_HEX(0x0000ff).CGColor];
        [button.layer setBorderWidth:1.0f];
        [button.layer setCornerRadius:25.0f];
        [button.layer setMasksToBounds:YES];
    }];
    
    [DemoIbView customizeForAppearance:^(UIView *appearance) {
        DemoIbView *ibView = (DemoIbView*)appearance;
        [ibView setBackgroundColor:[UIColor blueColor]];
    }];
}
@end
