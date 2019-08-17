//
//
//
//  github:https://github.com/MxABC/LBXScan
//  Created by lbxia on 15/3/4.
//  Copyright (c) 2015年 lbxia. All rights reserved.
//


#ifndef __cplusplus
@import UIKit;
@import Foundation;
@import AVFoundation;
#endif

#import "LBXScanTypes.h"
#define LBXScan_Define_Native




/**
 @brief  ios系统自带扫码功能
 */
@interface LBXScanNative : NSObject


#pragma mark --初始化
/**
 @brief  初始化采集相机
 @param preView 视频显示区域
 @param objType 识别码类型：如果为nil，默认支持很多类型。(二维码QR：AVMetadataObjectTypeQRCode,条码如：AVMetadataObjectTypeCode93Code
 @param block   识别结果
 @return LBXScanNative的实例
 */
- (instancetype)initWithPreView:(UIView*)preView ObjectType:(NSArray*)objType success:(void(^)(NSArray<LBXScanResult*> *array))block;


/**
 @brief  初始化采集相机
 @param preView 视频显示区域
 @param objType 识别码类型：如果为nil，默认支持很多类型。(二维码如QR：AVMetadataObjectTypeQRCode,条码如：AVMetadataObjectTypeCode93Code
 @param cropRect 识别区域，值CGRectZero 全屏识别
 @param block   识别结果
 @return LBXScanNative的实例
 */
- (instancetype)initWithPreView:(UIView*)preView ObjectType:(NSArray*)objType cropRect:(CGRect)cropRect
              success:(void(^)(NSArray<LBXScanResult*> *array))block;



#pragma mark --设备控制

/*!
 *  开始扫码
 */
- (void)startScan;

/*!
 *  停止扫码
 */
- (void)stopScan;

/**
 *  开启关闭闪光灯
 *
 *  @param torch ...
 */
- (void)setTorch:(BOOL)torch;

/*!
 *  自动根据闪关灯状态去改变
 */
- (void)changeTorch;

/**
 *  修改扫码类型：二维码、条形码
 *
 *  @param objType type
 */
- (void)changeScanType:(NSArray*)objType;

/*!
 *  设置扫码成功后是否拍照
 *
 *  @param isNeedCaputureImg YES:拍照， NO:不拍照
 */
- (void)setNeedCaptureImage:(BOOL)isNeedCaputureImg;

#pragma mark --镜头
/**
 @brief 获取摄像机最大拉远镜头
 @return 放大系数
 */
- (CGFloat)getVideoMaxScale;

/**
 @brief 拉近拉远镜头
 @param scale 系数
 */
- (void)setVideoScale:(CGFloat)scale;

#pragma mark --识别图片


/**
 识别QR二维码图片,ios8.0以上支持

 @param image 图片
 @param block 返回识别结果
 */
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<LBXScanResult*> *array))block;

#pragma mark --生成条码


/**
 生成QR二维码

 @param text 字符串
 @param size 二维码大小
 @return 返回二维码图像
 */
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size;


/**
 生成QR二维码

 @param text 字符串
 @param size 大小
 @param qrColor 二维码前景色
 @param bkColor 二维码背景色
 @return 二维码图像
 */
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor;


/**
 生成条形码

 @param text 字符串
 @param size 大小
 @return 返回条码图像
 */
+ (UIImage*)createBarCodeWithString:(NSString*)text QRSize:(CGSize)size;

@end

