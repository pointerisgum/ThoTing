//
//  AutoChatAudioCell.h
//  ThoThing
//
//  Created by macpro15 on 2017. 8. 30..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "SWTableViewCell.h"
#import "ExtentionButton.h"

@interface AutoChatAudioCell : SWTableViewCell
@property (nonatomic, assign) long long nEId;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) long long messageId;
@property (nonatomic, assign) CGFloat fPlayDuration;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) IBOutlet UIView *v_Bg;
@property (nonatomic, weak) IBOutlet ExtentionButton *btn_PlayPause;
@property (nonatomic, weak) IBOutlet UILabel *lb_Time;
@property (nonatomic, weak) IBOutlet UILabel *lb_BgTime;
@property (nonatomic, weak) IBOutlet UIButton *btn_Replay;
@end
