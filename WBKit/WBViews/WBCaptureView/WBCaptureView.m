//
//  WBCaptureView.m
//  xuxian
//
//  Created by wangbo on 16/12/14.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "WBCaptureView.h"
#import <AVFoundation/AVFoundation.h>

@interface WBCaptureView ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureFileOutputRecordingDelegate>

//私有属性
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic) AVCaptureDevice *VideoDevice;
@property(nonatomic) AVCaptureDevice *audioDevice;
//输入输出
@property (nonatomic) AVCaptureDeviceInput *audioInput;
@property (nonatomic) AVCaptureDeviceInput *videoInput;
@property (nonatomic) AVCaptureStillImageOutput *imageOutPut;
@property (nonatomic) AVCaptureMovieFileOutput *movieOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

//是否允许旋转（注意在视频录制过程中禁止屏幕旋转）
@property (assign,nonatomic) BOOL enableRotation;
//后台任务标识
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;


//blcok用来反馈录像结果
@property (strong) void (^getVideoBlock)(AVCaptureFileOutput *captureOutput,NSURL *outputFileURL,NSArray *connections);
@property (strong) void (^errorBlock)(NSError *error);

@end

@implementation WBCaptureView

#pragma mark - 初始化

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        
        if ([self canUserCamear]) {
            [self initializeLayer];
        }
    }
    return self;
}

- (void)initializeLayer{
    
    if (!self.VideoDevice || !self.audioDevice) {
        NSLog(@"获取设备时出错.");
        return;
    }
    [self buildSession];
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.previewLayer];
    
}

- (void)buildSession{
    [self buildAudioInput];
    [self buildVideoInput];
    [self buildImageOutPut];
    [self buildMovieOutput];
}

- (void)buildAudioInput{
    NSError *error=nil;
    self.audioInput=[[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:&error];
    if (error) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if(status == AVAuthorizationStatusAuthorized) {
            // authorized
        } else if(status == AVAuthorizationStatusDenied){
            // denied
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无法访问麦克风", nil) message:NSLocalizedString(@"请到设置->隐私中开启本程序麦克风权限", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
            [alert show];
        } else if(status == AVAuthorizationStatusRestricted){
            // restricted
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无法访问麦克风",nil) message:NSLocalizedString(@"请到设置->通用->访问限制中开启麦克风权限",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil];
            [alert show];
        }
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
}

- (void)buildVideoInput{
    NSError *error=nil;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.VideoDevice error:&error];
    if (error) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if(status == AVAuthorizationStatusAuthorized) {
            // authorized
        } else if(status == AVAuthorizationStatusDenied){
            // denied
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无法访问摄像头",nil) message:NSLocalizedString(@"请到设置->隐私中开启本程序摄像头权限",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil];
            [alert show];
        } else if(status == AVAuthorizationStatusRestricted){
            // restricted
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无法访问摄像头",nil) message:NSLocalizedString(@"请到设置->通用->访问限制中开启摄像头权限",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil];
            [alert show];
        }
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
}

- (void)buildMovieOutput{
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    //这几句干啥的没搞明白，先写着
    AVCaptureConnection *captureConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
    self.movieOutput.movieFragmentInterval = kCMTimeInvalid;
    if ([captureConnection isVideoStabilizationSupported ]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    
    //将音频设备输出添加到会话中
    if ([self.session canAddOutput:self.movieOutput]) {
        [self.session addOutput:self.movieOutput];
    }
}

- (void)buildImageOutPut{
    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoWidthKey : @(CGRectGetWidth(self.bounds)),
                                     AVVideoHeightKey: @(CGRectGetWidth(self.bounds)),
                                     AVVideoCodecKey : AVVideoCodecJPEG};
    
    [self.imageOutPut setOutputSettings:outputSettings];
    //将图像设备输出添加到会话中
    if ([self.session canAddOutput:self.imageOutPut]) {
        [self.session addOutput:self.imageOutPut];
    }
    
}




#pragma mark - 对外暴露方法
///开始工作
- (void)startShowCapture{
    //开始启动
    [self.session startRunning];
}

- (void)setFrame:(CGRect)frame animated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = frame;;
        }];
    }else{
        self.frame = frame;
    }
    
}

-(void)setFlashMode:(AVCaptureFlashMode)mode{
    if ([_VideoDevice lockForConfiguration:nil]) {
        if ([_VideoDevice isFlashModeSupported:mode]) {
            [_VideoDevice setFlashMode:mode];
        }
        [_VideoDevice unlockForConfiguration];
    }
}

- (void)turnDevicePosition:(BOOL)isDeviceBack{
    [self turnCamera:isDeviceBack];
}

- (void)forcusAtPoint:(CGPoint)point{
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

- (void)takePhoto:(void (^)(UIImage *photo))getPhoto restartControl:(void (^)(void (^restart)()))restartControlBlock{
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"Take photo failed!");
        return;
    }
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        [self.session stopRunning];
        
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        getPhoto(image);
        
        restartControlBlock(^{
            [self startShowCapture];
        });
    }];
}

- (void)startTakingVideo{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        NSLog(@"Recording video failed!");
        return;
    }
    //根据连接取得设备输出的数据
    if (![self.movieOutput isRecording]) {
        //如果支持多任务则则开始多任务
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.previewLayer connection].videoOrientation;
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"Move_%f.mov",[[NSDate date] timeIntervalSince1970]]];
        NSURL *fileUrl=[NSURL fileURLWithPath:path];
        [self.movieOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        /**
         *  TO DELEGATE TO GET THE CALL BAKE
         */
    }else{
        NSLog(@"Is recording!");
    }
}

- (void)endTakingVideoWithCallback:(void (^)(AVCaptureFileOutput *, NSURL *, NSArray *))getVideoBlock Error:(void (^)(NSError *))errorBlock{
    _getVideoBlock = getVideoBlock;
    _errorBlock = errorBlock;
    [self.movieOutput stopRecording];
}


#pragma mark - movieOutputDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"Start recording...");
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    if (self.getVideoBlock) {
        self.getVideoBlock(captureOutput,outputFileURL,connections);
    }
    if (error && self.errorBlock) {
        self.errorBlock(error);
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}
- (BOOL)captureOutputShouldProvideSampleAccurateRecordingStart:(AVCaptureOutput *)captureOutput{
    return YES;
}

#pragma mark - 私有方法

//翻转摄像头
- (void)turnCamera:(BOOL)isDeviceBack{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        //        AVCaptureDevicePosition position = [[self.videoInput device] position];
        if (isDeviceBack){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.videoInput = newInput;
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"Toggle carema failed, error = %@", error);
        }
        
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

-(void)changeDeviceProperty:(void(^)(AVCaptureDevice *captureDevice))propertyChange{
    AVCaptureDevice *captureDevice= [self.videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

#pragma mark - 检测方法

///检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请在iPhone的“设置-隐私-相机”选项中，开启访问相机权限" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }else if (authStatus == AVAuthorizationStatusRestricted) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请在iPhone的“设置-通用-访问限制”选项中，开启相机权限" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 200;
        [alertView show];
        return NO;
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }else{
        }
    }else if (alertView.tag == 200){
    }
}

#pragma mark - lazyLoading

- (AVCaptureDevice *)VideoDevice{
    //使用默认摄像头进行视频设输入备初始化
    if (!_VideoDevice) {
        _VideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([_VideoDevice lockForConfiguration:nil]) {
            if ([_VideoDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [_VideoDevice setFlashMode:AVCaptureFlashModeOff];
            }
            //自动白平衡
            if ([_VideoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [_VideoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            [_VideoDevice unlockForConfiguration];
        }
    }
    return _VideoDevice;
}

- (AVCaptureDevice *)audioDevice{
    //初始化一个音频输入设备
    if (!_audioDevice) {
        _audioDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    }
    return _audioDevice;
}

- (AVCaptureSession *)session{
    //生成会话，用来结合输入输出
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        }else if ([_session canSetSessionPreset:AVCaptureSessionPresetMedium]){
            _session.sessionPreset = AVCaptureSessionPresetMedium;
        }else if ([_session canSetSessionPreset:AVCaptureSessionPresetLow]){
            _session.sessionPreset = AVCaptureSessionPresetLow;
        }else{
            NSLog(@"Cannot set session preset!");
        }
    }
    return _session;
}

@end
