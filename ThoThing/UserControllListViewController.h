//
//  UserControllListViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 31..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserControllListViewController : UIViewController
@property (nonatomic, assign) BOOL isMannager;
@property (nonatomic, assign) BOOL isMasterMode;
@property (nonatomic, assign) BOOL isChannel;
@property (nonatomic, assign) BOOL isChannelMode;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSString *str_Mode;

//#채널
@property (nonatomic, strong) NSString *str_ChannelType;
@property (nonatomic, strong) NSString *str_ChannelHashTag;
@end
