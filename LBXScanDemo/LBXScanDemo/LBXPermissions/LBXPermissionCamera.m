//
//  LBXPermissionCamera.m
//  LBXKits
//
//  Created by lbxia on 2017/9/10.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXPermissionCamera.h"

@implementation LBXPermissionCamera

+ (BOOL)authorized
{
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        return permission == AVAuthorizationStatusAuthorized;
       
    } else {
        // Prior to iOS 8 all apps were authorized.
        return YES;
    }
}

+ (AVAuthorizationStatus)authorizationStatus
{
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    } else {
        // Prior to iOS 8 all apps were authorized.
        return AVAuthorizationStatusAuthorized;
    }
}

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                completion(YES,NO);
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                completion(NO,NO);
                break;
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                                             if (completion) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     completion(granted,YES);
                                                 });
                                             }
                                         }];
                
            }
                break;
        }
    } else {
        // Prior to iOS 8 all apps were authorized.
        completion(YES,NO);
    }
}


@end
