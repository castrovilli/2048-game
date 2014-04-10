//
//  ViewController.m
//  2048 game
//
//  Created by lxs on 14-4-5.
//  Copyright (c) 2014年 leeXsen. All rights reserved.
//

#import "GameController.h"

@interface GameController ()
{
    NSUInteger score;
}

@property (strong, nonatomic) UILabel *bestLabel;
@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UIView *boardView;
@property (strong, nonatomic) Map *map;

@end

@implementation GameController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self initGame];
    [self initGesture];
    
    _map = [[Map alloc] init:_boardView gameController:self];
}

- (void)initGame
{
    CGRect rect = UIScreen.mainScreen.bounds;
    CGFloat screenHeight = rect.size.height;
    int viewSize = 292;
    CGFloat viewHeight = (screenHeight-viewSize)/2;
    
    _boardView = [[UIView alloc] init];
    _boardView.frame = CGRectMake(14, viewHeight, viewSize, viewSize);
   
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"boardBackground.png"]];
    image.frame = CGRectMake(6, viewHeight-8, 308, 308);
    [self.view addSubview:image];
    
    //[self.view addSubview:_boardView];
    //self.view.backgroundColor = [UIColor colorWithRed:250/255.0f green:248/255.0f blue:239/255.0f alpha:1];
    
    /*
    // 将boardView设置为圆角矩形
    CGFloat minSide = fmin(_boardView.bounds.size.width, _boardView.bounds.size.height);
    _boardView.layer.cornerRadius = minSide/40;
    _boardView.layer.masksToBounds = YES;
    _boardView.opaque = NO;
    _boardView.backgroundColor = [UIColor colorWithRed:187/255.0f green:172/255.0f blue:160/255.0f alpha:1];
     */
    
    [self.view addSubview:_boardView];
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0f green:248/255.0f blue:239/255.0f alpha:1];
    
    
    UIImageView *scoreImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreBackground.png"]];
    UIImageView *bestImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bestBackground.png"]];
    UIImageView *newGameImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newGameBackground.png"]];
    // 为newGameImg增加点击监听
    newGameImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetGame)];
    [newGameImg addGestureRecognizer:singleTap];

    _bestLabel = [[UILabel alloc] init];
    _bestLabel.text = [self readHeightScoreFromFile];
    _bestLabel.textColor = [UIColor whiteColor];
    _bestLabel.textAlignment = NSTextAlignmentCenter;
    _bestLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0];
    
    _scoreLabel = [[UILabel alloc] init];
    _scoreLabel.text = @"0";
    _scoreLabel.textColor = [UIColor whiteColor];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0];
    
    scoreImg.frame = CGRectMake(20, (viewHeight-60)/2, 81, 60);
    _scoreLabel.frame = CGRectMake(20, (viewHeight-60)/2+27, 81, 30);
    [self.view addSubview:scoreImg];
    [self.view addSubview:_scoreLabel];
    
    bestImg.frame = CGRectMake(219, (viewHeight-60)/2, 81, 60);
    _bestLabel.frame = CGRectMake(219, (viewHeight-60)/2+27, 81, 30);
    [self.view addSubview:bestImg];
    [self.view addSubview:_bestLabel];
    
    newGameImg.frame = CGRectMake(120, (viewHeight-60)/2, 81, 60);
    [self.view addSubview:newGameImg];
}

// 为boardView设置手势
- (void)initGesture
{
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_boardView addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [_boardView addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [_boardView addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_boardView addGestureRecognizer:recognizer];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    BOOL moved = [_map parallel:recognizer];
    BOOL mergered = [_map merger:recognizer];
    [_map parallel:recognizer];
    
    if (moved || mergered)
        [_map randomCard:NO];
    
    enum checkStatus code = [_map checkStatus];
    if (code == Victory) {
        [[[UIAlertView alloc]
            initWithTitle:nil
            message:@"你赢了，你真无聊 :)"
            delegate:self
            cancelButtonTitle:@"确定"
            otherButtonTitles:nil, nil] show];
    } else if (code == Failed) {
        [[[UIAlertView alloc]
          initWithTitle:nil
          message:@"无路可走了吧，哈哈，你输了！"
          delegate:self
          cancelButtonTitle:@"确定"
          otherButtonTitles:nil, nil] show];
    }
}

- (void)UpdateScroe:(int)num
{
    [UILabel animateWithDuration:0.2f animations:^{
        score += num;
        _scoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)score];
        _scoreLabel.transform = CGAffineTransformScale(_scoreLabel.transform, 1.5f, 1.5f);
        _scoreLabel.transform = CGAffineTransformConcat(_scoreLabel.transform,  CGAffineTransformInvert(_scoreLabel.transform));
    }];
}

- (NSString *)readHeightScoreFromFile
{
    NSError *error;
    NSString *filePath = NSHomeDirectory();
    filePath = [NSString stringWithFormat:@"%@/score", filePath];
    NSString *str = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    return (error != nil) ? @"0" : str;
}

- (void)writeHeightScoreToFile
{
    NSString *filePath = NSHomeDirectory();
    filePath = [NSString stringWithFormat:@"%@/score", filePath];
    [_bestLabel.text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)resetGame
{
    if ([_bestLabel.text intValue] < score) {
        
        [UILabel animateWithDuration:0.2f animations:^{
            _bestLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)score];
            [self writeHeightScoreToFile];
            
            _bestLabel.transform = CGAffineTransformScale(_bestLabel.transform, 1.5f, 1.5f);
            _bestLabel.transform = CGAffineTransformConcat(_bestLabel.transform,  CGAffineTransformInvert(_bestLabel.transform));
        }];
    }
    score = 0;
    _scoreLabel.text = @"0";
    
    self.map = nil;
    _map = [[Map alloc] init:_boardView gameController:self];
}

@end