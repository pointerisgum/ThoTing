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

@interface AutoChatAudioCell : UITableViewCell
@property (nonatomic, assign) NSInteger nEId;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) IBOutlet UIButton *btn_PlayPause;
@property (nonatomic, weak) IBOutlet UILabel *lb_Time;
@property (nonatomic, weak) IBOutlet UIButton *btn_Replay;
@end
