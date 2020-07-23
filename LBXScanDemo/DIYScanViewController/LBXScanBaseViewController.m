//
//  LBXScanBaseViewController.m
//  LBXScanDemo
//
//  Created by 夏利兵 on 2020/7/20.
//  Copyright © 2020 lbx. All rights reserved.
//

#import "LBXScanBaseViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ScanResultViewController.h"

@interface LBXScanBaseViewController ()

@end

@implementation LBXScanBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}


#pragma mark- 识别结果
- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    
    if (!array ||  array.count < 1)
    {
        NSLog(@"失败失败了。。。。");
        NSLog(@"失败失败了。。。。");
        NSLog(@"失败失败了。。。。");
            
        [self reStartDevice];
        return;
    }
    
    //经测试，可以ZXing同时识别2个二维码，不能同时识别二维码和条形码
    //    for (LBXScanResult *result in array) {
    //
    //        NSLog(@"scanResult:%@",result.strScanned);
    //    }
    
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    
    if (!strResult) {
        
        [self reStartDevice];
        return;
    }
    
    [self.qRScanView stopScanAnimation];
    
    self.scanImage = scanResult.imgScanned;
    
    //TODO: 这里可以根据需要添加震动或播放成功提醒音等提示相关代码
    //...
    
    //TODO:表示二维码位置
    //ZXing在开启区域识别后，当前计算方式不准确
    if (!self.isOpenInterestRect && self.cameraPreView && !CGRectEqualToRect(CGRectZero, scanResult.bounds) ) {
        
        CGFloat centerX = scanResult.bounds.origin.x + scanResult.bounds.size.width / 2;
        CGFloat centerY = scanResult.bounds.origin.y + scanResult.bounds.size.height / 2;
        
        //条码中心位置绘制红色正方形
        [self signCodeWithCenterX:centerX centerY:centerY];
        
        //条码位置边缘绘制及内部填充
        [self didDetectCodes:scanResult.bounds corner:scanResult.corners];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self showNextVCWithScanResult:scanResult];
            });
        });
    }
    else
    {
        [self showNextVCWithScanResult:scanResult];
    }
    
}

-(UIImage *)getImageFromLayer:(CALayer *)layer size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, [[UIScreen mainScreen]scale]);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (CGPoint)pointForCorner:(NSDictionary *)corner {
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corner, &point);
    return point;
}



- (void)handCorners:(NSArray<NSDictionary *> *)corners bounds:(CGRect)bounds
{
    CGFloat totalX = 0;
    CGFloat totalY = 0;
    
    for (NSDictionary *dic in corners) {
        CGPoint pt = [self pointForCorner:dic];
        NSLog(@"pt:%@",NSStringFromCGPoint(pt));
        totalX += pt.x;
        totalY += pt.y;
    }
    
    CGFloat averX = totalX / corners.count;
    CGFloat averY = totalY / corners.count;
    
   
    
    CGFloat minSize = MIN(bounds.size.width , bounds.size.height);
    
     NSLog(@"averx:%f,avery:%f minsize:%f",averX,averY,minSize);

    dispatch_async(dispatch_get_main_queue(), ^{
             
        [self signCodeWithCenterX:averX centerY:averY];
        
    });
}

- (void)signCodeWithCenterX:(CGFloat)centerX centerY:(CGFloat)centerY
{
    UIView *signView = [[UIView alloc]initWithFrame:CGRectMake(centerX-10, centerY-10, 20, 20)];
    
    [self.cameraPreView addSubview:signView];
    signView.backgroundColor = [UIColor redColor];
    
    self.codeFlagView = signView;
}
  


//继承者实现
- (void)reStartDevice
{
    
}

- (void)resetCodeFlagView
{
    if (_codeFlagView) {
        [_codeFlagView removeFromSuperview];
        self.codeFlagView = nil;
    }
    if (self.layers) {
        
        for (CALayer *layer in self.layers) {
            [layer removeFromSuperlayer];
        }
        
        self.layers = nil;
    }
}

- (UIImage *)imageByCroppingWithSrcImage:(UIImage*)srcImg cropRect:(CGRect)cropRect
{
   
    CGImageRef imageRef = srcImg.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, cropRect);
    UIImage *cropImage = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    return cropImage;
}


- (void)showNextVCWithScanResult:(LBXScanResult*)strResult
{
    ScanResultViewController *vc = [ScanResultViewController new];
    vc.imgScan = strResult.imgScanned;
    
    vc.strScan = strResult.strScanned;
    
    vc.strCodeType = strResult.strBarCodeType;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    //隐藏标记条码位置的信息
    [self resetCodeFlagView];
}


#pragma mark- 绘制二维码区域标志
- (void)didDetectCodes:(CGRect)bounds corner:(NSArray<NSDictionary*>*)corners
{
    AVCaptureVideoPreviewLayer * preview = nil;
    
    for (CALayer *layer in [self.cameraPreView.layer sublayers]) {
        
        if ( [layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            
            preview = (AVCaptureVideoPreviewLayer*)layer;
        }
    }
    
    NSArray *layers = nil;
    if (!layers) {
        layers = @[[self makeBoundsLayer],[self makeCornersLayer]];
        [preview addSublayer:layers[0]];
        [preview addSublayer:layers[1]];
    }
    
    CAShapeLayer *boundsLayer = layers[0];
    boundsLayer.path = [self bezierPathForBounds:bounds].CGPath;
    //得到一个CGPathRef赋给图层的path属性
    
    if (corners) {
        CAShapeLayer *cornersLayer = layers[1];
        cornersLayer.path = [self bezierPathForCorners:corners].CGPath;
        //对于cornersLayer，基于元数据对象创建一个CGPath
    }
    
    self.layers = layers;

}


- (UIBezierPath *)bezierPathForBounds:(CGRect)bounds {
    // 图层边界，创建一个和对象的bounds关联的UIBezierPath
    return [UIBezierPath bezierPathWithRect:bounds];
}

- (CAShapeLayer *)makeBoundsLayer {
    //CAShapeLayer 是具体化的CALayer子类，用于绘制Bezier路径
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor colorWithRed:0.96f green:0.75f blue:0.06f alpha:1.0f].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 4.0f;
    
    return shapeLayer;
}

- (CAShapeLayer *)makeCornersLayer {
    
    CAShapeLayer *cornersLayer = [CAShapeLayer layer];
    cornersLayer.lineWidth = 2.0f;
    cornersLayer.strokeColor = [UIColor colorWithRed:0.172 green:0.671 blue:0.428 alpha:1.0].CGColor;
    cornersLayer.fillColor = [UIColor colorWithRed:0.190 green:0.753 blue:0.489 alpha:0.5].CGColor;
    
    return cornersLayer;;
}

- (UIBezierPath *)bezierPathForCorners:(NSArray *)corners {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < corners.count; i ++) {
        CGPoint point = [self pointForCorner:corners[i]];
        //遍历每个条目，为每个条目创建一个CGPoint
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    return path;
}


#pragma mark- 相册

//继承者实现
- (void)recognizeImageWithImage:(UIImage*)image
{
   

}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self recognizeImageWithImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark- 权限
- (void)requestCameraPemissionWithResult:(void(^)( BOOL granted))completion
{
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                completion(YES);
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                completion(NO);
                break;
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (granted) {
                                                     completion(true);
                                                 } else {
                                                     completion(false);
                                                 }
                                             });
                                             
                                         }];
            }
                break;
                
        }
    }
    
    
}

+ (void)authorizePhotoPermissionWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if (@available(iOS 8.0, *)) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status) {
            case PHAuthorizationStatusAuthorized:
            {
                if (completion) {
                    completion(YES,NO);
                }
            }
                break;
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
            {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
            case PHAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(status == PHAuthorizationStatusAuthorized,YES);
                        });
                    }
                }];
            }
                break;
            default:
            {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
        }
        
    }else{
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        switch (status) {
            case ALAuthorizationStatusAuthorized:
            {
                if (completion) {
                    completion(YES, NO);
                }
            }
                break;
            case ALAuthorizationStatusNotDetermined:
            {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                
                [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                       usingBlock:^(ALAssetsGroup *assetGroup, BOOL *stop) {
                                           if (*stop) {
                                               if (completion) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(YES, NO);
                                                   });
                                                   
                                               }
                                           } else {
                                               *stop = YES;
                                           }
                                       }
                                     failureBlock:^(NSError *error) {
                                         if (completion) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(NO, YES);
                                             });
                                         }
                                     }];
            } break;
            case ALAuthorizationStatusRestricted:
            case ALAuthorizationStatusDenied:
            {
                if (completion) {
                    completion(NO, NO);
                }
            }
                break;
        }
    }
  
}


@end
