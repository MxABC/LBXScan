//
//  LBXScanWrapper.m
//
//
//  Created by lbxia on 15/3/4.
//  Copyright (c) 2015年 lbxia. All rights reserved.
//

#import "LBXScanWrapper.h"
#import "LBXScanNative.h"
#import "ZXingWrapper.h"
#import "ZXBarcodeFormat.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface LBXScanWrapper()
{
    
}

//ios7之后native封装
@property(nonatomic,strong)LBXScanNative* scanNativeObj;

//ZXing封装
@property(nonatomic,strong)ZXingWrapper *scanZXingObj;

/**
 @brief  扫码类型
 */
@property(nonatomic,strong)NSArray* arrayBarCodeType;

//是否指定使用ZXing库
@property(nonatomic,assign)BOOL isUseZXingLib;



@end


@implementation LBXScanWrapper


- (BOOL)isSysIos7Later
{
    //return NO;
    
     if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
         return YES;
    return NO;
}

- (BOOL)isSysIos8Later
{
    // return NO;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        return YES;
    return NO;
}

- (instancetype)initWithPreView:(UIView*)preView ArrayObjectType:(NSArray*)arrayBarCodeType
              success:(void(^)(NSArray<LBXScanResult*> *array))blockScanResult
{
    if (self = [super init])
    {
        self.isUseZXingLib = NO;
        
        self.arrayBarCodeType = arrayBarCodeType;
        
        
        CGRect frame = preView.frame;
        frame.origin = CGPointZero;
       
        if ( [self isSysIos7Later] )
        {
            _scanNativeObj = [[LBXScanNative alloc]initWithPreView:preView ObjectType:arrayBarCodeType success:^(NSArray<LBXScanResult*> *array) {
                
                if (blockScanResult)
                {
                    blockScanResult(array);
                }
            }];
            [_scanNativeObj setNeedCaptureImage:YES];
        }
        else
        {
            _scanZXingObj = [[ZXingWrapper alloc]initWithPreView:preView block:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg) {
                
                //TODO:ZXing统一识别所有的码
                if ( blockScanResult )
                {
                    NSString *barCodeType = [LBXScanWrapper convertZXBarcodeFormat:barcodeFormat];
                    
                    LBXScanResult *result = [[LBXScanResult alloc]initWithScanString:str imgScan:scanImg barCodeType:barCodeType];
                    
                    blockScanResult(@[result]);
                }
            }];

        }

    }
    
    return self;
}

- (void)setScanRect:(CGRect)scanRect
{
    if ([self isSysIos7Later]) {
        
        [_scanNativeObj setScanRect:scanRect];
    }
    else
    {
        [_scanZXingObj setScanRect:scanRect];
    }
    
}

/**
 @brief  初始化相机，并指定使用ZXing库识别各种码
 @param preView         视频显示View
 @param blockScanResult 返回结果
 @return LBXScanVendor
 */
- (instancetype)initZXingWithPreView:(UIView *)preView success:(void(^)(NSArray<LBXScanResult*> *array))blockScanResult
{
    if (self = [super init])
    {
        self.isUseZXingLib = YES;
        
        _scanZXingObj = [[ZXingWrapper alloc]initWithPreView:preView block:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg) {
            
            NSString *barCodeType = [LBXScanWrapper convertZXBarcodeFormat:barcodeFormat];
            
            if (blockScanResult) {
                blockScanResult(@[str,scanImg,barCodeType]);
            }            
        }];
    }
    
    return self;
}



/*!
 *  开始扫码
 */
- (void)startScan
{
    
    if ( [self isSysIos7Later] && !_isUseZXingLib )
        [_scanNativeObj startScan];
    else
        [_scanZXingObj start];
}

/*!
 *  停止扫码
 */
- (void)stopScan
{
    if ( [self isSysIos7Later] && !_isUseZXingLib )
        [_scanNativeObj stopScan];
    else
        [_scanZXingObj stop];    
}

- (void)openFlash:(BOOL)bOpen
{
    if ([self isSysIos7Later] && !_isUseZXingLib )
        [_scanNativeObj setTorch:bOpen];
    else
        [_scanZXingObj openTorch:bOpen];
}

- (void)openOrCloseFlash
{
    if ([self isSysIos7Later] && !_isUseZXingLib )
        [_scanNativeObj changeTorch];
    else
        [_scanZXingObj openOrCloseTorch];
}

/*!
 *  修改扫码类型
 *
 *  @param objType 扫码类型
 */
- (void)changeScanObjType:(NSArray*)objType
{
    if ( [self isSysIos7Later] && !_isUseZXingLib )
    {
        [_scanNativeObj changeScanType:objType];
    }
}



/*!
 *  生成二维码
 *
 *  @param str  二维码字符串
 *  @param size 二维码图片大小
 *
 *  @return 返回生成的图像
 */
+ (UIImage*)createQRWithString:(NSString*)str size:(CGSize)size
{
    return  [ZXingWrapper createUIImageWithString:str size:size];
}



/**
 @brief  图像中间加logo图片
 @param srcImg    原图像
 @param LogoImage logo图像
 @param logoSize  logo图像尺寸
 @return 加Logo的图像
 */
+ (UIImage*)addImageLogo:(UIImage*)srcImg centerLogoImage:(UIImage*)LogoImage logoSize:(CGSize)logoSize
{
    UIGraphicsBeginImageContext(srcImg.size);
    [srcImg drawInRect:CGRectMake(0, 0, srcImg.size.width, srcImg.size.height)];
    
    CGRect rect = CGRectMake(srcImg.size.width/2 - logoSize.width/2, srcImg.size.height/2-logoSize.height/2, logoSize.width, logoSize.height);
    [LogoImage drawInRect:rect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}



//识别图片上的二维码

/*!
 *  识别各种码图片
 *
 *  @param image 图像
 *  @param block 返回识别结果
 */
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<LBXScanResult*> *array))block;
{    
    __block UIImage* tmpImg = image;
    
    [ZXingWrapper recognizeImage:image block:^(ZXBarcodeFormat barCodeFormat,NSString* str)
     {
         NSString *barCodeType = [LBXScanWrapper convertZXBarcodeFormat:barCodeFormat];
         
         if (block) {
             
             LBXScanResult *result = [[LBXScanResult alloc]initWithScanString:str imgScan:tmpImg barCodeType:barCodeType];
             block(@[result]);
         }
         
     }];
}







#pragma mark- 震动、声音效果

#define SOUNDID  1109  //1012 -iphone   1152 ipad  1109 ipad
+ (void)systemVibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)systemSound
{
    AudioServicesPlaySystemSound(SOUNDID);
}


#pragma mark -相机、相册权限
+ (BOOL)isGetCameraPermission
{
    BOOL isCameraValid = YES;
    //ios7之前系统默认拥有权限
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (authStatus == AVAuthorizationStatusDenied)
        {
            isCameraValid = NO;
        }
    }
    return isCameraValid;
}


+ (BOOL)isGetPhotoPermission
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


+ (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat
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
