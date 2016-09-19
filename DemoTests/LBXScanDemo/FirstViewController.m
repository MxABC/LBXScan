//
//  FirstViewController.m
//  LBXScanDemo
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "FirstViewController.h"
#import "SubLBXScanViewController.h"
#import "MyQRViewController.h"
#import "LBXScanView.h"
#import <objc/message.h>
#import "ScanResultViewController.h"
#import "LBXScanResult.h"
#import "LBXScanWrapper.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray* arrayItems;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"扫码";
    
    self.arrayItems = @[
                        @[@"模拟qq扫码界面",@"qqStyle"],
                        @[@"模仿支付宝扫码区域",@"ZhiFuBaoStyle"],
                        @[@"模仿微信扫码区域",@"weixinStyle"],
                        @[@"无边框，内嵌4个角",@"InnerStyle"],
                        @[@"4个角在矩形框线上,网格动画",@"OnStyle"],
                        @[@"自定义颜色",@"changeColor"],
                        @[@"只识别框内",@"recoCropRect"],
                        @[@"改变尺寸",@"changeSize"],
                        @[@"条形码效果",@"notSquare"],
                        @[@"二维码/条形码生成",@"myQR"],
                        @[@"相册",@"openLocalPhotoAlbum"]
                        ];
    
    
//#pragma mark -自定义4个角及矩形框颜色
//    - (void)changeColor

    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayItems.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [_arrayItems[indexPath.row]firstObject];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* array = _arrayItems[indexPath.row];
    
    if (indexPath.row < (_arrayItems.count - 2) )
    {
        if (![self cameraPemission])
        {
            [self showError:@"没有摄像机权限"];
            return;
        }
    }
    
    NSString *methodName = [array lastObject];
    
    SEL normalSelector = NSSelectorFromString(methodName);
    if ([self respondsToSelector:normalSelector]) {
        
        ((void (*)(id, SEL))objc_msgSend)(self, normalSelector);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)cameraPemission
{
    
    BOOL isHavePemission = NO;
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                isHavePemission = YES;
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                break;
            case AVAuthorizationStatusNotDetermined:
                isHavePemission = YES;
                break;
        }
    }
    
    return isHavePemission;
}


#pragma mark -模仿qq界面
- (void)qqStyle
{
    //设置扫码区域参数设置
    
    //创建参数对象
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    
    //矩形区域中心上移，默认中心点为屏幕中心点
    style.centerUpOffset = 44;
    
    //扫码框周围4个角的类型,设置为外挂式
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    
    //扫码框周围4个角绘制的线条宽度
    style.photoframeLineW = 6;
    
    //扫码框周围4个角的宽度
    style.photoframeAngleW = 24;
    
    //扫码框周围4个角的高度
    style.photoframeAngleH = 24;
    
    //扫码框内 动画类型 --线条上下移动
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //线条上下移动图片
    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    
    //SubLBXScanViewController继承自LBXScanViewController
    //添加一些扫码或相册结果处理
    SubLBXScanViewController *vc = [SubLBXScanViewController new];
    vc.style = style;   
    
    vc.isQQSimulator = YES;
    vc.isVideoZoom = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --模仿支付宝
- (void)ZhiFuBaoStyle
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 60;
    style.xScanRetangleOffset = 30;
    
    if ([UIScreen mainScreen].bounds.size.height <= 480 )
    {
        //3.5inch 显示的扫码缩小
        style.centerUpOffset = 40;
        style.xScanRetangleOffset = 20;
    }
    
    
    style.alpa_notRecoginitonArea = 0.6;
    
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
    style.photoframeLineW = 2.0;
    style.photoframeAngleW = 16;
    style.photoframeAngleH = 16;
    
    style.isNeedShowRetangle = NO;
    
    style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;
    
        //使用的支付宝里面网格图片
    UIImage *imgFullNet = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_full_net"];
    
    
    style.animationImage = imgFullNet;
    
    
    [self openScanVCWithStyle:style];
}



#pragma mark -无边框，内嵌4个角
- (void)InnerStyle
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
    style.photoframeLineW = 3;
    style.photoframeAngleW = 18;
    style.photoframeAngleH = 18;
    style.isNeedShowRetangle = NO;
    
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    
    style.animationImage = imgLine;
    //非正方形
    //        style.isScanRetangelSquare = NO;
    //        style.xScanRetangleOffset = 40;
    
    
   [self openScanVCWithStyle:style];
}

#pragma mark -无边框，内嵌4个角
- (void)weixinStyle
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
    style.photoframeLineW = 2;
    style.photoframeAngleW = 18;
    style.photoframeAngleH = 18;
    style.isNeedShowRetangle = YES;
    
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    style.colorAngle = [UIColor colorWithRed:0./255 green:200./255. blue:20./255. alpha:1.0];
  
    
    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_Scan_weixin_Line"];
    
   // imgLine = [self createImageWithColor:[UIColor colorWithRed:120/255. green:221/255. blue:71/255. alpha:1.0]];
    
    style.animationImage = imgLine;
  
    
    
    
    [self openScanVCWithStyle:style];
}

#pragma mark -框内区域识别
- (void)recoCropRect
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_On;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    style.isNeedShowRetangle = YES;
    
    style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;
    
    
    //矩形框离左边缘及右边缘的距离
    style.xScanRetangleOffset = 80;
    
    //使用的支付宝里面网格图片
    UIImage *imgPartNet = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"];
    
    style.animationImage = imgPartNet;
    
    
    SubLBXScanViewController *vc = [SubLBXScanViewController new];
    vc.style = style;
    //开启只识别框内
    vc.isOpenInterestRect = YES;
    [self.navigationController pushViewController:vc animated:YES];
}




#pragma mark -4个角在矩形框线上,网格动画
- (void)OnStyle
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_On;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    style.isNeedShowRetangle = YES;
    
    style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;
    
   
    //使用的支付宝里面网格图片
    UIImage *imgPartNet = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"];
    
    style.animationImage = imgPartNet;
    
    //非正方形
    //        style.isScanRetangelSquare = NO;
    //        style.xScanRetangleOffset = 40;
    
    [self openScanVCWithStyle:style];
}

#pragma mark -自定义4个角及矩形框颜色
- (void)changeColor
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    
    //扫码框周围4个角的类型设置为在框的上面
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_On;
    //扫码框周围4个角绘制线宽度
    style.photoframeLineW = 6;
    
    //扫码框周围4个角的宽度
    style.photoframeAngleW = 24;
    
    //扫码框周围4个角的高度
    style.photoframeAngleH = 24;
    
    //显示矩形框
    style.isNeedShowRetangle = YES;
    
    //动画类型：网格形式，模仿支付宝
    style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;
    
    
    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"];;
    
    //码框周围4个角的颜色
    style.colorAngle = [UIColor colorWithRed:65./255. green:174./255. blue:57./255. alpha:1.0];
    
    //矩形框颜色
    style.colorRetangleLine = [UIColor colorWithRed:247/255. green:202./255. blue:15./255. alpha:1.0];
    
    //非矩形框区域颜色
    style.red_notRecoginitonArea = 247./255.;
    style.green_notRecoginitonArea = 202./255;
    style.blue_notRecoginitonArea = 15./255;
    style.alpa_notRecoginitonArea = 0.2;
    
    SubLBXScanViewController *vc = [SubLBXScanViewController new];
    vc.style = style;
    
    //开启只识别矩形框内图像功能
    vc.isOpenInterestRect = YES;
    [self.navigationController pushViewController:vc animated:YES];
   
}

#pragma mark -改变扫码区域位置
- (void)changeSize
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    
    //矩形框向上移动
    style.centerUpOffset = 60;
    //矩形框离左边缘及右边缘的距离
    style.xScanRetangleOffset = 100;
    
    
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_On;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    style.isNeedShowRetangle = YES;
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    
    style.animationImage = imgLine;
    
    [self openScanVCWithStyle:style];
}

#pragma mark -非正方形，可以用在扫码条形码界面

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)notSquare
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
    style.photoframeLineW = 4;
    style.photoframeAngleW = 28;
    style.photoframeAngleH = 16;
    style.isNeedShowRetangle = NO;
    
    style.anmiationStyle = LBXScanViewAnimationStyle_LineStill;
    
    
    style.animationImage = [self createImageWithColor:[UIColor redColor]];
    //非正方形
    //设置矩形宽高比
    style.whRatio = 4.3/2.18;

    //离左边和右边距离
    style.xScanRetangleOffset = 30;    
    
    
    
    [self openScanVCWithStyle:style];
}

- (void)myQR
{
    MyQRViewController *vc = [[MyQRViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openScanVCWithStyle:(LBXScanViewStyle*)style
{
     SubLBXScanViewController *vc = [SubLBXScanViewController new];
     vc.style = style;
    //vc.isOpenInterestRect = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 相册
- (void)openLocalPhotoAlbum
{
    if ([LBXScanWrapper isGetPhotoPermission])
    {
        [self openLocalPhoto];
    }
    else
        [self showError:@"      请到设置->隐私中开启本程序相册权限     "];
}

/*!
 *  打开本地照片，选择图片识别
 */
- (void)openLocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    
    
//    picker.allowsEditing = YES;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}



//当选择一张图片后进入这里

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    __weak __typeof(self) weakSelf = self;
    [LBXScanWrapper recognizeImage:image success:^(NSArray<LBXScanResult *> *array) {
        
        [weakSelf scanResultWithArray:array];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    
    if (array.count < 1)
    {
        [self showError:@"识别失败了"];
        
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    for (LBXScanResult *result in array) {
        
        NSLog(@"scanResult:%@",result.strScanned);
    }
    
    LBXScanResult *scanResult = array[0];
    
    //震动提醒
    [LBXScanWrapper systemVibrate];
    //声音提醒
    [LBXScanWrapper systemSound];
    
    [self showNextVCWithScanResult:scanResult];
}


- (void)showError:(NSString*)str
{
    [LBXAlertAction showAlertWithTitle:@"提示" msg:str chooseBlock:nil buttonsStatement:@"知道了",nil];
}

- (void)showNextVCWithScanResult:(LBXScanResult*)strResult
{
    ScanResultViewController *vc = [ScanResultViewController new];
    vc.imgScan = strResult.imgScanned;
    
    vc.strScan = strResult.strScanned;
    
    vc.strCodeType = strResult.strBarCodeType;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end


