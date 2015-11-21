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
    
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 80, 40)];
    [btn1 setTitle:@"logo" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(createQR1) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(110, 20, 80, 40)];
    [btn2 setTitle:@"上色" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(createQR2) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btn3 = [[UIButton alloc]initWithFrame:CGRectMake(210, 20, 110, 40)];
    
    [btn3 setTitle:@"背景前景颜色" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(createQR3) forControlEvents:UIControlEventTouchUpInside];
    
    btn1.backgroundColor = [UIColor lightGrayColor];
    btn2.backgroundColor = [UIColor lightGrayColor];
    btn3.backgroundColor = [UIColor lightGrayColor];
    
    btn1.titleLabel.font = [UIFont systemFontOfSize:12.];
    
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
    [self.view addSubview:btn3];
   
    
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



@end
