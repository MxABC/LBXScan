//
//  LBXPermissionGPS.m
//  LBXKits
//
//  Created by lbx on 2017/9/7.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXPermissionLocation.h"
#import <UIKit/UIKit.h>

@interface LBXPermissionLocation()<CLLocationManagerDelegate>
@property(nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void (^permissionCompletion)(BOOL granted,BOOL firstTime);
@end

@implementation LBXPermissionLocation

+ (instancetype)sharedManager
{
    static LBXPermissionLocation* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LBXPermissionLocation alloc] init];
    });
    
    return _sharedInstance;
}

+ (BOOL)isServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)authorized
{
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];

    return authorizationStatus == kCLAuthorizationStatusAuthorizedAlways || authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse;
}

+ (CLAuthorizationStatus)authorizationStatus;
{
    return  [CLLocationManager authorizationStatus];
}


+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;
{
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            if (completion) {
                completion(YES,NO);
            }
        } break;
        case kCLAuthorizationStatusNotDetermined:
        {
            if (![self isServicesEnabled]) {
                if (completion) {
                    completion(NO,NO);
                }
                return;
            }
            
            [[LBXPermissionLocation sharedManager]startGps:completion];
        }
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            if (completion) {
                completion(NO,NO);
            }
        } break;
    }
}

- (void)startGps:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if ( self.locationManager != nil ) {
        [self stopGps];
    }
    
    self.permissionCompletion = completion;
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        BOOL hasAlwaysKey = [[NSBundle mainBundle]
                             objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
        BOOL hasWhenInUseKey =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] !=
        nil;
        if (hasAlwaysKey) {
            [_locationManager requestAlwaysAuthorization];
        } else if (hasWhenInUseKey) {
            [_locationManager requestWhenInUseAuthorization];
        } else {
            // At least one of the keys NSLocationAlwaysUsageDescription or
            // NSLocationWhenInUseUsageDescription MUST be present in the Info.plist
            // file to use location services on iOS 8+.
            NSAssert(hasAlwaysKey || hasWhenInUseKey,
                     @"To use location services in iOS 8+, your Info.plist must "
                     @"provide a value for either "
                     @"NSLocationWhenInUseUsageDescription or "
                     @"NSLocationAlwaysUsageDescription.");
        }
    }
    [self.locationManager startUpdatingLocation];
}

- (void)stopGps
{
    if ( self.locationManager )
    {
        [_locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            //access permission,first callback this status
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            
            [self stopGps];
            if (_permissionCompletion) {
                _permissionCompletion(YES,YES);
            }
            self.permissionCompletion = nil;
        }
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            
            [self stopGps];
            if (_permissionCompletion) {
                _permissionCompletion(NO,YES);
            }
            self.permissionCompletion = nil;
            break;
        }
    }
    
}


@end
