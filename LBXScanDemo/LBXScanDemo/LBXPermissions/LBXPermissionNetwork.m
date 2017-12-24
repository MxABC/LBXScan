//
//  LBXPermissionNetwork.m
//  LBXKits
//
//  Created by lbx on 2017/12/7.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXPermissionNetwork.h"
@import CoreTelephony;

@implementation LBXPermissionNetwork


+ (BOOL)authorized
{
    if (@available(iOS 9,*))
    {
        CTCellularData *cellularData = [[CTCellularData alloc] init];
        CTCellularDataRestrictedState status = cellularData.restrictedState;
        
        return status == kCTCellularDataNotRestricted;
    }
    
    return YES;
}

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if (@available(iOS 9,*)) {
        
        CTCellularData *cellularData = [[CTCellularData alloc] init];
        CTCellularDataRestrictedState status = cellularData.restrictedState;
        
        switch (status) {
            case kCTCellularDataNotRestricted:
            {
                //没有限制
                completion(YES,NO);
            }
                break;
            case kCTCellularDataRestricted:
            {
                //限制
                completion(YES,NO);
            }
                break;
            case kCTCellularDataRestrictedStateUnknown:
            {
                cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (state == kCTCellularDataNotRestricted) {
                            //没有限制
                            completion(YES,YES);
                        }
                        else if (state == kCTCellularDataRestrictedStateUnknown)
                        {
                            completion(NO,YES);
                        }
                        else{
                            //
                            completion(NO,YES);
                        }
                    });
                };
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        completion(YES,NO);
    }

}

@end
