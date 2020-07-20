//
//
//  
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanZXingViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ScanResultViewController.h"

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
            [_qRScanView stopDeviceReadying];
        }
    }];
   
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
    
    if (!_cameraInvokeMsg) {
        
//        _cameraInvokeMsg = NSLocalizedString(@"wating...", nil);
    }
    
    [_qRScanView startDeviceReadyingWithText:_cameraInvokeMsg];

}

- (void)reStartDevice
{

    [_zxingObj start];
    
}

//启动设备
- (void)startScan
{
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
        
    if (!_zxingObj) {
        
        __weak __typeof(self) weakSelf = self;
        self.zxingObj = [[ZXingWrapper alloc]initWithPreView:videoView block:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg) {
            
            LBXScanResult *result = [[LBXScanResult alloc]init];
            result.strScanned = str;
            result.imgScanned = scanImg;
            result.strBarCodeType = [weakSelf convertZXBarcodeFormat:barcodeFormat];
            
            [weakSelf scanResultWithArray:@[result]];
            
        }];
        
        if (_isOpenInterestRect) {
            
            //设置只识别框内区域
            CGRect cropRect = [LBXScanView getZXingScanRectWithPreView:videoView style:_style];
            
            [_zxingObj setScanRect:cropRect];
        }
    }
    [_zxingObj start];


    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];

    
    self.view.backgroundColor = [UIColor clearColor];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
 
    [self stopScan];
    

    [_qRScanView stopScanAnimation];

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


#pragma mark- 识别结果
- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    if (!array ||  array.count < 1)
    {
        
        NSLog(@"识别失败.....");
        NSLog(@"识别失败.....");
        NSLog(@"识别失败.....");
        
        [self reStartDevice];
        
        return;
    }
    
    //经测试，可以ZXing同时识别2个二维码，不能同时识别二维码和条形码
    //    for (LBXScanResult *result in array) {
    //
    //        NSLog(@"scanResult:%@",result.strScanned);
    //    }
    
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    
    self.scanImage = scanResult.imgScanned;
    
    if (!strResult) {
        
        return;
    }
    
    //TODO: 这里可以根据需要添加震动或播放成功提醒音等提示相关代码
    //...
    
    [self showNextVCWithScanResult:scanResult];
}


- (void)showNextVCWithScanResult:(LBXScanResult*)strResult
{
    ScanResultViewController *vc = [ScanResultViewController new];
    vc.imgScan = strResult.imgScanned;
    
    vc.strScan = strResult.strScanned;
    
    vc.strCodeType = strResult.strBarCodeType;
    
    [self.navigationController pushViewController:vc animated:YES];
}


//当选择一张图片后进入这里

#pragma mark- 相册
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];    
    
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    __weak __typeof(self) weakSelf = self;
        
    [ZXingWrapper recognizeImage:image block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
        
        LBXScanResult *result = [[LBXScanResult alloc]init];
        result.strScanned = str;
        result.imgScanned = image;
        result.strBarCodeType = [self convertZXBarcodeFormat:barcodeFormat];
        
        [weakSelf scanResultWithArray:@[result]];
    }];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if (@available(iOS 8.0, *)) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status) {
            case PHAuthorizationStatusAuthorized:
            {
                if (completion) {
                    completion(YES,NO);
                }
            }
                break;
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
            {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
            case PHAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(status == PHAuthorizationStatusAuthorized,YES);
                        });
                    }
                }];
            }
                break;
            default:
            {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
        }
        
    }else{
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        switch (status) {
            case ALAuthorizationStatusAuthorized:
            {
                if (completion) {
                    completion(YES, NO);
                }
            }
                break;
            case ALAuthorizationStatusNotDetermined:
            {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                
                [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                       usingBlock:^(ALAssetsGroup *assetGroup, BOOL *stop) {
                                           if (*stop) {
                                               if (completion) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(YES, NO);
                                                   });
                                                   
                                               }
                                           } else {
                                               *stop = YES;
                                           }
                                       }
                                     failureBlock:^(NSError *error) {
                                         if (completion) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(NO, YES);
                                             });
                                         }
                                     }];
            } break;
            case ALAuthorizationStatusRestricted:
            case ALAuthorizationStatusDenied:
            {
                if (completion) {
                    completion(NO, NO);
                }
            }
                break;
        }
    }
  
}





@end
