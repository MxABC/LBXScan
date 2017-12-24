//
//  LBXContactPermission.h
//  LBXKits
//
//  Created by lbx on 2017/9/3.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

@interface LBXPermissionContacts : NSObject

+ (BOOL)authorized;

/**
 access authorizationStatus
 
 @return ABAuthorizationStatus(prior to iOS 9) or CNAuthorizationStatus(after iOS 9)
 */
+ (NSInteger)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end
