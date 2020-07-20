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
#import "LBXZBarWrapper.h"



@interface LBXScanZBarViewController : LBXScanBaseViewController


//扫码类型: test only ZBAR_I25 effective
@property (nonatomic, assign) zbar_symbol_type_t zbarType;

/**
 ZBar扫码对象
 */
@property (nonatomic, strong) LBXZBarWrapper *zbarObj;



//打开相册
- (void)openLocalPhoto:(BOOL)allowsEditing;

//开关闪光灯
- (void)openOrCloseFlash;

//启动扫描
- (void)reStartDevice;

//关闭扫描
- (void)stopScan;


@end
