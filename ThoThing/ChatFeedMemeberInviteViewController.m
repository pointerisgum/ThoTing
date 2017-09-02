//
//  ChatFeedMemeberInviteViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 23..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChatFeedMemeberInviteViewController.h"
#import "InvitationCell.h"
#import "UserPageMainViewController.h"
#import "ODRefreshControl.h"
#import "SharedHeaderCell.h"
#import "GroupMakeViewController.h"
#import "ChatFeedViewController.h"
#import "SBJsonParser.h"
#import "MyMainViewController.h"

@interface ChatFeedMemeberInviteViewController ()
{
//    NSString *str_ImagePrefix;
//    NSString *str_UserImagePrefix;
//    NSString *str_NoImagePrefix;
    
    //    UIColor *deSelectColor;
    NSMutableDictionary *dicM_Check;
    NSMutableDictionary *dicM_MainCheck;
    
    CGFloat fKeyboardHeight;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_TitleCount;
@property (nonatomic, weak) IBOutlet UIButton *btn_Next;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AccBottom;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (strong, nonatomic) SBDUserListQuery *userListQuery;
//@property (strong, nonatomic) NSMutableArray<SBDUser *> *users;

@end

@implementation ChatFeedMemeberInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btn_Next.layer.cornerRadius = 5.f;
    self.btn_Next.layer.borderWidth = 1.f;
    self.btn_Next.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_Next.backgroundColor = [UIColor whiteColor];
    [self.btn_Next setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    if( self.isAddMode )
    {
        self.lb_Title.text = @"추가하기";
        [self.btn_Next setTitle:@"추가하기" forState:UIControlStateNormal];
    }
    else if( self.isViewMode )
    {
        self.lb_Title.text = @"참여자";
        self.btn_Next.hidden = YES;
    }
    
    dicM_Check = [NSMutableDictionary dictionary];
    dicM_MainCheck = [NSMutableDictionary dictionary];
    
    

//    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tbv_List];
//    self.refreshControl.tintColor = kMainYellowColor;
//    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
//    [self.tbv_List addSubview:self.refreshControl];
    
    //    //온 시
    //    self.btn_Shared.backgroundColor = kMainYellowColor;
    //    [self.btn_Shared setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self updateList];
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
    if( self.isAddMode )
    {
//        self.userListQuery = [SBDMain createAllUserListQuery];
//        self.userListQuery.limit = 100; //맥스가 100
//        [self.userListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
//
//            self.arM_List = [NSMutableArray arrayWithArray:users];
//
//            //이미 참여중인 사람 걸러내기
//            NSArray *ar_Members = [NSMutableArray arrayWithArray:self.channel.members];
//            for( NSInteger i = 0; i < ar_Members.count; i++ )
//            {
//                SBDUser *inUser = ar_Members[i];
//                for( NSInteger j = 0; j < self.arM_List.count; j++ )
//                {
//                    SBDUser *user = self.arM_List[j];
//                    if( [inUser.userId isEqualToString:user.userId] )
//                    {
//                        [self.arM_List removeObject:user];
//                        break;
//                    }
//                }
//            }
//            
//            self.lb_TitleCount.text = [NSString stringWithFormat:@"%ld", self.arM_List.count];
//            [self.tbv_List reloadData];
//        }];
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"channelId"]], @"channelId",
                                            [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                            @"nonInvite", @"listMode",
                                            nil];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/qna/chat/room/invite/user/list"
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
//                                                    str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
//                                                    str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
//                                                    str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                                    
                                                    self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
//                                                    self.lb_TitleCount.text = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"userListCount"]];
                                                    
                                                    [self.tbv_List reloadData];
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                        }];
    }
    else if( self.isViewMode )
    {
//        self.arM_List = [NSMutableArray arrayWithArray:self.channel.members];
//        self.lb_TitleCount.text = [NSString stringWithFormat:@"%ld", self.arM_List.count];
//        [self.tbv_List reloadData];
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"channelId"]], @"channelId",
                                            [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                            @"invite", @"listMode",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/qna/chat/room/invite/user/list"
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
//                                                    str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
//                                                    str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
//                                                    str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                                    
                                                    self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                    self.lb_TitleCount.text = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"userListCount"]];
                                                    [self.tbv_List reloadData];
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                        }];
    }
    else
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            //                                        @"", @"channelId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/make/chat/room/invite/user/list"
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
//                                                    str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
//                                                    str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
//                                                    str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                                    
                                                    self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                    self.lb_TitleCount.text = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"userListCount"]];
                                                    
                                                    [self.tbv_List reloadData];
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                        }];
    }
}

- (void)nextButtonOn
{
    self.btn_Next.userInteractionEnabled = YES;
    
//    self.btn_Next.backgroundColor = kMainColor;
    [self.btn_Next setTitleColor:kMainColor forState:UIControlStateNormal];
    self.btn_Next.layer.borderColor = kMainColor.CGColor;
}

- (void)nextButtonOff
{
    self.btn_Next.userInteractionEnabled = NO;
    
//    self.btn_Next.backgroundColor = [UIColor whiteColor];
    [self.btn_Next setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.btn_Next.layer.borderColor = [UIColor lightGrayColor].CGColor;
}



#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
//    return self.arM_List.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSDictionary *dic = [self.arM_List objectAtIndex:section];
//    NSArray *ar = [dic objectForKey:@"channelUserList"];
//    return ar.count;
    return self.arM_List.count;

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvitationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitationCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     memberLevel = 9;
     userId = 108;
     userName = "\Ud1a0\Ud305\Uc120\Uc0dd\Ub2d81";
     userThumbnail = "000/000/164aa850dc2e3c45bff40379582d642e_620.jpg";
     userType = manager;
     */
    
    cell.iv_User.tag = indexPath.row;
    
    NSDictionary *dic = [self.arM_List objectAtIndex:indexPath.row];
    
    cell.iv_User.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];
    
    if( self.isAddMode )
    {
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:self.str_UserImagePrefix withFooter:[dic objectForKey_YM:@"imgUrl"]]];
    }
    else if( self.isViewMode )
    {
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:self.str_UserImagePrefix withFooter:[dic objectForKey_YM:@"imgUrl"]]];
        cell.btn_Check.hidden = YES;
    }
    else
    {
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:self.str_UserImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]]];
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
    
    if( self.isViewMode )
    {
        return;
    }
    
    NSDictionary *dic = [self.arM_List objectAtIndex:indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( self.isViewMode )
    {
        return 0;
    }
    
    return 60.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if( self.isViewMode )
    {
        return nil;
    }
    
    SharedHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SharedHeaderCell"];
    cell.tag = section;
    
//    NSDictionary *dic = [self.arM_List objectAtIndex:section];
    cell.lb_Title.text = [NSString stringWithFormat:@"%@ %@", @"진명학원", self.lb_TitleCount.text];
    
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
    
    NSString *str_HeaderKey = [dicM_MainCheck objectForKey:@"0"];
    if( str_HeaderKey )
    {
        //이미 선택된 상태면 모두 디셀렉트
        for( NSInteger i = 0; i < self.arM_List.count; i++ )
        {
            NSDictionary *dic = self.arM_List[i];
            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
            
            [dicM_Check removeObjectForKey:str_UserId];
        }
        
        [dicM_MainCheck removeObjectForKey:[NSString stringWithFormat:@"%ld", headerCell.tag]];
    }
    else
    {
        //체크가 안되어 있으면 모두 셀렉트
        for( NSInteger i = 0; i < self.arM_List.count; i++ )
        {
            NSDictionary *dic = self.arM_List[i];
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
    BOOL isAllSelected = YES;
    NSArray *ar = self.arM_List;
    for( NSInteger i = 0; i < ar.count; i++ )
    {
        NSDictionary *dic = ar[i];
        NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];

        if( [str_UserId isEqualToString:[dicM_Check objectForKey:str_UserId]] == NO )
        {
            isAllSelected = NO;
            break;
        }
    }
    
    if( isAllSelected )
    {
        [dicM_MainCheck setObject:@"0" forKey:@"0"];
    }
    else
    {
        [dicM_MainCheck removeObjectForKey:@"0"];
    }
    
    if( dicM_Check.count > 0 )
    {
        [self nextButtonOn];
    }
    else
    {
        [self nextButtonOff];
    }
    
    [self.tbv_List reloadData];
}

- (void)imageTap:(UIGestureRecognizer *)gesture
{
    UIView *view = (UIView *)gesture.view;
    NSDictionary *dic = self.arM_List[view.tag];
    NSString *str_UserId = [dic objectForKey:@"userId"];
    
    MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isAnotherUser = YES;
    vc.isShowNavi = YES;
    vc.str_UserIdx = str_UserId;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)goSendInvite:(id)sender
{
    if( dicM_Check.count <= 0 )
    {
        self.btn_Next.userInteractionEnabled = YES;
        return;
    }
    
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
    
    if( self.isAddMode )
    {
        //추가하기일때
        [self addMember:strM];
    }
    else
    {
        if( dicM_Check.count == 1 )
        {
            //1:1채팅
            self.btn_Next.userInteractionEnabled = NO;
            [self makeOneOnOneChat:strM];
        }
        else
        {
            //그룹채팅
            [self showGroupMake:strM];
        }
    }
}

- (void)addMember:(NSString *)aInviteUser
{
    self.btn_Next.userInteractionEnabled = NO;
    
//    MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeYM;
//    hud.labelText = @"초대중...";
//    [hud show:YES];
    
    [SBDGroupChannel getChannelWithUrl:self.channel.channelUrl
                     completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                         
                         [channel inviteUserIds:[aInviteUser componentsSeparatedByString:@","] completionHandler:^(SBDError * _Nullable error) {

//                             [MBProgressHUD hideHUDForView:self.view animated:YES];
//                             
//                             if( error != nil )
//                             {
//                                 UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//                                 [window makeToast:@"오류" withPosition:kPositionCenter];
//                                 self.btn_Next.userInteractionEnabled = YES;
//                             }
//                             
//                             UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//                             [window makeToast:@"초대 했습니다" withPosition:kPositionCenter];
//
//                             [self.navigationController popViewControllerAnimated:YES];
//                             
//                             self.btn_Next.userInteractionEnabled = YES;
                         }];
                     }];

    
    
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"rId"]], @"rId",
                                        aInviteUser, @"inviteUserIdStr",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/chat/room/add/invite/user"
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
                                                if( dicM_Check.count > 0 )
                                                {
                                                    NSMutableArray *arM_Users = [NSMutableArray array];

                                                    for( NSInteger i = 0; i < self.arM_List.count; i++ )
                                                    {
                                                        NSDictionary *dic = self.arM_List[i];
                                                        NSInteger nUserId = [[dic objectForKey:@"userId"] integerValue];
                                                        NSArray *ar_AllKeys = dicM_Check.allKeys;
                                                        for( NSInteger j = 0; j < ar_AllKeys.count; j++ )
                                                        {
                                                            NSString *str_Val = [dicM_Check objectForKey:ar_AllKeys[j]];
                                                            if( [str_Val integerValue] == nUserId )
                                                            {
                                                                [arM_Users addObject:@{@"userId":[dic objectForKey:@"userId"], @"userName":[dic objectForKey:@"userName"]}];
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    
                                                    
                                                    NSArray *ar_AllKeys = dicM_Check.allKeys;
                                                    NSString *str_SelectedUserId = [dicM_Check objectForKey:[ar_AllKeys firstObject]];
                                                    for( NSInteger i = 0; i < self.arM_List.count; i++ )
                                                    {
                                                        NSDictionary *dic = self.arM_List[i];
//                                                        [arM_Users addObject:@{@"userId":[dic objectForKey:@"userId"], @"userName":[dic objectForKey:@"userName"]}];
                                                        
                                                        NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
                                                        if( [str_UserId isEqualToString:str_SelectedUserId] )
                                                        {
                                                            if( self.completionBlock )
                                                            {
                                                                NSNumber *num = [NSNumber numberWithInteger:dicM_Check.count];
                                                                NSString *str_MainUserName = [dic objectForKey_YM:@"userName"];
                                                                self.completionBlock(@{@"userName":str_MainUserName, @"count":num, @"users":arM_Users});
                                                            }

                                                            break;
                                                        }
                                                    }
                                                }

                                                [self.navigationController popViewControllerAnimated:YES];
                                                
//                                                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//                                                [window makeToast:@"초대 했습니다" withPosition:kPositionCenter];
//                                                [self.navigationController popViewControllerAnimated:YES];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        self.btn_Next.userInteractionEnabled = YES;
                                    }];
}

- (void)makeOneOnOneChat:(NSString *)aInviteUser
{
    [self startSendBird];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        @"", @"roomName",
                                        aInviteUser, @"inviteUserIdStr",
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
                                                NSDictionary *dic = [resulte objectForKey:@"qnaRoomInfo"];
                                                [self makeSendbird:dic withUserId:aInviteUser];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        self.btn_Next.userInteractionEnabled = YES;
                                    }];
}

- (void)showGroupMake:(NSString *)aInviteUser
{
    NSMutableArray *arM_UserList = [NSMutableArray array];
    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
    [arM_UserList addObject:dicM_MyInfo];
    
    //유저 이름 가져오기
    NSArray *ar_UserIds = [aInviteUser componentsSeparatedByString:@","];
    for( NSInteger i = 0; i < ar_UserIds.count; i++ )
    {
        NSString *str_UserId = [ar_UserIds objectAtIndex:i];
        for( NSInteger j = 0; j < self.arM_List.count; j++ )
        {
            NSDictionary *dic_Tmp = [self.arM_List objectAtIndex:j];
            if( [str_UserId integerValue] == [[dic_Tmp objectForKey:@"userId"] integerValue] )
            {
                NSString *str_UserName = [dic_Tmp objectForKey_YM:@"userName"];
                NSString *str_UserThumb = [NSString stringWithFormat:@"%@%@", self.str_UserImagePrefix, [dic_Tmp objectForKey_YM:@"userThumbnail"]];
                
                NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                [dicM_MyInfo setObject:str_UserId forKey:@"userId"];
                [dicM_MyInfo setObject:str_UserName forKey:@"userName"];
                [dicM_MyInfo setObject:str_UserThumb forKey:@"imgUrl"];
                [arM_UserList addObject:dicM_MyInfo];
                
                break;
            }
        }
    }

    GroupMakeViewController *vc = [[GroupMakeViewController alloc] initWithNibName:@"GroupMakeViewController" bundle:nil];
    vc.str_InviteUsers = aInviteUser;
    vc.ar_UserInfos = arM_UserList;
    vc.str_ChannelId = self.str_ChannelId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)makeSendbird:(NSDictionary *)dic withUserId:(NSString *)aUserId
{
    NSString *str_SBDChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];

    __block NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
    //    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
    NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", @"1:1", str_RId];
    
    //isDistinct : YES 기존 채널 활용
    //isDistinct : NO 새로운 채널 생성
    
    NSMutableArray *arM_UserList = [NSMutableArray array];
    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
    [arM_UserList addObject:dicM_MyInfo];
    
    //유저 이름 가져오기
    NSString *str_UserName = @"";
    NSString *str_UserThumb = @"";
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        NSDictionary *dic_Tmp = [self.arM_List objectAtIndex:i];
        if( [aUserId integerValue] == [[dic_Tmp objectForKey:@"userId"] integerValue] )
        {
            str_UserName = [dic_Tmp objectForKey_YM:@"userName"];
            str_UserThumb = [NSString stringWithFormat:@"%@%@", self.str_UserImagePrefix, [dic_Tmp objectForKey_YM:@"userThumbnail"]];
            
            NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
            [dicM_MyInfo setObject:aUserId forKey:@"userId"];
            [dicM_MyInfo setObject:str_UserName forKey:@"userName"];
            [dicM_MyInfo setObject:str_UserThumb forKey:@"imgUrl"];
            [arM_UserList addObject:dicM_MyInfo];
            
            break;
        }
    }
    
    //qnaRoomInfos로 감싸서 보낼것
    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
//    [dicM setObject:self.str_ChannelId forKey:@"channelIds"];
    [dicM setObject:arM_UserList forKey:@"userThumbnail"];
    
    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
    __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    if( str_SBDChannelUrl && str_SBDChannelUrl.length > 0 )
    {
        [SBDGroupChannel getChannelWithUrl:str_SBDChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {

            BOOL isHave = NO;
            NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
            id tmp = [dic objectForKey_YM:@"channelIds"];
            NSMutableArray *arM_ChannelIds;
            if( [tmp isKindOfClass:[NSArray class]] == NO )
            {
                arM_ChannelIds = [NSMutableArray array];
            }
            else
            {
                arM_ChannelIds = [NSMutableArray arrayWithArray:[dic objectForKey:@"channelIds"]];
            }
            
            for( NSInteger i = 0; i < arM_ChannelIds.count; i++ )
            {
                NSString *str_CurrentChannelId = arM_ChannelIds[i];
                if( [str_CurrentChannelId isEqualToString:self.str_ChannelId] )
                {
                    isHave = YES;
                    break;
                }
            }
            
            if( isHave == NO && self.str_ChannelId && self.str_ChannelId.length > 0 )
            {
                [arM_ChannelIds addObject:self.str_ChannelId];
            }

            if( arM_ChannelIds == nil )
            {
                [dicM setObject:[NSArray array] forKey:@"channelIds"];
            }
            else
            {
                [dicM setObject:arM_ChannelIds forKey:@"channelIds"];
            }
            
            
            NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
            str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    
            [channel updateChannelWithName:channel.name isDistinct:NO coverUrl:@"" data:str_Dic customType:nil completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {

                //기존에 만든방이면
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                vc.str_RId = str_RId;
                vc.dic_Info = dic;
                vc.str_RoomName = str_ChannelName;
                vc.str_RoomTitle = str_UserName;
                vc.str_RoomThumb = str_UserThumb;
                vc.ar_UserIds = @[aUserId];
                vc.channel = channel;
                vc.str_ChannelIdTmp = self.str_ChannelId;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }];
    }
    else
    {
        //1:1방은 기존방 유지
        //userThumbnail : [{userId:{userId}, userName:{userName}, imgUrl:{이미지경로}]
        //방 이름은 그룹채팅일때만 쓰임
        //1:1은 유저 섬네일에서 가져와서 씀
        
        NSMutableArray *arM_ChannelId = [NSMutableArray array];
        if( self.str_ChannelId && self.str_ChannelId.length > 0 )
        {
            [arM_ChannelId addObject:self.str_ChannelId];
        }
        
        [dicM setObject:arM_ChannelId forKey:@"channelIds"];
        
        NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
        __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        [SBDGroupChannel createChannelWithName:@"" isDistinct:NO userIds:@[aUserId] coverUrl:@"" data:str_Dic customType:nil
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
                                 //sendbird_group_channel_33963702_f367360d2ae3758e8ea7bc29f321bdc57db463ce
                                 SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                                 NSLog(@"%@", baseChannel.channelUrl);
                                 [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                                 
                                 //https://sites.google.com/site/thotingapi/api/api-jeong-ui/api-list/chaetingbangsendbirdchannelurlbyeongyeong
                                 //여기에 채널url 등록
                                 
                                 UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                 ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                 vc.str_RId = str_RId;
                                 vc.dic_Info = dic;
                                 vc.str_RoomName = str_ChannelName;
                                 vc.str_RoomTitle = str_UserName;
                                 vc.str_RoomThumb = str_UserThumb;
                                 vc.ar_UserIds = @[aUserId];
                                 vc.channel = channel;
                                 vc.str_ChannelIdTmp = self.str_ChannelId;
                                 [self.navigationController pushViewController:vc animated:YES];
                             }];
    }
}


#pragma mark - SendBird
- (void)startSendBird
{
//    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
//
//    } errorBlock:^(NSInteger code) {
//
//    } channelLeftBlock:^(SendBirdChannel *channel) {
//
//    } messageReceivedBlock:^(SendBirdMessage *message) {
//
//        NSLog(@"Recive");
//        NSLog(@"message.message: %@, message.data: %@", message.message, message.data);
//        //        ALERT(nil, message.message, nil, @"확인", nil);
//
//        NSData* data = [message.data dataUsingEncoding:NSUTF8StringEncoding];
//
//        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//        NSMutableDictionary *dicM_Result = [NSMutableDictionary dictionaryWithDictionary:[jsonParser objectWithString:dataString]];
//
//        NSLog(@"dicM_Result : %@", dicM_Result);
//
//        if( [message.message isEqualToString:@"create-chat"] )
//        {
//            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//            [window makeToast:@"채팅방이 개설되었습니다" withPosition:kPositionCenter];
//            
//        }
//    } systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
//        
//    } broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
//        
//    } fileReceivedBlock:^(SendBirdFileLink *fileLink) {
//        
//    } messagingStartedBlock:^(SendBirdMessagingChannel *channel) {
//        
//    } messagingUpdatedBlock:^(SendBirdMessagingChannel *channel) {
//        
//    } messagingEndedBlock:^(SendBirdMessagingChannel *channel) {
//        
//    } allMessagingEndedBlock:^{
//        
//    } messagingHiddenBlock:^(SendBirdMessagingChannel *channel) {
//        
//    } allMessagingHiddenBlock:^{
//        
//    } readReceivedBlock:^(SendBirdReadStatus *status) {
//        
//    } typeStartReceivedBlock:^(SendBirdTypeStatus *status) {
//        
//    } typeEndReceivedBlock:^(SendBirdTypeStatus *status) {
//        
//    } allDataReceivedBlock:^(NSUInteger sendBirdDataType, int count) {
//        
//    } messageDeliveryBlock:^(BOOL send, NSString *message, NSString *data, NSString *tempId) {
//        
//    } mutedMessagesReceivedBlock:^(SendBirdMessage *message) {
//        
//    } mutedFileReceivedBlock:^(SendBirdFileLink *message) {
//        
//    }];
}

@end
