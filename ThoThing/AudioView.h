//
//  AudioView.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 15..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@interface AudioView : UIView
{
    CGFloat fDuration;
    NSString *str_HttpUrl;
    BOOL isSeeking;
}
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) IBOutlet UIButton *btn_Play;
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentTime;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalTime;

- (void)initPlayer:(NSString *)aUrl;
- (void)initPlayer:(NSString *)aUrl whitViewing:(BOOL)isViewwing;
- (void)pause;
- (void)resume;
- (void)stop;
@end
