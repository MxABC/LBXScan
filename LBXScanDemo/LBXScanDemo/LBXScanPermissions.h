//
//  LBXScanPermissions.h
//  LBXScanDemo
//
//  Created by lbxia on 2017/1/4.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBXScanPermissions : NSObject

+ (BOOL)cameraPemission;

+ (void)requestCameraPemissionWithResult:(void(^)( BOOL granted))completion;

+ (BOOL)photoPermission;

@end
