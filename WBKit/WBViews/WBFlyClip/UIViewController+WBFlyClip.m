//
//  UIViewController+WBFlyClip.m
//
//  Created by wangbo on 16/12/3.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "UIViewController+WBFlyClip.h"
#import "UIViewController+FindCurrentHelper.h"
#import <objc/runtime.h>
#import "WBFlyClipManager.h"

@interface UIViewController ()

@property (nonatomic , assign) CGPoint panGesCenter;

@end

static const char *marginKey = "fcmargin";

static const char *flyoutBlockKey = "flyoutBlockKey";

static CGFloat fc_margin_ = 0;

@implementation UIViewController (WBFlyClip)

+ (CGFloat)fc_margin {
    return fc_margin_;
}

+ (void)setFc_margin:(CGFloat)fc_margin {
    fc_margin_ = fc_margin;
}

- (CGFloat)fc_margin {
    NSNumber *numer = objc_getAssociatedObject(self, marginKey);
    if (numer) {
        return numer.doubleValue;
    }
    return fc_margin_;
}

- (void)setFc_margin:(CGFloat)fc_margin {
    objc_setAssociatedObject(self, marginKey, @(fc_margin), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - 关键方法，放大缩小

-(void)WBFlyClip_zoomIn{
    [self WBFlyClip_zoomInComplete:nil];
}

-(void)WBFlyClip_zoomInComplete:(void (^)(void))complete{
    if ([self isZoomedIn]) {
        return;
    }
    [[WBFlyClipManager sharedManager] zoomInViewController:self complete:^{
        [self WBFlyClip_addGestures];
        if (complete) {
            complete();
        }
    }];
}

-(void)WBFlyClip_zoomOut{
    [self WBFlyClip_zoomOutComplete:nil];
}

-(void)WBFlyClip_zoomOutComplete:(void (^)(void))complete{
    if (![self isZoomedIn]) {
        return;
    }
    if ([[WBFlyClipManager sharedManager] zoomOutViewControllerWithID:self.nodeId complete:complete]) {
        [self WBFlyClip_releaseGestures];
    }
}

-(void)WBFlyClip_flyOut{
    [self WBFlyClip_flyOutComplete:nil];
}

- (void (^)(void))fc_flyOutBlock {
    return objc_getAssociatedObject(self, flyoutBlockKey);
}

- (void)setFc_flyOutBlock:(void (^)(void))fc_flyOutBlock {
    if (fc_flyOutBlock) {
        objc_setAssociatedObject(self, flyoutBlockKey, fc_flyOutBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

-(void)WBFlyClip_flyOutComplete:(void (^)(void))complete{
    if (![self isZoomedIn]) {
        return;
    }
    
    if (self.fc_flyOutBlock) {
        self.fc_flyOutBlock();
    }
    
    [[WBFlyClipManager sharedManager] flyOutViewControllerWithID:self.nodeId complete:complete];
    
    [self WBFlyClip_releaseGestures];
}

-(void)WBFlyClip_switchWithNodeId:(NSString *)nodeId{
    [self WBFlyClip_switchWithNodeId:nodeId complete:nil];
}
-(void)WBFlyClip_switchWithNodeId:(NSString *)nodeId complete:(void (^)(void))complete{
    if ([UIViewController currentViewController] == self && ![self isZoomedIn]) {//当前vc是缩小状态
        //得到需要缩小的vc
        UIViewController<WBFlyClipNodeProtocal> *nodeViewController = [[self class] WBFlyClip_ViewControllerForNodeId:nodeId];
        [nodeViewController WBFlyClip_releaseGestures];
        
        [[WBFlyClipManager sharedManager] switchViewController:self withNodeControllerId:nodeId complete:^{
            [self WBFlyClip_addGestures];
            if (complete) {
                complete();
            }
        }];
        return;
    }
    NSLog(@"WBFlyClip_不能完成交换");
}

-(void)WBFlyClip_switchWithNodeController:(UIViewController<WBFlyClipNodeProtocal> *)nodeController{
    [self WBFlyClip_switchWithNodeController:nodeController complete:nil];
}

-(void)WBFlyClip_switchWithNodeController:(UIViewController<WBFlyClipNodeProtocal> *)nodeController complete:(void (^)(void))complete{
    
    void (^switchComplete)(void);
    
    if ([self isZoomedIn] && self.nodeGestureZoomOut) {
        [self setNodeGestureZoomOut:NO];
        switchComplete = ^{
            [self setNodeGestureZoomOut:YES];
        };
    }else if ([nodeController isZoomedIn] && nodeController.nodeGestureZoomOut){
        [nodeController setNodeGestureZoomOut:NO];
        switchComplete = ^{
            [nodeController setNodeGestureZoomOut:YES];
        };
    }
    
    if ([self isZoomedIn] && nodeController == [UIViewController currentViewController]) {//当前vc是缩小状态
        [self WBFlyClip_releaseGestures];
        
        [[WBFlyClipManager sharedManager] switchViewController:nodeController withNodeControllerId:self.nodeId complete:^{
            //对当前vc添加缩小后的手势
            [nodeController WBFlyClip_addGestures];
            
            if (switchComplete) {
                switchComplete();
            }
            
            if (complete) {
                complete();
            }
        }];
    }else if([nodeController isZoomedIn] && self == [UIViewController currentViewController]){//当前vc是栈内正常vc
        [nodeController WBFlyClip_releaseGestures];
        
        [[WBFlyClipManager sharedManager] switchViewController:self withNodeControllerId:nodeController.nodeId complete:^{
            [self WBFlyClip_addGestures];
            
            if (switchComplete) {
                switchComplete();
            }
            
            if (complete) {
                complete();
            }
        }];
        
    }else{
        NSLog(@"WBFlyClip_不能完成交换");
    }
}

#pragma mark - 手势处理

-(void)WBFlyClip_addGestures{
    //单机放大手势
    UITapGestureRecognizer *tapToZoomOut = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(WBFlyClip_Tap:)];
    [self.view addGestureRecognizer:tapToZoomOut];
    objc_setAssociatedObject(self, @"zoomOutTap", tapToZoomOut, OBJC_ASSOCIATION_RETAIN_NONATOMIC);//添加进属性
    
    //拖拽移动手势
    UIPanGestureRecognizer *panToMove = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(WBFlyClip_NeedPanToMove:)];
    [self.view addGestureRecognizer:panToMove];
    objc_setAssociatedObject(self, @"movePan", panToMove, OBJC_ASSOCIATION_RETAIN_NONATOMIC);//添加进属性
}

-(void)WBFlyClip_releaseGestures{
    //移除单机放大手势
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, @"zoomOutTap");
    if (tap) {
        [self.view removeGestureRecognizer:tap];
    }
    
    //移除拖拽移动手势
    UIPanGestureRecognizer *pan = objc_getAssociatedObject(self, @"movePan");
    if (pan) {
        [self.view removeGestureRecognizer:pan];
    }
}

-(void)WBFlyClip_Tap:(UITapGestureRecognizer *)tap{
    
    //将tap手势传递出去
    if (self.clip_tapGestureHandler) {
        self.clip_tapGestureHandler(tap);
    }
    if (self.nodeGestureZoomOut) {
        [self WBFlyClip_zoomOut];
    }
}

-(void)WBFlyClip_NeedPanToMove:(UIPanGestureRecognizer *)pan{
    
    //将pan手势传递出去
    if (self.clip_panGestureHandler) {
        self.clip_panGestureHandler(pan);
    }
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.panGesCenter = self.view.center;
    }
    
    CGPoint translationPoint = [pan translationInView:self.view.superview];
    CGPoint newCenter = CGPointMake(self.panGesCenter.x + translationPoint.x,
                                    self.panGesCenter.y + translationPoint.y);
    //限定在屏幕范围内
    newCenter.x = fmaxf(0, newCenter.x);
    newCenter.x = fminf(newCenter.x, CGRectGetMaxX(self.view.superview.frame));
    newCenter.y = fmaxf(0, newCenter.y);
    newCenter.y = fmin(newCenter.y, CGRectGetMaxY(self.view.superview.frame));
    
    if (self.nodeGestureFlyOut) {
        //如果靠边还往外划，则移除
        if ((newCenter.x == 0 && self.view.center.x == 0) || (newCenter.x == ScreenWidth && self.view.center.x == ScreenWidth)) {
            [self WBFlyClip_flyOut];
        }
    }
    
    //移动view
    self.view.center = newCenter;
    
    //结束之后调整位置动画
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self panGesEnd];
    }
}

-(void)panGesEnd{
    CGPoint endCenter;
    endCenter.y = self.view.center.y;
    if (CGRectGetMidX([UIScreen mainScreen].bounds) > self.view.center.x) {
        //向左靠
        endCenter.x = self.view.frame.size.width/2 + self.fc_margin;
    }else{
        //向右靠
        endCenter.x = ScreenWidth - self.view.frame.size.width/2-self.fc_margin;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:self.nodeSpringDamping initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.center = endCenter;
        } completion:^(BOOL finished) {
            self.nodeFrame = self.view.frame;//移动结束后设置nodeFrame
            [self.view setUserInteractionEnabled:YES];
        }];
    });
    
}

#pragma mark - 一个从nav变为modal产生的返回
-(void)WBFlyClip_back:(id)sender{
    [self closeAnimated:YES completion:nil];
}

- (void)closeAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:animated];
        if (!completion) {
            return;
        }
        if (!animated) {
            completion();
        } else {
            //延迟0.5秒保证pop动画完成
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), completion);
        }
    } else {
        [self.presentingViewController dismissViewControllerAnimated:animated completion:completion];
    }
}

#pragma mark - 判断是否缩小
-(BOOL)isZoomedIn{
    if (self.view.frame.size.width == self.nodeFrame.size.width) {
        return YES;
    }
    return NO;
}

#pragma mark - 找到所有小vc的id

+ (NSArray *)WBFlyClip_ViewControlerIds{
    return [WBFlyClipManager sharedManager].nodeIds;
}

+ (UIViewController<WBFlyClipNodeProtocal> *)WBFlyClip_ViewControllerForNodeId:(NSString *)nodeId{
    return [[WBFlyClipManager sharedManager] NodeControllerWithID:nodeId];
}

#pragma mark - privateProperties

static char WBNodePanGesCenterKey;

-(void)setPanGesCenter:(CGPoint)panGesCenter{
    objc_setAssociatedObject(self, &WBNodePanGesCenterKey, [NSValue valueWithCGPoint:panGesCenter],OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(CGPoint)panGesCenter{
    NSValue *panGesCenterValue = objc_getAssociatedObject(self, &WBNodePanGesCenterKey);
    CGPoint panGesCenter = [panGesCenterValue CGPointValue];
    if (!panGesCenterValue) {
        panGesCenter = self.view.center;
        [self setPanGesCenter:panGesCenter];
        return panGesCenter;
    }
    return panGesCenter;
}

#pragma mark - WBFlyClipNodeProtocal publicProperties Default

static char WBNodeIdKey;
static char WBNodeAppearKey;
static char WBNodeFrameKey;
static char WBNodeSpringDampingKey;
static char WBNodeEnableKey;
static char WBNodeGestureZoomOutKey;
static char WBNodeGestureFlyOutKey;
static char WBNodeTapHandlerKey;
static char WBNodePanHandlerKey;

- (void)setNodeId:(NSString *)nodeId{
    objc_setAssociatedObject(self, &WBNodeIdKey, nodeId,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)nodeId{
    NSString *WBNodeId = objc_getAssociatedObject(self, &WBNodeIdKey);
    if (!WBNodeId) {//如果不存在，那么自动创建
        WBNodeId = [NSString stringWithFormat:@"%@|%f",NSStringFromClass([self class]),[[NSDate date] timeIntervalSince1970]];
        [self setNodeId:WBNodeId];
        return WBNodeId;
    }
    return WBNodeId;
}

-(void)setNodeFrame:(CGRect)frame animated:(BOOL)animated{
    
    self.nodeFrame = frame;
    
    if ([self isZoomedIn] && animated) {
        [UIView animateWithDuration:.25 animations:^{
            [UIView setAnimationCurve:7];
            self.view.frame = frame;
        }];
    }
}

-(void)setNodeFrame:(CGRect)nodeFrame{
    objc_setAssociatedObject(self, &WBNodeFrameKey, [NSValue valueWithCGRect:nodeFrame],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGRect)nodeFrame{
    NSValue *nodeFrameValue = objc_getAssociatedObject(self, &WBNodeFrameKey);
    CGRect WBNodeFrame = [nodeFrameValue CGRectValue];
    if (!nodeFrameValue) {
        WBNodeFrame = [[WBFlyClipManager sharedManager] blankRectForNextZoomInViewController];
        [self setNodeFrame:WBNodeFrame];
        return WBNodeFrame;
    }
    return WBNodeFrame;
}

-(void)setNodeAppear:(WBViewControllerAppear)nodeAppear{
    objc_setAssociatedObject(self, &WBNodeAppearKey, [NSNumber numberWithInteger:nodeAppear],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(WBViewControllerAppear)nodeAppear{
    NSNumber *nodeAppearNum = objc_getAssociatedObject(self, &WBNodeAppearKey);
    if (!nodeAppearNum) {
        [self setNodeAppear:WBViewControllerAppearModal];//默认modal
        return WBViewControllerAppearModal;
    }
    return (WBViewControllerAppear)[nodeAppearNum integerValue];
}

-(void)setNodeEnable:(BOOL)nodeEnable{
    objc_setAssociatedObject(self, &WBNodeEnableKey, [NSNumber numberWithBool:nodeEnable],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)nodeEnable{
    NSNumber *nodeEnableNum = objc_getAssociatedObject(self, &WBNodeEnableKey);
    if (!nodeEnableNum) {
        [self setNodeEnable:YES];//默认yes
        return YES;
    }
    return [nodeEnableNum boolValue];
}

-(void)setNodeGestureZoomOut:(BOOL)nodeGestureZoomOut{
    objc_setAssociatedObject(self, &WBNodeGestureZoomOutKey, [NSNumber numberWithBool:nodeGestureZoomOut],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)nodeGestureZoomOut{
    NSNumber *nodeGestureZoomOutNum = objc_getAssociatedObject(self, &WBNodeGestureZoomOutKey);
    if (!nodeGestureZoomOutNum) {
        [self setNodeGestureZoomOut:YES];//默认yes
        return YES;
    }
    return [nodeGestureZoomOutNum boolValue];
}

-(void)setNodeGestureFlyOut:(BOOL)nodeGestureFlyOut{
    objc_setAssociatedObject(self, &WBNodeGestureFlyOutKey, [NSNumber numberWithBool:nodeGestureFlyOut],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)nodeGestureFlyOut{
    NSNumber *nodeGestureFlyOutNum = objc_getAssociatedObject(self, &WBNodeGestureFlyOutKey);
    if (!nodeGestureFlyOutNum) {
        [self setNodeGestureFlyOut:YES];//默认yes
        return YES;
    }
    return [nodeGestureFlyOutNum boolValue];
}

-(void (^)(UITapGestureRecognizer *tap))clip_tapGestureHandler{
    return objc_getAssociatedObject(self, &WBNodeTapHandlerKey);
}

-(void)setClip_tapGestureHandler:(void (^)(UITapGestureRecognizer *))tapGestureHandler{
    objc_setAssociatedObject(self, &WBNodeTapHandlerKey, tapGestureHandler,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void (^)(UIPanGestureRecognizer *pan))clip_panGestureHandler{
    return objc_getAssociatedObject(self, &WBNodePanHandlerKey);
}

-(void)setClip_panGestureHandler:(void (^)(UIPanGestureRecognizer *))panGestureHandler{
    objc_setAssociatedObject(self, &WBNodePanHandlerKey, panGestureHandler,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)nodeSpringDamping{
    NSNumber *springNum = objc_getAssociatedObject(self, &WBNodeSpringDampingKey);
    if (!springNum) {
        [self setNodeSpringDamping:0.5f];
        return 0.5f;
    }
    return [springNum floatValue];
}

- (void)setNodeSpringDamping:(CGFloat)nodeSpringDamping{
    objc_setAssociatedObject(self, &WBNodeSpringDampingKey, @(nodeSpringDamping),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
