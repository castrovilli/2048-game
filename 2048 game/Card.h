//
//  Card.h
//  2048 game
//
//  Created by lxs on 14-4-5.
//  Copyright (c) 2014年 leeXsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

enum {
    RotationAnimation,
    ZoomAnimation
};

@property (assign, nonatomic) BOOL willMove;
@property (assign, nonatomic) int data;
@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UIImageView *oldImage;

- (id)init:(int)data image:(UIImageView *)image;
- (void)moveTo:(int) x y:(int)y;
- (void)addToView:(id)view animation:(int)i delay:(float)delay;
- (void)add:(Card *)card;

@end
