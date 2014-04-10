//
//  Card.m
//  2048 game
//
//  Created by lxs on 14-4-5.
//  Copyright (c) 2014年 leeXsen. All rights reserved.
//

#import "Card.h"

@implementation Card

- (id)init:(int)data image:(UIImageView *)image
{
    self = [super init];
    
    if (self) {
        _data = data;
        self.image = image;
    }
    
    return self;
}

- (void)moveTo:(int)_x y:(int)_y
{
    CGFloat x = _x*75;
    CGFloat y = _y*75;

    [self moveAnimation:x y:y];
}

- (void)addToView:(id)view animation:(int)i delay:(float)delay
{
    [view addSubview:_image];
    
    if (i == RotationAnimation)
        [self rotationAnimation:delay];
    else
        [self zoomAnimation];
}

- (void)add:(Card *)card
{
    _data += card.data;
    
    NSString *num = [[NSNumber numberWithInt:_data] stringValue];
    NSString *numFile = [num stringByAppendingString:@".png"];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:numFile]];
    image.frame = _image.frame;
    
    if (_willMove)
        self.oldImage = self.image;
    else
        [_image removeFromSuperview];
    
    if (card.willMove) {
        card.image.frame = image.frame;
        card.oldImage = card.image;
    } else
        [card.image removeFromSuperview];
    
    self.image = image;
    
    card.data = -1;
    card.image = nil;
}

// 移动动画
- (void)moveAnimation:(int)x y:(int)y
{
    [UIView animateWithDuration:0.2f animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        _image.layer.frame = CGRectMake(x, y, 67, 67);
        _willMove = YES;
    } completion:^(BOOL finished){
        if (finished) {
            _willMove = NO;
            [_oldImage removeFromSuperview];
            self.oldImage = nil;
        }
    }];
}

// 旋转动画
- (void)rotationAnimation:(float)delay
{
    [UIView animateWithDuration:0.2f animations:^{
        [UIView setAnimationDelay:delay];
        _image.transform = CGAffineTransformScale(_image.transform, -0.1f, -0.1f);
        _image.transform = CGAffineTransformConcat(_image.transform,  CGAffineTransformInvert(_image.transform));
    }];
}

// 缩放动画
- (void)zoomAnimation
{
    [UIView animateWithDuration:0.3f animations:^{
        _image.transform = CGAffineTransformScale(_image.transform, 1.5f, 1.5f);
        _image.transform = CGAffineTransformConcat(_image.transform,  CGAffineTransformInvert(_image.transform));
    }];
}

- (void)dealloc
{
    self.image = nil;
}

@end
