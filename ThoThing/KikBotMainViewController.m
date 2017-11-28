//
//  KikBotMainViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 10. 2..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikBotMainViewController.h"
#import "KikBotMainCell.h"
#import "KikRoomInfoViewController.h"
#import "KikMakeBotsViewController.h"

@interface KikBotMainViewController ()
{
    BOOL isSearchMode;
    NSString *str_UserImagePrefix;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_BackUpList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UITextField *tf_Search;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_NaviHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CancelWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SearchBgHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvBottom;
@end

@implementation KikBotMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( isSearchMode == NO )
    {
        [self updateList];
    }
    
    
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
                                                str_UserImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
                                                weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"chatBotList"]];
                                                weakSelf.arM_BackUpList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"chatBotList"]];
                                                [weakSelf.tbv_List reloadData];
                                            }
                                        }
                                    }];
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



#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_Search )
    {
        if( self.tf_Search.text.length > 0 )
        {
            [self updateSearchWord];
        }
        else
        {
            [self startSearchMode];
        }
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateSearchWord) withObject:nil afterDelay:0.1f];
    
    return YES;
}

- (void)updateSearchWord
{
    if( self.tf_Search.text.length > 0 )
    {
        NSPredicate *p1 = [NSPredicate predicateWithFormat:@"SELF.displayName contains[c] %@", self.tf_Search.text];
        NSPredicate *p2 = [NSPredicate predicateWithFormat:@"SELF.hashTagStr contains[c] %@", self.tf_Search.text];
        NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[p1, p2]];

        NSArray *ar = [self.arM_BackUpList filteredArrayUsingPredicate:predicate];
        self.arM_List = [NSMutableArray arrayWithArray:ar];
    }
    else{
        self.arM_List = self.arM_BackUpList;
    }
    
    [self.tbv_List reloadData];
}


- (void)startSearchMode
{
    isSearchMode = YES;
    [self.arM_List removeAllObjects];
    [self.tbv_List reloadData];
    
    __weak __typeof(&*self)weakSelf = self;
    self.lc_NaviHeight.constant = 0.f;
    self.lc_CancelWidth.constant = 44.f;
    self.lc_SearchBgHeight.constant = 64.f;
    [UIView animateWithDuration:0.2f animations:^{
        
        [weakSelf.view layoutIfNeeded];
    }];
}

- (void)endSearchMode
{
    isSearchMode = NO;
    self.tf_Search.text = @"";
    self.arM_List = [NSMutableArray arrayWithArray:self.arM_BackUpList];
    [self.tbv_List reloadData];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.view endEditing:YES];
    self.lc_NaviHeight.constant = 64.f;
    self.lc_CancelWidth.constant = 0.f;
    self.lc_SearchBgHeight.constant = 44.f;
    [UIView animateWithDuration:0.2f animations:^{
        
        [weakSelf.view layoutIfNeeded];
    }];
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
    KikBotMainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KikBotMainCell"];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    /*
     userId: 사용자 ID (챗봇 userId)
     channelId: 채널 ID (챗봇 채팅방 channelId)
     userType: 답변자 구분 [U-사용자, G-그룹, B-Bot] (Bot만 내려옴)
     thumbnail: 챗봇 썸네일
     displayName: 챗봇 이름
     hashtagStr: 챗봇 만들때 입력한 해시태그
     userCount: 챗봇을 사용한 유저수
     rId: 채팅방 ID [0이면 채팅방을 개설해야함]
     questionId : 채팅방 questionId [0이면 채팅방을 개설해야함]
     sendbirdChannelUrl: sendbird channel url
     */

    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"thumbnail"]];
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] placeholderImage:BundleImage(@"no_image.png")];
    
    cell.lb_Titile.text = [dic objectForKey_YM:@"displayName"];
    
    cell.lb_Tags.text = [dic objectForKey_YM:@"hashtagStr"];
    if( cell.lb_Tags.text.length <= 0 )
    {
        cell.lb_Tags.text = [dic objectForKey_YM:@"hashTagStr"];
    }
    
    cell.lb_Count.text = [NSString stringWithFormat:@"(%@)", [dic objectForKey_YM:@"userCount"]];
    
    NSInteger nAvgStar = [[dic objectForKey:@"avgStarCount"] integerValue];
    [cell.v_Star setStarScore:nAvgStar];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];

    NSString *str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]];
    if( str_QuestionId == nil || str_QuestionId.length <= 0 || [str_QuestionId integerValue] <= 0 )
    {
        //퀘스쳔아이디가 없으면 방을 만들고 이동해야 함
        [self makePublicGroup:[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]] withTitle:[dic objectForKey_YM:@"displayName"] withCover:[dic objectForKey_YM:@"thumbnail"]];
    }
    else
    {
        KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
        vc.str_QuestionId = str_QuestionId;
        vc.roomType = kBot;
//        vc.str_BotId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]];
        vc.str_BotId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"botId"]];
        vc.str_ChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)makePublicGroup:(NSString *)aBotId withTitle:(NSString *)aTitle withCover:(NSString *)coverUrl
{
    __block NSString *str_CoverUrl = [NSString stringWithString:coverUrl];
    __weak __typeof(&*self)weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        aTitle, @"roomName",
                                        aBotId, @"inviteUserIdStr",
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
                                                
                                                NSMutableArray *arM_UserList = [NSMutableArray array];
                                                NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                                                [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
                                                [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
                                                [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
                                                [arM_UserList addObject:dicM_MyInfo];
                                                 
                                                NSMutableDictionary *dicM_OtherInfo = [NSMutableDictionary dictionary];
                                                [dicM_OtherInfo setObject:aBotId forKey:@"userId"];
                                                [dicM_OtherInfo setObject:aTitle forKey:@"userName"];
                                                [dicM_OtherInfo setObject:coverUrl forKey:@"imgUrl"];
                                                [arM_UserList addObject:dicM_OtherInfo];
                                                
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_QnaInfo];
                                                [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                [dicM setObject:aBotId forKey:@"botUserId"];
                                                [dicM setObject:@"chatBot" forKey:@"roomType"];

                                                
                                                NSString *str_RId = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"rId"]];
                                                //                                                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", @"1:1", str_RId];
                                                
                                                NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                if( str_CoverUrl )
                                                {
                                                    if( str_UserImagePrefix == nil || str_UserImagePrefix.length <= 0 )
                                                    {
                                                        str_UserImagePrefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"];
                                                    }
                                                    
                                                    str_CoverUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, str_CoverUrl];
                                                }

                                                NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"rId"]] forKey:@"rId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"questionId"]] forKey:@"questionId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"channelId"]] forKey:@"channelId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"hashTagStr"]] forKey:@"hashTagStr"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomDesc"]] forKey:@"roomDesc"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"ownerId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey:@"botUserId"]] forKey:@"botUserId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey:@"botOwnerId"]] forKey:@"botOwnerId"];

                                                NSError * err;
                                                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data options:0 error:&err];
                                                __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                                                [SBDGroupChannel createChannelWithName:aTitle isDistinct:NO userIds:@[aBotId] coverUrl:str_CoverUrl data:str_Dic customType:@"chatBot"
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
                                                                         
                                                                         KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
                                                                         vc.str_QuestionId = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"questionId"]];
                                                                         vc.str_BotId = aBotId;
                                                                         vc.roomType = kBot;
                                                                         vc.str_ChannelUrl = baseChannel.channelUrl;
                                                                         vc.str_ChatBotThumUrl = str_CoverUrl;
                                                                         [weakSelf.navigationController pushViewController:vc animated:YES];
                                                                     }];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}


#pragma mark - IBAction
- (IBAction)goMakeBot:(id)sender
{
    KikMakeBotsViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikMakeBotsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goCancel:(id)sender
{
    [self endSearchMode];
}

@end
