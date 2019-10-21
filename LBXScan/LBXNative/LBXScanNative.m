


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


@end

@implementation LBXScanNative


- (void)setNeedCaptureImage:(BOOL)isNeedCaputureImg{
    _isNeedCaputureImage = isNeedCaputureImg;
}

- (instancetype)initWithPreView:(UIView*)preView ObjectType:(NSArray*)objType cropRect:(CGRect)cropRect success:(void(^)(NSArray<LBXScanResult*> *array))block{
    if (self = [super init]) {
        [self initParaWithPreView:preView ObjectType:objType cropRect:cropRect success:block];
    }
    return self;
}

- (instancetype)initWithPreView:(UIView*)preView ObjectType:(NSArray*)objType success:(void(^)(NSArray<LBXScanResult*> *array))block{
    if (self = [super init]) {
        [self initParaWithPreView:preView ObjectType:objType cropRect:CGRectZero success:block];
    }
    return self;
}


- (void)initParaWithPreView:(UIView*)videoPreView ObjectType:(NSArray*)objType cropRect:(CGRect)cropRect success:(void(^)(NSArray<LBXScanResult*> *array))block{
    self.arrayBarCodeType = objType;
    self.blockScanResult = block;
    self.videoPreView = videoPreView;
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!_device) {
        return;
    }
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if ( !_input  ){
        return;
    }

    bNeedScanResult = YES;

    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    if (!CGRectEqualToRect(cropRect,CGRectZero)){
        _output.rectOfInterest = cropRect;
    }

    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];

    if ([_session canAddInput:_input]){
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_output]){
        [_session addOutput:_output];
    }

    if ([_session canAddOutput:_stillImageOutput]){
        [_session addOutput:_stillImageOutput];
    }

    
    if (!objType) {
        objType = [self defaultMetaDataObjectTypes];
    }
    
    _output.metadataObjectTypes = objType;
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CGRect frame = videoPreView.frame;
    frame.origin = CGPointZero;
    _preview.frame = frame;
    
    [videoPreView.layer insertSublayer:self.preview atIndex:0];

    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
     CGFloat scale = videoConnection.videoScaleAndCropFactor;

    //先进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
    if (_device.isFocusPointOfInterestSupported &&
        [_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        [_input.device lockForConfiguration:nil];
        [_input.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [_input.device unlockForConfiguration];
    }
}

- (CGFloat)getVideoMaxScale{
    [_input.device lockForConfiguration:nil];
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;
    [_input.device unlockForConfiguration];
    return maxScale;
}

- (void)setVideoScale:(CGFloat)scale{
    [_input.device lockForConfiguration:nil];
    
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    
    CGFloat zoom = scale / videoConnection.videoScaleAndCropFactor;
    
    videoConnection.videoScaleAndCropFactor = scale;
    
    [_input.device unlockForConfiguration];
    
    CGAffineTransform transform = _videoPreView.transform;
    
    _videoPreView.transform = CGAffineTransformScale(transform, zoom, zoom);
}

- (void)setScanRect:(CGRect)scanRect{
    //识别区域设置
    if (_output) {
        _output.rectOfInterest = [self.preview metadataOutputRectOfInterestForRect:scanRect];
    }
}

- (void)changeScanType:(NSArray*)objType{
    _output.metadataObjectTypes = objType;
}

- (void)startScan{
    if ( _input && !_session.isRunning ){
        [_session startRunning];
        bNeedScanResult = YES;
        [_videoPreView.layer insertSublayer:self.preview atIndex:0];
    }
    bNeedScanResult = YES;
}

- (void)stopScan{
    bNeedScanResult = NO;
    if ( _input && _session.isRunning ){
        bNeedScanResult = NO;
        [_session stopRunning];
    }
}

- (void)setTorch:(BOOL)torch {   
    if ([self.input.device hasFlash] && [self.input.device hasTorch]) {
        [self.input.device lockForConfiguration:nil];
        self.input.device.torchMode = torch ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [self.input.device unlockForConfiguration];
    }
}

- (void)changeTorch{
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

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                return connection;
            }
        }
    }
    return nil;
}

- (void)captureImage{
    AVCaptureConnection *stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    __weak typeof(self) weakSelf = self;
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){
         [weakSelf stopScan];
         if (imageDataSampleBuffer){
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *img = [UIImage imageWithData:imageData];
             for (LBXScanResult* result in _arrayResult) {
                 result.imgScanned = img;
             }
         }
         if (_blockScanResult){
             _blockScanResult(_arrayResult);
         }
     }];
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput2:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //识别扫码类型
    for(AVMetadataObject *current in metadataObjects){
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]] ){
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
        }
    }
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (!bNeedScanResult) {
        return;
    }
    bNeedScanResult = NO;
    
    if (!_arrayResult) {
        self.arrayResult = [NSMutableArray arrayWithCapacity:1];
    }else{
        [_arrayResult removeAllObjects];
    }
    //识别扫码类型
    for(AVMetadataObject *current in metadataObjects){
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
            bNeedScanResult = NO;
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            
            if (scannedResult && ![scannedResult isEqualToString:@""]) {
                LBXScanResult *result = [LBXScanResult new];
                result.strScanned = scannedResult;
                result.strBarCodeType = current.type;
                
                [_arrayResult addObject:result];
            }
        }
    }
    if (_arrayResult.count < 1){
        bNeedScanResult = YES;
        return;
    }
    if (_isNeedCaputureImage){
        [self captureImage];
    }else{
        [self stopScan];
        if (_blockScanResult) {
            _blockScanResult(_arrayResult);
        }
    }
}

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
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_0){
        [types addObjectsFromArray:@[AVMetadataObjectTypeInterleaved2of5Code,
                                     AVMetadataObjectTypeITF14Code,
                                     AVMetadataObjectTypeDataMatrixCode]];
    }
    
    return types;
}

#pragma mark --识别条码图片
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<LBXScanResult*> *array))block {
    if ([[[UIDevice currentDevice]systemVersion]floatValue] < 8.0 || !image){
        if (block) {
            LBXScanResult *result = [[LBXScanResult alloc]init];
            result.strScanned = @"只支持ios8.0之后系统";
            block(@[result]);
        }
        return;
    }
    
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSMutableArray<LBXScanResult*> *mutableArray = [[NSMutableArray alloc]initWithCapacity:1];
    if (features.count > 0) {
        for (CIQRCodeFeature *feature in features) {
            NSString *scannedResult = feature.messageString;
            LBXScanResult *item = [[LBXScanResult alloc]init];
            item.strScanned = scannedResult;
            item.strBarCodeType = CIDetectorTypeQRCode;
            item.imgScanned = image;
            [mutableArray addObject:item];
        }
    }
    if (block) {
        block(mutableArray);
    }
}


#pragma mark - 生成二维码/条形码
//! 生成二维码
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size {
    
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator" withInputParameters:@{@"inputMessage": codeData, @"inputCorrectionLevel": @"H"}];
    UIImage *codeImage = [LBXScanNative scaleImage:filter.outputImage toSize:size];
    
    return codeImage;
}

//! 生成二维码+logo
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(nonnull UIImage *)logo {
    
    UIImage *codeImage = [LBXScanNative generateQRCode:code size:size];
    codeImage = [LBXScanNative combinateCodeImage:codeImage andLogo:logo];
    
    return codeImage;
}

//! 生成条形码
+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size {
    
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator" withInputParameters:@{@"inputMessage": codeData, @"inputQuietSpace": @.0}];
    UIImage *codeImage = [LBXScanNative scaleImage:filter.outputImage toSize:size];
    
    return codeImage;
}


#pragma mark - Util functions
// 缩放图片(生成高质量图片）
+ (UIImage *)scaleImage:(CIImage *)image toSize:(CGSize)size {
    
    //! 将CIImage转成CGImageRef
    CGRect integralRect = image.extent;// CGRectIntegral(image.extent);// 将rect取整后返回，origin取舍，size取入
    CGImageRef imageRef = [[CIContext context] createCGImage:image fromRect:integralRect];
    
    //! 创建上下文
    CGFloat sideScale = fminf(size.width / integralRect.size.width, size.width / integralRect.size.height) * [UIScreen mainScreen].scale;// 计算需要缩放的比例
    size_t contextRefWidth = ceilf(integralRect.size.width * sideScale);
    size_t contextRefHeight = ceilf(integralRect.size.height * sideScale);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, contextRefWidth, contextRefHeight, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);// 灰度、不透明
    CGColorSpaceRelease(colorSpaceRef);
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);// 设置上下文无插值
    CGContextScaleCTM(contextRef, sideScale, sideScale);// 设置上下文缩放
    CGContextDrawImage(contextRef, integralRect, imageRef);// 在上下文中的integralRect中绘制imageRef
    CGImageRelease(imageRef);
    
    //! 从上下文中获取CGImageRef
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    
    //! 将CGImageRefc转成UIImage
    UIImage *scaledImage = [UIImage imageWithCGImage:scaledImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(scaledImageRef);
    
    return scaledImage;
}

// 合成图片（code+logo）
+ (UIImage *)combinateCodeImage:(UIImage *)codeImage andLogo:(UIImage *)logo {
    
    UIGraphicsBeginImageContextWithOptions(codeImage.size, YES, [UIScreen mainScreen].scale);
    
    // 将codeImage画到上下文中
    [codeImage drawInRect:(CGRect){.0, .0, codeImage.size.width, codeImage.size.height}];
    
    // 定义logo的绘制参数
    CGFloat logoSide = fminf(codeImage.size.width, codeImage.size.height) / 4;
    CGFloat logoX = (codeImage.size.width - logoSide) / 2;
    CGFloat logoY = (codeImage.size.height - logoSide) / 2;
    CGRect logoRect = (CGRect){logoX, logoY, logoSide, logoSide};
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:logoRect cornerRadius:logoSide / 5];
    [cornerPath setLineWidth:2.0];
    [[UIColor whiteColor] set];
    [cornerPath stroke];
    [cornerPath addClip];
    
    // 将logo画到上下文中
    [logo drawInRect:logoRect];
    
    // 从上下文中读取image
    codeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return codeImage;
}


@end
