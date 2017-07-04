//
//  RevelView.m
//  RevealAnimation
//
//  Created by ffm on 16/9/6.
//  Copyright © 2016年 ITPanda. All rights reserved.
//
/**
    9.8号更新
    实现了动画的多次循环 啦啦啦啦啦
 */

#import "RevelView.h"
#import <AVFoundation/AVFoundation.h>

@interface RevelView ()

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *clockworkLabel;
@property (weak, nonatomic) IBOutlet UILabel *stoneAgeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundPic;

@property (weak, nonatomic) IBOutlet UIButton *previousBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, strong) UIView *blueCircleView;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *myTimer;
@end

@implementation RevelView

- (void)drawRect:(CGRect)rect
{
    self.playBtn.layer.cornerRadius = 37.5;
    self.playBtn.layer.masksToBounds = YES;
    
    [self.slider addTarget:self action:@selector(changeSongCurrentTime) forControlEvents:UIControlEventValueChanged];
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateValueByCurrentTime) userInfo:nil repeats:YES];
}

#pragma mark - 播放器
- (AVAudioPlayer *)player
{
    if (!_player)
    {
        NSString *strPath = [[NSBundle mainBundle] pathForResource:@"Dear Jane - 不许你注定一人" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:strPath];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        [_player prepareToPlay];
    }
    return _player;
}



#pragma mark PART-1
#pragma mark 点击播放按钮 动画开始
- (IBAction)clikePlayBtn:(id)sender
{
    [self.player play];
    self.player.enableRate = YES;
    self.player.rate = 1;
    
    /**
     *  因为开启动画的时间很短 开启后就交由后台去执行动画 
     *  然后执行下面的代码 所以这两个动画可以看做是同时开启的
     */
    [self playBtnBezierAnimation];
    [self hideLabelsAnimation];
}

#pragma mark 播放按钮的贝塞尔曲线动画
- (void)playBtnBezierAnimation
{
    CAKeyframeAnimation *bezierTranslateAnimation = [[CAKeyframeAnimation alloc] init];
    bezierTranslateAnimation.duration = 0.2;
    
    //动画结束后维持当前状态
    bezierTranslateAnimation.removedOnCompletion = NO;
    bezierTranslateAnimation.fillMode = kCAFillModeForwards;
    
    //创建贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.playBtn.center];
    [path addQuadCurveToPoint:CGPointMake(self.playBtn.center.x, self.frame.size.height-75) controlPoint:CGPointMake(self.frame.size.width+50, self.frame.size.height-110)];
    
    bezierTranslateAnimation.keyPath = @"position";
    bezierTranslateAnimation.path = path.CGPath;

    bezierTranslateAnimation.delegate = self;
    [self.playBtn.layer addAnimation:bezierTranslateAnimation forKey:@"bezierTranslateAnimation"];
}

#pragma mark 隐藏两个label
- (void)hideLabelsAnimation
{
    [UIView animateWithDuration:0.5 animations:^{
        self.clockworkLabel.alpha = 0;
        self.stoneAgeLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.playBtn.alpha = 0;
        [self circleScaleAnimation];
    }];
}

#pragma mark 播放键完成贝塞尔曲线后 做平移运动
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
        [self playBtnTranslateAnimation];
}

- (void)playBtnTranslateAnimation
{
    CABasicAnimation *playBtnTranslateAnimation = [[CABasicAnimation alloc] init];
    playBtnTranslateAnimation.duration = 0.2;
    playBtnTranslateAnimation.removedOnCompletion = NO;
    playBtnTranslateAnimation.fillMode = kCAFillModeForwards;
    playBtnTranslateAnimation.keyPath = @"position";
    playBtnTranslateAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.frame.size.height-75)];
    [self.playBtn.layer addAnimation:playBtnTranslateAnimation forKey:@"playBtnTranslateAnimation"];
}

#pragma mark 蓝色的圆view放大动画
- (void)circleScaleAnimation
{
    self.blueCircleView.alpha = 1;
    [self bringSubviewToFront:self.backgroundPic];
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:1 initialSpringVelocity:5 options:UIViewAnimationOptionTransitionNone animations:^{
        self.blueCircleView.transform = CGAffineTransformScale(self.blueCircleView.transform, 5.5, 5.5);
    } completion:^(BOOL finished) {
        [self otherComponentSetup];
    }];
}

#pragma mark 蓝色圆view懒加载
- (UIView *)blueCircleView
{
    if (!_blueCircleView)
    {
        _blueCircleView = [[UIView alloc] initWithFrame:CGRectMake(self.center.x - 37.5, self.frame.size.height-75-37.5, 75, 75)];
        _blueCircleView.layer.cornerRadius = 37.5;
        _blueCircleView.layer.masksToBounds = YES;
        _blueCircleView.backgroundColor = [UIColor colorWithCGColor:self.playBtn.backgroundColor.CGColor];
        [self addSubview:_blueCircleView];
    }
    return _blueCircleView;
}

#pragma mark 蓝色view放大后 其他部件的出现动画
- (void)otherComponentSetup
{
    [self sendSubviewToBack:self.backgroundPic];
    [self sendSubviewToBack:self.blueCircleView];
    self.stopBtn.alpha = 1;
    self.previousBtn.alpha = 1;
    self.nextBtn.alpha = 1;
    self.slider.alpha = 1;
    self.songNameLabel.alpha = 1;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.previousBtn.transform = CGAffineTransformTranslate(self.stopBtn.transform, -100, -40);
        self.stopBtn.transform = CGAffineTransformTranslate(self.stopBtn.transform, 0, -40);
        self.nextBtn.transform = CGAffineTransformTranslate(self.nextBtn.transform, 100, -40);
        self.slider.transform = CGAffineTransformTranslate(self.slider.transform, 0, -10);
        self.songNameLabel.transform = CGAffineTransformTranslate(self.songNameLabel.transform, 0, 20);
    } completion:^(BOOL finished){
    }];
}

#pragma mark PART-2
- (IBAction)clickStop:(id)sender {
    [self otherComponentHide];
    
    [self.player stop];
    self.player.currentTime = 0;
}


#pragma mark 其他部件的隐藏
- (void)otherComponentHide
{
    [UIView animateWithDuration:0.5 animations:^{
        self.stopBtn.alpha = 0;
        self.previousBtn.alpha = 0;
        self.nextBtn.alpha = 0;
        self.slider.alpha = 0;
        self.songNameLabel.alpha = 0;
        self.blueCircleView.transform = CGAffineTransformScale(self.blueCircleView.transform, 0.1818, 0.1818);
    } completion:^(BOOL finished) {
        self.previousBtn.transform = CGAffineTransformTranslate(self.stopBtn.transform, 100, 40);
        self.stopBtn.transform = CGAffineTransformTranslate(self.stopBtn.transform, 0, 40);
        self.nextBtn.transform = CGAffineTransformTranslate(self.nextBtn.transform, -100, 40);
        self.slider.transform = CGAffineTransformTranslate(self.slider.transform, 0, 10);
        self.songNameLabel.transform = CGAffineTransformTranslate(self.songNameLabel.transform, 0, -20);

        self.playBtn.alpha = 1;
        self.blueCircleView.alpha = 0;
        [self playBtnBezierBackAnimation];
    }];
}
#pragma mark playBtn贝塞尔曲线返回
- (void)playBtnBezierBackAnimation
{
    CAKeyframeAnimation *bezierBackTranslateAnimation = [[CAKeyframeAnimation alloc] init];
    bezierBackTranslateAnimation.duration = 0.2;
    
    //动画结束后维持当前状态
    bezierBackTranslateAnimation.removedOnCompletion = NO;
    bezierBackTranslateAnimation.fillMode = kCAFillModeForwards;
    
    //创建贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.center.x, self.frame.size.height-75)];
    [path addQuadCurveToPoint:CGPointMake(self.frame.size.width-60, self.frame.size.height - 150) controlPoint:CGPointMake(self.frame.size.width+50, self.frame.size.height-110)];
    
    bezierBackTranslateAnimation.keyPath = @"position";
    bezierBackTranslateAnimation.path = path.CGPath;
    
    [self.playBtn.layer addAnimation:bezierBackTranslateAnimation forKey:@"bezierBackTranslateAnimation"];
    [self performSelector:@selector(showHiddenLabels) withObject:nil afterDelay:0.2];
}

#pragma mark 显示之前隐藏的两个label
- (void)showHiddenLabels
{
    self.clockworkLabel.transform = CGAffineTransformScale(self.clockworkLabel.transform, 0.1, 0.1);
    self.stoneAgeLabel.transform = CGAffineTransformScale(self.stoneAgeLabel.transform, 0.1, 0.1);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.clockworkLabel.transform = CGAffineTransformScale(self.clockworkLabel.transform, 10, 10);
        self.stoneAgeLabel.transform = CGAffineTransformScale(self.stoneAgeLabel.transform, 10, 10);
        self.clockworkLabel.alpha = 1;
        self.stoneAgeLabel.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 点击播放按钮上一首 下一首等 歌曲播放相关的
- (void)changeSongCurrentTime
{
    self.player.currentTime = self.player.duration * self.slider.value;
}
- (void)updateValueByCurrentTime
{
    self.slider.value = self.player.currentTime / self.player.duration;
}

//点击下一首button 这里先临时作为 快进
- (IBAction)clickNextBtn:(id)sender {
    self.player.enableRate = YES;
    if (self.player.rate == 1)
    {
        self.player.rate = 1.5;
    } else
    {
        self.player.rate = 2;
    }
    
}

//点击上一首button 这里先临时作为 播放键
- (IBAction)clickPreviousBtn:(id)sender {
    [self.player play];
    self.player.enableRate = YES;
    self.player.rate =1;
    
}


@end
