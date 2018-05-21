//
//  WBModelView.m
//  WBKitDemo
//
//  Created by Uknow on 2018/4/18.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "WBModelView.h"
@interface WBModelView ()

@property (nonatomic, strong) NSMutableArray *listArray;

@property (nonatomic, strong) NSMutableArray *labelArray;

@property (nonatomic, strong) UIScrollView *modelView;

@end

@implementation WBModelView

- (NSMutableArray *)listArray{
    
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}
- (NSMutableArray *)labelArray{
    
    if (!_labelArray) {
        _labelArray = [NSMutableArray array];
    }
    return _labelArray;
}
+(WBModelView *)show{
    WBModelView *modelView = [[WBModelView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    modelView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.4];
    [[UIApplication sharedApplication].keyWindow addSubview:modelView];
    return modelView;
}
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {

        UIScrollView *modelView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 300)];
        [UIView animateWithDuration:0.25 animations:^{
            modelView.frame = CGRectMake(0, kScreenHeight - 300, kScreenWidth, 300);
        }];
        self.modelView = modelView;
        modelView.backgroundColor = [UIColor redColor];
        [self addSubview:modelView];
        
    }
    return self;
}
- (void)addWithString:(NSString *)string{
    
    [self.listArray addObject:string];
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.tag = self.listArray.count;
    textLabel.font = [UIFont systemFontOfSize:20];
    textLabel.textColor = [UIColor blackColor];
    [self.labelArray addObject:textLabel];
    [self.modelView addSubview:textLabel];
    [self.modelView setContentSize:CGSizeMake(kScreenWidth, self.listArray.count*44)];
    if (self.modelView.contentSize.height > 300) {
        [self.modelView setContentOffset:CGPointMake(0, self.modelView.contentSize.height - self.modelView.frame.size.height) animated:YES];
    }
    
    [self update];

    
}
- (void)update{
    
    UILabel *textLabel = self.labelArray[self.listArray.count-1];
    textLabel.frame = CGRectMake(10, (self.listArray.count-1)*44, self.modelView.frame.size.width - 10, 44);
    textLabel.text = self.listArray[self.listArray.count-1];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.modelView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 290);
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
