//
//  UIActionSheet+Block.m
//
//
//  Created by lbxia on 15/10/27.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "UIActionSheet+LBXAlertAction.h"
#import <objc/runtime.h>

static char key;

@implementation UIActionSheet (LBXAlertAction)


- (void(^)(NSInteger idx,NSString* buttonTitle))block
{
    return objc_getAssociatedObject(self, &key);;
}
- (void)setBlock:(void(^)(NSInteger idx,NSString* buttonTitle))block
{
    if (block) {
        objc_setAssociatedObject(self, &key, block, OBJC_ASSOCIATION_COPY);
    }
}

- (void)showInView:(UIView *)view block:(void(^)(NSInteger idx,NSString* buttonTitle))block
{
    self.block = block;
    
    self.delegate = self;
    [self showInView:view];
}


// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.block) {
        self.block(buttonIndex,[self buttonTitleAtIndex:buttonIndex]);
    }
    
     objc_removeAssociatedObjects(self);
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
     objc_removeAssociatedObjects(self);
}

@end
