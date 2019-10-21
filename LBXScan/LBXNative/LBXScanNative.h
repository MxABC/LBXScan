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
//! 识别QR二维码图片,ios8.0以上支持
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<LBXScanResult*> *array))block;

#pragma mark - 生成二维码/条形码
//! 生成二维码
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size;
//! 生成二维码+logo
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(nonnull UIImage *)logo;
//! 生成条形码
+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size;
@end

