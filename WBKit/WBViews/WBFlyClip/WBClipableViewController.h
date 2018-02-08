//
//  WBClipableViewController.h
//  FlyClip
//
//  Created by wangbo on 16/12/30.
//  Copyright © 2016年 tongboshu. All rights reserved.
//

#import "WBFlyClipProtocolHeaders.h"

@class WBClipableViewController;
@protocol WBClipableViewControllerDelegate <NSObject>

@optional

- (void)WBClipableViewControllerDidZoomIn:(WBClipableViewController *)clipViewController rect:(CGRect)rect;
- (void)WBClipableViewControllerDidZoomOut:(WBClipableViewController *)clipViewController;
- (void)WBClipableViewControllerWillDisappear:(WBClipableViewController *)clipViewController;

@end


@interface WBClipableViewController : UIViewController<WBFlyClipNodeGestureHandler>

/**
 *  delegate
 */
@property (nonatomic , weak) id<WBClipableViewControllerDelegate> delegate;

/**
 *  public属性
 */
///enable的属性默认值均是YES
@property (nonatomic , assign) BOOL   enableClip;
@property (nonatomic , assign) BOOL   enableClipGestureOut;
@property (nonatomic , assign) BOOL   enableClipGestureRemove;
///缩小的时候使用的frame,有默认值，可以设置
@property (nonatomic , assign) CGRect clipFrame;
@property (nonatomic , strong) NSString *clipId;

@property (nonatomic , assign) BOOL   isDidAppear;

/**
 * public方法
 */
-(void)zoomIn;
-(void)zoomOut;
-(void)zoomAway;
-(void)switchWithClipViewController:(WBClipableViewController *)clipController;

///获取全部的小窗口页面id
+(NSArray<NSString *> *)clipIds;
///根据id获取controller
+(UIViewController *)getClipedControllerWithId:(NSString *)clipId;

@end
