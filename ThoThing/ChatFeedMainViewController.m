//
//  ChatFeedMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChatFeedMainViewController.h"
#import "ChatFeedCell.h"
#import "ChatFeedMemeberInviteViewController.h"
#import "ChatFeedViewController.h"
#import "ODRefreshControl.h"
#import "SBJsonParser.h"
#import "OnlineCell.h"
#import "ReciveSendViewController.h"
#import "OnlineBotCell.h"

@interface ChatFeedMainViewController () <SBDChannelDelegate, SWTableViewCellDelegate>
{
    BOOL isFirstLoad;
    NSString *str_ImagePrefix;
}
@property (nonatomic, strong) NSTimer *tm_OffLine;
@property (nonatomic, strong) NSString *str_CurrentChannel;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_Online;
//@property (nonatomic, strong) NSMutableDictionary *dicM_Count;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) SBDGroupChannelListQuery *groupChannelListQuery;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Icon;
@property (nonatomic, weak) IBOutlet UILabel *lb_MainTitle;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_OnlineHeight;
@property (nonatomic, weak) IBOutlet UICollectionView *cv_Online;
@property (nonatomic, weak) IBOutlet UIButton *btn_Close;
@end

@implementation ChatFeedMainViewController

- (void)onOffLineTask
{
    //네트웍이 연결된 상태면 오프라인에서 저장했던 api 콜
    if( [Util getNetworkSatatus] )
    {
        NSMutableArray *arM = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"OfflineCall"]];
        
        if( arM.count > 0 )
        {
            [SVProgressHUD showWithStatus:@"오프라인 작업 수행중.."];
            
            for( NSInteger i = 0; i < arM.count; i++ )
            {
                NSDictionary *dic = [arM objectAtIndex:i];
                
                [[WebAPI sharedData] callSyncWebAPIBlock:[dic objectForKey:@"path"] param:[dic objectForKey:@"params"] withMethod:[dic objectForKey:@"method"] withBlock:^(id resulte, NSError *error) {
                    
                    NSLog(@"오프라인 작업 %ld개 완료" , i + 1);
                }];
            }
            
            [arM removeAllObjects];
            
            [[NSUserDefaults standardUserDefaults] setObject:arM forKey:@"OfflineCall"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [SVProgressHUD dismiss];
        }
    }
}

//- (void)onTest33
//{
//    [self startSendBird];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( self.isChannelMode )
    {
        self.btn_Close.hidden = NO;
    }
    else
    {
        self.btn_Close.hidden = YES;
    }
    
    self.iv_Icon.layer.cornerRadius = self.iv_Icon.frame.size.width / 2;
    
    NSString *str_NormalQKey = [NSString stringWithFormat:@"NormalQuestion_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSData *tempData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
    if( tempData == nil )
    {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_NormalQKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    str_NormalQKey = [NSString stringWithFormat:@"PdfQuestion_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    tempData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
    if( tempData == nil )
    {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_NormalQKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

//    self.openChannelListQuery = [SBDOpenChannel createOpenChannelListQuery];
//    [self.openChannelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDOpenChannel *> * _Nullable channels, SBDError * _Nullable error) {
//        
//        
//    }];
    
    
//    [self startSendBird];
    [self performSelector:@selector(onChannelJoinInterval) withObject:nil afterDelay:1.0f];

//    //10초에 한번씩 오프라인 작업이 있는지 타이머를 돌려서 처리 체크
//    self.tm_OffLine = [NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(onOffLineTask) userInfo:nil repeats:YES];
//    [self.tm_OffLine fire];
//    //////////////////////////////////////////////
    
    
    self.tbv_List.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbv_List.frame.size.width, 27.f)];
    self.tbv_List.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbv_List.frame.size.width, 10.f)];
    
//    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//    [SendBird loginWithUserId:str_UserId andUserName:str_UserName andUserImageUrl:nil andAccessToken:kSendBirdApiToken];
//    NSLog(@"1111 : %@", [SendBird getUserId]);
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tbv_List];
    self.refreshControl.tintColor = kMainYellowColor;
    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_List addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReload) name:@"ChatFeedReloadNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDashBoardUpdate:) name:@"DashBoardUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveDashboardItem:) name:@"RemoveDashboardItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessagePushNoti:) name:@"MessagePushNoti" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTest33) name:@"Test33" object:nil];

//    NSString *str_Key = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    self.dicM_Count = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:str_Key]];
    
    
//    NSString *str_Key = [NSString stringWithFormat:@"DashBoard_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    NSData *dictionaryData = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
//    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
//    if( resulte )
//    {
////        [self updateView:resulte];
//    }
//    else
//    {
////        isFirstLoad = YES;
////
////        MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
////        hud.mode = MBProgressHUDModeYM;
////        hud.labelText = @"업데이트중...";
////        [hud show:YES];
//    }
    
//    [self updateListWithIndicator:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(becomeActiove)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];

    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/manage/channel/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
//                                                str_ImagePrefix = [resulte objectForKey:@"userImg_prefix"];

                                                NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"channelInfos"]];
                                                if( ar && ar.count > 0 )
                                                {
                                                    [[NSUserDefaults standardUserDefaults] setObject:@"Y" forKey:@"isTeacher"];
                                                    
                                                    [self updateTopIcon];
                                                }
                                                else
                                                {
                                                    [[NSUserDefaults standardUserDefaults] setObject:@"N" forKey:@"isTeacher"];
                                                }
                                                
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                            }
                                        }
                                    }];
    
    
}

- (void)becomeActiove
{
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.hidesBottomBarWhenPushed = NO;
    
    [SBDMain addChannelDelegate:self identifier:@"chatfeedmain"];

//    [self startSendBird];
//    [SBDMain addChannelDelegate:self identifier:self.description];
    
//    [self performSelector:@selector(onChannelJoinInterval) withObject:nil afterDelay:1.0f];
    
    if( isFirstLoad )
    {
//        isFirstLoad = NO;
    }
    else
    {
//        [self updateListWithIndicator:YES];
    }
    
    
    //    [self.tbv_List reloadData];
    
    [self updateTopIcon];
    [self updateOnlineUser];
    
    static BOOL isOnce = YES;
    if( isOnce )
    {
        isOnce = NO;
        [self updateList];
    }
    else
    {
        [self updateList];
//        SBDGroupChannelListQuery *query = [SBDGroupChannel createMyGroupChannelListQuery];
//        query.limit = 100;
//        query.order = SBDGroupChannelListOrderLatestLastMessage;
//        query.includeEmptyChannel = NO;   //아무 대화가 없는 채널 보일지 말지 (YES는 보이는거) => 카톡처럼
//        query.customTypeFilter = self.str_ChannelId;
//        [query loadNextPageWithCompletionHandler:^(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError * _Nullable error) {
//            if (error != nil)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.refreshControl endRefreshing];
//                });
//                
//                return;
//            }
//            
//            NSMutableArray *arM = [NSMutableArray arrayWithArray:channels];
//            NSInteger nTotalUnReadCount = 0;
//            for( NSInteger i = 0; i < arM.count; i++ )
//            {
//                SBDGroupChannel *groupChannel = arM[i];
//                nTotalUnReadCount += groupChannel.unreadMessageCount;
//            }
//            
//            NSLog(@"nTotalUnReadCount : %ld", nTotalUnReadCount);
//            
//            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
//            if( nTotalUnReadCount > 0 )
//            {
//                item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalUnReadCount];
//                [UIApplication sharedApplication].applicationIconBadgeNumber = nTotalUnReadCount;
//            }
//            else
//            {
//                item.badgeValue = nil;
//                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//            }
//            
//            [self.refreshControl endRefreshing];
//            [self.tbv_List reloadData];
//        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSString *str_Path = [NSString stringWithFormat:@"%@/api/v1/get/dashboard/answer/list", kBaseUrl];
    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];
    
    str_Path = [NSString stringWithFormat:@"%@/api/v1/get/my/manage/channel/list", kBaseUrl];
    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];
    
    str_Path = [NSString stringWithFormat:@"%@/api/v1/get/my/channel/qna/chat/room/list", kBaseUrl];
    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];
}

- (void)updateSendBirdDelegate
{
    [SBDMain addChannelDelegate:self identifier:@"chatfeedmain"];
    
    [self updateList];
}

- (void)updateTopIcon
{
    if( self.isChannelMode )
    {
        self.iv_Icon.hidden = YES;
        
        NSArray *ar_ExamInfos = [self.dic_ChannelData objectForKey:@"examInfos"];
        if( ar_ExamInfos.count > 0 )
        {
            NSDictionary *dic = [ar_ExamInfos firstObject];
            self.lb_MainTitle.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelName"]];
        }
    }
    else
    {
        self.iv_Icon.hidden = NO;
        
        NSString *str_IsTeacher = [[NSUserDefaults standardUserDefaults] objectForKey:@"isTeacher"];
        if( [str_IsTeacher isEqualToString:@"Y"] )
        {
            NSString *str_Name = @"";
            NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            NSString *str_DefaultChannel = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
            if( str_DefaultChannel == nil || str_DefaultChannel.length <= 0 )
            {
                str_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
            }
            else
            {
                str_Name = str_DefaultChannel;
            }
            
            if( [str_Name isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] )
            {
                NSString *str_UserPic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"];
                [self.iv_Icon sd_setImageWithURL:[NSURL URLWithString:str_UserPic] placeholderImage:BundleImage(@"no_image.png")];
                [self setIcon:str_UserPic];
            }
            else
            {
                NSString *str_IconUrl = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_Pic", str_Key]];
                [self.iv_Icon sd_setImageWithURL:[NSURL URLWithString:str_IconUrl] placeholderImage:BundleImage(@"no_image.png")];
                [self setIcon:str_IconUrl];
            }
            self.lb_MainTitle.text = str_Name;
        }
        else
        {
            self.iv_Icon.image = BundleImage(@"thoth00.png");
            self.lb_MainTitle.text = @"토팅";
        }
    }
}

- (void)setIcon:(NSString *)aUrl
{
    NSURL *url = [NSURL URLWithString:aUrl];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    [iv setImageWithURLRequest:theRequest placeholderImage:nil usingCache:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        CGSize size = CGSizeMake(25, 25);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContextWithOptions(newImage.size, NO, [UIScreen mainScreen].scale);
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)
                                    cornerRadius:size.width/2] addClip];
        [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        /*************하단 구조 바뀌며 주석처리함 20170607*************/
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarMyIdx];
        item.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

- (void)updateOnlineUser
{
    __weak __typeof__(self) weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/dashboard/answer/list"
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/dashboard/answer/group/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            str_ImagePrefix = [resulte objectForKey:@"userImg_prefix"];

                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.arM_Online = [NSMutableArray arrayWithArray:[resulte objectForKey:@"dashboardAnswerInfo"]];
                                                for( NSInteger i = 0; i < weakSelf.arM_Online.count; i++ )
                                                {
                                                    NSDictionary *dic = weakSelf.arM_Online[i];
                                                    NSInteger nUserId = [[dic objectForKey:@"userId"] integerValue];
                                                    NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
                                                    if( nUserId == nMyId )
                                                    {
                                                        [weakSelf.arM_Online removeObjectAtIndex:i];
                                                        break;
                                                    }
                                                }
                                                
                                                [weakSelf.cv_Online reloadData];
                                            }
                                        }
                                    }];
}

- (void)onMessagePushNoti:(NSNotification *)noti
{
    NSString *str_ChannelUrl = noti.object[@"url"];
    NSDictionary *dic_Data = noti.object[@"data"];
    
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        SBDGroupChannel *groupChannel = self.arM_List[i];
        if( [groupChannel.channelUrl isEqualToString:str_ChannelUrl] )
        {
            [groupChannel markAsRead];
            SBDBaseChannel *baseChannel = (SBDBaseChannel *)groupChannel;
            NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
            ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
            //    vc.hidesBottomBarWhenPushed = YES;
            vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"rId"]];
            vc.str_RoomName = [dic objectForKey_YM:@"roomName"];
            //    vc.str_ChatType = [NSString stringWithFormat:@"%@", [dic objectForKey:@"roomType"]];
            vc.roomColor = [UIColor colorWithHexString:[dic objectForKey:@"codeHex"]];
            vc.dic_Info = dic;
            vc.channelImageUrl = [NSURL URLWithString:baseChannel.coverUrl];
            vc.channel = groupChannel;
            vc.str_ChannelIdTmp = self.str_ChannelId;
            if( dic_Data )
            {
                vc.dic_MoveExamInfo = dic_Data;
            }
            [self.navigationController pushViewController:vc animated:YES];

            break;
        }
    }
    

//    NSDictionary *dic = noti.object;
//    
//    NSInteger nRId = [[NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]] integerValue];
//    [self updateOneItemReplace:nRId];
}

- (void)onDashBoardUpdate:(NSNotification *)noti
{
//    [self updateListWithIndicator:YES];

//    NSLog(@"%@", noti.object);
//
//    NSData *data = [noti.object dataUsingEncoding:NSUTF8StringEncoding];
//    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//
//    NSLog(@"userId : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]);
//
//    NSLog(@"%@", json);
//    
//    NSInteger nRId = [[json objectForKey:@"rId"] integerValue];
//
//    NSMutableArray *arM_Tmp = [NSMutableArray arrayWithArray:self.arM_List];
//    BOOL isFind = NO;
//    for( NSInteger i = 0; i < self.arM_List.count; i++ )
//    {
//        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[i]];
//        NSInteger nTempRId = [[dicM objectForKey_YM:@"rId"] integerValue];
//        if( nRId == nTempRId )
//        {
//            isFind = YES;
//            NSArray *ar = [json objectForKey:@"qnaBody"];
//            if( ar.count > 0 )
//            {
//                NSDictionary *dic = [ar firstObject];
//                NSString *str_MsgType = [json objectForKey_YM:@"msgType"];
//                [dicM setObject:str_MsgType forKey:@"msgType"];
//                [dicM setObject:[dic objectForKey:@"qnaBody"] forKey:@"lastMsg"];
//                [dicM setObject:[json objectForKey:@"createDate"] forKey:@"lastChatDate"];
//
//                [arM_Tmp removeObjectAtIndex:i];
//                [arM_Tmp insertObject:dicM atIndex:0];
//            }
//            else
//            {
//                //이건 메세지 공유했을땐데 기존 아이템을 갈아 끼워야 함
////                [self updateOneItemReplace:nRId];
//                
//                //대시보드 업데이트 할 데이터 만들기 (lastMsg와 lastChatDate)
//                
//                NSString *str_MsgType = [json objectForKey:@"msgType"];
//                if( [str_MsgType isEqualToString:@"share"] )
//                {
//                    [self updateOneItemReplace:nRId];
//                }
//                else
//                {
//                    [dicM setObject:str_MsgType forKey:@"msgType"];
//                    [dicM setObject:[json objectForKey:@"lastMsg"] forKey:@"lastMsg"];
//                    [dicM setObject:[json objectForKey:@"lastChatDate"] forKey:@"lastChatDate"];
//                    
//                    [arM_Tmp removeObjectAtIndex:i];
//                    [arM_Tmp insertObject:dicM atIndex:0];
//                }
//            }
//            break;
//        }
//    }
//    
//    //userImg_prefix
//    //qnaRoomInfos
//    //userImg_prefix
//    //rId
//    
//    if( isFind == NO )
//    {
//        //신규 메세지
////        [self updateListWithIndicator:YES];
//        
//        NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
//        NSString *str_UserIds = [json objectForKey:@"userIds"];
//        NSArray *ar_Tmp = [str_UserIds componentsSeparatedByString:@","];
//        for( NSInteger i = 0; i < ar_Tmp.count; i++ )
//        {
//            NSInteger nId = [[ar_Tmp objectAtIndex:i] integerValue];
//            if( nMyId == nId )
//            {
//                NSString *str_CountKey = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//                NSMutableDictionary *dicM_Count = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:str_CountKey]];
//                NSInteger nCount = [[dicM_Count objectForKey:[NSString stringWithFormat:@"%ld", nRId]] integerValue];
//                nCount++;
//                [dicM_Count setObject:[NSString stringWithFormat:@"%ld", nCount] forKey:[NSString stringWithFormat:@"%ld", nRId]];
//                [[NSUserDefaults standardUserDefaults] setObject:dicM_Count forKey:str_CountKey];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//
//                [self updateOneItem:nRId];
//                break;
//            }
//        }
//    }
//    else
//    {
//        NSString *str_CountKey = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//        NSMutableDictionary *dicM_Count = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:str_CountKey]];
//        NSInteger nCount = [[dicM_Count objectForKey:[NSString stringWithFormat:@"%ld", nRId]] integerValue];
//        nCount++;
//        [dicM_Count setObject:[NSString stringWithFormat:@"%ld", nCount] forKey:[NSString stringWithFormat:@"%ld", nRId]];
//        [[NSUserDefaults standardUserDefaults] setObject:dicM_Count forKey:str_CountKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//        
//        self.arM_List = arM_Tmp;
//        [self.tbv_List reloadData];
//
//        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
//        [dicM setObject:self.arM_List forKey:@"qnaRoomInfos"];
//        [dicM setObject:@"200" forKey:@"response_code"];
//        [dicM setObject:str_ImagePrefix forKey:@"userImg_prefix"];
//        
//        NSString *str_Key = [NSString stringWithFormat:@"DashBoard_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//        NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:dicM];
//        [[NSUserDefaults standardUserDefaults] setObject:saveData forKey:str_Key];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}

//- (void)onRemoveDashboardItem:(NSNotification *)noti
//{
//    NSMutableArray *arM_Tmp = [NSMutableArray arrayWithArray:self.arM_List];
//    for( NSInteger i = 0; i < self.arM_List.count; i++ )
//    {
//        NSDictionary *dic = self.arM_List[i];
//        NSInteger nIdx = [[dic objectForKey:@"rId"] integerValue];
//        NSInteger nTargetIdx = [noti.object integerValue];
//        
//        if( nIdx == nTargetIdx )
//        {
//            [arM_Tmp removeObjectAtIndex:i];
//            break;
//        }
//    }
//    
//    self.arM_List = arM_Tmp;
//    [self.tbv_List reloadData];
//}

- (void)updateOneItem:(NSInteger)nIdx
{
    __weak __typeof__(self) weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        @"main", @"callWhere",
                                        [NSString stringWithFormat:@"%ld", nIdx], @"rId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/channel/qna/chat/room/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSArray *ar_Tmp = [NSArray arrayWithArray:[resulte objectForKey:@"qnaRoomInfos"]];
                                            if( ar_Tmp.count > 0 )
                                            {
                                                NSMutableArray *arM_Tmp = [NSMutableArray arrayWithArray:weakSelf.arM_List];
                                                for( NSInteger i = 0; i < self.arM_List.count; i++ )
                                                {
                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[i]];
                                                    NSInteger nTempRId = [[dicM objectForKey_YM:@"rId"] integerValue];
                                                    if( nIdx == nTempRId )
                                                    {
                                                        [arM_Tmp removeObjectAtIndex:i];
                                                    }
                                                }

                                                weakSelf.arM_List = [NSMutableArray arrayWithArray:arM_Tmp];

                                                NSDictionary *dic_Tmp = [NSDictionary dictionaryWithDictionary:[ar_Tmp firstObject]];
                                                NSMutableArray *arM_First = [NSMutableArray arrayWithObject:dic_Tmp];
                                                [arM_First addObjectsFromArray:weakSelf.arM_List];
                                                weakSelf.arM_List = [NSMutableArray arrayWithArray:arM_First];

                                                [weakSelf.tbv_List reloadData];
                                            }
                                        }
                                    }];
}

- (void)updateOneItemReplace:(NSInteger)nIdx
{
//    NSString *temp = [NSString stringWithFormat:@"%ld", nIdx];
//    ALERT(@"nIdx", temp, nil, @"확인", nil);
    
    //        [dicM setObject:str_Body forKey:@"body"];

    __weak __typeof__(self) weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        @"main", @"callWhere",
                                        [NSString stringWithFormat:@"%ld", nIdx], @"rId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/channel/qna/chat/room/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        [SVProgressHUD dismiss];
                                        
                                        if( resulte )
                                        {
                                            NSArray *ar_Tmp = [NSArray arrayWithArray:[resulte objectForKey:@"qnaRoomInfos"]];
                                            if( ar_Tmp.count > 0 )
                                            {
                                                NSMutableArray *arM_Tmp = [NSMutableArray arrayWithArray:weakSelf.arM_List];
                                                NSDictionary *dic_My = [NSDictionary dictionaryWithDictionary:[ar_Tmp firstObject]];
                                                for( NSInteger i = 0; i < arM_Tmp.count; i++ )
                                                {
                                                    NSDictionary *dic = arM_Tmp[i];
                                                    
                                                    NSInteger nIdx = [[dic objectForKey:@"rId"] integerValue];
                                                    NSInteger nMyIdx = [[dic_My objectForKey:@"rId"] integerValue];
                                                    
                                                    if( nIdx == nMyIdx )
                                                    {
                                                        [arM_Tmp removeObjectAtIndex:i];
                                                        break;
                                                    }
                                                }
                                                
                                                [arM_Tmp insertObject:dic_My atIndex:0];
                                                weakSelf.arM_List = [NSMutableArray arrayWithArray:arM_Tmp];
                                                [weakSelf.tbv_List reloadData];
                                                [weakSelf.tbv_List setNeedsLayout];
                                            }
                                        }
                                    }];
}


- (void)onChannelJoinInterval
{
    [self joinMainChannel];
}

- (void)onReload
{
//    [self updateListWithIndicator:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSLog(@"1111 : %@", [SendBird getUserId]);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)joinMainChannel
{
    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_chatdashboard_%@", @"0"];
    NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_chatdashboard_%@_%@", @"토팅", @"0"];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        kSendBirdApiToken, @"auth",
                                        str_ChannelUrl, @"channel_url",
                                        str_ChannelName, @"name",
                                        nil];

    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:@"channel/create"
                                             param:dicM_Params
                                        withMethod:@"POST"
                                         withBlock:^(id resulte, NSError *error) {

                                             if( resulte )
                                             {
                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
                                                 {
                                                     //이미 방이 있으면 조인
                                                     self.str_CurrentChannel = str_ChannelUrl;

//                                                     [SendBird joinChannel:str_ChannelUrl];
//                                                     [SendBird connect];
                                                     
                                                     [[NSUserDefaults standardUserDefaults] setObject:str_ChannelUrl forKey:@"DashBoardChannel"];
                                                 }
                                                 else
                                                 {
                                                     self.str_CurrentChannel = [resulte objectForKey:@"channel_url"];

//                                                     [SendBird joinChannel:[resulte objectForKey:@"channel_url"]];
//                                                     [SendBird connect];
                                                     
                                                     [[NSUserDefaults standardUserDefaults] setObject:str_ChannelUrl forKey:@"DashBoardChannel"];
                                                 }
                                                 
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 
                                                 [self updateList];

//                                                 [SBDOpenChannel getChannelWithUrl:self.str_CurrentChannel
//                                                                 completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
//                                                                     
//                                                                     [channel enterChannelWithCompletionHandler:^(SBDError * _Nullable error) {
//                                                                         
//                                                                         [self updateList];
//                                                                     }];
//                                                                 }];
                                             }
                                         }];
}

- (void)updateList
{
    self.groupChannelListQuery = [SBDGroupChannel createMyGroupChannelListQuery];
    self.groupChannelListQuery.limit = 100;
    self.groupChannelListQuery.order = SBDGroupChannelListOrderLatestLastMessage;
    self.groupChannelListQuery.includeEmptyChannel = NO;   //아무 대화가 없는 채널 보일지 말지 (YES는 보이는거)
//    self.groupChannelListQuery.customTypeFilter = self.str_ChannelId;
    NSLog(@"%@", self.str_ChannelId);
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
            
            self.arM_List = [NSMutableArray arrayWithArray:arM_Tmp];
        }
        else
        {
            self.arM_List = [NSMutableArray arrayWithArray:channels];
        }
        
        NSInteger nTotalUnReadCount = 0;
        for( NSInteger i = 0; i < self.arM_List.count; i++ )
        {
            SBDGroupChannel *groupChannel = self.arM_List[i];
            nTotalUnReadCount += groupChannel.unreadMessageCount;
        }
        
        NSLog(@"nTotalUnReadCount : %ld", nTotalUnReadCount);
        
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
        if( nTotalUnReadCount > 0 )
        {
            item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalUnReadCount];
            [UIApplication sharedApplication].applicationIconBadgeNumber = nTotalUnReadCount;
        }
        else
        {
            item.badgeValue = nil;
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbv_List reloadData];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        });
    }];

    
    
    
    
    
    
    
    
    
    
    
    
//    SBDGroupChannelListQuery *query = [SBDGroupChannel createMyGroupChannelListQuery];
//    query.includeEmptyChannel = NO; // 마지막 대화가 있는 방만 표시 (방 만들고 아무말도 안쓴건 표시 안함)
////    query.limit = 1;
//    [query loadNextPageWithCompletionHandler:^(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"Error: %@", error);
//            return;
//        }
//        
//        self.arM_List = [NSMutableArray arrayWithArray:channels];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tbv_List reloadData];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                [self.refreshControl endRefreshing];
//            });
//        });
//    }];
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

- (void)onRefresh:(ODRefreshControl *)sender
{
    [self updateList];
    
//    [self.arM_List removeAllObjects];
//    self.arM_List = nil;
    
    isFirstLoad = YES;
    
//    [self updateListWithIndicator:YES];
    
}


- (void)updateListWithIndicator:(BOOL)isIndicator
{
    NSInteger nUserId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
    if( nUserId == 0 || nUserId < 0 )
    {
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        @"main", @"callWhere",
                                        nil];
    
//    NSInteger nFinalChatDate = 0;
//    for( NSInteger i = 0; i < self.arM_List.count; i++ )
//    {
//        NSDictionary *dic = [self.arM_List objectAtIndex:i];
//        NSInteger nLastChatDate = [[dic objectForKey_YM:@"lastChatDate"] integerValue];
//        
//        if( nLastChatDate > nFinalChatDate )
//        {
//            nFinalChatDate = nLastChatDate;
//        }
//
//    }

    if( self.arM_List && self.arM_List.count > 0 && isFirstLoad == NO )
    {
        NSDictionary *dic = [self.arM_List firstObject];
        NSInteger nLastChatDate = [[dic objectForKey_YM:@"lastChatDate"] integerValue];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nLastChatDate] forKey:@"lastLoadDate"];
    }

    //리턴받고 배열 돌려서 새로 받은 rId중에 기존에 데이터가 있는지 확인하고 있으면 지운다
    //리턴 받은 데이터를 기존 데이터에 애드 시킨다
    
    NSLog(@"Feed Main Start");
//    [Util showToast:@"대시보드 호출"];
//    ALERT(@"", @"대시보드 호출", nil, @"ok", nil);
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/channel/qna/chat/room/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                withIndicator:isIndicator
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                        [SVProgressHUD dismiss];
                                        
                                        [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                        
                                        if( resulte )
                                        {
                                            if( isFirstLoad )
                                            {
                                                //첫번째 로드
                                                [self updateView:resulte];
                                            }
                                            else
                                            {
                                                //두번째 로드부터
                                                NSMutableArray *arM = [NSMutableArray arrayWithArray:[resulte objectForKey:@"qnaRoomInfos"]];
                                                NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
                                                for( NSInteger i = 0; i < arM.count; i++ )
                                                {
                                                    NSDictionary *dic = [arM objectAtIndex:i];
                                                    NSInteger nRId = [[dic objectForKey:@"rId"] integerValue];
                                                    
                                                    for( NSInteger j = 0; j < self.arM_List.count; j++ )
                                                    {
                                                        NSDictionary *dic_Tmp = [self.arM_List objectAtIndex:j];
                                                        NSInteger nTargetRId = [[dic_Tmp objectForKey:@"rId"] integerValue];
                                                        if( nTargetRId == nRId )
                                                        {
                                                            [indexes addIndex:j];
                                                            break;
                                                        }
                                                    }
                                                }
                                                
                                                //지울놈은 지워주고
                                                [self.arM_List removeObjectsAtIndexes:indexes];
                                                
                                                //서버로부터 받은 최신 싱싱한 데이터는 젤 앞에 애드
                                                NSArray *ar_Tmp = [NSArray arrayWithArray:self.arM_List];
                                                self.arM_List = [NSMutableArray arrayWithArray:arM];
                                                [self.arM_List addObjectsFromArray:ar_Tmp];

                                                
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                [dicM setObject:self.arM_List forKey:@"qnaRoomInfos"];
                                                [self updateView:dicM];
                                            }
                                            
                                            isFirstLoad = NO;
                                        }
                                        
                                        NSLog(@"Feed Main End");
                                    }];
}

- (void)updateView:(NSDictionary *)resulte
{
    NSString *str_Key = [NSString stringWithFormat:@"DashBoard_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:resulte];
    [[NSUserDefaults standardUserDefaults] setObject:saveData forKey:str_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];

    str_ImagePrefix = [resulte objectForKey:@"userImg_prefix"];
    
    NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
    if( nCode == 200 )
    {
        self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"qnaRoomInfos"]];

        NSString *str_CountKey = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        NSMutableDictionary *dicM_Count = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:str_CountKey]];

        for( NSInteger i = 0; i < self.arM_List.count; i++ )
        {
            NSDictionary *dic = self.arM_List[i];
            
            [dicM_Count setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"newQnaCount"] integerValue]] forKey:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"rId"] integerValue]]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:dicM_Count forKey:str_CountKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [self.navigationController.view makeToast:[resulte objectForKey_YM:@"error_message"] withPosition:kPositionCenter];
    }
    
    [self.tbv_List reloadData];
    [self.tbv_List setNeedsLayout];
    
    NSInteger nTotalBadgeCnt = 0;
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        NSDictionary *dic = self.arM_List[i];
        NSInteger nBadgeCnt = [[dic objectForKey:@"newQnaCount"] integerValue];
        nTotalBadgeCnt += nBadgeCnt;
    }
    
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
    if( nTotalBadgeCnt > 0 )
    {
        item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalBadgeCnt];
        [UIApplication sharedApplication].applicationIconBadgeNumber = nTotalBadgeCnt;
    }
    else
    {
        item.badgeValue = nil;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}


#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    //버튼 선택시
    SBDGroupChannel *groupChannel = self.arM_List[cell.tag];

    if( index == 0 )
    {
        //읽음처리
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
        NSInteger nTotalUnReadCount = [item.badgeValue integerValue] - groupChannel.unreadMessageCount;
        if( nTotalUnReadCount <= 0 )
        {
            nTotalUnReadCount = 0;
            item.badgeValue = nil;
        }
        else
        {
            item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalUnReadCount];
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = nTotalUnReadCount;
        
        [groupChannel markAsRead];
        [cell hideUtilityButtonsAnimated:YES];
    }
    else if( index == 1 )
    {
        //나가기
        UIAlertView *alert = CREATE_ALERT(nil, @"이 대화방을 나가시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
                NSInteger nTotalUnReadCount = [item.badgeValue integerValue] - groupChannel.unreadMessageCount;
                if( nTotalUnReadCount <= 0 )
                {
                    nTotalUnReadCount = 0;
                    item.badgeValue = nil;
                }
                else
                {
                    item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalUnReadCount];
                }
                
                [UIApplication sharedApplication].applicationIconBadgeNumber = nTotalUnReadCount;
                
                [groupChannel markAsRead];

                [cell hideUtilityButtonsAnimated:YES];
                
                [self.arM_List removeObjectAtIndex:cell.tag];
                [self.tbv_List reloadData];
                
                [self leaveChat:groupChannel];

                [groupChannel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                    
                }];

                SBDBaseChannel *baseChannel = (SBDBaseChannel *)groupChannel;
                NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
                NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"rId"]];
                
                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                    [Util getUUID], @"uuid",
                                                    @"menu", @"pageInfo",
                                                    @"hide", @"setMode",
                                                    str_RId, @"rId",
                                                    nil];
                
                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/hide/my/qna/chat/room"
                                                    param:dicM_Params
                                               withMethod:@"POST"
                                                withBlock:^(id resulte, NSError *error) {
                                                    
                                                    [MBProgressHUD hide];
                                                    
                                                    if( resulte )
                                                    {
                                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                        if( nCode == 200 )
                                                        {

                                                        }
                                                        else
                                                        {

                                                        }
                                                    }
                                                }];
            }
        }];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:170.f/255.f green:170.f/255.f blue:170.f/255.f alpha:1]
                                           normalIcon:BundleImage(@"sw_read.png")
                                         selectedIcon:BundleImage(@"sw_read.png")];

    [rightUtilityButtons sw_addUtilityButtonWithColor:kMainRedColor
                                           normalIcon:BundleImage(@"sw_leave.png")
                                         selectedIcon:BundleImage(@"sw_leave.png")];

    return rightUtilityButtons;
}

- (void)leaveChat:(SBDBaseChannel *)channel
{
    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다.", str_UserName];

    //나감
    NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
    [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
    [dicM_Param setObject:str_Msg forKey:@"message"];
    [dicM_Param setObject:@"cmd" forKey:@"custom_type"];
    
    NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
    [dicM_Data setObject:@"USER_LEFT" forKey:@"type"];
    
    NSMutableDictionary *dicM_Inviter = [NSMutableDictionary dictionary];
    [dicM_Inviter setObject:str_UserId forKey:@"user_id"];
    [dicM_Inviter setObject:str_UserName forKey:@"nickname"];
    [dicM_Data setObject:dicM_Inviter forKey:@"sender"];
    
    
//    NSMutableArray *arM_Users = [NSMutableArray array];
//    NSArray *ar_Users = [NSArray arrayWithArray:data];
//    for( NSInteger i = 0; i < ar_Users.count; i++ )
//    {
//        NSDictionary *dic_User = ar_Users[i];
//        NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic_User objectForKey:@"userId"]];
//        [arM_Users addObject:@{@"user_id":str_UserId, @"nickname":[dic_User objectForKey:@"userName"]}];
//    }
    [dicM_Data setObject:[NSArray array] forKey:@"users"];
    
    [dicM_Data setObject:str_Msg forKey:@"message"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [dicM_Param setObject:jsonString forKey:@"data"];
    
    //        [dicM_Param setObject:@"true" forKey:@"is_silent"];
    [dicM_Param setObject:@"true" forKey:@"is_silent"];
    
    NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", channel.channelUrl];
    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
                                             param:dicM_Param
                                        withMethod:@"POST"
                                         withBlock:^(id resulte, NSError *error) {
                                             
                                             if( resulte )
                                             {
                                                 
                                             }
                                         }];
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSInteger nTotalBadgeCnt = 0;
//    NSString *str_CountKey = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    NSMutableDictionary *dicM_Count = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:str_CountKey]];
//    for( NSInteger i = 0; i < dicM_Count.allKeys.count; i++ )
//    {
//        NSString *str_Key = [dicM_Count.allKeys objectAtIndex:i];
//        NSInteger nCount = [[dicM_Count objectForKey:str_Key] integerValue];
//        nTotalBadgeCnt += nCount;
//    }
//    
//    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
//    if( nTotalBadgeCnt > 0 )
//    {
//        item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalBadgeCnt];
//        [UIApplication sharedApplication].applicationIconBadgeNumber = nTotalBadgeCnt;
//    }
//    else
//    {
//        item.badgeValue = nil;
//        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    }

    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatFeedCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    cell.tag = indexPath.row;
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;

    cell.iv_User.backgroundColor = [UIColor clearColor];

    SBDGroupChannel *groupChannel = self.arM_List[indexPath.row];
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
                NSString *str_ImageUrl = [dic_Tmp objectForKey:@"imgUrl"];
                if( [str_ImageUrl hasPrefix:@"http"] == NO )
                {
                    if( str_ImagePrefix == nil || str_ImagePrefix.length <= 0 )
                    {
                        str_ImageUrl = [NSString stringWithFormat:@"%@%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"], str_ImageUrl];
                    }
                    else
                    {
                        str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePrefix, str_ImageUrl];
                    }
                }
                [cell.iv_User setImageWithURL:[NSURL URLWithString:str_ImageUrl] usingCache:NO];
                
                //1:1 채팅일때 상대방 닉네임
                cell.lb_Title.text = [dic_Tmp objectForKey_YM:@"userName"];
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
    else if( [lastMessage.customType isEqualToString:@"pdf"] )
    {
        [cell.btn_Type setImage:BundleImage(@"camera_icon_small.png") forState:UIControlStateNormal];
        [cell.btn_Type setTitle:@"PDF 문제" forState:UIControlStateNormal];
        cell.btn_Type.hidden = NO;
        
        cell.lb_Disc2.text = @"";
    }
    else if( [lastMessage.customType isEqualToString:@"audio"] )
    {
        [cell.btn_Type setImage:BundleImage(@"audio_icon_samll.png") forState:UIControlStateNormal];
        [cell.btn_Type setTitle:@"음성" forState:UIControlStateNormal];
        cell.btn_Type.hidden = NO;
        
        cell.lb_Disc2.text = @"";
    }
    else if( [lastMessage.customType isEqualToString:@"shareExam"] || [lastMessage.customType isEqualToString:@"shareQuestion"] )
    {
        cell.lb_Disc1.text = [dic objectForKey_YM:@"subjectName"];
        cell.lb_Disc1.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
        
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
    else if( [lastMessage.customType isEqualToString:@"pdfQuestion"] || [lastMessage.customType isEqualToString:@"normalQuestion"] )
    {
        cell.lb_Disc1.text = @"";
        cell.lb_Disc2.text = @"""질문이 등록 되었습니다""";
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

    
//    NSDate *currDate = [NSDate date];
//    NSDateComponents *lastMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lastMessageDate];
//    NSDateComponents *currDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currDate];
//
//    if (lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day)
//    {
//        //오늘이 아니면 6월 20일
//        [lastMessageDateFormatter setDateStyle:NSDateFormatterShortStyle];
//        [lastMessageDateFormatter setTimeStyle:NSDateFormatterNoStyle];
//        NSString *str_Time = [lastMessageDateFormatter stringFromDate:lastMessageDate];
//        cell.lb_Date.text = str_Time;
//        NSLog(@"%@", str_Time);
//    }
//    else
//    {
//        //오늘이면 오전 5:47
//        [lastMessageDateFormatter setDateStyle:NSDateFormatterNoStyle];
//        [lastMessageDateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        NSString *str_Time = [lastMessageDateFormatter stringFromDate:lastMessageDate];
//        cell.lb_Date.text = str_Time;
//        NSLog(@"%@", str_Time);
//    }

    return cell;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     channelId = 7;
     channelImgUrl = "000/000/realEstateAgent.jpg";
     channelName = "\Uacf5\Uc778\Uc911\Uac1c\Uc0ac";
     chatType = N;
     codeHex = "";
     fileType = image;
     height = 960;
     inviteUserIdStr = "108,139,127,123,136,138";
     itemType = qna;
     lastChatDate = 20161104000243;
     lastMsg = "000/000/801c426612f533fdbd8689185637ec0e.jpg";
     lastViewDate = "";
     name = "\Ud53c\Ud130";
     newQnaCount = 0;
     orderInx = 0;
     ownerId = 126;
     pdfHeight = 0;
     pdfWidth = 0;
     qnaCount = 5;
     questionId = 24049;
     questionPage = 1;
     rId = 114;
     roomCreateDate = 20161104000126;
     roomName = "11/03 \Uc548\Ub4dc\Ub85c\Uc774\Ub4dc \Ud53c\Ub4dc\Ubc31";
     roomType = channel;
     startX = 0;
     startY = 0;
     toUserId = 126;
     useOk = Y;
     userCount = 7;
     userThumbnail = "000/000/64b3fb44f64538429dc98eed469eaef4.jpg";
     width = 540;
     */
    
//    cell.iv_User.backgroundColor = [UIColor clearColor];
//    
//    NSString *str_RoomType = [dic objectForKey_YM:@"roomType"];
//
//    //방 제목
//    if( [str_RoomType isEqualToString:@"user"] )
//    {
//        cell.lb_Title.text = [dic objectForKey_YM:@"userName"];
//    }
//    else
//    {
//        cell.lb_Title.text = [dic objectForKey_YM:@"roomName"];
//    }
//    
//    //그룹방 여부
//    cell.lb_GroupCount.text = cell.lb_TotalUser.text = @"";
//    cell.iv_User.image = BundleImage(@"");
//    cell.iv_User.backgroundColor = [UIColor clearColor];
//    
//    if( [str_RoomType isEqualToString:@"group"] )
//    {
//        cell.lb_GroupCount.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userCount"]];
//        cell.iv_User.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
//        cell.iv_User.image = BundleImage(@"");
//    }
//    else if( [str_RoomType isEqualToString:@"user"] )
//    {
//        NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
//        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
//
////        cell.lb_Title.text = [dic objectForKey_YM:@"userName"];
//
//    }
////    else if( [str_RoomType isEqualToString:@"channel"] )
////    else if( [str_RoomType isEqualToString:@"channelQna"] )
//    else
//    {
//        NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"channelImgUrl"]];
//        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
//        
//        //        cell.lb_Title.text = [dic objectForKey_YM:@"channelName"];
//        cell.lb_TotalUser.text = [NSString stringWithFormat:@"%@명", [dic objectForKey_YM:@"userCount"]];
//    }
//
//    
//    //하단 메세지
//    cell.btn_Type.hidden = YES;
//    cell.lb_Disc1.text = cell.lb_Disc2.text = @"";
//    [cell.btn_Type setImage:BundleImage(@"") forState:UIControlStateNormal];
//    [cell.btn_Type setTitle:@"" forState:UIControlStateNormal];
//
//    NSString *str_MsgType = [dic objectForKey_YM:@"msgType"];
//    if( [str_MsgType isEqualToString:@"text"] )
//    {
////        cell.lb_Disc1.text = [dic objectForKey_YM:@"subjectName"];
////        cell.lb_Disc1.backgroundColor = [UIColor colorWithHexString:[dic objectForKey:@"subjectCodeHex"]];
////        
////        if( cell.lb_Disc1.text.length > 0 )
////        {
////            cell.lb_Disc2.text = [NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"examTitle"]];
////            cell.lb_Disc2.text = [cell.lb_Disc2.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
////            NSMutableString *strM = [NSMutableString string];
////            [strM appendString:cell.lb_Disc2.text];
////            cell.lb_Disc2.text = strM;
////        }
////        else
////        {
//            cell.lb_Disc2.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"lastMsg"]];
//            cell.lb_Disc2.text = [cell.lb_Disc2.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//            NSMutableString *strM = [NSMutableString string];
//            [strM appendString:@"''"];
//            [strM appendString:cell.lb_Disc2.text];
//            [strM appendString:@"''"];
//            cell.lb_Disc2.text = strM;
////        }
//    }
//    else if( [str_MsgType isEqualToString:@"image"] )
//    {
//        [cell.btn_Type setImage:BundleImage(@"camera_icon_small.png") forState:UIControlStateNormal];
//        [cell.btn_Type setTitle:@"사진" forState:UIControlStateNormal];
//        cell.btn_Type.hidden = NO;
//    }
//    else if( [str_MsgType isEqualToString:@"video"] )
//    {
//        [cell.btn_Type setImage:BundleImage(@"video_icon_samll.png") forState:UIControlStateNormal];
//        [cell.btn_Type setTitle:@"동영상" forState:UIControlStateNormal];
//        cell.btn_Type.hidden = NO;
//    }
//    else if( [str_MsgType isEqualToString:@"share"] )
//    {
//        //이 외는 문제 공유
//        cell.lb_Disc1.text = [dic objectForKey_YM:@"subjectName"];
//        cell.lb_Disc1.backgroundColor = [UIColor colorWithHexString:[dic objectForKey:@"subjectCodeHex"]];
//        
//        if( cell.lb_Disc1.text.length > 0 )
//        {
//            cell.lb_Disc2.text = [NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"examTitle"]];
//            cell.lb_Disc2.text = [cell.lb_Disc2.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//            NSMutableString *strM = [NSMutableString string];
//            [strM appendString:cell.lb_Disc2.text];
//            cell.lb_Disc2.text = strM;
//        }
//        else
//        {
//            cell.lb_Disc2.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"lastMsg"]];
//            cell.lb_Disc2.text = [cell.lb_Disc2.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//            NSMutableString *strM = [NSMutableString string];
//            [strM appendString:@"''"];
//            [strM appendString:cell.lb_Disc2.text];
//            [strM appendString:@"''"];
//            cell.lb_Disc2.text = strM;
//        }
//    }
//    else
//    {
//        //여긴 내가 임의로 만든 데이터 구조 (채팅 대시보드를 위함)
//        cell.lb_Disc2.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"lastMsg"]];
//        cell.lb_Disc2.text = [cell.lb_Disc2.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//        NSMutableString *strM = [NSMutableString string];
//        [strM appendString:@"''"];
//        [strM appendString:cell.lb_Disc2.text];
//        [strM appendString:@"''"];
//        cell.lb_Disc2.text = strM;
//    }
//    
//    
//    //날짜
////    lastChatDate = 20161104000243;
//    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"lastChatDate"]];
//    if( str_Date.length >= 14 )
//    {
//        cell.lb_Date.text = [Util getMainThotingChatDate:str_Date];
//    }
//    else
//    {
//        str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"roomCreateDate"]];
//        if( str_Date.length >= 14 )
//        {
//            cell.lb_Date.text = [Util getMainThotingChatDate:str_Date];
//        }
//        else
//        {
//            cell.lb_Date.text = str_Date;
//        }
//    }
////    [str_Date substringWithRange:NSMakeRange(4, 2)];
//
//    
//    
//    
//    
//    
//    
//    NSString *str_CountKey = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    NSMutableDictionary *dicM_Count = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:str_CountKey]];
//    NSInteger nBadgeCount = [[dicM_Count objectForKey:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"rId"] integerValue]]] integerValue];
//    if( nBadgeCount > 0 )
//    {
//        cell.v_BadgeGuide.hidden = NO;
//        cell.lb_Badge.text = [NSString stringWithFormat:@"%ld", nBadgeCount];
//    }
//    else
//    {
//        cell.v_BadgeGuide.hidden = YES;
//        cell.lb_Badge.text = @"";
////        cell.v_BadgeGuide.hidden = NO;
////        cell.lb_Badge.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
//    }
//
//    
//    
////    //뱃지
////    NSInteger nNewQCnt = [[dic objectForKey_YM:@"newQnaCount"] integerValue];
////    if( nNewQCnt > 0 )
////    {
////        cell.v_BadgeGuide.hidden = NO;
////        cell.lb_Badge.text = [NSString stringWithFormat:@"%ld", nNewQCnt];
////    }
////    else
////    {
////        cell.v_BadgeGuide.hidden = YES;
////        cell.lb_Badge.text = @"";
//////        cell.v_BadgeGuide.hidden = NO;
//////        cell.lb_Badge.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
////    }
//    
//    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SBDGroupChannel *groupChannel = self.arM_List[indexPath.row];
    [groupChannel markAsRead];
    SBDBaseChannel *baseChannel = (SBDBaseChannel *)groupChannel;
    NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];

   
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
    ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
    //    vc.hidesBottomBarWhenPushed = YES;
    vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"rId"]];
    vc.str_RoomName = [dic objectForKey_YM:@"roomName"];
    //    vc.str_ChatType = [NSString stringWithFormat:@"%@", [dic objectForKey:@"roomType"]];
    vc.roomColor = [UIColor colorWithHexString:[dic objectForKey:@"codeHex"]];
    vc.dic_Info = dic;
    vc.channelImageUrl = [NSURL URLWithString:baseChannel.coverUrl];
    vc.channel = groupChannel;
    vc.str_ChannelIdTmp = self.str_ChannelId;
//    vc.str_ChannelUrl = baseChannel.channelUrl;
    
    
    if( groupChannel.memberCount <= 2 )
    {
        id userThumbnail = [dic objectForKey:@"userThumbnail"];
        if( [userThumbnail isKindOfClass:[NSArray class]]  )
        {
            NSArray *ar = userThumbnail;
            
            for( NSInteger i = 0; i < ar.count; i++ )
            {
                NSDictionary *dic_Tmp = [ar objectAtIndex:i];
                if( [[dic_Tmp objectForKey:@"userId"] integerValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
                {
                    //1:1 채팅일때 상대방 유저 사진
                    NSString *str_TargetName = [dic_Tmp objectForKey_YM:@"userName"];
                    if( [[dic objectForKey:@"roomType"] isEqualToString:@"chatBot"] )
                    {
                        vc.dic_BotInfo = @{@"userId":[NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"userId"]]};
                        break;
                    }
                    else if( [str_TargetName isEqualToString:@"#영어듣기"] || [str_TargetName isEqualToString:@"#PDF"] || [str_TargetName isEqualToString:@"#스피킹매트릭스"] ||
                            [str_TargetName isEqualToString:@"#미술"] || [str_TargetName isEqualToString:@"#test"] )
                    {
                        //봇방
                        vc.dic_BotInfo = @{@"userId":[NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"userId"]]};
                        break;
                    }
                }
            }
        }
    }

    [self.navigationController pushViewController:vc animated:YES];
    
    
    
    
    
//    NSDictionary *dic = self.arM_List[indexPath.row];
//    
//    if( [[dic objectForKey_YM:@"useOk"] isEqualToString:@"Y"] == NO )
//    {
//        [Util showToast:@"입장 권한이 없습니다"];
//        return ;
//    }
//
//    //뱃지 카운트를 초기화
//    NSString *str_CountKey = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    NSMutableDictionary *dicM_Count = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:str_CountKey]];
//    [dicM_Count setObject:@"0" forKey:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"rId"] integerValue]]];
//    [[NSUserDefaults standardUserDefaults] setObject:dicM_Count forKey:str_CountKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    //초기화한 뱃지 카운트를 서버와 동기화
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"rId"] integerValue]], @"rId",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/exit/chat/room"
//                                        param:dicM_Params
//                                   withMethod:@"POST"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                
//                                            }
//                                            else
//                                            {
//                                                
//                                            }
//                                        }
//                                    }];
//
//    
//    
//    
//    
//    
//    
//    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
//    [dicM setObject:@"0" forKey:@"newQnaCount"];
//    [self.arM_List replaceObjectAtIndex:indexPath.row withObject:dicM];
//
//    [self.tbv_List beginUpdates];
//    NSArray *array = [NSArray arrayWithObjects:indexPath, nil];
//    [self.tbv_List reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
//    [self.tbv_List endUpdates];
//
//    
//    
//    
//    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
//    ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
////    vc.hidesBottomBarWhenPushed = YES;
//    vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"rId"]];
//    vc.str_RoomName = [dic objectForKey_YM:@"roomName"];
////    vc.str_ChatType = [NSString stringWithFormat:@"%@", [dic objectForKey:@"roomType"]];
//    vc.roomColor = [UIColor colorWithHexString:[dic objectForKey:@"codeHex"]];
//    vc.dic_Info = dic;
//    vc.channelImageUrl = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"channelImgUrl"]];
//
//    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)getDday:(NSString *)aDay
{
    aDay = [aDay stringByReplacingOccurrencesOfString:@"-" withString:@""];
    aDay = [aDay stringByReplacingOccurrencesOfString:@" " withString:@""];
    aDay = [aDay stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *str_Year = [aDay substringWithRange:NSMakeRange(0, 4)];
    NSString *str_Month = [aDay substringWithRange:NSMakeRange(4, 2)];
    NSString *str_Day = [aDay substringWithRange:NSMakeRange(6, 2)];
    NSString *str_Hour = [aDay substringWithRange:NSMakeRange(8, 2)];
    NSString *str_Minute = [aDay substringWithRange:NSMakeRange(10, 2)];
    NSString *str_Second = [aDay substringWithRange:NSMakeRange(12, 2)];
    NSString *str_Date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", str_Year, str_Month, str_Day, str_Hour, str_Minute, str_Second];
    
    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    
    NSDate *ddayDate = [format1 dateFromString:str_Date];
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSDate *currentTime = [format1 dateFromString:[NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond]];
    
    NSTimeInterval diff = [currentTime timeIntervalSinceDate:ddayDate];
    
    NSTimeInterval nWriteTime = diff;
    
    
    
    
    if( nWriteTime > (60 * 60 * 24) )
    {
//        return [NSString stringWithFormat:@"%@-%@-%@", str_Year, str_Month, str_Day];
        return [NSString stringWithFormat:@"%@월 %@일", str_Month, str_Day];
    }
    else
    {
        if( nWriteTime <= 0 )
        {
            return @"1초전";
        }
        else if( nWriteTime < 60 )
        {
            //1분보다 작을 경우
            return [NSString stringWithFormat:@"%.0f초전", nWriteTime];
        }
        else if( nWriteTime < (60 * 60) )
        {
            //1시간보다 작을 경우
            return [NSString stringWithFormat:@"%.0f분전", nWriteTime / 60];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f시간전", ((nWriteTime / 60) / 60)];
        }
    }
    
    
    return @"";
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arM_Online.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"OnlineCell";
    
    OnlineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    /*
     aId = 1;
     answerCount = 1;
     channelId = 4;
     displayName = "\Uad6d\Uc5b4 \Uc81c\Uad8c";
     questionId = 35811;
     rId = 1011;
     thumbnail = "000/000/noImage15.png";
     userId = 123;
     userType = U;
     */
    
    NSDictionary *dic = self.arM_Online[indexPath.row];
    
    NSString *str_Type = [dic objectForKey:@"userType"];
    if( [str_Type isEqualToString:@"U"] )
    {
        //섬네일
        cell.lb_Count.text = @"";
        cell.iv_User.backgroundColor = [UIColor clearColor];
        
        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePrefix, [dic objectForKey:@"thumbnail"]];
        [cell.iv_User setImageWithURL:[NSURL URLWithString:str_ImageUrl] placeholderImage:nil usingCache:NO];
    }
    else if( [str_Type isEqualToString:@"B"] )
    {
        /*
         aId = 211;
         answerCount = 1;
         channelId = 0;
         displayName = "#\Uc601\Uc5b4\Ub4e3\Uae30";
         questionId = 0;
         rId = 0;
         roomType = chatBot;
         sendbirdChannelUrl = "";
         thumbnail = "000/000/noImage11.png";
         userId = 561;
         userType = B;
         */
        
//        //봇일 경우
//        OnlineBotCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OnlineBotCell" forIndexPath:indexPath];
//        cell.lb_Title.text = [dic objectForKey_YM:@"displayName"];
//        return cell;
        
        cell.iv_User.image = BundleImage(@"");
        cell.iv_User.backgroundColor = kMainColor;
        cell.lb_Count.text = @"#";
        [cell.lb_Count setFont:[UIFont systemFontOfSize:20.0]];
    }
    else
    {
        //카운트로 표시
        cell.iv_User.image = BundleImage(@"");
        cell.iv_User.backgroundColor = kMainColor;
        [cell.lb_Count setFont:[UIFont systemFontOfSize:15.0]];
        cell.lb_Count.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"answerCount"]];
    }
    
    cell.lb_Title.text = [dic objectForKey:@"displayName"];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block NSDictionary *dic = self.arM_Online[indexPath.row];
    
    __block NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
    __block NSString *str_TmpRId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
    __block NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePrefix, [dic objectForKey:@"thumbnail"]];

    NSString *str_SBChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];
    if( str_SBChannelUrl.length > 0 && [str_TmpRId integerValue] > 0 )
    {
        //기존 방이 있을 경우 기존걸 사용
        [SBDGroupChannel getChannelWithUrl:str_SBChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
           
            if( channel )
            {
                NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
                //            NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", @"1:1", str_RId];
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                vc.str_RId = str_RId;
                vc.dic_Info = dic;
                vc.str_RoomName = str_ChannelName;
                vc.str_RoomTitle = nil;
                vc.str_RoomThumb = str_ImageUrl;
                vc.ar_UserIds = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]]];
                vc.channel = channel;
                vc.str_ChannelIdTmp = self.str_ChannelId;
                if( [[dic objectForKey:@"roomType"] isEqualToString:@"chatBot"] )
                {
                    vc.dic_BotInfo = [NSDictionary dictionaryWithDictionary:dic];
                }
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [self makeNewRoom:dic withUserId:str_UserId withImageUrl:str_ImageUrl];
            }
        }];

    }
    else
    {
        [self makeNewRoom:dic withUserId:str_UserId withImageUrl:str_ImageUrl];
    }
    

    //유저 이름 가져오기
//    NSString *str_UserName = @"";
//    NSString *str_UserThumb = @"";
//    for( NSInteger i = 0; i < self.arM_List.count; i++ )
//    {
//        NSDictionary *dic_Tmp = [self.arM_List objectAtIndex:i];
//        if( [aUserId integerValue] == [[dic_Tmp objectForKey:@"userId"] integerValue] )
//        {
//            str_UserName = [dic_Tmp objectForKey_YM:@"userName"];
//            str_UserThumb = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic_Tmp objectForKey_YM:@"userThumbnail"]];
//            break;
//        }
//    }
    
    
    
    

    
    
    
    

    
    
    
    
    
    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
//    ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
//    vc.str_RId = str_RId;
//    vc.dic_Info = dic;
//    vc.str_RoomName = str_ChannelName;
//    vc.str_RoomTitle = nil;
//    vc.str_RoomThumb = str_ImageUrl;
//    vc.ar_UserIds = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]]];
//    [self.navigationController pushViewController:vc animated:YES];

}

- (void)makeNewRoom:(NSDictionary *)dic withUserId:(NSString *)str_UserId withImageUrl:(NSString *)str_ImageUrl
{
    //기존 방이 없을 경우 만들기
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        @"", @"roomName",
                                        str_UserId, @"inviteUserIdStr",
                                        @"group", @"channelType",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/make/chat/room"
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
                                                NSDictionary *dic_QnaInfo = [resulte objectForKey:@"qnaRoomInfo"];
                                                //                                                [self makeSendbird:dic withUserId:aInviteUser];
                                                
                                                //                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                //                                                [dicM setObject:str_ImageUrl forKey:@"userThumbnail"];
                                                
                                                NSMutableArray *arM_UserList = [NSMutableArray array];
                                                NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                                                [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
                                                [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
                                                [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
                                                [arM_UserList addObject:dicM_MyInfo];
                                                
                                                NSMutableDictionary *dicM_OtherInfo = [NSMutableDictionary dictionary];
                                                [dicM_OtherInfo setObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]] forKey:@"userId"];
                                                [dicM_OtherInfo setObject:[dic objectForKey:@"displayName"] forKey:@"userName"];
                                                [dicM_OtherInfo setObject:str_ImageUrl forKey:@"imgUrl"];
                                                [arM_UserList addObject:dicM_OtherInfo];
                                                
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_QnaInfo];
                                                [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                
                                                
                                                NSString *str_RId = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"rId"]];
                                                //                                                    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
                                                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", @"1:1", str_RId];
                                                
                                                NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
                                                NSError * err;
                                                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
                                                NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                
                                                [SBDGroupChannel createChannelWithName:@"" isDistinct:NO userIds:@[str_UserId] coverUrl:@"" data:str_Dic customType:self.str_ChannelId
                                                                     completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                                         
                                                                         if (error != nil)
                                                                         {
                                                                             NSLog(@"Error: %@", error);
                                                                             if( error.code == 400201 )
                                                                             {
                                                                                 UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                                                 [window makeToast:@"가입된 회원이 아닙니다" withPosition:kPositionCenter];
                                                                             }
                                                                             return;
                                                                         }
                                                                         
                                                                         SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                                                                         NSLog(@"%@", baseChannel.channelUrl);
                                                                         [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                                                                         
                                                                         //https://sites.google.com/site/thotingapi/api/api-jeong-ui/api-list/chaetingbangsendbirdchannelurlbyeongyeong
                                                                         //여기에 채널url 등록
                                                                         
                                                                         NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                                         [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"questionId"]] forKey:@"questionId"];
                                                                         
                                                                         UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                                                         ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                                                         vc.str_RId = str_RId;
                                                                         vc.dic_Info = dicM;
                                                                         vc.str_RoomName = str_ChannelName;
                                                                         vc.str_RoomTitle = nil;
                                                                         vc.str_RoomThumb = str_ImageUrl;
                                                                         vc.ar_UserIds = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]]];
                                                                         vc.channel = channel;
                                                                         vc.str_ChannelIdTmp = self.str_ChannelId;
                                                                         if( [[dic objectForKey:@"roomType"] isEqualToString:@"chatBot"] )
                                                                         {
                                                                             vc.dic_BotInfo = [NSDictionary dictionaryWithDictionary:dic];
                                                                         }
                                                                         [self.navigationController pushViewController:vc animated:YES];
                                                                     }];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (IBAction)goShowInvite:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
    ChatFeedMemeberInviteViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedMemeberInviteViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.str_UserImagePrefix = str_ImagePrefix;
    vc.str_ChannelId = self.str_ChannelId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goReceiveSend:(id)sender
{
    NSString *str_Key2 = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_ChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key2];
    
    ReciveSendViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReciveSendViewController"];
    vc.str_ChannelId = str_ChannelId;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - SendBird
//- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message
//{
//    
//
//    
////    NSLog(@"%@", [message sender]);
////    NSLog(@"%@", [message getSenderName]);
////    NSLog(@"%lld", [message getMessageId]);
////    NSLog(@"%@", message.jsonObj);
////    NSLog(@"%@", message.toJson);
////    
////    NSLog(@"Recive");
////    NSLog(@"message.message: %@, message.data: %@", message.message, message.data);
////    //        ALERT(nil, message.message, nil, @"확인", nil);
////    
////    NSData* data = [message.data dataUsingEncoding:NSUTF8StringEncoding];
////    
////    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
////    NSMutableDictionary *dicM_Result = [NSMutableDictionary dictionaryWithDictionary:[jsonParser objectWithString:dataString]];
////    
////    NSLog(@"dicM_Result : %@", dicM_Result);
//
//    
//    
//    
//    
//    
//    //        NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
//    //        NSInteger nTargetId = [[dicM_Result objectForKey_YM:@"userId"] integerValue];
//    
//    //        if( [message.message isEqualToString:@"dashBoardUpdate"] )
//    //        {
//    //            [[NSNotificationCenter defaultCenter] postNotificationName:@"DashBoardUpdate" object:message.data];
//    //        }
//
//}
//
//
////- (void)startSendBird
////{
//////    [SendBird registerNotificationHandlerMessagingChannelUpdatedBlock:^(SendBirdMessagingChannel *channel) {
//////        
//////        NSLog(@"@@@@@@@@@@@@@");
//////    }mentionUpdatedBlock:^(SendBirdMention *mention) {
//////        
//////        NSLog(@"Aaaaaaaaaaaaa");
//////    }];
////
////    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
////        
////    } errorBlock:^(NSInteger code) {
////        
////    } channelLeftBlock:^(SendBirdChannel *channel) {
////        
////    } messageReceivedBlock:^(SendBirdMessage *message) {
////        
////        NSLog(@"%@", [message sender]);
////        NSLog(@"%@", [message getSenderName]);
////        NSLog(@"%lld", [message getMessageId]);
////        NSLog(@"%@", message.jsonObj);
////        NSLog(@"%@", message.toJson);
////        
////        NSLog(@"Recive");
////        NSLog(@"message.message: %@, message.data: %@", message.message, message.data);
////        //        ALERT(nil, message.message, nil, @"확인", nil);
////        
////        NSData* data = [message.data dataUsingEncoding:NSUTF8StringEncoding];
////        
////        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
////        NSMutableDictionary *dicM_Result = [NSMutableDictionary dictionaryWithDictionary:[jsonParser objectWithString:dataString]];
////        
////        NSLog(@"dicM_Result : %@", dicM_Result);
////        
//////        NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
//////        NSInteger nTargetId = [[dicM_Result objectForKey_YM:@"userId"] integerValue];
////        
//////        if( [message.message isEqualToString:@"dashBoardUpdate"] )
//////        {
//////            [[NSNotificationCenter defaultCenter] postNotificationName:@"DashBoardUpdate" object:message.data];
//////        }
////        
////    } systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
////        
////    } broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
////        
////    } fileReceivedBlock:^(SendBirdFileLink *fileLink) {
////        
////    } messagingStartedBlock:^(SendBirdMessagingChannel *channel) {
////        
////    } messagingUpdatedBlock:^(SendBirdMessagingChannel *channel) {
////        
////    } messagingEndedBlock:^(SendBirdMessagingChannel *channel) {
////        
////    } allMessagingEndedBlock:^{
////        
////    } messagingHiddenBlock:^(SendBirdMessagingChannel *channel) {
////        
////    } allMessagingHiddenBlock:^{
////        
////    } readReceivedBlock:^(SendBirdReadStatus *status) {
////        
////    } typeStartReceivedBlock:^(SendBirdTypeStatus *status) {
////        
////    } typeEndReceivedBlock:^(SendBirdTypeStatus *status) {
////        
////        NSLog(@"typeEndReceivedBlock");
////        
////    } allDataReceivedBlock:^(NSUInteger sendBirdDataType, int count) {
////        
////        NSLog(@"allDataReceivedBlock");
////        
////    } messageDeliveryBlock:^(BOOL send, NSString *message, NSString *data, NSString *tempId) {
////        
////        NSLog(@"%@", message);
////        NSLog(@"%@", data);
////        NSLog(@"%@", tempId);
////    } mutedMessagesReceivedBlock:^(SendBirdMessage *message) {
////        
////        NSLog(@"%@", [message sender]);
////        NSLog(@"%@", [message getSenderName]);
////    } mutedFileReceivedBlock:^(SendBirdFileLink *message) {
////        
////    }];
////}
////
////+ (void)registerNotificationHandlerMessagingChannelUpdatedBlock:(void ( ^ ) ( SendBirdMessagingChannel *channel ))messagingChannelUpdated mentionUpdatedBlock:(void ( ^ ) ( SendBirdMention *mention ))mentionUpdated
////{
////    
////}
////
////+ (void)broadcastMessageReceived:(SendBirdBroadcastMessage *)msg
////
////{
////    
////}

- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    // Received a chat message
     
//    NSLog(@"%@", data.sender);
    
    if( [message isKindOfClass:[SBDAdminMessage class]] )
    {
        return;
    }
    
    if ([sender isKindOfClass:[SBDGroupChannel class]])
    {
        SBDUserMessage *data = (SBDUserMessage *)message;
        NSLog(@"%@", data.message);
        NSLog(@"%@", data.customType);

        SBDGroupChannel *messageReceivedChannel = (SBDGroupChannel *)sender;
        if ([self.arM_List indexOfObject:messageReceivedChannel] != NSNotFound)
        {
            [self.arM_List removeObject:messageReceivedChannel];
        }
        [self.arM_List insertObject:messageReceivedChannel atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSInteger nTotalUnReadCount = 0;
            for( NSInteger i = 0; i < self.arM_List.count; i++ )
            {
                SBDGroupChannel *groupChannel = self.arM_List[i];
                nTotalUnReadCount += groupChannel.unreadMessageCount;
            }
            
            NSLog(@"nTotalUnReadCount : %ld", nTotalUnReadCount);
            
            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
            if( nTotalUnReadCount > 0 )
            {
                item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalUnReadCount];
                [UIApplication sharedApplication].applicationIconBadgeNumber = nTotalUnReadCount;
            }
            else
            {
                item.badgeValue = nil;
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }
            
            
            [self.tbv_List reloadData];
        });
    }
}

//- (void)onReceiveMessageInterval:(SBDBaseChannel *)sender
//{
//    SBDGroupChannel *messageReceivedChannel = (SBDGroupChannel *)sender;
//    if ([self.arM_List indexOfObject:messageReceivedChannel] != NSNotFound)
//    {
//        [self.arM_List removeObject:messageReceivedChannel];
//    }
//    [self.arM_List insertObject:messageReceivedChannel atIndex:0];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        NSInteger nTotalUnReadCount = 0;
//        for( NSInteger i = 0; i < self.arM_List.count; i++ )
//        {
//            SBDGroupChannel *groupChannel = self.arM_List[i];
//            nTotalUnReadCount += groupChannel.unreadMessageCount;
//        }
//        
//        NSLog(@"nTotalUnReadCount : %ld", nTotalUnReadCount);
//        
//        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarBadgeIdx];
//        if( nTotalUnReadCount > 0 )
//        {
//            item.badgeValue = [NSString stringWithFormat:@"%ld", nTotalUnReadCount];
//            [UIApplication sharedApplication].applicationIconBadgeNumber = nTotalUnReadCount;
//        }
//        else
//        {
//            item.badgeValue = nil;
//            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//        }
//        
//        
//        [self.tbv_List reloadData];
//    });
//}

- (void)channel:(SBDBaseChannel * _Nonnull)sender didUpdateMessage:(SBDBaseMessage * _Nonnull)message
{
    
}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {
    // When read receipt has been updated
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    // When typing status has been updated
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    // When a new member joined the group channel
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    // When a member left the group channel
    
    NSString *str_MyId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    if ([str_MyId isEqualToString:user.userId])
    {
        [self.arM_List removeObject:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbv_List reloadData];
        });

//        [self performSelector:@selector(onRemoveRoom:) withObject:sender afterDelay:0.5f];
    }

}

- (void)onRemoveRoom:(SBDGroupChannel *)sender
{
    [self.arM_List removeObject:sender];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tbv_List reloadData];
    });
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidEnter:(SBDUser * _Nonnull)user {
    // When a new user entered the open channel
    
    SBDBaseChannel *baseChannel = (SBDBaseChannel *)sender;
    NSLog(@"%@", baseChannel.channelUrl);
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidExit:(SBDUser * _Nonnull)user {
    // When a new user left the open channel
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasMuted:(SBDUser * _Nonnull)user {
    // When a user is muted on the open channel
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnmuted:(SBDUser * _Nonnull)user {
    // When a user is unmuted on the open channel
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasBanned:(SBDUser * _Nonnull)user {
    // When a user is banned on the open channel
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnbanned:(SBDUser * _Nonnull)user {
    // When a user is unbanned on the open channel
}

- (void)channelWasFrozen:(SBDOpenChannel * _Nonnull)sender {
    // When the open channel is frozen
}

- (void)channelWasUnfrozen:(SBDOpenChannel * _Nonnull)sender {
    // When the open channel is unfrozen
}

- (void)channelWasChanged:(SBDBaseChannel * _Nonnull)sender {
    // When a channel property has been changed
    
    if ([sender isKindOfClass:[SBDGroupChannel class]])
    {
        SBDGroupChannel *messageReceivedChannel = (SBDGroupChannel *)sender;
        if ([self.arM_List indexOfObject:messageReceivedChannel] != NSNotFound)
        {
            [self.arM_List removeObject:messageReceivedChannel];
        }
        [self.arM_List insertObject:messageReceivedChannel atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbv_List reloadData];
        });
    }
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    // When a channel has been deleted
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    // When a message has been deleted
}

- (IBAction)goTest:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMainView];
}

@end
