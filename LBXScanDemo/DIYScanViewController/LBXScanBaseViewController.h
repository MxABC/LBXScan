//
//  LBXScanBaseViewController.h
//  LBXScanDemo
//
//  Created by 夏利兵 on 2020/7/20.
//  Copyright © 2020 lbx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBXScanTypes.h"
#import "LBXScanView.h"
#import "LBXScanNative.h"


@interface LBXScanBaseViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
#pragma mark ---- 需要初始化参数 ------


/**
 @brief 是否需要扫码图像
 */
@property (nonatomic, assign) BOOL isNeedScanImage;


/**
@brief 是否需要连续扫码
*/
@property (nonatomic, assign) BOOL continuous;

/**
 @brief  启动区域识别功能
 */
@property(nonatomic,assign) BOOL isOpenInterestRect;


/**
 相机启动提示,如 相机启动中...
 */
@property (nonatomic, copy) NSString *cameraInvokeMsg;


//相机预览
@property (nonatomic, strong) UIView *cameraPreView;

/**
 *  界面效果参数
 */
@property (nonatomic, strong) LBXScanViewStyle *style;

//default  AVCaptureVideoOrientationPortrait
@property (nonatomic, assign) AVCaptureVideoOrientation  orientation;

/**
 @brief  扫码区域视图,二维码一般都是框
 */
@property (nonatomic,strong) LBXScanView* qRScanView;


/// 首次加载
@property (nonatomic, assign) BOOL firstLoad;

//条码识别位置标示
@property (nonatomic, strong) UIView *codeFlagView;
@property (nonatomic, strong) NSArray<CALayer*> *layers;


/**
 @brief  扫码存储的当前图片
 */
@property(nonatomic,strong) UIImage* scanImage;


/**
 @brief  闪关灯开启状态记录
 */
@property(nonatomic,assign)BOOL isOpenFlash;



//继承者实现
- (void)reStartDevice;
- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array;


- (void)resetCodeFlagView;

///截取UIImage指定区域图片
- (UIImage *)imageByCroppingWithSrcImage:(UIImage*)srcImg cropRect:(CGRect)cropRect;

- (void)requestCameraPemissionWithResult:(void(^)( BOOL granted))completion;
+ (void)authorizePhotoPermissionWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;



- (BOOL)isLandScape;

- (AVCaptureVideoOrientation)videoOrientation;
@end


