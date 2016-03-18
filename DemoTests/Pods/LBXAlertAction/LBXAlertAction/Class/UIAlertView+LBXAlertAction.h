//
//  UIAlertView+Block.h
//
//
//  Created by lbxia on 15/10/27.
//  Copyright © 2015年 lbxia. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIAlertView (LBXAlertAction)

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showWithBlock:(void(^)(NSInteger buttonIndex)) block;




@end