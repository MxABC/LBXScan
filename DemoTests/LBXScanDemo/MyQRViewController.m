//
//  MyQRViewController.m
//  LBXScanDemo
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "MyQRViewController.h"
#import "LBXScanWrapper.h"

@interface MyQRViewController ()

@end

@implementation MyQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIImageView *imgview = [[UIImageView alloc]init];
    imgview.bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.frame)*4/5, CGRectGetWidth(self.view.frame)*4/5);
    imgview.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2-40);
    
    [self.view addSubview:imgview];
    
    UIImage *qrImg = [LBXScanWrapper createQRWithString:@"lbxia20091227@foxmail.com" size:imgview.bounds.size];
    
    
    UIImage *logoImg = [UIImage imageNamed:@"logo.JPG"];
    
    
    imgview.image = [LBXScanWrapper addImageLogo:qrImg centerLogoImage:logoImg logoSize:CGSizeMake(30, 30)];
    
    
}



@end
