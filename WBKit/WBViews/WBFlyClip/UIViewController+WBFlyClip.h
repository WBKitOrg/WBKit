//
//  UIViewController+WBFlyClip.h
//
//  Created by wangbo on 16/12/3.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    WBViewControllerAppearModal = 0,
    WBViewControllerAppearPush,
}WBViewControllerAppear;

@protocol WBFlyClipNodeProtocal <NSObject>

@required
@property (nonatomic , copy) NSString *nodeId;
@property (nonatomic , assign)WBViewControllerAppear nodeAppear;
@property (nonatomic , assign) CGRect nodeFrame;
@property (nonatomic , assign) CGFloat nodeSpringDamping;//默认0.5

-(void)setNodeFrame:(CGRect)frame animated:(BOOL)animated;

@optional
@property (nonatomic , assign) BOOL   nodeEnable;
@property (nonatomic , assign) BOOL   nodeGestureZoomOut;
@property (nonatomic , assign) BOOL   nodeGestureFlyOut;

/**
 * 可以实现的方法，用来差异化显示vc
 */
-(void)WBFlyClip_ViewNeedTransformToRect:(CGRect)rect;

@end


@protocol WBFlyClipNodeGestureHandler <NSObject>
@optional
@property (copy) void (^panGestureHandler)(UIPanGestureRecognizer *pan);
@property (copy) void (^tapGestureHandler)(UITapGestureRecognizer *tap);

@end


@interface UIViewController (WBFlyClip)<WBFlyClipNodeProtocal,WBFlyClipNodeGestureHandler>




/**
 * 关键方法，放大
 */
-(void)WBFlyClip_zoomIn;
-(void)WBFlyClip_zoomInComplete:(void (^)())complete;

/**
 * 关键方法，缩小
 */
-(void)WBFlyClip_zoomOut;
-(void)WBFlyClip_zoomOutComplete:(void (^)())complete;

/**
 * 关键方法，移出
 */
-(void)WBFlyClip_flyOut;
-(void)WBFlyClip_flyOutComplete:(void (^)())complete;

/**
 * 关键方法，交换,使用id只支持替换一个小窗口，使用controller可以小换大，大换小
 */
-(void)WBFlyClip_switchWithNodeId:(NSString *)nodeId;
-(void)WBFlyClip_switchWithNodeId:(NSString *)nodeId complete:(void (^)())complete;
-(void)WBFlyClip_switchWithNodeController:(UIViewController<WBFlyClipNodeProtocal> *)nodeController;
-(void)WBFlyClip_switchWithNodeController:(UIViewController<WBFlyClipNodeProtocal> *)nodeController complete:(void (^)())complete;

//全局设置
//停靠margin
@property (class) CGFloat fc_margin;

//实例设置
//停靠margin
@property (nonatomic,assign) CGFloat fc_margin;


@property (nonatomic,copy) void(^fc_flyOutBlock)();

/**
 * 需要使用的返回方法
 */
-(void)WBFlyClip_back:(id)sender;

/**
 *  用来判断是否缩小
 */
-(BOOL)isZoomedIn;

#pragma mark - 找到所有小窗口
+ (NSArray *)WBFlyClip_ViewControlerIds;
+ (UIViewController<WBFlyClipNodeProtocal> *)WBFlyClip_ViewControllerForNodeId:(NSString *)nodeId;

#pragma mark - 找到当前viewcontroller
+ (UIViewController *)topViewController;
+ (UIViewController *)currentViewController;
+ (UIViewController *)currentViewControllerWithRootViewController:(UIViewController*)rootViewController;

@end


