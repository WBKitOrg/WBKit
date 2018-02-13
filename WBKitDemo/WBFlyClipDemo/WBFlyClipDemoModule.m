//
//  WBFlyClipDemoModule.m
//  WBKitDemo
//
//  Created by wangbo on 2018/2/13.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "WBFlyClipDemoModule.h"
#import "WBFlyClipDemoViewController.h"

@implementation WBFlyClipDemoModule

REGISTER_MODULE

+ (NSInteger)priority
{
    return WBModulePriorityVeryHigh;
}

- (void)moduleDidInit:(WBModuleManager *)manager
{
    //do some manager init
    
    [self registerRoutes];
}

- (void)registerRoutes
{
    [WBURLRoute registerPattern:@"flyclip/smallwindow/open?id=&switch=" handler:^BOOL(NSDictionary *param, WBRouteCallback callback) {
        WBFlyClipDemoViewController *flyclipController = [[WBFlyClipDemoViewController alloc] init];
        if ([param valueForKey:@"id"]) {
            flyclipController.wb_id = [param valueForKey:@"id"];
        }
        [flyclipController zoomIn];
        if ([[param valueForKey:@"switch"] boolValue]) {
            //设置相互交换，这里代码比较复杂
            flyclipController.enableClipGestureOut = NO;
            __weak typeof (flyclipController) weakflyC = flyclipController;
            flyclipController.clip_tapGestureHandler = ^(UITapGestureRecognizer *tap) {
                
                if ([[UIViewController currentViewController] isKindOfClass:[WBFlyClipDemoViewController class]]) {
                    WBFlyClipDemoViewController *current = (WBFlyClipDemoViewController *)[UIViewController currentViewController];
                    current.enableClipGestureOut = NO;
                    __weak typeof (current) weakCurrent = current;
                    [current setClip_tapGestureHandler:^(UITapGestureRecognizer *tap) {
                        [weakCurrent switchWithClipViewController:weakflyC];
                    }];
                    
                    [weakflyC switchWithClipViewController:current];
                }
            };
        }
        return YES;
    }];
    
    [WBURLRoute registerPattern:@"flyclip/normalwindow/open?id=" handler:^BOOL(NSDictionary *param, WBRouteCallback callback) {
        WBFlyClipDemoViewController *flyclipController = [[WBFlyClipDemoViewController alloc] init];
        if ([param valueForKey:@"id"]) {
            flyclipController.wb_id = [param valueForKey:@"id"];
        }
        [[UIViewController currentViewController] presentViewController:flyclipController animated:YES completion:nil];
        return YES;
    }];
}

@end
