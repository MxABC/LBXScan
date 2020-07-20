//
//
//  
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanNativeViewController.h"



@interface LBXScanNativeViewController ()
@property (nonatomic, strong) UIView *videoView;
@end

@implementation LBXScanNativeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.title = @"native";

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self drawScanView];
    
    [self requestCameraPemissionWithResult:^(BOOL granted) {

        if (granted) {

            //不延时，可能会导致界面黑屏并卡住一会
            [self performSelector:@selector(startScan) withObject:nil afterDelay:0.3];

        }else{

            [self.qRScanView stopDeviceReadying];
        }
    }];
   
}

//绘制扫描区域
- (void)drawScanView
{
    
    if (!self.qRScanView)
    {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        
        self.qRScanView = [[LBXScanView alloc]initWithFrame:rect style:self.style];
        
        [self.view addSubview:self.qRScanView];
    }
    
    if (!self.cameraInvokeMsg) {
        
//        _cameraInvokeMsg = NSLocalizedString(@"wating...", nil);
    }
    
    [self.qRScanView startDeviceReadyingWithText:self.cameraInvokeMsg];
}

- (void)reStartDevice
{
    [_scanObj startScan];
}

//启动设备
- (void)startScan
{
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
    __weak __typeof(self) weakSelf = self;
    
    self.videoView = videoView;
    
    
    if (!_scanObj )
    {
        CGRect cropRect = CGRectZero;
        
        if (self.isOpenInterestRect) {
            
            //设置只识别框内区域
            cropRect = [LBXScanView getScanRectWithPreView:self.view style:self.style];
        }
        
        //                AVMetadataObjectTypeITF14Code 扫码效果不行,另外只能输入一个码制，虽然接口是可以输入多个码制
        self.scanObj = [[LBXScanNative alloc]initWithPreView:videoView ObjectType:self.listScanTypes cropRect:cropRect videoMaxScale:^(CGFloat maxScale) {
            
            [weakSelf setVideoMaxScale:maxScale];
        }  success:^(NSArray<LBXScanResult *> *array) {
            
            [weakSelf scanResultWithArray:array];
        }];
        [_scanObj setNeedCaptureImage:self.isNeedScanImage];
    }
    [_scanObj startScan];
    
    
    [self.qRScanView stopDeviceReadying];
    [self.qRScanView startScanAnimation];

    self.view.backgroundColor = [UIColor clearColor];
}

- (void)setVideoMaxScale:(CGFloat)maxScale
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
 
    [self stopScan];
    

    [self.qRScanView stopScanAnimation];

}

- (void)stopScan
{
    [_scanObj stopScan];
}

//开关闪光灯
- (void)openOrCloseFlash
{
    [_scanObj changeTorch];
    
    
    self.isOpenFlash =!self.isOpenFlash;
}


#pragma mark --打开相册并识别图片

/*!
 *  打开本地照片，选择图片识别
 */
- (void)openLocalPhoto:(BOOL)allowsEditing
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
   
    //部分机型有问题
    picker.allowsEditing = allowsEditing;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}



- (void)recognizeImageWithImage:(UIImage*)image
{
    __weak __typeof(self) weakSelf = self;
    
    if (@available(iOS 8.0, *)) {
        [LBXScanNative recognizeImage:image success:^(NSArray<LBXScanResult *> *array) {
            [weakSelf scanResultWithArray:array];
        }];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
//    if (_videoView) {
//        _videoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
//    }
}


@end
