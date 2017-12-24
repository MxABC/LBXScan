//
//  LBXPermissionNetwork.h
//  LBXKits
//
//  Created by lbx on 2017/12/7.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBXPermissionNetwork : NSObject

+ (BOOL)authorized;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end
