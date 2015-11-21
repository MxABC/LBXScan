//
//  LBXAlertAction.h
//
//  github:https://github.com/MxABC/LBXAlertAction
//
//  Created by lbxia on 15/10/27.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBXAlertAction : NSObject



/**
 @brief  模式对话框，选择一项（UIAlertView与与UIAlertController封装，根据不同ios版本对应选择调用方法）
 @param title        标题
 @param msg          提示内容
 @param block        返回点击的按钮index
 @param cancelString 取消按钮 文本，必须以nil结束
 */
+ (void)showAlertWithTitle:(NSString*)title msg:(NSString*)msg chooseBlock:(void (^)(NSInteger buttonIdx))block  buttonsStatement:(NSString*)cancelString, ...;

//增加延时消失入口



/**
 @brief  显示UIActionSheet模式对话框，UIActionSheet与UIAlertController封装，根据不同ios版本对应选择调用方法。
 @param title                  标题
 @param message                消息内容
 @param block                  返回block,buttonIdx:destructiveButtonTitle分别为0
                               otherButtonTitle从后面开始，如果destructiveButtonTitle没有，buttonIndex1开始，反之2开始，cancel是最后一个
 @param cancelString           取消文本
 @param destructiveButtonTitle 特殊标记按钮，默认红色
 @param otherButtonTitle       其他选项,必须以nil结束
 */
+ (void)showActionSheetWithTitle:(NSString*)title message:(NSString*)message chooseBlock:(void (^)(NSInteger buttonIdx))block
               cancelButtonTitle:(NSString*)cancelString destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitle:(NSString*)otherButtonTitle,...;


@end
