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
#import "LBXScanTypes.h"
#import "LBXScanView.h"
#import "LBXScanNative.h" 


@interface LBXScanNativeViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


#pragma mark ---- 需要初始化参数 ------


/**
 @brief 是否需要扫码图像
 */
@property (nonatomic, assign) BOOL isNeedScanImage;

/**
 @brief  启动区域识别功能
 */
@property(nonatomic,assign) BOOL isOpenInterestRect;


/**
 相机启动提示,如 相机启动中...
 */
@property (nonatomic, copy) NSString *cameraInvokeMsg;

/**
 *  界面效果参数
 */
@property (nonatomic, strong) LBXScanViewStyle *style;




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



#pragma mark - 扫码界面效果及提示等
/**
 @brief  扫码区域视图,二维码一般都是框
 */
@property (nonatomic,strong) LBXScanView* qRScanView;




/**
 @brief  扫码存储的当前图片
 */
@property(nonatomic,strong) UIImage* scanImage;


/**
 @brief  闪关灯开启状态记录
 */
@property(nonatomic,assign)BOOL isOpenFlash;





//打开相册
- (void)openLocalPhoto:(BOOL)allowsEditing;

//开关闪光灯
- (void)openOrCloseFlash;

//启动扫描
- (void)reStartDevice;

//关闭扫描
- (void)stopScan;


@end
