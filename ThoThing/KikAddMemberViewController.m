//
//  KikAddMemberViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 13..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikAddMemberViewController.h"
#import "ChatIngUserCell.h"
#import "KikAddMemberAccCell.h"

@interface KikAddMemberViewController ()
{
    NSString *str_UserImagePrefix;
}
@property (strong, nonatomic) NSMutableArray *arM_List;
@property (strong, nonatomic) NSMutableArray *arM_ListBackUp;
@property (nonatomic, strong) NSMutableArray *arM_SelectUserList;
@property (strong, nonatomic) SBDUserListQuery *userListQuery;
@property (nonatomic, weak) IBOutlet UIButton *btn_Start;
@property (nonatomic, weak) IBOutlet UITextField *tf_SearchMember;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvBottom;
@property (nonatomic, weak) IBOutlet UICollectionView *cv_AddMember;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AddMemberHeight;

@end

@implementation KikAddMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arM_SelectUserList = [NSMutableArray array];

    [self updateList];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hide];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
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
    
    NSString *str_QuestionId = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"questionId"] integerValue]];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        str_QuestionId, @"questionId",
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
                                                str_UserImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
                                                weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                weakSelf.arM_ListBackUp = weakSelf.arM_List;
                                                [weakSelf.tbv_List reloadData];
                                            }
                                        }
                                    }];
}


- (void)searchMemberName
{
    if( self.tf_SearchMember.text.length > 0 )
    {
        NSArray *ar = [self.arM_ListBackUp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.userName contains[c] %@", self.tf_SearchMember.text]];
        self.arM_List = [NSMutableArray arrayWithArray:ar];
    }
    else
    {
        self.arM_List = self.arM_ListBackUp;
    }
    
    [self.tbv_List reloadData];
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


#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    __weak __typeof(&*self)weakSelf = self;
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
            weakSelf.lc_TbvBottom.constant = -keyboardBounds.size.height;
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            weakSelf.lc_TbvBottom.constant = 0.f;
        }
    }completion:^(BOOL finished) {
        
    }];
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
    
    if( textField == self.tf_SearchMember )
    {
        self.arM_List = self.arM_ListBackUp;
        [self.tbv_List reloadData];
    }
    
    return YES;
}

#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    /*
     cc = 1;
     channelId = 4;
     imgUrl = "000/000/noImage14.png";
     isMemberAllow = A;
     isOwner = N;
     lastInviteDate = "";
     memberLevel = 20;
     url = U122160713;
     userEmail = "student5@thoting.com";
     userId = 122;
     userName = "\Uacf5\Ubd80\Uaf5d";
     userType = member;
     */
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    ChatIngUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIngUserCell"];
    
    cell.btn_Check.selected = NO;
    
    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"imgUrl"]];
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
    
    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"imgUrl"]];
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
- (IBAction)goAddMember:(id)sender
{
    if( self.arM_SelectUserList.count <= 0 )    return;
 
    __weak __typeof(&*self)weakSelf = self;

    __block NSMutableString *strM_InviteUserIds = [NSMutableString string];
    for( NSInteger i = 0; i < self.arM_SelectUserList.count; i++ )
    {
        NSDictionary *dic = self.arM_SelectUserList[i];
        NSString *str_UserId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"userId"] integerValue]];
        [strM_InviteUserIds appendString:str_UserId];
        [strM_InviteUserIds appendString:@","];
    }
    
    if( [strM_InviteUserIds hasSuffix:@","] )
    {
        [strM_InviteUserIds deleteCharactersInRange:NSMakeRange([strM_InviteUserIds length]-1, 1)];
    }

    
    NSString *str_RId = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"rId"] integerValue]];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        str_RId, @"rId",
                                        strM_InviteUserIds, @"inviteUserIdStr",
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
                                                NSDictionary *dic_InviteFirstUser = [weakSelf.arM_SelectUserList firstObject];
                                                NSString *str_MyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                                                NSString *str_UserName = [NSString stringWithFormat:@"%@", [dic_InviteFirstUser objectForKey_YM:@"userName"]];
                                                NSInteger nCnt = weakSelf.arM_SelectUserList.count;
                                                NSString *str_Msg = @"";
                                                if( nCnt == 1 )
                                                {
                                                    str_Msg = [NSString stringWithFormat:@"%@님이 %@님을 이 그룹에 추가했습니다.", str_MyName, str_UserName];
                                                }
                                                else
                                                {
                                                    str_Msg = [NSString stringWithFormat:@"%@님이 %@님 외 %ld명을 이 그룹에 추가했습니다.", str_MyName, str_UserName, nCnt - 1];
                                                }
                                                
                                                [weakSelf inviteUser:str_Msg withUsers:strM_InviteUserIds];

                                            }
                                        }
                                    }];
}

- (void)inviteUser:(NSString *)aMsg withUsers:(NSString *)aInviteUsers
{
    __weak __typeof(&*self)weakSelf = self;
    
    SBDUser *user = [SBDMain getCurrentUser];
    NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
    [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
    [dicM_Param setObject:aInviteUsers forKey:@"user_id"];
    [dicM_Param setObject:aMsg forKey:@"message"];
    [dicM_Param setObject:@"USER_JOIN" forKey:@"custom_type"];
    [dicM_Param setObject:@"true" forKey:@"is_silent"];
    
    NSMutableDictionary *dicM_MessageData = [NSMutableDictionary dictionary];
    [dicM_MessageData setObject:aMsg forKey:@"message"];
    
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
                                                 [weakSelf.channel inviteUserIds:[aInviteUsers componentsSeparatedByString:@","] completionHandler:^(SBDError * _Nullable error) {

                                                     if( [weakSelf.channel.customType isEqualToString:@"user"] || [weakSelf.channel.customType isEqualToString:@"group"] )
                                                     {
                                                         NSMutableString *strM_RoomName = [NSMutableString string];
                                                         for( NSInteger i = 0; i < weakSelf.channel.memberCount; i++ )
                                                         {
                                                             SBDUser *user = weakSelf.channel.members[i];
                                                             NSInteger nUserId = [user.userId integerValue];
                                                             NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
                                                             if( nUserId != nMyId )
                                                             {
                                                                 [strM_RoomName appendString:user.nickname];
                                                                 [strM_RoomName appendString:@","];
                                                             }
                                                         }
                                                         
                                                         if( [strM_RoomName hasSuffix:@","] )
                                                         {
                                                             [strM_RoomName deleteCharactersInRange:NSMakeRange([strM_RoomName length]-1, 1)];
                                                         }

                                                         [weakSelf.channel updateChannelWithName:strM_RoomName
                                                                                      isDistinct:weakSelf.channel.isDistinct
                                                                                        coverUrl:weakSelf.channel.coverUrl
                                                                                            data:weakSelf.channel.data
                                                                                      customType:@"group"
                                                                               completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                      
                                                                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                                                                               }];
                                                     }
                                                     else
                                                     {
                                                         [weakSelf.navigationController popViewControllerAnimated:YES];
                                                     }
                                                 }];
                                             }
                                         }];
}

@end
