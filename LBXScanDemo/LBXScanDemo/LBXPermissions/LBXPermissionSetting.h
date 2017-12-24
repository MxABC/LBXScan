//
//  LBXPermissionSetting.h
//  Demo
//
//  Created by lbx on 2017/12/8.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBXPermissionSetting : NSObject

#pragma mark- guide user to show App privacy setting
/**
 show App privacy settings
 */
+ (void)displayAppPrivacySettings;



/**
 show dialog to guide user to show App privacy setting
 
 @param title title
 @param message privacy message
 @param cancel cancel button text
 @param setting setting button text,if user tap this button ,will show App privacy setting
 */
+ (void)showAlertToDislayPrivacySettingWithTitle:(NSString*)title
                                             msg:(NSString*)message
                                          cancel:(NSString*)cancel
                                         setting:(NSString*)setting;

@end
