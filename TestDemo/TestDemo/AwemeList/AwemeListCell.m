//
//  AwemeListCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "AwemeListCell.h"

#define LIKE_BEFORE_TAP_ACTION 1000
#define LIKE_AFTER_TAP_ACTION 2000
#define COMMENT_TAP_ACTION 3000
#define SHARE_TAP_ACTION 4000

@interface AwemeListCell()<AVPlayerUpdateDelegate>
@property (nonatomic, strong) UIView                   *container;
@property (nonatomic, strong) UIView                   *playerStatusBar;
@property (nonatomic, strong) UITapGestureRecognizer   *singleTapGesture;
@property (nonatomic, assign) NSTimeInterval           lastTapTime;
@property (nonatomic, assign) CGPoint                  lastTapPoint;
@end

@implementation AwemeListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ColorRoseRed;
        self.lastTapTime = 0;
        self.lastTapPoint = CGPointZero;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    //init player view;
    _playerView = [AVPlayerView new];
    _playerView.delegate = self;
    [self.contentView addSubview:_playerView];
    
    //init hover on player view container
    _container = [UIView new];
    [self.contentView addSubview:_container];
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [_container addGestureRecognizer:_singleTapGesture];
    
    //init player status bar
    _playerStatusBar = [[UIView alloc]init];
    _playerStatusBar.backgroundColor = ColorWhite;
    [_playerStatusBar setHidden:YES];
    [_container addSubview:_playerStatusBar];
    
}

-(void)prepareForReuse {
    [super prepareForReuse];
    _isPlayerReady = NO;
    [_playerView cancelLoading];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _playerView.frame = self.bounds;
    _container.frame = self.bounds;
    
    _playerStatusBar.frame = CGRectMake(CGRectGetMidX(self.bounds) - 0.5, CGRectGetMaxY(self.bounds) - 49.5, 1.0, 0.5);
}


//gesture
- (void)handleGesture:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case COMMENT_TAP_ACTION: {
            break;
        }
        case SHARE_TAP_ACTION: {
            break;
        }
        default: {
            //获取点击坐标，用于设置爱心显示位置
            CGPoint point = [sender locationInView:self.container];
            //获取当前时间
            NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
            //判断当前点击时间与上次点击时间的时间间隔
            if(time - self.lastTapTime > 0.25f) {
                //推迟0.25秒执行单击方法
                [self performSelector:@selector(singleTapAction) withObject:nil afterDelay:0.25f];
            }else {
                //取消执行单击方法
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction) object: nil];
            }
            //更新上一次点击位置
            self.lastTapPoint = point;
            //更新上一次点击时间
            self.lastTapTime =  time;
            break;
        }
    }
    
}

- (void)singleTapAction {
    [self.playerView updatePlayerState];
}

//加载动画
-(void)startLoadingPlayItemAnim {
    self.playerStatusBar.backgroundColor = ColorWhite;
    [self.playerStatusBar setHidden:NO];
    [self.playerStatusBar.layer removeAllAnimations];
    
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc]init];
    animationGroup.duration = 0.5;
    animationGroup.beginTime = CACurrentMediaTime() + 0.5;
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation * scaleAnimation = [CABasicAnimation animation];
    scaleAnimation.keyPath = @"transform.scale.x";
    scaleAnimation.fromValue = @(1.0f);
    scaleAnimation.toValue = @(1.0f * SCREEN_WIDTH);
    
    CABasicAnimation * alphaAnimation = [CABasicAnimation animation];
    alphaAnimation.keyPath = @"opacity";
    alphaAnimation.fromValue = @(1.0f);
    alphaAnimation.toValue = @(0.5f);
    [animationGroup setAnimations:@[scaleAnimation, alphaAnimation]];
    [self.playerStatusBar.layer addAnimation:animationGroup forKey:nil];
}

// AVPlayerUpdateDelegate
-(void)onProgressUpdate:(CGFloat)current total:(CGFloat)total {
    //播放进度更新
}

-(void)onPlayItemStatusUpdate:(AVPlayerItemStatus)status {
    switch (status) {
        case AVPlayerItemStatusUnknown:
            [self startLoadingPlayItemAnim];
            break;
        case AVPlayerItemStatusReadyToPlay:
            [self.playerStatusBar.layer removeAllAnimations];
            [self.playerStatusBar setHidden:YES];
            
            self.isPlayerReady = YES;
            
            if(_onPlayerReady) {
                _onPlayerReady();
            }
            break;
        case AVPlayerItemStatusFailed:
            [self.playerStatusBar.layer removeAllAnimations];
            [self.playerStatusBar setHidden:YES];
            NSLog(@"加载失败");
            break;
        default:
            break;
    }
}

// update method
- (void)initData:(NSString *)urlPath {
    [_playerView setPlayerWithUrl:urlPath];
}

-(void)play {
    [_playerView play];
}

-(void)pause {
    [_playerView pause];
}

-(void)replay {
    [_playerView replay];
}

- (void)dealloc {
    _playerView = nil;
}

@end
