//
//  LBXPermission.m
//  LBXKits
//
//  Created by lbx on 2017/9/7.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXPermission.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>


typedef void(^completionPermissionHandler)(BOOL granted,BOOL firstTime);


@implementation LBXPermission


+ (BOOL)isServicesEnabledWithType:(LBXPermissionType)type
{
    if (type == LBXPermissionType_Location)
    {
        SEL sel = NSSelectorFromString(@"isServicesEnabled");
        BOOL ret  = ((BOOL *(*)(id,SEL))objc_msgSend)( NSClassFromString(@"LBXPermissionLocation"), sel);
        return ret;
    }
    return YES;
}

+ (BOOL)isDeviceSupportedWithType:(LBXPermissionType)type
{
    if (type == LBXPermissionType_Health) {
        
        SEL sel = NSSelectorFromString(@"isHealthDataAvailable");
        BOOL ret  = ((BOOL *(*)(id,SEL))objc_msgSend)( NSClassFromString(@"LBXPermissionHealth"), sel);
        return ret;
    }
    return YES;
}

+ (BOOL)authorizedWithType:(LBXPermissionType)type
{
    SEL sel = NSSelectorFromString(@"authorized");
    
    NSString *strClass = nil;
    switch (type) {
        case LBXPermissionType_Location:
            strClass = @"LBXPermissionLocation";
            break;
        case LBXPermissionType_Camera:
            strClass = @"LBXPermissionCamera";
            break;
        case LBXPermissionType_Photos:
            strClass = @"LBXPermissionPhotos";
            break;
        case LBXPermissionType_Contacts:
            strClass = @"LBXPermissionContacts";
            break;
        case LBXPermissionType_Reminders:
            strClass = @"LBXPermissionReminders";
            break;
        case LBXPermissionType_Calendar:
            strClass = @"LBXPermissionCalendar";
            break;
        case LBXPermissionType_Microphone:
            strClass = @"LBXPermissionMicrophone";
            break;
        case LBXPermissionType_Health:
            strClass = @"LBXPermissionHealth";
            break;
        case LBXPermissionType_DataNetwork:
            break;
        case LBXPermissionType_MediaLibrary:
            strClass = @"LBXPermissionMediaLibrary";
            break;
            
        default:
            break;
    }
    
    if (strClass) {
        BOOL ret  = ((BOOL *(*)(id,SEL))objc_msgSend)( NSClassFromString(strClass), sel);
        return ret;
    }
    
    return NO;
}

+ (void)authorizeWithType:(LBXPermissionType)type completion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    NSString *strClass = nil;
    switch (type) {
        case LBXPermissionType_Location:
            strClass = @"LBXPermissionLocation";
            break;
        case LBXPermissionType_Camera:
            strClass = @"LBXPermissionCamera";
            break;
        case LBXPermissionType_Photos:
            strClass = @"LBXPermissionPhotos";
            break;
        case LBXPermissionType_Contacts:
            strClass = @"LBXPermissionContacts";
            break;
        case LBXPermissionType_Reminders:
            strClass = @"LBXPermissionReminders";
            break;
        case LBXPermissionType_Calendar:
             strClass = @"LBXPermissionCalendar";
            break;
        case LBXPermissionType_Microphone:
            strClass = @"LBXPermissionMicrophone";
            break;
        case LBXPermissionType_Health:
            strClass = @"LBXPermissionHealth";
            break;
        case LBXPermissionType_DataNetwork:
            strClass = @"LBXPermissionData";
            break;
        case LBXPermissionType_MediaLibrary:
            strClass = @"LBXPermissionMediaLibrary";
            break;
            
        default:
            break;
    }
    
    if (strClass)
    {
        SEL sel = NSSelectorFromString(@"authorizeWithCompletion:");
        ((void(*)(id,SEL, completionPermissionHandler))objc_msgSend)(NSClassFromString(strClass),sel, completion);
    }
}

@end
