//
//  MakeChattingRoomViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 6..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "MakeChattingRoomViewController.h"

@interface MakeChattingRoomViewController ()
@property (nonatomic, weak) IBOutlet UIView *v_PopUp;
@property (nonatomic, weak) IBOutlet UITextField *tf;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_PopUpBottom;
@end

@implementation MakeChattingRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.v_PopUp.layer.borderWidth = 1.0f;
    self.v_PopUp.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
    
//    [self startSendBird];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tf becomeFirstResponder];
    
    self.lc_PopUpBottom.constant = 275.f;
    [self.v_PopUp setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.v_PopUp layoutIfNeeded];
    }];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tf resignFirstResponder];
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField.text.length > 0 )
    {
        [self goMake:nil];
    }
    
    return YES;
}


#pragma mark - IBAction
- (IBAction)goCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)goMake:(id)sender
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        self.tf.text, @"roomName",
                                        nil];
    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/create/channel/chat/qna/room"
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/create/channel/qna/chat/room"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic = [resulte objectForKey:@"qnaRoomInfo"];
                                                [self joinSendBirdRoom:[NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]]];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)joinSendBirdRoom:(NSString *)aQuestionId
{
    //채널질문방_{사용자가입력한질문방이름}_questionId
    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_channel_%@", aQuestionId];
    NSString *str_ChannelName = [NSString stringWithFormat:@"채널질문방_%@_%@", self.tf.text, aQuestionId];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        kSendBirdApiToken, @"auth",
                                        str_ChannelUrl, @"channel_url",
                                        str_ChannelName, @"name",
                                        nil];
    
    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:@"channel/create"
                                             param:dicM_Params
                                        withMethod:@"POST"
                                         withBlock:^(id resulte, NSError *error) {

                                             /*
                                              "channel_url" = "62e94.thotingQuestion_channel_18197";
                                              "cover_img_url" = "https://sendbird.com/main/img/cover/cover_03.jpg";
                                              "created_at" = 1474608364;
                                              data = "";
                                              id = 40121757;
                                              "max_length_message" = "-1";
                                              "member_count" = 0;
                                              name = "\Ucc44\Ub110\Uc9c8\Ubb38\Ubc29_\Ubc29 \Ub9cc\Ub4e4\Uae30 \Ud14c\Uc2a4\Ud2b84_18197";
                                              ops =     (
                                              );
                                              */
                                             if( resulte )
                                             {
//                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
//                                                 {
//                                                     //이미 방이 있으면 조인
//                                                     [SendBird joinChannel:str_ChannelUrl];
//                                                     [SendBird connect];
//                                                     //                                                     [SendBird sendMessage:@"@@hi@@"];
//                                                 }
//                                                 else
//                                                 {
//                                                     [SendBird joinChannel:[resulte objectForKey:@"channel_url"]];
//                                                     [SendBird connect];
//                                                 }
                                             }
                                             
                                             [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", aQuestionId]
                                                                                       forKey:[NSString stringWithFormat:@"%@", aQuestionId]];
                                             [[NSUserDefaults standardUserDefaults] synchronize];
                                             
                                             UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                             [window makeToast:@"채팅방이 개설되었습니다" withPosition:kPositionCenter];
                                             
                                             if( self.completionBlock )
                                             {
                                                 self.completionBlock(nil);
                                             }
                                             
                                             [self goCancel:nil];
                                         }];
}

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
