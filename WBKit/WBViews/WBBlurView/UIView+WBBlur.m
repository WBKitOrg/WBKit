//
//  UIView+WBBlur.m
//  WBUtilDemoProject
//
//  Created by wangbo on 16/10/13.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "UIView+WBBlur.h"
#import "FXBlurView.h"

@implementation UIView (WBBlur)

+(instancetype)blurViewWithAlpha:(float)alpha frame:(CGRect)frame{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        UIView *view = [[UIView alloc] initWithFrame:frame];
        if (view) {
            //  创建需要的毛玻璃特效类型
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            //  毛玻璃view 视图
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            //添加到要有毛玻璃特效的控件中
            effectView.frame = view.bounds;
            [view addSubview:effectView];
            //设置模糊透明度
            effectView.alpha = alpha;
        }
        return view;
    }else{
        FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:frame];
        [blurView setBackgroundColor:[UIColor whiteColor]];
        [blurView setTintColor:[UIColor clearColor]];
        [blurView setDynamic:YES];
        [blurView setBlurRadius:alpha*50];
        return blurView;
    }
}

@end
