//
//  UIButtonBadgeViewController.m
//  WBKitDemo
//
//  Created by Uknow on 2018/2/2.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UIButtonBadgeViewController.h"

@interface UIButtonBadgeViewController ()

@end

@implementation UIButtonBadgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
//  1.默认样式，SkinModule中设置
    UIButton *buttonOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOne setFrame:CGRectMake(50, 120, 150, 80)];
    [buttonOne setTitle:@"右上角badge" forState:UIControlStateNormal];
    [self.view addSubview:buttonOne];
    [buttonOne wb_showBadgeWithContent:@"1" animated:YES];
    
//-------------------------------------------------------------------

//  2.重写样式
    UIButton *buttonTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonTwo setFrame:CGRectMake(50, 220, 150, 80)];
    [buttonTwo setTitle:@"右上角badge" forState:UIControlStateNormal];
    [self.view addSubview:buttonTwo];
    //重置badge样式
    [buttonTwo wb_addBadgeAtPosition:WBBadgePositionBottomLeft];
    [buttonTwo setWb_badgeColor:[UIColor blackColor]];
    [buttonTwo setWb_badgeFontSize:10];
    [buttonTwo setWb_badgeInset:20];
    //根据wb_badgePositon向中间偏移（badge在左下角时，为向上向右偏移）
    [buttonTwo setWb_borderInset:60];
    [buttonTwo wb_showBadgeWithContent:@"2" animated:YES];
}


@end
