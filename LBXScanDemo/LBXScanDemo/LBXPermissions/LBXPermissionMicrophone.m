//
//  LBXPermissionAudio.m
//  LBXKit
//
//  Created by lbx on 2017/10/30.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXPermissionMicrophone.h"


@implementation LBXPermissionMicrophone

+ (BOOL)authorized
{
    return [self authorizationStatus] == AVAudioSessionRecordPermissionGranted;
}

+ (AVAudioSessionRecordPermission)authorizationStatus
{
    return  [[AVAudioSession sharedInstance] recordPermission];
}

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(recordPermission)]) {
        AVAudioSessionRecordPermission permission = [audioSession recordPermission];
        switch (permission) {
            case AVAudioSessionRecordPermissionGranted: {
                if (completion) {
                    completion(YES, NO);
                }
            }
                break;
            case AVAudioSessionRecordPermissionDenied: {
                if (completion) {
                    completion(NO, NO);
                }
            }
                break;
            case AVAudioSessionRecordPermissionUndetermined:
            {
                AVAudioSession *session = [[AVAudioSession alloc] init];
                NSError *error;
                [session setCategory:@"AVAudioSessionCategoryPlayAndRecord" error:&error];
                [session requestRecordPermission:^(BOOL granted) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(granted,YES);
                        });
                    }
                }];
            }
                break;
            default:
            {
                completion(NO,YES);
            }
                break;
        }
    }
    else
    {
        completion(YES, NO);
    }
}

@end
