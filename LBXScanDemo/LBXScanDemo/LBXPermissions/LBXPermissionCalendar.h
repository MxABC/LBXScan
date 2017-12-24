//
//  LBXPermissionCalendar.h
//  LBXKit
//
//  Created by lbx on 2017/10/30.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface LBXPermissionCalendar : NSObject

+ (BOOL)authorized;

+ (EKAuthorizationStatus)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end
