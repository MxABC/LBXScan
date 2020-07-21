//
//
//
//  github:https://github.com/MxABC/LBXScan
//  Created by lbxia on 15/3/4.
//  Copyright (c) 2015年 lbxia. All rights reserved.
//


@import UIKit;
@import Foundation;





@interface LBXScanResult : NSObject


- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type;

/**
 @brief  条码字符串
 */
@property (nonatomic, copy) NSString* strScanned;
/**
 @brief  扫码图像
 */
@property (nonatomic, strong) UIImage* imgScanned;
/**
 @brief  扫码码的类型,AVMetadataObjectType  如AVMetadataObjectTypeQRCode，AVMetadataObjectTypeEAN13Code等
 */
@property (nonatomic, copy) NSString* strBarCodeType;

//条码4个角
@property (nonatomic, copy)  NSArray<NSDictionary *> *corners;

//没有corners精确
@property (nonatomic, assign) CGRect bounds;

@end

