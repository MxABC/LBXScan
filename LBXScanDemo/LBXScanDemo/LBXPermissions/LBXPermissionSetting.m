//
//  LBXPermissionSetting.m
//  Demo
//
//  Created by lbx on 2017/12/8.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXPermissionSetting.h"
#import <UIKit/UIKit.h>

@implementation LBXPermissionSetting

#pragma mark-  disPlayAppPrivacySetting

+ (void)displayAppPrivacySettings
{
    if (@available(iOS 8,*))
    {
        if (UIApplicationOpenSettingsURLString != NULL)
        {
            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if (@available(iOS 10,*)) {
                [[UIApplication sharedApplication]openURL:appSettings options:@{} completionHandler:^(BOOL success) {
                }];
            }
            else
            {
                [[UIApplication sharedApplication]openURL:appSettings];
            }
        }
    }
}

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
                                         setting:(NSString*)setting
{
    [self showAlertToDislayPrivacySettingWithTitle:title msg:message cancel:cancel setting:setting completion:nil];
}

/**
 show dialog to guide user to show App privacy setting
 
 @param title title
 @param message privacy message
 @param cancel cancel button text
 @param setting setting button text,if user tap this button ,will show App privacy setting
 @param completion user has been choosed
 */
+ (void)showAlertToDislayPrivacySettingWithTitle:(NSString*)title
                                             msg:(NSString*)message
                                          cancel:(NSString*)cancel
                                         setting:(NSString*)setting
                                      completion:(void(^)(void))completion
{
    if (@available(iOS 8,*)) {
        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        //cancel
        UIAlertAction *action = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion) {
                completion();
            }
        }];
        [alertController addAction:action];
                
        //ok
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:setting style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            if (completion) {
                completion();
            }
            
            [self displayAppPrivacySettings];
        }];
        [alertController addAction:okAction];
        
        [[self currentTopViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

+ (UIViewController*)currentTopViewController
{
    UIViewController *currentViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while ([currentViewController presentedViewController])    currentViewController = [currentViewController presentedViewController];
    
    if ([currentViewController isKindOfClass:[UITabBarController class]]
        && ((UITabBarController*)currentViewController).selectedViewController != nil )
    {
        currentViewController = ((UITabBarController*)currentViewController).selectedViewController;
    }
    
    while ([currentViewController isKindOfClass:[UINavigationController class]]
           && [(UINavigationController*)currentViewController topViewController])
    {
        currentViewController = [(UINavigationController*)currentViewController topViewController];
    }
    
    return currentViewController;
}

@end
