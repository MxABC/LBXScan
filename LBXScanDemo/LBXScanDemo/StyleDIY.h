//
//  DemoListViewModel.h
//  LBXScanDemo
//
//  Created by lbxia on 2017/4/1.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LBXScanViewStyle.h>
#import <ZXBarcodeFormat.h>


@interface StyleDIY : NSObject

#pragma mark -模仿qq界面
+ (LBXScanViewStyle*)qqStyle;

#pragma mark --模仿支付宝
+ (LBXScanViewStyle*)ZhiFuBaoStyle;

#pragma mark -无边框，内嵌4个角
+ (LBXScanViewStyle*)InnerStyle;

#pragma mark -无边框，内嵌4个角
+ (LBXScanViewStyle*)weixinStyle;

#pragma mark -框内区域识别
+ (LBXScanViewStyle*)recoCropRect;

#pragma mark -4个角在矩形框线上,网格动画
+ (LBXScanViewStyle*)OnStyle;

#pragma mark -自定义4个角及矩形框颜色
+ (LBXScanViewStyle*)changeColor;

#pragma mark -改变扫码区域位置
+ (LBXScanViewStyle*)changeSize;

#pragma mark -非正方形，可以用在扫码条形码界面
+ (LBXScanViewStyle*)notSquare;

#pragma mark -ZXing码格式类型转native
+ (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat;

@end
