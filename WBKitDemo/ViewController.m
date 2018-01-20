//
//  ViewController.m
//  WBKitDemo
//
//  Created by wangbo on 2017/12/29.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "ViewController.h"
#import "DemoMessageListenner.h"
#import "DemoModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *routeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [routeButton setFrame:CGRectMake(100, kNavigationBarHeight+50, kScreenWidth-200, 50)];
    [routeButton setTitle:@"试一试route" forState:UIControlStateNormal];
    [routeButton addTarget:self action:@selector(tryRoute) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:routeButton];
    
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageButton setFrame:CGRectMake(100, kNavigationBarHeight+150, kScreenWidth-200, 50)];
    [messageButton setTitle:@"试一试messageRequest" forState:UIControlStateNormal];
    __weak typeof (self) weakSelf = self;
    [messageButton addAction:^{
        [weakSelf tryMessage];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messageButton];
    
    UIView *view = [[UIView alloc] init];
    [view setFrame:CGRectMake(100, kNavigationBarHeight+250, kScreenWidth-200, 50)];
    [self.view addSubview:view];
    
    DemoModel *model = [[DemoModel alloc] init];
    DemoSubModel *sub = [[DemoSubModel alloc] init];
    sub.propertyInt = 22;
    sub.propertyString = @"sub";
    model.propertySubModel = sub;
    
    NSMutableArray *ma = [NSMutableArray array];
    for (int i=0; i<5; i++) {
        DemoSubModelInArray *sa = [[DemoSubModelInArray alloc] init];
        sa.name = [NSString stringWithFormat:@"%d个",i];
        sa.index = i;
        [ma addObject:sa];
    }
    model.propertyMutableArray = ma;
    
    model.propertyNumber = @(11);
    model.ID = 10010;
    NSDictionary *dic = [model propertyList];
    
    DemoModel *modelBack = [[DemoModel alloc] initWithDictionary:dic];
    
    NSLog(@"modelBack.sub.int = %ld",modelBack.propertySubModel.propertyInt);
}

- (void)dealloc
{
    [self wb_messageRequest_unRegisteListenner];
}

- (void)tryRoute
{
    //route的使用方式
    [WBURLRoute openUrl:@"demo/test?id=1" params:@{@"testParam":@"xxx"} callback:^(NSDictionary *param) {
        NSLog(@"getCallBack&Param = %@",param);
    }];
}

- (void)tryMessage
{
    //message的使用方式
    [self wb_messageRequest_registeListenner];
    [self wb_messageRequest_request:[DemoMessageListenner sharedListenner].wb_id params:@{@"hi":@"hi,我是vc"} complete:^(id response) {
        NSLog(@"vc收到请求的反馈了:%@",response);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
