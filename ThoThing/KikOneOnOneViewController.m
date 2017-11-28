//
//  KikOneOnOneViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikOneOnOneViewController.h"
#import "KikAddressViewController.h"
#import "ChatIngUserCell.h"
#import "ChatFeedViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "KikGroupsHeaderCell.h"
#import "KikBotMainViewController.h"
#import "KikAddMemberAccCell.h"

@interface KikOneOnOneViewController ()
{
    BOOL isSyncing;
    NSString *str_UserImagePrefix;
    NSMutableString *strM_UserIds;
    NSMutableString *strM_RoomName;
}
@property (nonatomic, strong) NSMutableArray *arM_ListBackup;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_SelectUserList;
@property (nonatomic, strong) NSMutableArray *arM_NewUser;
@property (nonatomic, strong) NSMutableArray *arM_Address;
@property (nonatomic, weak) IBOutlet UITextField *tf_SearchMember;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AddressUnderLineLeft;
@property (nonatomic, weak) IBOutlet UIButton *btn_Sync;
@property (nonatomic, weak) IBOutlet UIButton *btn_Start;
@property (nonatomic, weak) IBOutlet UICollectionView *cv_AddMember;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AddMemberHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BotTapHeight;
@property (nonatomic, weak) IBOutlet UILabel *lb_BotCount;
@end

@implementation KikOneOnOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.arM_SelectUserList = [NSMutableArray array];
    self.lc_AddMemberHeight.constant = 0.f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateList];
    [self updateBotList];
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
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exist/chat/room/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                str_UserImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
                                                weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                weakSelf.arM_ListBackup = weakSelf.arM_List;
                                                [weakSelf.tbv_List reloadData];
                                            }
                                        }
                                    }];
}

- (void)updateBotList
{
    __weak __typeof(&*self)weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/chatbot/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSArray *ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"chatBotList"]];
                                                if( ar.count > 0 )
                                                {
                                                    weakSelf.lc_BotTapHeight.constant = 44.f;
                                                    weakSelf.lc_AddressUnderLineLeft.constant = 15.f;
                                                }
                                                else
                                                {
                                                    weakSelf.lc_BotTapHeight.constant = 0.f;
                                                    weakSelf.lc_AddressUnderLineLeft.constant = 0.f;
                                                }
                                                
                                                weakSelf.lb_BotCount.text = [NSString stringWithFormat:@"%ld", ar.count];
                                            }
                                        }
                                    }];
}

- (void)searchMemberName
{
    if( self.tf_SearchMember.text.length > 0 )
    {
        NSArray *ar = [self.arM_ListBackup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.userName contains[c] %@", self.tf_SearchMember.text]];
        self.arM_List = [NSMutableArray arrayWithArray:ar];
    }
    else{
        self.arM_List = self.arM_ListBackup;
    }
    
    [self.tbv_List reloadData];
}

- (void)moveChat:(NSString *)aInviteUser
{
    __weak __typeof(&*self)weakSelf = self;

    self.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        @"", @"roomName",
                                        aInviteUser, @"inviteUserIdStr",
                                        @"user", @"channelType",
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
                                        
                                        weakSelf.view.userInteractionEnabled = YES;
                                    }];
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
            str_UserThumb = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic_Tmp objectForKey_YM:@"userThumbnail"]];
            
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
            
            NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
            [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"rId"]] forKey:@"rId"];
            [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"questionId"]] forKey:@"questionId"];
            [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"channelId"]] forKey:@"channelId"];
            [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"hashTagStr"]] forKey:@"hashTagStr"];
            [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomDesc"]] forKey:@"roomDesc"];
            [dicM_Data setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"ownerId"];
            [dicM_Data setObject:@"" forKey:@"botUserId"];
            [dicM_Data setObject:@"" forKey:@"botOwnerId"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data options:0 error:&err];
            __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSString *str_UserName = @"";
            NSString *str_UserThumb = @"";
            NSArray *ar = [NSArray arrayWithArray:[dicM objectForKey:@"userThumbnail"]];
            for( NSInteger i = 0; i < ar.count; i++ )
            {
                NSDictionary *dic = ar[i];
                NSInteger nTargetUserId = [[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]] integerValue];
                NSInteger nMyUserId = [[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] integerValue];
                if( nTargetUserId != nMyUserId )
                {
                    str_UserName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userName"]];
                    str_UserThumb = [NSString stringWithFormat:@"%@", [dic objectForKey:@"imgUrl"]];
                    break;
                }
            }
            
            [channel updateChannelWithName:str_UserName isDistinct:NO coverUrl:str_UserThumb data:str_Dic customType:@"user" completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                
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
                vc.str_ChannelIdTmp = nil;
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
        
//        NSMutableArray *arM_ChannelId = [NSMutableArray array];
//        if( self.str_ChannelId && self.str_ChannelId.length > 0 )
//        {
//            [arM_ChannelId addObject:self.str_ChannelId];
//        }
        
        __weak __typeof(&*self)weakSelf = self;

        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"rId"]] forKey:@"rId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"questionId"]] forKey:@"questionId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"channelId"]] forKey:@"channelId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"hashTagStr"]] forKey:@"hashTagStr"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomDesc"]] forKey:@"roomDesc"];
        //            [dicM_Data setObject:user.userId forKey:@"ownerId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"ownerId"];
        [dicM_Data setObject:@"" forKey:@"botUserId"];
        [dicM_Data setObject:@"" forKey:@"botOwnerId"];
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data options:0 error:&err];
        __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *str_UserName = @"";
        NSString *str_UserThumb = @"";
        NSArray *ar = [NSArray arrayWithArray:[dicM objectForKey:@"userThumbnail"]];
        for( NSInteger i = 0; i < ar.count; i++ )
        {
            NSDictionary *dic = ar[i];
            NSInteger nTargetUserId = [[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]] integerValue];
            NSInteger nMyUserId = [[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] integerValue];
            if( nTargetUserId != nMyUserId )
            {
                str_UserName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userName"]];
                str_UserThumb = [NSString stringWithFormat:@"%@", [dic objectForKey:@"imgUrl"]];
                break;
            }
        }
        
        [SBDGroupChannel createChannelWithName:str_UserName isDistinct:NO userIds:@[aUserId] coverUrl:str_UserThumb data:str_Dic customType:@"user"
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
                                 vc.str_ChannelIdTmp = nil;
                                 [weakSelf.navigationController pushViewController:vc animated:YES];
                             }];
    }
}



- (void)updateAddMemberList
{
    if( self.arM_SelectUserList == nil || self.arM_SelectUserList.count <= 0 )
    {
        self.lc_AddMemberHeight.constant = 0.f;
        self.btn_Start.selected = NO;
    }
    else
    {
        self.lc_AddMemberHeight.constant = 36.f;
        self.btn_Start.selected = YES;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        [weakSelf.view layoutIfNeeded];
    }];
    
    [self.tbv_List reloadData];
    [self.cv_AddMember reloadData];
}



#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( textField == self.tf_SearchMember )
    {
        [self performSelector:@selector(searchMemberName) withObject:nil afterDelay:0.1f];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    if( textField == self.tf_SearchMember ){
        self.arM_List = self.arM_ListBackup;
        [self.tbv_List reloadData];
    }
    
    return YES;
}

#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( self.arM_NewUser && self.arM_NewUser.count > 0 )
    {
        return 2;
    }
    
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( self.arM_NewUser && self.arM_NewUser.count > 0 )
    {
        if( section == 0 )
        {
            return self.arM_NewUser.count;
        }
        else
        {
            return self.arM_List.count;
        }
        
    }
    
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     rId = 180;
     userAffiliation = "\Uacbd\Ubb38\Uace0\Ub4f1\Ud559\Uad50";
     userId = 99;
     userMajor = 1;
     userName = "\Ud669\Ud76c\Ucc2c";
     userThumbnail = "000/000/noImage12.png";
     userType = user;
     */
     
    if( indexPath.section == 0 && self.arM_NewUser && self.arM_NewUser.count > 0 )
    {
        NSDictionary *dic = self.arM_NewUser[indexPath.row];
        ChatIngUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIngUserCell"];
        cell.btn_Check.selected = NO;
        
        NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"userThumbnail"]];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];
        
        cell.lb_Name.text = [dic objectForKey_YM:@"userName"];
        cell.lb_NinkName.text = [dic objectForKey_YM:@"email"];
        
        NSArray *ar = [self.arM_SelectUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", [dic objectForKey_YM:@"userId"]]];
        if( ar.count > 0 )
        {
            cell.btn_Check.selected = YES;
        }

        return cell;
    }
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    ChatIngUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIngUserCell"];
    
    cell.btn_Check.selected = NO;
    
    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"userThumbnail"]];
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];
    
    cell.lb_Name.text = [dic objectForKey_YM:@"userName"];
    cell.lb_NinkName.text = [dic objectForKey_YM:@"userEmail"];
    
    NSArray *ar = [self.arM_SelectUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", [dic objectForKey_YM:@"userId"]]];
    if( ar.count > 0 )
    {
        cell.btn_Check.selected = YES;
    }

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSDictionary *dic = nil;
//    if( indexPath.section == 0 && self.arM_NewUser && self.arM_NewUser.count > 0 )
//    {
//        dic = self.arM_NewUser[indexPath.row];
//    }
//    else
//    {
//        dic = self.arM_List[indexPath.row];
//    }
//
//    if( dic == nil )    return;
//
//    [self moveChat:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]]];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    NSArray *ar = [self.arM_SelectUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", [dic objectForKey_YM:@"userId"]]];
    if( ar.count > 0 )
    {
        //이미 선택된건 삭제
        [self.arM_SelectUserList removeObject:dic];
    }
    else
    {
        //선택되지 않았던것은 추가
        [self.arM_SelectUserList addObject:dic];
    }
    
    [self updateAddMemberList];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"KikGroupsHeaderCell";

    if( section == 0 && self.arM_NewUser && self.arM_NewUser.count > 0 )
    {
        KikGroupsHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.lb_Title.text = @"신규 유저";
        return cell;
    }
    
    KikGroupsHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.lb_Title.text = @"채팅 중인 상대";
    return cell;
}



#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arM_SelectUserList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"KikAddMemberAccCell";
    
    KikAddMemberAccCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *dic = self.arM_SelectUserList[indexPath.row];
    
    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"userThumbnail"]];
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_SelectUserList[indexPath.row];
    [self.arM_SelectUserList removeObject:dic];
    [self.cv_AddMember reloadData];
    [self updateAddMemberList];
}


#pragma mark - IBAction
- (IBAction)goAddress:(id)sender
{
    KikAddressViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikAddressViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goAddressSync:(id)sender
{
    //동기화 버튼을 누르면
    //1.유저 전화번호가 있는지 확인하고
    //2.주소록을 가져오고
    //3.전화번호가 있으면 주소록을 업로드하고
    //4.서버에서 리턴받은 인스톨 유저와 기존에 저장하고 있던 인스톨 유저를 비교하여 신규 유저 추출
    //5.서버에서 리턴 받은 인스톨 유저를 앱에 저장
    
    __weak __typeof(&*self)weakSelf = self;

    __block UITextField *tf_Tmp = nil;
    NSString *str_UserPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
    if( str_UserPhoneNumber == nil || str_UserPhoneNumber.length <= 0 )
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"전화번호"
                                      message:@"전화번호를 입력해 주세요"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       //Do Some action here
                                                       
                                                       if( tf_Tmp.text && tf_Tmp.text.length > 0 )
                                                       {
                                                           [[NSUserDefaults standardUserDefaults] setObject:tf_Tmp.text forKey:@"phoneNumber"];
                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                           [weakSelf goAddressSync:nil];
                                                       }
                                                   }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"01012341234";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            tf_Tmp = textField;
        }];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        __block BOOL accessGranted = NO;
        if (ABAddressBookRequestAccessWithCompletion != NULL)
        { // We are on iOS 6
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(semaphore);
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            //dispatch_release(semaphore);
        }
        else
        { // We are on iOS 5 or Older
            accessGranted = YES;
            [self getContactsWithAddressBook:addressBook];
        }
        
        if (accessGranted)
        {
            [self getContactsWithAddressBook:addressBook];
        }
        
        [self updateAddressList];
    }
}

- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook
{
    self.arM_Address = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for (int i=0;i < nPeople;i++)
    {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        NSMutableString *strM_Name = [NSMutableString string];
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        if( firstName )
        {
            [strM_Name appendString:[NSString stringWithFormat:@"%@", firstName]];
        }
        
        if( lastName )
        {
            if( strM_Name.length > 0 )
            {
                [strM_Name appendString:@" "];
            }
            
            [strM_Name appendString:[NSString stringWithFormat:@"%@", lastName]];
        }
        
        if( strM_Name == nil || strM_Name.length <= 0 || [strM_Name isEqualToString:@" "] )
        {
            continue;
        }
        
        [dOfPerson setObject:[NSString stringWithFormat:@"%@", strM_Name] forKey:@"name"];
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0)
        {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
        }
        
        if( ABMultiValueGetCount(phones) <= 0 )
        {
            continue;
        }
        
        
        //For Phone number
        NSString* mobileLabel;
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++)
        {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
                break ;
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMainLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABHomeLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABWorkLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABOtherLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
        }
        
        [self.arM_Address addObject:dOfPerson];
    }
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    self.arM_Address = [NSMutableArray arrayWithArray:[self.arM_Address sortedArrayUsingDescriptors:@[descriptor]]];
}

- (void)updateAddressList
{
    __weak __typeof(&*self)weakSelf = self;
    
    isSyncing = YES;
    [self startSyncAnimation];
    
    
    //이름|국가코드|전화번호|이메일
    NSMutableArray *arM = [NSMutableArray array];
    
    //        NSError * err;
    //        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
    //        NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableString *strM = [NSMutableString string];
    for( NSInteger i = 0; i < self.arM_Address.count; i++ )
    {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        
        NSDictionary *dic = self.arM_Address[i];
        
        NSString *str_Name = [dic objectForKey_YM:@"name"];
        NSString *str_PhoneNumber = [dic objectForKey_YM:@"phone"];
        NSString *str_Email = [dic objectForKey_YM:@"email"];
        
        if( str_Name.length <= 0 || str_PhoneNumber.length <= 0 )
        {
            continue;
        }
        
        [dicM setObject:str_Name forKey:@"name"];
        //            [strM appendString:str_Name];
        //            [strM appendString:@"|"];
        
        if( [str_PhoneNumber hasPrefix:@"82"] )
        {
            //                [strM appendString:@"82"];
            [dicM setObject:@"82" forKey:@"code"];
        }
        else
        {
            [dicM setObject:@"" forKey:@"code"];
        }
        //            [strM appendString:@"|"];
        
        str_PhoneNumber = [str_PhoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
        str_PhoneNumber = [str_PhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        str_PhoneNumber = [str_PhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        if( [str_PhoneNumber hasPrefix:@"0"] == NO )
        {
            NSString *str_Tmp = [NSString stringWithFormat:@"0%@", str_PhoneNumber];
            str_PhoneNumber = str_Tmp;
        }
        
        //            [strM appendString:str_PhoneNumber];
        //            [strM appendString:@"|"];
        [dicM setObject:str_PhoneNumber forKey:@"phone"];
        
        
        //            [strM appendString:str_Email];
        [dicM setObject:str_Email forKey:@"email"];
        
        //            [strM appendString:@","];
        [arM addObject:dicM];
    }
    
    if( [strM hasSuffix:@","] )
    {
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    }
    
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"], @"myPhoneNumber",
                                        //                                            @"kym|||, test||01091810664|plzallyme@gmail.com", @"contactList",
                                        arM, @"contactList",
                                        nil];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/uplaod/contact/list"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                /*
                                                 email = "ss25@t.com";
                                                 phoneNumber = "";
                                                 userId = 154;
                                                 userName = "\Uae40\Uc601\Ubbfc25";
                                                 */
                                                
                                                NSArray *ar_Old = [[NSUserDefaults standardUserDefaults] objectForKey:@"installUserList"];
                                                NSArray *ar_New = [NSArray arrayWithArray:[resulte objectForKey:@"installUserList"]];
                                                NSMutableArray *arM_New = [NSMutableArray arrayWithArray:ar_New];
                                                
                                                for( NSInteger i = 0; i < ar_Old.count; i++ )
                                                {
                                                    NSDictionary *dic = ar_Old[i];
                                                    [arM_New removeObject:dic];
                                                }

                                                NSLog(@"%@", ar_Old);
                                                NSLog(@"%@", ar_New);
                                                NSLog(@"%@", arM_New);
                                                
                                                for( NSInteger i = 0; i < arM_New.count; i++ )
                                                {
                                                    NSDictionary *dic = arM_New[i];
                                                    
                                                    NSString *str_MyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                                                    NSString *str_Name = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userName"]];
                                                    
                                                    NSString *str_MyUserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                    NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
                                                    
                                                    if( [str_MyName isEqualToString:str_Name] || [str_MyUserId isEqualToString:str_UserId] )
                                                    {
                                                        [arM_New removeObject:dic];
                                                        break;
                                                    }
                                                }
                                                
                                                weakSelf.arM_NewUser = [NSMutableArray arrayWithArray:arM_New];
                                                [weakSelf.tbv_List reloadData];
                                            }
                                        }
                                        
                                        isSyncing = NO;

                                    }];
}

- (void)startSyncAnimation
{
    __weak __typeof(&*self)weakSelf = self;

    [UIView animateWithDuration:0.3f
                     animations:^{
                         weakSelf.btn_Sync.transform = CGAffineTransformMakeRotation(degreesToRadian(-180));
                     }completion:^(BOOL finished) {
                         weakSelf.btn_Sync.transform = CGAffineTransformMakeRotation(degreesToRadian(0));
                         
                         if( isSyncing )
                         {
                             [weakSelf startSyncAnimation];
                         }
                     }];
}

- (IBAction)goBack:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.arM_NewUser forKey:@"installUserList"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [super goBack:sender];
}

- (IBAction)goStart:(id)sender
{
    if( self.btn_Start.selected )
    {
        //1:1방
        if( self.arM_SelectUserList.count == 1 )
        {
            __weak __typeof(&*self)weakSelf = self;
            
            self.view.userInteractionEnabled = NO;
            
            NSDictionary *dic = [self.arM_SelectUserList firstObject];
            NSString *aInviteUser = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                @"", @"channelId",
                                                @"", @"roomName",
                                                aInviteUser, @"inviteUserIdStr",
                                                @"user", @"channelType",
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
                                                
                                                weakSelf.view.userInteractionEnabled = YES;
                                            }];
        }
        else
        {
            //그룹방
            [self makeGroupChat:nil];
        }
    }
}

- (void)makeGroupChat:(NSString *)coverUrl
{
    __weak __typeof(&*self)weakSelf = self;
    
    self.btn_Start.userInteractionEnabled = NO;
    
    strM_UserIds = [NSMutableString string];
    for( NSInteger i = 0; i < self.arM_SelectUserList.count; i++ )
    {
        NSDictionary *dic = self.arM_SelectUserList[i];
        [strM_UserIds appendString:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]]];
        [strM_UserIds appendString:@","];
    }
    
    if( [strM_UserIds hasSuffix:@","] )
    {
        [strM_UserIds deleteCharactersInRange:NSMakeRange([strM_UserIds length]-1, 1)];
    }
    
    /////////////////////////
    NSMutableArray *arM_UserList = [NSMutableArray array];
    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
    [arM_UserList addObject:dicM_MyInfo];
    
    //유저 이름 가져오기
    NSArray *ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
    for( NSInteger i = 0; i < ar_UserIds.count; i++ )
    {
        NSString *str_UserId = [ar_UserIds objectAtIndex:i];
        for( NSInteger j = 0; j < self.arM_SelectUserList.count; j++ )
        {
            NSDictionary *dic_Tmp = [self.arM_SelectUserList objectAtIndex:j];
            if( [str_UserId integerValue] == [[dic_Tmp objectForKey:@"userId"] integerValue] )
            {
                NSString *str_UserName = [dic_Tmp objectForKey_YM:@"userName"];
                NSString *str_UserThumb = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic_Tmp objectForKey_YM:@"userThumbnail"]];
                
                NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                [dicM_MyInfo setObject:str_UserId forKey:@"userId"];
                [dicM_MyInfo setObject:str_UserName forKey:@"userName"];
                [dicM_MyInfo setObject:str_UserThumb forKey:@"imgUrl"];
                [arM_UserList addObject:dicM_MyInfo];
                
                break;
            }
        }
    }
    
    ///////////////////////////////////
    
    strM_RoomName = [NSMutableString string];
    for( NSInteger i = 0; i < arM_UserList.count; i++ )
    {
        NSDictionary *dic = arM_UserList[i];
        NSString *str_UserName = [dic objectForKey_YM:@"userName"];
        [strM_RoomName appendString:str_UserName];
        [strM_RoomName appendString:@", "];
    }
    
    if( [strM_RoomName hasSuffix:@", "] )
    {
        [strM_RoomName deleteCharactersInRange:NSMakeRange([strM_RoomName length]-1, 1)];
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        strM_RoomName, @"roomName",
                                        strM_UserIds, @"inviteUserIdStr",
                                        @"group", @"channelType",
                                        [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl], @"roomCoverImg",
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
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                [weakSelf makeSendbird:dic withCover:coverUrl];
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        weakSelf.btn_Start.userInteractionEnabled = YES;
                                    }];
    
}

- (void)makeSendbird:(NSDictionary *)dic withCover:(NSString *)coverUrl
{
    NSString *str_SBDChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];
    
    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
    
//    if( self.iv_Thumb.image )
//    {
//        //20170926 새로 추가한 부분
//        //그룹방 개설시 이미지가 있으면 이미지를 샌드버드로 전송
//        [dicM setObject:coverUrl forKey:@"roomCoverUrl"];
//    }
    
    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
    __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
//    if( str_SBDChannelUrl && str_SBDChannelUrl.length > 0 )
    if( 0 )
    {
//        [SBDGroupChannel getChannelWithUrl:str_SBDChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
//
//            BOOL isHave = NO;
//            NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//            NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
//            id tmp = [dic objectForKey_YM:@"channelIds"];
//            NSMutableArray *arM_ChannelIds;
//            if( [tmp isKindOfClass:[NSArray class]] == NO )
//            {
//                arM_ChannelIds = [NSMutableArray array];
//            }
//            else
//            {
//                arM_ChannelIds = [NSMutableArray arrayWithArray:[dic objectForKey:@"channelIds"]];
//            }
//
//            if( arM_ChannelIds == nil )
//            {
//                [dicM setObject:[NSArray array] forKey:@"channelIds"];
//            }
//            else
//            {
//                [dicM setObject:arM_ChannelIds forKey:@"channelIds"];
//            }
//
//
//            NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
//
//            NSError * err;
//            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
//            str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//
//            [channel updateChannelWithName:channel.name isDistinct:NO coverUrl:@"" data:str_Dic customType:nil completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
//
//                NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
//                //                             NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
//                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.tf_GroupName.text, str_RId];
//
//                SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
//                NSLog(@"%@", baseChannel.channelUrl);
//                [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
//
//                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
//                ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
//                vc.str_RId = str_RId;
//                vc.dic_Info = dic;
//                vc.str_RoomTitle = strM_RoomName;
//                vc.ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
//                vc.channel = channel;
//                vc.str_ChannelIdTmp = nil;
//                [self.navigationController pushViewController:vc animated:YES];
//
//            }];
//        }];
    }
    else
    {
        //그룹방은 신규 방으로 개설
        //138,213,541
        NSMutableArray *arM_ChannelId = [NSMutableArray array];
        //        if( self.str_ChannelId && self.str_ChannelId.length > 0 )
        //        {
        //            [arM_ChannelId addObject:self.str_ChannelId];
        //        }
        
        [dicM setObject:arM_ChannelId forKey:@"channelIds"];
        
        NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];

        NSString *str_CustomType = @"";
        if( coverUrl )
        {
            str_CustomType = @"channel";
            coverUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl];
        }
        else
        {
            str_CustomType = @"group";
        }
        
        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"rId"]] forKey:@"rId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"questionId"]] forKey:@"questionId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"channelId"]] forKey:@"channelId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"hashTagStr"]] forKey:@"hashTagStr"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomDesc"]] forKey:@"roomDesc"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"ownerId"];
        [dicM_Data setObject:@"" forKey:@"botUserId"];
        [dicM_Data setObject:@"" forKey:@"botOwnerId"];
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data options:0 error:&err];
        __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //이름과 섬네일이 없는 그룹방
        
        if( [strM_RoomName hasSuffix:@","] )
        {
            [strM_RoomName deleteCharactersInRange:NSMakeRange([strM_RoomName length]-1, 1)];
        }
        
        if( coverUrl == nil )
        {
            coverUrl = @"";
        }
        
        [SBDGroupChannel createChannelWithName:strM_RoomName isDistinct:NO userIds:[strM_UserIds componentsSeparatedByString:@","] coverUrl:coverUrl data:str_Dic customType:str_CustomType
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
                                 
                                 //채널질문방_{사용자가입력한질문방이름}_questionId
                                 NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
                                 //                             NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
                                 //                                 NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.tf_GroupName.text, str_RId];
                                 
                                 SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                                 NSLog(@"%@", baseChannel.channelUrl);
                                 [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                                 
                                 UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                 ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                 vc.str_RId = str_RId;
                                 vc.dic_Info = dic;
                                 vc.str_RoomTitle = strM_RoomName;
                                 vc.ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
                                 vc.channel = channel;
                                 vc.str_ChannelIdTmp = nil;
                                 [self.navigationController pushViewController:vc animated:YES];
                             }];
    }
}

- (IBAction)goShowBotList:(id)sender
{
    KikBotMainViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikBotMainViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
