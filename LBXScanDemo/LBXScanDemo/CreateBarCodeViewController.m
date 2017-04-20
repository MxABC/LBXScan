//
//  CreateBarCodeViewController.m
//  LBXScanDemo
//
//  Created by lbxia on 2017/1/5.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "CreateBarCodeViewController.h"
#import "LBXAlertAction.h"
#import "LBXScanNative.h"
#import "ZXingWrapper.h"
#import "UIImageView+CornerRadius.h"
#import "Global.h"

@interface CreateBarCodeViewController ()

//二维码
@property (nonatomic, strong) UIView *qrView;
@property (nonatomic, strong) UIImageView* qrImgView;
@property (nonatomic, strong) UIImageView* logoImgView;

//条形码
@property (nonatomic, strong) UIView *tView;
@property (nonatomic, strong) UIImageView *tImgView;


@end

@implementation CreateBarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self showSetttingButton];
}

- (void)showSetttingButton
{
    //选择码扫码类型的按钮
    //把右侧的两个按钮添加到rightBarButtonItem
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    [rightBtn setTitle:@"切换" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(newCodeChooose) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightCunstomButtonView = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightCunstomButtonView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //二维码
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake( (CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.view.frame)*5/6)/2, 100, CGRectGetWidth(self.view.frame)*5/6, CGRectGetWidth(self.view.frame)*5/6)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.shadowOffset = CGSizeMake(0, 2);
    view.layer.shadowRadius = 2;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.5;
    
    
    self.qrImgView = [[UIImageView alloc]init];
    _qrImgView.bounds = CGRectMake(0, 0, CGRectGetWidth(view.frame)-12, CGRectGetWidth(view.frame)-12);
    _qrImgView.center = CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame)/2);
    [view addSubview:_qrImgView];
    self.qrView = view;
    
    
    //条形码
    self.tView = [[UIView alloc]initWithFrame:CGRectMake( (CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.view.frame)*5/6)/2,
                                                         100,
                                                         CGRectGetWidth(self.view.frame)*5/6,
                                                         CGRectGetWidth(self.view.frame)*5/6*0.5)];
    [self.view addSubview:_tView];
    
    
    self.tImgView = [[UIImageView alloc]init];
    _tImgView.bounds = CGRectMake(0, 0, CGRectGetWidth(_tView.frame)-12, CGRectGetHeight(_tView.frame)-12);
    _tImgView.center = CGPointMake(CGRectGetWidth(_tView.frame)/2, CGRectGetHeight(_tView.frame)/3);
    [_tView addSubview:_tImgView];
    
    
    [self createQR_logo];
    
}

- (void)newCodeChooose
{
    __weak __typeof(self) weakSelf = self;
    
    [LBXAlertAction showActionSheetWithTitle:@"" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitle:@[@"二维码+logo",@"二维码前景颜色+背景颜色",@"code13-商品条形码",@"支付宝付款条形码(code128)"] chooseBlock:^(NSInteger buttonIdx) {
        
        switch (buttonIdx) {
           
            case 1:
                [weakSelf createQR_logo];
                break;
            case 2:
                [weakSelf createQR_color];
                break;
            case 3:
                [weakSelf createCodeEAN13];
                break;
            case 4:
                [weakSelf createCode128];
                break;
                
            default:
                break;
        }
    }];
}


- (void)createQR_logo
{
    _qrView.hidden = NO;
    _tView.hidden = YES;
    
    
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
              _qrImgView.image = [LBXScanNative createQRWithString:@"lbxia20091227@foxmail.com" QRSize:_qrImgView.bounds.size];
            break;
        case SLT_ZXing:
            _qrImgView.image = [ZXingWrapper createCodeWithString:@"lbxia20091227@foxmail.com" size:_qrImgView.bounds.size CodeFomart:kBarcodeFormatQRCode];
            break;
            
        default:
            break;
    }
    
    CGSize logoSize=CGSizeMake(30, 30);
    self.logoImgView = [self roundCornerWithImage:[UIImage imageNamed:@"logo"] size:logoSize];
    _logoImgView.bounds = CGRectMake(0, 0, logoSize.width, logoSize.height);
    _logoImgView.center = CGPointMake(CGRectGetWidth(_qrImgView.frame)/2, CGRectGetHeight(_qrImgView.frame)/2);
    [_qrImgView addSubview:_logoImgView];
}

- (UIImageView*)roundCornerWithImage:(UIImage*)logoImg size:(CGSize)size
{
    //logo圆角
    UIImageView *backImage = [[UIImageView alloc] initWithCornerRadiusAdvance:6.0f rectCornerType:UIRectCornerAllCorners];
    backImage.frame = CGRectMake(0, 0, size.width, size.height);
    backImage.backgroundColor = [UIColor whiteColor];
    
    UIImageView *logImage = [[UIImageView alloc] initWithCornerRadiusAdvance:6.0f rectCornerType:UIRectCornerAllCorners];
    logImage.image =logoImg;
    CGFloat diff  =2;
    logImage.frame = CGRectMake(diff, diff, size.width - 2 * diff, size.height - 2 * diff);
    
    [backImage addSubview:logImage];
    
    return backImage;
}

- (void)createQR_color
{
    _qrView.hidden = NO;
    _tView.hidden = YES;
    
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
            _qrImgView.image = [LBXScanNative createQRWithString:@"" QRSize:_qrImgView.bounds.size QRColor:[UIColor blueColor] bkColor:[UIColor whiteColor]];
            break;
        case SLT_ZXing:
        default:
             [self showError:@"暂不支持"];
            break;
    }
}

//商品条形码
- (void)createCodeEAN13
{
    _qrView.hidden = YES;
    _tView.hidden = NO;
    
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
          [self showError:@"native暂不支持EAN13条形码"];
            break;
        case SLT_ZXing:
            _tImgView.image = [ZXingWrapper createCodeWithString:@"6944551723107" size:_qrImgView.bounds.size CodeFomart:kBarcodeFormatEan13];
            break;
            
        default:
            break;
    }
}

- (void)createCode128
{
    _qrView.hidden = YES;
    _tView.hidden = NO;
    
    switch ([Global sharedManager].libraryType) {
        case SLT_Native:
            _tImgView.image = [LBXScanNative createBarCodeWithString:@"283657461695996598" QRSize:_qrImgView.bounds.size];
            break;
        case SLT_ZXing:
             _tImgView.image = [ZXingWrapper createCodeWithString:@"283657461695996598" size:_qrImgView.bounds.size CodeFomart:kBarcodeFormatCode128];
            
//             _tImgView.image = [ZXingWrapper createCodeWithString:@"283657461695996598123456" size:_qrImgView.bounds.size CodeFomart:kBarcodeFormatITF];
            break;
            
        default:
            break;
    }
}

- (void)showError:(NSString*)str
{
    [LBXAlertAction showAlertWithTitle:@"提示" msg:str buttonsStatement:@[@"知道了"] chooseBlock:nil];
}


@end
