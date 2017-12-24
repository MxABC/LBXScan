//
//  LBXPermission.h
//  LBXKits

//  github: https://github.com/MxABC/LBXPermission

//  Created by lbx on 2017/9/7.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger,LBXPermissionType)
{
    LBXPermissionType_Location,
    LBXPermissionType_Camera,
    LBXPermissionType_Photos,
    LBXPermissionType_Contacts,
    LBXPermissionType_Reminders,
    LBXPermissionType_Calendar,
    LBXPermissionType_Microphone,
    LBXPermissionType_Health,
    LBXPermissionType_Network
};

@interface LBXPermission : NSObject

/**
 only effective for location servince,other type reture YES


 @param type permission type,when type is not location,return YES
 @return YES if system location privacy service enabled NO othersize
 */
+ (BOOL)isServicesEnabledWithType:(LBXPermissionType)type;


/**
 whether device support the type

 @param type permission type
 @return  YES if device support

 */
+ (BOOL)isDeviceSupportedWithType:(LBXPermissionType)type;

/**
 whether permission has been obtained, only return status, not request permission
 for example, u can use this method in app setting, show permission status
 in most cases, suggest call "authorizeWithType:completion" method

 @param type permission type
 @return YES if Permission has been obtained,NO othersize
 */
+ (BOOL)authorizedWithType:(LBXPermissionType)type;


/**
 request permission and return status in main thread by block.
 execute block immediately when permission has been requested,else request permission and waiting for user to choose "Don't allow" or "Allow"

 @param type permission type
 @param completion May be called immediately if permission has been requested
 granted: YES if permission has been obtained, firstTime: YES if first time to request permission
 */
+ (void)authorizeWithType:(LBXPermissionType)type completion:(void(^)(BOOL granted,BOOL firstTime))completion;





@end
