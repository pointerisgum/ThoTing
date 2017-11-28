//
//  KikRoomInfoViewController.h
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 27..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kOneOnOne       = 1,
    kGroup          = 2,
    kOpenGroup      = 3,
    kBot            = 4,
}RoomType;

@interface KikRoomInfoViewController : UIViewController
@property (nonatomic, assign) RoomType roomType;
@property (strong, nonatomic) SBDGroupChannel *channel;
@property (strong, nonatomic) NSDictionary *dic_Info;
@property (nonatomic, strong) NSString *str_RoomTitle;
@property (nonatomic, strong) NSString *str_RoomThumb;
@property (nonatomic, strong) NSString *str_MemberCount;
@property (nonatomic, strong) NSString *str_TargetUserName;
@property (nonatomic, strong) NSString *str_Tag;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NSString *str_ChannelUrl;
@property (nonatomic, strong) NSString *str_ChatBotThumUrl;

@property (nonatomic, assign) BOOL isFromRoom;  //챗방에서 진입


//오픈그룹 상세에서 이동할때 파라미터는 이것만 보냄
//이걸 받고 api로 정보를 받아와서 뿌려줌
@property (nonatomic, strong) NSString *str_QuestionId;

//봇 만들기일 경우
@property (nonatomic, strong) NSString *str_BotId;
@end
