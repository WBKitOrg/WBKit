//
//  WBFlyClipDemoViewController.m
//  WBKitDemo
//
//  Created by wangbo on 2018/2/13.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "WBFlyClipDemoViewController.h"

@interface WBFlyClipDemoViewController () <WBClipableViewControllerDelegate>

@end

@implementation WBFlyClipDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(100, 200, 100, 100)];
    [button setTitle:@"进入" forState:UIControlStateNormal];
    
    __weak typeof (self) weakSelf = self;
    
    [button addAction:^{
        [WBURLRoute openUrl:@"flyclip/normalwindow/open"];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setFrame:CGRectMake(200, 300, 100, 100)];
    [button2 setTitle:@"smallWindow" forState:UIControlStateNormal];
    [button2 addAction:^{
        [weakSelf zoomIn];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button3 setFrame:CGRectMake(100, 300, 100, 100)];
    [button3 setTitle:@"dismiss" forState:UIControlStateNormal];
    [button3 addAction:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button4 setFrame:CGRectMake(200, 200, 100, 100)];
    [button4 setTitle:@"opensmall" forState:UIControlStateNormal];
    [button4 addAction:^{
        [WBURLRoute openUrl:@"flyclip/smallwindow/open?switch=1"];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button4];
    
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
}

- (void)WBClipableViewControllerDidZoomIn:(WBClipableViewController *)clipViewController rect:(CGRect)rect
{
    [self.view setBackgroundColor:[UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]];
}
- (void)WBClipableViewControllerDidZoomOut:(WBClipableViewController *)clipViewController
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
}


@end
