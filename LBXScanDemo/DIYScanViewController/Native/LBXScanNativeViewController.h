//
//  QQStyleQRScanViewController.h
//
//  github:https://github.com/MxABC/LBXScan
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LBXScanBaseViewController.h"


@interface LBXScanNativeViewController : LBXScanBaseViewController



#pragma mark -----  扫码使用的库对象 -------

/**
 @brief  扫码功能封装对象
 */
@property (nonatomic,strong) LBXScanNative* scanObj;


/*
 AVMetadataObject.h 头文件中有支持的扫码类型,下面列几个常用的条码
 AVMetadataObjectTypeQRCode QR二维码
 AVMetadataObjectTypeCode128Code 支付条码
 AVMetadataObjectTypeCode93Code 93条码
 AVMetadataObjectTypeEAN13Code EAN13条码
 AVMetadataObjectTypeITF14Code native效果比较差，建议ZXing
 */
//虽然接口是支持可以输入多个码制，但是同时多个效果不理想
@property (nonatomic, strong) NSArray<NSString*> *listScanTypes;





//打开相册
- (void)openLocalPhoto:(BOOL)allowsEditing;

//开关闪光灯
- (void)openOrCloseFlash;


//关闭扫描
- (void)stopScan;


@end
