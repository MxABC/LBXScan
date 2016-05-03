##UIAlertView、UIActionSheet、UIAlertController封装 objective-c版本

###安装
####cocoapods安装

```ruby
platform :ios, '7.0'
pod 'LBXAlertAction'
```

####手动导入：
将LBXAlertAction文件夹中的所有文件拽入项目中
导入主头文件：#import "LBXAlertAction.h"

##使用说明

###UIAlertView形式示例

```obj-c
[LBXAlertAction showAlertWithTitle:@"标题" msg:@"提示消息内容" chooseBlock:^(NSInteger idx)
{
//取消为0，后面的按顺序从1开始...
NSLog(@"%ld",idx);

}buttonsStatement:@"取消",@"确认1",@"确认2",@"确认3",@"确认4",@"确认5",@"确认6",nil];
```

###UIActionSheet形式示例

```obj-c
[LBXAlertAction showActionSheetWithTitle:@"标题" message:@"ios8系统之后才会显示本消息内容" chooseBlock:^(NSInteger idx)
{
//取消为0，destructiveButtonTitle从1开始，如果destructiveButtonTitle输入为nil，则otherButtonTitle从1开始，否则从2开始
NSLog(@"%ld",idx);
}cancelButtonTitle:@"取消" destructiveButtonTitle:@"特殊标记的按钮(显示文字颜色:红色)" otherButtonTitle:@"items1",@"items2",@"items3",nil];
```
