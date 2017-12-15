//
//  WBCaptureView.h
//  xuxian
//
//  Created by wangbo on 16/12/14.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WBCaptureView : UIView

//使用方法
/**
 *  @brief 开始显示
 */
- (void)startShowCapture;

/**
 *  @brief 设置闪光灯
 *  @param mode 闪光灯模式
 */
- (void)setFlashMode:(AVCaptureFlashMode)mode;

/**
 *  @brief 选择摄像头
 *  @param isDeviceBack 是否是后置摄像头
 */
- (void)turnDevicePosition:(BOOL)isDeviceBack;

/**
 *  @brief 选择焦点
 *  @param point 焦点
 */
- (void)forcusAtPoint:(CGPoint)point;

/**
 *  @brief 改变frame
 *  @param frame 位置大小
 *  @param animated 是否动画
 */
- (void)setFrame:(CGRect)frame animated:(BOOL)animated;

/**
 *  @brief 照相
 *  @param getPhoto 得到相片的callBack
 *  @param restartControlBlock 恢复显示控制器
 */
- (void)takePhoto:(void (^)(UIImage *photo))getPhoto restartControl:(void (^)(void (^restart)()))restartControlBlock;

/**
 *  @brief 摄像开始
 */
- (void)startTakingVideo;

- (void)turnCamera:(BOOL)isDeviceBack;

/**
 *  @brief 摄像结束
 *  @param getVideoBlock 得到视频的callBack
 *  @param errorBlock 错误callBack
 */
- (void)endTakingVideoWithCallback:(void (^)(AVCaptureFileOutput *captureOutput,NSURL *outputFileURL,NSArray *connections))getVideoBlock Error:(void (^)(NSError *error))errorBlock;


@end
