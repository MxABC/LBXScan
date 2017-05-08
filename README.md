

# iOS 二维码、条形码 
[![Platform](https://img.shields.io/badge/platform-iOS-red.svg)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-OC-yellow.svg?style=flat
             )](https://en.wikipedia.org/wiki/Objective-C)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://mit-license.org)
![CocoaPods Version](https://img.shields.io/badge/pod-v1.2.0-brightgreen.svg)

[swift verison 点这里](https://github.com/MxABC/swiftScan)
### iOS扫码封装
- 扫码识别封装: 系统API(AVFoundation)、ZXing、ZBar
- 扫码界面效果封装
- 二维码、条形码
- 相册获取图片后识别

### 设置参数自定义效果
- 扫码框周围区域背景色可设置
- 扫码框颜色可也设置
- 扫码框4个角的颜色可设置、大小可设置
- 可设置只识别扫码框内的图像区域
- 可设置扫码成功后，获取当前图片
- 动画效果选择:  线条上下移动、网格形式移动、中间线条不移动(一般扫码条形码的效果)

### 模仿其他app(通过设置参数即可完成)
- 模仿QQ扫码界面
- 支付宝扫码框效果
- 微信扫码框效果

### Installation with CocoaPods
> 可独立安装某一功能,ZXing已经下载到本工程，解决之前版本下载速度慢的问题


***
- 安装所有库包括UI 

```ruby
 pod 'LBXScan', '~> 2.0'
```
建议按下面这样分组写，安装好后按文件夹分组，否则所有文件在一个文件夹里，很乱

```ruby
pod 'LBXScan/LBXNative','~> 2.0'
pod 'LBXScan/LBXZXing','~> 2.0'
pod 'LBXScan/LBXZBar','~> 2.0'
pod 'LBXScan/UI','~> 2.0'
```

- 只安装系统原生API封装库  

```ruby
pod 'LBXScan/LBXNative','~> 2.0'
```

- 只安装ZXing封装库 

```ruby
pod 'LBXScan/LBXZXing','~> 2.0'
```

- 只安装ZBar封装库 

```ruby
pod 'LBXScan/LBXZBar','~> 2.0'
```

- 只安装UI

```ruby
pod 'LBXScan/UI','~> 2.0'
```
- 安装任意组合

> 你可以通过上面的安装方式，安装任意组合


### Demo测试
- xcode版本:xcode8.3
- 将工程下载下来，打开DemoTests中 LBXScanDemo.xcworkspace
- Demo提供了选择对应库进行扫码识别、相册选择图片识别、生成条码等测试

### UI DIY参数介绍
```obj-c
- (LBXScanViewStyle*)DIY
{
//设置扫码区域参数
LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];

//扫码框中心位置与View中心位置上移偏移像素(一般扫码框在视图中心位置上方一点)
style.centerUpOffset = 44;



//扫码框周围4个角的类型设置为在框的上面,可自行修改查看效果
style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_On;

//扫码框周围4个角绘制线段宽度
style.photoframeLineW = 6;

//扫码框周围4个角水平长度
style.photoframeAngleW = 24;

//扫码框周围4个角垂直高度
style.photoframeAngleH = 24;


//动画类型：网格形式，模仿支付宝
style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;

//动画图片:网格图片
style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"];;

//扫码框周围4个角的颜色
style.colorAngle = [UIColor colorWithRed:65./255. green:174./255. blue:57./255. alpha:1.0];

//是否显示扫码框
style.isNeedShowRetangle = YES;
//扫码框颜色
style.colorRetangleLine = [UIColor colorWithRed:247/255. green:202./255. blue:15./255. alpha:1.0];

//非扫码框区域颜色(扫码框周围颜色，一般颜色略暗)
//必须通过[UIColor colorWithRed: green: blue: alpha:]来创建，内部需要解析成RGBA
style.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

return style;
}
```


# 界面效果
![image](https://github.com/MxABC/Resource/blob/master/scan12.gif)

