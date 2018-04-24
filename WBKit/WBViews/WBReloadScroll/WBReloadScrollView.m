//
//  WBReloadScrollView.m
//  testScrollTable
//
//  Created by wangbo on 15/10/24.
//  Copyright © 2015年 wangbo. All rights reserved.
//

#import "WBReloadScrollView.h"

@implementation WBReloadScrollView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        _currentIndex = 0;
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setDelegate:self];
        [self setContentSize:CGSizeMake(self.frame.size.width*3, self.frame.size.height)];
        
//        [self.panGestureRecognizer setDelegate:self];
        [self setScrollsToTop:NO];
        [self setBounces:NO];
        
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+frame.size.height-30, frame.size.width, 30)];
        [self.pageControl setUserInteractionEnabled:NO];
        
        //autorunseconds设置
        self.autoRunSeconds = 5;
        
        //fadescroll默认设置为yes
        self.fadeScroll = YES;
        //recirculate默认设置为yes
        self.recirculate = YES;
    }
    return self;
}


/**
 *6.1中重写setframe方法
 *用来实现重新布局所有子view的frame
 */

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setContentSize:CGSizeMake(self.contentSize.width, self.frame.size.height)];
}

-(void)reloadData{
    if (self.isReloading) {
        return;
    }
    self.isReloading = YES;
    
    self.numberOfItemsInScroll = (int)[self.WBReloadScrollDataSource NumberOfCellInScrolllView:self];
    
    if (self.numberOfItemsInScroll<=1) {//只有1页
        self.firstPage = nil;
        if ([self checkPageUsable:self.currentIndex]) {
            self.middlePage = [self.WBReloadScrollDataSource WBReloadScrollView:self ViewAtIndex:_currentIndex];
        }else{
           self.middlePage = nil;
        }
        self.lastPage = nil;
        [self layoutViews];
    }else{
        if ([self checkPageUsable:_currentIndex-1]) {//如果前一页可用
            self.firstPage = [self.WBReloadScrollDataSource WBReloadScrollView:self ViewAtIndex:_currentIndex-1];
        }else{//如果前一页不可用
            if (self.recirculate) {//循环滚动
                self.firstPage = [self.WBReloadScrollDataSource WBReloadScrollView:self ViewAtIndex:[self.WBReloadScrollDataSource NumberOfCellInScrolllView:self]-1];
            }else{//不可循环滚动
                self.firstPage = nil;
            }
        }
        
        if ([self checkPageUsable:_currentIndex]) {//当前页可用
            self.middlePage = [self.WBReloadScrollDataSource WBReloadScrollView:self ViewAtIndex:self.currentIndex];
        }
        
        if ([self checkPageUsable:_currentIndex+1]) {//后一页可用
            self.lastPage = [self.WBReloadScrollDataSource WBReloadScrollView:self ViewAtIndex:_currentIndex+1];
        }else{//后一页不可用
            if (_recirculate) {//循环滚动
                self.lastPage = [self.WBReloadScrollDataSource WBReloadScrollView:self ViewAtIndex:0];
            }else{
                self.lastPage = nil;
            }
        }
        
        [self layoutViews];
    }
}

-(void)layoutViews{
    
    if (_recirculate) {
        [self.firstPage setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.middlePage setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        [self.lastPage setFrame:CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height)];
    }else{
        if (!self.firstPage) {
            [self.middlePage setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [self.lastPage setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        }else if (!self.lastPage){
            [self.firstPage setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [self.middlePage setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        }else{
            [self.firstPage setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [self.middlePage setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
            [self.lastPage setFrame:CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height)];
        }
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (_fadeScroll) {
        CATransition *transition = [CATransition animation];
        transition.duration = .25;
        transition.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:nil];
    }
    
    
    if (self.firstPage) {
        [self addSubview:self.firstPage];
//        [firstPage setUserInteractionEnabled:YES];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//        [firstPage addGestureRecognizer:tap];
    }
    if (self.middlePage) {
        [self addSubview:self.middlePage];
//        [middlePage setUserInteractionEnabled:YES];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//        [middlePage addGestureRecognizer:tap];
    }
    
    if (self.lastPage) {
        [self addSubview:self.lastPage];
//        [lastPage setUserInteractionEnabled:YES];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//        [lastPage addGestureRecognizer:tap];
    }
    
    //仅在实现点击回调事件的时候添加手势，防止手势冲突
    if ([self.WBReloadScrollDelegate respondsToSelector:@selector(WBReloadScrollView:DidSelectAtIndex:)]) {
        if (self.firstPage) {
            [self.firstPage setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [self.firstPage addGestureRecognizer:tap];
        }
        if (self.middlePage) {
            [self.middlePage setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [self.middlePage addGestureRecognizer:tap];
        }
        
        if (self.lastPage) {
            [self.lastPage setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [self.lastPage addGestureRecognizer:tap];
        }
    }
    
    
    if (_recirculate) {
        [self setContentSize:CGSizeMake(self.frame.size.width*3, self.frame.size.height)];
        [self setContentOffset:CGPointMake(self.frame.size.width, 0)];
    }else{
        if (!self.firstPage) {
            [self setContentSize:CGSizeMake(self.frame.size.width*2, self.frame.size.height)];
            if (!self.lastPage) {//只有一页
                [self setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
            }
            [self setContentOffset:CGPointMake(0, 0)];
        }else if (!self.lastPage){
            [self setContentSize:CGSizeMake(self.frame.size.width*2, self.frame.size.height)];
            [self setContentOffset:CGPointMake(self.frame.size.width, 0)];
        }else{
            [self setContentSize:CGSizeMake(self.frame.size.width*3, self.frame.size.height)];
            [self setContentOffset:CGPointMake(self.frame.size.width, 0)];
        }
    }
    
    
//    NSLog(@"contentx = %f,contenty = %f",self.contentOffset.x,self.contentOffset.y);
    
    //pagecontrolSettings
    
    if (self.showPageControl) {
        if (![self.pageControl superview] && self.superview) {
            [self.superview addSubview:self.pageControl];
        }
        [self.pageControl setHidden:NO];
        
        if ([self.WBReloadScrollDataSource respondsToSelector:@selector(NumberOfCellInScrolllView:)]) {
            NSInteger pageNum = [self.WBReloadScrollDataSource NumberOfCellInScrolllView:self];
            if (pageNum>1) {
              [self.pageControl setNumberOfPages:pageNum];  
            }
            
        }else{
            [self.pageControl setNumberOfPages:0];
        }

        if (self.pageControlCurrentIndexColor) {
            [self.pageControl setCurrentPageIndicatorTintColor:self.pageControlCurrentIndexColor];
        }
        [self.pageControl setCurrentPage:self.currentIndex];
    }else{
        [self.pageControl setHidden:YES];
    }
    
    /**
     * layout 结束后reloading完成
     */
    self.isReloading = NO;
}

-(void)setScrollWithIndex:(int)index{
    
    if (index>_currentIndex) {
        CATransition *transition = [CATransition animation];
        transition.duration = .25;
        transition.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.20 :0.03 :0.13 :1.00];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        [self.layer addAnimation:transition forKey:nil];
        _currentIndex = index;
        [self reloadData];
    }else if (index<_currentIndex){
        CATransition *transition = [CATransition animation];
        transition.duration = .25;
        transition.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.20 :0.03 :0.13 :1.00];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [self.layer addAnimation:transition forKey:nil];
        _currentIndex = index;
        [self reloadData];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.WBReloadScrollDelegate respondsToSelector:@selector(WBReloadScrollView:DidEndScrollingAnimationAtIndex:)]) {
            [self.WBReloadScrollDelegate WBReloadScrollView:self DidEndScrollingAnimationAtIndex:self.currentIndex];
        }
    });
    
}

-(BOOL)checkPageUsable:(int)page{
    return page>=0 && page<[self.WBReloadScrollDataSource NumberOfCellInScrolllView:self];
}


#pragma mark - delegateFunc

-(void)tap:(id)sender{
    UIGestureRecognizer *gr = sender;
    if ([self.WBReloadScrollDelegate respondsToSelector:@selector(WBReloadScrollView:DidSelectAtIndex:)]) {
        if ([gr.view isEqual:self.firstPage]) {
            [self.WBReloadScrollDelegate WBReloadScrollView:self DidSelectAtIndex:_currentIndex-1];
        }else if ([gr.view isEqual:self.middlePage]){
            [self.WBReloadScrollDelegate WBReloadScrollView:self DidSelectAtIndex:_currentIndex];
        }else if ([gr.view isEqual:self.lastPage]){
            [self.WBReloadScrollDelegate WBReloadScrollView:self DidSelectAtIndex:_currentIndex+1];
        }

    }
}



#pragma mark - ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float x = scrollView.contentOffset.x;
    
//    NSLog(@"x = %f",x);
    
    if (x<=0) {
        if (_currentIndex>0) {
            if (self.isReloading) {//这里的代码是因为在非循环的情况下最后一页向前滑动的时候在reloading的情况下会两次进入这里，原因是在layout方法中setcontentsize在前，在contentoffset在后。而这俩方法貌似不会阻塞滑动线程，所以这里两次进入了导致出错！！
                return;
            }
            _currentIndex--;
            [self reloadData];
        }else{
            if (_recirculate) {
                _currentIndex = (int)[self.WBReloadScrollDataSource NumberOfCellInScrolllView:self]-1;
                [self reloadData];
            }else{
                _currentIndex = 0;
            }
        }
        
    }else if (x>=self.frame.size.width*2 || (scrollView.contentSize.width==self.frame.size.width*2 && x>=self.frame.size.width)){
        if (_currentIndex<[self.WBReloadScrollDataSource NumberOfCellInScrolllView:self]-1) {
            _currentIndex++;
            [self reloadData];
        }else{
            if (_recirculate) {
                _currentIndex = 0;
                [self reloadData];
            }else{
                _currentIndex = (int)[self.WBReloadScrollDataSource NumberOfCellInScrolllView:self]-1;
            }
            
        }
        
    }
    
    
    //WBScrollDidscrollDelegate
    if ([self.WBReloadScrollDelegate respondsToSelector:@selector(WBReloadScrollView:DidScroll:)]) {
        if (_recirculate) {//循环滚动
            [self.WBReloadScrollDelegate WBReloadScrollView:self DidScroll:CGPointMake((_currentIndex-1)*scrollView.frame.size.width+scrollView.contentOffset.x, scrollView.contentOffset.y)];
        }else{
            if (_currentIndex==0) {//如果不是循环滚动，第一屏不用减去上一页宽度
                [self.WBReloadScrollDelegate WBReloadScrollView:self DidScroll:CGPointMake(_currentIndex*scrollView.frame.size.width+scrollView.contentOffset.x, scrollView.contentOffset.y)];
            }else{
                [self.WBReloadScrollDelegate WBReloadScrollView:self DidScroll:CGPointMake((_currentIndex-1)*scrollView.frame.size.width+scrollView.contentOffset.x, scrollView.contentOffset.y)];
            }
        }
    }

    
//    if ([self.panGestureRecognizer locationInView:self].x>0 && ![self.layer containsPoint:[self.panGestureRecognizer locationInView:self]]) {//手势超出scrollview范围
//        NSLog(@"需要取消手势");
//    }
    
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    /**
     *  6.1 wangbo 为了解决滑动滚动的多处部分 添加以下代码计算多处部分并重新滑动回弹
     */
    int exX = (int)scrollView.contentOffset.x%(int)scrollView.frame.size.width;
    if (exX!=0) {
        int xToChange;
        if (exX<(int)scrollView.frame.size.width/2) {//右边多
            xToChange = exX;
        }else{//左边多
            xToChange = exX-scrollView.frame.size.width;
        }
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x - xToChange, scrollView.contentOffset.y) animated:YES];
        return;
    }
    
    if ([self.WBReloadScrollDelegate respondsToSelector:@selector(WBReloadScrollView:DidScrollAtIndex:)]) {
        [self.WBReloadScrollDelegate WBReloadScrollView:self DidScrollAtIndex:_currentIndex];
    }
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([self.WBReloadScrollDelegate respondsToSelector:@selector(WBReloadScrollView:DidEndScrollingAnimationAtIndex:)]) {
        [self.WBReloadScrollDelegate WBReloadScrollView:self DidEndScrollingAnimationAtIndex:_currentIndex];
    }
}

#pragma mark - 自动滚动设置

-(void)startAutoRun{
    self.running = YES;
    
    if (self.HasTimeRunner) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (true) {
            self.HasTimeRunner = YES;
            [NSThread sleepForTimeInterval:self.autoRunSeconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                @try {
                    if ([self.WBReloadScrollDataSource respondsToSelector:@selector(NumberOfCellInScrolllView:)]) {
                        if (!self.isDragging && !self.isDecelerating && [self.WBReloadScrollDataSource NumberOfCellInScrolllView:self]>1) {
                            
                            CATransition *transition = [CATransition animation];
                            transition.duration = .25;
                            transition.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                            transition.type = kCATransitionFade;
                            
                            [self.layer addAnimation:transition forKey:nil];
                            [self setContentOffset:CGPointMake(self.frame.size.width*2, 0) animated:NO];
                        }
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"%s\n%@", __FUNCTION__, exception);
                }
                @finally {

                }
                
            });
            if (!self.running) {
                self.HasTimeRunner = NO;
                break;
            }
        }
        
    });

}
-(void)stopAutoRun{
    self.running = NO;
}


#pragma mark - 重写事件
-(void)removeFromSuperview{
    [super removeFromSuperview];
    self.running = NO;
    _WBReloadScrollDelegate = nil;
    _WBReloadScrollDataSource = nil;
}

#pragma mark - touch事件是否接收重写

//-(BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view{
//    UITouch *touch = [[touches allObjects] firstObject];
//    if ([self.layer containsPoint:[touch locationInView:self]]) {
//        return YES;
//    }
//    return NO;
//}

//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    if ([self.layer containsPoint:[gestureRecognizer locationInView:self]]) {
//        return YES;
//    }
//    return NO;
//}

//- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
//    
//    
//    return YES;
//}

//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    UITouch *touch = [[touches allObjects] firstObject];
//    if ([self.layer containsPoint:[touch locationInView:self]]) {
//        return;
//    }
////    [touch ];
//}


@end
