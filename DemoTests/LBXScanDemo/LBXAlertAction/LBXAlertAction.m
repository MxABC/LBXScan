//
//  LBXAlertAction.m
//
//
//  Created by lbxia on 15/10/27.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXAlertAction.h"
#import <UIKit/UIKit.h>
#import "UIAlertView+LBXAlertAction.h"
#import "UIActionSheet+LBXAlertAction.h"

@implementation LBXAlertAction


+ (BOOL)isIosVersion8AndAfter
{
   // return NO;
    
    
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ;
}

+ (void)showAlertWithTitle:(NSString*)title msg:(NSString*)message chooseBlock:(void (^)(NSInteger buttonIdx))block  buttonsStatement:(NSString*)cancelString, ...
{
    
    NSMutableArray* argsArray = [[NSMutableArray alloc] initWithCapacity:2];
    [argsArray addObject:cancelString];
    id arg;
    va_list argList;
    if(cancelString)
    {
        va_start(argList,cancelString);
        while ((arg = va_arg(argList,id)))
        {
            [argsArray addObject:arg];
        }
        va_end(argList);
    }
    
    if ( [LBXAlertAction isIosVersion8AndAfter])
    {
        //UIAlertController style
        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        for (int i = 0; i < [argsArray count]; i++)
        {
            UIAlertActionStyle style =  (0 == i)? UIAlertActionStyleCancel: UIAlertActionStyleDefault;
            // Create the actions.
            UIAlertAction *action = [UIAlertAction actionWithTitle:[argsArray objectAtIndex:i] style:style handler:^(UIAlertAction *action) {
                if (block) {
                    block(i);
                }
            }];
            [alertController addAction:action];
        }
        
        [[LBXAlertAction getTopViewController] presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    if (argsArray.count > 7)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"" message:@"UIAlertView按钮过多，请修改源代码" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //UIAlertView style
    
    UIAlertView* alertView = nil;
    
    switch ([argsArray count])
    {
        case 1:
        {
            alertView = [[UIAlertView alloc]initWithTitle:title message:message
                                                 delegate:nil cancelButtonTitle:cancelString otherButtonTitles:nil, nil];
        }
            break;
        case 2:
        {
            alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelString
                                        otherButtonTitles:argsArray[1], nil];
        }
            break;
        case 3:
        {
            alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelString
                                        otherButtonTitles:argsArray[1],argsArray[2], nil];
        }
            break;
        case 4:
        {
            alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelString
                                        otherButtonTitles:argsArray[1],argsArray[2],argsArray[3], nil];
        }
            break;
        case 5:
        {
            alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelString
                                        otherButtonTitles:argsArray[1],argsArray[2],argsArray[3],argsArray[4], nil];
        }
            break;
        case 6:
        {
            alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelString
                                        otherButtonTitles:argsArray[1],argsArray[2],argsArray[3],argsArray[4], argsArray[5],nil];
        }
            break;
        case 7:
        {
            alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelString
                                        otherButtonTitles:argsArray[1],argsArray[2],argsArray[3],argsArray[4], argsArray[5],argsArray[6],nil];
        }
            break;
            
        default:
            break;
    }

   
    
    [alertView showWithBlock:^(NSInteger buttonIdx)
    {
        
        block(buttonIdx);
    }];
    
    

}


+ (UIViewController*)getTopViewController
{
    UIViewController *result = nil;
    
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}



+ (void)showActionSheetWithTitle:(NSString*)title message:(NSString*)message chooseBlock:(void (^)(NSInteger buttonIdx))block
               cancelButtonTitle:(NSString*)cancelString destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitle:(NSString*)otherButtonTitle,...
{
    NSMutableArray* argsArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    
    if (cancelString) {
        [argsArray addObject:cancelString];
    }
    
    if (destructiveButtonTitle) {
        [argsArray addObject:destructiveButtonTitle];
    }

   
    id arg;
    va_list argList;
    if(otherButtonTitle)
    {
        [argsArray addObject:otherButtonTitle];
        va_start(argList,otherButtonTitle);
        while ((arg = va_arg(argList,id)))
        {
            [argsArray addObject:arg];
        }
        va_end(argList);
    }
    
    if (argsArray.count < 2) {
        return;
    }
    
    if ( [LBXAlertAction isIosVersion8AndAfter] )
    {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        for (int i = 0; i < [argsArray count]; i++)
        {
            UIAlertActionStyle style =  (0 == i)? UIAlertActionStyleCancel: UIAlertActionStyleDefault;
            
            if (1==i && destructiveButtonTitle) {
                
                style = UIAlertActionStyleDestructive;
            }
            
            // Create the actions.
            UIAlertAction *action = [UIAlertAction actionWithTitle:[argsArray objectAtIndex:i] style:style handler:^(UIAlertAction *action) {
                if (block) {
                    block(i);
                }
            }];
            [alertController addAction:action];
        }
        
        [[LBXAlertAction getTopViewController] presentViewController:alertController animated:YES completion:nil];
    
        return;
    }
   
    
    
    //UIActionSheet
    UIView *view = [self getTopViewController].view;
    UIActionSheet *sheet = nil;
    
    NSInteger firstIdx = destructiveButtonTitle ? 2:1;
    NSInteger otherButtonCount = argsArray.count - 1 - (destructiveButtonTitle ? 1:0);
    
    
    if (otherButtonCount > 6) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"items过多，请修改源代码" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    
    switch (otherButtonCount) {
        case 1:
            sheet = [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle
                                      otherButtonTitles:argsArray[firstIdx], nil];
            break;
        case 2:
            sheet = [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle
                                      otherButtonTitles:argsArray[firstIdx],argsArray[firstIdx+1], nil];
            break;
        case 3:
            sheet = [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle
                                      otherButtonTitles:argsArray[firstIdx],argsArray[firstIdx+1],argsArray[firstIdx+2], nil];
            break;
        case 4:
            sheet = [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle
                                      otherButtonTitles:argsArray[firstIdx],argsArray[firstIdx+1],argsArray[firstIdx+2],argsArray[firstIdx+3], nil];
            break;
        case 5:
            sheet = [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle
                                      otherButtonTitles:argsArray[firstIdx],argsArray[firstIdx+1],argsArray[firstIdx+2],argsArray[firstIdx+3],argsArray[firstIdx+4], nil];
            break;
        case 6:
            sheet = [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle
                                      otherButtonTitles:argsArray[firstIdx],argsArray[firstIdx+1],argsArray[firstIdx+2],argsArray[firstIdx+3],argsArray[firstIdx+4],argsArray[firstIdx+5], nil];
            break;
            
        default:
            break;
    }
    
//    
    __block NSInteger maxIndex = otherButtonCount + (destructiveButtonTitle != nil ? 1:0)  ;
    
    [sheet showInView:view block:^(NSInteger buttonIdx)
     {
         NSInteger idx = buttonIdx;
         if (maxIndex == buttonIdx) {
             idx = 0;
         }
         else
         {
             idx = buttonIdx+1;
         }
         
         if (block) {
             block(idx);
         }
     }];
}


@end
