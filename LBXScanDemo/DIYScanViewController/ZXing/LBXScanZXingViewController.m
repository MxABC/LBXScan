//
//
//  
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanZXingViewController.h"
#import <ZXResultPoint.h>
//#import <ZXQRCodeFinderPattern.h>
@interface LBXScanZXingViewController ()
@end

@implementation LBXScanZXingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.title = @"ZXing";
    
    self.isNeedScanImage = NO;
    
    [self drawScanView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.qRScanView startDeviceReadyingWithText:self.cameraInvokeMsg];


    [self requestCameraPemissionWithResult:^(BOOL granted) {

        if (granted) {
            
            [self startScan];

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
    
    [_zxingObj start];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.cameraPreView.frame = self.view.bounds;
    self.qRScanView.frame = self.view.bounds;
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
    if (!_zxingObj) {
        
        self.zxingObj = [[ZXingWrapper alloc]initWithPreView:self.cameraPreView success:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg, NSArray *resultPoints) {
            [weakSelf handZXingResult:barcodeFormat barStr:str scanImg:scanImg resultPoints:resultPoints];
        }];
        
        if (self.isOpenInterestRect) {
            
            //设置只识别框内区域
            CGRect cropRect = [LBXScanView getZXingScanRectWithPreView:self.cameraPreView style:self.style];
            
            [_zxingObj setScanRect:cropRect];
        }
    }
    _zxingObj.continuous = self.continuous;
    [_zxingObj start];
    
    _zxingObj.onStarted = ^{
        
        [weakSelf.qRScanView stopDeviceReadying];
        [weakSelf.qRScanView startScanAnimation];
    };

    self.view.backgroundColor = [UIColor clearColor];
}

- (void)handZXingResult:(ZXBarcodeFormat)barcodeFormat barStr:(NSString*)str scanImg:(UIImage*)scanImg resultPoints:(NSArray*)resultPoints
{
    LBXScanResult *result = [[LBXScanResult alloc]init];
    result.strScanned = str;
    result.imgScanned = scanImg;
    result.strBarCodeType = [self convertZXBarcodeFormat:barcodeFormat];
    
    NSLog(@"ZXing pts:%@",resultPoints);
    
    if (self.cameraPreView && resultPoints && scanImg) {
        
        CGFloat minx = 100000;
        CGFloat miny= 100000;
        CGFloat maxx = 0;
        CGFloat maxy= 0;
        
        for (ZXResultPoint *pt in resultPoints) {
            
            if (pt.x < minx) {
                minx = pt.x;
            }
            if (pt.x > maxx) {
                maxx = pt.x;
            }
            
            if (pt.y < miny) {
                miny = pt.y;
            }
            if (pt.y > maxy) {
                maxy = pt.y;
            }
        }
        
//        CGFloat width = maxx - minx;
//        CGFloat height = maxy - miny;
        
        CGSize imgSize = scanImg.size;
        CGSize preViewSize = self.cameraPreView.frame.size;
        minx = minx / imgSize.width * preViewSize.width;
        maxx = maxx / imgSize.width * preViewSize.width;
        miny = miny / imgSize.height * preViewSize.height;
        maxy = maxy / imgSize.height * preViewSize.height;
        
        result.bounds = CGRectMake(minx, miny,  maxx - minx,maxy - miny);
        
        NSLog(@"bounds:%@",NSStringFromCGRect(result.bounds));
        
        [self scanResultWithArray:@[result]];
    }
    else
    {
        [self scanResultWithArray:@[result]];
    }
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
    [_zxingObj stop];
}


//开关闪光灯
- (void)openOrCloseFlash
{
    [_zxingObj openOrCloseTorch];

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



//当选择一张图片后进入这里

//继承者实现
- (void)recognizeImageWithImage:(UIImage*)image
{
    __weak __typeof(self) weakSelf = self;
    
    [ZXingWrapper recognizeImage:image block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
        
        LBXScanResult *result = [[LBXScanResult alloc]init];
        result.strScanned = str;
        result.imgScanned = image;
        result.strBarCodeType = [self convertZXBarcodeFormat:barcodeFormat];
        
        [weakSelf scanResultWithArray:@[result]];
    }];
}



- (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat
{
    NSString *strAVMetadataObjectType = nil;
    
    switch (barCodeFormat) {
        case kBarcodeFormatQRCode:
            strAVMetadataObjectType = AVMetadataObjectTypeQRCode;
            break;
        case kBarcodeFormatEan13:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN13Code;
            break;
        case kBarcodeFormatEan8:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN8Code;
            break;
        case kBarcodeFormatPDF417:
            strAVMetadataObjectType = AVMetadataObjectTypePDF417Code;
            break;
        case kBarcodeFormatAztec:
            strAVMetadataObjectType = AVMetadataObjectTypeAztecCode;
            break;
        case kBarcodeFormatCode39:
            strAVMetadataObjectType = AVMetadataObjectTypeCode39Code;
            break;
        case kBarcodeFormatCode93:
            strAVMetadataObjectType = AVMetadataObjectTypeCode93Code;
            break;
        case kBarcodeFormatCode128:
            strAVMetadataObjectType = AVMetadataObjectTypeCode128Code;
            break;
        case kBarcodeFormatDataMatrix:
            strAVMetadataObjectType = AVMetadataObjectTypeDataMatrixCode;
            break;
        case kBarcodeFormatITF:
            strAVMetadataObjectType = AVMetadataObjectTypeITF14Code;
            break;
        case kBarcodeFormatRSS14:
            break;
        case kBarcodeFormatRSSExpanded:
            break;
        case kBarcodeFormatUPCA:
            break;
        case kBarcodeFormatUPCE:
            strAVMetadataObjectType = AVMetadataObjectTypeUPCECode;
            break;
        default:
            break;
    }
    
    return strAVMetadataObjectType;
}





@end
