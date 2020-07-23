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
    
    self.isNeedScanImage = YES;
  
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
    [_zxingObj start];
}

//启动设备
- (void)startScan
{
    if (!self.cameraPreView) {
        UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
          videoView.backgroundColor = [UIColor clearColor];
          [self.view insertSubview:videoView atIndex:0];
          
          self.cameraPreView = videoView;
    }
        
    if (!_zxingObj) {
        
        __weak __typeof(self) weakSelf = self;

        self.zxingObj = [[ZXingWrapper alloc]initWithPreView:self.cameraPreView success:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg, NSArray *resultPoints) {
            [weakSelf handZXingResult:barcodeFormat barStr:str scanImg:scanImg resultPoints:resultPoints];
        }];
        
        if (self.isOpenInterestRect) {
            
            //设置只识别框内区域
            CGRect cropRect = [LBXScanView getZXingScanRectWithPreView:self.cameraPreView style:self.style];
            
            [_zxingObj setScanRect:cropRect];
        }
    }
    [_zxingObj start];


    [self.qRScanView stopDeviceReadying];
    [self.qRScanView startScanAnimation];

    
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
