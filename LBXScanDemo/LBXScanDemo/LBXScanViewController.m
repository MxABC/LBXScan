//
//
//  
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanViewController.h"
#import "LBXAlertAction.h"
#import "ScanResultViewController.h"
#import "Global.h"


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
    

    switch ([Global sharedManager].libraryType) {
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
    
    //不延时，可能会导致界面黑屏并卡住一会
    [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
}

//绘制扫描区域
- (void)drawScanView
{
    if (!_qRScanView)
    {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        
        self.qRScanView = [[LBXScanView alloc]initWithFrame:rect style:_style];
        
        [self.view addSubview:_qRScanView];
    }
    [_qRScanView startDeviceReadyingWithText:@"相机启动中"];
}

- (void)reStartDevice
{
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
        {
           [_scanObj startScan];
        }
            break;
        case SLT_ZXing:
        {
            [_zxingObj start];
        }
            break;
        case SLT_ZBar:
        {
            [_zbarObj start];
        }
            break;
        default:
            break;
    }
    
}

//启动设备
- (void)startScan
{
    if ( ![LBXScanPermissions cameraPemission] )
    {
        [_qRScanView stopDeviceReadying];
        
        [self showError:@"   请到设置隐私中开启本程序相机权限   "];
        return;
    }
    
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
    __weak __typeof(self) weakSelf = self;
    
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
        {
            if (!_scanObj )
            {
                CGRect cropRect = CGRectZero;
                
                if (_isOpenInterestRect) {
                    
                    //设置只识别框内区域
                    cropRect = [LBXScanView getScanRectWithPreView:self.view style:_style];
                }

                NSString *strCode = AVMetadataObjectTypeQRCode;
                if ([Global sharedManager].scanCodeType != SCT_BarCodeITF ) {
                    
                    strCode = [[Global sharedManager]nativeCodeType];
                }
                
                //AVMetadataObjectTypeITF14Code 扫码效果不行,另外只能输入一个码制，虽然接口是可以输入多个码制
                self.scanObj = [[LBXScanNative alloc]initWithPreView:videoView ObjectType:@[strCode] cropRect:cropRect success:^(NSArray<LBXScanResult *> *array) {
                    
                    [weakSelf scanResultWithArray:array];
                }];
                [_scanObj setNeedCaptureImage:_isNeedScanImage];
            }
            [_scanObj startScan];

        }
            break;
        case SLT_ZXing:
        {
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
        }
            break;
        case SLT_ZBar:
        {
            if (!_zbarObj) {
                
                self.zbarObj = [[LBXZBarWrapper alloc]initWithPreView:videoView barCodeType:ZBAR_I25 block:^(NSArray<LBXZbarResult *> *result) {
                    
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
        }
            break;
        default:
            break;
    }
    [_qRScanView stopDeviceReadying];
    
    [_qRScanView startScanAnimation];
    
    self.view.backgroundColor = [UIColor clearColor];
}




- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
        {
           [_scanObj stopScan];
        }
            break;
        case SLT_ZXing:
        {
            [_zxingObj stop];
        }
            break;
        case SLT_ZBar:
        {
            [_zbarObj stop];
        }
            break;
        default:
            break;
    }
    [_qRScanView stopScanAnimation];
}

#pragma mark -实现类继承该方法，作出对应处理

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    if (!array ||  array.count < 1)
    {
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
//    for (LBXScanResult *result in array) {
//        
//        NSLog(@"scanResult:%@",result.strScanned);
//    }
    
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    
    self.scanImage = scanResult.imgScanned;
    
    if (!strResult) {
        
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //震动提醒
    // [LBXScanWrapper systemVibrate];
    //声音提醒
    //[LBXScanWrapper systemSound];
    
    [self showNextVCWithScanResult:scanResult];
    
}

- (void)popAlertMsgWithScanResult:(NSString*)strResult
{
    if (!strResult) {
        
        strResult = @"识别失败";
    }
    
    __weak __typeof(self) weakSelf = self;
    [LBXAlertAction showAlertWithTitle:@"扫码内容" msg:strResult buttonsStatement:@[@"知道了"] chooseBlock:^(NSInteger buttonIdx) {
        
        [weakSelf reStartDevice];
    }];
}

- (void)showNextVCWithScanResult:(LBXScanResult*)strResult
{
    ScanResultViewController *vc = [ScanResultViewController new];
    vc.imgScan = strResult.imgScanned;
    
    vc.strScan = strResult.strScanned;
    
    vc.strCodeType = strResult.strBarCodeType;
    
    [self.navigationController pushViewController:vc animated:YES];
}


//开关闪光灯
- (void)openOrCloseFlash
{
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
        {
//             [_scanObj setTorch:!self.isOpenFlash];
            [_scanObj changeTorch];
        }
            break;
        case SLT_ZXing:
        {
            [_zxingObj openOrCloseTorch];
        }
            break;
        case SLT_ZBar:
        {
            
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
- (void)openLocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
   
    //部分机型有问题
//    picker.allowsEditing = YES;
    
    
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
    
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
        {
            if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
            {
                __weak __typeof(self) weakSelf = self;
                [LBXScanNative recognizeImage:image success:^(NSArray<LBXScanResult *> *array) {
                    [weakSelf scanResultWithArray:array];
                }];
            }
            else
            {
                [self showError:@"native低于ios8.0系统不支持识别图片条码"];
            }
        }
            break;
        case SLT_ZXing:
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
            break;
        case SLT_ZBar:
        {
            __weak __typeof(self) weakSelf = self;
            
            [LBXZBarWrapper recognizeImage:image block:^(NSArray<LBXZbarResult *> *result) {
                
                //测试，只使用扫码结果第一项
                LBXZbarResult *firstObj = result[0];
                
                LBXScanResult *scanResult = [[LBXScanResult alloc]init];
                scanResult.strScanned = firstObj.strScanned;
                scanResult.imgScanned = firstObj.imgScanned;
                scanResult.strBarCodeType = [LBXZBarWrapper convertFormat2String:firstObj.format];
                
                [weakSelf scanResultWithArray:@[scanResult]];

            }];
            
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

//子类继承必须实现的提示
- (void)showError:(NSString*)str
{
     [LBXAlertAction showAlertWithTitle:@"提示" msg:str buttonsStatement:@[@"知道了"] chooseBlock:nil];
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
