//
//  Global.m
//  LBXScanDemo
//
//  Created by lbxia on 2017/1/4.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "Global.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@implementation Global

+ (instancetype)sharedManager
{
    static Global* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Global alloc] init];
        _sharedInstance.libraryType = SLT_Native;
        _sharedInstance.scanCodeType = SCT_QRCode;
    });
    
    return _sharedInstance;
}

- (NSString*)nativeCodeType
{
    return [self nativeCodeWithType:_scanCodeType];
}

- (NSString*)nativeCodeWithType:(SCANCODETYPE)type
{
    switch (type) {
        case SCT_QRCode:
            return AVMetadataObjectTypeQRCode;
            break;
        case SCT_BarCode93:
            return AVMetadataObjectTypeCode93Code;
            break;
        case SCT_BarCode128:
            return AVMetadataObjectTypeCode128Code;
            break;
        case SCT_BarCodeITF:
            return @"ITF条码:only ZXing支持";
            break;
        case SCT_BarEAN13:
            return AVMetadataObjectTypeEAN13Code;
            break;
            
        default:
            return AVMetadataObjectTypeQRCode;
            break;
    }
}

- (NSArray*)nativeTypes
{
    return @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,@"ITF(只有ZXing支持)",AVMetadataObjectTypeEAN13Code];
}


@end
