//
//  WBClipableViewController.m
//  FlyClip
//
//  Created by wangbo on 16/12/30.
//  Copyright © 2016年 tongboshu. All rights reserved.
//

#import "WBClipableViewController.h"
#import <objc/runtime.h>
@interface WBClipableViewController ()

@end

@implementation WBClipableViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isDidAppear = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化靠边弹性0.2,在wbflyclip中默认0.5,保留个人对弹性动画美感的理解
    self.nodeSpringDamping = 0.2;
    self.clipId = [NSString stringWithFormat:@"%@=====%lf",NSStringFromClass([self class]),[NSDate date].timeIntervalSince1970];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)zoomIn{
    [self WBFlyClip_zoomIn];
}
-(void)zoomOut{
    [self WBFlyClip_zoomOut];
}
-(void)zoomAway{
    if ([self.delegate respondsToSelector:@selector(WBClipableViewControllerWillDisappear:)]) {
        [self.delegate WBClipableViewControllerWillDisappear:self];
    }
    [self WBFlyClip_flyOut];
}

-(void)switchWithClipViewController:(WBClipableViewController *)clipController{
    
    if(!clipController.isDidAppear)
    {
        NSLog(@"不能交换");
        return;
    }
    void (^switchComplish)();
    
    if ([self isZoomedIn] && self.enableClipGestureOut) {
        [self setEnableClipGestureOut:NO];
        switchComplish = ^{
            [self setEnableClipGestureOut:YES];
        };
    }else if ([clipController isZoomedIn] && clipController.enableClipGestureOut){
        [clipController setEnableClipGestureOut:NO];
        switchComplish = ^{
            [clipController setEnableClipGestureOut:YES];
        };
    }
    
    [self WBFlyClip_switchWithNodeController:clipController complete:^{
        if (switchComplish) {
            switchComplish();
        }
    }];
}


- (void)WBFlyClip_ViewNeedTransformToRect:(CGRect)rect{
    if (CGRectEqualToRect(rect, self.nodeFrame)) {
        if ([self.delegate respondsToSelector:@selector(WBClipableViewControllerDidZoomIn:rect:)]) {
            [self.delegate WBClipableViewControllerDidZoomIn:self rect:rect];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(WBClipableViewControllerDidZoomOut:)]) {
            [self.delegate WBClipableViewControllerDidZoomOut:self];
        }
    }
}

#pragma mark - staticMethods

+(NSArray<NSString *> *)clipIds{
    return [UIViewController WBFlyClip_ViewControlerIds];
}

+(UIViewController *)getClipedControllerWithId:(NSString *)clipId{
    return [UIViewController WBFlyClip_ViewControllerForNodeId:clipId];
}

#pragma mark - propertySetter&Getter

- (void)setEnableClip:(BOOL)enableClip{
    self.nodeEnable = enableClip;
}

-(BOOL)enableClip{
    return self.nodeEnable;
}

- (void)setEnableClipGestureOut:(BOOL)enableClipGestureOut{
    self.nodeGestureZoomOut = enableClipGestureOut;
}

-(BOOL)enableClipGestureOut{
    return self.nodeGestureZoomOut;
}

- (void)setEnableClipGestureRemove:(BOOL)enableClipGestureRemove{
    self.nodeGestureFlyOut = enableClipGestureRemove;
}

-(BOOL)enableClipGestureRemove{
    return self.nodeGestureFlyOut;
}

- (void)setClipFrame:(CGRect)clipFrame{
    //将setter方法改为动画变换
//    self.nodeFrame = clipFrame;
    if(clipFrame.origin.y+clipFrame.size.height>[UIScreen mainScreen].bounds.size.height)
    {
        clipFrame = CGRectMake(clipFrame.origin.x, [UIScreen mainScreen].bounds.size.height-clipFrame.size.height, clipFrame.size.width, clipFrame.size.height);
    }
    if(clipFrame.origin.y<0)
    {
        clipFrame.origin.y = 0;
    }
    [self setNodeFrame:clipFrame animated:YES];
}

- (CGRect)clipFrame{
    return self.nodeFrame;
}

- (void)setClipId:(NSString *)clipId
{
    self.nodeId = clipId;
}

- (NSString *)clipId
{
    return self.nodeId;
}


@end
