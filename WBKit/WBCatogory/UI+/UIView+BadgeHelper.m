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

@property (nonatomic, strong) UIColor            *wb_backgroundColor;
@property (nonatomic, strong) NSLayoutConstraint *wb_heightCT;
@property (nonatomic, strong) NSLayoutConstraint *wb_widthCT;

@end

@implementation WBBadgeView

- (instancetype)initWithHeight:(CGFloat)height color:(UIColor *)color
{
    self = [super init];
    if (self) {
        [self setBackgroundWithColor:color size:height];
    }
    return self;
}

- (void)reSetBackgroundWithColor:(UIColor *)color
{
    if (self.currentBackgroundImage) {
        [self setBackgroundWithColor:color size:self.currentBackgroundImage.size.height];
    }
}

- (void)setBackgroundWithColor:(UIColor *)color size:(CGFloat)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size, size);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:size] addClip];
    [image drawInRect:rect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2-1, image.size.width/2-1, image.size.height/2-1, image.size.width/2-1) resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setWb_backgroundColor:color];
}

- (void)showWithAnimation
{
    self.hidden = NO;
}

- (void)hideWithAnimation
{
    self.hidden = YES;
}

#pragma mark - setter &getter

- (NSLayoutConstraint *)wb_heightCT
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWb_heightCT:(NSLayoutConstraint *)wb_heightCT
{
    objc_setAssociatedObject(self, @selector(wb_heightCT), wb_heightCT, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)wb_widthCT
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWb_widthCT:(NSLayoutConstraint *)wb_widthCT
{
    objc_setAssociatedObject(self, @selector(wb_widthCT), wb_widthCT, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)wb_backgroundColor
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWb_backgroundColor:(UIColor *)wb_backgroundColor
{
    objc_setAssociatedObject(self, @selector(wb_backgroundColor), wb_backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface UIView ()

@property (nonatomic, strong) WBBadgeView *wb_badgeView;
@property (nonatomic        ) WBBadgePosition wb_badgePositon;

@property (nonatomic, strong) NSLayoutConstraint *badgeViewRightCt;
@property (nonatomic, strong) NSLayoutConstraint *badgeViewLeftCt;
@property (nonatomic, strong) NSLayoutConstraint *badgeViewTopCt;
@property (nonatomic, strong) NSLayoutConstraint *badgeViewBottomCt;

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
    if (self.wb_badgeView && position==self.wb_badgePositon) {
        return;
    } else if (self.wb_badgeView && position!=self.wb_badgePositon) {
        [self.wb_badgeView removeFromSuperview];
    }
    
    self.wb_badgePositon = position;
    CGFloat height = self.wb_badgeFontSize+2*self.wb_badgeInset;
    
    self.wb_badgeView = [[WBBadgeView alloc] initWithHeight:height color:color];
    [self.wb_badgeView setTitleColor:self.wb_badgeContentColor forState:UIControlStateNormal];
    self.wb_badgeView.titleLabel.font = font;
    [self.wb_badgeView setContentEdgeInsets:UIEdgeInsetsMake(self.wb_badgeInset/2, self.wb_badgeInset, self.wb_badgeInset/2, self.wb_badgeInset)];
    self.wb_badgeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.wb_badgeView.hidden = YES;
    self.clipsToBounds = NO;
    [self addSubview:self.wb_badgeView];
    
    self.wb_badgeView.wb_heightCT = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:height];
    [self.wb_badgeView addConstraint:self.wb_badgeView.wb_heightCT];
    self.wb_badgeView.wb_widthCT = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.wb_badgeView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.wb_badgeView addConstraint:self.wb_badgeView.wb_widthCT];
    
    switch (position) {
        case WBBadgePositionTopRight:
        {
            self.badgeViewRightCt = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.wb_borderInset];
            [self addConstraint:self.badgeViewRightCt];
            
            self.badgeViewTopCt = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.wb_borderInset];
            [self addConstraint:self.badgeViewTopCt];
            break;
        }
        case WBBadgePositionTopLeft:
        {
            self.badgeViewLeftCt = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.wb_borderInset];
            [self addConstraint:self.badgeViewLeftCt];
            
            self.badgeViewTopCt = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.wb_borderInset];
            [self addConstraint:self.badgeViewTopCt];
            break;
        }
        case WBBadgePositionBottomRight:
        {
            self.badgeViewRightCt = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.wb_borderInset];
            [self addConstraint:self.badgeViewRightCt];
            
            self.badgeViewBottomCt = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.wb_borderInset];
            [self addConstraint:self.badgeViewBottomCt];
            break;
        }
        case WBBadgePositionBottomLeft:
        {
            self.badgeViewLeftCt = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.wb_borderInset];
            [self addConstraint:self.badgeViewLeftCt];
            
            self.badgeViewBottomCt = [NSLayoutConstraint constraintWithItem:self.wb_badgeView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.wb_borderInset];
            [self addConstraint:self.badgeViewBottomCt];
            break;
        }
    }
}

- (void)wb_showBadgeWithContent:(NSString *)content animated:(BOOL)animated
{
    [self bringSubviewToFront:self.wb_badgeView]; 
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

- (WBBadgePosition)wb_badgePositon
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setWb_badgePositon:(WBBadgePosition)wb_badgePositon
{
    objc_setAssociatedObject(self, @selector(wb_badgePositon), @(wb_badgePositon), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)badgeViewTopCt
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeViewTopCt:(NSLayoutConstraint *)badgeViewTopCt
{
    objc_setAssociatedObject(self, @selector(badgeViewTopCt), badgeViewTopCt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)badgeViewLeftCt
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeViewLeftCt:(NSLayoutConstraint *)badgeViewLeftCt
{
    objc_setAssociatedObject(self, @selector(badgeViewLeftCt), badgeViewLeftCt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)badgeViewRightCt
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeViewRightCt:(NSLayoutConstraint *)badgeViewRightCt
{
    objc_setAssociatedObject(self, @selector(badgeViewRightCt), badgeViewRightCt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)badgeViewBottomCt
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeViewBottomCt:(NSLayoutConstraint *)badgeViewBottomCt
{
    objc_setAssociatedObject(self, @selector(badgeViewBottomCt), badgeViewBottomCt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

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
    if (self.wb_badgeView) {
        self.wb_badgeView.titleLabel.font = [UIFont systemFontOfSize:wb_badgeFontSize];
        CGFloat height = wb_badgeFontSize+2*self.wb_badgeInset;
        self.wb_badgeView.wb_heightCT.constant = height;
        [self.wb_badgeView setNeedsLayout];
        [self.wb_badgeView layoutIfNeeded];
        [self.wb_badgeView setBackgroundWithColor:self.wb_badgeView.wb_backgroundColor size:height];
    }
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
    if (self.wb_badgeView) {
        [self.wb_badgeView setContentEdgeInsets:UIEdgeInsetsMake(wb_badgeInset/2, wb_badgeInset, wb_badgeInset/2, wb_badgeInset)];
        CGFloat height = self.wb_badgeFontSize+2*wb_badgeInset;
        self.wb_badgeView.wb_heightCT.constant = height;
        [self.wb_badgeView setNeedsLayout];
        [self.wb_badgeView layoutIfNeeded];
        [self.wb_badgeView setBackgroundWithColor:self.wb_badgeView.wb_backgroundColor size:height];
    }
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
    if (self.wb_badgeView) {
        switch (self.wb_badgePositon) {
            case WBBadgePositionTopRight:
            {
                self.badgeViewRightCt.constant = -wb_borderInset;
                self.badgeViewTopCt.constant = wb_borderInset;
                break;
            }
            case WBBadgePositionTopLeft:
            {
                self.badgeViewLeftCt.constant = wb_borderInset;
                self.badgeViewTopCt.constant = wb_borderInset;
                break;
            }
            case WBBadgePositionBottomRight:
            {
                self.badgeViewRightCt.constant = -wb_borderInset;
                self.badgeViewBottomCt.constant = -wb_borderInset;
                break;
            }
            case WBBadgePositionBottomLeft:
            {
                self.badgeViewLeftCt.constant = wb_borderInset;
                self.badgeViewBottomCt.constant = -wb_borderInset;
                break;
            }
        }
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
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
    if (self.wb_badgeView) {
        [self.wb_badgeView reSetBackgroundWithColor:wb_badgeColor];
    }
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
    if (self.wb_badgeView) {
        [self.wb_badgeView setTitleColor:wb_badgeContentColor forState:UIControlStateNormal];
    }
    objc_setAssociatedObject(self, @selector(wb_badgeContentColor), wb_badgeContentColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
