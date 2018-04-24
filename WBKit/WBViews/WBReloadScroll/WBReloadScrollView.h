//
//  WBReloadScrollView.h
//  testScrollTable
//
//  Created by wangbo on 15/10/24.
//  Copyright © 2015年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  WBReloadScrollViewDelegate <NSObject>

@optional

-(void)WBReloadScrollView:(UIScrollView *)scrollView DidScrollAtIndex:(NSInteger)index;
-(void)WBReloadScrollView:(UIScrollView *)scrollView DidEndScrollingAnimationAtIndex:(NSInteger)index;
-(void)WBReloadScrollView:(UIScrollView *)scrollView DidScroll:(CGPoint)contentOffset;
-(void)WBReloadScrollView:(UIScrollView *)scrollView DidSelectAtIndex:(NSInteger)index;

@end

@protocol  WBReloadScrollViewDataSource <NSObject>

-(UIView *)WBReloadScrollView:(UIScrollView *)scrollView ViewAtIndex:(NSInteger)index;
-(NSInteger)NumberOfCellInScrolllView:(UIScrollView *)scrollView;

@optional

@end


@interface WBReloadScrollView : UIScrollView<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic , strong) UIView *firstPage;
@property (nonatomic , strong) UIView *middlePage;
@property (nonatomic , strong) UIView *lastPage;
//设置自动滚动
@property (nonatomic , assign) BOOL running;
@property (nonatomic , assign) BOOL HasTimeRunner;
/**
 *  1.1修改了一个bug 在不能循环滚动的时候最后一屏幕前滚会多次进入，所以在加载的时候禁止第二次重加载
 */
@property (nonatomic , assign) BOOL isReloading;
@property (nonatomic , assign) int numberOfItemsInScroll;
//
//{
//    UIView *firstPage;
//    UIView *middlePage;
//    UIView *lastPage;
//
//    //设置自动滚动
//    BOOL running;
//    BOOL HasTimeRunner;
//
//    /**
//     *  1.1修改了一个bug 在不能循环滚动的时候最后一屏幕前滚会多次进入，所以在加载的时候禁止第二次重加载
//     */
//    BOOL isReloading;
//
//    int numberOfItemsInScroll;
//}

@property (nonatomic , assign) id<WBReloadScrollViewDelegate> WBReloadScrollDelegate;
@property (nonatomic , assign) id<WBReloadScrollViewDataSource> WBReloadScrollDataSource;

@property (nonatomic , assign) int currentIndex;

/*
 * @param function
*/
-(void)reloadData;
-(void)setScrollWithIndex:(int)index;


/*＊
 * @param 是否渐隐渐现
 * - 默认为yes
 */
@property (nonatomic , assign)BOOL fadeScroll;

/*＊
 * @param 循环滚动
 * - 默认为yes
 */
@property (nonatomic , assign)BOOL recirculate;

#pragma mark - pagecontrol

@property (nonatomic , assign)BOOL showPageControl;
@property (nonatomic , retain)UIPageControl *pageControl;
@property (nonatomic , retain)UIColor *pageControlCurrentIndexColor;

#pragma mark - timeRunner

@property (nonatomic , assign)NSInteger autoRunSeconds;

-(void)startAutoRun;
-(void)stopAutoRun;

@end
