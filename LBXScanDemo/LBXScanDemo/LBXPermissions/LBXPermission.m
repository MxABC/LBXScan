//
//  LBXPermission.m
//  LBXKits
//
//  Created by lbx on 2017/9/7.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXPermission.h"
#import <UIKit/UIKit.h>

#import "LBXPermissionCamera.h"
#import "LBXPermissionPhotos.h"
#import "LBXPermissionContacts.h"
#import "LBXPermissionLocation.h"
#import "LBXPermissionHealth.h"
#import "LBXPermissionCalendar.h"
#import "LBXPermissionReminders.h"
#import "LBXPermissionMicrophone.h"
#import "LBXPermissionNetwork.h"

@implementation LBXPermission


+ (BOOL)isServicesEnabledWithType:(LBXPermissionType)type
{
    if (type == LBXPermissionType_Location) {
        return [LBXPermissionLocation isServicesEnabled];
    }
    
    return YES;
}

+ (BOOL)isDeviceSupportedWithType:(LBXPermissionType)type
{
    if (type == LBXPermissionType_Health) {
        
        return  [LBXPermissionHealth isHealthDataAvailable];
    }
    
    return YES;
}

+ (BOOL)authorizedWithType:(LBXPermissionType)type
{
    switch (type) {
        case LBXPermissionType_Location:
            return [LBXPermissionLocation authorized];
            break;
        case LBXPermissionType_Camera:
            return [LBXPermissionCamera authorized];
            break;
        case LBXPermissionType_Photos:
            return [LBXPermissionPhotos authorized];
            break;
        case LBXPermissionType_Contacts:
            return [LBXPermissionContacts authorized];
            break;
        case LBXPermissionType_Reminders:
            return [LBXPermissionReminders authorized];
            break;
        case LBXPermissionType_Calendar:
            return [LBXPermissionCalendar authorized];
            break;
        case LBXPermissionType_Microphone:
            return [LBXPermissionMicrophone authorized];
            break;
        case LBXPermissionType_Health:
            return [LBXPermissionHealth authorized];
            break;
        case LBXPermissionType_Network:
            return [LBXPermissionNetwork authorized];
            break;
        default:
            break;
    }
    return NO;
}

+ (void)authorizeWithType:(LBXPermissionType)type completion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    switch (type) {
        case LBXPermissionType_Location:
            return [LBXPermissionLocation authorizeWithCompletion:completion];
            break;
        case LBXPermissionType_Camera:
            return [LBXPermissionCamera authorizeWithCompletion:completion];
            break;
        case LBXPermissionType_Photos:
            return [LBXPermissionPhotos authorizeWithCompletion:completion];
            break;
        case LBXPermissionType_Contacts:
            return [LBXPermissionContacts authorizeWithCompletion:completion];
            break;
        case LBXPermissionType_Reminders:
            return [LBXPermissionReminders authorizeWithCompletion:completion];
            break;
        case LBXPermissionType_Calendar:
            return [LBXPermissionCalendar authorizeWithCompletion:completion];
            break;
        case LBXPermissionType_Microphone:
            return [LBXPermissionMicrophone authorizeWithCompletion:completion];
            break;
        case LBXPermissionType_Health:
            return [LBXPermissionHealth authorizeWithCompletion:completion];
            break;
        case LBXPermissionType_Network:
            return [LBXPermissionNetwork authorizeWithCompletion:completion];
            break;
            
        default:
            break;
    }
}

@end
