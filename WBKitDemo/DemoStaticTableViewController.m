//
//  DemoStaticTableViewController.m
//  WBKitDemo
//
//  Created by wangbo on 2018/1/29.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "DemoStaticTableViewController.h"
#import "ViewController.h"

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
    cell.textLabel.text = @"第三个cell";
    cell.cellHeight = 80;
    __weak typeof (cell) weakCell = cell;
    cell.cellDidSelect = ^{
        [weakCell setSelected:NO animated:YES];
        NSLog(@"thirdCellDidSelect");
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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(50, 20, 150, 80)];
    [button setTitle:@"第五个cell" forState:UIControlStateNormal];
    [cell.contentView addSubview:button];
    
    [button setWb_badgeColor:[UIColor blueColor]];
    [button setWb_badgeFontSize:0];
    [button setWb_badgeInset:20];
    [button setWb_borderInset:60];
    [button wb_showBadgeWithContent:@"" animated:YES];
    
    cell.cellHeight = 120;
    cell.cellDidSelect = ^{
        NSLog(@"fifthCellDidSelect");
    };
    return cell;
}

@end
