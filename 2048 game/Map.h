//
//  Map.h
//  2048 game
//
//  Created by lxs on 14-4-5.
//  Copyright (c) 2014年 leeXsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MapDelegate

@required
- (void)UpdateScroe:(int)num;

@end

@interface Map : NSObject

enum checkStatus {
    Victory,
    Failed,
    GoOn
};

@property (weak, nonatomic) UIView *view;
@property (weak, nonatomic) id<MapDelegate> delegate;

- (id)init:(UIView *)view gameController:(id<MapDelegate>) controller;
- (void)randomCard:(BOOL)isFirst;
- (BOOL)parallel:(UISwipeGestureRecognizer *)recognizer;
- (BOOL)merger:(UISwipeGestureRecognizer *)recognizer;
- (int)checkStatus;

@end
