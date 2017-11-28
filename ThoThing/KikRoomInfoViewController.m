//
//  KikRoomInfoViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 27..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikRoomInfoViewController.h"
#import "ChatMemberListViewController.h"
#import "RoomInfoUserCell.h"
#import "ChatFeedViewController.h"
#import "KikMakeBotsViewController.h"
#import "KikMyViewController.h"
#import "KikAddMemberViewController.h"
#import "KikRoomModifyViewController.h"
#import "StarView.h"

@interface KikRoomInfoViewController () <StarViewDelegate>
{
    NSString *str_UserImagePrefix;
    NSString *str_SBDChannelUrl;
    NSString *str_RId;
    
    BOOL isMaker;                   //만든사람
}
@property (nonatomic, strong) NSMutableArray *arM_UserList;
@property (nonatomic, strong) NSDictionary *dic_TopInfo;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UILabel *lb_MainTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_TitleMemberCount;
@property (nonatomic, weak) IBOutlet UILabel *lb_MemberCount;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TitleHeight;
@property (nonatomic, weak) IBOutlet UICollectionView *cv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_Action;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TopInfoHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_JoinHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ThumbWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ThumbHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_HashTagHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_StarViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_StarDescripHeight;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb1;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb2;
@property (nonatomic, weak) IBOutlet UIImageView *iv_ThumbBg;
@property (nonatomic, weak) IBOutlet StarView *v_Star;
@property (nonatomic, weak) IBOutlet UILabel *lb_StarCount;
@end

@implementation KikRoomInfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.v_Star.delegate = self;

    if( self.roomType == kBot )
    {
        self.lb_MainTitle.text = @"";
    }
    
    
//    if( self.roomType == kOneOnOne )
//    {
//
//    }
//    else if( self.roomType == kGroup )
//    {
//
//    }
//    else if( self.roomType == kOpenGroup )
//    {
//
//    }
//    else if( self.roomType == kBot )
//    {
//
//    }
    
    
//    if( self.str_QuestionId )
//    {
//        self.lb_Title.text = self.str_RoomTitle;
//        self.lb_TitleMemberCount.text = @"";
////        self.lc_TitleHeight.constant = 22.f;
////        [self updateList];
//    }
//    else
//    {
//        if( self.str_RoomTitle.length > 0 && [self.str_MemberCount integerValue] > 2 )
//        {
//            self.lb_Title.text = self.str_RoomTitle;
//            self.lb_TitleMemberCount.text = [NSString stringWithFormat:@"%@명의 회원", self.str_MemberCount];
//            self.lc_TitleHeight.constant = 22.f;
//        }
//        else
//        {
//            self.lb_Title.text = self.str_TargetUserName;
//            self.lc_TitleHeight.constant = 44.f;
//        }
//
//        if( self.str_RoomThumb && self.str_RoomThumb.length > 0 )
//        {
//            [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:self.str_RoomThumb]];
//        }
//        else
//        {
//            self.iv_Thumb.backgroundColor = self.bgColor;
//            self.lb_MemberCount.text = self.str_MemberCount;
//        }
//    }
    
//    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak __typeof(&*self)weakSelf = self;
    
    if( self.channel == nil )
    {
        if( self.str_ChannelUrl.length > 0 )
        {
            [SBDGroupChannel getChannelWithUrl:self.str_ChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                
                weakSelf.channel = channel;
                
                NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[weakSelf.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                NSInteger nOwnerId = [[dic_Data objectForKey:@"ownerId"] integerValue];
                
                weakSelf.arM_UserList = [NSMutableArray arrayWithCapacity:weakSelf.channel.memberCount];
                for( NSInteger i = 0; i < weakSelf.channel.memberCount; i++ )
                {
                    SBDUser *user = self.channel.members[i];
                    if( nOwnerId == [user.userId integerValue] )
                    {
                        [weakSelf.arM_UserList insertObject:user atIndex:0];
                    }
                    else
                    {
                        [weakSelf.arM_UserList addObject:user];
                    }
                }
                
                [weakSelf initRoomInfo];
                [weakSelf updateTopList];
            }];
        }
    }
    else
    {
        NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSInteger nOwnerId = [[dic_Data objectForKey:@"ownerId"] integerValue];
        
        self.arM_UserList = [NSMutableArray arrayWithCapacity:self.channel.memberCount];
        for( NSInteger i = 0; i < self.channel.memberCount; i++ )
        {
            SBDUser *user = self.channel.members[i];
            if( nOwnerId == [user.userId integerValue] )
            {
                [self.arM_UserList insertObject:user atIndex:0];
            }
            else
            {
                [self.arM_UserList addObject:user];
            }
        }
        
        [self initRoomInfo];
        [self updateTopList];
    }
    
    self.iv_Thumb1.backgroundColor = [UIColor whiteColor];
    self.iv_Thumb1.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_Thumb1.clipsToBounds = YES;
    self.iv_Thumb1.layer.cornerRadius = self.iv_Thumb1.frame.size.width / 2;
    self.iv_Thumb1.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
    self.iv_Thumb1.layer.borderWidth = 1.f;
    
    self.iv_Thumb2.backgroundColor = [UIColor whiteColor];
    self.iv_Thumb2.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_Thumb2.clipsToBounds = YES;
    self.iv_Thumb2.layer.cornerRadius = self.iv_Thumb2.frame.size.width / 2;
    self.iv_Thumb2.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
    self.iv_Thumb2.layer.borderWidth = 1.f;
    
    self.iv_ThumbBg.layer.cornerRadius = self.iv_ThumbBg.frame.size.width / 2;
    self.iv_ThumbBg.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
    self.iv_ThumbBg.layer.borderWidth = 1.f;
    
    self.lb_MemberCount.hidden = YES;
    
    
    if( 0 )
    {
        self.iv_Thumb.layer.cornerRadius = 20.f;
        self.lc_ThumbWidth.constant = 118.f;
        self.lc_ThumbHeight.constant = 118.f;
    }
    else
    {
        self.iv_Thumb.layer.cornerRadius = self.iv_Thumb.frame.size.width / 2;
        self.lc_ThumbWidth.constant = 120.f;
        self.lc_ThumbHeight.constant = 120.f;
    }
    
    self.iv_Thumb.layer.borderWidth = 1.f;
    self.iv_Thumb.layer.borderColor = kRoundColor.CGColor;
    
    if( self.isFromRoom )
    {
        self.lc_JoinHeight.constant = 0.f;
    }
    else
    {
        self.lc_JoinHeight.constant = 50.f;
        
        if( self.roomType == kBot )
        {
//            self.lc_TopInfoHeight.constant = 196.f + 21.f;
//            self.lc_HashTagHeight.constant = 18.f;
            [self.btn_Action setTitle:@"Start" forState:UIControlStateNormal];
        }
        else
        {
            [self.btn_Action setTitle:@"참여하기" forState:UIControlStateNormal];
//            self.lc_TopInfoHeight.constant = 196.f;
        }
    }
    
    
}

- (void)initRoomInfo
{
    //17.11.13새로 만든거
    self.iv_ThumbBg.hidden = YES;
    self.iv_Thumb.hidden = NO;
    self.iv_Thumb1.hidden = YES;
    self.iv_Thumb2.hidden = YES;
    
    if( self.channel.memberCount <= 2 )
    {
        //1:1chat
        if( self.channel.memberCount == 1 )
        {
            SBDUser *user = self.channel.members[0];
            self.lb_Title.text = user.nickname;
            [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
        }
        else
        {
            for( NSInteger i = 0; i < self.channel.memberCount; i++ )
            {
                SBDUser *user = self.channel.members[i];
                NSString *str_MyUserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                if( [str_MyUserId isEqualToString:user.userId] == NO )
                {
                    self.lb_Title.text = user.nickname;
                    [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
                    break;
                }
            }
        }
    }
    else
    {
        //group chat
        NSLog(@"groupChannel.customType: %@", self.channel.customType);
        if( [self.channel.customType isEqualToString:@"channel"] )
        {
            //섬네일이 있는 그룹방
            [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:self.channel.coverUrl] placeholderImage:BundleImage(@"")];
        }
        else if( [self.channel.customType isEqualToString:@"opengroup"] )
        {
            //이건 #채널 (항상 이미지와 타이틀이 있음)
            [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:self.channel.coverUrl] placeholderImage:BundleImage(@"")];
        }
        else if( [self.channel.customType isEqualToString:@"group"] )
        {
            //이름과 섬네일이 없는 그룹방
            if( self.channel.coverUrl.length > 0 )
            {
                [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:self.channel.coverUrl] placeholderImage:BundleImage(@"")];
            }
            else
            {
                self.iv_Thumb.hidden = YES;
                self.iv_Thumb1.hidden = NO;
                self.iv_Thumb2.hidden = NO;
                
                NSMutableArray *arM = [NSMutableArray arrayWithArray:self.channel.members];
                for( NSInteger i = 0; i < arM.count; i++ )
                {
                    //그룹 챗일 경우 내 이미지는 제거한다
                    SBDUser *user = arM[i];
                    NSString *str_MyId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                    if( [str_MyId isEqualToString:user.userId] )
                    {
                        [arM removeObjectAtIndex:i];
                        break;
                    }
                }
                
                for( NSInteger i = 0; i < 2; i++ )
                {
                    SBDUser *user = arM[i];
                    if( i == 0 )
                    {
                        [self.iv_Thumb1 sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
                    }
                    else if( i == 1 )
                    {
                        [self.iv_Thumb2 sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
                    }
                }
            }
        }
        else
        {
            //그 외엔 1:1로 침
            for( NSInteger i = 0; i < self.channel.memberCount; i++ )
            {
                SBDUser *user = self.channel.members[i];
                NSString *str_MyUserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                if( [str_MyUserId isEqualToString:user.userId] == NO )
                {
                    [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
                    break;
                }
            }
        }
        
        self.lb_Title.text = self.channel.name;
    }
}

- (void)viewWillLayoutSubviews;
{
    [super viewWillLayoutSubviews];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.cv_List.collectionViewLayout;
    
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 5, ([UIScreen mainScreen].bounds.size.width / 5) + 20);

    [flowLayout invalidateLayout]; //force the elements to get laid out again with the new size
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateList
{
    __weak __typeof(&*self)weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"0", @"channelId",
                                        self.str_QuestionId, @"questionId",
                                        @"invite", @"listMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/qna/chat/room/invite/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                str_UserImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
//                                                weakSelf.arM_UserList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
//                                                weakSelf.lb_TitleMemberCount.text = [NSString stringWithFormat:@"%ld명의 회원", weakSelf.arM_UserList.count];

                                                str_RId = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"rId"]];
                                                str_SBDChannelUrl = [resulte objectForKey_YM:@"sendbirdChannelUrl"];
                                                
                                                if( weakSelf.roomType == kBot )
                                                {
                                                    [weakSelf.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:weakSelf.str_RoomThumb]];
                                                }
                                                else
                                                {
                                                    if( weakSelf.str_QuestionId )
                                                    {
//                                                        weakSelf.lb_TitleMemberCount.text = [NSString stringWithFormat:@"%ld명의 회원", weakSelf.arM_UserList.count];
                                                        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [resulte objectForKey_YM:@"channelImgUrl"]];
                                                        [weakSelf.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                                                    }
                                                }

//                                                for( NSInteger i = 0; i < weakSelf.arM_UserList.count; i++ )
//                                                {
//                                                    NSDictionary *dic = weakSelf.arM_UserList[i];
//                                                    BOOL isOwner = [[dic objectForKey_YM:@"isOwner"] isEqualToString:@"Y"];
//                                                    if( isOwner )
//                                                    {
//                                                        [weakSelf.arM_UserList exchangeObjectAtIndex:0 withObjectAtIndex:i];
//                                                        break;
//                                                    }
//                                                }
                                            }
                                            
                                            [weakSelf updateTopList];
                                        }
                                    }];
}

- (void)updateTopList
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    if( self.channel.memberCount > 2 )
    {
//        self.lb_Title.text = @"";
        self.lb_TitleMemberCount.text = [NSString stringWithFormat:@"%@명의 회원", self.str_MemberCount];
        self.lc_TitleHeight.constant = 22.f;
    }
    else
    {
        self.lb_TitleMemberCount.text = @"";
        self.lc_TitleHeight.constant = 44.f;
    }
    

    NSString *str_Tag = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"hashTag"]];
    if( str_Tag.length > 0 )
    {
//        self.lc_TopInfoHeight.constant = 196.f + 21.f;
        self.lc_HashTagHeight.constant = 18.f;
        self.lb_Tag.text = [NSString stringWithFormat:@"%@", str_Tag];
    }
    else
    {
//        self.lc_TopInfoHeight.constant = 196.f;
        self.lb_Tag.text = @"";
    }

    
    NSInteger nBotUserId = [[dic objectForKey:@"botUserId"] integerValue];
    if( nBotUserId > 0 )
    {
        //챗봇이면 네비 유저 수 표현하지 않기
        self.lc_TitleHeight.constant = 44.f;
        self.lb_TitleMemberCount.text = @"";
    }
    else
    {
        //챗봇이 아닌 경우에만 하단 유저 리스트 표현
        self.lc_TitleHeight.constant = 44.f;
        [self.cv_List reloadData];
    }

    __weak __typeof(&*self)weakSelf = self;

    NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", [[dic_Data objectForKey:@"rId"] integerValue]], @"rId",
                                        nil];

//    SBDUser *user = [self.channel.members objectAtIndex:0];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/chat/room/header/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {

                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.dic_TopInfo = [NSDictionary dictionaryWithDictionary:resulte];
                                                
                                                NSInteger nMyId = [[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] integerValue];
                                                NSInteger nMakerId = [[NSString stringWithFormat:@"%@", [resulte objectForKey:@"chatBotOwnerId"]] integerValue];
                                                if( nMyId == nMakerId )
                                                {
                                                    isMaker = YES;
                                                }
                                                
                                                NSString *str_Tag = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"hashTagStr"]];
                                                if( str_Tag.length > 0 )
                                                {
//                                                    weakSelf.lc_TopInfoHeight.constant = 196.f + 21.f;
                                                    weakSelf.lc_HashTagHeight.constant = 18.f;
                                                    weakSelf.lb_Tag.text = [NSString stringWithFormat:@"%@", str_Tag];
                                                }
                                                
                                                
                                                
                                                
                                                if( self.roomType == kBot )
                                                {
                                                    [weakSelf updateChatBot];
                                                }
                                                
//                                                if( self.roomType == kBot )
//                                                {
//                                                    self.lb_MainTitle.text = @"";
//                                                    self.lc_StarViewHeight.constant = 45.f;  //45.f
//                                                }
//
//
//                                                self.lc_StarDescripHeight.constant = 17.f;   //17.f
//
//
//                                                if( 1 )
//                                                {
//                                                    //평가완료 했으면
//                                                    self.lc_StarDescripHeight.constant = 0.f;   //17.f
//                                                    self.v_Star.userInteractionEnabled = NO;
//
//                                                }
//                                                else
//                                                {
//                                                    //평가완료하지 않았으면
//                                                    self.lc_StarDescripHeight.constant = 17.f;   //17.f
//                                                    self.v_Star.userInteractionEnabled = YES;
//                                                }

                                            }
                                        }
                                    }];
}

- (void)updateChatBot
{
    __weak __typeof(&*self)weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_TopInfo objectForKey:@"botId"]], @"botId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/chatbot/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic_BotInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"chatBotInfo"]];
                                                
                                                weakSelf.lb_MainTitle.text = [NSString stringWithFormat:@"사용자 %@명", [dic_BotInfo objectForKey:@"userCount"]];
                                                
                                                NSInteger nStarUserCount = [[dic_BotInfo objectForKey:@"starUserCount"] integerValue];
                                                weakSelf.lb_StarCount.text = [NSString stringWithFormat:@"(%ld)", nStarUserCount];
                                                
                                                NSInteger nMyStarCount = [[dic_BotInfo objectForKey:@"myStarCount"] integerValue];
                                                if( nMyStarCount <= 0 )
                                                {
                                                    //0이면 평가 안했음
                                                    weakSelf.lc_StarDescripHeight.constant = 17.f;   //17.f
                                                    weakSelf.v_Star.userInteractionEnabled = YES;
                                                }
                                                else
                                                {
                                                    //평가 했으면
                                                    NSInteger nScore = [[dic_BotInfo objectForKey:@"avgStarCount"] integerValue];
                                                    weakSelf.lc_StarDescripHeight.constant = 0.f;   //17.f
                                                    weakSelf.v_Star.userInteractionEnabled = NO;
                                                    [weakSelf.v_Star setStarScore:nScore];
                                                }
                                            }
                                        }
                                    }];
}

- (void)sendSendBirdPlatformApi:(NSString *)aType
{
    [UIAlertController showAlertInViewController:self
                                       withTitle:@""
                                         message:@"채팅방을 나가시겠습니까?"
                               cancelButtonTitle:@"취소"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                            if (buttonIndex == controller.cancelButtonIndex)
                                            {
                                                NSLog(@"Cancel Tapped");
                                            }
                                            else if (buttonIndex == controller.destructiveButtonIndex)
                                            {
                                                NSLog(@"Delete Tapped");
                                            }
                                            else if (buttonIndex >= controller.firstOtherButtonIndex)
                                            {
                                                __weak __typeof(&*self)weakSelf = self;
                                                
                                                //나감
                                                SBDUser *user = [SBDMain getCurrentUser];
                                                NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다", user.nickname];
                                                NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
                                                [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
                                                [dicM_Param setObject:user.userId forKey:@"user_id"];
                                                [dicM_Param setObject:str_Msg forKey:@"message"];
                                                [dicM_Param setObject:@"USER_LEFT" forKey:@"custom_type"];
                                                [dicM_Param setObject:@"true" forKey:@"is_silent"];
                                                
                                                NSMutableDictionary *dicM_MessageData = [NSMutableDictionary dictionary];
                                                [dicM_MessageData setObject:str_Msg forKey:@"message"];
                                                
                                                NSMutableDictionary *dicM_Sender = [NSMutableDictionary dictionary];
                                                [dicM_Sender setObject:user.nickname forKey:@"nickname"];
                                                [dicM_Sender setObject:user.userId forKey:@"user_id"];
                                                [dicM_MessageData setObject:dicM_Sender forKey:@"sender"];
                                                
                                                NSError *error;
                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_MessageData
                                                                                                   options:NSJSONWritingPrettyPrinted
                                                                                                     error:&error];
                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                [dicM_Param setObject:jsonString forKey:@"data"];
                                                
                                                NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
                                                [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
                                                                                         param:dicM_Param
                                                                                    withMethod:@"POST"
                                                                                     withBlock:^(id resulte, NSError *error) {
                                                                                         
                                                                                         if( resulte )
                                                                                         {
                                                                                             [weakSelf.channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                                                                                                 
                                                                                             }];
                                                                                             
                                                                                             [weakSelf performSelector:@selector(onPopControllerInterval) withObject:nil afterDelay:0.3f];
                                                                                         }
                                                                                     }];
                                                
                                                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                                                //        NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
                                                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                                    [Util getUUID], @"uuid",
                                                                                    [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]], @"rId",
                                                                                    nil];
                                                
                                                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/chat/room/leave"
                                                                                    param:dicM_Params
                                                                               withMethod:@"POST"
                                                                                withBlock:^(id resulte, NSError *error) {
                                                                                    
                                                                                    [MBProgressHUD hide];
                                                                                    
                                                                                    if( resulte )
                                                                                    {
                                                                                        NSLog(@"resulte : %@", resulte);
                                                                                        
                                                                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                                        if( nCode == 200 )
                                                                                        {
                                                                                            
                                                                                        }
                                                                                    }
                                                                                }];
                                            }
                                        }];
}

- (void)onPopControllerInterval
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark - StarViewDelegate
- (void)didUpdateStarView:(NSInteger)nScore
{
    NSLog(@"%ld", nScore);
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@""
                                         message:[NSString stringWithFormat:@"이 봇 점수를 %ld점으로 평가하시겠습니까?", nScore]
                               cancelButtonTitle:@"취소"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                            if (buttonIndex == controller.cancelButtonIndex)
                                            {
                                                NSLog(@"Cancel Tapped");
                                            }
                                            else if (buttonIndex == controller.destructiveButtonIndex)
                                            {
                                                NSLog(@"Delete Tapped");
                                            }
                                            else if (buttonIndex >= controller.firstOtherButtonIndex)
                                            {
                                                __weak __typeof(&*self)weakSelf = self;
                                                
                                                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                                    [Util getUUID], @"uuid",
                                                                                    [NSString stringWithFormat:@"%@", [self.dic_TopInfo objectForKey:@"botId"]], @"botId",
                                                                                    [NSString stringWithFormat:@"%ld", nScore], @"starCount",
                                                                                    nil];
                                                
                                                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/chatbot/star"
                                                                                    param:dicM_Params
                                                                               withMethod:@"POST"
                                                                                withBlock:^(id resulte, NSError *error) {
                                                                                    
                                                                                    if( resulte )
                                                                                    {
                                                                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                                        if( nCode == 200 )
                                                                                        {
                                                                                            [weakSelf updateChatBot];
                                                                                            [Util showToast:@"평가 되었습니다"];
                                                                                        }
                                                                                    }
                                                                                }];
                                            }
                                        }];
}



#pragma mark - IBAction
- (IBAction)goMenu:(id)sender
{
    NSMutableArray *arM = [NSMutableArray array];

    if( self.roomType == kBot )
    {
        if( isMaker )
        {
            [arM addObject:@"봇 수정"];
            [arM addObject:@"봇 삭제"];
            [arM addObject:@"나가기"];

            [OHActionSheet showSheetInView:self.view
                                     title:nil
                         cancelButtonTitle:@"취소"
                    destructiveButtonTitle:nil
                         otherButtonTitles:arM
                                completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
             {
                 if( buttonIndex == 0 )
                 {
                     //수정하기
                     /*
                      chatThumbnail: #오픈그룹인 경우 커버 이미지 url, 챗봇인 경우 챗봇 썸네일
                      examId: 챗봇에서 사용하는 문제지 ID
                      chatBotHashTag: 챗봇 해시태그
                      examIdStr: 챗봇 생성시 등록한 문제지 정보
                      chatBotOwnerId: 챗봇 만든 사용자 ID
                      */
                     //weakSelf.dic_TopInfo
                     KikMakeBotsViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikMakeBotsViewController"];
                     vc.dic_ModifyData = self.dic_TopInfo;
                     [self.navigationController pushViewController:vc animated:YES];
                 }
                 else if( buttonIndex == 1 )
                 {
                     __weak __typeof(&*self)weakSelf = self;
                     
                     [UIAlertController showAlertInViewController:self
                                                        withTitle:@""
                                                          message:@"삭제 하시겠습니까?"
                                                cancelButtonTitle:@"취소"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@[@"확인"]
                                                         tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                             
                                                             if (buttonIndex == controller.cancelButtonIndex)
                                                             {
                                                                 NSLog(@"Cancel Tapped");
                                                             }
                                                             else if (buttonIndex == controller.destructiveButtonIndex)
                                                             {
                                                                 NSLog(@"Delete Tapped");
                                                             }
                                                             else if (buttonIndex >= controller.firstOtherButtonIndex)
                                                             {
                                                                 //봇 삭제
                                                                 [weakSelf removeChatBot];
                                                             }
                                                         }];
                 }
                 else if( buttonIndex == 2 )
                 {
                     [self sendSendBirdPlatformApi:@"leaveChat"];
                 }
             }];
        }
        else
        {
            [arM addObject:@"나가기"];
            [OHActionSheet showSheetInView:self.view
                                     title:nil
                         cancelButtonTitle:@"취소"
                    destructiveButtonTitle:nil
                         otherButtonTitles:arM
                                completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
             {
                 if( buttonIndex == 0 )
                 {
                     [self sendSendBirdPlatformApi:@"leaveChat"];
                 }
             }];
        }
    }
//    else if( [self.channel.customType isEqualToString:@"opengroup"] )
    else if( self.str_RoomTitle.length > 0 && [self.str_MemberCount integerValue] > 2 )
    {
        NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSInteger nOwnerId = [[dic_Data objectForKey:@"ownerId"] integerValue];
        SBDUser *user = [SBDMain getCurrentUser];
        if( nOwnerId == [user.userId integerValue] )
        {
            //회원보기, 신고하기, 취소
            [arM addObject:@"수정하기"];
            [arM addObject:@"초대하기"];
            //        [arM addObject:@"회원보기"];
            [arM addObject:@"신고하기"];
            [arM addObject:@"나가기"];
            
            [OHActionSheet showSheetInView:self.view
                                     title:nil
                         cancelButtonTitle:@"취소"
                    destructiveButtonTitle:nil
                         otherButtonTitles:arM
                                completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
             {
                 if( buttonIndex == 0 )
                 {
                     //수정하기
                     KikRoomModifyViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomModifyViewController"];
                     vc.channel = self.channel;
                     [self.navigationController pushViewController:vc animated:YES];
                 }
                 else if( buttonIndex == 1 )
                 {
                     NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                     
                     KikAddMemberViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikAddMemberViewController"];
                     vc.channel = self.channel;
                     vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic_Data];
                     //                 vc.str_QuestionId = [NSString stringWithFormat:@"%ld", [[dic_Data objectForKey:@"questionId"] integerValue]];
                     [self.navigationController pushViewController:vc animated:YES];
                 }
                 //             else if( buttonIndex == 1 )
                 //             {
                 //                 //회원보기
                 //                 ChatMemberListViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"ChatMemberListViewController"];
                 //                 vc.channel = self.channel;
                 //                 vc.dic_Info = self.dic_Info;
                 //                 [self.navigationController pushViewController:vc animated:YES];
                 //             }
                 else if( buttonIndex == 2 )
                 {
                     //신고하기
                     [self reportChatRoom];
                 }
                 else if( buttonIndex == 3 )
                 {
                     [self sendSendBirdPlatformApi:@"leaveChat"];
                 }
             }];
        }
        else
        {
            //회원보기, 신고하기, 취소
            [arM addObject:@"초대하기"];
            //        [arM addObject:@"회원보기"];
            [arM addObject:@"신고하기"];
            [arM addObject:@"나가기"];
            
            [OHActionSheet showSheetInView:self.view
                                     title:nil
                         cancelButtonTitle:@"취소"
                    destructiveButtonTitle:nil
                         otherButtonTitles:arM
                                completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
             {
                 if( buttonIndex == 0 )
                 {
                     NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                     
                     KikAddMemberViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikAddMemberViewController"];
                     vc.channel = self.channel;
                     vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic_Data];
                     //                 vc.str_QuestionId = [NSString stringWithFormat:@"%ld", [[dic_Data objectForKey:@"questionId"] integerValue]];
                     [self.navigationController pushViewController:vc animated:YES];
                 }
                 //             else if( buttonIndex == 1 )
                 //             {
                 //                 //회원보기
                 //                 ChatMemberListViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"ChatMemberListViewController"];
                 //                 vc.channel = self.channel;
                 //                 vc.dic_Info = self.dic_Info;
                 //                 [self.navigationController pushViewController:vc animated:YES];
                 //             }
                 else if( buttonIndex == 1 )
                 {
                     //신고하기
                     [self reportChatRoom];
                 }
                 else if( buttonIndex == 2 )
                 {
                     [self sendSendBirdPlatformApi:@"leaveChat"];
                 }
             }];
        }
    }
    else
    {
        //1:1방
        [arM addObject:@"초대하기"];
        [arM addObject:@"신고하기"];
        [arM addObject:@"나가기"];

        [OHActionSheet showSheetInView:self.view
                                 title:nil
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:nil
                     otherButtonTitles:arM
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

                 KikAddMemberViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikAddMemberViewController"];
                 vc.channel = self.channel;
                 NSDictionary *dic = [dic_Data objectForKey:@"qnaRoomInfos"];
                 if( dic )
                 {
                     dic_Data = dic;
                 }
                 vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic_Data];
                 [self.navigationController pushViewController:vc animated:YES];
             }
             else if( buttonIndex == 1 )
             {
                 [self reportChatRoom];
             }
             else if( buttonIndex == 2 )
             {
                 [self sendSendBirdPlatformApi:@"leaveChat"];
             }
         }];
    }
}

- (void)removeChatBot
{
    __weak __typeof(&*self)weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_TopInfo objectForKey:@"botId"]], @"botId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/delete/chatbot"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                [Util showToast:@"삭제 되었습니다"];
                                                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                                            }
                                        }
                                    }];
}

- (void)reportChatRoom
{
    __weak __typeof(&*self)weakSelf = self;
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@""
                                         message:@"신고하시겠습니까?"
                               cancelButtonTitle:@"취소"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                            if (buttonIndex == controller.cancelButtonIndex)
                                            {
                                                NSLog(@"Cancel Tapped");
                                            }
                                            else if (buttonIndex == controller.destructiveButtonIndex)
                                            {
                                                NSLog(@"Delete Tapped");
                                            }
                                            else if (buttonIndex >= controller.firstOtherButtonIndex)
                                            {
                                                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                                    [Util getUUID], @"uuid",
                                                                                    weakSelf.channel.channelUrl, @"sendbirdChannelUrl",
                                                                                    nil];
                                                
                                                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/group/channel/set/report"
                                                                                    param:dicM_Params
                                                                               withMethod:@"POST"
                                                                                withBlock:^(id resulte, NSError *error) {
                                                                                    
                                                                                    [MBProgressHUD hide];
                                                                                    
                                                                                    if( resulte )
                                                                                    {
                                                                                        NSLog(@"resulte : %@", resulte);
                                                                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                                        if( nCode == 200 )
                                                                                        {
                                                                                            [Util showToast:@"신고하였습니다"];
                                                                                        }
                                                                                    }
                                                                                }];
                                            }
                                        }];
}



#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arM_UserList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"RoomInfoUserCell";
    
    RoomInfoUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    /*
     cc = 1;
     channelId = 4;
     imgUrl = "000/000/f51df8be247438d5a6df1cf4ab5da74a.jpg";
     isMemberAllow = A;
     isOwner = Y;
     lastInviteDate = 20170929164657;
     memberLevel = 9;
     url = U138160721;
     userEmail = "ss2@t.com";
     userId = 138;
     userName = "\Uae40\Uc601\Ubbfc-iOS";
     userType = manager;
     */

    NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSInteger nOwnerId = [[dic_Data objectForKey:@"ownerId"] integerValue];
    
    SBDUser *user = self.arM_UserList[indexPath.row];
//    NSDictionary *dic = self.channel.members[indexPath.row];
    if( nOwnerId == [user.userId integerValue] )
    {
        cell.iv_Reader.hidden = NO;
    }
    else
    {
        cell.iv_Reader.hidden = YES;
    }

    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];
    cell.lb_Title.text = user.nickname;
    
//    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"imgUrl"]];
//    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];
//
//    cell.lb_Title.text = [dic objectForKey_YM:@"userName"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    /*
     channelId = 0;
     imgUrl = "000/000/f51df8be247438d5a6df1cf4ab5da74a.jpg";
     isMemberAllow = "";
     isOwner = N;
     isOwnerOrder = 1;
     lastInviteDate = 20170823163800;
     mId = 14352;
     memberLevel = 99;
     rId = 2224;
     url = U138160721;
     userEmail = "01057011027hj@gmail.com";
     userId = 138;
     userName = "\Uae40\Uc601\Ubbfc-iOS";
     userType = member;
     */
    
//    NSDictionary *dic = self.arM_UserList[indexPath.row];
    SBDUser *user = self.arM_UserList[indexPath.row];

    KikMyViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikMyViewController"];
//    vc.str_UserIdx = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]];
//    vc.str_UserIdx = user.userId;
    vc.user = user;
    vc.channel = self.channel;
    if( self.channel.memberCount == 2 )
    {
        vc.isOneOneChatIng = YES;
    }
    else
    {
        vc.isOneOneChatIng = NO;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if( [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight )
//    {
//        return CGSizeMake(554, 375);
////        return CGSizeMake(self.view.frame.size.width, (CGRectGetHeight(collectionView.frame)));
//    }
//
//    return CGSizeMake(375, 554);
////    return CGSizeMake(self.view.frame.size.width, (CGRectGetHeight(collectionView.frame)));
//}

- (IBAction)goJoinChat:(id)sender
{
    //참여하기
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSDictionary *dic_Tmp = [dic objectForKey:@"qnaRoomInfos"];
    if( dic_Tmp )
    {
        dic = dic_Tmp;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"rId"] integerValue]], @"rId",
                                        nil];
    
    if( self.channel )
    {
        [dicM_Params setObject:self.channel.channelUrl forKey:@"sendbirdChannelUrl"];
    }
    else
    {
        [dicM_Params setObject:str_SBDChannelUrl forKey:@"sendbirdChannelUrl"];
    }
    
    if( str_SBDChannelUrl.length <= 0 && self.channel == nil )
    {
        ALERT_ONE(@"방 생성 오류");
        return;
        
//        //방 생성이 잘못됐을 경우
//        __block NSMutableArray *arM_UserIds = [NSMutableArray array];
//        for( NSInteger i = 0; i < self.arM_UserList.count; i++ )
//        {
//            NSDictionary *dic_User = self.arM_UserList[i];
//            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic_User objectForKey:@"userId"]];
//            [arM_UserIds addObject:str_UserId];
//        }
//
//        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                            [Util getUUID], @"uuid",
//                                            nil];
//
//        NSString *str_Path = [NSString stringWithFormat:@"v1/open/group/%@", str_RId];
//        [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
//                                            param:dicM_Params
//                                       withMethod:@"GET"
//                                        withBlock:^(id resulte, NSError *error) {
//
//                                            if( resulte )
//                                            {
//                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                                if( nCode == 200 )
//                                                {
//                                                    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"groupInfo"]];
//                                                    NSError * err;
//                                                    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
//                                                    __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//                                                    [SBDGroupChannel createChannelWithName:weakSelf.lb_Title.text isDistinct:NO userIds:arM_UserIds coverUrl:nil data:str_Dic customType:nil
//                                                                         completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
//
//                                                                             if (error != nil)
//                                                                             {
//                                                                                 ALERT_ONE(@"방 생성 오류");
//                                                                             }
//                                                                             else if( channel == nil )
//                                                                             {
//                                                                                 ALERT_ONE(@"방 생성 오류");
//                                                                             }
//                                                                             else
//                                                                             {
//                                                                                 weakSelf.channel = channel;
//                                                                                 [weakSelf goJoinChat:nil];
//                                                                             }
//                                                                         }];
//
//                                                }
//                                            }
//                                        }];
//        return;
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/join/open/group"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                /*
                                                 channelId = 0;
                                                 channelImgUrl = "000/000/b1cad5db67153356bb146d0a9a4f0336.jpg";
                                                 channelName = "group1006_2";
                                                 "error_code" = success;
                                                 "error_message" = success;
                                                 hashTag = "#t1 #t2 #t3";
                                                 "image_prefix" = "http://data.thoting.com:8282/c_edujm/exam/";
                                                 "response_code" = 200;
                                                 sendbirdChannelUrl = "sendbird_group_channel_34200692_e4dbcf9a8dc1ec55ff4236e0193c921d8fd16eab";
                                                 success = success;
                                                 userId = 138;
                                                 "userImg_prefix" = "http://data.thoting.com:8282/c_edujm/images/user/";
                                                 */
                                                
                                                NSString *str_SDBChannelUrlTmp = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"sendbirdChannelUrl"]];
//                                                if( str_SDBChannelUrlTmp == nil || str_SDBChannelUrlTmp.length <= 0 )
//                                                {
//                                                    NSDictionary *dic_RoomInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"qnaRoomInfos"]];
//                                                    str_SDBChannelUrlTmp = [NSString stringWithFormat:@"%@", [dic_RoomInfo objectForKey_YM:@"sendbirdChannelUrl"]];
//                                                }
                                                [SBDGroupChannel getChannelWithUrl:str_SDBChannelUrlTmp completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {

                                                    NSMutableArray *arM_UserIds = [NSMutableArray array];
                                                    for( NSInteger i = 0; i < arM_UserIds.count; i++ )
                                                    {
                                                        NSDictionary *dic = weakSelf.arM_UserList[i];
                                                        NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]];
                                                        [arM_UserIds addObject:str_UserId];
                                                    }
                                                    
                                                    NSDictionary *dic_RoomInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"qnaRoomInfos"]];
                                                    
                                                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                                    ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                                    vc.str_RId = str_RId;
                                                    vc.dic_Info = dic_RoomInfo;
                                                    vc.str_RoomTitle = [dic_RoomInfo objectForKey_YM:@"roomName"];
                                                    vc.ar_UserIds = arM_UserIds;
                                                    vc.channel = channel;
                                                    vc.str_ChannelIdTmp = nil;
                                                    if( self.str_BotId )
                                                    {
                                                        vc.dic_BotInfo = @{@"userId":self.str_BotId};
                                                    }
                                                    [weakSelf.navigationController pushViewController:vc animated:YES];
                                                }];
                                            }
                                        }
                                    }];
}

@end
