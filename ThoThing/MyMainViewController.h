//
//  MyMainViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMainViewController : YmBaseViewController
@property (nonatomic, assign) BOOL isManagerView;
@property (nonatomic, assign) BOOL isPermission;
@property (nonatomic, assign) BOOL isShowNavi;
@property (nonatomic, assign) BOOL isAnotherUser;
@property (nonatomic, assign) BOOL isModalMode;         //초대로 들어올 경우 모달로 처리
@property (nonatomic, strong) NSString *str_UserIdx;
@property (nonatomic, strong) NSString *str_ChannelId;
@end
