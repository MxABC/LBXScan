//
//
//  
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanNativeViewController.h"



@interface LBXScanNativeViewController ()
//@property (nonatomic, strong) UIView *videoView;
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
    
    [self drawScanView];
    
    [self requestCameraPemissionWithResult:^(BOOL granted) {
        
        if (granted) {
            
            [self startScan];
        }
    }];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.frame;
    rect.origin = CGPointMake(0, 0);
    
    self.qRScanView.frame = rect;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [self reStartDevice];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopScan];

    [self.qRScanView stopScanAnimation];

}



//绘制扫描区域
- (void)drawScanView
{
    if (!self.qRScanView)
    {
        
        self.qRScanView = [[LBXScanView alloc]initWithFrame:self.view.bounds style:self.style];
        
        [self.view insertSubview:self.qRScanView atIndex:1];
    }
    
    if (!self.cameraInvokeMsg) {
        
        self.cameraInvokeMsg = NSLocalizedString(@"wating...", nil);
    }
}

- (void)reStartDevice
{
    
    [self.qRScanView startDeviceReadyingWithText:self.cameraInvokeMsg];
    [_scanObj startScan];
}

//启动设备
- (void)startScan
{
    if (!self.cameraPreView) {
        
        CGRect frame = self.view.bounds;
        
        frame.size.width = 0;
        frame.size.height = 0;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        
        if (  !(fabs(frame.size.width - width) <= 64 || fabs(frame.size.height - height) <= 64 ) ) {
            
            frame.size.width = width;
            frame.size.height = height - 20;
            
            if (self.navigationController && !self.navigationController.navigationBarHidden ) {
                
                frame.size.height -= 44;
            }
        }
        
        UIView *videoView = [[UIView alloc]initWithFrame:frame];
        videoView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:videoView atIndex:0];
        
        self.cameraPreView = videoView;
    }
    
    __weak __typeof(self) weakSelf = self;

    if (!_scanObj )
    {
        CGRect cropRect = CGRectZero;
        
        if (self.isOpenInterestRect) {
            
            //设置只识别框内区域
            cropRect = [LBXScanView getScanRectWithPreView:self.view style:self.style];
        }
        

        self.scanObj = [[LBXScanNative alloc]initWithPreView:self.cameraPreView ObjectType:self.listScanTypes cropRect:cropRect videoMaxScale:^(CGFloat maxScale) {
            [weakSelf setVideoMaxScale:maxScale];
            
        }  success:^(NSArray<LBXScanResult *> *array) {
            
            [weakSelf handScanNative:array];
        }];
        [_scanObj setNeedCaptureImage:self.isNeedScanImage];
        //是否需要返回条码坐标
        _scanObj.needCodePosion = YES;
        _scanObj.continuous = self.continuous;
    }
    
    
    _scanObj.onStarted = ^{
        
        [weakSelf.qRScanView stopDeviceReadying];
        [weakSelf.qRScanView startScanAnimation];
    };
    
    [_scanObj startScan];

    self.view.backgroundColor = [UIColor clearColor];
}

- (void)handScanNative:(NSArray<LBXScanResult *> *)array
{
    [self scanResultWithArray:array];
}

- (void)setVideoMaxScale:(CGFloat)maxScale
{
    
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




@end
