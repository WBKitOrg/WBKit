//
//  DemoStaticTableViewController.m
//  WBKitDemo
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "DemoStaticTableViewController.h"
#import "ViewController.h"
#import "UIButtonBadgeViewController.h"
#import "WBModelView.h"

@interface DemoStaticTableViewController ()

@end

@implementation DemoStaticTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navigationController.view.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];

    
    NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:3];
    [section1 addObject:[self firstCell]];
    [section1 addObject:[self secondCell]];
    [section1 addObject:[self thirdCell]];
    [self.sections addObject:section1];

    NSMutableArray *section2 = [NSMutableArray arrayWithCapacity:2];
    [section2 addObject:[self forthCell]];
    [section2 addObject:[self fifthCell]];
    [self.sections addObject:section2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)firstCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = @"代码初始化ViewController";
    cell.cellHeight = 40;
    __weak typeof (self) weakSelf = self;
    __weak typeof (cell) weakCell = cell;
    cell.cellDidSelect = ^{
        [weakCell setSelected:NO animated:YES];
        ViewController *vc = [[ViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    return cell;
}
- (UITableViewCell *)secondCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = @"IB初始化ViewController";
    cell.cellHeight = 60;
    __weak typeof (self) weakSelf = self;
    __weak typeof (cell) weakCell = cell;
    cell.cellDidSelect = ^{
        [weakCell setSelected:NO animated:YES];
        UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
        ViewController *vc = [board instantiateViewControllerWithIdentifier:@"ViewController"];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    return cell;
}
- (UITableViewCell *)thirdCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = @"测试串行事件";
    cell.cellHeight = 80;
    __weak typeof (cell) weakCell = cell;
    cell.cellDidSelect = ^{
        [weakCell setSelected:NO animated:YES];
        
        WBModelView *modelView = [WBModelView show];

        WBSerialAction *serialAction = [WBSerialAction sharedSerialAction];
        id<WBSerialActionHandler> handler = serialAction.addAction(^(void (^complete)(void)){
            NSLog(@"事件1开始");
            [modelView addWithString:@"1"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"事件1完成");
                [modelView addWithString:@"1"];
                complete();
            });
        }).addAction(^(void (^complete)(void)){
            NSLog(@"事件2开始");
            [modelView addWithString:@"2"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"事件2完成");
                [modelView addWithString:@"2"];
                complete();
            });
        }).addAction(^(void (^complete)(void)){
            NSLog(@"事件3开始");
            [modelView addWithString:@"3"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"事件3完成");
                [modelView addWithString:@"3"];
                complete();
            });
        });
        
        [handler setComplte:^{
            NSLog(@"串行事件完成");
            [modelView addWithString:@"完成"];
        }];
        
        NSLog(@"串行事件开始");
        [modelView addWithString:@"开始"];
        [handler start];
        
        serialAction.addAction(^(void (^complete)(void)){
            NSLog(@"事件4开始");
            [modelView addWithString:@"4"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"事件4完成");
                [modelView addWithString:@"4"];
                complete();
            });
        });
    };
    return cell;
}
- (UITableViewCell *)forthCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"第四个cell";
    cell.cellHeight = 100;
    cell.cellDidSelect = ^{
        NSLog(@"forthCellDidSelect");
    };
    return cell;
}
- (UITableViewCell *)fifthCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"UIButton+badge";
    
    cell.cellHeight = 120;
    __weak typeof (self) weakSelf = self;
    cell.cellDidSelect = ^{
        UIButtonBadgeViewController *buttonBadgeVC = [UIButtonBadgeViewController new];
        [weakSelf.navigationController pushViewController:buttonBadgeVC animated:YES];
    };
    return cell;
}

@end
