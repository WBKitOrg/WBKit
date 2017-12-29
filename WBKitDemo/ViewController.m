//
//  ViewController.m
//  WBKitDemo
//
//  Created by wangbo on 2017/12/29.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [WBURLRoute openUrl:@"demo/test?id=1" params:@{@"testParam":@"xxx"} callback:^(NSDictionary *param) {
        NSLog(@"getCallBack&Param = %@",param);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
