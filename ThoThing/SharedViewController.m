//
//  SharedViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "SharedViewController.h"
#import "InvitationCell.h"
#import "UserPageMainViewController.h"
#import "ODRefreshControl.h"
#import "SharedHeaderCell.h"
#import "ChatFeedCell.h"
#import "MyMainViewController.h"

@interface SharedViewController () <UIGestureRecognizerDelegate>
{
    BOOL isOldShowNavi;
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    
//    UIColor *deSelectColor;
    NSMutableDictionary *dicM_Check;
    NSMutableDictionary *dicM_MainCheck;

    CGFloat fKeyboardHeight;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_RoomList;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) NSDictionary *dic_SelectedRoom;

@property (nonatomic, strong) SBDGroupChannelListQuery *groupChannelListQuery;
//@property (nonatomic, strong) SBDGroupChannel *channel;

@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_TitleCount;
@property (nonatomic, weak) IBOutlet UIButton *btn_Shared;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AccBottom;
@property (nonatomic, weak) IBOutlet UITextField *tf_SharedMessage;
@property (nonatomic, weak) IBOutlet UIView *v_TextFieldBg;
@property (nonatomic, weak) IBOutlet UIButton *btn_Send;

@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;

@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet UIView *v_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;
@property (nonatomic, weak) IBOutlet UITableView *tbv_RoomList;

@end

@implementation SharedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isOldShowNavi = self.navigationController.navigationBarHidden;
    
    self.tbv_RoomList.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbv_List.frame.size.width, 27.f)];
    self.tbv_RoomList.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbv_List.frame.size.width, 10.f)];

    self.v_TextFieldBg.layer.cornerRadius = 6.f;
    self.v_TextFieldBg.layer.borderWidth = 1.f;
    self.v_TextFieldBg.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;

    self.btn_Send.layer.cornerRadius = 6.f;
    self.btn_Send.layer.borderWidth = 1.f;
    self.btn_Send.layer.borderColor = kMainColor.CGColor;

    self.btn_Shared.layer.cornerRadius = 5.f;
    self.btn_Shared.layer.borderWidth = 1.f;
    self.btn_Shared.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_Shared.backgroundColor = [UIColor whiteColor];
    [self.btn_Shared setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    
    dicM_Check = [NSMutableDictionary dictionary];
    dicM_MainCheck = [NSMutableDictionary dictionary];
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tbv_List];
    self.refreshControl.tintColor = kMainYellowColor;
    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_List addSubview:self.refreshControl];

//    //온 시
//    self.btn_Shared.backgroundColor = kMainYellowColor;
//    [self.btn_Shared setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
//    NSString *str_Key = [NSString stringWithFormat:@"DashBoard_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    NSData *dictionaryData = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
//    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
//    if( resulte )
//    {
//        [self updateView:resulte];
//    }
//    else
//    {
//        [self updateRoomList];
//    }

    [self updateList];
    [self updateRoomList];
}

- (void)viewDidLayoutSubviews
{
    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.frame.size.width * 2, self.sv_Contents.contentSize.height);
    self.lc_ContentsWidth.constant = self.sv_Contents.contentSize.width;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.tf_SharedMessage addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:isOldShowNavi];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)onRefresh:(UIRefreshControl *)sender
{
    [self.arM_List removeAllObjects];
    self.arM_List = nil;
    [self updateList];
    [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
}

#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    fKeyboardHeight = keyboardBounds.size.height;
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
            self.lc_AccBottom.constant = keyboardBounds.size.height;
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            self.lc_AccBottom.constant = -50.f;
        }
    }completion:^(BOOL finished) {
        
    }];
}


- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ExamId, @"examId",
                                        self.str_QuestionId, @"questionId",
                                        self.str_ChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/follow/channel/member/list"
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
                                                str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                                
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                
//                                                NSInteger nTotalCnt = 0;
//                                                for( NSInteger i = 0; i < self.arM_List.count; i++ )
//                                                {
//                                                    NSDictionary *dic = self.arM_List[i];
//                                                    NSInteger nCnt = [[dic objectForKey:@"channelUserCount"] integerValue];
//                                                    
//                                                    nTotalCnt += nCnt;
//                                                }
                                                
//                                                self.lb_TitleCount.text = [NSString stringWithFormat:@"%ld", nTotalCnt];
                                                
                                                self.lb_TitleCount.text = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"totalUserCount"]];
                                                
                                                [self.tbv_List reloadData];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)updateRoomList
{
    self.groupChannelListQuery = [SBDGroupChannel createMyGroupChannelListQuery];
    self.groupChannelListQuery.limit = 100;
    self.groupChannelListQuery.order = SBDGroupChannelListOrderLatestLastMessage;
    self.groupChannelListQuery.includeEmptyChannel = NO;   //아무 대화가 없는 채널 보일지 말지 (YES는 보이는거)
//    self.groupChannelListQuery.customTypeFilter = self.str_ChannelId;
    
    [self.groupChannelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError * _Nullable error) {
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            return;
        }
        
        NSMutableArray *arM_Tmp = [NSMutableArray array];
        if( self.str_ChannelId && self.str_ChannelId.length > 0 )
        {
            for( NSInteger i = 0; i < channels.count; i++ )
            {
                SBDGroupChannel *groupChannel = channels[i];
                NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
                id tmp = [dic objectForKey_YM:@"channelIds"];
                if( [tmp isKindOfClass:[NSArray class]] == NO )
                {
                    continue;
                }
                NSArray *ar_ChannelId = [NSArray arrayWithArray:[dic objectForKey_YM:@"channelIds"]];
                for( NSInteger i = 0; i < ar_ChannelId.count; i++ )
                {
                    NSString *str_TmpChannelId = ar_ChannelId[i];
                    if( [self.str_ChannelId isEqualToString:str_TmpChannelId] )
                    {
                        [arM_Tmp addObject:groupChannel];
                    }
                }
            }
            
            self.arM_RoomList = [NSMutableArray arrayWithArray:arM_Tmp];
        }
        else
        {
            self.arM_RoomList = [NSMutableArray arrayWithArray:channels];
        }

//        self.arM_RoomList = [NSMutableArray arrayWithArray:channels];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbv_RoomList reloadData];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        });
    }];
    

//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
//                                        @"examShare", @"callWhere",
//                                        nil];
//    //http://dev2.thoting.com/api/v1/get/my/channel/qna/chat/room/list?pUserId=138&callWhere=examShare&apiToken=c7f4566d688f8b9ab87f4331b19bb3&uuid=3FF1C31A-7B8A-48DF-8EDB-ACC7212C85B4
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/channel/qna/chat/room/list"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            [self updateView:resulte];
//                                        }
//                                    }];
    
}

- (void)updateView:(NSDictionary *)resulte
{
    self.arM_RoomList = nil;
    
    str_ImagePrefix = [resulte objectForKey:@"userImg_prefix"];
    
    NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
    if( nCode == 200 )
    {
        self.arM_RoomList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"qnaRoomInfos"]];
    }
    else
    {
        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
    }
    
    [self.tbv_RoomList reloadData];
    
    NSInteger nTotalBadgeCnt = 0;
    for( NSInteger i = 0; i < self.arM_RoomList.count; i++ )
    {
        NSDictionary *dic = self.arM_RoomList[i];
        NSInteger nBadgeCnt = [[dic objectForKey:@"newQnaCount"] integerValue];
        nTotalBadgeCnt += nBadgeCnt;
    }
    
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
    if( nTotalBadgeCnt > 0 )
    {
        item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalBadgeCnt];
    }
    else
    {
        item.badgeValue = nil;
    }
}

- (void)invitationButtonOn
{
    self.btn_Shared.userInteractionEnabled = YES;
    
    self.btn_Shared.backgroundColor = kMainColor;
    [self.btn_Shared setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btn_Shared.layer.borderColor = kMainColor.CGColor;
}

- (void)invitationButtonOff
{
    self.btn_Shared.userInteractionEnabled = NO;
    
    self.btn_Shared.backgroundColor = [UIColor whiteColor];
    [self.btn_Shared setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.btn_Shared.layer.borderColor = [UIColor lightGrayColor].CGColor;
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_RoomList )
    {
        return 1;
    }
    
    return self.arM_List.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_RoomList )
    {
        return self.arM_RoomList.count;
    }
    
    NSDictionary *dic = [self.arM_List objectAtIndex:section];
    NSArray *ar = [dic objectForKey:@"channelUserList"];
    return ar.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_RoomList )
    {
        ChatFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatFeedCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
//        NSDictionary *dic = self.arM_RoomList[indexPath.row];
        SBDGroupChannel *groupChannel = self.arM_RoomList[indexPath.row];
        SBDBaseChannel *baseChannel = (SBDBaseChannel *)groupChannel;
        NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];

        cell.iv_User.image = BundleImage(@"");
        cell.lb_Title.text = @"";
        cell.lb_GroupCount.text = @"";
        
        if( groupChannel.memberCount <= 2 )
        {
            id userThumbnail = [dic objectForKey:@"userThumbnail"];
            if( [userThumbnail isKindOfClass:[NSArray class]] == NO )
            {
                return cell;
            }
            
            NSArray *ar = userThumbnail;
            
            for( NSInteger i = 0; i < ar.count; i++ )
            {
                NSDictionary *dic_Tmp = [ar objectAtIndex:i];
                if( [[dic_Tmp objectForKey:@"userId"] integerValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
                {
                    //1:1 채팅일때 상대방 유저 사진
                    [cell.iv_User setImageWithURL:[NSURL URLWithString:[dic_Tmp objectForKey:@"imgUrl"]] usingCache:NO];
                    
                    //1:1 채팅일때 상대방 닉네임
                    cell.lb_Title.text = [dic_Tmp objectForKey:@"userName"];
                }
            }
        }
        else
        {
            //그룹 채팅일때 채팅방 전체 유저 수
            cell.lb_GroupCount.text = [NSString stringWithFormat:@"%ld", groupChannel.memberCount];
            
            //그룹 채팅일때 방 만들때 방 제목 입력한거
            cell.lb_Title.text = baseChannel.name;
            
            //그룹 채팅일때 원 배경색
            cell.iv_User.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
            cell.iv_User.image = BundleImage(@"");
        }
        
        
        //뱃지 카운트
        if( groupChannel.unreadMessageCount > 0 )
        {
            cell.v_BadgeGuide.hidden = NO;
            cell.lb_Badge.text = [NSString stringWithFormat:@"%ld", groupChannel.unreadMessageCount];
        }
        else
        {
            cell.lb_Badge.text = @"0";
            cell.v_BadgeGuide.hidden = YES;
        }
        
        cell.btn_Type.hidden = YES;
        
        //뱃지는 숨겨주자
        cell.v_BadgeGuide.hidden = YES;
        
        //마지막 메세지 (이미지, 동영상, 텍스트에 대한 구분이 필요함)
        SBDUserMessage *lastMessage = (SBDUserMessage *)groupChannel.lastMessage;
        if( [lastMessage.customType isEqualToString:@"image"] )
        {
            [cell.btn_Type setImage:BundleImage(@"camera_icon_small.png") forState:UIControlStateNormal];
            [cell.btn_Type setTitle:@"사진" forState:UIControlStateNormal];
            cell.btn_Type.hidden = NO;
            
            cell.lb_Disc2.text = @"";
        }
        else if( [lastMessage.customType isEqualToString:@"video"] )
        {
            [cell.btn_Type setImage:BundleImage(@"video_icon_samll.png") forState:UIControlStateNormal];
            [cell.btn_Type setTitle:@"동영상" forState:UIControlStateNormal];
            cell.btn_Type.hidden = NO;
            
            cell.lb_Disc2.text = @"";
        }
        else if( [lastMessage.customType isEqualToString:@"shareExam"] || [lastMessage.customType isEqualToString:@"shareQuestion"] )
        {
            cell.lb_Disc1.text = [dic objectForKey_YM:@"subjectName"];
            cell.lb_Disc1.backgroundColor = [UIColor colorWithHexString:[dic objectForKey:@"codeHex"]];
            
            if( cell.lb_Disc1.text.length > 0 )
            {
                cell.lb_Disc2.text = [NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"examTitle"]];
                cell.lb_Disc2.text = [cell.lb_Disc2.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
                NSMutableString *strM = [NSMutableString string];
                [strM appendString:cell.lb_Disc2.text];
                cell.lb_Disc2.text = strM;
            }
            else
            {
                cell.lb_Disc2.text = lastMessage.message;
                
                NSMutableString *strM = [NSMutableString string];
                //            [strM appendString:@"''"];
                [strM appendString:cell.lb_Disc2.text];
                //            [strM appendString:@"''"];
                cell.lb_Disc2.text = strM;
            }
        }
        //    else if( [lastMessage.customType isEqualToString:@"shareQuestion"] )
        //    {
        //
        //    }
        else
        {
            if( lastMessage.message.length > 0 )
            {
                cell.lb_Disc2.text = lastMessage.message;
            }
            else
            {
                cell.lb_Disc2.text = @"";
            }
            //    NSLog(@"lastMessage.createdAt : %lld", lastMessage.createdAt);
        }
        
        NSDate *lastMessageDate = nil;
        if( lastMessage.createdAt <= 0 )
        {
            //마지막 메세지가 없을때
            lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)groupChannel.createdAt];
            
        }
        else
        {
            //마지막 메세지가 있을때
            lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastMessage.createdAt / 1000.0f];
        }
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:lastMessageDate];
        NSInteger nYear = [components year];
        NSInteger nMonth = [components month];
        NSInteger nDay = [components day];
        NSInteger nHour = [components hour];
        NSInteger nMinute = [components minute];
        NSInteger nSecond = [components second];
        
        NSString *str_Date = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond];
        cell.lb_Date.text = [Util getMainThotingChatDate:str_Date];

        return cell;
    }
    
    InvitationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitationCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     channelId = 4;
     channelImgUrl = "000/000/noImage9.png";
     isMemberAllow = N;
     lastShareDate = "";
     memberLevel = 99;
     name = guseowhs;
     statusCode = F;
     url = S75160410;
     userAffiliation = "\Uc6a9\Uc0b0\Uace0\Ub4f1\Ud559\Uad50";
     userId = 75;
     userName = guseowhs;
     userThumbnail = "000/000/noImage9.png";
     userType = member;
     */
    
    cell.iv_User.tag = indexPath.row;
    
    NSDictionary *dic_Main = [self.arM_List objectAtIndex:indexPath.section];
    NSArray *ar = [dic_Main objectForKey:@"channelUserList"];
    NSDictionary *dic = ar[indexPath.row];
    
    cell.iv_User.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];
    
    [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]]];
    
    cell.lb_Date.text = @"";
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"lastShareDate"]];
    if( str_Date.length >= 12 )
    {
        NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
        NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
        NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
        //        NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
        //        NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
        
        cell.lb_Date.text = [NSString stringWithFormat:@"공유 %04ld-%02ld-%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue]];
    }
    else
    {
        cell.lb_Date.text = str_Date;
    }
    
    cell.lb_Name.text = [dic objectForKey:@"userName"];

    NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
    NSInteger nSelectedUserId = [[dicM_Check objectForKey:str_UserId] integerValue];
    if( nSelectedUserId > 0 )
    {
        cell.btn_Check.selected = YES;
    }
    else
    {
        cell.btn_Check.selected = NO;
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( tableView == self.tbv_RoomList )
    {
//        NSDictionary *dic = self.arM_RoomList[indexPath.row];

        SBDGroupChannel *groupChannel = self.arM_RoomList[indexPath.row];
//        SBDBaseChannel *baseChannel = (SBDBaseChannel *)groupChannel;
        NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];

        NSString *str_RoomType = [dic objectForKey_YM:@"roomType"];
        
        NSMutableString *strM = [NSMutableString string];

        if( groupChannel.memberCount <= 2 )
        {
            id userThumbnail = [dic objectForKey:@"userThumbnail"];
            if( [userThumbnail isKindOfClass:[NSArray class]] == NO )
            {
                strM = [NSMutableString stringWithString:@"1:1 채팅방"];
            }
            
            NSArray *ar = userThumbnail;
            
            for( NSInteger i = 0; i < ar.count; i++ )
            {
                NSDictionary *dic_Tmp = [ar objectAtIndex:i];
                if( [[dic_Tmp objectForKey:@"userId"] integerValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
                {
                    //1:1 채팅일때 상대방 유저 사진
                    strM = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"userName"]]];
                }
            }
        }
        else
        {
            [strM appendString:[dic objectForKey_YM:@"roomName"]];
        }

        [strM appendString:@"에 공유하시겠습니까?"];
        
        UIAlertView *alert = CREATE_ALERT(nil, strM, @"확인", @"취소");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                self.dic_SelectedRoom = dic;
                [self invitationButtonOn];
                [self sendRoomShared];
            }
            else
            {
                [self invitationButtonOff];
                self.dic_SelectedRoom = nil;
            }
        }];
    }
    else
    {
        NSDictionary *dic_Main = [self.arM_List objectAtIndex:indexPath.section];
        NSArray *ar = [dic_Main objectForKey:@"channelUserList"];
        NSDictionary *dic = ar[indexPath.row];
        NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
        
        InvitationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        cell.btn_Check.selected = !cell.btn_Check.selected;
        
        if( cell.btn_Check.selected )
        {
            //선택이면 추가
            [dicM_Check setObject:str_UserId forKey:str_UserId];
        }
        else
        {
            //아니면 우선 삭제
            [dicM_Check removeObjectForKey:str_UserId];
        }
        
        [self updateSelectStatus];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_RoomList )
    {
        return 0;
    }
    
    return 60.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_RoomList )
    {
        return nil;
    }
    
    SharedHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SharedHeaderCell"];
    cell.tag = section;
    
    NSDictionary *dic = [self.arM_List objectAtIndex:section];
    cell.lb_Title.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"channelName"], [dic objectForKey:@"channelUserCount"]];
    
    NSString *str_HeaderKey = [dicM_MainCheck objectForKey:[NSString stringWithFormat:@"%ld", section]];
    if( str_HeaderKey )
    {
        cell.btn_Check.selected = YES;
    }
    else
    {
        cell.btn_Check.selected = NO;
    }
    
    UITapGestureRecognizer *singleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap:)];
    singleTapRecogniser.numberOfTouchesRequired = 1;
    singleTapRecogniser.numberOfTapsRequired = 1;
    [cell addGestureRecognizer:singleTapRecogniser];

    return cell;
}

- (void)headerTap:(UIGestureRecognizer *)gesture
{
    SharedHeaderCell *headerCell = (SharedHeaderCell *)gesture.view;
    NSDictionary *dic_Main = [self.arM_List objectAtIndex:headerCell.tag];
    NSArray *ar = [dic_Main objectForKey:@"channelUserList"];

    NSString *str_HeaderKey = [dicM_MainCheck objectForKey:[NSString stringWithFormat:@"%ld", headerCell.tag]];
    if( str_HeaderKey )
    {
        //이미 선택된 상태면 모두 디셀렉트
        for( NSInteger i = 0; i < ar.count; i++ )
        {
            NSDictionary *dic = ar[i];
            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
            [dicM_Check removeObjectForKey:str_UserId];
        }
        
        [dicM_MainCheck removeObjectForKey:[NSString stringWithFormat:@"%ld", headerCell.tag]];
    }
    else
    {
        //체크가 안되어 있으면 모두 셀렉트
        for( NSInteger i = 0; i < ar.count; i++ )
        {
            NSDictionary *dic = ar[i];
            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
            [dicM_Check setObject:str_UserId forKey:str_UserId];
        }
        
        [dicM_MainCheck setObject:[NSString stringWithFormat:@"%ld", headerCell.tag] forKey:[NSString stringWithFormat:@"%ld", headerCell.tag]];
    }
    
    [self updateSelectStatus];
}

- (void)updateSelectStatus
{
    //셀렉할때마다 전체 검사
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        BOOL isAllSelected = YES;
        NSDictionary *dic_Main = self.arM_List[i];
        NSArray *ar = [dic_Main objectForKey:@"channelUserList"];
        for( NSInteger j = 0; j < ar.count; j++ )
        {
            NSDictionary *dic = ar[j];
            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
            if( [str_UserId isEqualToString:[dicM_Check objectForKey:str_UserId]] == NO )
            {
                isAllSelected = NO;
                break;
            }
        }
        
        if( isAllSelected )
        {
            [dicM_MainCheck setObject:[NSString stringWithFormat:@"%ld", i] forKey:[NSString stringWithFormat:@"%ld", i]];
        }
        else
        {
            [dicM_MainCheck removeObjectForKey:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    if( dicM_Check.count > 0 )
    {
        [self invitationButtonOn];
    }
    else
    {
        [self invitationButtonOff];
    }

    [self.tbv_List reloadData];
}

- (void)imageTap:(UIGestureRecognizer *)gesture
{
    UIView *view = (UIView *)gesture.view;
    NSDictionary *dic = self.arM_List[view.tag];
    
    MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isAnotherUser = YES;
    vc.str_UserIdx = [dic objectForKey:@"userId"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goSendShared:(id)sender
{
    if( self.seg.selectedSegmentIndex == 0 )
    {
        [self sendRoomShared];
        return;
    }
    
    if( dicM_Check.count <= 0 )
    {
        self.btn_Shared.userInteractionEnabled = YES;
        return;
    }
    
    if( [self.tf_SharedMessage isFirstResponder] == NO )
    {
        [self.tf_SharedMessage becomeFirstResponder];
        return;
    }

    self.btn_Shared.userInteractionEnabled = NO;
    
    NSMutableString *strM = [NSMutableString string];
    NSArray *ar_AllKeys = dicM_Check.allKeys;
    for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
    {
        [strM appendString:[dicM_Check objectForKey:ar_AllKeys[i]]];
        [strM appendString:@","];
    }
    
    if( [strM hasSuffix:@","] )
    {
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ExamId, @"examId",
                                        self.str_QuestionId, @"questionId",
                                        self.tf_SharedMessage.text.length > 0 ? self.tf_SharedMessage.text : @"", @"shareMsg",
                                        strM, @"inviteUserIdStr",
                                        nil];
    
    if( self.arM_List.count > 1 )
    {
        NSMutableString *strM = [NSMutableString string];
        for( NSInteger i = 0; i < self.arM_List.count; i++ )
        {
            NSDictionary *dic = self.arM_List[i];
            NSInteger nChannelId = [[dic objectForKey:@"channelId"] integerValue];
            [strM appendString:[NSString stringWithFormat:@"%ld-%ld", nChannelId, ar_AllKeys.count]];
            [strM appendString:@","];
        }
        
        if( [strM hasSuffix:@","] )
        {
            [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
        }
        
        [dicM_Params setObject:strM forKey:@"channelShareInfo"];
    }
    else
    {
//        NSDictionary *dic = [self.arM_List firstObject];
        [dicM_Params setObject:[NSString stringWithFormat:@"0-%ld", ar_AllKeys.count] forKey:@"channelShareInfo"];
    }
    //기교연
    
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/send/share/message/channel/member"
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
                                                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                [window makeToast:@"공유했습니다" withPosition:kPositionBottom];
                                                
//                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",
//                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]], @"eId",
//                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"itemType"]], @"itemType",

//                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
//                                                [dicM setObject:@"share" forKey:@"msgType"];
//                                                [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"eId"]] forKey:@"eId"];
//                                                [dicM setObject:[NSString stringWithFormat:@"%@", [self.dic_SelectedRoom objectForKey_YM:@"questionId"]] forKey:@"questionId"];
//                                                
//                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM
//                                                                                                   options:NSJSONWritingPrettyPrinted
//                                                                                                     error:&error];
//                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//                                                [SendBird sendMessage:@"shareExam" withData:jsonString];
//                                                [SendBird sendMessage:@"dashBoardUpdate" withData:jsonString];

                                                if( self.completionBlock )
                                                {
                                                    self.completionBlock(nil);
                                                }
                                                else
                                                {
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                    [self dismissViewControllerAnimated:NO completion:^{
                                                        
                                                    }];
                                                }
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        self.btn_Shared.userInteractionEnabled = YES;
                                    }];
    
}

- (void)sendRoomShared
{
    if( [self.tf_SharedMessage isFirstResponder] == NO )
    {
        [self.tf_SharedMessage becomeFirstResponder];
        return;
    }
    
    self.btn_Shared.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ExamId, @"examId",
//                                        self.str_QuestionId, @"questionId",
//                                        [self.str_QuestionId integerValue] > 0 ? [NSString stringWithFormat:@"%@", [self.dic_SelectedRoom objectForKey_YM:@"questionId"]] : @"0", @"questionId",
                                        [self.str_QuestionId integerValue] > 0 ? self.str_QuestionId : @"0", @"questionId",
                                        self.tf_SharedMessage.text.length > 0 ? self.tf_SharedMessage.text : @"", @"shareMsg",
                                        [self.dic_SelectedRoom objectForKey_YM:@"rId"], @"inviteUserIdStr",
                                        @"room", @"inviteType",
                                        @"0", @"channelShareInfo",
                                        nil];
    //26467
    __weak __typeof__(self) weakSelf = self;

    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/send/share/message/channel/member"
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
                                                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                [window makeToast:@"공유했습니다" withPosition:kPositionBottom];
                                                
//                                                NSString *str_RId = [NSString stringWithFormat:@"%@", [self.dic_SelectedRoom objectForKey_YM:@"rId"]];
//                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
//                                                [dicM setObject:@"share" forKey:@"msgType"];
//                                                [dicM setObject:str_RId forKey:@"rId"];
//                                                
//                                                [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"eId"]] forKey:@"eId"];
//                                                [dicM setObject:[NSString stringWithFormat:@"%@", [self.dic_SelectedRoom objectForKey_YM:@"questionId"]] forKey:@"questionId"];
//
//                                                
//                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM
//                                                                                                   options:NSJSONWritingPrettyPrinted
//                                                                                                     error:&error];
//                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                                                [SendBird sendMessage:@"shareExam" withData:jsonString];
//                                                [SendBird sendMessage:@"dashBoardUpdate" withData:jsonString];
                                                
                                                
                                                if( self.completionBlock )
                                                {
                                                    self.completionBlock(nil);
                                                }
                                                else
                                                {
                                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                    if( appDelegate.isChannelMode )
                                                    {
                                                        [weakSelf.navigationController popViewControllerAnimated:YES];
                                                    }
                                                    else
                                                    {
                                                        [weakSelf.navigationController popViewControllerAnimated:YES];
                                                        [weakSelf dismissViewControllerAnimated:NO completion:^{
                                                            
                                                        }];
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        self.btn_Shared.userInteractionEnabled = YES;
                                    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( self.seg.selectedSegmentIndex == 0 )
    {
        [self sendRoomShared];
        return YES;
    }
    
    [self goSendShared:nil];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)tf
{
    if( tf.text.length > 0 )
    {
        self.btn_Send.selected = YES;
    }
    else
    {
        self.btn_Send.selected = NO;
    }
}

- (IBAction)goSegChange:(id)sender
{
    [self.view endEditing:YES];

    if( self.seg.selectedSegmentIndex == 0 )
    {
        self.btn_Shared.hidden = YES;
    }
    else
    {
        self.btn_Shared.hidden = NO;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.frame.size.width * self.seg.selectedSegmentIndex, 0);
        
    }]; 
}

- (IBAction)goBack:(id)sender
{
    if( self.isModalMode )
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    else
    {
        [super goBack:sender];
    }
}

@end
