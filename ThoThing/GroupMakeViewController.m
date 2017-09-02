//
//  GroupMakeViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 23..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "GroupMakeViewController.h"
#import "ChatFeedViewController.h"
#import "SBJsonParser.h"
@interface GroupMakeViewController ()
@property (nonatomic, weak) IBOutlet UITextField *tf_GroupName;
@property (nonatomic, weak) IBOutlet UIButton *btn_Next;
@end

@implementation GroupMakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [SBDMain addChannelDelegate:self identifier:self.description];

    self.btn_Next.layer.cornerRadius = 5.f;
    self.btn_Next.layer.borderWidth = 1.f;
    self.btn_Next.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_Next.backgroundColor = [UIColor whiteColor];
    [self.btn_Next setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

    [self.tf_GroupName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self.tf_GroupName becomeFirstResponder];
    
//    [self startSendBird];
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

- (void)textFieldDidChange:(UITextField *)tf
{
    if( tf.text.length > 0 )
    {
        self.btn_Next.userInteractionEnabled = YES;
        [self.btn_Next setTitleColor:kMainColor forState:UIControlStateNormal];
        self.btn_Next.layer.borderColor = kMainColor.CGColor;
    }
    else
    {
        self.btn_Next.userInteractionEnabled = NO;
        [self.btn_Next setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.btn_Next.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField.text.length > 0 )
    {
        [self makeGroupChat];
    }
    
    return YES;
}

- (void)makeGroupChat
{
    if( self.tf_GroupName.text.length > 0 )
    {
        self.btn_Next.userInteractionEnabled = NO;
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            @"", @"channelId",
                                            self.tf_GroupName.text, @"roomName",
                                            self.str_InviteUsers, @"inviteUserIdStr",
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
                                                    [self makeSendbird:dic];
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                            
                                            self.btn_Next.userInteractionEnabled = YES;
                                        }];
    }
}


- (IBAction)goNext:(id)sender
{
    [self makeGroupChat];
}

- (void)makeSendbird:(NSDictionary *)dic
{
    NSString *str_SBDChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];

    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dicM setObject:self.ar_UserInfos forKey:@"userThumbnail"];
    
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

                NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
                //                             NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.tf_GroupName.text, str_RId];
                
                SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                NSLog(@"%@", baseChannel.channelUrl);
                [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                vc.str_RId = str_RId;
                vc.dic_Info = dic;
                vc.str_RoomName = str_ChannelName;
                vc.str_RoomTitle = self.tf_GroupName.text;
                vc.ar_UserIds = [self.str_InviteUsers componentsSeparatedByString:@","];
                vc.channel = channel;
                vc.str_ChannelIdTmp = self.str_ChannelId;
                [self.navigationController pushViewController:vc animated:YES];

            }];
        }];
    }
    else
    {
        //그룹방은 신규 방으로 개설
        //138,213,541
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

        [SBDGroupChannel createChannelWithName:self.tf_GroupName.text isDistinct:NO userIds:[self.str_InviteUsers componentsSeparatedByString:@","] coverUrl:nil data:str_Dic customType:nil
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
                                 NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.tf_GroupName.text, str_RId];
                                 
                                 SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                                 NSLog(@"%@", baseChannel.channelUrl);
                                 [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                                 
                                 UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                 ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                 vc.str_RId = str_RId;
                                 vc.dic_Info = dic;
                                 vc.str_RoomName = str_ChannelName;
                                 vc.str_RoomTitle = self.tf_GroupName.text;
                                 vc.ar_UserIds = [self.str_InviteUsers componentsSeparatedByString:@","];
                                 vc.channel = channel;
                                 vc.str_ChannelIdTmp = self.str_ChannelId;
                                 [self.navigationController pushViewController:vc animated:YES];
                             }];
    }
}


#pragma mark - SendBird
//- (void)startSendBird
//{
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
//}

@end
