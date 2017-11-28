//
//  HelpMenuViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "HelpMenuViewController.h"
#import "HelpMenuCell.h"
#import "EtcWebViewController.h"
#import "ChatFeedViewController.h"

@interface HelpMenuViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIImageView *iv_ThotingIcon;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvHeight;
@end

@implementation HelpMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arM_List = [NSMutableArray array];
    [self.arM_List addObject:@"도움말"];
    [self.arM_List addObject:@"업데이트"];
    [self.arM_List addObject:@"서비스 약관"];
    [self.arM_List addObject:@"개인정보 취급방침"];
    [self.arM_List addObject:@"라이선스"];
    [self.arM_List addObject:@"법적 고지"];
    
    self.lc_TbvHeight.constant = self.arM_List.count * 55.f;
    
    self.iv_ThotingIcon.clipsToBounds = YES;
    [self.iv_ThotingIcon sd_setImageWithURL:[NSURL URLWithString:kThotingThumbUrl]];
    self.iv_ThotingIcon.layer.cornerRadius = self.iv_ThotingIcon.frame.size.width / 2;
    self.iv_ThotingIcon.layer.borderColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1].CGColor;
    self.iv_ThotingIcon.layer.borderWidth = 1.f;
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
    HelpMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HelpMenuCell"];
    
    NSString *str_Title = self.arM_List[indexPath.row];
    
    cell.lb_Title.text = str_Title;
    
    if( [str_Title isEqualToString:@"업데이트"] )
    {
        cell.lb_SubTitle.text = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        cell.iv_Arrow.hidden = YES;
        cell.lb_SubTitle.hidden = NO;
    }
    else
    {
        cell.lb_SubTitle.text = @"";
        cell.iv_Arrow.hidden = YES;
        cell.lb_SubTitle.hidden = NO;
    }

    if( indexPath.row == self.arM_List.count - 1 )
    {
        cell.lc_LineLeft.constant = 0.f;
    }
    else
    {
        cell.lc_LineLeft.constant = 15.f;
    }

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *str_Title = self.arM_List[indexPath.row];
    
    if( [str_Title isEqualToString:@"업데이트"] )
    {
        
    }
    else
    {
        EtcWebViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"EtcWebViewController"];
        vc.str_Title = str_Title;
        
        if( [str_Title isEqualToString:@"도움말"] )
        {
            vc.str_Url = @"http://naver.com";
        }
        else if( [str_Title isEqualToString:@"업데이트"] )
        {
            
        }
        else if( [str_Title isEqualToString:@"서비스 약관"] )
        {
            
        }
        else if( [str_Title isEqualToString:@"개인정보 취급방침"] )
        {
            
        }
        else if( [str_Title isEqualToString:@"라이선스"] )
        {
            
        }
        else if( [str_Title isEqualToString:@"법적 고지"] )
        {
            
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}



- (IBAction)goStartThotingChat:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;
    
    self.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        @"", @"roomName",
                                        @"1", @"inviteUserIdStr",
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
                                                [self makeSendbird:dic withUserId:@"1"];
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
    
//    //유저 이름 가져오기
//    NSString *str_UserName = @"";
//    NSString *str_UserThumb = @"";
//    for( NSInteger i = 0; i < self.arM_List.count; i++ )
//    {
//        NSDictionary *dic_Tmp = [self.arM_List objectAtIndex:i];
//        if( [aUserId integerValue] == [[dic_Tmp objectForKey:@"userId"] integerValue] )
//        {
//            str_UserName = [dic_Tmp objectForKey_YM:@"userName"];
//            str_UserThumb = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic_Tmp objectForKey_YM:@"userThumbnail"]];
//
//            NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
//            [dicM_MyInfo setObject:aUserId forKey:@"userId"];
//            [dicM_MyInfo setObject:str_UserName forKey:@"userName"];
//            [dicM_MyInfo setObject:str_UserThumb forKey:@"imgUrl"];
//            [arM_UserList addObject:dicM_MyInfo];
//
//            break;
//        }
//    }
    
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

        [SBDGroupChannel createChannelWithName:@"토팅" isDistinct:NO userIds:@[aUserId] coverUrl:kThotingThumbUrl data:str_Dic customType:@"user"
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

@end
