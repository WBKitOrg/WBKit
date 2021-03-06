//
//  ViewController.m
//  WBKitDemo
//
//  Created by wangbo on 2017/12/29.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "ViewController.h"
#import "DemoStaticTableViewController.h"
#import "DemoMessageListenner.h"
#import "DemoModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    UIButton *toStaticTableButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [toStaticTableButton setFrame:CGRectMake(100, kNavigationBarHeight+250, kScreenWidth-200, 50)];
    [toStaticTableButton setTitle:@"静态tableViewController" forState:UIControlStateNormal];
    [toStaticTableButton addAction:^{
        DemoStaticTableViewController *staticTable = [[DemoStaticTableViewController alloc] init];
        [weakSelf.navigationController pushViewController:staticTable animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toStaticTableButton];
    
    
    self.addEventInLifeCircle(WBLifeCircleViewDidAppear, ^{
        DemoModel *model = [DemoModel getFromDisk];
        if (!model) {
            model = [[DemoModel alloc] init];
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
        }
        NSDictionary *dic = [model propertyList];
        DemoModel *modelBack = [[DemoModel alloc] initWithDictionary:dic];
        [modelBack saveToDisk];
        
        NSLog(@"dic = %@",dic);
        NSLog(@"model = %@",modelBack.description);
    });
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithHandler:^{
        NSLog(@"didTap");
    }];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)dealloc
{
    [self wb_messageRequest_unRegisteListenner];
}

- (void)tryRoute
{
    
    [WBURLRoute openUrl:@"flyclip/normalwindow/open"];
    
//    //route的使用方式
//    [WBURLRoute openUrl:@"demo/test?id=1" params:@{@"testParam":@"xxx"} callback:^(NSDictionary *param) {
//        NSLog(@"getCallBack&Param = %@",param);
//    }];
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
