//
//  Global.h
//  LBXScanDemo
//
//  Created by lbxia on 2017/1/4.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SCANLIBRARYTYPE) {
    SLT_Native,
    SLT_ZXing,
    SLT_ZBar
};

// @[@"QRCode",@"BarCode93",@"BarCode128",@"BarCodeITF",@"EAN13"];
typedef NS_ENUM(NSInteger, SCANCODETYPE) {
    SCT_QRCode, //QR二维码
    SCT_BarCode93,//支付宝条形码
    SCT_BarCode128,
    SCT_BarCodeITF,//
    SCT_BarEAN13 //一般用做商品码
};

@interface Global : NSObject
//当前选择的扫码库
@property (nonatomic, assign) SCANLIBRARYTYPE libraryType;
//当前选择的识别码制
@property (nonatomic, assign) SCANCODETYPE scanCodeType;

+ (instancetype)sharedManager;


//返回native选择的识别码的类型
- (NSString*)nativeCodeType;

- (NSString*)nativeCodeWithType:(SCANCODETYPE)type;

//返回SCANCODETYPE 类别数组
- (NSArray*)nativeTypes;


@end
