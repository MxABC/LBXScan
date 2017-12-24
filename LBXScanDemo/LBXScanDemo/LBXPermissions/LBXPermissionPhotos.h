//
//  LBXPermissionPhotos.h
//  LBXKits
//
//  Created by lbxia on 2017/9/10.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface LBXPermissionPhotos : NSObject

+ (BOOL)authorized;

+ (PHAuthorizationStatus)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end
