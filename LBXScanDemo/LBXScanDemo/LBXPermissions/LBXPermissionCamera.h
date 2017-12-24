//
//  LBXPermissionCamera.h
//  LBXKits
//
//  Created by lbxia on 2017/9/10.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface LBXPermissionCamera : NSObject

+ (BOOL)authorized;

+ (AVAuthorizationStatus)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted ,BOOL firstTime ))completion;

@end
