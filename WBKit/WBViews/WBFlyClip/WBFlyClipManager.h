//
//  WBFlyClipManager.h
//
//  Created by wangbo on 16/12/2.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewController+WBFlyClip.h"


#ifndef ScreenWidth
#define ScreenWidth                [UIScreen mainScreen].bounds.size.width
#endif

#ifndef ScreenHeight
#define ScreenHeight               [UIScreen mainScreen].bounds.size.height
#endif


//@class WBFlyClipNode;

@interface WBFlyClipManager : NSObject

@property(nonatomic , strong)NSMutableArray<UIViewController<WBFlyClipNodeProtocal> *> *managedControllerNodes;//这里Array中装的是在app中活跃的小窗口对象
@property(nonatomic , assign)CGFloat springDamping;

+ (WBFlyClipManager *) sharedManager;//单例方法

/**
 *  @brief 缩小当前显示的viewcontroller
 */
-(void)zoomInViewController:(UIViewController<WBFlyClipNodeProtocal> *)viewController;
-(void)zoomInViewController:(UIViewController<WBFlyClipNodeProtocal> *)viewController complete:(void (^)(void))complete;

/**
 *  @brief 根据一个vc的id放大一个缩小的vc并将其返回
 */
-(UIViewController *)zoomOutViewControllerWithID:(NSString *)vcid;
-(UIViewController *)zoomOutViewControllerWithID:(NSString *)vcid complete:(void (^)(void))complete;

/**
 *  @brief 根据一个vc的id移除一个缩小的vc
 */
-(void)flyOutViewControllerWithID:(NSString *)vcid;
-(void)flyOutViewControllerWithID:(NSString *)vcid complete:(void (^)(void))complete;

/**
 *  @brief 置换两个viewController
 */
-(void)switchViewController:(UIViewController<WBFlyClipNodeProtocal> *)viewController withNodeControllerId:(NSString *)nodeId;
-(void)switchViewController:(UIViewController<WBFlyClipNodeProtocal> *)viewController withNodeControllerId:(NSString *)nodeId complete:(void (^)(void))complete;

#pragma mark - 数据方法

///返回nodeids数组
-(NSArray *)nodeIds;

///根据id获取一个viewcontrollerNode
-(UIViewController<WBFlyClipNodeProtocal> *)NodeControllerWithID:(NSString *)vcid;

///下一个缩小的vc的位置
-(CGRect)blankRectForNextZoomInViewController;



@end


