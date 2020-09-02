//
//  TKTool.m
//  HandKooPDSDKDemo
//
//  Created by lbxia on 2018/5/7.
//  Copyright © 2018年 HDTK. All rights reserved.
//

#import "LBXToast.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Toast/UIView+Toast.h>


@implementation LBXToast

+ (void)showToastWithMessage:(NSString*)message
{
    if (message == nil) {
        message = @"";
    }
    //tip
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    [window makeToast:message
             duration:2
             position:CSToastPositionCenter];
}

+ (UIViewController*)getTopViewController
{
    return [self currentTopViewController];
}




#pragma mark- Get TOP VC
+ (UIViewController*)topRootController
{
    UIViewController *topController = [[UIApplication sharedApplication].delegate.window rootViewController];
    
    //  Getting topMost ViewController
    while ([topController presentedViewController])
        topController = [topController presentedViewController];
    
    //  Returning topMost ViewController
    return topController;
}

+ (UIViewController*)presentedWithController:(UIViewController*)vc
{
    while ([vc presentedViewController])
        vc = vc.presentedViewController;
    return vc;
}


+ (UIViewController*)currentTopViewController
{
    UIViewController *currentViewController = [self topRootController];
    
    if ([currentViewController isKindOfClass:[UITabBarController class]]
        && ((UITabBarController*)currentViewController).selectedViewController != nil )
    {
        currentViewController = ((UITabBarController*)currentViewController).selectedViewController;
    }
    
    currentViewController = [self presentedWithController:currentViewController];
    
    while ([currentViewController isKindOfClass:[UINavigationController class]]
           && [(UINavigationController*)currentViewController topViewController])
    {
        currentViewController = [(UINavigationController*)currentViewController topViewController];
        currentViewController = [self presentedWithController:currentViewController];
        
    }
    
    
    currentViewController = [self presentedWithController:currentViewController];
    
    
    return currentViewController;
}

@end
