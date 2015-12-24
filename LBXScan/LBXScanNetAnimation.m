//
//  LBXScanLineAnimation.m
//
//
//  Created by lbxia on 15/11/3.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanNetAnimation.h"


@interface LBXScanNetAnimation()
{
    BOOL isAnimationing;
}

@property (nonatomic,assign) CGRect animationRect;
@property (nonatomic,strong) UIImageView *scanImageView;

@end

@implementation LBXScanNetAnimation

- (instancetype)init{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        [self addSubview:self.scanImageView];
    }
    return self;
}

- (UIImageView *)scanImageView{
    if (!_scanImageView) {
        _scanImageView = [[UIImageView alloc] init];
    }
    return _scanImageView;
}

- (void)stepAnimation
{
    if (!isAnimationing) {
        return;
    }
    
    CGRect frame = _animationRect;
    frame.origin.y -= frame.size.height;
    self.frame = frame;
    
    self.alpha = 0.0;
    
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:1.2 animations:^{
        weakSelf.alpha = 1.0;
        weakSelf.frame = weakSelf.animationRect;
        
    } completion:^(BOOL finished)
     {
         
         [weakSelf performSelector:@selector(stepAnimation) withObject:nil afterDelay:0.3];
     }];
}


- (void)stepAnimation2
{
    if (!isAnimationing) {
        return;
    }
    
    CGRect frame = _animationRect;
    frame.origin.y -= frame.size.height/2;
    frame.size.height = _animationRect.size.height/2;
    self.frame = frame;
    
    self.alpha = 0.0;
    
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:1.2 animations:^{
        weakSelf.alpha = 1.0;
        
        CGRect frame = weakSelf.animationRect;
        frame.origin.y += frame.size.height/2;
        frame.size.height = weakSelf.animationRect.size.height/2;
        weakSelf.frame = frame;
        
        // weakSelf.frame = weakSelf.animationRect;
        
    } completion:^(BOOL finished)
     {
         
         [weakSelf performSelector:@selector(stepAnimation2) withObject:nil afterDelay:0.3];
     }];
}

- (void)stepAnimation3
{
    if (!isAnimationing) {
        return;
    }
    
    CGRect frame = _animationRect;
    
    CGFloat hImg = _scanImageView.image.size.height * _animationRect.size.width / _scanImageView.image.size.width;
    
    frame.size.height = hImg;
    self.frame = frame;
    
    CGFloat scanNetImageViewW = self.frame.size.width;
    CGFloat scanNetImageH = 241;
    __weak __typeof(self) weakSelf = self;
    self.alpha = 0.5;
    _scanImageView.frame = CGRectMake(0, -scanNetImageH, scanNetImageViewW, scanNetImageH);
    [UIView animateWithDuration:1.4 animations:^{
        weakSelf.alpha = 1.0;
        
        _scanImageView.frame = CGRectMake(0, scanNetImageViewW-scanNetImageH, scanNetImageViewW, scanNetImageH);
        
    } completion:^(BOOL finished)
     {
         [weakSelf performSelector:@selector(stepAnimation3) withObject:nil afterDelay:0.3];
     }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self performSelector:@selector(stepAnimation3) withObject:nil afterDelay:0.3];
}


- (void)startAnimatingWithRect:(CGRect)animationRect InView:(UIView *)parentView Image:(UIImage*)image
{
    [self.scanImageView setImage:image];
    
    self.animationRect = animationRect;
    
    [parentView addSubview:self];
    
    self.hidden = NO;
    
    isAnimationing = YES;
    
    [self stepAnimation3];
}


- (void)dealloc
{
    [self stopAnimating];
}

- (void)stopAnimating
{
    self.hidden = YES;
    isAnimationing = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
