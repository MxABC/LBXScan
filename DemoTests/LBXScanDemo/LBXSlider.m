//
//  LBXSlider.m
//  LBXScanDemo
//
//  Created by csc on 16/3/18.
//  Copyright © 2016年 csce. All rights reserved.
//

#import "LBXSlider.h"

@implementation LBXSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIImage *) toImage:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 4.0f, 16.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    [self setThumbImage:[self toImage:[UIColor redColor]] forState:UIControlStateNormal];
    return self;
}

@end
