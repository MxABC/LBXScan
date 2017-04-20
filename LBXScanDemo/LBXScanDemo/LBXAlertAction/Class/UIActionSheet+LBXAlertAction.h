//
//  UIActionSheet+Block.h
//
//
//  Created by lbxia on 15/10/27.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIActionSheet (LBXAlertAction)<UIActionSheetDelegate>


- (void)showInView:(UIView *)view block:(void(^)(NSInteger idx,NSString* buttonTitle))block;

@end
