//
//  AudioView.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 15..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "AudioView.h"

@implementation AudioView
- (void)awakeFromNib
{
    [super awakeFromNib];
//    self.btn_Play.layer.cornerRadius = self.btn_Play.frame.size.width/2;
//    self.btn_Play.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.btn_Play.layer.borderWidth = 1.f;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)initPlayer:(NSString *)aUrl whitViewing:(BOOL)isViewwing
{
    str_HttpUrl = aUrl;
    
    self.slider.hidden = self.lb_TotalTime.hidden = self.lb_CurrentTime.hidden = YES;
//    NSURL *url = [NSURL URLWithString:aUrl];
//    self.playerItem = [AVPlayerItem playerItemWithURL:url];
//    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//    self.player = [AVPlayer playerWithURL:url];
    //    self.lb_TotalTime.backgroundColor = [UIColor blackColor];
    
//    fDuration = CMTimeGetSeconds(self.playerItem.asset.duration);
//    NSLog(@"%f", fDuration);
//    NSInteger nMinute = (NSInteger)fDuration / 60;
//    NSInteger nSecond = (NSInteger)fDuration % 60;
//    
//    self.lb_CurrentTime.text = @"00:00";
//    self.lb_TotalTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:[self.player currentItem]];
//    //
//    //    [[NSNotificationCenter defaultCenter] addObserver:self
//    //                                             selector:@selector(playerItemDidReachEnd:)
//    //                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//    //                                               object:[self.player currentItem]];
//    
//    //    _observer =
//    __weak __typeof(&*self)weakSelf = self;
//    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2)
//                                              queue:dispatch_get_main_queue()
//                                         usingBlock:^(CMTime time)
//     {
//         if( isSeeking == NO )
//         {
//             CGFloat fCurrentTime = CMTimeGetSeconds(time);
//             weakSelf.slider.value = fCurrentTime / fDuration;
//             
//             NSInteger nMinute = (NSInteger)fCurrentTime / 60;
//             NSInteger nSecond = (NSInteger)fCurrentTime % 60;
//             weakSelf.lb_CurrentTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
//             
//             NSLog(@"%f", CMTimeGetSeconds(time));
//         }
//     }];
}

- (void)initPlayer:(NSString *)aUrl
{
//    NSString *str_Body = [btn.dic_Info objectForKey:@"questionBody"];
//    NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
    str_HttpUrl = aUrl;
    
    [self stop];
    
    NSURL *url = [NSURL URLWithString:aUrl];
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player = [AVPlayer playerWithURL:url];
//    self.lb_TotalTime.backgroundColor = [UIColor blackColor];
    
    fDuration = CMTimeGetSeconds(self.playerItem.asset.duration);
    NSLog(@"%f", fDuration);
    NSInteger nMinute = (NSInteger)fDuration / 60;
    NSInteger nSecond = (NSInteger)fDuration % 60;
    
    self.lb_CurrentTime.text = @"00:00";
    self.lb_TotalTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:[self.player currentItem]];

//    _observer =
    __weak __typeof(&*self)weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2)
                                               queue:dispatch_get_main_queue()
                                          usingBlock:^(CMTime time)
     {
         if( isSeeking == NO )
         {
             CGFloat fCurrentTime = CMTimeGetSeconds(time);
             weakSelf.slider.value = fCurrentTime / fDuration;
             
             NSInteger nMinute = (NSInteger)fCurrentTime / 60;
             NSInteger nSecond = (NSInteger)fCurrentTime % 60;
             weakSelf.lb_CurrentTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
             
             NSLog(@"%f", CMTimeGetSeconds(time));
         }
     }];
}


- (IBAction)goPlayToggle:(id)sender
{
    if ((self.player.rate != 0) && (self.player.error == nil))
    {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }

    self.btn_Play.selected = !self.btn_Play.selected;
}

- (IBAction)goSliderTouchDown:(id)sender
{
    isSeeking = YES;
}

- (IBAction)goSliderTouchUp:(id)sender
{
    CMTime videoLength = self.player.currentItem.asset.duration;  // Gets the video duration
    float videoLengthInSeconds = videoLength.value/videoLength.timescale; // Transfers the CMTime duration into seconds
    
    [self.player seekToTime:CMTimeMakeWithSeconds(videoLengthInSeconds * [self.slider value], 1)
          completionHandler:^(BOOL finished)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             isSeeking = NO;
             // Do some stuff
         });
     }];
}

- (IBAction)goSkeep:(id)sender
{
    CGFloat fCurrentTime = fDuration * self.slider.value;
    self.slider.value = fCurrentTime / fDuration;
    
    NSInteger nMinute = (NSInteger)fCurrentTime / 60;
    NSInteger nSecond = (NSInteger)fCurrentTime % 60;
    self.lb_CurrentTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self.player pause];
    self.btn_Play.selected = NO;
    self.slider.value = 0;
    [self initPlayer:str_HttpUrl];
}

- (void)pause
{
    if ((self.player.rate != 0) && (self.player.error == nil))
    {
        [self.player pause];
    }
    
    self.btn_Play.selected = NO;

    [self.player pause];
}

- (void)resume
{
    self.btn_Play.selected = YES;

    [self.player play];
}

- (void)stop
{
    if( self.player )
    {
        [self.player seekToTime:CMTimeMake(0, 1)];
        [self.player pause];
    }
}

@end
