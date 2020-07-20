//
//  QQStyleQRScanViewController.h
//
//  github:https://github.com/MxABC/LBXScan
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LBXScanBaseViewController.h"
#import "ZXingWrapper.h"



@interface LBXScanZXingViewController : LBXScanBaseViewController


#pragma mark ---- 需要初始化参数 ------
/**
 ZXing扫码对象
 */
@property (nonatomic, strong) ZXingWrapper *zxingObj;



//打开相册
- (void)openLocalPhoto:(BOOL)allowsEditing;

//开关闪光灯
- (void)openOrCloseFlash;

//启动扫描
- (void)reStartDevice;

//关闭扫描
- (void)stopScan;


@end
