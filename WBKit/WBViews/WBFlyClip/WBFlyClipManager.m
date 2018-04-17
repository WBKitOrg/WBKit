//
//  WBFlyClipManager.m
//
//  Created by wangbo on 16/12/2.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "WBFlyClipManager.h"
#import "UIViewController+FindCurrentHelper.h"
#import <objc/runtime.h>


static const int32_t moveInY                 = 64;
static const int32_t defaultNodeFrameWidth   = 200;
static const int32_t defaultNodeFrameHeight  = 100;
static const int32_t defaultNodeGap          = 10;
static const int32_t defaultNodeTabbarHeight = 50;

@interface WBFlyClipManager ()

@property (nonatomic,assign)BOOL zoomAnimating;
@end

@implementation WBFlyClipManager

+(WBFlyClipManager *)sharedManager{
    static dispatch_once_t onceToken;
    static WBFlyClipManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - 初始化方法

- (instancetype)init{
    self = [super init];
    if (self) {
        self.springDamping = 0.7;
    }
    return self;
}


#pragma mark - 关键方法

-(void)zoomInViewController:(UIViewController<WBFlyClipNodeProtocal> *)viewController{
    [self zoomInViewController:viewController complete:nil];
}

-(void)zoomInViewController:(UIViewController<WBFlyClipNodeProtocal> *)viewController complete:(void (^)(void))complete{
    //如果存在一个vcid标注的node，返回不做处理
    if ([self managedControllerNodeshasNVCforID:viewController.nodeId]) {
        return;
    }
    
    if (self.zoomAnimating) {
        return;
    }
    
    //添加进managedControllerNodes中，保持活跃
    [self.managedControllerNodes addObject:viewController];
    
    [self missingNodeViewController:viewController complete:^{
        //加载到应用最上层window中
        [[UIApplication sharedApplication].keyWindow addSubview:viewController.view];
        [viewController.view.layer setMasksToBounds:YES];
        
        self.zoomAnimating = YES;
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            zoomAnimating = NO;
        //        });
        
        //动画变化
        [UIView animateWithDuration:.45 delay:0.0 usingSpringWithDamping:self.springDamping initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            if ([viewController respondsToSelector:@selector(WBFlyClip_ViewNeedTransformToRect:)]) {
                [viewController WBFlyClip_ViewNeedTransformToRect:viewController.nodeFrame];
            }
            [viewController.view setFrame:viewController.nodeFrame];
        } completion:^(BOOL finished) {
            self.zoomAnimating = NO;
            if (complete) {
                complete();
            }
        }];
        
    }];
}

-(UIViewController *)zoomOutViewControllerWithID:(NSString *)vcid{
    return [self zoomOutViewControllerWithID:vcid complete:nil];
}

-(UIViewController *)zoomOutViewControllerWithID:(NSString *)vcid complete:(void (^)(void))complete{
    if (self.zoomAnimating) {
        return nil;
    }
    UIViewController<WBFlyClipNodeProtocal> *NodeVCToZoomout = [self NodeControllerWithID:vcid];//需要放大的flyClipvc
    UIViewController *currentVC = [UIViewController currentViewController];//当前最上层vc
    
    //将当前所有的小窗口移动到最上层,将要放大的view必须放在当前window最下层，否则会覆盖其他的flyClip
    for (UIViewController<WBFlyClipNodeProtocal> *flyclip in self.managedControllerNodes) {
        if (flyclip != NodeVCToZoomout) {
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:flyclip.view];
        }
    }
    
    //放大事件触发时间
    self.zoomAnimating = YES;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        zoomAnimating = NO;
//    });
    //动画变化
    [UIView animateWithDuration:.45 delay:0.0 usingSpringWithDamping:self.springDamping initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        if ([NodeVCToZoomout respondsToSelector:@selector(WBFlyClip_ViewNeedTransformToRect:)]) {
            [NodeVCToZoomout WBFlyClip_ViewNeedTransformToRect:CGRectMake(0,0,ScreenWidth,ScreenHeight)];
        }
        [NodeVCToZoomout.view setFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight)];
    } completion:^(BOOL finished) {
        //动画处理完成之后再做还原操作
        
        CATransition *transition = [CATransition animation];
        transition.duration = .15;
        transition.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionFade;
        [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:nil];
        
        __weak typeof (self) WeakSelf = self;
        [self restoreViewController:NodeVCToZoomout ToBaseViewController:currentVC complete:^{
            
            //由于modal出来的vc会有将window覆盖的可能，暂时着么改,将当前所有的小窗口移动到最上层
            for (UIViewController<WBFlyClipNodeProtocal> *flyclip in self.managedControllerNodes) {
                if (flyclip != NodeVCToZoomout) {
                    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:flyclip.view];
                }
            }
            
            //还原完成之后移除nodevc
            [WeakSelf.managedControllerNodes removeObject:NodeVCToZoomout];
            
            self.zoomAnimating = NO;
            
            if (complete) {
                complete();
            }
        }];
        
    }];
    
    return NodeVCToZoomout;
}



-(void)flyOutViewControllerWithID:(NSString *)vcid{
    [self flyOutViewControllerWithID:vcid complete:nil];
}

-(void)flyOutViewControllerWithID:(NSString *)vcid complete:(void (^)(void))complete{
    UIViewController<WBFlyClipNodeProtocal> *nodeVCToFlyOut = [self NodeControllerWithID:vcid];//需要移除的flyClipvc
    if (![objc_getAssociatedObject(nodeVCToFlyOut, @"isFlyingOut") boolValue]) {
        objc_setAssociatedObject(nodeVCToFlyOut, @"isFlyingOut", @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        CATransition *transition = [CATransition animation];
        transition.duration = .15;
        transition.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionPush;
        
        if (nodeVCToFlyOut.view.center.x>=ScreenWidth/2) {//在屏幕右边
            transition.subtype = kCATransitionFromLeft;
        }else{
            transition.subtype = kCATransitionFromRight;
        }
        [nodeVCToFlyOut.view.layer addAnimation:transition forKey:nil];
        [nodeVCToFlyOut.view setHidden:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //动画完成之后移除vc
            objc_setAssociatedObject(nodeVCToFlyOut, @"isFlyingOut", @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [nodeVCToFlyOut.view removeFromSuperview];
            [self.managedControllerNodes removeObject:nodeVCToFlyOut];
            
            if (complete) {
                complete();
            }
        });
    }
}


-(void)switchViewController:(UIViewController<WBFlyClipNodeProtocal> *)viewController withNodeControllerId:(NSString *)nodeId{
    [self switchViewController:viewController withNodeControllerId:nodeId complete:nil];
}

-(void)switchViewController:(UIViewController<WBFlyClipNodeProtocal> *)viewController withNodeControllerId:(NSString *)nodeId complete:(void (^)(void))complete{
    
    UIViewController<WBFlyClipNodeProtocal> *NodeVCToZoomout = [self NodeControllerWithID:nodeId];//需要放大的flyClipvc
    
    //设置需要缩小的vc的nodeframe
    viewController.nodeFrame = CGRectMake(NodeVCToZoomout.nodeFrame.origin.x, NodeVCToZoomout.nodeFrame.origin.y, viewController.nodeFrame.size.width, viewController.nodeFrame.size.height);
    
    __weak typeof (self) WeakSelf = self;
    void (^restoreBlock)(void) = ^{
        //由于modal出来的vc会有将window覆盖的可能，暂时着么改,将当前所有的小窗口移动到最上层
        for (UIViewController<WBFlyClipNodeProtocal> *flyclip in self.managedControllerNodes) {
            if (flyclip != NodeVCToZoomout) {
                [[UIApplication sharedApplication].keyWindow bringSubviewToFront:flyclip.view];
            }
        }
        
        //还原完成之后移除nodevc
        [WeakSelf.managedControllerNodes removeObject:NodeVCToZoomout];
        
        self.zoomAnimating = NO;
        
        if (complete) {
            complete();
        }
    };
    
    
    void (^missingBlock)(void) = ^{
        
        //加载到应用最上层window中
        [[UIApplication sharedApplication].keyWindow addSubview:viewController.view];
        [viewController.view.layer setMasksToBounds:YES];

        self.zoomAnimating = YES;
        
        //将当前所有的小窗口移动到最上层,将要放大的view必须放在当前window最下层，否则会覆盖其他的flyClip
        for (UIViewController<WBFlyClipNodeProtocal> *flyclip in self.managedControllerNodes) {
            if (flyclip != NodeVCToZoomout) {
                [[UIApplication sharedApplication].keyWindow bringSubviewToFront:flyclip.view];
            }
        }
        //动画
        [UIView animateWithDuration:.45 delay:0.0 usingSpringWithDamping:self.springDamping initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            if ([viewController respondsToSelector:@selector(WBFlyClip_ViewNeedTransformToRect:)]) {
                [viewController WBFlyClip_ViewNeedTransformToRect:viewController.nodeFrame];
            }
            [viewController.view setFrame:viewController.nodeFrame];
            
            if ([NodeVCToZoomout respondsToSelector:@selector(WBFlyClip_ViewNeedTransformToRect:)]) {
                [NodeVCToZoomout WBFlyClip_ViewNeedTransformToRect:CGRectMake(0,0,ScreenWidth,ScreenHeight)];
            }
            [NodeVCToZoomout.view setFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight)];
            
        } completion:^(BOOL finished) {
            
            //动画处理完成之后再做还原操作
            
            CATransition *transition = [CATransition animation];
            transition.duration = .15;
            transition.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            transition.type = kCATransitionFade;
            [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:nil];
            
            UIViewController *currentVC = [UIViewController currentViewController];//当前最上层vc
            //放大
            [self restoreViewController:NodeVCToZoomout ToBaseViewController:currentVC complete:restoreBlock];
        }];
        
    };
    
    
    //如果存在一个vcid标注的node，返回不做处理
    if ([self managedControllerNodeshasNVCforID:viewController.nodeId]) {
        return;
    }
    if (self.zoomAnimating) {
        return;
    }
    //添加进managedControllerNodes中，保持活跃
    [self.managedControllerNodes addObject:viewController];
    
    //缩小
    [self missingNodeViewController:viewController complete:missingBlock];
}



-(void)missingNodeViewController:(UIViewController<WBFlyClipNodeProtocal> *)nodeVc complete:(void(^)(void))complete{
    //从当前控制器管理中移除
    
    //先判断是否有nav
    if ([nodeVc navigationController]) {
        nodeVc.nodeAppear = WBViewControllerAppearPush;//push
    }else{
        nodeVc.nodeAppear = WBViewControllerAppearModal;//modal
    }
    
    if (![nodeVc isEqual:[UIViewController currentViewController]]) {
        //nodevc未在viewcontroller栈中存在，仅初始化
        //对未进入controller栈的vc的view直接设置view在屏幕外
        nodeVc.view.frame = CGRectMake(-nodeVc.nodeFrame.size.width, moveInY, nodeVc.nodeFrame.size.width, nodeVc.nodeFrame.size.height);
        complete();
    }else if (nodeVc.navigationController.viewControllers.count>1 && [nodeVc.navigationController.topViewController isEqual:nodeVc]) {//如果存在navigationController并且navigationController的子controller大于一个，并且viewController是最上层
        complete();
        
        [nodeVc.navigationController popViewControllerAnimated:NO];
    }else if(![nodeVc navigationController] || [nodeVc navigationController].viewControllers.count==1){//不存在nav，或者nav的viewcontroller只有一个，即本身，则这个vc是modal出来的
        [nodeVc.presentingViewController dismissViewControllerAnimated:NO completion:^{
            complete();
        }];
    }
}

-(void)restoreViewController:(UIViewController<WBFlyClipNodeProtocal> *)vc ToBaseViewController:(UIViewController *)baseVc complete:(void(^)(void))complete{
    if (baseVc.navigationController) {//存在navigation
        if (vc.nodeAppear == WBViewControllerAppearPush) {
            //需要放大的vc是navigationpush出来的
            
            //如果存在backItem
            if (objc_getAssociatedObject(vc, @"backItem")) {
                vc.navigationItem.leftBarButtonItem = nil;//清空返回按钮，使用系统的
            }
            [baseVc.navigationController pushViewController:vc animated:NO];
            complete();
        }else if (vc.nodeAppear == WBViewControllerAppearModal){
            //需要放大的vc是model出来的
            [baseVc.navigationController presentViewController:vc animated:NO completion:^{
                complete();
            }];
        }else{
            //其他情况
            NSLog(@"WBFlyClipManager - not exist,for extention");
            complete();
        }
    }else{//当前页面不存在nav
        if (vc.nodeAppear == WBViewControllerAppearPush) {
            //需要放大的vc是navigationpush出来的,手动添加一个nav给即将出现的vc
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            UIBarButtonItem *itemleft = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:vc action:@selector(WBFlyClip_back:)];
            [itemleft setTintColor:nav.navigationBar.tintColor];
            vc.navigationItem.leftBarButtonItem = itemleft;
            //记录backitem
            objc_setAssociatedObject(vc, @"backItem", itemleft, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [baseVc presentViewController:nav animated:NO completion:^{
                complete();
            }];
        }else if (vc.nodeAppear == WBViewControllerAppearModal){
            //需要放大的vc是model出来的
            [baseVc presentViewController:vc animated:NO completion:^{
                complete();
            }];
        }else{
            //其他情况
            NSLog(@"WBFlyClipManager - not exist,for extention");
            complete();
        }
    }
}

#pragma mark - 数据方法

-(NSArray *)nodeIds{
    NSMutableArray *ids = [NSMutableArray array];
    for (UIViewController *nodeController in self.managedControllerNodes) {
        [ids addObject:nodeController.nodeId];
    }
    return ids;
}

-(UIViewController<WBFlyClipNodeProtocal> *)NodeControllerWithID:(NSString *)vcid{
    for (UIViewController *nodeController in self.managedControllerNodes) {
        if ([nodeController.nodeId isEqualToString:vcid]) {
            return nodeController;
        }
    }
    return nil;
}

-(BOOL)managedControllerNodeshasNVCforID:(NSString *)vcid{
    if ([self NodeControllerWithID:vcid]) {
        return YES;
    }
    return NO;
}

-(CGRect)blankRectForNextZoomInViewController{
    //#warning TODO:需要一个算法计算控制器需要显示在哪个位置
    int originY = moveInY;
    while (originY<ScreenHeight-defaultNodeFrameHeight-defaultNodeTabbarHeight) {//刨除tabbar的高度
        if ([self canShowInRect:CGRectMake(ScreenWidth-defaultNodeFrameWidth, originY, defaultNodeFrameWidth, defaultNodeFrameHeight)]) {
            return CGRectMake(ScreenWidth-defaultNodeFrameWidth, originY, defaultNodeFrameWidth, defaultNodeFrameHeight);
        }
        originY+=defaultNodeFrameHeight+defaultNodeGap;
    }
    return CGRectMake(ScreenWidth-defaultNodeFrameWidth, moveInY, defaultNodeFrameWidth, defaultNodeFrameHeight);
}

-(BOOL)canShowInRect:(CGRect)rect{
    for (UIViewController<WBFlyClipNodeProtocal> *nodeVc in self.managedControllerNodes) {
        if (CGRectIntersectsRect(nodeVc.nodeFrame, rect)) {//相交
            return NO;
        }
    }
    //如果没有相交，可以现实当前rect
    return YES;
}

#pragma mark - 懒加载

-(NSMutableArray<UIViewController<WBFlyClipNodeProtocal> *> *)managedControllerNodes{
    if (!_managedControllerNodes) {
        _managedControllerNodes = [NSMutableArray array];
    }
    return _managedControllerNodes;
}


@end



