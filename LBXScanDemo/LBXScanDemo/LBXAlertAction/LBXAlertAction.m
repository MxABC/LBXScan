//
//  LBXAlertAction.m
//
//  https://github.com/MxABC/LBXAlertAction
//  Created by lbxia on 15/10/27.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXAlertAction.h"
#import <UIKit/UIKit.h>
#import "UIAlertView+LBXAlertAction.h"
#import "UIActionSheet+LBXAlertAction.h"
#import "UIWindow+LBXHierarchy.h"

@implementation LBXAlertAction


+ (BOOL)isIosVersion8AndAfter
{  
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ;
}

+ (void)showAlertWithTitle:(NSString*)title msg:(NSString*)message buttonsStatement:(NSArray<NSString*>*)arrayItems chooseBlock:(void (^)(NSInteger buttonIdx))block
{
    
    NSMutableArray* argsArray = [[NSMutableArray alloc] initWithArray:arrayItems];
 
    
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
    
    //UIAlertView style
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:argsArray[0] otherButtonTitles:nil, nil];
    
    [argsArray removeObject:argsArray[0]];
    for (NSString *buttonTitle in argsArray) {
        
        NSLog(@"buttonTitle:%@",buttonTitle);
        [alertView addButtonWithTitle:buttonTitle];
    }
    
    [alertView showWithBlock:^(NSInteger buttonIdx)
     {
         
         block(buttonIdx);
     }];
}


+ (UIViewController*)getTopViewController
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    return window.currentViewController;
}



+ (void)showActionSheetWithTitle:(NSString*)title
                         message:(NSString*)message
               cancelButtonTitle:(NSString*)cancelString
          destructiveButtonTitle:(NSString*)destructiveButtonTitle
                otherButtonTitle:(NSArray<NSString*>*)otherButtonArray
                     chooseBlock:(void (^)(NSInteger buttonIdx))block
{
    NSMutableArray* argsArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    
    if (cancelString) {
        [argsArray addObject:cancelString];
    }
    if (destructiveButtonTitle) {
        [argsArray addObject:destructiveButtonTitle];
    }
  
    [argsArray addObjectsFromArray:otherButtonArray];
        
    if ( [LBXAlertAction isIosVersion8AndAfter])
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
    
    NSInteger count = argsArray.count;
    
    if (cancelString) {
        [argsArray removeObject:cancelString];
    }
    if (destructiveButtonTitle) {
        [argsArray removeObject:destructiveButtonTitle];
    }
    if (argsArray.count == 0)
    {
        sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil, nil];
    }
    
    switch (argsArray.count) {
        case 0:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil, nil];
            break;
            
        case 1:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:argsArray[0], nil];
            break;
            
        case 2:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:argsArray[0],argsArray[1], nil];
            break;
        case 3:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:argsArray[0],argsArray[1],argsArray[2], nil];
            break;
            
        case 4:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:argsArray[0],argsArray[1],argsArray[2],argsArray[3], nil];
            break;
            
        case 5:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:argsArray[0],argsArray[1],argsArray[2],argsArray[3],argsArray[4], nil];
            break;
            
        case 6:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:argsArray[0],argsArray[1],argsArray[2],argsArray[3],argsArray[4],argsArray[5], nil];
            break;
            
        case 7:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:argsArray[0],argsArray[1],argsArray[2],argsArray[3],argsArray[4],argsArray[5],argsArray[6], nil];
            break;
            
        case 8:
            sheet =  [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelString destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:argsArray[0],argsArray[1],argsArray[2],argsArray[3],argsArray[4],argsArray[5],argsArray[6],argsArray[7], nil];
            break;
            
        default:
            break;
    }
    
    [sheet showInView:view block:^(NSInteger buttonIdx,NSString* buttonTitle)
     {
         NSInteger idx = buttonIdx;
         
         if (idx == count -1) {
             idx = 0;
         }
         else
         {
             ++idx;
         }
         
//         NSLog(@"idx:%ld",idx);
         
         if (block) {
             block(idx);
         }
     }];
    
    
}



@end
