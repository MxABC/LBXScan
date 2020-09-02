


#import "LBXScanNative.h"



@interface LBXScanNative()<AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL bNeedScanResult;
   
}

@property (assign,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property(nonatomic,strong)  AVCaptureStillImageOutput *stillImageOutput;//拍照

@property(nonatomic,assign)BOOL isNeedCaputureImage;

//启动中
@property (nonatomic, assign)  BOOL starting;

//扫码结果
@property (nonatomic, strong) NSMutableArray<LBXScanResult*> *arrayResult;

//扫码类型
@property (nonatomic, strong) NSArray* arrayBarCodeType;

/**
 @brief  视频预览显示视图
 */
@property (nonatomic,weak)UIView *videoPreView;


/*!
 *  扫码结果返回
 */
@property(nonatomic,copy)void (^blockScanResult)(NSArray<LBXScanResult*> *array);

@property (nonatomic, copy) void (^blockvideoMaxScale)(CGFloat maxScale);


@end

@implementation LBXScanNative


- (void)setNeedCaptureImage:(BOOL)isNeedCaputureImg
{
    _isNeedCaputureImage = isNeedCaputureImg;
}


- (instancetype)initWithPreView:(UIView*)preView
                     ObjectType:(NSArray*)objType
                  videoMaxScale:(void(^)(CGFloat maxScale))blockvideoMaxScale
                        success:(void(^)(NSArray<LBXScanResult*> *array))success
{
    if (self = [super init]) {
        
        
        [self initParaWithPreView:preView ObjectType:objType cropRect:CGRectZero videoMaxScale:blockvideoMaxScale success:success];
    }
    
    return self;
}

- (instancetype)initWithPreView:(UIView*)preView
                     ObjectType:(NSArray*)objType
                        success:(void(^)(NSArray<LBXScanResult*> *array))success
{
    if (self = [super init]) {
        
        [self initParaWithPreView:preView ObjectType:objType cropRect:CGRectZero videoMaxScale:nil success:success];
    }
    
    return self;
}


- (instancetype)initWithPreView:(UIView*)preView
                     ObjectType:(NSArray*)objType
                       cropRect:(CGRect)cropRect
                  videoMaxScale:(void(^)(CGFloat maxScale))blockvideoMaxScale
                        success:(void(^)(NSArray<LBXScanResult*> *array))success
{
    if (self = [super init]) {
        [self initParaWithPreView:preView ObjectType:objType cropRect:cropRect videoMaxScale:blockvideoMaxScale success:success];
    }
    return self;
}

- (instancetype)initWithPreView:(UIView*)preView
                     ObjectType:(NSArray*)objType
                       cropRect:(CGRect)cropRect
                        success:(void(^)(NSArray<LBXScanResult*> *array))success
{
    if (self = [super init]) {
        [self initParaWithPreView:preView ObjectType:objType cropRect:cropRect videoMaxScale:nil success:success];
    }
    return self;
}



- (void)initParaWithPreView:(UIView*)videoPreView
                 ObjectType:(NSArray*)objType
                   cropRect:(CGRect)cropRect
              videoMaxScale:(void(^)(CGFloat maxScale))blockvideoMaxScale
                    success:(void(^)(NSArray<LBXScanResult*> *array))success
{
    
    self.needCodePosion = NO;
    self.continuous = NO;
    self.starting = NO;
    self.orientation = AVCaptureVideoOrientationPortrait;
    self.blockvideoMaxScale  = blockvideoMaxScale;
    
    self.arrayBarCodeType = objType;
    self.blockScanResult = success;
    self.videoPreView = videoPreView;
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!_device) {
        return;
    }
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if ( !_input  )
        return ;
    
    
    bNeedScanResult = YES;
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    
    if ( !CGRectEqualToRect(cropRect,CGRectZero) )
    {
        _output.rectOfInterest = cropRect;
    }
    
    /*
    // Setup the still image file output
     */
//    AVCapturePhotoOutput
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
//    [_session setSessionPreset:AVCaptureSessionPreset1280x720];
    
    if ([_session canAddInput:_input])
    {
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_output])
    {
        [_session addOutput:_output];
    }

    if ([_session canAddOutput:_stillImageOutput])
    {
        [_session addOutput:_stillImageOutput];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
   // _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    if (!objType) {
        objType = [self defaultMetaDataObjectTypes];
    }
    
    _output.metadataObjectTypes = objType;
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
//    _preview
    
    //_preview.frame =CGRectMake(20,110,280,280);
    
    CGRect frame = videoPreView.frame;
    frame.origin = CGPointZero;
    _preview.frame = frame;
    

    [videoPreView.layer insertSublayer:self.preview atIndex:0];
    
    
    if (_blockvideoMaxScale) {
        
        AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
        CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;
        CGFloat scale = videoConnection.videoScaleAndCropFactor;
        NSLog(@"max:%F cur:%f",maxScale,scale);
        
        _blockvideoMaxScale(maxScale);
    }

    
    //先进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
    if (_device.isFocusPointOfInterestSupported &&[_device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        [_input.device lockForConfiguration:nil];
        [_input.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [_input.device unlockForConfiguration];
    }
}

- (CGFloat)getVideoMaxScale
{
    [_input.device lockForConfiguration:nil];
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;
    [_input.device unlockForConfiguration];
    
    return maxScale;
}

- (void)setVideoScale:(CGFloat)scale
{
    [_input.device lockForConfiguration:nil];
    

    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    

    if (scale < 1 || scale > videoConnection.videoMaxScaleAndCropFactor ) {
        return;
    }
    
    CGFloat zoom = scale / videoConnection.videoScaleAndCropFactor;
//     NSLog(@"max :%f",videoConnection.videoMaxScaleAndCropFactor);

    
    videoConnection.videoScaleAndCropFactor = scale;
    
    [_input.device unlockForConfiguration];
    
    CGAffineTransform transform = _videoPreView.transform;
    
    _videoPreView.transform = CGAffineTransformScale(transform, zoom, zoom);
    
    
//    CGFloat y = 0;
//    y = y + zoom > 1 ? zoom : -zoom;
//    //移动
//    _videoPreView.transform = CGAffineTransformTranslate(_videoPreView.transform, 0, y);

}

- (void)setScanRect:(CGRect)scanRect
{
    //识别区域设置
    if (_output) {
        _output.rectOfInterest = [self.preview metadataOutputRectOfInterestForRect:scanRect];
    }
}

- (void)changeScanType:(NSArray*)objType
{    
    _output.metadataObjectTypes = objType;
}

- (void)setOrientation:(AVCaptureVideoOrientation)orientation
{
    _orientation = orientation;
    
    if ( _input  )
    {
        self.preview.connection.videoOrientation = self.orientation;
    }

}

- (void)setVideoLayerframe:(CGRect)videoLayerframe
{
    self.preview.frame = videoLayerframe;
}

- (void)startScan
{
    if ( !_starting && _input && !_session.isRunning )
    {
        _starting = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            self.preview.connection.videoOrientation = self.orientation;

            [self.session startRunning];
            self->bNeedScanResult = YES;
            self.starting = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                

                [self.videoPreView.layer insertSublayer:self.preview atIndex:0];
                if (self.onStarted) {
                    self.onStarted();
                }
            });
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( object == _input.device ) {
        
        NSLog(@"flash change");
    }
}

- (void)stopScan
{
    bNeedScanResult = NO;
    if ( _input && _session.isRunning )
    {
        bNeedScanResult = NO;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            [self.session stopRunning];
            self.starting  = NO;
        });
    }
}

- (BOOL)hasTorch
{
    return [_input.device hasTorch];
}

- (void)setTorch:(BOOL)torch {   
    if ([self.input.device hasTorch]) {
        NSError *error = nil;
        if([self.input.device lockForConfiguration:&error])
        self.input.device.torchMode = torch ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [self.input.device unlockForConfiguration];
    }
}

- (void)changeTorch
{
    if ([self.input.device hasTorch]) {
        
        AVCaptureTorchMode torch = self.input.device.torchMode;
        
        switch (_input.device.torchMode) {
            case AVCaptureTorchModeAuto:
                break;
            case AVCaptureTorchModeOff:
                torch = AVCaptureTorchModeOn;
                break;
            case AVCaptureTorchModeOn:
                torch = AVCaptureTorchModeOff;
                break;
            default:
                break;
        }
        
        [_input.device lockForConfiguration:nil];
        _input.device.torchMode = torch;
        [_input.device unlockForConfiguration];
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

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                return connection;
            }
        }
    }
    return nil;
}

- (void)captureImage
{
    AVCaptureConnection *stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
        if (!self.continuous) {
            [self stopScan];
        }
        
        if (imageDataSampleBuffer)
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            UIImage *img = [UIImage imageWithData:imageData];
            
            for (LBXScanResult* result in self.arrayResult) {
                
                result.imgScanned = img;
            }
        }
        
        if (self.blockScanResult)
        {
            self.blockScanResult(self.arrayResult);
        }
    }];
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput2:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //识别扫码类型
    for(AVMetadataObject *current in metadataObjects)
    {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]] )
        {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            NSLog(@"type:%@",current.type);
            NSLog(@"result:%@",scannedResult);
            //测试可以同时识别多个二维码
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (!bNeedScanResult) {
        return;
    }
    
    bNeedScanResult = NO;
    
    if (!_arrayResult) {
        
        self.arrayResult = [NSMutableArray arrayWithCapacity:1];
    }
    else
    {
        [_arrayResult removeAllObjects];
    }
    
    metadataObjects = [self transformedCodesFromCodes:metadataObjects];
    
    //识别扫码类型
    for(AVMetadataObject *current in metadataObjects)
    {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]] )
        {
            bNeedScanResult = NO;
            
            NSLog(@"type:%@",current.type);
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            
            NSArray<NSDictionary *> *corners = ((AVMetadataMachineReadableCodeObject *) current).corners;
            CGRect bounds  = ((AVMetadataMachineReadableCodeObject *) current).bounds;
                       
            NSLog(@"corners:%@ bounds:%@",corners,NSStringFromCGRect( bounds ));
            
            if (scannedResult && ![scannedResult isEqualToString:@""])
            {
                LBXScanResult *result = [LBXScanResult new];
                result.strScanned = scannedResult;
                result.strBarCodeType = current.type;
                result.corners = corners;
                result.bounds = bounds;
                                
                [_arrayResult addObject:result];
            }
            //测试可以同时识别多个二维码
        }
    }
    
    if (_arrayResult.count < 1)
    {
        bNeedScanResult = YES;
        return;
    }
    
    if (!_continuous && !_needCodePosion && _isNeedCaputureImage)
    {
        [self captureImage];
    }
    else
    {
        if (!_continuous) {
            [self stopScan];
        }
        
        if (_blockScanResult) {
            _blockScanResult(_arrayResult);
        }
    }
    
    if (_continuous) {
        bNeedScanResult = YES;
    }
}


- (NSArray *)transformedCodesFromCodes:(NSArray *)codes {
    NSMutableArray *transformedCodes = [NSMutableArray array];
    [codes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AVMetadataObject *transformedCode = [self.preview transformedMetadataObjectForMetadataObject:obj];
        [transformedCodes addObject:transformedCode];
    }];
    return [transformedCodes copy];
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
    
    [self.videoPreView addSubview:signView];
    signView.backgroundColor = [UIColor redColor];
    
}
  

/// 条码可以放到到指定位置 （条码在边缘位置，放大及平移后，导致边缘是黑色
/// @param averX averX descriptio
/// @param averY averY description
/// @param bounds bounds description
- (void)videoNearCode:(CGFloat)averX averY:(CGFloat)averY bounds:(CGRect)bounds
{
     CGFloat minSize = MIN(bounds.size.width , bounds.size.height);
    //    CGFloat y = 0;
    //    y = y + zoom > 1 ? zoom : -zoom;
    //    //移动
    //    _videoPreView.transform = CGAffineTransformTranslate(_videoPreView.transform, 0, y);
    
    CGFloat width = _videoPreView.bounds.size.width;
    CGFloat height = _videoPreView.bounds.size.height;
    
    CGFloat centerX = width / 2;
    CGFloat centerY = height / 2;
    
    CGFloat diffX  =  centerX  - averX;
    CGFloat diffY =   centerY - averY;
    
    //计算二维码尺寸，然后计算放大比例
    CGFloat scale  = 100 / minSize * 1.1;
    
    
    NSLog(@"diffX:%f,diffY:%f,scale:%f",diffX,diffY,scale);
    
    diffX = diffX / MAX(1, scale * 0.8);
    diffY = diffY / MAX(1, scale * 0.8);
    
    if (scale > 1) {
        
        [_input.device lockForConfiguration:nil];
        
        AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
        
        
        if (scale < 1 || scale > videoConnection.videoMaxScaleAndCropFactor ) {
            return;
        }
        
        CGFloat zoom = scale / videoConnection.videoScaleAndCropFactor;
        
        videoConnection.videoScaleAndCropFactor = scale;
        
        [_input.device unlockForConfiguration];
        
        CGAffineTransform transform = _videoPreView.transform;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.videoPreView.transform = CGAffineTransformScale(transform, zoom, zoom);
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
             
             self.videoPreView.transform = CGAffineTransformTranslate(self.videoPreView.transform,diffX , diffY);
         }];
    }
}


/**
 @brief  默认支持码的类别
 @return 支持类别 数组
 */
- (NSArray *)defaultMetaDataObjectTypes
{
    NSMutableArray *types = [@[AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeAztecCode] mutableCopy];
    
    if (@available(iOS 8.0, *)) {
        
        [types addObjectsFromArray:@[
                                            AVMetadataObjectTypeInterleaved2of5Code,
                                            AVMetadataObjectTypeITF14Code,
                                            AVMetadataObjectTypeDataMatrixCode
                                            ]];
    }
    
    return types;
}

#pragma mark --识别条码图片
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<LBXScanResult*> *array))block;
{
    if (!image) {
        block(nil);
        return;
    }
    
    if (@available(iOS 8.0, *)) {
        
        CIImage * cimg = [CIImage imageWithCGImage:image.CGImage];
        
        if (!cimg) {
            block(nil);
            return;
        }
        
        NSArray *features = nil;
        @try {
            CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
            features = [detector featuresInImage:cimg];
        } @catch (NSException *exception) {
            block(nil);
            return;
        } @finally {
            
        }
        
        NSMutableArray<LBXScanResult*> *mutableArray = [[NSMutableArray alloc]initWithCapacity:1];
        for (int index = 0; index < [features count]; index ++)
        {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *scannedResult = feature.messageString;
            LBXScanResult *item = [[LBXScanResult alloc]init];
            item.strScanned = scannedResult;
            item.strBarCodeType = CIDetectorTypeQRCode;
            item.imgScanned = image;
            [mutableArray addObject:item];
        }
        if (block) {
            block(mutableArray);
        }
    }else{
        if (block) {
            LBXScanResult *result = [[LBXScanResult alloc]init];
            result.strScanned = @"只支持ios8.0之后系统";
            block(@[result]);
        }
    }
}

#pragma mark --生成条码

//下面引用自 https://github.com/yourtion/Demo_CustomQRCode
#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *aImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return aImage;
}

#pragma mark - QRCodeGenerator
+ (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}


#pragma mark - 生成二维码，背景色及二维码颜色设置
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size
{
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}

//引用自:http://www.jianshu.com/p/e8f7a257b612
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor
{
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:qrColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:bkColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}

+ (UIImage*)createBarCodeWithString:(NSString*)text QRSize:(CGSize)size
{
    
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    
     CIImage *barcodeImage = [filter outputImage];
    
    // 消除模糊
    
    CGFloat scaleX = size.width / barcodeImage.extent.size.width; // extent 返回图片的frame
    
    CGFloat scaleY = size.height / barcodeImage.extent.size.height;
    
    CIImage *transformedImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
    
}




@end
