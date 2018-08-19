//
//  AwemeListCell.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "AVPlayerView.h"

typedef void (^OnPlayerReady)(void);

@interface AwemeListCell : UITableViewCell

@property (nonatomic, strong) AVPlayerView     *playerView;

@property (nonatomic, strong) OnPlayerReady    onPlayerReady;
@property (nonatomic, assign) BOOL             isPlayerReady;

- (void)initData:(NSString *)urlPath;

-(void)play;

-(void)pause;

-(void)replay;

@end
