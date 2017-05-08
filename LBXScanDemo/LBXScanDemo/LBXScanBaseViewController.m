//
//  LBXScanBaseViewController.m
//  LBXScanDemo
//
//  Created by lbxia on 2017/4/25.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXScanBaseViewController.h"

@interface LBXScanBaseViewController ()

@end

@implementation LBXScanBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self drawScanView];
    
    //不延时，可能会导致界面黑屏并卡住一会
    [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
}

//绘制扫描区域
- (void)drawScanView
{
    
}

- (void)reStartDevice
{
    
}

//启动设备
- (void)startScan
{
    
}


@end
