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
    
    self.title = [NSString stringWithFormat:@"native 支持横竖屏切换 - %@",self.continuous ? @"连续扫码" : @"不连续扫码"];
    
    
    
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
    
    self.cameraPreView.frame = self.view.bounds;
    
    if (_scanObj) {
        [_scanObj setVideoLayerframe:self.cameraPreView.frame];
    }
    
    [self.qRScanView stopScanAnimation];
    
    [self.qRScanView startScanAnimation];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.firstLoad) {
        [self reStartDevice];
    }
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
    [self refreshLandScape];
    
    [self.qRScanView startDeviceReadyingWithText:self.cameraInvokeMsg];
    
    _scanObj.orientation = [self videoOrientation];
    [_scanObj startScan];
}

//启动设备
- (void)startScan
{
    if (!self.cameraPreView) {
        
        CGRect frame = self.view.bounds;
        
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
    
    //可动态修改
    _scanObj.orientation = [self videoOrientation];
    
    
    [self.qRScanView startDeviceReadyingWithText:self.cameraInvokeMsg];

    
#if TARGET_OS_SIMULATOR
    
#else
     [_scanObj startScan];
#endif
    
   
    
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


#pragma mark- 旋转
- (void)refreshLandScape
{
    if ([self isLandScape]) {
        
        self.style.centerUpOffset = 20;
        
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat max = MAX(w, h);
        
        CGFloat min = MIN(w, h);
        
        CGFloat scanRetangeH = min / 3;
        
        self.style.xScanRetangleOffset = max / 2 - scanRetangeH / 2;
    }
    else
    {
        self.style.centerUpOffset = 40;
        self.style.xScanRetangleOffset = 60;
    }
    
    self.qRScanView.viewStyle = self.style;
    [self.qRScanView setNeedsDisplay];
}


- (void)statusBarOrientationChanged:(NSNotification*)notification
{
    [self refreshLandScape];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (_scanObj) {
        _scanObj.orientation = [self videoOrientation];
    }
    
    [self.qRScanView stopScanAnimation];
    
    [self.qRScanView startScanAnimation];
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
