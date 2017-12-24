//
//  LBXPermissionHealth.m
//  LBXKit
//
//  Created by lbx on 2017/10/30.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXPermissionHealth.h"

@implementation LBXPermissionHealth

+ (BOOL)authorized
{
    return [self authorizationStatus] == HKAuthorizationStatusSharingAuthorized;
}

+ (HKAuthorizationStatus)authorizationStatus
{
    if (![HKHealthStore isHealthDataAvailable])
    {
        return HKAuthorizationStatusSharingDenied;
    }
    
    NSMutableSet *readTypes = [NSMutableSet set];
    NSMutableSet *writeTypes = [NSMutableSet set];
    
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    NSMutableSet *allTypes = [NSMutableSet set];
    [allTypes unionSet:readTypes];
    [allTypes unionSet:writeTypes];
    for (HKObjectType *sampleType in allTypes) {
        HKAuthorizationStatus status = [healthStore authorizationStatusForType:sampleType];
        return status;
    }
    
    return HKAuthorizationStatusSharingDenied;
}

/*!
 @method        isHealthDataAvailable
 @abstract      Returns YES if HealthKit is supported on the device.
 @discussion    HealthKit is not supported on all iOS devices.  Using HKHealthStore APIs on devices which are not
 supported will result in errors with the HKErrorHealthDataUnavailable code.  Call isHealthDataAvailable
 before attempting to use other parts of the framework.
 */
+ (BOOL)isHealthDataAvailable
{
    return [HKHealthStore isHealthDataAvailable];
}

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if (![HKHealthStore isHealthDataAvailable])
    {
        completion(NO,YES);
        return;
    }
    
    NSMutableSet *readTypes = [NSMutableSet set];
    NSMutableSet *writeTypes = [NSMutableSet set];
    
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    NSMutableSet *allTypes = [NSMutableSet set];
    [allTypes unionSet:readTypes];
    [allTypes unionSet:writeTypes];
    

    if (allTypes.count <= 0 ) {
        //设备不支持健康
        completion(NO,YES);
        return;
    }
    
    for (HKObjectType *healthType in allTypes) {
        HKAuthorizationStatus status = [healthStore authorizationStatusForType:healthType];
        switch (status) {
            case HKAuthorizationStatusNotDetermined:
            {
                HKHealthStore *healthStore = [[HKHealthStore alloc] init];
                [healthStore requestAuthorizationToShareTypes:writeTypes
                                                    readTypes:readTypes
                                                   completion:^(BOOL success, NSError *error) {
                                                       if (completion) {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               completion(success,YES);
                                                           });
                                                       }
                                                   }];
            }
                break;
            case HKAuthorizationStatusSharingAuthorized: {
                if (completion) {
                    completion(YES, NO);
                }
            } break;
            case HKAuthorizationStatusSharingDenied: {
                if (completion) {
                    completion(YES, NO);
                }
            } break;
        }
    }
}

@end
