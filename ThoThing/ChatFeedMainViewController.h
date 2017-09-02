//
//  ChatFeedMainViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatFeedMainViewController : UIViewController
@property (nonatomic, assign) BOOL isChannelMode;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSDictionary *dic_ChannelData;
- (void)updateSendBirdDelegate;
@end
