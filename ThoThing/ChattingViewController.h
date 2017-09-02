//
//  ChattingViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 6..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChattingViewController : UIViewController
@property (nonatomic, assign) BOOL isMove;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSString *str_RId;    //채팅방 ID
@property (nonatomic, strong) NSDictionary *dic_Info;

//마이페이지용
@property (nonatomic, assign) BOOL isMyMode;
@property (nonatomic, strong) UIImage *i_User;

@end
