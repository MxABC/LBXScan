//
//  QQStyleQRScanViewController.h
//  LBXScanDemo
//  github:https://github.com/MxABC/LBXScan
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Global.h"


//Native代码量很小，基本是会下载的
#define LBXScan_Define_Native
#define LBXScan_Define_ZXing
#define LBXScan_Define_ZBar
#define LBXScan_Define_UI

#import "LBXScanPermissions.h"

//UI
#ifdef LBXScan_Define_UI
#import "LBXScanView.h"
#endif


#ifdef LBXScan_Define_Native
#import "LBXScanNative.h" //原生扫码封装
#endif

#ifdef LBXScan_Define_ZXing
#import "ZXingWrapper.h" //ZXing扫码封装
#endif

#ifdef LBXScan_Define_ZBar
#import "LBXZBarWrapper.h"//ZBar扫码封装
#endif





@interface LBXScanViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


/**
 @brief 是否需要扫码图像
 */
@property (nonatomic, assign) BOOL isNeedScanImage;


#ifdef LBXScan_Define_Native
/**
 @brief  扫码功能封装对象
 */
@property (nonatomic,strong) LBXScanNative* scanObj;

#endif


#ifdef LBXScan_Define_ZXing
/**
 ZXing扫码对象
 */
@property (nonatomic, strong) ZXingWrapper *zxingObj;
#endif



#ifdef LBXScan_Define_ZBar
/**
 ZBar扫码对象
 */
@property (nonatomic, strong) LBXZBarWrapper *zbarObj;

#endif


#ifdef LBXScan_Define_UI

#pragma mark - 扫码界面效果及提示等
/**
 @brief  扫码区域视图,二维码一般都是框
 */
@property (nonatomic,strong) LBXScanView* qRScanView;


/**
 *  界面效果参数
 */
@property (nonatomic, strong) LBXScanViewStyle *style;


#endif


/**
 @brief  扫码存储的当前图片
 */
@property(nonatomic,strong)UIImage* scanImage;






/**
 @brief  启动区域识别功能
 */
@property(nonatomic,assign)BOOL isOpenInterestRect;


/**
 @brief  闪关灯开启状态
 */
@property(nonatomic,assign)BOOL isOpenFlash;


//打开相册
- (void)openLocalPhoto;
//开关闪光灯
- (void)openOrCloseFlash;


//子类继承必须实现的提示
/**
 *  继承者实现的alert提示功能
 *
 *  @param str 提示语
 */
- (void)showError:(NSString*)str;


- (void)reStartDevice;


@end
