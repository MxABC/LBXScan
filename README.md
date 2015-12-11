


# LBXScan

  

---

Swift Version <img src="http://github.fabriziobrancati.com/bfkit/resources/swift-icon.png" height="25" width="25">
=====
If you are looking for Swift version check it out here: **[swiftScan](https://github.com/MxABC/swiftScan)**


## 介绍
**iOS扫码封装 objective-c版本 封装ios系统API和ZXing**
- 扫码界面效果封装
- 二维码、条形码
- 相册获取图片后识别

**模仿其他app**
- 模仿QQ扫码界面
- 支付宝扫码框效果
- 微信扫码框效果

**其他设置参数自定义效果**

- 扫码框周围区域背景色可设置
- 扫码框颜色可也设置
- 扫码框4个角的颜色可设置、大小可设置
- 可设置只识别扫码框内的图像区域
- 可设置扫码成功后，获取当前图片
- 动画效果选择:  线条上下移动、网格形式移动、中间线条不移动(一般扫码条形码的效果)

###
##  如果好用请帮忙右上角 star 支持一下

# 安装

### Installation with CocoaPods

```ruby
platform :ios, '6.0'
pod 'LBXScan',:git=>'https://github.com/MxABC/LBXScan.git'
```

### 手动安装 
下载后将LBXScan文件夹copy到工程中
添加预编译 pch文件 （如何添加请百度）
并在其中添加
```objective-c
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
```
否则编译会报许多错误


# Demo测试
将工程下载下来后，打开DemoTests中 LBXScanDemo.xcodeproj
xcode版本:xcode7.1


# 界面效果

(加载速度慢，可刷新网页)

![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page1.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page2.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page3.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page11.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page4.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page5.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page6.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page7.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page8.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page9.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page12.png)
![image](https://github.com/MxABC/LBXScan/blob/master/ScreenShots/page10.png)

