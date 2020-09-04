

# iOS 二维码、条形码 
[![Platform](https://img.shields.io/badge/platform-iOS-red.svg)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-OC-yellow.svg?style=flat
             )](https://en.wikipedia.org/wiki/Objective-C)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://mit-license.org)
![CocoaPods Version](https://img.shields.io/badge/pod-v2.4-brightgreen.svg)

[swift版本 点这里](https://github.com/MxABC/swiftScan)

[DIY参数理解参考工具点这里](https://github.com/MxABC/LBXScanUITool)

QQ交流群: 522806629 

- [iOS扫码封装](#iOS扫码封装)
- [DIY](#设置参数自定义效果)
- [模仿其他app](#模仿其他app(通过设置参数即可完成))
- [DIY参数介绍](#DIY参数介绍)
- [界面效果](#界面效果)


### iOS扫码封装
- 扫码识别封装: 系统API(AVFoundation)、ZXing、ZBar
- 扫码界面效果封装
- 二维码、条形码
- 相册获取图片后识别
- 系统API及ZXing支持界面动态横竖屏旋转，设置扫码对象接口，正确显示相机预览
- 支持连续扫码(可通过参数设置)

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

### 历史版本
#### 2.4
- ZBarSDK 删除UIWebView，相机采集分辨率设置高分辨率[LBXZBarSDK](https://github.com/MxABC/LBXZBarSDK)
- 当前库删除了ZBarSDK了依赖，需要ZBAR的，可单独一行pod
- 原生和ZXing扫码后获取条码位置坐标返回，Demo中标记条码位置坐标
- 原生扫码，支持相机预览放大(见Demo)
- Demo中新增原生、ZXing、ZBar 三个库对应的扫码控制器，可根据需要定制修改

#### 2.3 
- 修改ZXing内存修改bug,完善ZXing扫码完成后，内存释放
- Demo相机和相册权限获取代码优化
- ZBar修改参数支持ITF-14
- 扫码启动相机提示优化，放置中间位置

#### 2.2 
- 可分库下载(native、ZXing、ZBar)

#### 1.x 
- 1.x

### Installation with CocoaPods
> 可独立安装某一功能,ZXing已经下载到本工程，解决之前版本下载速度慢的问题


***
- 安装所有库包括UI(不包含ZBar) 

```ruby
 pod 'LBXScan', '~> 2.4'
```
建议按下面这样分组写，安装好后按文件夹分组，否则所有文件在一个文件夹里，很乱

```ruby
pod 'LBXScan/LBXNative','~> 2.4'
pod 'LBXScan/LBXZXing','~> 2.4'
pod 'LBXScan/UI','~> 2.4'
```

需要ZBar支持的

```ruby
pod 'LBXZBarSDK','~> 1.3'
```

- 只安装系统原生API封装库  

```ruby
pod 'LBXScan/LBXNative','~> 2.4'
```

- 只安装ZXing封装库 

```ruby
pod 'LBXScan/LBXZXing','~> 2.4'
```

- 只安装ZBar封装库 

```ruby
pod 'LBXZBarSDK','~> 1.3'
```

- 只安装UI

```ruby
pod 'LBXScan/UI','~> 2.3'
```
- 安装任意组合

> 你可以通过上面的安装方式，安装任意组合


### Demo测试
- xcode版本:xcode9.2
- 将工程下载下来，打开DemoTests中 LBXScanDemo.xcworkspace
- Demo提供了选择对应库进行扫码识别、相册选择图片识别、生成条码等测试

### UI DIY参数介绍

辅助理解参考工具请看：[LBXScanUITool](https://github.com/MxABC/LBXScanUITool)


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

### 扫码控制器示例代码(在Demo代码中,可根据需要自行修改)
- 基类控制器 
`LBXScanBaseViewController`

- Native(原生扫码)扫码控制器

```
LBXScanNativeViewController
QQScanNativeViewController
```

- ZXing扫码控制器

```
LBXScanZXingViewController
QQScanZXingViewController
```

- ZBar扫码控制器

```
LBXScanZBarViewController
QQScanZBarViewController
```

### 使用扫码控制器LBXScanViewController(API_DEPRECATED，不支持ZBar)

如果你需要使用提供的扫码控制器LBXScanViewController(包含在UI模块中)，需要在你的工程中添加预编译头文件xx.pch文件或对应调用的地方添加对应的宏(LBXScanViewController代码包含了所有的库和UI，所以需要你根据你自己下载的库的情况，对应添加宏)

例如，当前工程Demo中PrefixHeader.pch，我的demo中下载了所有的模块，所以下面定义了各个模块的宏

```

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define LBXScan_Define_Native  //下载了native模块
#define LBXScan_Define_ZXing   //下载了ZXing模块
#define LBXScan_Define_ZBar   //下载了ZBar模块
#define LBXScan_Define_UI     //下载了界面模块
#endif

```

扫码结果处理，可以通过实现委托方法 scanResultWithArray 或继承控制器LBXScanViewController，然后override方法scanResultWithArray即可


# 界面效果
![image](https://upload-images.jianshu.io/upload_images/4952852-e558da2ffb6c9fbe.gif?imageMogr2/auto-orient/strip)

支持动态横竖屏

![scanrotate.gif](https://upload-images.jianshu.io/upload_images/4952852-e859fcfd3f41bfc0.gif?imageMogr2/auto-orient/strip)

# 打赏作者

如果LBXScan在开发中有帮助到你、如果你需要技术支持，都可以拼命打赏我！

![支付.jpg](https://upload-images.jianshu.io/upload_images/4952852-f108de0181a55ee0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

