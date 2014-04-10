//
//  Map.m
//  2048 game
//
//  Created by lxs on 14-4-5.
//  Copyright (c) 2014年 leeXsen. All rights reserved.
//

#import "Map.h"
#import "Card.h"

@interface Map ()

@property (strong, nonatomic) NSMutableArray *map;
@property (strong, nonatomic) NSMutableArray *leakImageViews;

@end

@implementation Map

- (id)init:(UIView *)view gameController:(id<MapDelegate>) controller
{
    self = [super self];

    if (self) {
        _view = view;
        _delegate = controller;
        _map = [NSMutableArray new];
        _leakImageViews = [NSMutableArray new];
       
        @autoreleasepool {
            for (int i = 0; i < 4; i++) {
                NSMutableArray *array = [NSMutableArray new];
                int y = 75*i;
                
                for (int j = 0; j < 4; j++) {
                    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0.png"]];
                    image.frame = CGRectMake(75*j, y, 67, 67);
                    
                    [array addObject:[[Card alloc] init:-1 image:image]];
                    [_leakImageViews addObject:image]; // 搜集可能会内存泄露的对象，并在dealloc中释放
                    [(Card *)(array.lastObject) addToView:view animation:RotationAnimation delay:0.0f];
                }
            
                [_map addObject:array];
            }
        }
        
        [self randomCard:true];
    }
    
    return self;
}

- (void)randomCard:(BOOL)isFirst
{
    int i;
    int x, y, data;
    
    if (isFirst)
        i = 0;
    else
        i = 1;
    
    for (; i < 2; i++) {
        do {
            x = rand() % 4;
            y = rand() % 4;
            data = rand() % 3 + 2;
        } while (data == 3 || ((Card *)_map[y][x]).data != -1);
            
        UIImageView *image;
        NSString *num = [[NSNumber numberWithInt:data] stringValue];
        NSString *numFile = [num stringByAppendingString:@".png"];
        
        image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:numFile]];
        image.frame = CGRectMake(75*x, 75*y, 67, 67);

        Card *card = _map[y][x];
        card.data = data;
        card.image = image;
        
        [card addToView:_view animation:RotationAnimation delay:0.2f];
    }
}

// 使所有卡片挤在一起
- (BOOL)parallel:(UISwipeGestureRecognizer *)recognizer
{
    BOOL moved = NO;

    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            for (int i = 0; i < 4; i++) {
                int k = 0;
                while (k < 3 && ((Card *)_map[k][i]).data != -1)
                    ++k;
                
                if (k != 3) {
                    for (int j = k+1; j < 4; j++) {
                        if (((Card *)_map[j][i]).data == -1)
                            continue;
                        
                        [(Card *)_map[j][i] moveTo:i y:k];
                        id card = _map[j][i];
                        _map[j][i] = _map[k][i];
                        _map[k][i] = card;
                        
                        moved = YES;
                        ++k;
                    }
                }
            }
            break;
            
        case UISwipeGestureRecognizerDirectionDown:
            for (int i = 0; i < 4; i++) {
                int k = 3;
                while (k > 0 && ((Card *)_map[k][i]).data != -1)
                    --k;
                
                if (k != 0) {
                    for (int j = k-1; j >= 0; j--) {
                        if (((Card *)_map[j][i]).data == -1)
                            continue;
                        
                        [(Card *)_map[j][i] moveTo:i y:k];
                        id card = _map[j][i];
                        _map[j][i] = _map[k][i];
                        _map[k][i] = card;
                            
                        moved = YES;
                        --k;
                    }
                }
            }
            
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
            for (int i = 0; i < 4; i++) {
                int k = 0;
                while (k < 3 && ((Card *)_map[i][k]).data != -1)
                    ++k;
                
                if (k != 3) {
                    for (int j = k+1; j < 4; j++) {
                        if (((Card *)_map[i][j]).data == -1)
                            continue;
                        
                        [(Card *)_map[i][j] moveTo:k y:i];
                        id card = _map[i][j];
                        _map[i][j] = _map[i][k];
                        _map[i][k] = card;
                        
                        moved = YES;
                        ++k;
                    }
                }
            }
            break;
            
        case UISwipeGestureRecognizerDirectionRight:
            for (int i = 0; i < 4; i++) {
                int k = 3;
                while (k > 0 && ((Card *)_map[i][k]).data != -1)
                    --k;
                
                if (k != 0) {
                    for (int j = k-1; j >= 0; j--) {
                        if (((Card *)_map[i][j]).data == -1)
                            continue;
                        
                        [(Card *)_map[i][j] moveTo:k y:i];
                        id card = _map[i][j];
                        _map[i][j] = _map[i][k];
                        _map[i][k] = card;
                        
                        moved = YES;
                        --k;
                    }
                }
            }
            break;
    }
    
    return moved;
}

// 合并卡片
- (BOOL)merger:(UISwipeGestureRecognizer *)recognizer
{
    BOOL mergered = NO;

    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            for (int i = 0; i < 4; i++) {
                for (int j = 1; j < 4; j++) {
                    Card *prevCard = _map[j-1][i];
                    Card *currentCard = _map[j][i];
                    
                    if (currentCard.data == -1)
                        break;
                    if (currentCard.data != prevCard.data)
                        continue;
                    
                    [prevCard add:currentCard];
                    [prevCard addToView:_view animation:ZoomAnimation delay:0.0f];
                    
                    [_delegate UpdateScroe:prevCard.data];
                    mergered = YES;
                }
            }
            break;
            
        case UISwipeGestureRecognizerDirectionDown:
            for (int i = 0; i < 4; i++) {
                for (int j = 2; j >= 0; j--) {
                    Card *prevCard = _map[j+1][i];
                    Card *currentCard = _map[j][i];
                    
                    if (currentCard.data == -1)
                        break;
                    if (currentCard.data != prevCard.data)
                        continue;

                    [prevCard add:currentCard];
                    [prevCard addToView:_view animation:ZoomAnimation delay:0.0f];
                    
                    [_delegate UpdateScroe:prevCard.data];
                    mergered = YES;
                }
            }
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
            for (int i = 0; i < 4; i++) {
                for (int j = 1; j < 4; j++) {
                    Card *prevCard = _map[i][j-1];
                    Card *currentCard = _map[i][j];
                    
                    if (currentCard.data == -1)
                        break;
                    if (currentCard.data != prevCard.data)
                        continue;

                    [prevCard add:currentCard];
                    [prevCard addToView:_view animation:ZoomAnimation delay:0.0f];
                    
                    [_delegate UpdateScroe:prevCard.data];
                    mergered = YES;
                }
            }
            break;
            
        case UISwipeGestureRecognizerDirectionRight:
            for (int i = 0; i < 4; i++) {
                for (int j = 2; j >= 0; j--) {
                    Card *prevCard = _map[i][j+1];
                    Card *currentCard = _map[i][j];
                    
                    if (currentCard.data == -1)
                        break;
                    if (currentCard.data != prevCard.data)
                        continue;

                    [prevCard add:currentCard];
                    [prevCard addToView:_view animation:ZoomAnimation delay:0.0f];
                    
                    [_delegate UpdateScroe:prevCard.data];
                    mergered = YES;
                }
            }
            break;
    }
    
    return mergered;
}

- (int)checkStatus
{
    BOOL goOn = NO;
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            Card *current = _map[i][j];
            
            if (current.data == 2048)
                return Victory;
            if (current.data == -1)
                goOn = YES;
            
            if (i-1 >= 0 && current.data == ((Card *)_map[i-1][j]).data)
                goOn = YES;
            
            if (i+1 < 4 && current.data == ((Card *)_map[i+1][j]).data)
                goOn = YES;
            
            if (j-1 >= 0 && current.data == ((Card *)_map[i][j-1]).data)
                goOn = YES;
            
            if (j+1 < 4 && current.data == ((Card *)_map[i][j+1]).data)
                goOn = YES;
        }
    }
    
    return goOn ? GoOn : Failed;
}

- (void)dealloc
{
    for (NSArray *array in _map) {
        for (Card *card in array)
            [card.image removeFromSuperview];
    }
    
    for (UIImageView *img in _leakImageViews)
        [img removeFromSuperview];
    
    self.map = nil;
}
 
@end