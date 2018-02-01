//
//  UIView+BadgeHelper.m
//  WBKit
//
//  Created by wangbo on 2018/2/1.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UIView+BadgeHelper.h"
#import <objc/runtime.h>

@interface WBBadgeView : UIButton
@end

@implementation WBBadgeView

- (instancetype)initWithHeight:(CGFloat)height color:(UIColor *)color
{
    self = [super init];
    if (self) {
        CGRect rect = CGRectMake(0.0f, 0.0f, height, height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:height] addClip];
        [image drawInRect:rect];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2-1, image.size.width/2-1, image.size.height/2-1, image.size.width/2-1) resizingMode:UIImageResizingModeStretch];
        [self setBackgroundImage:image forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)showWithAnimation
{
    self.hidden = NO;
}

- (void)hideWithAnimation
{
    self.hidden = YES;
}

@end

@interface UIView ()

@property (nonatomic, strong) WBBadgeView *wb_badgeView;

@end


@implementation UIView (BadgeHelper)

- (void)wb_addBadgeDot
{
    [self wb_addBadgeAtPosition:WBBadgePositionTopRight];
}

- (void)wb_addBadgeAtPosition:(WBBadgePosition)position
{
    [self wb_addBadgeAtPosition:position font:[UIFont systemFontOfSize:self.wb_badgeFontSize] color:self.wb_badgeColor];
}


- (void)wb_addBadgeAtPosition:(WBBadgePosition)position font:(UIFont *)font color:(UIColor *)color
{
    // 不允许多次添加
    if (self.wb_badgeView) {
        return;
    }
    
    CGFloat height = self.wb_badgeFontSize+2*self.wb_badgeInset;
    
    self.wb_badgeView = [[WBBadgeView alloc] initWithHeight:height color:color];
    [self.wb_badgeView setTitleColor:self.wb_badgeContentColor forState:UIControlStateNormal];
    self.wb_badgeView.titleLabel.font = font;
    [self.wb_badgeView setContentEdgeInsets:UIEdgeInsetsMake(self.wb_badgeInset/2, self.wb_badgeInset, self.wb_badgeInset/2, self.wb_badgeInset)];
    self.wb_badgeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.wb_badgeView.hidden = YES;
    self.clipsToBounds = NO;
    [self addSubview:self.wb_badgeView];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:height];
    [self.wb_badgeView addConstraint:heightConstraint];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.wb_badgeView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.wb_badgeView addConstraint:widthConstraint];
    
    switch (position) {
        case WBBadgePositionTopRight:
        {
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.wb_borderInset];
            [self addConstraint:rightConstraint];
            
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.wb_borderInset];
            [self addConstraint:topConstraint];
            break;
        }
        case WBBadgePositionTopLeft:
        {
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.wb_borderInset];
            [self addConstraint:leftConstraint];
            
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.wb_borderInset];
            [self addConstraint:topConstraint];
            break;
        }
        case WBBadgePositionBottomRight:
        {
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.wb_borderInset];
            [self addConstraint:rightConstraint];
            
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.wb_borderInset];
            [self addConstraint:bottomConstraint];
            break;
        }
        case WBBadgePositionBottomLeft:
        {
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.wb_borderInset];
            [self addConstraint:leftConstraint];
            
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.wb_borderInset];
            [self addConstraint:bottomConstraint];
            break;
        }
    }
}

- (void)wb_showBadgeWithContent:(NSString *)content animated:(BOOL)animated
{
    [self.wb_badgeView setTitle:content forState:UIControlStateNormal];
    if (animated) {
        [self.wb_badgeView showWithAnimation];
    } else {
        self.wb_badgeView.hidden = NO;
    }
}

- (void)wb_hideBadgeAnimated:(BOOL)animated
{
    if (animated) {
        [self.wb_badgeView hideWithAnimation];
    } else {
        self.wb_badgeView.hidden = YES;
    }
    
}

#pragma mark - getters and setters


- (WBBadgeView *)wb_badgeView
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWb_badgeView:(WBBadgeView *)wb_badgeView
{
    objc_setAssociatedObject(self, @selector(wb_badgeView), wb_badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)wb_badgeFontSize
{
    CGFloat fontSize = 0;
    id fontSizeValue = objc_getAssociatedObject(self, _cmd);
    if (!fontSizeValue) {
        fontSize = 10;
        [self setWb_badgeFontSize:fontSize];
    } else {
        fontSize = [fontSizeValue floatValue];
    }
    return fontSize;
}

- (void)setWb_badgeFontSize:(CGFloat)wb_badgeFontSize
{
    objc_setAssociatedObject(self, @selector(wb_badgeFontSize), @(wb_badgeFontSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)wb_badgeInset
{
    CGFloat badgeInset = 0;
    id badgeInsetValue = objc_getAssociatedObject(self, _cmd);
    if (!badgeInsetValue) {
        badgeInset = 3;
        [self setWb_badgeInset:badgeInset];
    } else {
        badgeInset = [badgeInsetValue floatValue];
    }
    return badgeInset;
}

- (void)setWb_badgeInset:(CGFloat)wb_badgeInset
{
    objc_setAssociatedObject(self, @selector(wb_badgeInset), @(wb_badgeInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)wb_borderInset
{
    CGFloat borderInset = 0;
    id borderInsetValue = objc_getAssociatedObject(self, _cmd);
    if (!borderInsetValue) {
        borderInset = 15;
        [self setWb_borderInset:borderInset];
    } else {
        borderInset = [borderInsetValue floatValue];
    }
    return borderInset;
}

- (void)setWb_borderInset:(CGFloat)wb_borderInset
{
    objc_setAssociatedObject(self, @selector(wb_borderInset), @(wb_borderInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)wb_badgeColor
{
    UIColor *badgeColor = objc_getAssociatedObject(self, _cmd);
    if (!badgeColor) {
        badgeColor = [UIColor redColor];
        [self setWb_badgeColor:badgeColor];
    }
    return badgeColor;
}

- (void)setWb_badgeColor:(UIColor *)wb_badgeColor
{
    objc_setAssociatedObject(self, @selector(wb_badgeColor), wb_badgeColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)wb_badgeContentColor
{
    UIColor *contentColor = objc_getAssociatedObject(self, _cmd);
    if (!contentColor) {
        contentColor = [UIColor whiteColor];
        [self setWb_badgeContentColor:contentColor];
    }
    return contentColor;
}

- (void)setWb_badgeContentColor:(UIColor *)wb_badgeContentColor
{
    objc_setAssociatedObject(self, @selector(wb_badgeContentColor), wb_badgeContentColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
