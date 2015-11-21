//
//  MyQRViewController.m
//  LBXScanDemo
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "MyQRViewController.h"
#import "LBXScanWrapper.h"
#import "LBXAlertAction.h"

@interface MyQRViewController ()
@property (nonatomic, strong) UIImageView* imgView;
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
    
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(80, 20, 100, 40)];
    [btn1 setTitle:@"创建新码" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(newCodeChooose) forControlEvents:UIControlEventTouchUpInside];
    
    btn1.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:btn1];
   
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake( (CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.view.frame)*5/6)/2, 100, CGRectGetWidth(self.view.frame)*5/6, CGRectGetWidth(self.view.frame)*5/6)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.shadowOffset = CGSizeMake(0, 2);
    view.layer.shadowRadius = 2;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.5;
    
    
    self.imgView = [[UIImageView alloc]init];
    _imgView.bounds = CGRectMake(0, 0, CGRectGetWidth(view.frame)-12, CGRectGetWidth(view.frame)-12);
    _imgView.center = CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame)/2);
    [view addSubview:_imgView];
  
    
    [self createQR1];
    
}

- (void)newCodeChooose
{
    __weak __typeof(self) weakSelf = self;
    [LBXAlertAction showActionSheetWithTitle:@"选择" message:@"选择" chooseBlock:^(NSInteger buttonIdx) {
        
        if (buttonIdx==0) {
            [weakSelf createQR1];
        }
        else if (buttonIdx == 1)
        {
            [weakSelf createQR2];
        }
        else if (buttonIdx == 2)
        {
            [weakSelf createQR3];
        }
        else if (buttonIdx == 3)
        {
            [weakSelf createCodeEAN13];
        }
        else if (buttonIdx == 4)
        {
            [weakSelf createCode93];
        }
        
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitle:@"二维码+logo",@"二维码上色",@"二维码前景颜色+背景颜色",@"商品条形码",@"code93(支付宝付款条形码)",nil];
}


- (void)createQR1
{
     UIImage *qrImg = [LBXScanWrapper createQRWithString:@"lbxia20091227@foxmail.com" size:_imgView.bounds.size];
    
    UIImage *logoImg = [UIImage imageNamed:@"logo.JPG"];
    _imgView.image = [LBXScanWrapper addImageLogo:qrImg centerLogoImage:logoImg logoSize:CGSizeMake(30, 30)];
    
}

- (void)createQR2
{
    UIImage *image = [LBXScanWrapper createQRWithString:@"lbxia20091227@foxmail.com" size:_imgView.bounds.size];
    //二维码上色
    _imgView.image = [LBXScanWrapper imageBlackToTransparent:image withRed:255.0f andGreen:74.0f andBlue:89.0f];
    
}

- (void)createQR3
{
    _imgView.image = [LBXScanWrapper createQRWithString:@"lbxia20091227@foxmail.com"
                                                 QRSize:_imgView.bounds.size
                                                QRColor:[UIColor colorWithRed:120./255. green:84./255. blue:40./255 alpha:1.0]
                                                bkColor:[UIColor colorWithRed:41./255. green:130./255. blue:45./255. alpha:1.0]];
}

//商品条形码
- (void)createCodeEAN13
{
    _imgView.image = [LBXScanWrapper createCodeWithString:@"6944551723107" size:_imgView.bounds.size CodeFomart:AVMetadataObjectTypeEAN13Code];
}

- (void)createCode93
{
    //支付宝付款码-条款码
    _imgView.image = [LBXScanWrapper createCodeWithString:@"283657461695996598" size:_imgView.bounds.size CodeFomart:AVMetadataObjectTypeCode128Code];
}



@end
