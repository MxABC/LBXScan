//
//  ZXingWrapper.m
//
//
//  Created by lbxia on 15/1/6.
//  Copyright (c) 2015年 lbxia. All rights reserved.
//

#import "ZXingWrapper.h"
#import "ZXingObjC.h"
#import "LBXZXCaptureDelegate.h"
#import "LBXZXCapture.h"


@interface ZXingWrapper() <LBXZXCaptureDelegate>
@property (nonatomic, strong) LBXZXCapture *capture;

@property (nonatomic, copy) void (^success)(ZXBarcodeFormat barcodeFormat,NSString *str,UIImage *scanImg);

@property (nonatomic, copy) void (^onSuccess)(ZXBarcodeFormat barcodeFormat,NSString *str,UIImage *scanImg,NSArray* resultPoints);

@property (nonatomic, assign) BOOL bNeedScanResult;

@end

@implementation ZXingWrapper


- (id)init
{
    if ( self = [super init] )
    {
        self.capture = [[LBXZXCapture alloc] init];
        self.capture.camera = self.capture.back;
        self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        self.capture.rotation = 90.0f;
        self.capture.delegate = self;
        self.continuous = NO;
        self.orientation = AVCaptureVideoOrientationPortrait;
    }
    return self;
}

- (void)setOnStarted:(void (^)(void))onStarted
{
    self.capture.onStarted = onStarted;
}

- (id)initWithPreView:(UIView*)preView block:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *str,UIImage *scanImg))block
{
    if (self = [super init]) {
        
        self.capture = [[LBXZXCapture alloc] init];
        self.capture.camera = self.capture.back;
        self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        self.capture.rotation = 90.0f;
        self.capture.delegate = self;
        self.continuous = NO;
        self.orientation = AVCaptureVideoOrientationPortrait;
        
        self.success = block;
        
        CGRect rect = preView.frame;
        rect.origin = CGPointZero;
        
        self.capture.layer.frame = rect;
        //[preView.layer addSublayer:self.capture.layer];
        
        [preView.layer insertSublayer:self.capture.layer atIndex:0];
        
    }
    return self;
}

- (id)initWithPreView:(UIView*)preView success:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *str,UIImage *scanImg,NSArray* resultPoints))success
{
    if (self = [super init]) {
        
        self.capture = [[LBXZXCapture alloc] init];
        self.capture.camera = self.capture.back;
        self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        self.capture.rotation = 90.0f;
        self.capture.delegate = self;
        self.continuous = NO;
        self.orientation = AVCaptureVideoOrientationPortrait;
        
        self.onSuccess = success;
        
        CGRect rect = preView.frame;
        rect.origin = CGPointZero;
        
        self.capture.layer.frame = rect;
        //[preView.layer addSublayer:self.capture.layer];
        
        [preView.layer insertSublayer:self.capture.layer atIndex:0];
        
    }
    return self;
}

- (void)setScanRect:(CGRect)scanRect
{
    self.capture.scanRect = scanRect;
}

- (void)start
{
    self.bNeedScanResult = YES;
    
    AVCaptureVideoPreviewLayer * preview = (AVCaptureVideoPreviewLayer*)self.capture.layer;
    preview.connection.videoOrientation = self.orientation;
    
    [self.capture start];
}


- (void)stop
{
    self.bNeedScanResult = NO;
    [self.capture stop];
}

- (void)setOrientation:(NSInteger)orientation
{
    _orientation = orientation;
    
    AVCaptureVideoPreviewLayer * preview = (AVCaptureVideoPreviewLayer*)self.capture.layer;
       preview.connection.videoOrientation = self.orientation;
    
    switch (self.orientation) {
        case AVCaptureVideoOrientationPortrait:
        case AVCaptureVideoOrientationPortraitUpsideDown:
            self.capture.rotation = 90.0f;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
        case AVCaptureVideoOrientationLandscapeRight:
            self.capture.rotation = 0.0f;
            break;
        default:
            break;
    }
}

- (void)setVideoLayerframe:(CGRect)videoLayerframe
{
    _videoLayerframe = videoLayerframe;
    
    AVCaptureVideoPreviewLayer * preview = (AVCaptureVideoPreviewLayer*)self.capture.layer;
    preview.frame = videoLayerframe;
}

- (void)openTorch:(BOOL)on_off
{
    [self.capture setTorch:on_off];
}
- (void)openOrCloseTorch
{
    [self.capture changeTorch];
}


#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result scanImage:(UIImage *)img
{
    if (!result) return;
    
    if (self.bNeedScanResult == NO) {
        
        return;
    }
    
    if (!_continuous) {
        
         [self stop];
    }
    
    
    if (_onSuccess) {
        _onSuccess(result.barcodeFormat,result.text,img,result.resultPoints);
    }
    else if ( _success )
    {
        _success(result.barcodeFormat,result.text,img);
    }    
}


+ (UIImage*)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(ZXBarcodeFormat)format
{
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *result = [writer encode:str
                                  format:format
                                   width:size.width
                                  height:size.width
                                   error:nil];
    
    if (result) {
        ZXImage *image = [ZXImage imageWithMatrix:result];
        return [UIImage imageWithCGImage:image.cgimage];
    } else {
        return nil;
    }
}


+ (void)recognizeImage:(UIImage*)image block:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *str))block;
{
    ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
    
    ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource: source];
    
    ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
    
    NSError *error;
    
    id<ZXReader> reader;
    
    if (NSClassFromString(@"ZXMultiFormatReader")) {
        reader = [NSClassFromString(@"ZXMultiFormatReader") performSelector:@selector(reader)];
    }
    
    ZXDecodeHints *_hints = [ZXDecodeHints hints];
    ZXResult *result = [reader decode:bitmap hints:_hints error:&error];
    
    if (result == nil) {
        
        block(kBarcodeFormatQRCode,nil);
        return;
    }
    
    block(result.barcodeFormat,result.text);
}




@end
