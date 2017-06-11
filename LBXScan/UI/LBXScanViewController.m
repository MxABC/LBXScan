//
//
//  
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface LBXScanViewController ()
@end

@implementation LBXScanViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    

    switch (_libraryType) {
        case SLT_Native:
            self.title = @"native";
            break;
        case SLT_ZXing:
            self.title = @"ZXing";
            break;
        case SLT_ZBar:
            self.title = @"ZBar";
            break;
        default:
            break;
    }
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
            
#ifdef LBXScan_Define_UI
            [_qRScanView stopDeviceReadying];
#endif
            
            [self showError:@"   请到设置隐私中开启本程序相机权限   "];
        }
    }];
    
   
}

//绘制扫描区域
- (void)drawScanView
{
#ifdef LBXScan_Define_UI
    
    if (!_qRScanView)
    {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        
        self.qRScanView = [[LBXScanView alloc]initWithFrame:rect style:_style];
        
        [self.view addSubview:_qRScanView];
    }
    [_qRScanView startDeviceReadyingWithText:_cameraInvokeMsg];
#endif
}

- (void)reStartDevice
{
    switch (_libraryType) {
        case SLT_Native:
        {
#ifdef LBXScan_Define_Native
            [_scanObj startScan];
#endif
        }
            break;
        case SLT_ZXing:
        {
#ifdef LBXScan_Define_ZXing
            [_zxingObj start];
#endif
        }
            break;
        case SLT_ZBar:
        {
#ifdef LBXScan_Define_ZBar
            [_zbarObj start];
#endif
        }
            break;
        default:
            break;
    }
    
}

//启动设备
- (void)startScan
{
//    if ( ![LBXScanPermissions cameraPemission] )
//    {
//        [_qRScanView stopDeviceReadying];
//        
//        [self showError:@"   请到设置隐私中开启本程序相机权限   "];
//        return;
//    }
    
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
    __weak __typeof(self) weakSelf = self;
    
    switch (_libraryType) {
        case SLT_Native:
        {

            
#ifdef LBXScan_Define_Native
            
            if (!_scanObj )
            {
                CGRect cropRect = CGRectZero;
                
                if (_isOpenInterestRect) {
                    
                    //设置只识别框内区域
                    cropRect = [LBXScanView getScanRectWithPreView:self.view style:_style];
                }

                NSString *strCode = AVMetadataObjectTypeQRCode;
                if (_scanCodeType != SCT_BarCodeITF ) {
                    
                    strCode = [self nativeCodeWithType:_scanCodeType];
                }
                
                //AVMetadataObjectTypeITF14Code 扫码效果不行,另外只能输入一个码制，虽然接口是可以输入多个码制
                self.scanObj = [[LBXScanNative alloc]initWithPreView:videoView ObjectType:@[strCode] cropRect:cropRect success:^(NSArray<LBXScanResult *> *array) {
                    
                    [weakSelf scanResultWithArray:array];
                }];
                [_scanObj setNeedCaptureImage:_isNeedScanImage];
            }
            [_scanObj startScan];
#endif

        }
            break;
        case SLT_ZXing:
        {

#ifdef LBXScan_Define_ZXing
            if (!_zxingObj) {
                
                self.zxingObj = [[ZXingWrapper alloc]initWithPreView:videoView block:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg) {
                    
                    LBXScanResult *result = [[LBXScanResult alloc]init];
                    result.strScanned = str;
                    result.imgScanned = scanImg;
                    result.strBarCodeType = [self convertZXBarcodeFormat:barcodeFormat];
                    
                    [weakSelf scanResultWithArray:@[result]];
                    
                }];
                
                if (_isOpenInterestRect) {
                    
                    //设置只识别框内区域
                    CGRect cropRect = [LBXScanView getZXingScanRectWithPreView:videoView style:_style];
                                        
                     [_zxingObj setScanRect:cropRect];
                }               
            }
            [_zxingObj start];
#endif
        }
            break;
        case SLT_ZBar:
        {
#ifdef LBXScan_Define_ZBar
            if (!_zbarObj) {
                
                self.zbarObj = [[LBXZBarWrapper alloc]initWithPreView:videoView barCodeType:[self zbarTypeWithScanType:_scanCodeType] block:^(NSArray<LBXZbarResult *> *result) {
                    
                    //测试，只使用扫码结果第一项
                    LBXZbarResult *firstObj = result[0];
                    
                    LBXScanResult *scanResult = [[LBXScanResult alloc]init];
                    scanResult.strScanned = firstObj.strScanned;
                    scanResult.imgScanned = firstObj.imgScanned;
                    scanResult.strBarCodeType = [LBXZBarWrapper convertFormat2String:firstObj.format];
                    
                    [weakSelf scanResultWithArray:@[scanResult]];
                }];
            }
            [_zbarObj start];
#endif
        }
            break;
        default:
            break;
    }
    
#ifdef LBXScan_Define_UI
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
#endif
    
    self.view.backgroundColor = [UIColor clearColor];
}

#ifdef LBXScan_Define_ZBar
- (zbar_symbol_type_t)zbarTypeWithScanType:(SCANCODETYPE)type
{
    //test only ZBAR_I25 effective,why
    return ZBAR_I25;
    
//    switch (type) {
//        case SCT_QRCode:
//            return ZBAR_QRCODE;
//            break;
//        case SCT_BarCode93:
//            return ZBAR_CODE93;
//            break;
//        case SCT_BarCode128:
//            return ZBAR_CODE128;
//            break;
//        case SCT_BarEAN13:
//            return ZBAR_EAN13;
//            break;
//            
//        default:
//            break;
//    }
//    
//    return (zbar_symbol_type_t)type;
}
#endif

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
 
    [self stopScan];
    
#ifdef LBXScan_Define_UI
    [_qRScanView stopScanAnimation];
#endif
}

- (void)stopScan
{
    switch (_libraryType) {
        case SLT_Native:
        {
#ifdef LBXScan_Define_Native
            [_scanObj stopScan];
#endif
        }
            break;
        case SLT_ZXing:
        {
#ifdef LBXScan_Define_ZXing
            [_zxingObj stop];
#endif
        }
            break;
        case SLT_ZBar:
        {
#ifdef LBXScan_Define_ZBar
            [_zbarObj stop];
#endif
        }
            break;
        default:
            break;
    }

}

#pragma mark -扫码结果处理

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    //设置了委托的处理
    if (_delegate) {
        [_delegate scanResultWithArray:array];
    }
    
    //也可以通过继承LBXScanViewController，重写本方法即可
}



//开关闪光灯
- (void)openOrCloseFlash
{
    
    switch (_libraryType) {
        case SLT_Native:
        {
#ifdef LBXScan_Define_Native
            [_scanObj changeTorch];
#endif
        }
            break;
        case SLT_ZXing:
        {
#ifdef LBXScan_Define_ZXing
            [_zxingObj openOrCloseTorch];
#endif
        }
            break;
        case SLT_ZBar:
        {
#ifdef LBXScan_Define_ZBar
            [_zbarObj openOrCloseFlash];
#endif
        }
            break;
        default:
            break;
    }
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

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];    
    
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    __weak __typeof(self) weakSelf = self;
        
    switch (_libraryType) {
        case SLT_Native:
        {
#ifdef LBXScan_Define_Native
            if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
            {
                [LBXScanNative recognizeImage:image success:^(NSArray<LBXScanResult *> *array) {
                    [weakSelf scanResultWithArray:array];
                }];
            }
            else
            {
                [self showError:@"native低于ios8.0系统不支持识别图片条码"];
            }
#endif
        }
            break;
        case SLT_ZXing:
        {
#ifdef LBXScan_Define_ZXing
            
            [ZXingWrapper recognizeImage:image block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
                
                LBXScanResult *result = [[LBXScanResult alloc]init];
                result.strScanned = str;
                result.imgScanned = image;
                result.strBarCodeType = [self convertZXBarcodeFormat:barcodeFormat];
                
                [weakSelf scanResultWithArray:@[result]];
            }];
#endif
            
        }
            break;
        case SLT_ZBar:
        {
#ifdef LBXScan_Define_ZBar
            [LBXZBarWrapper recognizeImage:image block:^(NSArray<LBXZbarResult *> *result) {
                
                //测试，只使用扫码结果第一项
                LBXZbarResult *firstObj = result[0];
                
                LBXScanResult *scanResult = [[LBXScanResult alloc]init];
                scanResult.strScanned = firstObj.strScanned;
                scanResult.imgScanned = firstObj.imgScanned;
                scanResult.strBarCodeType = [LBXZBarWrapper convertFormat2String:firstObj.format];
                
                [weakSelf scanResultWithArray:@[scanResult]];
                
            }];
#endif
            
        }
            break;
            
        default:
            break;
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#ifdef LBXScan_Define_ZXing
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
#endif


- (NSString*)nativeCodeWithType:(SCANCODETYPE)type
{
    switch (type) {
        case SCT_QRCode:
            return AVMetadataObjectTypeQRCode;
            break;
        case SCT_BarCode93:
            return AVMetadataObjectTypeCode93Code;
            break;
        case SCT_BarCode128:
            return AVMetadataObjectTypeCode128Code;
            break;
        case SCT_BarCodeITF:
            return @"ITF条码:only ZXing支持";
            break;
        case SCT_BarEAN13:
            return AVMetadataObjectTypeEAN13Code;
            break;

        default:
            return AVMetadataObjectTypeQRCode;
            break;
    }
}

- (void)showError:(NSString*)str
{
    
}

- (void)requestCameraPemissionWithResult:(void(^)( BOOL granted))completion
{
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                completion(YES);
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                completion(NO);
                break;
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (granted) {
                                                     completion(true);
                                                 } else {
                                                     completion(false);
                                                 }
                                             });
                                             
                                         }];
            }
                break;
                
        }
    }
    
    
}

+ (BOOL)photoPermission
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        
        if ( author == ALAuthorizationStatusDenied ) {
            
            return NO;
        }
        return YES;
    }
    
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if ( authorStatus == PHAuthorizationStatusDenied ) {
        
        return NO;
    }
    return YES;
}



@end
