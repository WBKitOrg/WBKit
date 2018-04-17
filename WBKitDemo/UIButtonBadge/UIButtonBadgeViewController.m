//
//  UIButtonBadgeViewController.m
//  WBKitDemo
//
//  Created by Uknow on 2018/2/2.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UIButtonBadgeViewController.h"

@interface UIButtonBadgeViewController ()

@property (nonatomic, strong) UIButton *buttonTwo;
@property (nonatomic, assign) int badgeCount;
@end

@implementation UIButtonBadgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.badgeCount = 0;

//  1.默认样式，SkinModule中设置
    UIButton *buttonOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOne setFrame:CGRectMake(50, kNavigationBarHeight + 50, 150, 80)];
    [buttonOne setTitle:@"右上角badge" forState:UIControlStateNormal];
    [self.view addSubview:buttonOne];
    [buttonOne wb_showBadgeWithContent:@"2" animated:YES];
    
//-------------------------------------------------------------------

//  2.重写样式
    UIButton *buttonTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonTwo = buttonTwo;
    [buttonTwo setFrame:CGRectMake(50, 280, 150, 80)];
    [buttonTwo setTitle:@"左下角badge" forState:UIControlStateNormal];
    [self.view addSubview:buttonTwo];
    //重置badge样式
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setFrame:CGRectMake(20, 240, 30, 30)];
    [addButton setTitle:@"+" forState:UIControlStateNormal];
    [addButton addAction:^{
        self.badgeCount++;
        [buttonTwo wb_showBadgeWithContent:[NSString stringWithFormat:@"%d",self.badgeCount] animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downButton setFrame:CGRectMake(60, 240, 30, 30)];
    [downButton setTitle:@"-" forState:UIControlStateNormal];
    [downButton addAction:^{
        self.badgeCount--;
        if(self.badgeCount == 0){
            [buttonTwo wb_hideBadgeAnimated:YES];
        }else{
            [buttonTwo wb_showBadgeWithContent:[NSString stringWithFormat:@"%d",self.badgeCount] animated:YES];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downButton];
    
    [buttonTwo wb_addBadgeAtPosition:WBBadgePositionBottomLeft];
    [buttonTwo setWb_badgeColor:[UIColor blackColor]];
    [buttonTwo setWb_badgeFontSize:10];
    [buttonTwo setWb_badgeInset:20];
    //根据wb_badgePositon向中间偏移（badge在左下角时，为向上向右偏移）
    [buttonTwo setWb_borderInset:60];
}


@end
