//
//  ChatFeedViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 24..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChatFeedViewController.h"
#import "ChatFeedMemeberInviteViewController.h"
#import "CommentKeyboardAccView.h"
@import AVFoundation;
@import MediaPlayer;
#import "MWPhotoBrowser.h"
#import "ChattingCell.h"
#import "QuestionListCell.h"
#import "YTPlayerView.h"
#import "YmExtendButton.h"
#import "AudioView.h"
#import "DiscripFooterView.h"
#import "DiscripHeaderCell.h"
#import "AddDiscripViewController.h"
#import "SBJsonParser.h"
#import "VideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "InRoomMemberListViewController.h"
#import "InvitationViewController.h"
#import "CommentKeyboardAccView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "UserPageMainViewController.h"
#import "MyMainViewController.h"
#import "QuestionStartViewController.h"
#import "QuestionDetailViewController.h"
#import "QuestionContainerViewController.h"

#import "MyChatBasicCell.h"
#import "MyShareExamCell.h"
#import "MyShareExamNoMsgCell.h"
#import "MyImageCell.h"
#import "CmdChatCell.h"
#import "MyDirectChatCell.h"
#import "OtherDirectChatCell.h"
#import "MyDirectChatMsgCell.h"
#import "OtherDirectChatMsgCell.h"

#import "OtherCmdFollowingCell.h"
#import "MyCmdFollowingCell.h"

#import "NormalQuestionCell.h"

#import "NotiViewController.h"
#import "ChannelMainViewController.h"
#import "ChatReportViewController.h"

#import <TTTAttributedLabel.h>
#import "BABFrameObservingInputAccessoryView.h"
#import "QuestionViewController.h"

#import "YTPlayerView.h"
#import "TMImageZoom.h"
#import "AutoAnswerCell.h"
#import "AutoChatAudioCell.h"

@import AVFoundation;
@import MediaPlayer;

static NSInteger kMoreCount = 50;

typedef enum {
    kLeaveChat      = -1,
    kInviteChat     = 0,
    kEnterChat      = 1,
} ChatStatus;

typedef enum {
    kWatingMode     = -2,   //문제 선택
    kPrintExam      = -1,   //문제 선택
    kPrintItem      = 0,    //보기 선택
    kPrintAnswer    = 1,    //답 선택
    kNextExam       = 2,    //다음 문제
    kPrintContinue  = 3,    //계속풀기
} AutoChatMode;

@interface ChatFeedViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate, SBDChannelDelegate, SBDConnectionDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL isLoding;
    BOOL isFirstLoad;   //첫 로드인지 기억했다가 첫로드면 로드중 추가된 메세지는 로드후 애드 시키기 위함
    BOOL hasNext;
    BOOL isShowInRoomMsg;
    
    NSInteger nTotalCnt;
    
    CGFloat fKeyboardHeight;
    
    NSString *str_UserImagePrefix;
    NSString *str_ImagePreFix;
    
    NSString *str_ChatType;
    NSString *str_NormalTmpMessage;
    
    NSString *str_ImagePrefix;
    NSString *str_ChannelId;
    
    MWPhotoBrowser *browser;
    
    NSInteger nLastMyIdx;   //내가 등록한 마지막 글 인덱스 (전송완료 체크를 위해 필요)
    
    //    NSString *str_ChannelUrl;
    
    NSInteger nAutoAnswerIdx;
}
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_TempList;
@property (nonatomic, strong) NSMutableArray *arM_MessageQ;
@property (nonatomic, strong) NSMutableDictionary *dicM_TempMyContents;
@property (nonatomic, strong) NSDictionary *dic_PrintItemInfo;
@property (nonatomic, strong) NSTimer *tm_MessageQ;
@property (nonatomic, strong) NSDictionary *dic_Data;
@property (nonatomic, strong) NSMutableArray *arM_User;
@property (nonatomic, strong) NSMutableArray *arM_AutoAnswer;
@property (nonatomic, strong) NSMutableDictionary *dicM_AutoAudio;
@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
@property (nonatomic, assign) AutoChatMode autoChatMode;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalUserCount;
@property (nonatomic, weak) IBOutlet UILabel *lb_GroupCount;
@property (nonatomic, weak) IBOutlet UIImageView *iv_TopUser;
@property (nonatomic, weak) IBOutlet UIButton *btn_GroupInfo;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet CommentKeyboardAccView *v_CommentKeyboardAccView;
@property (nonatomic, strong) MyChatBasicCell *c_MyChatBasicCell;
@property (nonatomic, strong) OtherChatBasicCell *c_OtherChatBasicCell;
@property (nonatomic, strong) OtherShareExamCell *c_OtherShareExamCell;
@property (nonatomic, strong) MyShareExamCell *c_MyShareExamCell;
@property (nonatomic, strong) OtherShareExamNoMsgCell *c_OtherShareExamNoMsgCell;
@property (nonatomic, strong) MyShareExamNoMsgCell *c_MyShareExamNoMsgCell;
@property (nonatomic, strong) OtherImageCell *c_OtherImageCell;
@property (nonatomic, strong) MyImageCell *c_MyImageCell;
@property (nonatomic, strong) CmdChatCell *c_CmdChatCell;
@property (nonatomic, strong) OtherCmdFollowingCell *c_OtherCmdFollowingCell;
@property (nonatomic, strong) MyCmdFollowingCell *c_MyCmdFollowingCell;
@property (nonatomic, strong) MyDirectChatCell *c_MyDirectChatCell;
@property (nonatomic, strong) OtherDirectChatCell *c_OtherDirectChatCell;

@property (nonatomic, strong) MyDirectChatMsgCell *c_MyDirectChatMsgCell;
@property (nonatomic, strong) OtherDirectChatMsgCell *c_OtherDirectChatMsgCell;

@property (nonatomic, strong) NormalQuestionCell *c_NormalQuestionCell;

@property (atomic) long long minMessageTimestamp;
//@property (strong, nonatomic) NSArray<SBDBaseMessage *> *dumpedMessages;
//@property (strong, nonatomic) NSMutableArray<SBDBaseMessage *> *messages;
@property (strong, nonatomic) NSMutableArray *messages;

//음성문제 관련
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
@property (nonatomic, strong) AudioView *v_Audio;
/////////

//유튜브
@property (nonatomic, strong) YTPlayerView *playerView;
@property (nonatomic, strong) NSString *str_AudioBody;
@property (nonatomic, strong) NSMutableArray *arM_Audios;

@property (nonatomic, strong) AutoAnswerCell *c_AutoAnswerCell;

@end

@implementation ChatFeedViewController

- (void)onEnterForegroundNoti
{
    if( self.dic_BotInfo )
    {
        [self sendBotWelcome];
    }
    else
    {
        [self.view endEditing:YES];
    }
}

//- (void)onShareExamNoti:(NSNotification *)noti
//{
////    ALERT(@"노티", @"onShareExamNoti", nil, @"확인", nil);
//
//
////    NSDictionary *dic = noti.object;
////
////    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
////    [dicM setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"eId"] integerValue]] forKey:@"eId"];
////    [dicM setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"questionId"] integerValue]] forKey:@"questionId"];
////    [dicM setObject:@"cmd" forKey:@"itemType"];
////
////    [self updateOneList:dicM];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //    [self startSendBird];
    
    NSLog(@"self.str_PdfImageUrl : %@", self.str_PdfImageUrl);
    
    self.autoChatMode = kPrintExam;
    
    /*
     SBDUserConnectionStatusNonAvailable = 0,
     SBDUserConnectionStatusOnline = 1,
     SBDUserConnectionStatusOffline = 2,
     */
    for( NSInteger i = 0; i < self.channel.members.count; i++ )
    {
        SBDUser *user = [self.channel.members objectAtIndex:i];
        NSLog(@"%@", user.userId);
        NSLog(@"%@", user.nickname);
        NSLog(@"connectionStatus : %ld", user.connectionStatus);
        //        if( user.connectionStatus == 1 )
        //        {
        //            ALERT(nil, user.nickname, nil, @"online", nil);
        //        }
        
    }
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShareExamNoti:) name:@"ShareExamNoti" object:nil];
    
    [SBDMain addChannelDelegate:self identifier:@"chat"];
    [SBDMain addConnectionDelegate:self identifier:@"chat"];
    
    //    NSLog(@"%d", self.channel.isPushEnabled);
    //    [self.channel setPushPreferenceWithPushOn:YES completionHandler:^(SBDError * _Nullable error) {
    //        if (error != nil) {
    //            NSLog(@"Error");
    //            return;
    //        }
    //    }];
    
    hasNext = YES;
    
    //    [SBDGroupChannel getChannelWithUrl:self.channel.channelUrl
    //                     completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
    //
    ////                         NSString *str_Msg = [NSString stringWithFormat:@"%@님이 입장하셨습니다.", [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
    ////                         [channel sendUserMessage:str_Msg data:nil customType:@"join" completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
    ////
    ////                         }];
    //                     }];
    
    //    self.tbv_List.translatesAutoresizingMaskIntoConstraints = YES;
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(becomeActiove)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    
    if( self.dic_BotInfo )
    {
        [self sendBotWelcome];
    }
    
    //스크롤뷰 내릴때 키보드도 함께 내리기
    BABFrameObservingInputAccessoryView *inputView = [[BABFrameObservingInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    inputView.userInteractionEnabled = NO;
    
    
    self.v_CommentKeyboardAccView.tv_Contents.inputAccessoryView = inputView;
    
    __weak typeof(self)weakSelf = self;
    
    inputView.inputAcessoryViewFrameChangedBlock = ^(CGRect inputAccessoryViewFrame){
        
        CGFloat value = CGRectGetHeight(weakSelf.view.frame) - CGRectGetMinY(inputAccessoryViewFrame) - CGRectGetHeight(weakSelf.v_CommentKeyboardAccView.tv_Contents.inputAccessoryView.frame);
        
        weakSelf.v_CommentKeyboardAccView.lc_Bottom.constant = MAX(0, value);
        
        [weakSelf.view layoutIfNeeded];
        
    };
    ///////////////////////////////
    
    if( self.dic_BotInfo )
    {
        self.v_CommentKeyboardAccView.btn_KeyboardChange.hidden = NO;
    }
    else
    {
        self.v_CommentKeyboardAccView.btn_KeyboardChange.hidden = YES;
    }
    
    [self.v_CommentKeyboardAccView.btn_KeyboardChange addTarget:self action:@selector(onKeyboardChange:) forControlEvents:UIControlEventTouchUpInside];
    
    nAutoAnswerIdx = -1;
    self.arM_AutoAnswer = [NSMutableArray array];
    
    //    [self.arM_AutoAnswer addObject:@"고1 전국연합학력평가고1 전국연합학력평가고1 전국연합학력평가고1 전국연합학력평가고1 전국연합학력평가고1 전국연합학력평가고1 전국연합학력평가고1 전국연합학력평가고1 전국연합학력평가"];
    //    [self.arM_AutoAnswer addObject:@"고2 전국연합학력평가"];
    //    [self.arM_AutoAnswer addObject:@"고3 전국연합학력평가"];
    //    [self.arM_AutoAnswer addObject:@"대학수학능력시험 9월"];
    //    [self.arM_AutoAnswer addObject:@"모의고사"];
    
    self.arM_List = [NSMutableArray array];
    self.arM_User = [NSMutableArray array];
    self.arM_MessageQ = [NSMutableArray array];
    self.arM_TempList = [NSMutableArray array];
    self.dicM_TempMyContents = [NSMutableDictionary dictionary];
    self.arM_Audios = [NSMutableArray array];
    self.dicM_AutoAudio = [NSMutableDictionary dictionary];
    
    self.tbv_List.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbv_List.frame.size.width, 27.f)];
    self.tbv_List.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbv_List.frame.size.width, 10.f)];
    
    self.c_MyChatBasicCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([MyChatBasicCell class])];
    self.c_OtherChatBasicCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([OtherChatBasicCell class])];
    self.c_OtherShareExamCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([OtherShareExamCell class])];
    self.c_MyShareExamCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([MyShareExamCell class])];
    
    self.c_OtherShareExamNoMsgCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([OtherShareExamNoMsgCell class])];
    self.c_MyShareExamNoMsgCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([MyShareExamNoMsgCell class])];
    
    self.c_OtherImageCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([OtherImageCell class])];
    self.c_MyImageCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([MyImageCell class])];
    
    self.c_CmdChatCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([CmdChatCell class])];
    
    self.c_OtherCmdFollowingCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([OtherCmdFollowingCell class])];
    self.c_MyCmdFollowingCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([MyCmdFollowingCell class])];
    
    self.c_MyDirectChatCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([MyDirectChatCell class])];
    self.c_OtherDirectChatCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([OtherDirectChatCell class])];
    
    self.c_MyDirectChatMsgCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([MyDirectChatMsgCell class])];
    self.c_OtherDirectChatMsgCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([OtherDirectChatMsgCell class])];
    
    self.c_NormalQuestionCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([NormalQuestionCell class])];
    
    //    self.c_AutoAnswerCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([AutoAnswerCell class])];
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AutoAnswerCell" owner:self options:nil];
    self.c_AutoAnswerCell = [topLevelObjects objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEnterForegroundNoti) name:@"EnterForegroundNoti" object:nil];
    
    
    self.v_CommentKeyboardAccView.tv_Contents.placeholder = kChatPlaceHolder;
    
    self.iv_TopUser.clipsToBounds = YES;
    self.iv_TopUser.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_TopUser.layer.cornerRadius = self.iv_TopUser.frame.size.width / 2;
    self.iv_TopUser.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
    self.iv_TopUser.layer.borderWidth = 1.f;
    
    self.btn_GroupInfo.hidden = YES;
    self.iv_TopUser.hidden = YES;
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topImageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [self.iv_TopUser addGestureRecognizer:imageTap];
    
    [self updateTopData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReload:) name:@"ChatReloadNoti" object:nil];
    
    self.minMessageTimestamp = LLONG_MAX;
    
    self.messages = [NSMutableArray array];
    
    NSString *str_Key = [NSString stringWithFormat:@"Chat_%@", self.str_RId];
    NSData *dictionaryData = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    NSArray *ar = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
    if( ar && ar.count > 0 )
    {
        self.messages = [NSMutableArray arrayWithArray:ar];
        for( NSInteger i = 0; i < self.messages.count; i++ )
        {
            NSDictionary *dic = self.messages[i];
            if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_ENTER"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"enterBotRoom"] )
            {
                [self.messages removeObjectAtIndex:i];
            }
        }
        [self.tbv_List reloadData];
        [self.tbv_List layoutIfNeeded];
        [self scrollToTheBottom:NO];
        [self updateChatList:YES];
    }
    else
    {
        //        self.dumpedMessages = [Util loadMessagesInChannel:self.channel.channelUrl];
        
        //        self.messages = [NSMutableArray array];
        [self updateChatList:YES];
        
        //        if (self.dumpedMessages.count > 0)
        //        {
        //            [self.messages addObjectsFromArray:self.dumpedMessages];
        //
        //            [self.tbv_List reloadData];
        //            [self.tbv_List layoutIfNeeded];
        //        }
        //        else
        //        {
        //            NSLog(@"%lld", LLONG_MAX);
        //
        //        }
    }
    
    if( self.str_RoomTitle )
    {
        //신규방
        self.lb_Title.text = self.str_RoomTitle;
        
        if( self.str_RoomThumb )
        {
            //개인방
            self.btn_GroupInfo.hidden = YES;
            self.iv_TopUser.hidden = NO;
            [self.iv_TopUser sd_setImageWithURL:[NSURL URLWithString:self.str_RoomThumb]];
            self.arM_User = [NSMutableArray arrayWithArray:self.ar_UserIds];
        }
        else
        {
            //단체방
            self.btn_GroupInfo.hidden = NO;
            self.iv_TopUser.hidden = YES;
            self.arM_User = [NSMutableArray arrayWithArray:self.ar_UserIds];
        }
    }
    else
    {
        //기존에 있던 방
        //        [self updateList:YES];
    }
    
    isShowInRoomMsg = YES;
    
    //    [self performSelector:@selector(onShowingInterval) withObject:nil afterDelay:0.7f];
    
    
    //    str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", self.str_RId];
    //    NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.str_RoomName, self.str_RId];
    //
    //    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                        kSendBirdApiToken, @"auth",
    //                                        str_ChannelUrl, @"channel_url",
    //                                        str_ChannelName, @"name",
    //                                        nil];
    //
    //    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:@"channel/create"
    //                                             param:dicM_Params
    //                                        withMethod:@"POST"
    //                                         withBlock:^(id resulte, NSError *error) {
    //
    //                                             if( resulte )
    //                                             {
    //                                                 NSString *str_CurrentChannel = @"";
    //                                                 NSString *str_DashBoardChannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"DashBoardChannel"];
    //
    //                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
    //                                                 {
    //                                                     str_CurrentChannel = str_ChannelUrl;
    //                                                     //이미 방이 있으면 조인
    ////                                                     [SendBird joinChannel:str_ChannelUrl];
    ////                                                     [SendBird joinMultipleChannels:@[str_ChannelUrl, str_DashBoardChannel]];
    ////                                                     [SendBird connect];
    //
    //                                                     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
    //                                                                                                                  @"userName":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
    //                                                                                                                  @"channelUrl":str_ChannelUrl}
    //                                                                                                        options:NSJSONWritingPrettyPrinted
    //                                                                                                          error:nil];
    //                                                     NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //                                                     [self performSelector:@selector(sendJoinDelay:) withObject:jsonString afterDelay:1.0f];
    //                                                 }
    //                                                 else
    //                                                 {
    //                                                     str_CurrentChannel = [resulte objectForKey:@"channel_url"];
    ////                                                     str_ChannelUrl = [resulte objectForKey:@"channel_url"];
    ////                                                     [SendBird joinChannel:str_ChannelUrl];
    ////                                                     [SendBird joinMultipleChannels:@[[resulte objectForKey:@"channel_url"], str_DashBoardChannel]];
    ////                                                     [SendBird connect];
    //
    //                                                     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
    //                                                                                                                  @"userName":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
    //                                                                                                                  @"channelUrl":str_ChannelUrl}
    //                                                                                                        options:NSJSONWritingPrettyPrinted
    //                                                                                                          error:nil];
    //                                                     NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //                                                     [self performSelector:@selector(sendJoinDelay:) withObject:jsonString afterDelay:1.0f];
    //                                                 }
    //
    ////                                                 [SBDOpenChannel getChannelWithUrl:@"thotingQuestion_chatdashboard_0"
    ////                                                                 completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
    ////
    ////                                                                     [channel sendUserMessage:@"join" completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
    ////
    ////                                                                         NSLog(@"@@@@@@@@@@@@@");
    ////                                                                     }];
    ////                                                                 }];
    //
    //                                                 [SBDGroupChannel getChannelWithUrl:self.str_ChannelUrl
    //                                                                  completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
    //
    //                                                                      [channel sendUserMessage:@"message" data:@"data" completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
    //
    //
    //                                                                      }];
    //
    //                                                                      [channel sendUserMessage:@"join" completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
    //
    //                                                                          NSLog(@"@@@@@@@@@@@@@");
    //                                                                      }];
    //                                                                  }];
    ////                                                 [SBDOpenChannel getChannelWithUrl:str_CurrentChannel
    ////                                                                 completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
    ////
    ////                                                                     [channel enterChannelWithCompletionHandler:^(SBDError * _Nullable error) {
    ////
    ////                                                                         [channel sendUserMessage:@"join" completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
    ////
    ////                                                                         }];
    ////                                                                     }];
    ////                                                                 }];
    //
    ////                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"Test33" object:nil];
    //                                             }
    //                                         }];
    
    
    //    self.lc_TfWidth.constant = 45.f;
}

- (void)onKeyboardChange:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    
    if( btn.selected )
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - fKeyboardHeight, window.bounds.size.width, fKeyboardHeight)];
        view.tag = 1982;
        view.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
        
        UITableView *tbv_AutoAnswer = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        tbv_AutoAnswer.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 8.f)];
        tbv_AutoAnswer.tag = 1983;
        tbv_AutoAnswer.backgroundColor = [UIColor clearColor];
        tbv_AutoAnswer.separatorStyle = UITableViewCellSeparatorStyleNone;
        tbv_AutoAnswer.delegate = self;
        tbv_AutoAnswer.dataSource = self;
        [tbv_AutoAnswer reloadData];
        [view addSubview:tbv_AutoAnswer];
        
        [window addSubview:view];
        [window bringSubviewToFront:view];
    }
    else
    {
        UIView *view = [window viewWithTag:1982];
        [view removeFromSuperview];
    }
}

- (void)showTempleteKeyboard
{
    self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = YES;
    
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    UIView *view_Tmp = [window viewWithTag:1982];
    if( view_Tmp )
    {
        [view_Tmp removeFromSuperview];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - fKeyboardHeight, window.bounds.size.width, fKeyboardHeight)];
    view.tag = 1982;
    view.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
    
    UITableView *tbv_AutoAnswer = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    tbv_AutoAnswer.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 8.f)];
    tbv_AutoAnswer.tag = 1983;
    tbv_AutoAnswer.backgroundColor = [UIColor clearColor];
    tbv_AutoAnswer.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbv_AutoAnswer.delegate = self;
    tbv_AutoAnswer.dataSource = self;
    [tbv_AutoAnswer reloadData];
    [view addSubview:tbv_AutoAnswer];
    
    [window addSubview:view];
    [window bringSubviewToFront:view];
}

- (void)onKeyboardShow
{
    [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
}

- (void)sendBotWelcome
{
    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    
    NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
    [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
    [dicM_Param setObject:@"test" forKey:@"message"];
    [dicM_Param setObject:@"cmd" forKey:@"custom_type"];
    [dicM_Param setObject:@"enterBotRoom" forKey:@"custom_type"];
    
    NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
    [dicM_Data setObject:@"enterBotRoom" forKey:@"type"];
    
    NSMutableDictionary *dicM_Inviter = [NSMutableDictionary dictionary];
    [dicM_Inviter setObject:str_UserId forKey:@"user_id"];
    [dicM_Inviter setObject:str_UserName forKey:@"nickname"];
    [dicM_Data setObject:dicM_Inviter forKey:@"sender"];
    
    
    //    NSMutableArray *arM_Users = [NSMutableArray array];
    //    [dicM_Data setObject:arM_Users forKey:@"users"];
    
    [dicM_Data setObject:@"test" forKey:@"message"];
    [dicM_Data setObject:[NSString stringWithFormat:@"%@", [self.dic_BotInfo objectForKey:@"userId"]] forKey:@"botUserId"];
    [dicM_Data setObject:@"botChat" forKey:@"roomType"];
    [dicM_Data setObject:@"user" forKey:@"userType"];
    [dicM_Data setObject:@"" forKey:@"chatScreen"];
    [dicM_Data setObject:@"" forKey:@"mesgAction"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [dicM_Param setObject:jsonString forKey:@"data"];
    
    [dicM_Param setObject:@"true" forKey:@"is_silent"];
    
    
    NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
                                             param:dicM_Param
                                        withMethod:@"POST"
                                         withBlock:^(id resulte, NSError *error) {
                                             
                                             if( resulte )
                                             {
                                                 
                                             }
                                         }];
}

- (void)scrollToBottomInterval:(NSNumber *)num
{
    [self scrollToTheBottom:[num boolValue]];
    self.tbv_List.alpha = YES;
}

- (void)updateChatList:(BOOL)isInit
{
    if( hasNext == NO )
    {
        return;
    }
    
    isLoding = YES;
    
    if( isInit )
    {
        [self.messages removeAllObjects];
    }
    
    [self.channel getPreviousMessagesByTimestamp:self.minMessageTimestamp
                                           limit:kMoreCount    //최대가 100개
                                         reverse:NO
                                     messageType:SBDMessageTypeFilterAll
                                      customType:@""
                               completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
                                   
                                   if (messages.count == 0)
                                   {
                                       if( self.isAskMode && self.isPdfMode && self.str_PdfImageUrl.length > 0 )
                                       {
                                           [self performSelector:@selector(onKeyboardShow) withObject:nil afterDelay:0.3f];
                                           [self addTmpImage];
                                           [self performSelector:@selector(scrollToBottomInterval:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.3f];
                                           self.v_CommentKeyboardAccView.lc_AddWidth.constant = 54.f;
                                       }
                                       else if( self.isAskMode && self.dic_NormalQuestionInfo )
                                       {
                                           [self performSelector:@selector(onKeyboardShow) withObject:nil afterDelay:0.3f];
                                           [self addTmpNormalQuestion];
                                           [self performSelector:@selector(scrollToBottomInterval:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.3f];
                                           self.v_CommentKeyboardAccView.lc_AddWidth.constant = 54.f;
                                       }
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           [self.tbv_List reloadData];
                                           [self.tbv_List layoutIfNeeded];
                                           
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                               
                                               [self.tbv_List reloadData];
                                           });
                                       });
                                       
                                       hasNext = NO;
                                       return ;
                                   }
                                   
                                   [self showEnterRoomMsgIfNeeds];
                                   
                                   if( self.messages.count > 0 )
                                   {
                                       //더보기
                                       if( messages.count > 0 )
                                       {
                                           NSMutableArray *arM = [NSMutableArray arrayWithArray:messages];
                                           
                                           for( NSInteger i = 0; i < arM.count; i++ )
                                           {
                                               SBDBaseMessage *baseMessage = arM[i];
                                               SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
                                               NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                                               NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                               
                                               if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_ENTER"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"enterBotRoom"] )
                                               {
                                                   [self.channel deleteMessage:baseMessage completionHandler:^(SBDError * _Nullable error) {
                                                       
                                                   }];
                                                   
                                                   [arM removeObjectAtIndex:i];
                                               }
                                           }
                                           
                                           [arM addObjectsFromArray:self.messages];
                                           [self.messages removeAllObjects];
                                           self.messages = [NSMutableArray arrayWithArray:arM];
                                       }
                                       
                                       for (SBDBaseMessage *message in messages)
                                       {
                                           if (self.minMessageTimestamp > message.createdAt)
                                           {
                                               self.minMessageTimestamp = message.createdAt;
                                           }
                                       }
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           CGSize contentSizeBefore = self.tbv_List.contentSize;
                                           
                                           [self.tbv_List reloadData];
                                           [self.tbv_List layoutIfNeeded];
                                           
                                           CGSize contentSizeAfter = self.tbv_List.contentSize;
                                           
                                           CGPoint newContentOffset = CGPointMake(0, contentSizeAfter.height - contentSizeBefore.height);
                                           [self.tbv_List setContentOffset:newContentOffset animated:NO];
                                           
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                               [self.tbv_List reloadData];
                                               //                                               [self.tbv_List layoutIfNeeded];
                                           });
                                           
                                           isLoding = NO;
                                       });
                                   }
                                   else
                                   {
                                       //초기 로드
                                       NSMutableArray *arM = [NSMutableArray arrayWithArray:messages];
                                       for( NSInteger i = 0; i < arM.count; i++ )
                                       {
                                           SBDBaseMessage *baseMessage = arM[i];
                                           SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
                                           NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                                           NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                           
                                           if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_ENTER"] ||
                                              [[dic objectForKey_YM:@"type"] isEqualToString:@"enterBotRoom"] )
                                           {
                                               [self.channel deleteMessage:baseMessage completionHandler:^(SBDError * _Nullable error) {
                                                   
                                               }];
                                               
                                               [arM removeObjectAtIndex:i];
                                           }
                                       }
                                       
                                       messages = [NSArray arrayWithArray:arM];
                                       
                                       for (SBDBaseMessage *message in messages)
                                       {
                                           SBDUserMessage *data = (SBDUserMessage *)message;
                                           NSLog(@"data.message : %@", data.message);
                                           NSLog(@"data.customType : %@", data.customType);
                                           NSLog(@"data.data : %@", data.data);
                                           
                                           [self.messages addObject:message];
                                           
                                           if (self.minMessageTimestamp > message.createdAt)
                                           {
                                               self.minMessageTimestamp = message.createdAt;
                                           }
                                       }
                                       
                                       
                                       if( self.isAskMode && self.isPdfMode && self.str_PdfImageUrl.length > 0 )
                                       {
                                           [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
                                           [self addTmpImage];
                                           [self performSelector:@selector(scrollToBottomInterval:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.3f];
                                           self.v_CommentKeyboardAccView.lc_AddWidth.constant = 54.f;
                                       }
                                       else if( self.isAskMode && self.dic_NormalQuestionInfo )
                                       {
                                           [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
                                           [self addTmpNormalQuestion];
                                           self.v_CommentKeyboardAccView.lc_AddWidth.constant = 54.f;
                                       }
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           self.tbv_List.alpha = NO;
                                           
                                           [self.tbv_List reloadData];
                                           [self.tbv_List layoutIfNeeded];
                                           [self performSelector:@selector(scrollToBottomInterval:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.3f];
                                           
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                               
                                               [self.tbv_List reloadData];
                                               //                                               [self.tbv_List layoutIfNeeded];
                                           });
                                           
                                           isLoding = NO;
                                       });
                                   }
                                   
                                   [self saveChattingMessage];
                               }];
}

- (void)addTmpNormalQuestion
{
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSString *str_CreateTime = [NSString stringWithFormat:@"%04ld%02ld%02ld%02d%02d%02d", nYear, nMonth, nDay, nHour, nMinute, nSecond];
    NSDictionary *dic_Temp = @{@"questionId":[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]],
                               //                               @"contents":str_NoEncoding,
                               @"type":@"normalQuestion",
                               @"createDate":str_CreateTime,
                               @"temp":@"YES",
                               @"isDone":@"N",
                               @"obj":self.dic_NormalQuestionInfo,
                               };
    
    NSMutableDictionary *dicM_Tmp = [NSMutableDictionary dictionaryWithDictionary:dic_Temp];
    //    [dicM_Tmp setObject:self.str_ExamTitle forKey:@"examTitle"];
    [self.dicM_TempMyContents setObject:dicM_Tmp forKey:[NSString stringWithFormat:@"%ld", self.messages.count]];
    [self.messages addObject:dicM_Tmp];
}

- (void)addTmpImage
{
    NSArray *ar = [self.str_PdfImageUrl componentsSeparatedByString:@"|"];
    NSData *imageData = [NSData dataWithContentsOfURL:[Util createImageUrl:str_ImagePreFix withFooter:[ar firstObject]]];
    UIImage *image = [UIImage imageWithData:imageData];
    UIImage *resizeImage = [Util imageWithImage:image convertToWidth:self.view.bounds.size.width - 30];
    
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSString *str_CreateTime = [NSString stringWithFormat:@"%04ld%02ld%02ld%02d%02d%02d", nYear, nMonth, nDay, nHour, nMinute, nSecond];
    NSDictionary *dic_Temp = @{@"questionId":[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]],
                               //                               @"contents":str_NoEncoding,
                               @"type":@"pdfQuestion",
                               @"createDate":str_CreateTime,
                               @"temp":@"YES",
                               @"isDone":@"N",
                               @"obj":UIImageJPEGRepresentation(resizeImage, 1.0f),
                               @"qnaBody":self.str_PdfImageUrl,
                               };
    
    NSMutableDictionary *dicM_Tmp = [NSMutableDictionary dictionaryWithDictionary:dic_Temp];
    [dicM_Tmp setObject:self.str_ExamTitle forKey:@"examTitle"];
    [self.dicM_TempMyContents setObject:dicM_Tmp forKey:[NSString stringWithFormat:@"%ld", self.messages.count]];
    [self.messages addObject:dicM_Tmp];
}

- (void)showEnterRoomMsgIfNeeds
{
    if( isShowInRoomMsg )
    {
        NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        NSString *str_EnterMsg = [NSString stringWithFormat:@"%@님이 입장하였습니다", str_UserName];
        [self sendSendBirdPlatformApi:kEnterChat withData:nil withMsg:str_EnterMsg];
        
        isShowInRoomMsg = NO;
    }
}

//- (void)onShowingInterval
//{
//    self.view.hidden = NO;
//}

- (void)sendJoinDelay:(NSString *)aStr
{
    //    [SendBird sendMessage:@"join-chat" withData:aStr];
    //    [SendBird sendMessage:@"join-chat" withData:aStr andTempId:@"" mentionedUserIds:@[@"154"]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.v_CommentKeyboardAccView resignFirstResponder];
    self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
    
    self.navigationController.navigationBarHidden = YES;
    //    self.hidesBottomBarWhenPushed = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [self getNextMessage];
    
    if( self.dic_MoveExamInfo )
    {
        [self didSelectedItem:self.dic_MoveExamInfo];
        self.dic_MoveExamInfo = nil;
    }
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShareExamNoti:) name:@"ShareExamNoti" object:nil];
    
    //    if( self.tm_MessageQ )
    //    {
    //        [self.tm_MessageQ invalidate];
    //        self.tm_MessageQ = nil;
    //    }
    //
    //    self.tm_MessageQ = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onSendMessage) userInfo:nil repeats:YES];
    //    [[NSRunLoop mainRunLoop] addTimer:self.tm_MessageQ forMode:NSRunLoopCommonModes];  //메인스레드에 돌리면 터치를 잡고 있을때 어는 현상이 있어서 스레드 분기시킴
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hide];
    
    [self saveChattingMessage];
    
    self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
    
    //    [self.v_CommentKeyboardAccView.tv_Contents resignFirstResponder];
    [self.view endEditing:YES];
    
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    UIView *view_Tmp = [window viewWithTag:1982];
    [view_Tmp removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:@"ShareExamNoti"
    //                                                  object:nil];
    
    //    [self.tm_MessageQ invalidate];
    //    self.tm_MessageQ = nil;
}

- (void)viewDidLayoutSubviews
{
    //#ifdef DEBUG
    //    self.v_CommentKeyboardAccView.lc_AddWidth.constant = 63.f;
    //#endif
    
    //    if( self.v_CommentKeyboardAccView.tv_Contents.text.length <= 0 )
    //    {
    //        self.v_CommentKeyboardAccView.lc_TfWidth.constant = 63.f;
    //    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)onSendMessage
//{
//    [self.tm_MessageQ invalidate];
//
//    if( self.arM_MessageQ == nil || self.arM_MessageQ.count <= 0 )
//    {
//        self.tm_MessageQ = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onSendMessage) userInfo:nil repeats:YES];
//        [[NSRunLoop mainRunLoop] addTimer:self.tm_MessageQ forMode:NSRunLoopCommonModes];
//        return;
//    }
//
//    NSLog(@"Send Start");
//
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithDictionary:[self.arM_MessageQ firstObject]];
//    NSString *str_Dump = self.v_CommentKeyboardAccView.tv_Contents.text;
//    __weak __typeof(&*self)weakSelf = self;
//
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/add/reply/question/and/view"
//                                        param:dicM_Params
//                                   withMethod:@"POST"
//                                    withBlock:^(id resulte, NSError *error) {
//
//                                        [MBProgressHUD hide];
//
//                                        NSLog(@"Send End");
//
//                                        if( resulte )
//                                        {
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                //전송완료 후 센드버드 메세지 호출
//                                                //새로운 질문
//
//                                                NSInteger nFindIdx = -1;
//                                                for( NSInteger i = self.arM_List.count - 1; i >= 0; i-- )
//                                                {
//                                                    NSDictionary *dic_Tmp = [self.arM_List objectAtIndex:i];
//                                                    if( [[dic_Tmp objectForKey_YM:@"temp"] isEqualToString:@"YES"] )
//                                                    {
//                                                        nFindIdx = i;
//                                                        break;
//                                                    }
//                                                }
//
//                                                if( nFindIdx >= 0 )
//                                                {
//                                                    NSDictionary *dic = @{@"resulte":resulte, @"idx":[NSString stringWithFormat:@"%ld", nFindIdx]};
//                                                    [weakSelf performSelectorOnMainThread:@selector(messageCheckInteval:) withObject:dic waitUntilDone:YES];
//                                                }
//
//
//                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
//                                                                                                             @"eId":[resulte objectForKey:@"qnaId"],
//                                                                                                             @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
//                                                                                                             @"channelUrl":str_ChannelUrl}
//                                                                                                   options:NSJSONWritingPrettyPrinted
//                                                                                                     error:&error];
//                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                                                [SendBird sendMessage:@"regist-qna" withData:jsonString];
//
//
//
//
//                                                //채팅 대시보드 업데이트 관련
//                                                NSMutableDictionary *dicM_Resulte = [NSMutableDictionary dictionaryWithDictionary:resulte];
//                                                [dicM_Resulte setObject:@"text" forKey:@"msgType"];
//                                                [self sendDashboardUpdate:dicM_Resulte];
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                        }
//                                        else
//                                        {
//                                            self.v_CommentKeyboardAccView.tv_Contents.text = str_Dump;
//                                            [self.navigationController.view makeToast:@"메세지 전송을 실패 하였습니다" withPosition:kPositionCenter];
//                                        }
//
//                                        //메세지 큐에 있는 데이터 지우고 그 다음 데이터 호출
//                                        [self.arM_MessageQ removeObjectAtIndex:0];
//
//                                        self.tm_MessageQ = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onSendMessage) userInfo:nil repeats:YES];
//                                        [[NSRunLoop mainRunLoop] addTimer:self.tm_MessageQ forMode:NSRunLoopCommonModes];
//                                        [self.tm_MessageQ fire];
//                                    }];
//}

- (void)saveChattingMessage
{
    NSMutableArray *arM = [NSMutableArray arrayWithCapacity:self.messages.count];
    for( NSInteger i = 0; i < self.messages.count; i++ )
    {
        id message = self.messages[i];
        if( [message isKindOfClass:[SBDBaseMessage class]] == NO )
        {
            [arM addObject:message];
        }
        else
        {
            SBDUserMessage *message = self.messages[i];
            
            NSData *data = [message.data dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if( json )
            {
                [arM addObject:json];
            }
        }
    }
    
    NSString *str_Key = [NSString stringWithFormat:@"Chat_%@", self.str_RId];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arM];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)messageCheckInteval:(NSDictionary *)dic
{
    NSInteger nIdx = [[dic objectForKey:@"idx"] integerValue];
    NSLog(@"nIdx : %ld", nIdx);
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"resulte"]];
    [dicM setObject:@"Y" forKey:@"isDone"];
    [self.arM_List replaceObjectAtIndex:nIdx withObject:dicM];
    //                                                    [self.arM_List addObject:dicM];
    nLastMyIdx = self.arM_List.count - 1;
    [self setMiddleDate];
    
    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dumpLoadQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tbv_List reloadData];
            [self.tbv_List setNeedsLayout];
            
            [self scrollToTheBottom:NO];
        });
    });
    
    
    //    NSInteger lastSectionIndex = [self.tbv_List numberOfSections] - 1;
    //    NSInteger lastItemIndex = [self.tbv_List numberOfRowsInSection:lastSectionIndex] - 1;
    //    NSIndexPath *pathToLastItem = [NSIndexPath indexPathForItem:nIdx inSection:0];
    //    NSArray *array = [NSArray arrayWithObjects:pathToLastItem, nil];
    //
    //    [self.tbv_List beginUpdates];
    //    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.arM_List.count - 1 inSection:0];
    //    [self.tbv_List reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    //    [self.tbv_List endUpdates];
    //
    //    [self.tbv_List setNeedsLayout];
    
    
    //    int64_t delayInSeconds = 0.1f;
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
    //
    //        [self.tbv_List reloadData];
    //    });
    
    //    [self.tbv_List reloadData];
    //    [self.tbv_List setNeedsLayout];
    
    //    NSInteger lastSectionIndex = [self.tbv_List numberOfSections] - 1;
    //    NSInteger lastItemIndex = [self.tbv_List numberOfRowsInSection:lastSectionIndex] - 1;
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:lastItemIndex inSection:lastSectionIndex];
    //    NSArray *array = [NSArray arrayWithObjects:indexPath, nil];
    //
    //    [self.tbv_List beginUpdates];
    ////    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nIdx inSection:0];
    ////    [self.tbv_List reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    //    [self.tbv_List insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    //    [self.tbv_List endUpdates];
    ////
    ////    [self.tbv_List setNeedsLayout];
    
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
            self.v_CommentKeyboardAccView.lc_Bottom.constant = keyboardBounds.size.height;
            //            self.v_CommentKeyboardAccView.lc_AddWidth.constant = 63.f;
            if (self.tbv_List.contentSize.height > self.tbv_List.frame.size.height)
            {
                CGPoint offset = CGPointMake(0, self.tbv_List.contentOffset.y + keyboardBounds.size.height);
                [self.tbv_List setContentOffset:offset animated:NO];
            }
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
            UIView *view_Tmp = [window viewWithTag:1982];
            [view_Tmp removeFromSuperview];
            
            self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
            //            self.v_CommentKeyboardAccView.lc_AddWidth.constant = 0.f;
            //            self.v_CommentKeyboardAccView.tv_Contents.placeholder = @"질문하기...";
            
            //#ifdef DEBUG
            //            self.v_CommentKeyboardAccView.lc_AddWidth.constant = 63.f;
            //#endif
        }
    }completion:^(BOOL finished) {
        
        [self.v_CommentKeyboardAccView updateConstraints];
        [self.v_CommentKeyboardAccView layoutIfNeeded];
        [self.v_CommentKeyboardAccView setNeedsLayout];
        
    }];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self saveChattingMessage];
}

- (void)becomeActiove
{
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//- (void)onShareExamNoti:(NSNotification *)noti
//{
//    [self updateOneShare:noti.object];
//}

- (void)updateTopData
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_RId, @"rId",
                                        nil];
    //http://dev2.thoting.com/api/v1/get/chat/room/header/info?uuid=3FF1C31A-7B8A-48DF-8EDB-ACC7212C85B4&rId=515&apiToken=753a15183f55198a4e85bb10542836a9
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/chat/room/header/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSArray *ar_Tmp = [NSArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                for( NSInteger i = 0; i < ar_Tmp.count; i++ )
                                                {
                                                    NSDictionary *dic = [ar_Tmp objectAtIndex:i];
                                                    [self.arM_User addObject:[dic objectForKey:@"userId"]];
                                                }
                                                
                                                self.dic_Data = [NSDictionary dictionaryWithDictionary:resulte];
                                                
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                
                                                str_ChannelId = [resulte objectForKey_YM:@"channelId"];
                                                
                                                NSString *str_HeaderUrl = [resulte objectForKey_YM:@"userImg_prefix"];
                                                if( str_HeaderUrl.length > 0 )
                                                {
                                                    str_ImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
                                                }
                                                
                                                str_HeaderUrl = [resulte objectForKey_YM:@"image_prefix"];
                                                if( str_HeaderUrl.length > 0 )
                                                {
                                                    str_ImagePreFix = [resulte objectForKey_YM:@"image_prefix"];
                                                }
                                                else
                                                {
                                                    str_ImagePreFix = @"http://data.thoting.com:8282/c_edujm/exam/";
                                                }
                                                
                                                self.lb_Title.text = [resulte objectForKey_YM:@"roomName"];
                                                self.lb_GroupCount.text = @"";
                                                
                                                str_ChatType = [resulte objectForKey:@"roomType"];
                                                if( [str_ChatType isEqualToString:@"group"] )
                                                {
                                                    self.btn_GroupInfo.hidden = NO;
                                                    self.iv_TopUser.hidden = YES;
                                                }
                                                else if( [str_ChatType isEqualToString:@"channel"] )
                                                {
                                                    self.btn_GroupInfo.hidden = YES;
                                                    self.iv_TopUser.hidden = NO;
                                                }
                                                else if( [str_ChatType isEqualToString:@"user"] )
                                                {
                                                    self.btn_GroupInfo.hidden = YES;
                                                    self.iv_TopUser.hidden = NO;
                                                }
                                                
                                                if( [str_ChatType isEqualToString:@"group"] )
                                                {
                                                    self.lb_TotalUserCount.text = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"userCount"]];
                                                    self.iv_TopUser.backgroundColor = self.roomColor ? self.roomColor : [UIColor colorWithHexString:@"9ED8EB"];
                                                }
                                                else if( [str_ChatType isEqualToString:@"channel"] )
                                                {
                                                    self.lb_TotalUserCount.text = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"userCount"]];
                                                    [self.iv_TopUser sd_setImageWithURL:self.channelImageUrl];
                                                }
                                                else if( [str_ChatType isEqualToString:@"user"] )
                                                {
                                                    self.lb_Title.text = [resulte objectForKey_YM:@"userName"];
                                                    [self.iv_TopUser sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix
                                                                                                  withFooter:[resulte objectForKey_YM:@"thumbnail"]] placeholderImage:BundleImage(@"no_image.png")];
                                                }
                                                
                                                dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
                                                dispatch_async(dumpLoadQueue, ^{
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        [self.tbv_List reloadData];
                                                        [self.tbv_List setNeedsLayout];
                                                    });
                                                });
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)updateList:(BOOL)isNew
{
    //    if( isNew )
    //    {
    //        [self.arM_List removeAllObjects];
    ////        [self.tbv_List reloadData];
    //    }
    
    
    if( isLoding )
    {
        NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        return;
    }
    
    isLoding = YES;
    
    isFirstLoad = isNew;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_RId, @"rId",
                                        @"chatQna", @"callWhere",
                                        @"list", @"resultType",
                                        //                                        @"newest", @"orderBy",
                                        nil];
    
    if( isNew )
    {
        //새로 고침
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", kMoreCount] forKey:@"limitCount"];
        [dicM_Params setObject:@"" forKey:@"lastQnaId"];
    }
    else
    {
        //더보기
        if( self.arM_List && self.arM_List.count > 0 )
        {
            NSDictionary *dic_First = nil;
            for( NSInteger i = 0 ; i < self.arM_List.count; i++ )
            {
                NSDictionary *dic = [self.arM_List objectAtIndex:i];
                
                if( [[dic objectForKey_YM:@"type"] isEqualToString:@"date"] )
                {
                    continue;
                }
                else
                {
                    dic_First = dic;
                    break;
                }
            }
            
            if( dic_First == nil )
            {
                return;
            }
            
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", kMoreCount] forKey:@"limitCount"];
            
            NSString *str_EId = [NSString stringWithFormat:@"%@", [dic_First objectForKey_YM:@"eId"]];
            if( [str_EId integerValue] <= 0 )
            {
                return;
            }
            [dicM_Params setObject:[NSString stringWithFormat:@"%@", [dic_First objectForKey_YM:@"eId"]] forKey:@"lastQnaId"]; //questionId
        }//    questionId = 26345;
        else
        {
            [dicM_Params setObject:@"" forKey:@"limitCount"];
            [dicM_Params setObject:@"" forKey:@"lastQnaId"];
        }
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/qna/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        
                                        isFirstLoad = NO;
                                        isLoding = NO;
                                        
                                        if( resulte )
                                        {
                                            nTotalCnt = [[resulte objectForKey:@"qnaCount"] integerValue];
                                            str_ChannelId = [resulte objectForKey_YM:@"channelId"];
                                            
                                            //신규 데이터가 없으면 갱신하지 말기~
                                            if( self.arM_List && self.arM_List.count > 0 )
                                            {
                                                NSMutableArray *arM = [NSMutableArray arrayWithArray:[resulte objectForKey:@"data"]];
                                                NSDictionary *dic_New = [arM lastObject];
                                                NSDictionary *dic_Old = [self.arM_List lastObject];
                                                
                                                if( [[dic_New objectForKey:@"eId"] integerValue] == [[dic_Old objectForKey:@"eId"] integerValue] )
                                                {
                                                    //달라진건 없겠지만 서버에서 받은 신선한 데이터로 교체
                                                    //달라진게 없을때 리로드 안하다가 리로드 해주는걸로 바꿈 왜냐면 중간에 삭제된 데이터가 있을 수 있기 때문
                                                    self.arM_List = [NSMutableArray arrayWithArray:arM];
                                                    
                                                    if( self.arM_TempList.count > 0 )
                                                    {
                                                        [self.arM_List addObjectsFromArray:self.arM_TempList];
                                                        [self.arM_TempList removeAllObjects];
                                                    }
                                                    
                                                    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
                                                    dispatch_async(dumpLoadQueue, ^{
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            [self.tbv_List reloadData];
                                                            [self.tbv_List setNeedsLayout];
                                                        });
                                                    });
                                                    
                                                    return ;
                                                }
                                                //                                                else
                                                //                                                {
                                                //                                                    //마지막 데이터가 다를 경우
                                                //                                                    self.arM_List = [NSMutableArray arrayWithArray:arM];
                                                //
                                                //                                                    if( self.arM_TempList.count > 0 )
                                                //                                                    {
                                                //                                                        [self.arM_List addObjectsFromArray:self.arM_TempList];
                                                //                                                        [self.arM_TempList removeAllObjects];
                                                //                                                    }
                                                //
                                                //                                                    [self.tbv_List reloadData];
                                                //                                                    [self.tbv_List setNeedsLayout];
                                                //                                                }
                                            }
                                            
                                            if( isNew )
                                            {
                                                NSString *str_Key = [NSString stringWithFormat:@"Chat_%@", self.str_RId];
                                                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resulte];
                                                [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_Key];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                [self.arM_List removeAllObjects];
                                            }
                                            
                                            [self updateView:resulte];
                                        }
                                    }];
}

- (void)updateView:(NSDictionary *)resulte
{
    //    str_ChannelId = [resulte objectForKey_YM:@"channelId"];
    
    NSString *str_HeaderUrl = [resulte objectForKey_YM:@"userImg_prefix"];
    if( str_HeaderUrl.length > 0 )
    {
        str_ImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
    }
    
    str_HeaderUrl = [resulte objectForKey_YM:@"image_prefix"];
    if( str_HeaderUrl.length > 0 )
    {
        str_ImagePreFix = [resulte objectForKey_YM:@"image_prefix"];
    }
    
    NSLog(@"resulte : %@", resulte);
    NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
    if( nCode == 200 )
    {
        if( self.arM_List != nil && self.arM_List.count > 0 )
        {
            NSArray *ar_Tmp = [NSArray arrayWithArray:self.arM_List];
            NSMutableArray *arM = [NSMutableArray arrayWithArray:[resulte objectForKey:@"data"]];
            [arM addObjectsFromArray:self.arM_List];
            self.arM_List = [NSMutableArray arrayWithArray:arM];
            [self.arM_List addObjectsFromArray:self.arM_TempList];
            [self.arM_TempList removeAllObjects];
            
            dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(dumpLoadQueue, ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self setMiddleDate];
                    [self.tbv_List reloadData];
                    [self.tbv_List setNeedsLayout];
                    
                    NSInteger nIdx = self.arM_List.count - (ar_Tmp.count + 1);
                    if( nIdx < 0 )
                    {
                        nIdx = 0;
                    }
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nIdx inSection:0];
                    [self.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                });
            });
        }
        else
        {
            self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"data"]];
            [self.arM_List addObjectsFromArray:self.arM_TempList];
            [self.arM_TempList removeAllObjects];
            
            dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(dumpLoadQueue, ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //중간 날짜 데이터 찡겨 넣기
                    [self setMiddleDate];
                    [self.tbv_List reloadData];
                    [self.tbv_List setNeedsLayout];
                    
                    [self scrollToTheBottom:NO];
                });
            });
            
            
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                [self scrollToTheBottom:NO];
            //            });
        }
    }
    else
    {
        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
    }
}

- (void)scrollToTheBottom:(BOOL)animated
{
    if( self.tbv_List.contentSize.height < self.tbv_List.frame.size.height )
    {
        return;
    }
    
    if( self.messages.count > 0 )
    {
        CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
        [self.tbv_List setContentOffset:offset animated:animated];
        
        //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.arM_List.count-1 inSection:0];
        //        [self.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)setMiddleDate
{
    NSInteger nOldDate = 0;
    NSMutableArray *arM_Data = [NSMutableArray array];
    NSMutableArray *arM_Tmp = [NSMutableArray arrayWithArray:self.arM_List];
    
    for( NSInteger i = 0; i < arM_Tmp.count; i++ )
    {
        NSDictionary *dic = [arM_Tmp objectAtIndex:i];
        if( [[dic objectForKey:@"type"] isEqualToString:@"date"] == NO )
        {
            [arM_Data addObject:dic];
        }
    }
    
    self.arM_List = [NSMutableArray arrayWithArray:arM_Data];
    [arM_Data removeAllObjects];
    arM_Tmp = [NSMutableArray arrayWithArray:self.arM_List];
    
    for( NSInteger i = 0; i < arM_Tmp.count; i++ )
    {
        NSDictionary *dic = arM_Tmp[i];
        NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]];
        if( str_Date.length >= 8 )
        {
            str_Date = [str_Date substringWithRange:NSMakeRange(0, 8)];
            NSInteger nCreateDate = [str_Date integerValue];
            
            NSDate *date = [NSDate date];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
            NSInteger nYear = [components year];
            NSInteger nMonth = [components month];
            NSInteger nDay = [components day];
            NSString *str_CurrentDay = [NSString stringWithFormat:@"%04ld%02ld%02ld", nYear, nMonth, nDay];
            
            NSInteger nCurrentDay = [str_CurrentDay integerValue];
            
            if( nOldDate < nCreateDate )
            {
                nOldDate = nCreateDate;
                
                NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]];
                NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
                NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
                NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
                NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
                NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
                str_Date = [NSString stringWithFormat:@"%04ld.%ld.%ld %@ %ld:%02ld",
                            [str_Year integerValue], [str_Month integerValue], [str_Day integerValue],
                            [str_Hour integerValue] > 12 ? @"오후" : @"오전",
                            ([str_Hour integerValue] > 12) ? [str_Hour integerValue] - 12 : [str_Hour integerValue] == 0 ? 12 : [str_Hour integerValue], [str_Minute integerValue]];
                
                [arM_Data addObject:@{@"type":@"date", @"contents":str_Date}];
                //                                                        [self.arM_List insertObject:@{@"type":@"date", @"contents":str_Date} atIndex:i + nCnt];
            }
        }
        
        [arM_Data addObject:dic];
    }
    
    self.arM_List = arM_Data;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( scrollView == self.tbv_List )
    {
        if (scrollView.contentOffset.y == 0)
        {
            //            if (self.messages.count > 0 && self.initialLoading == NO)
            if (self.messages.count > 0 && hasNext == YES )
            {
                [self updateChatList:NO];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView.contentOffset.y <= 0 && isLoding == NO && self.messages.count > 0 )
    {
        //up
        //        if( nTotalCnt > 0 && self.arM_List.count >= nTotalCnt )
        //        {
        //            return;
        //        }
        
        [self updateChatList:NO];
        //        [self updateList:NO];
    }
}

- (void)addTapGesture:(UIView *)view
{
    UITapGestureRecognizer *chatTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatTap:)];
    [chatTap setNumberOfTapsRequired:1];
    [view addGestureRecognizer:chatTap];
}



#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}




#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_List )
    {
        NSMutableArray *arM_Tmp = [NSMutableArray arrayWithArray:self.messages];
        for( id message in arM_Tmp )
        {
            if( [message isKindOfClass:[NSDictionary class]] )
            {
                if( [[message objectForKey_YM:@"type"] isEqualToString:@"USER_ENTER"] ||
                   [[message objectForKey_YM:@"type"] isEqualToString:@"enterBotRoom"] )
                {
                    [self.messages removeObject:message];
                }
            }
            else if( [message isKindOfClass:[SBDBaseMessage class]] )
            {
                SBDBaseMessage *baseMessage = message;
                SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_ENTER"] ||
                   [[dic objectForKey_YM:@"type"] isEqualToString:@"enterBotRoom"] )
                {
                    [self.messages removeObject:message];
                }
            }
        }
        
        return self.messages.count;
    }
    
    return self.arM_AutoAnswer.count;
    
    //    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_List )
    {
        id message = self.messages[indexPath.row];
        
        NSDictionary *dic = nil;
        if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDBaseMessage *baseMessage = self.messages[indexPath.row];
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_JOIN"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_LEFT"] )
            {
                //조인
                CmdChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CmdChatCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self cmdCell:cell forRowAtIndexPath:indexPath];
                [self addTapGesture:cell];
                return cell;
            }
            
            if( [userMessage.customType isEqualToString:@"cmd"] )
            {
                CmdChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CmdChatCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self cmdCell:cell forRowAtIndexPath:indexPath];
                [self addTapGesture:cell];
                return cell;
            }
        }
        else
        {
            dic = message;
            
            if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_JOIN"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_LEFT"] )
            {
                //조인
                CmdChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CmdChatCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self cmdCell:cell forRowAtIndexPath:indexPath];
                [self addTapGesture:cell];
                return cell;
            }
        }
        
        if( dic == nil )
        {
            MyChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            return cell;
        }
        
        //    NSDictionary *dic = self.arM_List[indexPath.row];
        
        //글 타입 여부 (채널, direct)
        BOOL isChannelType = [[dic objectForKey:@"qnaType"] isEqualToString:@"channel"];
        //내 글인지 여부
        
        if( [[dic objectForKey:@"type"] isEqualToString:@"date"] )
        {
            CmdChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CmdChatCell"];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            cell.v_Bg.backgroundColor = [UIColor clearColor];
            cell.lb_Cmd.text = [dic objectForKey:@"contents"];
            
            [self addTapGesture:cell];
            
            return cell;
        }
        
        //템프 글 (내 글 바로 붙인거)
        if( [[dic objectForKey_YM:@"temp"] isEqualToString:@"YES"] )
        {
            if( [[dic objectForKey:@"type"] isEqualToString:@"text"] )
            {
                MyChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                //        cell.contentView.backgroundColor = [UIColor redColor];
                //        cell.lb_Contents.textColor = [UIColor blackColor];
                //        cell.lb_Contents.backgroundColor = [UIColor blueColor];
                
                cell.tag = indexPath.row;
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                [cell addGestureRecognizer:longPress];
                
                [self addTapGesture:cell];
                
                [self myTextCellTemp:cell forRowAtIndexPath:indexPath];
                
                return cell;
            }
            else if( [[dic objectForKey:@"type"] isEqualToString:@"image"] )
                //        else if( [[dic objectForKey:@"type"] isEqualToString:@"image"] )
            {
                MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyImageCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                cell.tag = cell.btn_Origin.tag = indexPath.row;
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                [cell addGestureRecognizer:longPress];
                
                cell.btn_Origin.hidden = YES;
                [cell.btn_Origin setTitle:@"" forState:UIControlStateNormal];
                
                cell.btn_Read.hidden = NO;
                cell.lb_Date.hidden = NO;
                
                [self hidenDateIfNeed:cell indexPath:indexPath];
                
                cell.btn_Read.selected = NO;
                
                cell.v_Video.hidden = YES;
                
                NSData *data = [NSData dataWithData:[dic objectForKey:@"obj"]];
                cell.iv_Contents.image = [UIImage imageWithData:data];
                
                cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
                
                if( [[dic objectForKey_YM:@"isFail"] isEqualToString:@"YES"] )
                {
                    [cell.btn_Read setImage:BundleImage(@"chat_check_fail.png") forState:UIControlStateNormal];
                }
                else
                {
                    [cell.btn_Read setImage:BundleImage(@"chat_no_check.png") forState:UIControlStateNormal];
                }
                
                [cell.btn_Origin removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                
                if( [[dic objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
                {
                    cell.btn_Read.hidden = YES;
                    cell.lb_Date.hidden = YES;
                    
                    cell.btn_Origin.hidden = NO;
                    [cell.btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic objectForKey_YM:@"examTitle"]] forState:UIControlStateNormal];
                    [cell.btn_Origin addTarget:self action:@selector(onMoveToPdf:) forControlEvents:UIControlEventTouchUpInside];
                }
                
                return cell;
            }
            else if( [[dic objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
            {
                NormalQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalQuestionCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                [self pdfQuestionCell:cell forRowAtIndexPath:indexPath withMy:YES];
                
                return cell;
            }
            else if( [[dic objectForKey:@"type"] isEqualToString:@"normalQuestion"] )
            {
                NormalQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalQuestionCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                [self normalQuestionCell:cell forRowAtIndexPath:indexPath withMy:YES];
                
                return cell;
            }
            else if( [[dic objectForKey:@"type"] isEqualToString:@"video"] )
            {
                MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyImageCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                cell.tag = indexPath.row;
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                [cell addGestureRecognizer:longPress];
                
                cell.btn_Read.selected = NO;
                
                cell.v_Video.hidden = NO;
                
                NSData *data = [NSData dataWithData:[dic objectForKey:@"obj"]];
                cell.iv_Contents.image = [UIImage imageWithData:data];
                
                cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
                
                if( [[dic objectForKey_YM:@"isFail"] isEqualToString:@"YES"] )
                {
                    [cell.btn_Read setImage:BundleImage(@"chat_check_fail.png") forState:UIControlStateNormal];
                }
                else
                {
                    [cell.btn_Read setImage:BundleImage(@"chat_no_check.png") forState:UIControlStateNormal];
                }
                
                return cell;
            }
        }
        
        
        NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
        NSInteger nTargetId = [[dic objectForKey_YM:@"userId"] integerValue];
        BOOL isMy = nMyId == nTargetId;
        
        if( isMy )
        {
            if( 1 )
            {
                NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
                if( ar_Body && ar_Body.count > 0 )
                {
                    NSDictionary *dic_Body = [ar_Body firstObject];
                    
                    if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"image"] )
                    {
                        MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyImageCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        cell.tag = indexPath.row;
                        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                        [cell addGestureRecognizer:longPress];
                        
                        cell.btn_Origin.hidden = YES;
                        [cell.btn_Origin setTitle:@"" forState:UIControlStateNormal];
                        
                        cell.btn_Read.hidden = NO;
                        cell.lb_Date.hidden = NO;
                        
                        [self myImageCell:cell forRowAtIndexPath:indexPath withVideo:NO];
                        return cell;
                    }
                    else if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"pdfQuestion"] )
                    {
                        NormalQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalQuestionCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        [self pdfQuestionCell:cell forRowAtIndexPath:indexPath withMy:YES];
                        
                        return cell;
                    }
                    else if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"video"] )
                    {
                        MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyImageCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        cell.tag = indexPath.row;
                        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                        [cell addGestureRecognizer:longPress];
                        
                        [self myImageCell:cell forRowAtIndexPath:indexPath withVideo:YES];
                        return cell;
                    }
                    else if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"normalQuestion"] )
                    {
                        NormalQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalQuestionCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        [self normalQuestionCell:cell forRowAtIndexPath:indexPath withMy:YES];
                        
                        return cell;
                    }
                    else
                    {
                        if( [[dic objectForKey_YM:@"itemType"] isEqualToString:@"cmd"] )
                        {
                            CmdChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CmdChatCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            [self cmdCell:cell forRowAtIndexPath:indexPath];
                            [self addTapGesture:cell];
                            return cell;
                        }
                        else
                        {
                            MyChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self myTextCell:cell forRowAtIndexPath:indexPath];
                            
                            //                            [self addTapGesture:cell];
                            
                            return cell;
                        }
                    }
                }
                else
                {
                    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
                    NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
                    NSString *str_MsgType = [dic_ActionMap objectForKey:@"msgType"];
                    
                    if( [str_MsgType isEqualToString:@"shareExam"] )
                    {
                        if( str_ShareMsg.length > 0 )
                        {
                            //공유한 메세지가 있으면
                            MyShareExamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyShareExamCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self myShareExamCell:cell forRowAtIndexPath:indexPath];
                            return cell;
                        }
                        else
                        {
                            MyShareExamNoMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyShareExamNoMsgCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self myShareExamNoMsgCell:cell forRowAtIndexPath:indexPath];
                            return cell;
                        }
                    }
                    else if( [str_MsgType isEqualToString:@"shareQuestion"] )
                    {
                        if( str_ShareMsg.length > 0 )
                        {
                            //공유한 내용이 있으면
                            MyDirectChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyDirectChatMsgCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self myDirectMsgCell:cell forRowAtIndexPath:indexPath];
                            
                            //                    [self addTapGesture:cell];
                            
                            return cell;
                        }
                        else
                        {
                            //공유한 내용이 없으면
                            MyDirectChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyDirectChatCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self myDirectCell:cell forRowAtIndexPath:indexPath];
                            
                            //                    [self addTapGesture:cell];
                            
                            return cell;
                        }
                    }
                    else if( [str_MsgType isEqualToString:@"channel-follow"] || [str_MsgType isEqualToString:@"regist-member"] )
                    {
                        MyCmdFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCmdFollowingCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        [self myFollowingCell:cell forRowAtIndexPath:indexPath];
                        return cell;
                    }
                    else if( [str_MsgType isEqualToString:@"directQNA"] )
                    {
                        //내가 쓴 다이렉트 질문
                        MyDirectChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyDirectChatMsgCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        cell.tag = indexPath.row;
                        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                        [cell addGestureRecognizer:longPress];
                        
                        [self myDirectMsgCell:cell forRowAtIndexPath:indexPath];
                        
                        //                    [self addTapGesture:cell];
                        
                        return cell;
                    }
                }
            }
            else
            {
                
            }
        }
        else
        {
            if( 1 )
            {
                NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
                if( ar_Body && ar_Body.count > 0 )
                {
                    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
                    //                NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
                    
                    NSDictionary *dic_Body = [ar_Body firstObject];
                    //                NSString *str_MsgType = [dic_Body objectForKey:@"msgType"];
                    
                    if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"image"] )
                    {
                        OtherImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherImageCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        cell.tag = indexPath.row;
                        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                        [cell addGestureRecognizer:longPress];
                        
                        cell.btn_Origin.hidden = YES;
                        [cell.btn_Origin setTitle:@"" forState:UIControlStateNormal];
                        
                        cell.btn_Read.hidden = NO;
                        cell.lb_Date.hidden = NO;
                        
                        [self otherImageCell:cell forRowAtIndexPath:indexPath withVideo:NO];
                        return cell;
                    }
                    else if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"pdfQuestion"] )
                    {
                        NormalQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalQuestionCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        [self pdfQuestionCell:cell forRowAtIndexPath:indexPath withMy:NO];
                        
                        return cell;
                    }
                    else if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"video"] )
                    {
                        OtherImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherImageCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        cell.tag = indexPath.row;
                        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                        [cell addGestureRecognizer:longPress];
                        
                        [self otherImageCell:cell forRowAtIndexPath:indexPath withVideo:YES];
                        return cell;
                    }
                    else if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"normalQuestion"] )
                    {
                        NormalQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalQuestionCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        [self normalQuestionCell:cell forRowAtIndexPath:indexPath withMy:NO];
                        
                        return cell;
                    }
                    else
                    {
                        if( [[dic objectForKey_YM:@"itemType"] isEqualToString:@"cmd"] )
                        {
                            CmdChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CmdChatCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            [self cmdCell:cell forRowAtIndexPath:indexPath];
                            [self addTapGesture:cell];
                            return cell;
                        }
                        else
                        {
                            id message = self.messages[indexPath.row];
                            
                            if( [message isKindOfClass:[SBDBaseMessage class]] )
                            {
                                SBDBaseMessage *baseMessage = self.messages[indexPath.row];
                                SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
                                
                                if( [userMessage.customType isEqualToString:@"audio"] )
                                {
                                    AutoChatAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutoChatAudioCell"];
                                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                    
                                    NSURL *url = [Util createImageUrl:[dic_Body objectForKey:@"image_prefix"] withFooter:[dic_Body objectForKey:@"qnaBody"]];
                                    
                                    //                                    aaaaaa
                                    NSString *str_Key = [NSString stringWithFormat:@"%ld", indexPath.row];
                                    NSDictionary *dic_PlayerData = [self.dicM_AutoAudio objectForKey:str_Key];
                                    AVPlayer *player = [dic_PlayerData objectForKey:@"player"];
                                    if( player == nil )
                                    {
                                        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                                        player = [AVPlayer playerWithPlayerItem:playerItem];
                                        player = [AVPlayer playerWithURL:url];
                                        
                                        CGFloat fDuration = CMTimeGetSeconds(playerItem.asset.duration);
                                        NSLog(@"%f", fDuration);
                                        
                                        cell.lb_Time.text = @"00:00";
                                        
                                        __weak AutoChatAudioCell *weakCell = cell;
                                        [cell.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2)
                                                                                  queue:dispatch_get_main_queue()
                                                                             usingBlock:^(CMTime time)
                                         {
                                             CGFloat fCurrentTime = CMTimeGetSeconds(time);
                                             NSInteger nMinute = (NSInteger)fCurrentTime / 60;
                                             NSInteger nSecond = (NSInteger)fCurrentTime % 60;
                                             weakCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                             
                                             NSLog(@"%f", CMTimeGetSeconds(time));
                                         }];
                                        
                                        [self.dicM_AutoAudio setObject:@{@"cell":cell, @"player":player} forKey:str_Key];
                                    }
                                    else
                                    {
                                        if ((player.rate != 0) && (player.error == nil))
                                        {
                                            cell.btn_PlayPause.selected = YES;
                                        }
                                        else
                                        {
                                            cell.btn_PlayPause.selected = NO;
                                        }
                                    }
                                    
                                    cell.player = player;
                                    
                                    cell.tag = cell.btn_PlayPause.tag = cell.btn_Replay.tag = indexPath.row;
                                    [cell.btn_PlayPause addTarget:self action:@selector(onAutoAudioPlayAndPause:) forControlEvents:UIControlEventTouchUpInside];
                                    [cell.btn_Replay addTarget:self action:@selector(onAutoAudioReplay:) forControlEvents:UIControlEventTouchUpInside];
                                    
                                    return cell;
                                }
                                else if( [userMessage.customType isEqualToString:@"image"] )
                                {
                                    OtherImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherImageCell"];
                                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                    
                                    cell.tag = indexPath.row;
                                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                                    [cell addGestureRecognizer:longPress];
                                    
                                    cell.btn_Origin.hidden = YES;
                                    [cell.btn_Origin setTitle:@"" forState:UIControlStateNormal];
                                    
                                    cell.btn_Read.hidden = NO;
                                    cell.lb_Date.hidden = NO;
                                    
                                    [self otherImageCell:cell forRowAtIndexPath:indexPath withVideo:NO];
                                    return cell;
                                }
                            }
                            
                            OtherChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherChatBasicCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self otherTextCell:cell forRowAtIndexPath:indexPath];
                            //                            [self addTapGesture:cell];
                            
                            return cell;
                        }
                    }
                }
                else
                {
                    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
                    NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
                    NSString *str_MsgType = [dic_ActionMap objectForKey:@"msgType"];
                    if( [str_MsgType isEqualToString:@"shareExam"] )
                    {
                        if( str_ShareMsg.length > 0 )
                        {
                            OtherShareExamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherShareExamCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self otherShareExamCell:cell forRowAtIndexPath:indexPath];
                            return cell;
                        }
                        else
                        {
                            OtherShareExamNoMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherShareExamNoMsgCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self otherShareExamNoMsgCell:cell forRowAtIndexPath:indexPath];
                            return cell;
                        }
                    }
                    else if( [str_MsgType isEqualToString:@"channel-follow"] || [str_MsgType isEqualToString:@"regist-member"] )
                    {
                        OtherCmdFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCmdFollowingCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        [self otherFollowingCell:cell forRowAtIndexPath:indexPath];
                        return cell;
                    }
                    else if( [str_MsgType isEqualToString:@"shareQuestion"] )
                    {
                        if( str_ShareMsg.length > 0 )
                        {
                            OtherDirectChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherDirectChatMsgCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self otherDirectMsgCell:cell forRowAtIndexPath:indexPath];
                            //                    [self addTapGesture:cell];
                            
                            return cell;
                        }
                        else
                        {
                            OtherDirectChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherDirectChatCell"];
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];
                            
                            cell.tag = indexPath.row;
                            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                            [cell addGestureRecognizer:longPress];
                            
                            [self otherDirectCell:cell forRowAtIndexPath:indexPath];
                            //                    [self addTapGesture:cell];
                            
                            return cell;
                        }
                    }
                    else if( [str_MsgType isEqualToString:@"directQNA"] )
                    {
                        //남이 쓴 다이렉트 질문일 경우
                        OtherDirectChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherDirectChatMsgCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        cell.tag = indexPath.row;
                        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                        [cell addGestureRecognizer:longPress];
                        
                        [self otherDirectMsgCell:cell forRowAtIndexPath:indexPath];
                        //                    [self addTapGesture:cell];
                        
                        return cell;
                    }
                    else
                    {
                        MyChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        
                        return cell;
                    }
                }
            }
            else
            {
                
            }
        }
    }
    else
    {
        AutoAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutoAnswerCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AutoAnswerCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        [self autoAnswerSetData:cell forRowAtIndexPath:indexPath];
        
        if( indexPath.row == nAutoAnswerIdx )
        {
            cell.lb_Title.textColor = [UIColor whiteColor];
            cell.v_Bg.backgroundColor = [UIColor colorWithHexString:@"#343B57"];
        }
        else
        {
            cell.lb_Title.textColor = [UIColor colorWithHexString:@"#343B57"];
            cell.v_Bg.backgroundColor = [UIColor whiteColor];
        }
        
        return cell;
    }
    
    return nil;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( tableView == self.tbv_List )
    {
        id message = self.messages[indexPath.row];
        if( [message isKindOfClass:[SBDBaseMessage class]] == NO )
        {
            return;
        }
        
        //구매했고 문제집 공유일 경우는 문제집 시작 페이지로
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        [self didSelectedItem:dic];
    }
    else
    {
        nAutoAnswerIdx = indexPath.row;
        
        NSDictionary *dic = self.arM_AutoAnswer[indexPath.row];
        NSString *str_AutoAnswer = @"";
        if( self.autoChatMode == kPrintExam )
        {
            str_AutoAnswer = [dic objectForKey:@"examTitle"];
            
            self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = NO;
            [self performSelector:@selector(onKeyboardDownInterval) withObject:nil afterDelay:0.3f];
        }
        else if( self.autoChatMode == kPrintItem )
        {
            str_AutoAnswer = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"itemNo"], [dic objectForKey:@"itemBody"]];
            
            self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = NO;
            [self performSelector:@selector(onKeyboardDownInterval) withObject:nil afterDelay:0.3f];
        }
        else if( self.autoChatMode == kPrintAnswer || self.autoChatMode == kNextExam || self.autoChatMode == kPrintContinue )
        {
            str_AutoAnswer = [dic objectForKey:@"title"];
            self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = YES;
            [self performSelector:@selector(onKeyboardShowInterval) withObject:nil afterDelay:0.3f];
        }
        
        self.v_CommentKeyboardAccView.tv_Contents.text = str_AutoAnswer;
        
        [self goSendMsg:nil];
        [tableView reloadData];
    }
}

- (void)onAutoAudioPlayAndPause:(UIButton *)btn
{
    NSString *str_Key = [NSString stringWithFormat:@"%ld", btn.tag];
    NSDictionary *dic_PlayerData = [self.dicM_AutoAudio objectForKey:str_Key];
    //    AVPlayer *player = [dic_PlayerData objectForKey:@"player"];
    
    AutoChatAudioCell *cell = [dic_PlayerData objectForKey:@"cell"];
    if ((cell.player.rate != 0) && (cell.player.error == nil))
    {
        [cell.player pause];
    }
    else
    {
//        id observer = [dic_PlayerData objectForKey:@"observer"];

        [cell.player play];
    }
    
    btn.selected = !btn.selected;
}

- (void)onAutoAudioReplay:(UIButton *)btn
{
    NSString *str_Key = [NSString stringWithFormat:@"%ld", btn.tag];
    NSDictionary *dic_PlayerData = [self.dicM_AutoAudio objectForKey:str_Key];
    //    AVPlayer *player = [dic_PlayerData objectForKey:@"player"];
    
    AutoChatAudioCell *cell = [dic_PlayerData objectForKey:@"cell"];
    if ((cell.player.rate != 0) && (cell.player.error == nil))
    {
        [cell.player seekToTime:CMTimeMake(0, 1)];
        [cell.player play];
    }
}

- (void)onKeyboardShowInterval
{
    [self showTempleteKeyboard];
}

- (void)onKeyboardDownInterval
{
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    __block UIView *view = [window viewWithTag:1982];
    //    __block UITableView *tbv = [view viewWithTag:1983];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        view.frame = CGRectMake(0, self.view.frame.size.height, view.frame.size.width, view.frame.size.height);
    }];
    
    [self.v_CommentKeyboardAccView.tv_Contents resignFirstResponder];
    nAutoAnswerIdx = -1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_List )
    {
        id message = self.messages[indexPath.row];
        
        NSDictionary *dic = nil;
        if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDBaseMessage *baseMessage = self.messages[indexPath.row];
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        else
        {
            dic = message;
        }
        
        if( [[dic objectForKey_YM:@"itemType"] isEqualToString:@"cmd"] || [[dic objectForKey:@"type"] isEqualToString:@"date"] )
        {
            return 44.f;
        }
        
        if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_JOIN"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_LEFT"] )
        {
            //조인
            return 44.f;
        }
        else if( [[dic objectForKey_YM:@"temp"] isEqualToString:@"YES"] )
        {
            if( [[dic objectForKey_YM:@"type"] isEqualToString:@"text"] )
            {
                self.c_MyChatBasicCell.lb_Contents.text = [dic objectForKey_YM:@"contents"];
                CGFloat fHeight = [Util getTextSize2:self.c_MyChatBasicCell.lb_Contents].height;
                //            NSLog(@"fHeight : %f", fHeight);
                
                [self.c_MyChatBasicCell updateConstraintsIfNeeded];
                [self.c_MyChatBasicCell layoutIfNeeded];
                
                self.c_MyChatBasicCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyChatBasicCell.bounds));
                
                //            NSLog(@"cell height : %f", fHeight + 30.f);
                return fHeight + 30.f;
                
                //            [self myTextCellTemp:self.c_MyChatBasicCell forRowAtIndexPath:indexPath];
                //
                //            [self.c_MyChatBasicCell updateConstraintsIfNeeded];
                //            [self.c_MyChatBasicCell layoutIfNeeded];
                //
                //            self.c_MyChatBasicCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyChatBasicCell.bounds));
                //
                //            return self.c_MyChatBasicCell.bounds.size.height;
                
                //            return [self.c_MyChatBasicCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            }
            else if( [[dic objectForKey_YM:@"type"] isEqualToString:@"image"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"video"] )
            {
                return 420.f;
            }
            else if( [[dic objectForKey_YM:@"type"] isEqualToString:@"pdfQuestion"] )
            {
                [self pdfQuestionCell:self.c_NormalQuestionCell forRowAtIndexPath:indexPath withMy:YES];
                return self.c_NormalQuestionCell.sv_Contents.contentSize.height;
                //            NSString *str_Url = [dic objectForKey:@"url"];
                //            NSArray *ar_Urls = [str_Url componentsSeparatedByString:@"|"];
                //            return ar_Urls.count * 420.f;
            }
            else if( [[dic objectForKey_YM:@"type"] isEqualToString:@"normalQuestion"] )
            {
                [self normalQuestionCell:self.c_NormalQuestionCell forRowAtIndexPath:indexPath withMy:YES];
                return self.c_NormalQuestionCell.sv_Contents.contentSize.height;
            }
        }
        
        //글 타입 여부 (채널, direct)
        BOOL isChannelType = [[dic objectForKey:@"qnaType"] isEqualToString:@"channel"];
        
        //내 글인지 여부
        NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
        NSInteger nTargetId = [[dic objectForKey_YM:@"userId"] integerValue];
        BOOL isMy = nMyId == nTargetId;
        
        if( isMy )
        {
            if( 1 )
            {
                NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
                if( ar_Body && ar_Body.count > 0 )  //텍스트, 이미지, 동영상, 초대, 나감등 일반 메세지
                {
                    NSDictionary *dic_Body = [ar_Body firstObject];
                    NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
                    
                    if( [str_QnaType isEqualToString:@"text"] )
                    {
                        [self myTextCell:self.c_MyChatBasicCell forRowAtIndexPath:indexPath];
                        
                        [self.c_MyChatBasicCell updateConstraintsIfNeeded];
                        [self.c_MyChatBasicCell layoutIfNeeded];
                        
                        self.c_MyChatBasicCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyChatBasicCell.bounds));
                        
                        //                        NSLog(@"c_MyChatBasicCell height : %f", [self.c_MyChatBasicCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                        //138, 228
                        
                        //                    CGSize size = [Util getTextSize:self.c_MyChatBasicCell.lb_Contents.text];
                        CGRect rect = [self.c_MyChatBasicCell.lb_Contents.attributedText boundingRectWithSize:CGSizeMake(self.c_MyChatBasicCell.lb_Contents.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine context:nil];
                        
                        NSLog(@"text hieght : %f", rect.size.height);
                        NSLog(@"c_MyChatBasicCell height : %f", [self.c_MyChatBasicCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                        
                        return [self.c_MyChatBasicCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    }
                    else if( [str_QnaType isEqualToString:@"image"] || [str_QnaType isEqualToString:@"video"] )
                    {
                        return 420.f;
                    }
                    else if( [str_QnaType isEqualToString:@"pdfQuestion"] )
                    {
                        [self pdfQuestionCell:self.c_NormalQuestionCell forRowAtIndexPath:indexPath withMy:YES];
                        return self.c_NormalQuestionCell.sv_Contents.contentSize.height;
                        
                        //                    NSString *str_Body = [dic_Body objectForKey:@"qnaBody"];
                        //                    NSArray *ar_Bodys = [str_Body componentsSeparatedByString:@"|"];
                        //
                        //                    return ar_Bodys.count * 420.f;
                        //                    return 420.f;
                    }
                    else if( [str_QnaType isEqualToString:@"normalQuestion"] )
                    {
                        [self normalQuestionCell:self.c_NormalQuestionCell forRowAtIndexPath:indexPath withMy:YES];
                        return self.c_NormalQuestionCell.sv_Contents.contentSize.height;
                    }
                }
                else
                {
                    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
                    NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
                    NSString *str_MsgType = [dic_ActionMap objectForKey:@"msgType"];
                    if( [str_MsgType isEqualToString:@"shareExam"] )
                    {
                        if( str_ShareMsg.length > 0 )
                        {
                            [self myShareExamCell:self.c_MyShareExamCell forRowAtIndexPath:indexPath];
                            
                            [self.c_MyShareExamCell updateConstraintsIfNeeded];
                            [self.c_MyShareExamCell layoutIfNeeded];
                            
                            self.c_MyShareExamCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyShareExamCell.bounds));
                            
                            //                        return self.c_MyShareExamCell.bounds.size.height;
                            
                            //                        NSLog(@"cell height : %f", [self.c_MyShareExamCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                            
                            return [self.c_MyShareExamCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        }
                        else
                        {
                            [self myShareExamNoMsgCell:self.c_MyShareExamNoMsgCell forRowAtIndexPath:indexPath];
                            
                            [self.c_MyShareExamNoMsgCell updateConstraintsIfNeeded];
                            [self.c_MyShareExamNoMsgCell layoutIfNeeded];
                            
                            self.c_MyShareExamNoMsgCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyShareExamNoMsgCell.bounds));
                            
                            //                        NSLog(@"cell height : %f", [self.c_MyShareExamNoMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                            
                            return [self.c_MyShareExamNoMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        }
                    }
                    else if( [str_MsgType isEqualToString:@"shareQuestion"] )
                    {
                        if( str_ShareMsg.length > 0 )
                        {
                            [self myDirectMsgCell:self.c_MyDirectChatMsgCell forRowAtIndexPath:indexPath];
                            
                            [self.c_MyDirectChatMsgCell updateConstraintsIfNeeded];
                            [self.c_MyDirectChatMsgCell layoutIfNeeded];
                            
                            self.c_MyDirectChatMsgCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyDirectChatMsgCell.bounds));
                            
                            //                        NSLog(@"c_MyDirectChatMsgCell height : %f", [self.c_MyDirectChatMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                            
                            return [self.c_MyDirectChatMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        }
                        else
                        {
                            [self myDirectCell:self.c_MyDirectChatCell forRowAtIndexPath:indexPath];
                            
                            [self.c_MyDirectChatCell updateConstraintsIfNeeded];
                            [self.c_MyDirectChatCell layoutIfNeeded];
                            
                            self.c_MyDirectChatCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyDirectChatCell.bounds));
                            
                            //                        NSLog(@"cell height : %f", [self.c_MyDirectChatCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                            
                            return [self.c_MyDirectChatCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        }
                    }
                    else if( [str_MsgType isEqualToString:@"channel-follow"] || [str_MsgType isEqualToString:@"regist-member"] )
                    {
                        [self myFollowingCell:self.c_MyCmdFollowingCell forRowAtIndexPath:indexPath];
                        
                        [self.c_MyCmdFollowingCell updateConstraintsIfNeeded];
                        [self.c_MyCmdFollowingCell layoutIfNeeded];
                        
                        self.c_MyCmdFollowingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyCmdFollowingCell.bounds));
                        
                        //                    NSLog(@"c_MyCmdFollowingCell height : %f", [self.c_MyCmdFollowingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                        
                        return [self.c_MyCmdFollowingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    }
                    else if( [str_MsgType isEqualToString:@"directQNA"] )
                    {
                        //내가 쓴 다이렉트 질문
                        [self myDirectMsgCell:self.c_MyDirectChatMsgCell forRowAtIndexPath:indexPath];
                        
                        [self.c_MyDirectChatMsgCell updateConstraintsIfNeeded];
                        [self.c_MyDirectChatMsgCell layoutIfNeeded];
                        
                        self.c_MyDirectChatMsgCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyDirectChatMsgCell.bounds));
                        
                        //                    NSLog(@"c_MyDirectChatMsgCell height : %f", [self.c_MyDirectChatMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                        
                        return [self.c_MyDirectChatMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    }
                }
            }
            else
            {
                NSLog(@"000000000000000");
            }
        }
        else
        {
            if( 1 )
            {
                NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
                if( ar_Body && ar_Body.count > 0 )
                {
                    NSDictionary *dic_Body = [ar_Body firstObject];
                    NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
                    
                    if( [str_QnaType isEqualToString:@"text"] )
                    {
                        id message = self.messages[indexPath.row];
                        
                        NSDictionary *dic = nil;
                        if( [message isKindOfClass:[SBDBaseMessage class]] )
                        {
                            SBDBaseMessage *baseMessage = self.messages[indexPath.row];
                            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
                            
                            if( [userMessage.customType isEqualToString:@"audio"] )
                            {
                                return 60.f;
                            }
                            else if( [userMessage.customType isEqualToString:@"image"] )
                            {
                                return 420.f;
                            }
                        }
                        
                        [self otherTextCell:self.c_OtherChatBasicCell forRowAtIndexPath:indexPath];
                        
                        [self.c_OtherChatBasicCell updateConstraintsIfNeeded];
                        [self.c_OtherChatBasicCell layoutIfNeeded];
                        
                        self.c_OtherChatBasicCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_OtherChatBasicCell.bounds));
                        
                        //                        NSLog(@"cell height : %f", [self.c_OtherCmdFollowingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                        
                        return [self.c_OtherChatBasicCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    }
                    else if( [str_QnaType isEqualToString:@"image"] || [str_QnaType isEqualToString:@"video"] )
                    {
                        return 420.f;
                    }
                    else if( [str_QnaType isEqualToString:@"pdfQuestion"] )
                    {
                        [self pdfQuestionCell:self.c_NormalQuestionCell forRowAtIndexPath:indexPath withMy:NO];
                        return self.c_NormalQuestionCell.sv_Contents.contentSize.height;
                    }
                    else if( [str_QnaType isEqualToString:@"normalQuestion"] )
                    {
                        [self normalQuestionCell:self.c_NormalQuestionCell forRowAtIndexPath:indexPath withMy:NO];
                        return self.c_NormalQuestionCell.sv_Contents.contentSize.height;
                    }
                }
                else
                {
                    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
                    NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
                    NSString *str_MsgType = [dic_ActionMap objectForKey:@"msgType"];
                    
                    if( [str_MsgType isEqualToString:@"shareExam"] )
                    {
                        if( str_ShareMsg.length > 0 )
                        {
                            [self otherShareExamCell:self.c_OtherShareExamCell forRowAtIndexPath:indexPath];
                            
                            [self.c_OtherShareExamCell updateConstraintsIfNeeded];
                            [self.c_OtherShareExamCell layoutIfNeeded];
                            
                            self.c_OtherShareExamCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_OtherShareExamCell.bounds));
                            
                            //                        NSLog(@"cell height : %f", [self.c_OtherShareExamCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                            
                            return [self.c_OtherShareExamCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        }
                        else
                        {
                            [self otherShareExamNoMsgCell:self.c_OtherShareExamNoMsgCell forRowAtIndexPath:indexPath];
                            
                            [self.c_OtherShareExamNoMsgCell updateConstraintsIfNeeded];
                            [self.c_OtherShareExamNoMsgCell layoutIfNeeded];
                            
                            self.c_OtherShareExamNoMsgCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_OtherShareExamNoMsgCell.bounds));
                            
                            //                        NSLog(@"cell height : %f", [self.c_OtherShareExamNoMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                            
                            return [self.c_OtherShareExamNoMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        }
                    }
                    else if( [str_MsgType isEqualToString:@"shareQuestion"] )
                    {
                        if( str_ShareMsg.length > 0 )
                        {
                            [self otherDirectMsgCell:self.c_OtherDirectChatMsgCell forRowAtIndexPath:indexPath];
                            
                            [self.c_OtherDirectChatMsgCell updateConstraintsIfNeeded];
                            [self.c_OtherDirectChatMsgCell layoutIfNeeded];
                            
                            self.c_OtherDirectChatMsgCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_OtherDirectChatMsgCell.bounds));
                            
                            //                        NSLog(@"cell height : %f", [self.c_OtherDirectChatMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                            
                            return [self.c_OtherDirectChatMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        }
                        else
                        {
                            [self otherDirectCell:self.c_OtherDirectChatCell forRowAtIndexPath:indexPath];
                            
                            [self.c_OtherDirectChatCell updateConstraintsIfNeeded];
                            [self.c_OtherDirectChatCell layoutIfNeeded];
                            
                            self.c_OtherDirectChatCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_OtherDirectChatCell.bounds));
                            
                            //                        NSLog(@"cell height : %f", [self.c_OtherDirectChatCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                            
                            return [self.c_OtherDirectChatCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        }
                    }
                    else if( [str_MsgType isEqualToString:@"channel-follow"] || [str_MsgType isEqualToString:@"regist-member"] )
                    {
                        [self otherFollowingCell:self.c_OtherCmdFollowingCell forRowAtIndexPath:indexPath];
                        
                        [self.c_OtherCmdFollowingCell updateConstraintsIfNeeded];
                        [self.c_OtherCmdFollowingCell layoutIfNeeded];
                        
                        self.c_OtherCmdFollowingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_OtherCmdFollowingCell.bounds));
                        
                        //                    NSLog(@"cell height : %f", [self.c_OtherCmdFollowingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                        
                        return [self.c_OtherCmdFollowingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    }
                    else if( [str_MsgType isEqualToString:@"directQNA"] )
                    {
                        //남이 쓴 다이렉트 질문일 경우
                        [self otherDirectMsgCell:self.c_OtherDirectChatMsgCell forRowAtIndexPath:indexPath];
                        
                        [self.c_OtherDirectChatMsgCell updateConstraintsIfNeeded];
                        [self.c_OtherDirectChatMsgCell layoutIfNeeded];
                        
                        self.c_OtherDirectChatMsgCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_OtherDirectChatMsgCell.bounds));
                        
                        //                    NSLog(@"cell height : %f", [self.c_OtherDirectChatMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
                        
                        return [self.c_OtherDirectChatMsgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    }
                }
            }
            else
            {
                
            }
        }
    }
    else
    {
        
        [self autoAnswerSetData:self.c_AutoAnswerCell forRowAtIndexPath:indexPath];
        
        [self.c_AutoAnswerCell updateConstraintsIfNeeded];
        [self.c_AutoAnswerCell layoutIfNeeded];
        
        self.c_AutoAnswerCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_AutoAnswerCell.bounds));
        
        NSLog(@"cell height : %f", [self.c_AutoAnswerCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
        
        return [self.c_AutoAnswerCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        //        return 70.f;
    }
    
    return 0;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id message = self.messages[indexPath.row];
//
//    if( [message isKindOfClass:[SBDBaseMessage class]] )
//    {
//        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
//        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//
//        if( [userMessage.customType isEqualToString:@"audio"] )
//        {
//            NSString *str = [NSString stringWithFormat:@"willDisplayCell : %ld", indexPath.row];
//            NSLog(@"%@", str);
//
////            AutoChatAudioCell *audioCell = (AutoChatAudioCell *)cell;
////            if ((audioCell.player.rate != 0) && (audioCell.player.error == nil))
////            {
////                NSLog(@"will play");
////            }
////            else
////            {
////                NSLog(@"will stop");
////            }
//        }
//    }
//}

//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0);
//{
//    if( indexPath == nil )  return;
//
//    id message = self.messages[indexPath.row];
//
//    if( [message isKindOfClass:[SBDBaseMessage class]] )
//    {
//        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
//        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//
//        if( [userMessage.customType isEqualToString:@"audio"] )
//        {
//            NSString *str = [NSString stringWithFormat:@"didEndDisplayingCell : %ld", indexPath.row];
//            NSLog(@"%@", str);
//
////            AutoChatAudioCell *audioCell = (AutoChatAudioCell *)cell;
////            if ((audioCell.player.rate != 0) && (audioCell.player.error == nil))
////            {
////                NSLog(@"did play");
////            }
////            else
////            {
////                NSLog(@"did stop");
////            }
//
//
//        }
//    }
//}

- (void)autoAnswerSetData:(AutoAnswerCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_AutoAnswer[indexPath.row];
    
    if( self.autoChatMode == kPrintExam )
    {
        cell.lb_Title.text = [dic objectForKey:@"examTitle"];
    }
    else if( self.autoChatMode == kPrintItem )
    {
        cell.lb_Title.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"itemNo"], [dic objectForKey:@"itemBody"]];
    }
    else if( self.autoChatMode == kPrintAnswer || self.autoChatMode == kNextExam || self.autoChatMode == kPrintContinue )
    {
        cell.lb_Title.text = [dic objectForKey:@"title"];
    }
}

- (void)didSelectedItem:(NSDictionary *)dic
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSMutableDictionary *dic_Main = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSDictionary *dic_ActionMap = [dic_Main objectForKey:@"actionMap"];
    NSString *str_MsgType = [dic_ActionMap objectForKey:@"msgType"];
    
    if( [str_MsgType isEqualToString:@"shareExam"] )
    {
        //문제집 공유
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[dic_Main objectForKey:@"actionMap"]];
        
        NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            str_ExamId, @"examId",
                                            nil];
        
        //        __weak __typeof(&*self)weakSelf = self;
        
        NSString *str_Path = [NSString stringWithFormat:@"v1/ispaid/exam/%@", str_ExamId];
        [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                NSString *str_IsPaid = [resulte objectForKey_YM:@"isPaid"];
                                                if( [str_IsPaid isEqualToString:@"paid"] )
                                                {
                                                    //구매한거
                                                    QuestionStartViewController  *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    vc.str_StartIdx = @"0";
                                                    vc.str_Title = [dic objectForKey:@"examTitle"];
                                                    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdf"];
                                                    vc.str_ChannelId = str_ChannelId;
                                                    
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                                else
                                                {
                                                    //구매 안한거
                                                    QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    vc.str_Title = [dic objectForKey:@"examTitle"];
                                                    [vc setCompletionPriceBlock:^(id completeResult) {
                                                        
                                                        //                                                        NSLog(@"@@@@@@@@@@@@@@@@@@@");
                                                        //
                                                        //                                                        [dic setObject:@"paid" forKey:@"isPaid"];
                                                        //                                                        [dic_Main setObject:dic forKey:@"actionMap"];
                                                        //                                                        [self.arM_List replaceObjectAtIndex:indexPath.row withObject:dic_Main];
                                                        
                                                        QuestionStartViewController  *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
                                                        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                        vc.str_StartIdx = @"0";
                                                        vc.str_Title = [dic objectForKey:@"examTitle"];
                                                        //                vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
                                                        vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdf"]; //원랜 pdfExam 였는데 pdf로 바꼈네?
                                                        vc.str_ChannelId = str_ChannelId;
                                                        
                                                        [self.navigationController pushViewController:vc animated:YES];
                                                    }];
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                            }
                                        }];
    }
    else if( [str_MsgType isEqualToString:@"shareQuestion"] )
    {
        //문제 공유
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[dic_Main objectForKey:@"actionMap"]];
        NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            str_ExamId, @"examId",
                                            nil];
        
        //        __weak __typeof(&*self)weakSelf = self;
        
        NSString *str_Path = [NSString stringWithFormat:@"v1/ispaid/exam/%@", str_ExamId];
        [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                NSString *str_IsPaid = [resulte objectForKey_YM:@"isPaid"];
                                                if( [str_IsPaid isEqualToString:@"paid"] )
                                                {
                                                    QuestionViewController *vc = [kQuestionBoard instantiateViewControllerWithIdentifier:@"QuestionViewController"];
                                                    vc.hidesBottomBarWhenPushed = YES;
                                                    vc.str_Title = [dic objectForKey:@"examTitle"];
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
                                                    vc.str_SortType = @"all";
                                                    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdf"];
                                                    vc.str_ChannelId = str_ChannelId;
                                                    [self presentViewController:vc animated:NO completion:^{
                                                        
                                                    }];
                                                    
                                                    //                                                    QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                                                    //                                                    vc.hidesBottomBarWhenPushed = YES;
                                                    //                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    //                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
                                                    //                                                    vc.str_SortType = @"all";
                                                    //                                                    vc.str_ChannelId = str_ChannelId;
                                                    //                                                    if( [[dic objectForKey:@"pdfPage"] integerValue] > 0 )
                                                    //                                                    {
                                                    //                                                        vc.str_PdfPage = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"pdfPage"] integerValue]];
                                                    //                                                    }
                                                    //                                                    if( [[dic objectForKey:@"examNo"] integerValue] > 0 )
                                                    //                                                    {
                                                    //                                                        vc.str_PdfNo = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue]];
                                                    //                                                    }
                                                    //
                                                    //                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                                else
                                                {
                                                    QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    vc.str_Title = [dic objectForKey:@"examTitle"];
                                                    [vc setCompletionPriceBlock:^(id completeResult) {
                                                        
                                                        //                                                        NSLog(@"@@@@@@@@@@@@@@@@@@@");
                                                        //
                                                        //                                                        [dic setObject:@"paid" forKey:@"isPaid"];
                                                        //                                                        [dic_Main setObject:dic forKey:@"actionMap"];
                                                        //                                                        [self.arM_List replaceObjectAtIndex:indexPath.row withObject:dic_Main];
                                                        
                                                        
                                                        QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                                                        vc.hidesBottomBarWhenPushed = YES;
                                                        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                        vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
                                                        vc.str_SortType = @"all";
                                                        vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdf"];
                                                        vc.str_ChannelId = str_ChannelId;
                                                        
                                                        [self.navigationController pushViewController:vc animated:YES];
                                                    }];
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                            }
                                        }];
    }
    else if( [str_MsgType isEqualToString:@"channel-follow"] )
    {
        //채널 팔로우
        NSDictionary *dic_ActionMap = [dic_Main objectForKey:@"actionMap"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
        vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic_ActionMap objectForKey:@"channelId"]];
        vc.isShowNavi = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if( [str_MsgType isEqualToString:@"regist-member"] )
    {
        //채널 인증
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        NotiViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NotiViewController"];
        vc.dic_Info = dic_Main;
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
    else if( [str_MsgType isEqualToString:@"directQNA"] )
    {
        //다이렉트 질문
        //해당 문제로 이동
        //문제 공유
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[dic_Main objectForKey:@"actionMap"]];
        if( [[dic objectForKey_YM:@"isPaid"] isEqualToString:@"paid"] )
        {
            QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examId"] integerValue]];
            vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examNo"] integerValue] - 1];
            vc.str_SortType = @"all";
            vc.isPdf = [[dic objectForKey_YM:@"examType"] isEqualToString:@"pdf"];
            vc.str_ChannelId = str_ChannelId;
            if( [[dic objectForKey:@"pdfPage"] integerValue] > 0 )
            {
                vc.str_PdfPage = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"pdfPage"] integerValue]];
            }
            if( [[dic objectForKey:@"examNo"] integerValue] > 0 )
            {
                vc.str_PdfNo = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examNo"] integerValue]];
            }
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            //구매를 안했으면 문제지 상세 페이지로 이동
            QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
            vc.str_Title = [dic objectForKey:@"examTitle"];
            [vc setCompletionPriceBlock:^(id completeResult) {
                
                //                NSLog(@"@@@@@@@@@@@@@@@@@@@");
                //
                //                [dic setObject:@"paid" forKey:@"isPaid"];
                //                [dic_Main setObject:dic forKey:@"actionMap"];
                //                [self.arM_List replaceObjectAtIndex:indexPath.row withObject:dic_Main];
                
                QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                vc.hidesBottomBarWhenPushed = YES;
                vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
                vc.str_SortType = @"all";
                vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdf"];
                vc.str_ChannelId = str_ChannelId;
                
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
    {
        NSArray *ar_Body = [dic_Main objectForKey:@"qnaBody"];
        if( ar_Body.count > 0 )
        {
            NSDictionary *dic_Body = [ar_Body firstObject];
            if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"image"] || [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"pdfQuestion"] ||
               [[dic objectForKey_YM:@"fileType"] isEqualToString:@"image"] )
            {
                self.ar_Photo = [NSMutableArray array];
                self.thumbs = [NSMutableArray array];
                
                if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"pdfQuestion"] )
                {
                    NSString *str_Json = [dic_Body objectForKey:@"qnaBody"];
                    NSData *data = [str_Json dataUsingEncoding:NSUTF8StringEncoding];
                    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSArray *ar = [json objectForKey:@"examQuestionInfos"];
                    for( NSInteger i = ar.count - 1; i >= 0; i-- )
                    {
                        NSDictionary *dic = [ar objectAtIndex:i];
                        NSString *str_ImageUrl = [dic objectForKey:@"pdfImgUrl"];
                        NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:str_ImageUrl];
                        [self.thumbs addObject:[MWPhoto photoWithURL:url]];
                        [self.ar_Photo addObject:[MWPhoto photoWithURL:url]];
                    }
                }
                else
                {
                    NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
                    NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:str_Contents];
                    [self.thumbs addObject:[MWPhoto photoWithURL:url]];
                    [self.ar_Photo addObject:[MWPhoto photoWithURL:url]];
                }
                
                BOOL displayActionButton = NO;
                BOOL displaySelectionButtons = NO;
                BOOL displayNavArrows = YES;
                BOOL enableGrid = NO;
                BOOL startOnGrid = NO;
                
                browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
                browser.displayActionButton = displayActionButton;
                browser.displayNavArrows = displayNavArrows;
                browser.displaySelectionButtons = displaySelectionButtons;
                browser.alwaysShowControls = displaySelectionButtons;
                browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                browser.wantsFullScreenLayout = YES;
#endif
                browser.enableGrid = enableGrid;
                browser.startOnGrid = startOnGrid;
                browser.enableSwipeToDismiss = YES;
                [browser setCurrentPhotoIndex:0];
                
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
                nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:nc animated:YES completion:nil];
                
                // Release
                
                // Test reloading of data after delay
                double delayInSeconds = 3;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                });
            }
            else if( [[dic_Body objectForKey_YM:@"qnaType"] isEqualToString:@"video"] )
            {
                NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
                NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:str_Contents];
                self.vc_Movie = [[MPMoviePlayerViewController alloc]initWithContentURL:url];
                self.vc_Movie.view.frame = self.view.bounds;
                self.vc_Movie.moviePlayer.repeatMode = MPMovieRepeatModeOne;
                self.vc_Movie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
                self.vc_Movie.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
                self.vc_Movie.moviePlayer.shouldAutoplay = YES;
                self.vc_Movie.moviePlayer.repeatMode = NO;
                [self.vc_Movie.moviePlayer prepareToPlay];
                
                [self presentViewController:self.vc_Movie animated:YES completion:nil];
            }
        }
        
    }
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self.view endEditing:YES];
        
        UIView *view = (UIView *)gesture.view;
        
        NSDictionary *dic = nil;
        NSString *str_WriteUserId = @"";
        id message = self.messages[view.tag];
        if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDUserMessage *userMessage = self.messages[view.tag];
            SBDUser *user = (SBDUser *)userMessage.sender;
            str_WriteUserId = user.userId;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
        }
        else
        {
            if( [message isKindOfClass:[NSDictionary class]] )
            {
                if( [[message objectForKey_YM:@"isFail"] isEqualToString:@"YES"] )
                {
                    NSMutableArray *arM = [NSMutableArray array];
                    [arM addObject:@"재전송"];
                    [arM addObject:@"삭제"];
                    
                    [OHActionSheet showSheetInView:self.view
                                             title:nil
                                 cancelButtonTitle:@"취소"
                            destructiveButtonTitle:nil
                                 otherButtonTitles:arM
                                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
                     {
                         if( buttonIndex == 0 )
                         {
                             //재전송
                             [self deleteTempMsg:message];
                             
                             if( [[message objectForKey:@"type"] isEqualToString:@"text"] )
                             {
                                 [self sendMsg:[message objectForKey:@"contents"]];
                             }
                             else if( [[message objectForKey:@"type"] isEqualToString:@"image"] )
                             {
                                 NSData *data = [message objectForKey:@"obj"];
                                 UIImage *outputImage = [UIImage imageWithData:data];
                                 UIImage *resizeImage = [Util imageWithImage:outputImage convertToWidth:self.view.bounds.size.width - 30];
                                 [self uploadData:@{@"type":@"image", @"obj":UIImageJPEGRepresentation(resizeImage, 0.3f), @"thumb":resizeImage}];
                             }
                             else if( [[message objectForKey:@"type"] isEqualToString:@"video"] )
                             {
                                 NSURL *videoUrl = [NSURL URLWithString:[message objectForKey:@"videoUrl"]];
                                 
                                 AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
                                 AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                                 gen.appliesPreferredTrackTransform = YES;
                                 CMTime time = CMTimeMakeWithSeconds(0.0, 1);
                                 NSError *error = nil;
                                 CMTime actualTime;
                                 
                                 CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                                 UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                                 
                                 UIImage *resizeImage = [Util imageWithImage:thumb convertToWidth:self.view.bounds.size.width - 30];
                                 
                                 NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
                                 [self uploadData:@{@"type":@"video", @"obj":videoData, @"thumb":UIImageJPEGRepresentation(resizeImage, 0.3f), @"videoUrl":[videoUrl absoluteString]}];
                             }
                         }
                         else if( buttonIndex == 1 )
                         {
                             //삭제
                             [self deleteTempMsg:message];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.tbv_List reloadData];
                                 [self.tbv_List layoutIfNeeded];
                             });
                         }
                     }];
                }
            }
            return;
        }
        
        NSString *str_Type = [dic objectForKey:@"itemType"];
        NSString *str_MyUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        
        if( [str_WriteUserId integerValue] == [str_MyUserId integerValue] )
        {
            //내가 쓴 글
            if( [str_Type isEqualToString:@"qna"] )
            {
                //질문일 경우 아래 달린 댓글도 삭제
                [self deleteQna:view.tag];
            }
            else
            {
                //답변일 경우
                //                [self deleteReply:view.tag];
            }
        }
        else if( [str_WriteUserId integerValue] <= 0 )
        {
            //이건 내 글 템프
            //1.배열에서 삭제
            //2.리로드
            //3.아이템 하나 가져오기로 eId 얻기
            //4.얻은 eId로 삭제 api 호출
            
            if( view.tag > -1 )
            {
                [self deleteQna:view.tag];
            }
            
            
        }
        else
        {
            //다른 사람이 쓴 글
            NSMutableArray *arM = [NSMutableArray array];
            [arM addObject:@"신고하기"];
            
            [OHActionSheet showSheetInView:self.view
                                     title:nil
                         cancelButtonTitle:@"취소"
                    destructiveButtonTitle:nil
                         otherButtonTitles:arM
                                completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
             {
                 if( buttonIndex == 0 )
                 {
                     //신고하기
                     UIAlertView *alert = CREATE_ALERT(nil, @"해당 게시글을 신고하시겠습니까?", @"확인", @"취소");
                     [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                         
                         if( buttonIndex == 0 )
                         {
                             NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                 [Util getUUID], @"uuid",
                                                                 [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]], @"eId",
                                                                 nil];
                             
                             __weak __typeof(&*self)weakSelf = self;
                             
                             [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/question/explain/report"
                                                                 param:dicM_Params
                                                            withMethod:@"POST"
                                                             withBlock:^(id resulte, NSError *error) {
                                                                 
                                                                 [MBProgressHUD hide];
                                                                 
                                                                 if( resulte )
                                                                 {
                                                                     NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                     if( nCode == 200 )
                                                                     {
                                                                         [weakSelf.navigationController.view makeToast:@"신고 되었습니다." withPosition:kPositionCenter];
                                                                     }
                                                                     else
                                                                     {
                                                                         [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                                     }
                                                                 }
                                                             }];
                         }
                     }];
                 }
             }];
        }
    }
}

- (void)deleteTempMsg:(NSDictionary *)message
{
    [self.messages removeObject:message];
    
    NSArray *ar_Tmp = [self.dicM_TempMyContents allKeys];
    NSString *str_FindKey = nil;
    for( NSInteger i = 0; i < ar_Tmp.count; i++ )
    {
        NSString *str_Key = ar_Tmp[i];
        id tmp = [self.dicM_TempMyContents objectForKey:str_Key];
        if( [tmp isKindOfClass:[NSDictionary class]] )
        {
            NSDictionary *dic_Tmp = (NSDictionary *)tmp;
            NSInteger nTargetId = [[dic_Tmp objectForKey:@"createDate"] integerValue];
            NSInteger nId = [[message objectForKey:@"createDate"] integerValue];
            if( nTargetId != 0 && nTargetId == nId )
            {
                str_FindKey = str_Key;
                break;
            }
        }
    }
    
    if( str_FindKey )
    {
        [self.dicM_TempMyContents removeObjectForKey:str_FindKey];
    }
}

- (void)deleteQna:(NSInteger)nTag
{
    //    __block NSDictionary *dic = self.arM_List[nTag];
    
    __block SBDUserMessage *message = self.messages[nTag];
    //    SBDUser *user = (SBDUser *)message.sender;
    NSData *data = [message.data dataUsingEncoding:NSUTF8StringEncoding];
    __block NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"삭제하기"];
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIAlertView *alert = CREATE_ALERT(nil, @"해당 게시글을 삭제하시겠습니까?", @"확인", @"취소");
             [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 
                 if( buttonIndex == 0 )
                 {
                     //v3 메세지 삭제
                     [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                         
                     }];
                     /***********************************/
                     
                     
                     __block NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                 [Util getUUID], @"uuid",
                                                                 [self.dic_Info objectForKey:@"questionId"], @"questionId",
                                                                 [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]], @"eId",
                                                                 nil];
                     
                     //                     if( [[dic objectForKey:@"temp"] isEqualToString:@"YES"] )
                     //                     {
                     //                         //템프일 경우
                     //                         NSDictionary *dic_Tmp = [self.dicM_TempMyContents objectForKey:[NSString stringWithFormat:@"%ld", nTag]];
                     //                         [dicM_Params setObject:[dic_Tmp objectForKey:@"eId"] forKey:@"eId"];
                     //
                     //                         [self.arM_List removeObjectAtIndex:nTag];
                     //                         [self setMiddleDate];
                     //                         [self.tbv_List reloadData];
                     //
                     //                     }
                     
                     
                     __weak __typeof(&*self)weakSelf = self;
                     
                     [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/question/explain/delete"
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
                                                                 //                                                                 NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
                                                                 //                                                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"eId":[NSString stringWithFormat:@"%@", [dicM_Params objectForKey:@"eId"]],
                                                                 //                                                                                                                              @"channelUrl":self.str_ChannelUrl}
                                                                 //                                                                                                                    options:NSJSONWritingPrettyPrinted
                                                                 //                                                                                                                      error:&error];
                                                                 //                                                                 NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                                 
                                                                 //                                                                 [SendBird sendMessage:@"delete-qna" withData:jsonString];
                                                             }
                                                             else
                                                             {
                                                                 [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                             }
                                                         }
                                                     }];
                 }
             }];
             
         }
     }];
}

- (void)onMoveToPdf:(UIButton *)btn
{
    id message = self.messages[btn.tag];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[btn.tag];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        //        dic = message;
        return;
    }
    
    __block BOOL isPdf = YES;
    //    NSDictionary *dic_Tmp = [dic objectForKey:@"dataMap"];
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    NSDictionary *dic_Tmp = [ar_Body firstObject];
    if( [[dic_Tmp objectForKey_YM:@"qnaType"] isEqualToString:@"normalQuestion"] )
    {
        isPdf = NO;
        //        NSString *str_Tmp = [dic_Tmp objectForKey:@"qnaBody"];
        //        NSData *data2 = [str_Tmp dataUsingEncoding:NSUTF8StringEncoding];
        //        dic = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //    NSMutableDictionary *dic_Main = [NSMutableDictionary dictionaryWithDictionary:dic];
    //    NSDictionary *dic_ActionMap = [dic_Main objectForKey:@"actionMap"];
    //    NSString *str_MsgType = [dic_ActionMap objectForKey:@"msgType"];
    
    //    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[dic_Main objectForKey:@"actionMap"]];
    NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        str_ExamId, @"examId",
                                        nil];
    
    //        __weak __typeof(&*self)weakSelf = self;
    
    NSString *str_Path = [NSString stringWithFormat:@"v1/ispaid/exam/%@", str_ExamId];
    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSString *str_IsPaid = [resulte objectForKey_YM:@"isPaid"];
                                            if( [str_IsPaid isEqualToString:@"paid"] )
                                            {
                                                if( isPdf == NO )
                                                {
                                                    QuestionViewController *vc = [kQuestionBoard instantiateViewControllerWithIdentifier:@"QuestionViewController"];
                                                    vc.hidesBottomBarWhenPushed = YES;
                                                    vc.str_Title = [dic objectForKey:@"examTitle"];
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
                                                    vc.str_SortType = @"all";
                                                    vc.isPdf = isPdf;
                                                    vc.str_ChannelId = str_ChannelId;
                                                    
                                                    [self presentViewController:vc animated:NO completion:^{
                                                        
                                                    }];
                                                    
                                                    //                                                    QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                                                    //                                                    vc.hidesBottomBarWhenPushed = YES;
                                                    //                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    //                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
                                                    //                                                    vc.str_SortType = @"all";
                                                    //                                                    vc.str_ChannelId = str_ChannelId;
                                                    //                                                    if( [[dic objectForKey:@"pdfPage"] integerValue] > 0 )
                                                    //                                                    {
                                                    //                                                        vc.str_PdfPage = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"pdfPage"] integerValue]];
                                                    //                                                    }
                                                    //                                                    if( [[dic objectForKey:@"examNo"] integerValue] > 0 )
                                                    //                                                    {
                                                    //                                                        vc.str_PdfNo = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue]];
                                                    //                                                    }
                                                    //
                                                    //                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                                else
                                                {
                                                    QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                                                    vc.hidesBottomBarWhenPushed = YES;
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
                                                    vc.str_SortType = @"all";
                                                    vc.isPdf = isPdf;
                                                    vc.str_ChannelId = str_ChannelId;
                                                    if( [[dic objectForKey:@"pdfPage"] integerValue] > 0 )
                                                    {
                                                        vc.str_PdfPage = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"pdfPage"] integerValue]];
                                                    }
                                                    if( [[dic objectForKey:@"examNo"] integerValue] > 0 )
                                                    {
                                                        vc.str_PdfNo = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue]];
                                                    }
                                                    
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                            }
                                            else
                                            {
                                                QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
                                                vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                NSString *str_Title = [dic objectForKey_YM:@"examTitle"];
                                                vc.str_Title = [dic objectForKey_YM:@"examTitle"];
                                                [vc setCompletionPriceBlock:^(id completeResult) {
                                                    
                                                    QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                                                    vc.hidesBottomBarWhenPushed = YES;
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
                                                    vc.str_SortType = @"all";
                                                    //                                                    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdf"];
                                                    vc.isPdf = vc.isPdf;
                                                    vc.str_ChannelId = str_ChannelId;
                                                    
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }];
                                                [self.navigationController pushViewController:vc animated:YES];
                                            }
                                        }
                                    }];
}

- (void)pdfQuestionCell:(NormalQuestionCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withMy:(BOOL)isMy
{
    cell.sv_Contents.userInteractionEnabled = NO;
    
    for( id subview in cell.sv_Contents.subviews )
    {
        [subview removeFromSuperview];
    }
    
    for( id subview in cell.contentView.subviews )
    {
        if( [subview isKindOfClass:[UIButton class]] )
        {
            [subview removeFromSuperview];
        }
    }
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        //        if( [[message objectForKey:@"temp"] isEqualToString:@"YES"] )
        //        {
        //            dic = [message objectForKey:@"obj"];
        //        }
        //        else
        //        {
        //            dic = message;
        //        }
        
        dic = message;
    }
    
    __block CGFloat fSampleViewTotalHeight = 0;
    if( isMy )
    {
        
    }
    else
    {
        fSampleViewTotalHeight = 20.f;
    }
    
    //    NSDictionary *dic_DataMap = [dic objectForKey:@"dataMap"];
    NSDictionary *dic_DataMap = nil;
    id body = [dic objectForKey:@"qnaBody"];
    if( [body isKindOfClass:[NSArray class]] )
    {
        NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
        dic_DataMap = [ar_Body firstObject];
    }
    //    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    //    NSDictionary *dic_DataMap = [ar_Body firstObject];
    if( dic_DataMap == nil )    //temp글 일시
    {
        dic_DataMap = dic;
        //        NSString *str_Tmp = [dic objectForKey:@"qnaBody"];
        //        NSData *data2 = [str_Tmp dataUsingEncoding:NSUTF8StringEncoding];
        //        dic = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
    }
    
    NSString *str_Images = [dic_DataMap objectForKey:@"qnaBody"];
    NSData *data2 = [str_Images dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
    if( dic_Tmp )
    {
        //새로 정의한 데이터
        NSArray *ar_Data = [dic_Tmp objectForKey:@"examQuestionInfos"];
        for( NSInteger i = ar_Data.count - 1; i >= 0; i-- )
        {
            NSDictionary *dic_Sub = [ar_Data objectAtIndex:i];
            NSString *str_ImageUrl = [dic_Sub objectForKey:@"pdfImgUrl"];
            
            CGFloat fWidth = [[dic_Sub objectForKey:@"width"] floatValue];
            CGFloat fHeight = [[dic_Sub objectForKey:@"height"] floatValue];
            
            CGFloat fScale = self.tbv_List.frame.size.width / fWidth;
            fHeight = fHeight * fScale;
            if( isnan(fHeight) )
            {
                fHeight = 300.f;
            }
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, fSampleViewTotalHeight, self.tbv_List.frame.size.width, fHeight)];
            [iv sd_setImageWithURL:[Util createImageUrl:str_ImagePreFix withFooter:str_ImageUrl]];
            //            iv.image = [Util imageWithImage:iv.image convertToWidth:self.tbv_List.frame.size.width];
            iv.userInteractionEnabled = YES;
            iv.tag = indexPath.row;
            
            UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
            pinchZoom.delegate = self;
            [iv addGestureRecognizer:pinchZoom];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            tapGesture.delegate = self;
            [iv addGestureRecognizer:tapGesture];
            
            
            //            CGRect frame = iv.frame;
            //            frame.size.height = iv.image.size.height;
            //            iv.frame = frame;
            
            //            CGFloat fHeight = iv.image.size.height * (self.tbv_List.frame.size.width / iv.image.size.width);
            //            CGRect frame = iv.frame;
            //            if( isnan(fHeight) )
            //            {
            //                fHeight = 300.f;
            //            }
            //            else
            //            {
            //                frame.size.height = fHeight;
            //            }
            //            iv.frame = frame;
            
            fSampleViewTotalHeight += iv.frame.size.height;
            
            [cell.sv_Contents addSubview:iv];
            cell.sv_Contents.userInteractionEnabled = YES;
        }
        \
    }
    else
    {
        //예전 데이터
        NSArray *ar_Images = [str_Images componentsSeparatedByString:@"|"];
        
        for( NSInteger i = ar_Images.count - 1; i >= 0; i-- )
        {
            NSString *str_ImageUrl = ar_Images[i];
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, fSampleViewTotalHeight, self.tbv_List.frame.size.width, 0)];
            [iv sd_setImageWithURL:[Util createImageUrl:str_ImagePreFix withFooter:str_ImageUrl]];
            //            iv.image = [Util imageWithImage:iv.image convertToWidth:self.tbv_List.frame.size.width];
            iv.userInteractionEnabled = YES;
            iv.tag = indexPath.row;
            
            UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
            pinchZoom.delegate = self;
            [iv addGestureRecognizer:pinchZoom];
            
            //        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            //        tapGesture.delegate = self;
            //        [iv addGestureRecognizer:tapGesture];
            
            
            //            CGRect frame = iv.frame;
            //            frame.size.height = iv.image.size.height;
            //            iv.frame = frame;
            
            CGFloat fHeight = iv.image.size.height * (self.tbv_List.frame.size.width / iv.image.size.width);
            CGRect frame = iv.frame;
            if( isnan(fHeight) )
            {
                fHeight = 300.f;
            }
            else
            {
                frame.size.height = fHeight;
            }
            iv.frame = frame;
            
            fSampleViewTotalHeight += iv.frame.size.height;
            
            [cell.sv_Contents addSubview:iv];
            cell.sv_Contents.userInteractionEnabled = YES;
        }
    }
    
    
    UIButton *btn_Origin = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_Origin.tag = indexPath.row;
    btn_Origin.backgroundColor = [UIColor whiteColor];
    btn_Origin.frame = CGRectMake(0, fSampleViewTotalHeight + 40, cell.sv_Contents.frame.size.width, 35);
    btn_Origin.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [btn_Origin.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [btn_Origin setTitleColor:kMainColor forState:UIControlStateNormal];
    [btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic objectForKey:@"examTitle"]] forState:UIControlStateNormal];
    btn_Origin.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [btn_Origin addTarget:self action:@selector(onMoveToPdf:) forControlEvents:UIControlEventTouchUpInside];
    
    if( isMy )
    {
        cell.iv_User.hidden = cell.lb_Name.hidden = YES;
        btn_Origin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    else
    {
        //        fSampleViewTotalHeight += 40.f;
        
        cell.iv_User.hidden = cell.lb_Name.hidden = NO;
        btn_Origin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        NSDictionary *dic = nil;
        if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDBaseMessage *baseMessage = self.messages[indexPath.row];
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        else
        {
            if( [[message objectForKey:@"temp"] isEqualToString:@"YES"] )
            {
                dic = [message objectForKey:@"obj"];
            }
            else
            {
                dic = message;
            }
        }
        
        NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
        cell.lb_Name.text = [dic objectForKey:@"name"];
    }
    [cell.contentView addSubview:btn_Origin];
    
    fSampleViewTotalHeight += 70.f;
    
    cell.sv_Contents.contentSize = CGSizeMake(self.tbv_List.frame.size.width, fSampleViewTotalHeight);
}

- (void)normalQuestionCell:(NormalQuestionCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withMy:(BOOL)isMy
{
    for( id subview in cell.sv_Contents.subviews )
    {
        [subview removeFromSuperview];
    }
    
    for( id subview in cell.contentView.subviews )
    {
        if( [subview isKindOfClass:[UIButton class]] )
        {
            [subview removeFromSuperview];
        }
    }
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        if( [[message objectForKey:@"temp"] isEqualToString:@"YES"] )
        {
            dic = [message objectForKey:@"obj"];
        }
        else
        {
            dic = message;
        }
    }
    
    //    NSDictionary *dic_Tmp = [dic objectForKey:@"dataMap"];
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    NSDictionary *dic_Tmp = [ar_Body firstObject];
    
    if( dic_Tmp )
    {
        NSString *str_Tmp = [dic_Tmp objectForKey:@"qnaBody"];
        NSData *data2 = [str_Tmp dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
    }
    
    __block CGFloat fSampleViewTotalHeight = 30;
    
    NSArray *ar_ExamQuestionInfos = nil;
    NSArray *ar_ExamUserItemInfos = nil;
    
    id qnaBody = [dic objectForKey:@"qnaBody"];
    if( [qnaBody isKindOfClass:[NSDictionary class]] )
    {
        ar_ExamQuestionInfos = [qnaBody objectForKey:@"examQuestionInfos"];
        ar_ExamUserItemInfos = [qnaBody objectForKey:@"examUserItemInfos"];
    }
    else if( [qnaBody isKindOfClass:[NSArray class]] )
    {
        ar_ExamQuestionInfos = [dic objectForKey:@"qnaBody"];
    }
    else
    {
        ar_ExamQuestionInfos = [dic objectForKey:@"examQuestionInfos"];
        ar_ExamUserItemInfos = [dic objectForKey:@"examUserItemInfos"];
    }
    
    CGFloat fX = 15.f;
    
    NSMutableString *strM_Exam = [NSMutableString string];
    for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamQuestionInfos[i];
        NSString *str_Type = [dic objectForKey:@"questionType"];
        NSString *str_Body = [dic objectForKey:@"questionBody"];
        str_Body = [str_Body stringByReplacingOccurrencesOfString:@"#####" withString:@"\n"];
        
        if( [str_Type isEqualToString:@"text"] )
        {
            str_Body = [str_Body stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
            //            [strM_Exam appendString:str_Body];
            //            [strM_Exam appendString:@"\n"];
            //            [strM_Exam appendString:@"\n"];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:20.f];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;
            
            [cell.sv_Contents addSubview:lb_Contents];
            
            fSampleViewTotalHeight += lb_Contents.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"html"] )
        {
            //            UIFont *font = [UIFont fontWithName:@"Helvetica" size:16.f];
            //
            //            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
            //                                                                        forKey:NSFontAttributeName];
            //
            //            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding]
            //                                                                                         options:@{NSFontAttributeName:font,
            //                                                                                                   NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
            //                                                                              documentAttributes:nil
            //                                                                                           error:nil];
            //
            //            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            //            [paragraphStyle setLineSpacing:4];  // Or whatever (positive) value you like...
            //
            ////            [attrStr beginEditing];
            ////            [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.length)];
            ////            [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrStr.length)];
            ////            [attrStr addAttribute:NSDocumentTypeDocumentAttribute value:NSHTMLTextDocumentType range:NSMakeRange(0, attrStr.length)];
            ////            [attrStr addAttribute:NSCharacterEncodingDocumentAttribute value:@(NSUTF8StringEncoding) range:NSMakeRange(0, attrStr.length)];
            ////            [attrStr endEditing];
            //
            ////            NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName : font } documentAttributes:nil error:nil];
            //
            //            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.sv_Contents.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            //
            //            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), rect.size.height)];
            //            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            //            lb_Contents.numberOfLines = 0;
            //            lb_Contents.attributedText = attrStr;
            //
            //            [cell.sv_Contents addSubview:lb_Contents];
            
            
            //            [strM_Exam appendString:str_Body];
            //            [strM_Exam appendString:@"\n"];
            //            [strM_Exam appendString:@"\n"];
            
            BOOL isTemp = NO;
            if( [message isKindOfClass:[SBDBaseMessage class]] )
            {
                
            }
            else
            {
                if( [[message objectForKey:@"temp"] isEqualToString:@"YES"] )
                {
                    isTemp = YES;
                }
                else
                {
                    
                }
            }
            
            if( isTemp )
            {
                //템프인 경우 html이고
                UIFont *font = [UIFont fontWithName:@"Helvetica" size:20.f];
                
                NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName : font } documentAttributes:nil error:nil];
                [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrStr.length)];
                
                CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.sv_Contents.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), rect.size.height)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.numberOfLines = 0;
                lb_Contents.attributedText = attrStr;
                
                [cell.sv_Contents addSubview:lb_Contents];
                
                fSampleViewTotalHeight += rect.size.height + 20;
            }
            else
            {
                fSampleViewTotalHeight += 10.f;
                
                //템프가 아닌 경우는 string이다
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), 0)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:20.f];
                lb_Contents.text = str_Body;
                lb_Contents.numberOfLines = 0;
                
                CGRect frame = lb_Contents.frame;
                frame.size.height = [Util getTextSize:lb_Contents].height;
                lb_Contents.frame = frame;
                
                [cell.sv_Contents addSubview:lb_Contents];
                
                fSampleViewTotalHeight += lb_Contents.frame.size.height + 20;
            }
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, fSampleViewTotalHeight, self.tbv_List.frame.size.width, 0)];
            [iv sd_setImageWithURL:[Util createImageUrl:str_ImagePreFix withFooter:str_Body]];
            iv.image = [Util imageWithImage:iv.image convertToWidth:self.tbv_List.frame.size.width];
            
            CGRect frame = iv.frame;
            frame.size.height = iv.image.size.height;
            iv.frame = frame;
            
            fSampleViewTotalHeight += iv.frame.size.height + 20;
            
            [cell.sv_Contents addSubview:iv];
        }
        else if( [str_Type isEqualToString:@"videoLink"] )
        {
            //유튜브
            self.playerView = [[YTPlayerView alloc] initWithFrame:
                               CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), (cell.sv_Contents.frame.size.width - (fX*2)) * 0.7f)];
            
            NSDictionary *playerVars = @{
                                         @"controls" : @1,
                                         @"playsinline" : @1,
                                         @"autohide" : @1,
                                         @"showinfo" : @0,
                                         @"modestbranding" : @1
                                         };
            
            [self.playerView loadWithVideoId:str_Body playerVars:playerVars];
            
            [cell.sv_Contents addSubview:self.playerView];
            
            fSampleViewTotalHeight += self.playerView.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"audio"] )
        {
            NSString *str_Body = [dic objectForKey:@"questionBody"];
            self.str_AudioBody = str_Body;
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, self.str_AudioBody];
            
            AudioView *v_Audio = [cell.sv_Contents viewWithTag:10];
            if( v_Audio == nil )
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
                v_Audio = [topLevelObjects objectAtIndex:0];
                v_Audio.tag = 10;
                [v_Audio initPlayer:str_Url];
                
                [self.arM_Audios addObject:v_Audio];
            }
            
            v_Audio.userInteractionEnabled = NO;
            
            CGRect frame = v_Audio.frame;
            frame.origin.y = fSampleViewTotalHeight;
            frame.size.width = self.view.bounds.size.width;
            frame.size.height = 48;
            v_Audio.frame = frame;
            
            [cell.sv_Contents addSubview:v_Audio];
            
            fSampleViewTotalHeight += v_Audio.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), (cell.sv_Contents.frame.size.width - (fX*2)) * 0.7f)];
            
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
            self.vc_Movie = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:str_Url]];
            self.vc_Movie.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            self.vc_Movie.moviePlayer.repeatMode = MPMovieRepeatModeOne;
            //            vc.moviePlayer.fullscreen = NO;
            //            vc.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
            self.vc_Movie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
            self.vc_Movie.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
            self.vc_Movie.moviePlayer.shouldAutoplay = NO;
            self.vc_Movie.moviePlayer.repeatMode = NO;
            //                [self.vc_Movie.moviePlayer setFullscreen:NO animated:NO];
            [self.vc_Movie.moviePlayer prepareToPlay];
            
            [view addSubview:self.vc_Movie.view];
            [cell.sv_Contents addSubview:view];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            
            fSampleViewTotalHeight += view.frame.size.height;
        }
    }
    
    //    if( strM_Exam.length > 0 )
    //    {
    //        UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), 0)];
    //        lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
    //        lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:20.f];
    //        lb_Contents.text = strM_Exam;
    //        lb_Contents.numberOfLines = 0;
    ////        lb_Contents.backgroundColor = [UIColor redColor];
    //
    //        CGSize size = [Util getTextSize:lb_Contents];
    //
    //        CGRect frame = lb_Contents.frame;
    //        frame.size.height = size.height;
    //        lb_Contents.frame = frame;
    //
    //        [cell.sv_Contents addSubview:lb_Contents];
    //
    //        fSampleViewTotalHeight += size.height;
    //    }
    
    //보기
    //보기입력
    NSMutableString *strM_Item = [NSMutableString string];
    for( NSInteger i = 0; i < ar_ExamUserItemInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamUserItemInfos[i];
        NSString *str_Type = [dic objectForKey:@"type"];
        NSString *str_Body = [dic objectForKey:@"itemBody"];
        str_Body = [str_Body stringByReplacingOccurrencesOfString:@"#####" withString:@"\n"];
        
        NSString *str_Number = [NSString stringWithFormat:@"%@ ", [dic objectForKey_YM:@"printNo"]];   //printNo 이걸쓰라고? itemNo
        str_Number = [str_Number stringByReplacingOccurrencesOfString:@"#####" withString:@"\n"];
        
        if( [str_Type isEqualToString:@"itemImage"] )
        {
            if( i % 2 == 0 )
            {
                fX = 15.f;
            }
            else
            {
                fX = (self.view.bounds.size.width / 2) + 20;
            }
            
            if( i != 0 && i % 2 == 0 )
            {
                fSampleViewTotalHeight += 150 + 10;
            }
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 20, 20)];
            lb_Contents.numberOfLines = 0;
            lb_Contents.text = str_Number;
            [cell.sv_Contents addSubview:lb_Contents];
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX + 20, fSampleViewTotalHeight, ((self.view.bounds.size.width / 2) - 50), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFit;
            iv.clipsToBounds = YES;
            //            iv.backgroundColor = [UIColor redColor];
            
            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
            
            [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
            
            CGRect frame = iv.frame;
            frame.size.height = 150.f;
            iv.frame = frame;
            
            [cell.sv_Contents addSubview:iv];
            
            if( i == ar_ExamUserItemInfos.count - 1 )
            {
                fSampleViewTotalHeight += 200;
            }
        }
        else if( [str_Type isEqualToString:@"itemHtml"] )
        {
            [strM_Item appendString:[NSString stringWithFormat:@"%@ %@", str_Number, str_Body]];
            
            //            UIFont *font = [UIFont fontWithName:@"Helvetica" size:19.f];
            //            NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
            //                                                                 forKey:NSFontAttributeName];
            //
            //            NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            //
            //            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", str_Number] attributes:dic_Attr];
            //            //            [attrStr appendAttributedString:attrStr_Html];
            //
            //            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.sv_Contents.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            //
            //            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 30, rect.size.height)];
            //            lb_Contents.numberOfLines = 0;
            //            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:24.f];
            //            lb_Contents.text = attrStr.string;
            //            //            lb_Contents.attributedText = attrStr;
            //            //                        lb_Contents.backgroundColor = [UIColor redColor];
            //
            //            CGSize size = [Util getTextSize:lb_Contents];
            //
            //            CGRect frame = lb_Contents.frame;
            //            frame.size.height = size.height;
            //            lb_Contents.frame = frame;
            //
            //            [cell.sv_Contents addSubview:lb_Contents];
            //
            //            //            if( isNumberQuestion == NO )
            //            //            {
            //            //                lb_Contents.text = @"";
            //            //            }
            //
            //            //마지막에 줄바꿈이 들어가서 없애줌
            //            NSArray *charSet = [attrStr_Html.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            //            NSString *str_Contents = [charSet componentsJoinedByString:@""];
            //            ////////////////////////////
            //
            //            UILabel * lb_Contents2 = [[UILabel alloc] initWithFrame:CGRectMake(lb_Contents.text.length > 0 ?
            //                                                                               lb_Contents.frame.origin.x + lb_Contents.frame.size.width : fX, fSampleViewTotalHeight,
            //                                                                               lb_Contents.text.length > 0 ?
            //                                                                               cell.sv_Contents.frame.size.width - (lb_Contents.frame.origin.x + lb_Contents.frame.size.width + fX) :
            //                                                                               cell.sv_Contents.frame.size.width - (fX * 2),
            //                                                                               0)];
            //            lb_Contents2.numberOfLines = 0;
            //            lb_Contents2.font = [UIFont fontWithName:@"Helvetica" size:20.f];
            //            lb_Contents2.text = str_Contents;
            //            lb_Contents2.textColor = [UIColor colorWithHexString:@"030304"];
            //            //            lb_Contents2.backgroundColor = [UIColor blueColor];
            //            //            lb_Contents.attributedText = attrStr;
            //
            //            size = [Util getTextSize:lb_Contents2];
            //
            //            frame = lb_Contents2.frame;
            //            frame.size.height = size.height < lb_Contents.frame.size.height ? lb_Contents.frame.size.height : size.height;
            //            lb_Contents2.frame = frame;
            //
            //            [cell.sv_Contents addSubview:lb_Contents2];
            //
            //
            //
            //            fSampleViewTotalHeight += size.height + 15;
        }
        else
        {
            [strM_Item appendString:[NSString stringWithFormat:@"%@ %@", str_Number, str_Body]];
            
            //            UIFont *font = [UIFont fontWithName:@"Helvetica" size:19.f];
            //            NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
            //                                                                 forKey:NSFontAttributeName];
            //
            //            NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[@"" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            //
            //            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str_Number, str_Body] attributes:dic_Attr];
            //            [attrStr appendAttributedString:attrStr_Html];
            //
            //            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.sv_Contents.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            //
            //            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 30, rect.size.height)];
            //            lb_Contents.numberOfLines = 0;
            //            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:24.f];
            //            lb_Contents.text = str_Number;
            //            //            lb_Contents.attributedText = attrStr;
            //            //            lb_Contents.backgroundColor = [UIColor redColor];
            //
            //            CGSize size = [Util getTextSize:lb_Contents];
            //
            //            CGRect frame = lb_Contents.frame;
            //            frame.size.height = size.height;
            //            lb_Contents.frame = frame;
            //
            //            [cell.sv_Contents addSubview:lb_Contents];
            //
            //            UILabel * lb_Contents2 = [[UILabel alloc] initWithFrame:CGRectMake(lb_Contents.frame.origin.x + lb_Contents.frame.size.width, fSampleViewTotalHeight,
            //                                                                               cell.sv_Contents.frame.size.width - (lb_Contents.frame.origin.x + lb_Contents.frame.size.width + fX), 0)];
            //            lb_Contents2.numberOfLines = 0;
            //            lb_Contents2.font = [UIFont fontWithName:@"Helvetica" size:20.f];
            //            lb_Contents2.text = str_Body;
            //            lb_Contents2.textColor = [UIColor colorWithHexString:@"030304"];
            //            //            lb_Contents2.backgroundColor = [UIColor blueColor];
            //            //            lb_Contents.attributedText = attrStr;
            //
            //            size = [Util getTextSize:lb_Contents2];
            //
            //            frame = lb_Contents2.frame;
            //            frame.size.height = size.height < lb_Contents.frame.size.height ? lb_Contents.frame.size.height : size.height;
            //            lb_Contents2.frame = frame;
            //
            //            [cell.sv_Contents addSubview:lb_Contents2];
            //
            //
            //
            //            fSampleViewTotalHeight += size.height + 15;
        }
    }
    
    if( strM_Item.length > 0 )
    {
        UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), 0)];
        lb_Contents.numberOfLines = 0;
        lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:20.f];
        lb_Contents.text = strM_Item;
        //        lb_Contents.backgroundColor = [UIColor blueColor];
        
        CGSize size = [Util getTextSize:lb_Contents];
        
        CGRect frame = lb_Contents.frame;
        frame.size.height = size.height;
        lb_Contents.frame = frame;
        
        [cell.sv_Contents addSubview:lb_Contents];
        
        fSampleViewTotalHeight += size.height + 15;
    }
    
    
    
    
    
    
    
    NSString *str_Origin = [dic objectForKey:@"examTitle"];
    UIButton *btn_Origin = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_Origin.tag = indexPath.row;
    btn_Origin.backgroundColor = [UIColor whiteColor];
    btn_Origin.frame = CGRectMake(0, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width, 35);
    btn_Origin.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [btn_Origin.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [btn_Origin setTitleColor:kMainColor forState:UIControlStateNormal];
    if( str_Origin.length > 0 )
    {
        [btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic objectForKey:@"examTitle"]] forState:UIControlStateNormal];
    }
    else
    {
        id message = self.messages[indexPath.row];
        
        NSDictionary *dic_Tmp = nil;
        if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDBaseMessage *baseMessage = self.messages[indexPath.row];
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic_Tmp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        else
        {
            if( [[message objectForKey:@"temp"] isEqualToString:@"YES"] )
            {
                dic_Tmp = [message objectForKey:@"obj"];
            }
            else
            {
                dic_Tmp = message;
            }
        }
        [btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic_Tmp objectForKey:@"examTitle"]] forState:UIControlStateNormal];
    }
    btn_Origin.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [btn_Origin addTarget:self action:@selector(onMoveToPdf:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if( isMy )
    {
        cell.iv_User.hidden = cell.lb_Name.hidden = YES;
        btn_Origin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    else
    {
        cell.iv_User.hidden = cell.lb_Name.hidden = NO;
        btn_Origin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        NSDictionary *dic = nil;
        if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDBaseMessage *baseMessage = self.messages[indexPath.row];
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        else
        {
            if( [[message objectForKey:@"temp"] isEqualToString:@"YES"] )
            {
                dic = [message objectForKey:@"obj"];
            }
            else
            {
                dic = message;
            }
        }
        
        NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
        cell.lb_Name.text = [dic objectForKey:@"name"];
    }
    [cell.sv_Contents addSubview:btn_Origin];
    
    cell.sv_Contents.contentSize = CGSizeMake(self.tbv_List.frame.size.width, fSampleViewTotalHeight + (110-35));
}

- (void)myImageCell:(MyImageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withVideo:(BOOL)isVideo
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        if( isVideo == NO )
        {
            cell.v_Video.hidden = YES;
            
            [cell.btn_Origin removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            
            if( [[dic_Body objectForKey:@"qnaType"] isEqualToString:@"pdfQuestion"] )
            {
                cell.btn_Origin.tag = indexPath.row;
                cell.btn_Read.hidden = YES;
                cell.lb_Date.hidden = YES;
                
                cell.btn_Origin.hidden = NO;
                [cell.btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic objectForKey_YM:@"examTitle"]] forState:UIControlStateNormal];
                [cell.btn_Origin addTarget:self action:@selector(onMoveToPdf:) forControlEvents:UIControlEventTouchUpInside];
                
                NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
                NSArray *ar_Tmp = [str_Contents componentsSeparatedByString:@"|"];
                if( ar_Tmp && ar_Tmp.count > 0 )
                {
                    NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:[ar_Tmp firstObject]];
                    //                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", str_ImagePreFix, [ar_Tmp firstObject]]];
                    [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
                }
            }
            else
            {
                NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
                NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:str_Contents];
                [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
                
                cell.iv_Contents.userInteractionEnabled = YES;
                cell.iv_Contents.tag = indexPath.row;
                UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
                pinchZoom.delegate = self;
                [cell.iv_Contents addGestureRecognizer:pinchZoom];
            }
        }
        else if( isVideo )
        {
            cell.v_Video.hidden = NO;
            NSString *str_Contents = [dic_Body objectForKey:@"videoCoverPath"];
            NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:str_Contents];
            [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
        }
        
        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    [[TMImageZoom shared] gestureStateChanged:gesture withZoomImageView:(UIImageView *)gesture.view];
    
    //    id message = self.messages[gesture.view.tag];
    //
    //    NSDictionary *dic = nil;
    //    if( [message isKindOfClass:[SBDBaseMessage class]] )
    //    {
    //        SBDBaseMessage *baseMessage = self.messages[gesture.view.tag];
    //        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
    //        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
    //        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //    }
    //    else
    //    {
    //        dic = message;
    //    }
    //
    //    NSDictionary *dic_DataMap = [dic objectForKey:@"dataMap"];
    //    if( dic_DataMap == nil )    //temp글 일시
    //    {
    //        dic_DataMap = dic;
    //    }
    //
    //    NSString *str_Images = [dic_DataMap objectForKey:@"qnaBody"];
    //    NSArray *ar_Images = [str_Images componentsSeparatedByString:@"|"];
    //
    //    __block CGFloat fSampleViewTotalHeight = 0;
    //    if( ar_Images.count == 1 )
    //    {
    //        [[TMImageZoom shared] gestureStateChanged:gesture withZoomImageView:(UIImageView *)gesture.view];
    //    }
    //    else
    //    {
    //        UIImageView *iv_Base = [[UIImageView alloc] init];
    //        iv_Base.userInteractionEnabled = YES;
    //
    //        for( NSInteger i = ar_Images.count - 1; i >= 0; i-- )
    //        {
    //            NSString *str_ImageUrl = ar_Images[i];
    //            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, fSampleViewTotalHeight, self.tbv_List.frame.size.width, 0)];
    //            [iv sd_setImageWithURL:[Util createImageUrl:str_ImagePreFix withFooter:str_ImageUrl]];
    //            iv.image = [Util imageWithImage:iv.image convertToWidth:self.tbv_List.frame.size.width];
    //            iv.userInteractionEnabled = YES;
    //
    //            CGRect frame = iv.frame;
    //            frame.size.height = iv.image.size.height;
    //            iv.frame = frame;
    //
    //            fSampleViewTotalHeight += iv.frame.size.height;
    //
    //            [iv_Base addSubview:iv];
    //        }
    //
    //        iv_Base.frame = CGRectMake(0, 0, self.tbv_List.frame.size.width, fSampleViewTotalHeight);
    //
    //        [[TMImageZoom shared] gestureStateChanged:gesture withZoomImageView:iv_Base];
    //    }
    
    
    
    
    
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    //구매했고 문제집 공유일 경우는 문제집 시작 페이지로
    SBDBaseMessage *baseMessage = self.messages[gesture.view.tag];
    SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
    NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self didSelectedItem:dic];
    
}

- (void)otherImageCell:(OtherImageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withVideo:(BOOL)isVideo
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    //    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        //        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
        
        NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        
        cell.iv_User.tag = indexPath.row;
        cell.iv_User.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:imageTap];
        
        
        if( [str_ChatType isEqualToString:@"group"] )
        {
            cell.lb_Name.hidden = NO;
        }
        else if( [str_ChatType isEqualToString:@"channel"] )
        {
            cell.lb_Name.hidden = NO;
        }
        else if( [str_ChatType isEqualToString:@"user"] )
        {
            cell.lb_Name.hidden = YES;
        }
        
        cell.lb_Name.text = [dic objectForKey_YM:@"name"];
        
        if( isVideo == NO )
        {
            cell.v_Video.hidden = YES;
            
            [cell.btn_Origin removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            
            if( [[dic_Body objectForKey:@"qnaType"] isEqualToString:@"pdfQuestion"] )
            {
                cell.btn_Origin.tag = indexPath.row;
                cell.btn_Read.hidden = YES;
                cell.lb_Date.hidden = YES;
                
                cell.btn_Origin.hidden = NO;
                [cell.btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic objectForKey_YM:@"examTitle"]] forState:UIControlStateNormal];
                [cell.btn_Origin addTarget:self action:@selector(onMoveToPdf:) forControlEvents:UIControlEventTouchUpInside];
                
                NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
                NSArray *ar_Tmp = [str_Contents componentsSeparatedByString:@"|"];
                if( ar_Tmp && ar_Tmp.count > 0 )
                {
                    NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:[ar_Tmp firstObject]];
                    //                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", str_ImagePreFix, [ar_Tmp firstObject]]];
                    [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
                }
            }
            else
            {
                NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
                NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:str_Contents];
                [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
                
                cell.iv_Contents.userInteractionEnabled = YES;
                cell.iv_Contents.tag = indexPath.row;
                UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
                pinchZoom.delegate = self;
                [cell.iv_Contents addGestureRecognizer:pinchZoom];
            }
        }
        else if( isVideo )
        {
            cell.v_Video.hidden = NO;
            NSString *str_Contents = [dic_Body objectForKey:@"videoCoverPath"];
            NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:str_Contents];
            [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
        }
        
        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
    }
}

- (void)myShareExamCell:(MyShareExamCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    shareUserCount = 3;
    //    solveUserCount = 3;
    
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    //푼 사람 수
    NSString *str_SolveCnt = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"solveUserCount"]];
    
    //전체 공유한 인원 수
    NSString *str_ShareCnt = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"shareUserCount"]];
    
    if( [str_SolveCnt integerValue] > 0 )
    {
        //푼 사람이 있을 시
        [cell.btn_Result setTitle:[NSString stringWithFormat:@"%@ / %@", str_SolveCnt, str_ShareCnt] forState:UIControlStateNormal];
        [cell.btn_Result setBackgroundColor:[UIColor colorWithHexString:@"F75E00"]];
    }
    else
    {
        //푼 사람이 없을 시
        [cell.btn_Result setTitle:@"결과" forState:UIControlStateNormal];
        //        [cell.btn_Result setBackgroundColor:[UIColor colorWithHexString:@"FFC600"]];
    }
    
    cell.btn_Result.tag = indexPath.row;
    [cell.btn_Result addTarget:self action:@selector(onShowResulte:) forControlEvents:UIControlEventTouchUpInside];
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
    NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    
    cell.lb_Contents.text = str_ShareMsg;
    
    cell.lb_Msg.text = [dic_ActionMap objectForKey_YM:@"examTitle"];
    
    cell.lb_SubjectName.text = [NSString stringWithFormat:@"#%@", [dic_ActionMap objectForKey_YM:@"subjectName"]];
    cell.lb_SubjectName.backgroundColor = [UIColor colorWithHexString:[dic_ActionMap objectForKey_YM:@"codeHex"]];
    
    cell.lc_ResultWidth.constant = 60.f;
}

- (void)otherShareExamCell:(OtherShareExamCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    cell.lc_ResultWidth.constant = 0;
    
    //    //푼 사람 수
    //    NSString *str_SolveCnt = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"solveUserCount"]];
    //
    //    //전체 공유한 인원 수
    //    NSString *str_ShareCnt = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"shareUserCount"]];
    //
    //    if( [str_SolveCnt integerValue] > 0 )
    //    {
    //        //푼 사람이 있을 시
    //        [cell.btn_Result setTitle:[NSString stringWithFormat:@"%@ / %@", str_SolveCnt, str_ShareCnt] forState:UIControlStateNormal];
    //        [cell.btn_Result setBackgroundColor:[UIColor colorWithHexString:@"F75E00"]];
    //    }
    //    else
    //    {
    //        //푼 사람이 없을 시
    //        [cell.btn_Result setTitle:@"결과" forState:UIControlStateNormal];
    //        [cell.btn_Result setBackgroundColor:[UIColor colorWithHexString:@"FFC600"]];
    //    }
    
    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
    NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
    
    cell.lb_Name.text = [dic_ActionMap objectForKey_YM:@"name"];
    
    NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
    [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
    
    cell.lb_Contents.text = str_ShareMsg;
    
    cell.lb_Msg.text = [dic_ActionMap objectForKey_YM:@"examTitle"];
    
    cell.lb_SubjectName.text = [NSString stringWithFormat:@"#%@", [dic_ActionMap objectForKey_YM:@"subjectName"]];
    cell.lb_SubjectName.backgroundColor = [UIColor colorWithHexString:[dic_ActionMap objectForKey_YM:@"codeHex"]];
}

- (void)myFollowingCell:(MyCmdFollowingCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
    NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    
    cell.lb_Contents.text = str_ShareMsg;
    
    if( ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        if( [str_QnaType isEqualToString:@"text"] )
        {
            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
            cell.lb_Msg.text = str_Contents;
            //            cell.lb_Contents.text = str_Contents;
            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
        }
        else if( [str_QnaType isEqualToString:@""] )
        {
            
        }
    }
}

- (void)otherFollowingCell:(OtherCmdFollowingCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
    NSString *str_ShareMsg = [dic_ActionMap objectForKey_YM:@"shareMsg"];
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    
    NSString *str_MsgType = [dic objectForKey_YM:@"msgType"];
    if( [str_MsgType isEqualToString:@"regist-member"] )
    {
        cell.lb_Msg.text = @"인증하기";
    }
    else if( [str_MsgType isEqualToString:@"channel-follow"] )
    {
        cell.lb_Msg.text = [dic_ActionMap objectForKey_YM:@"channelName"];
    }
    else
    {
        cell.lb_Msg.text = str_ShareMsg;
    }
    
    if( ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        if( [str_QnaType isEqualToString:@"text"] )
        {
            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
            cell.lb_Contents.text = str_Contents;
            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            
            NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
            [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
            
            cell.iv_User.tag = indexPath.row;
            cell.iv_User.userInteractionEnabled = YES;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
            [imageTap setNumberOfTapsRequired:1];
            [cell.iv_User addGestureRecognizer:imageTap];
            
            if( [str_ChatType isEqualToString:@"group"] )
            {
                cell.lb_Name.hidden = NO;
            }
            else if( [str_ChatType isEqualToString:@"channel"] )
            {
                cell.lb_Name.hidden = NO;
            }
            else if( [str_ChatType isEqualToString:@"user"] )
            {
                cell.lb_Name.hidden = YES;
            }
            
            cell.lb_Name.text = [dic objectForKey_YM:@"name"];
        }
        else if( [str_QnaType isEqualToString:@""] )
        {
            
        }
    }
}

- (void)myShareExamNoMsgCell:(MyShareExamNoMsgCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    //푼 사람 수
    NSString *str_SolveCnt = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"solveUserCount"]];
    
    //전체 공유한 인원 수
    NSString *str_ShareCnt = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"shareUserCount"]];
    
    if( [str_SolveCnt integerValue] > 0 )
    {
        //푼 사람이 있을 시
        [cell.btn_Result setTitle:[NSString stringWithFormat:@"%@ / %@", str_SolveCnt, str_ShareCnt] forState:UIControlStateNormal];
        [cell.btn_Result setBackgroundColor:[UIColor colorWithHexString:@"F75E00"]];
    }
    else
    {
        //푼 사람이 없을 시
        [cell.btn_Result setTitle:@"결과" forState:UIControlStateNormal];
        //        [cell.btn_Result setBackgroundColor:[UIColor colorWithHexString:@"FFC600"]];
    }
    
    cell.btn_Result.tag = indexPath.row;
    [cell.btn_Result addTarget:self action:@selector(onShowResulte:) forControlEvents:UIControlEventTouchUpInside];
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
    
    cell.lb_Contents.text = [dic_ActionMap objectForKey_YM:@"examTitle"];
    
    cell.lb_SubjectName.text = [NSString stringWithFormat:@"#%@", [dic_ActionMap objectForKey_YM:@"subjectName"]];
    cell.lb_SubjectName.backgroundColor = [UIColor colorWithHexString:[dic_ActionMap objectForKey_YM:@"codeHex"]];
    
    cell.lc_ResultWidth.constant = 60.f;
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    //    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    //    if( ar_Body.count > 0 )
    //    {
    //        NSDictionary *dic_Body = [ar_Body firstObject];
    //        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
    //        if( [str_QnaType isEqualToString:@"text"] )
    //        {
    //            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
    ////            cell.lb_Contents.text = str_Contents;
    ////            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
    //        }
    //        else if( [str_QnaType isEqualToString:@""] )
    //        {
    //
    //        }
    //    }
}

- (void)onShowResulte:(UIButton *)btn
{
    id message = self.messages[btn.tag];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[btn.tag];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
    ChatReportViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatReportViewController"];
    vc.dic_Info = dic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)otherShareExamNoMsgCell:(OtherShareExamNoMsgCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    //    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    cell.lc_ResultWidth.constant = 0;
    
    NSDictionary *dic_ActionMap = [dic objectForKey:@"actionMap"];
    
    cell.lb_Name.text = [dic_ActionMap objectForKey_YM:@"name"];
    
    NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
    [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
    
    cell.lb_Contents.text = [dic_ActionMap objectForKey_YM:@"examTitle"];
    
    cell.lb_SubjectName.text = [NSString stringWithFormat:@"#%@", [dic_ActionMap objectForKey_YM:@"subjectName"]];
    cell.lb_SubjectName.backgroundColor = [UIColor colorWithHexString:[dic_ActionMap objectForKey_YM:@"codeHex"]];
    
    
    //    //푼 사람 수
    //    NSString *str_SolveCnt = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"solveUserCount"]];
    //
    //    //전체 공유한 인원 수
    //    NSString *str_ShareCnt = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"shareUserCount"]];
    //
    //    if( [str_SolveCnt integerValue] > 0 )
    //    {
    //        //푼 사람이 있을 시
    //        [cell.btn_Result setTitle:[NSString stringWithFormat:@"%@ / %@", str_SolveCnt, str_ShareCnt] forState:UIControlStateNormal];
    //        [cell.btn_Result setBackgroundColor:[UIColor colorWithHexString:@"F75E00"]];
    //    }
    //    else
    //    {
    //        //푼 사람이 없을 시
    //        [cell.btn_Result setTitle:@"결과" forState:UIControlStateNormal];
    //        [cell.btn_Result setBackgroundColor:[UIColor colorWithHexString:@"FFC600"]];
    //    }
    
    //    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    //    if( ar_Body.count > 0 )
    //    {
    //        NSDictionary *dic_Body = [ar_Body firstObject];
    //        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
    //        if( [str_QnaType isEqualToString:@"text"] )
    //        {
    //            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
    ////            cell.lb_Contents.text = str_Contents;
    ////            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
    //
    //            NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
    //            [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
    //
    //            cell.iv_User.tag = indexPath.row;
    //            cell.iv_User.userInteractionEnabled = YES;
    //            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
    //            [imageTap setNumberOfTapsRequired:1];
    //            [cell.iv_User addGestureRecognizer:imageTap];
    //
    //            if( [str_ChatType isEqualToString:@"group"] )
    //            {
    //                cell.lb_Name.hidden = NO;
    //            }
    //            else if( [str_ChatType isEqualToString:@"channel"] )
    //            {
    //                cell.lb_Name.hidden = NO;
    //            }
    //            else if( [str_ChatType isEqualToString:@"user"] )
    //            {
    //                cell.lb_Name.hidden = YES;
    //            }
    //
    //            cell.lb_Name.text = [dic objectForKey_YM:@"name"];
    //        }
    //        else if( [str_QnaType isEqualToString:@""] )
    //        {
    //
    //        }
    //    }
}

- (void)hidenDateIfNeed:(MyChatBasicCell *)cell indexPath:(NSIndexPath *)indexPath
{
    //    if( self.arM_List.count > indexPath.row + 1 )
    //    {
    //        NSDictionary *dic_Tmp = self.arM_List[indexPath.row + 1];
    //        NSDictionary *dic_Tmp2 = self.arM_List[indexPath.row];
    //
    //        NSInteger nOwerId = [[dic_Tmp objectForKey:@"userId"] integerValue];
    //        NSInteger nOwerId2 = [[dic_Tmp2 objectForKey:@"userId"] integerValue];
    //
    //        NSString *str_MsgType = [dic_Tmp objectForKey:@"msgType"];
    //        if( [str_MsgType isEqualToString:@"shareExam"] || [str_MsgType isEqualToString:@"shareQuestion"] || [[dic_Tmp objectForKey_YM:@"itemType"] isEqualToString:@"cmd"] )
    //        {
    //            cell.lb_Date.hidden = cell.iv_User.hidden = NO;
    //            cell.lc_NameHeight.constant = 15.f;
    //            cell.lc_BottomHeight.constant = 15.f;
    //        }
    //        else
    //        {
    //            if( nOwerId == nOwerId2 )
    //            {
    //                cell.lb_Date.hidden = cell.iv_User.hidden = YES;
    //                cell.lc_NameHeight.constant = 0;
    //                cell.lc_BottomHeight.constant = 2;
    //            }
    //            else
    //            {
    //                cell.lb_Date.hidden = cell.iv_User.hidden = NO;
    //                cell.lc_NameHeight.constant = 15.f;
    //                cell.lc_BottomHeight.constant = 15.f;
    //            }
    //        }
    //    }
    //    else
    //    {
    //        cell.lb_Date.hidden = cell.iv_User.hidden = NO;
    //        cell.lc_NameHeight.constant = 15.f;
    //        cell.lc_BottomHeight.constant = 15.f;
    //    }
    //
    //    //같은 사람이 쓴 글 붙이기 위해서
    //    if( indexPath.row > 0 )
    //    {
    //        NSDictionary *dic_Tmp = self.arM_List[indexPath.row - 1];
    //        NSDictionary *dic_Tmp2 = self.arM_List[indexPath.row];
    //
    //        NSInteger nOwerId = [[dic_Tmp objectForKey:@"userId"] integerValue];
    //        NSInteger nOwerId2 = [[dic_Tmp2 objectForKey:@"userId"] integerValue];
    //
    //        if( nOwerId == nOwerId2 )
    //        {
    //            cell.lc_NameHeight.constant = 0;
    //            cell.lc_BottomHeight.constant = 0;
    //        }
    //    }
    //
    //
    //    //푼 문제에 대한 이름 영역은 표시해준다
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    //    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    //    if( ar_Body.count > 0 )
    //    {
    //        NSDictionary *dic_Body = [ar_Body firstObject];
    //        if( [[dic_Body objectForKey_YM:@"msgType"] isEqualToString:@"solveExam"] )
    //        {
    //            cell.lc_NameHeight.constant = 15.f;
    //        }
    //    }
    //
    //    [cell setNeedsLayout];
    //    [cell updateConstraints];
    //
    //    [cell.contentView setNeedsLayout];
    //    [cell.contentView updateConstraints];
    //
    //    [cell.lb_Contents setNeedsLayout];
    //    [cell.lb_Contents updateConstraints];
    //
    //    [cell.lb_Date setNeedsLayout];
    //    [cell.lb_Date updateConstraints];
    
}

- (void)myTextCell:(MyChatBasicCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        if( [str_QnaType isEqualToString:@"text"] )
        {
            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            
            [self addContent:cell withString:[dic_Body objectForKey:@"qnaBody"]];
        }
    }
}

- (void)addContent:(OtherChatBasicCell *)cell withString:(NSString *)aContents
{
    aContents = [NSString stringWithFormat:@"%@", aContents];
    NSDictionary *textAttr = @{ NSFontAttributeName: cell.lb_Contents.font,
                                //                                        NSParagraphStyleAttributeName: ps,
                                NSForegroundColorAttributeName: cell.lb_Contents.textColor };
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:aContents attributes:textAttr];
    
    cell.lb_Contents.text = str;
    cell.lb_Contents.attributedText = str;
    cell.lb_Contents.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    cell.lb_Contents.delegate = self;
    //            NSRange range = [cell.lb_Contents.text rangeOfString:@"www.naver.com"];
    //            [cell.lb_Contents addLinkToURL:[NSURL URLWithString:@"www.naver.com"] withRange:range];
    
    
    NSRange range1 = [cell.lb_Contents.text rangeOfString:@"www"];
    NSRange range2 = [cell.lb_Contents.text rangeOfString:@"http"];
    NSRange range3 = [cell.lb_Contents.text rangeOfString:@"https"];
    if( range1.location == NSNotFound && range2.location == NSNotFound && range3.location == NSNotFound )
    {
        //3개다 없으면 링크 아니라고 판단
        [self addTapGesture:cell];
    }
    else
    {
        for( UIGestureRecognizer *ges in cell.gestureRecognizers )
        {
            if( [ges isKindOfClass:[UILongPressGestureRecognizer class]] == NO )
            {
                [cell removeGestureRecognizer:ges];
            }
        }
    }
}

- (void)myDirectCell:(MyDirectChatCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body && ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        NSDictionary *dic_Action = [dic objectForKey:@"actionMap"];
        
        if( [str_QnaType isEqualToString:@"text"] )
        {
            //            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
            cell.lb_Contents.text = [dic_Action objectForKey_YM:@"examTitle"];
            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            cell.lb_QNum.text = [NSString stringWithFormat:@"(%ld)번 문제", [[dic_Action objectForKey_YM:@"examNo"] integerValue]];
        }
        else if( [str_QnaType isEqualToString:@""] )
        {
            
        }
    }
    else
    {
        NSDictionary *dic_Action = [dic objectForKey:@"actionMap"];
        cell.lb_Contents.text = [dic_Action objectForKey_YM:@"examTitle"];
        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        cell.lb_QNum.text = [NSString stringWithFormat:@"(%ld)번 문제", [[dic_Action objectForKey_YM:@"examNo"] integerValue]];
    }
}

- (void)myDirectMsgCell:(MyDirectChatMsgCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body && ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        NSDictionary *dic_Action = [dic objectForKey:@"actionMap"];
        
        if( [str_QnaType isEqualToString:@"text"] )
        {
            //            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
            cell.lb_Contents.text = [dic_Action objectForKey_YM:@"examTitle"];
            cell.lb_QNum.text = [NSString stringWithFormat:@"(%ld)번 문제", [[dic_Action objectForKey_YM:@"examNo"] integerValue]];
            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            if( [[dic_Action objectForKey_YM:@"msgType"] isEqualToString:@"shareQuestion"] )
            {
                cell.lb_Msg.text = [dic_Action objectForKey_YM:@"shareMsg"];
            }
            else
            {
                cell.lb_Msg.text = [dic_Body objectForKey_YM:@"qnaBody"];
            }
        }
        else if( [str_QnaType isEqualToString:@""] )
        {
            
        }
    }
    else
    {
        NSDictionary *dic_Action = [dic objectForKey:@"actionMap"];
        
        cell.lb_Contents.text = [dic_Action objectForKey_YM:@"examTitle"];
        cell.lb_QNum.text = [NSString stringWithFormat:@"(%ld)번 문제", [[dic_Action objectForKey_YM:@"examNo"] integerValue]];
        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"createDate"]]];
        if( [[dic_Action objectForKey_YM:@"msgType"] isEqualToString:@"shareQuestion"] )
        {
            cell.lb_Msg.text = [dic_Action objectForKey_YM:@"shareMsg"];
        }
        else
        {
            //            cell.lb_Msg.text = [dic_Body objectForKey_YM:@"qnaBody"];
        }
    }
}

- (void)myTextCellTemp:(MyChatBasicCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    //    if( [[dic objectForKey:@"check"] isEqualToString:@"Y"] )
    //    {
    //        cell.btn_Read.selected = YES;
    //    }
    //    else
    //    {
    //        cell.btn_Read.selected = NO;
    //    }
    
    cell.btn_Read.selected = NO;
    
    if( [[dic objectForKey_YM:@"isFail"] isEqualToString:@"YES"] )
    {
        [cell.btn_Read setImage:BundleImage(@"chat_check_fail.png") forState:UIControlStateNormal];
    }
    else
    {
        [cell.btn_Read setImage:BundleImage(@"chat_no_check.png") forState:UIControlStateNormal];
    }
    
    cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
    [self addContent:cell withString:[dic objectForKey:@"contents"]];
    
    //    cell.lb_Contents.text = [dic objectForKey:@"contents"];
}

- (void)cmdCell:(CmdChatCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.v_Bg.backgroundColor = [UIColor colorWithHexString:@"ECEFF1"];
    
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_JOIN"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_LEFT"] )
    {
        //초대, 나감
        cell.lb_Cmd.text = [dic objectForKey:@"message"];
    }
    else if( [[dic objectForKey:@"type"] isEqualToString:@"USER_ENTER"] )
    {
        //입장
        //        [self.navigationController.view makeToast:[dic objectForKey:@"message"] withPosition:kPositionCenter];
    }
    
    //    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    //    if( ar_Body.count > 0 )
    //    {
    //        NSDictionary *dic_Body = [ar_Body firstObject];
    //        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
    //        if( [str_QnaType isEqualToString:@"text"] )
    //        {
    //            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
    //            cell.lb_Cmd.text = str_Contents;
    ////            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
    //        }
    //    }
}

- (void)otherTextCell:(OtherChatBasicCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
//    if( self.dic_BotInfo )
    if( 1 ) //20170901 챗봇처럼 상대방 메세지를 하얗게 표시해 달라고 피터님이 요청함
    {
        cell.lb_Contents.textColor = [UIColor darkGrayColor];
        cell.v_ContentsBg.backgroundColor = [UIColor whiteColor];
        cell.v_ContentsBg.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
        cell.v_ContentsBg.layer.borderWidth = 1.f;
    }
    else
    {
        cell.lb_Contents.textColor = [UIColor whiteColor];
        cell.v_ContentsBg.backgroundColor = [UIColor colorWithHexString:@"4FB826"];
        cell.v_ContentsBg.layer.borderColor = [UIColor clearColor].CGColor;
        cell.v_ContentsBg.layer.borderWidth = 1.f;
    }
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        if( [str_QnaType isEqualToString:@"text"] )
        {
            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
            [self addContent:cell withString:str_Contents];
            //            cell.lb_Contents.text = str_Contents;
            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            
            NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
            [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
            
            cell.iv_User.tag = indexPath.row;
            cell.iv_User.userInteractionEnabled = YES;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
            [imageTap setNumberOfTapsRequired:1];
            [cell.iv_User addGestureRecognizer:imageTap];
            
            if( [str_ChatType isEqualToString:@"group"] )
            {
                cell.lb_Name.hidden = NO;
            }
            else if( [str_ChatType isEqualToString:@"channel"] )
            {
                cell.lb_Name.hidden = NO;
            }
            else if( [str_ChatType isEqualToString:@"user"] )
            {
                cell.lb_Name.hidden = YES;
            }
            
            if( [[dic_Body objectForKey_YM:@"msgType"] isEqualToString:@"solveExam"] )
            {
                cell.lb_Name.text = [NSString stringWithFormat:@"%@: #%@, %@",
                                     [dic objectForKey_YM:@"name"], [dic objectForKey_YM:@"subjectName"], [dic objectForKey_YM:@"examTitle"]];
            }
            else
            {
                cell.lb_Name.text = [dic objectForKey_YM:@"name"];
            }
        }
        else if( [str_QnaType isEqualToString:@""] )
        {
            
        }
    }
}

- (void)otherDirectCell:(OtherDirectChatCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body && ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        NSDictionary *dic_Action = [dic objectForKey:@"actionMap"];
        
        if( [str_QnaType isEqualToString:@"text"] )
        {
            //            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
            cell.lb_Contents.text = [dic_Action objectForKey_YM:@"examTitle"];
            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            cell.lb_QNum.text = [NSString stringWithFormat:@"(%ld)번 문제", [[dic_Action objectForKey_YM:@"examNo"] integerValue]];
            
            NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
            [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
            
            cell.iv_User.tag = indexPath.row;
            cell.iv_User.userInteractionEnabled = YES;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
            [imageTap setNumberOfTapsRequired:1];
            [cell.iv_User addGestureRecognizer:imageTap];
            
            if( [str_ChatType isEqualToString:@"group"] )
            {
                cell.lb_Name.hidden = NO;
            }
            else if( [str_ChatType isEqualToString:@"channel"] )
            {
                cell.lb_Name.hidden = NO;
            }
            else if( [str_ChatType isEqualToString:@"user"] )
            {
                cell.lb_Name.hidden = YES;
            }
            
            if( [[dic_Body objectForKey_YM:@"msgType"] isEqualToString:@"solveExam"] )
            {
                cell.lb_Name.text = [NSString stringWithFormat:@"%@: #%@, %@",
                                     [dic objectForKey_YM:@"name"], [dic objectForKey_YM:@"subjectName"], [dic objectForKey_YM:@"examTitle"]];
            }
            else
            {
                cell.lb_Name.text = [dic objectForKey_YM:@"name"];
            }
        }
        else if( [str_QnaType isEqualToString:@""] )
        {
            
        }
    }
    else
    {
        NSDictionary *dic_Action = [dic objectForKey:@"actionMap"];
        
        cell.lb_Contents.text = [dic_Action objectForKey_YM:@"examTitle"];
        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        cell.lb_QNum.text = [NSString stringWithFormat:@"(%ld)번 문제", [[dic_Action objectForKey_YM:@"examNo"] integerValue]];
        
        NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        cell.iv_User.tag = indexPath.row;
        cell.iv_User.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:imageTap];
        
        if( [str_ChatType isEqualToString:@"group"] )
        {
            cell.lb_Name.hidden = NO;
        }
        else if( [str_ChatType isEqualToString:@"channel"] )
        {
            cell.lb_Name.hidden = NO;
        }
        else if( [str_ChatType isEqualToString:@"user"] )
        {
            cell.lb_Name.hidden = YES;
        }
        
        //        if( [[dic_Body objectForKey_YM:@"msgType"] isEqualToString:@"solveExam"] )
        //        {
        //            cell.lb_Name.text = [NSString stringWithFormat:@"%@: #%@, %@",
        //                                 [dic objectForKey_YM:@"name"], [dic objectForKey_YM:@"subjectName"], [dic objectForKey_YM:@"examTitle"]];
        //        }
        //        else
        //        {
        //            cell.lb_Name.text = [dic objectForKey_YM:@"name"];
        //        }
    }
}

- (void)otherDirectMsgCell:(OtherDirectChatMsgCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body && ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        NSDictionary *dic_Action = [dic objectForKey:@"actionMap"];
        if( [str_QnaType isEqualToString:@"text"] )
        {
            //            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
            cell.lb_Contents.text = [dic_Action objectForKey_YM:@"examTitle"];
            cell.lb_QNum.text = [NSString stringWithFormat:@"(%ld)번 문제", [[dic_Action objectForKey_YM:@"examNo"] integerValue]];
            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            if( [[dic_Action objectForKey_YM:@"msgType"] isEqualToString:@"shareQuestion"] )
            {
                cell.lb_Msg.text = [dic_Action objectForKey_YM:@"shareMsg"];
            }
            else
            {
                cell.lb_Msg.text = [dic_Body objectForKey_YM:@"qnaBody"];
            }
            
            NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
            [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
            
            cell.iv_User.tag = indexPath.row;
            cell.iv_User.userInteractionEnabled = YES;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
            [imageTap setNumberOfTapsRequired:1];
            [cell.iv_User addGestureRecognizer:imageTap];
            
            if( [str_ChatType isEqualToString:@"group"] )
            {
                cell.lb_Name.hidden = NO;
            }
            else if( [str_ChatType isEqualToString:@"channel"] )
            {
                cell.lb_Name.hidden = NO;
            }
            else if( [str_ChatType isEqualToString:@"user"] )
            {
                cell.lb_Name.hidden = YES;
            }
            
            if( [[dic_Body objectForKey_YM:@"msgType"] isEqualToString:@"solveExam"] )
            {
                cell.lb_Name.text = [NSString stringWithFormat:@"%@: #%@, %@",
                                     [dic objectForKey_YM:@"name"], [dic objectForKey_YM:@"subjectName"], [dic objectForKey_YM:@"examTitle"]];
            }
            else
            {
                cell.lb_Name.text = [dic objectForKey_YM:@"name"];
            }
        }
        else if( [str_QnaType isEqualToString:@""] )
        {
            
        }
    }
    else
    {
        NSDictionary *dic_Action = [dic objectForKey:@"actionMap"];
        cell.lb_Name.text = [dic_Action objectForKey_YM:@"name"];
        cell.lb_Contents.text = [dic_Action objectForKey_YM:@"examTitle"];
        cell.lb_QNum.text = [NSString stringWithFormat:@"(%ld)번 문제", [[dic_Action objectForKey_YM:@"examNo"] integerValue]];
        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        if( [[dic_Action objectForKey_YM:@"msgType"] isEqualToString:@"shareQuestion"] )
        {
            cell.lb_Msg.text = [dic_Action objectForKey_YM:@"shareMsg"];
        }
        else
        {
            //            cell.lb_Msg.text = [dic_Body objectForKey_YM:@"qnaBody"];
        }
        
        NSURL *url = [Util createImageUrl:str_ImagePrefix withFooter:[dic objectForKey_YM:@"userThumbnail"]];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        cell.iv_User.tag = indexPath.row;
        cell.iv_User.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:imageTap];
        
        if( [str_ChatType isEqualToString:@"group"] )
        {
            cell.lb_Name.hidden = NO;
        }
        else if( [str_ChatType isEqualToString:@"channel"] )
        {
            cell.lb_Name.hidden = NO;
        }
        else if( [str_ChatType isEqualToString:@"user"] )
        {
            cell.lb_Name.hidden = YES;
        }
        
        //        if( [[dic_Body objectForKey_YM:@"msgType"] isEqualToString:@"solveExam"] )
        //        {
        //            cell.lb_Name.text = [NSString stringWithFormat:@"%@: #%@, %@",
        //                                 [dic objectForKey_YM:@"name"], [dic objectForKey_YM:@"subjectName"], [dic objectForKey_YM:@"examTitle"]];
        //        }
        //        else
        //        {
        //            cell.lb_Name.text = [dic objectForKey_YM:@"name"];
        //        }
    }
}

//- (NSString *)getDday:(NSString *)aDay
//{
//    aDay = [aDay stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    aDay = [aDay stringByReplacingOccurrencesOfString:@" " withString:@""];
//    aDay = [aDay stringByReplacingOccurrencesOfString:@":" withString:@""];
//
//    NSString *str_Year = [aDay substringWithRange:NSMakeRange(0, 4)];
//    NSString *str_Month = [aDay substringWithRange:NSMakeRange(4, 2)];
//    NSString *str_Day = [aDay substringWithRange:NSMakeRange(6, 2)];
//    NSString *str_Hour = [aDay substringWithRange:NSMakeRange(8, 2)];
//    NSString *str_Minute = [aDay substringWithRange:NSMakeRange(10, 2)];
//    NSString *str_Second = [aDay substringWithRange:NSMakeRange(12, 2)];
//    NSString *str_Date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", str_Year, str_Month, str_Day, str_Hour, str_Minute, str_Second];
//
//    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
//    [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
//
//    NSDate *ddayDate = [format1 dateFromString:str_Date];
//
//    NSDate *date = [NSDate date];
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
//    NSInteger nYear = [components year];
//    NSInteger nMonth = [components month];
//    NSInteger nDay = [components day];
//    NSInteger nHour = [components hour];
//    NSInteger nMinute = [components minute];
//    NSInteger nSecond = [components second];
//
//    NSDate *currentTime = [format1 dateFromString:[NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond]];
//
//    NSTimeInterval diff = [currentTime timeIntervalSinceDate:ddayDate];
//
//    NSTimeInterval nWriteTime = diff;
//
//
//
//
//    if( nWriteTime > (60 * 60 * 24) )
//    {
//        //        return [NSString stringWithFormat:@"%@-%@-%@", str_Year, str_Month, str_Day];
//        return [NSString stringWithFormat:@"%@월 %@일", str_Month, str_Day];
//    }
//    else
//    {
//        if( nWriteTime <= 0 )
//        {
//            return @"1초전";
//        }
//        else if( nWriteTime < 60 )
//        {
//            //1분보다 작을 경우
//            return [NSString stringWithFormat:@"%.0f초전", nWriteTime];
//        }
//        else if( nWriteTime < (60 * 60) )
//        {
//            //1시간보다 작을 경우
//            return [NSString stringWithFormat:@"%.0f분전", nWriteTime / 60];
//        }
//        else
//        {
//            return [NSString stringWithFormat:@"%.0f시간전", ((nWriteTime / 60) / 60)];
//        }
//    }
//
//
//    return @"";
//}


#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _ar_Photo.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _ar_Photo.count)
        return [_ar_Photo objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < _thumbs.count)
    {
        return [_thumbs objectAtIndex:index];
    }
    return nil;
}


- (IBAction)goChatRoomBack:(id)sender
{
    [self.channel markAsRead];
    
    NSMutableArray *arM_Temp = [NSMutableArray arrayWithArray:self.arM_List];
    //    if( arM_Temp.count > 40 )
    //    {
    //        [arM_Temp removeObjectsInRange:NSMakeRange(40, (arM_Temp.count - 40))];
    //    }
    
    //    NSString *str_Key = [NSString stringWithFormat:@"Chat_%@", self.str_RId];
    //    NSData *dictionaryData = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    //    NSMutableDictionary *dicM = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
    //    [dicM setObject:arM_Temp forKey:@"data"];
    //
    //    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM];
    //    [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_Key];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //
    //    //내가 들어가 있던 방 나올땐 뱃지 카운트 0으로 하고 나오기
    //    NSString *str_CountKey = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    //    NSMutableDictionary *dicM_Count = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:str_CountKey]];
    //    [dicM_Count setObject:@"0" forKey:[NSString stringWithFormat:@"%ld", [self.str_RId integerValue]]];
    //    [[NSUserDefaults standardUserDefaults] setObject:dicM_Count forKey:str_CountKey];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //메세지 읽음 처리 서버로 보내기
    //    __weak __typeof__(self) weakSelf = self;
    //
    //    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
    //                                        [Util getUUID], @"uuid",
    //                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"nId"]], @"nId",
    //                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"pkId"]], @"pkId",
    //                                        nil];
    //
    //    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/read/noti"
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
    //                                                NSInteger nBadgeCnt = [[resulte objectForKey:@"notiCount"] integerValue];
    //                                                if( nBadgeCnt == 0 )
    //                                                {
    //                                                    [[weakSelf navigationController] tabBarItem].badgeValue = nil;
    //                                                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //                                                }
    //                                                else
    //                                                {
    //                                                    [[weakSelf navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", nBadgeCnt];
    //                                                    [UIApplication sharedApplication].applicationIconBadgeNumber = nBadgeCnt;
    //
    //                                                }
    //                                            }
    //                                            else
    //                                            {
    //                                                //                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
    //                                            }
    //                                        }
    //                                    }];
    
    //    [SendBird leaveChannel:str_ChannelUrl];
    //    [SendBird disconnect];
    
    [self saveChattingMessage];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_RId, @"rId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/exit/chat/room"
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

- (IBAction)goGroupInfo:(id)sender
{
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"추가하기"];
    [arM addObject:@"참여자"];
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
             //추가하기
             [self addMemberList];
         }
         else if( buttonIndex == 1 )
         {
             //참여자
             [self showMemberList];
         }
         else if( buttonIndex == 2 )
         {
             //나가기
             [self leaveChat];
         }
     }];
}

- (void)addMemberList
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
    ChatFeedMemeberInviteViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedMemeberInviteViewController"];
    [vc setCompletionBlock:^(id completeResult) {
        
        NSArray *ar_Users = [NSArray arrayWithArray:[completeResult objectForKey:@"users"]];
        
        //        NSString *str_UserIds = [completeResult objectForKey_YM:@"userId"];
        //        NSArray *ar_Tmp = [str_UserIds componentsSeparatedByString:@","];
        for( NSInteger i = 0; i < ar_Users.count; i++ )
        {
            NSDictionary *dic_Tmp = ar_Users[i];
            [self.arM_User addObject:[dic_Tmp objectForKey:@"userId"]];
        }
        
        NSString *str_MyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        NSString *str_UserName = [completeResult objectForKey_YM:@"userName"];
        NSInteger nCnt = [[completeResult objectForKey_YM:@"count"] integerValue];
        NSString *str_Msg = @"";
        if( nCnt == 1 )
        {
            str_Msg = [NSString stringWithFormat:@"%@님이 %@님을 이 그룹에 추가했습니다.", str_MyName, str_UserName];
        }
        else
        {
            str_Msg = [NSString stringWithFormat:@"%@님이 %@님 외 %ld명을 이 그룹에 추가했습니다.", str_MyName, str_UserName, nCnt - 1];
        }
        
        [self sendMsgCmd:kInviteChat withMsg:str_Msg withUsers:ar_Users];
        
        //대시보드 업데이트 할 데이터 만들기 (lastMsg와 lastChatDate)
        NSDate *date = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
        NSInteger nYear = [components year];
        NSInteger nMonth = [components month];
        NSInteger nDay = [components day];
        NSInteger nHour = [components hour];
        NSInteger nMinute = [components minute];
        NSInteger nSecond = [components second];
        NSString *str_LastChatDate = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond];
        
        
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        [dicM setObject:str_Msg forKey:@"lastMsg"];
        [dicM setObject:str_LastChatDate forKey:@"lastChatDate"];
        [dicM setObject:@"text" forKey:@"msgType"];
        
        [self sendDashboardUpdate:dicM];
    }];
    vc.hidesBottomBarWhenPushed = YES;
    vc.isAddMode = YES;
    vc.dic_Info = self.dic_Info;
    vc.channel = self.channel;
    vc.str_UserImagePrefix = str_UserImagePrefix;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showMemberList
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
    ChatFeedMemeberInviteViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedMemeberInviteViewController"];
    vc.channel = self.channel;
    vc.hidesBottomBarWhenPushed = YES;
    vc.isViewMode = YES;
    vc.dic_Info = self.dic_Info;
    vc.channel = self.channel;
    vc.str_UserImagePrefix = str_UserImagePrefix;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)leaveChat
{
    __weak __typeof(&*self)weakSelf = self;
    
    UIAlertView *alert = CREATE_ALERT(nil, @"대화방을 나가시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                @"menu", @"pageInfo",
                                                @"hide", @"setMode",
                                                self.str_RId, @"rId",
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
                                                        NSString *str_MyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                                                        NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다.", str_MyName];
                                                        [weakSelf sendSendBirdPlatformApi:kLeaveChat withData:nil withMsg:str_Msg];
                                                        
                                                        NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[weakSelf.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                                                        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:[dic_Tmp objectForKey:@"qnaRoomInfos"]];
                                                        id tmp = [dicM objectForKey_YM:@"channelIds"];
                                                        //                                                        if( [tmp isKindOfClass:[NSArray class]] == NO || weakSelf.str_ChannelIdTmp == nil || weakSelf.str_ChannelIdTmp.length <= 0 )
                                                        if( 1 )
                                                        {
                                                            [dicM setObject:[NSArray array] forKey:@"channelIds"];
                                                            NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
                                                            NSError * err;
                                                            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
                                                            NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                            [weakSelf.channel updateChannelWithName:weakSelf.channel.name
                                                                                         isDistinct:weakSelf.channel.isDistinct
                                                                                           coverUrl:weakSelf.channel.coverUrl
                                                                                               data:str_Dic
                                                                                         customType:weakSelf.channel.customType
                                                                                  completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                                                      
                                                                                      [weakSelf.channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                                                                                          
                                                                                          [weakSelf performSelectorOnMainThread:@selector(goChatRoomBack:) withObject:nil waitUntilDone:YES];
                                                                                          //                                                                                      [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                                                                                          //                                                                                      [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                                                          
                                                                                      }];
                                                                                  }];
                                                        }
                                                        //정책 변경으로 방 나가면 모든 방에서 나가도록 변경
                                                        //                                                        else
                                                        //                                                        {
                                                        //                                                            NSMutableArray *arM_ChannelId = [NSMutableArray arrayWithArray:tmp];
                                                        //                                                            for( NSInteger i = 0; i < arM_ChannelId.count; i++ )
                                                        //                                                            {
                                                        //                                                                NSString *str_CurrnetChannelId = arM_ChannelId[i];
                                                        //                                                                if( [weakSelf.str_ChannelIdTmp isEqualToString:str_CurrnetChannelId] )
                                                        //                                                                {
                                                        //                                                                    [arM_ChannelId removeObjectAtIndex:i];
                                                        //                                                                    break;
                                                        //                                                                }
                                                        //                                                            }
                                                        //
                                                        //                                                            [dicM setObject:arM_ChannelId forKey:@"channelIds"];
                                                        //
                                                        //                                                            NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
                                                        //                                                            NSError * err;
                                                        //                                                            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
                                                        //                                                            NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                        //                                                            [weakSelf.channel updateChannelWithName:weakSelf.channel.name
                                                        //                                                                                     isDistinct:weakSelf.channel.isDistinct
                                                        //                                                                                       coverUrl:weakSelf.channel.coverUrl
                                                        //                                                                                           data:str_Dic
                                                        //                                                                                     customType:weakSelf.channel.customType
                                                        //                                                                              completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                        //
                                                        //                                                                                  [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                                                        //                                                                                  [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                        //
                                                        //                                                                              }];
                                                        //                                                        }
                                                        
                                                        
                                                        //                                                        [SBDGroupChannel getChannelWithUrl:self.channel.channelUrl
                                                        //                                                                         completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                        //
                                                        //                                                                             [channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                                                        //
                                                        //                                                                             }];
                                                        //                                                                         }];
                                                        
                                                        
                                                        //                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                                        //                                                                                                             @"userName":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]}
                                                        //                                                                                                   options:NSJSONWritingPrettyPrinted
                                                        //                                                                                                     error:nil];
                                                        //                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                        
                                                        //                                                NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                                                        //                                                NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다.", str_UserName];
                                                        //                                                [self sendMsgCmd:kLeaveChat withMsg:str_Msg];
                                                        
                                                        //                                                //대시보드 업데이트 할 데이터 만들기 (lastMsg와 lastChatDate)
                                                        //                                                NSDate *date = [NSDate date];
                                                        //                                                NSCalendar* calendar = [NSCalendar currentCalendar];
                                                        //                                                NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
                                                        //                                                NSInteger nYear = [components year];
                                                        //                                                NSInteger nMonth = [components month];
                                                        //                                                NSInteger nDay = [components day];
                                                        //                                                NSInteger nHour = [components hour];
                                                        //                                                NSInteger nMinute = [components minute];
                                                        //                                                NSInteger nSecond = [components second];
                                                        //                                                NSString *str_LastChatDate = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond];
                                                        //
                                                        //                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
                                                        //                                                [dicM setObject:str_Msg forKey:@"lastMsg"];
                                                        //                                                [dicM setObject:str_LastChatDate forKey:@"lastChatDate"];
                                                        //                                                [dicM setObject:@"text" forKey:@"msgType"];
                                                        //
                                                        //                                                [self sendDashboardUpdate:dicM];
                                                        //                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveDashboardItem" object:self.str_RId];
                                                        
                                                        
                                                        
                                                        //                                                        NSError * err;
                                                        //                                                        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
                                                        //                                                        NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                        //                                                        NSDictionary *dic_DataMap = [resulte objectForKey:@"dataMap"];
                                                        //                                                        __block NSString *str_Msg = [dic_DataMap objectForKey:@"qnaBody"];
                                                        //
                                                        //                                                        [self.channel sendUserMessage:str_Msg
                                                        //                                                                            data:str_Data
                                                        //                                                                      customType:@"command"
                                                        //                                                               completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                        //
                                                        //                                                                   if( error != nil )
                                                        //                                                                   {
                                                        //                                                                       //에러가 났을 경우
                                                        //                                                                       return ;
                                                        //                                                                   }
                                                        //
                                                        //                                                                   [self.messages addObject:userMessage];
                                                        //
                                                        //                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                        //                                                                       [self.tbv_List reloadData];
                                                        //                                                                       [self.tbv_List layoutIfNeeded];
                                                        //                                                                   });
                                                        //                                                               }];
                                                        
                                                        //                                                        [SBDGroupChannel getChannelWithUrl:self.channel.channelUrl
                                                        //                                                                         completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                        //
                                                        //                                                                             NSError * err;
                                                        //                                                                             NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
                                                        //                                                                             NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                        //                                                                             NSDictionary *dic_DataMap = [resulte objectForKey:@"dataMap"];
                                                        //                                                                             __block NSString *str_Msg = [dic_DataMap objectForKey:@"qnaBody"];
                                                        //
                                                        //                                                                             [channel sendUserMessage:str_Msg
                                                        //                                                                                                 data:str_Data
                                                        //                                                                                           customType:@"command"
                                                        //                                                                                    completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                        //
                                                        //                                                                                        if( error != nil )
                                                        //                                                                                        {
                                                        //                                                                                            //에러가 났을 경우
                                                        //                                                                                            return ;
                                                        //                                                                                        }
                                                        //
                                                        //                                                                                        [self.messages addObject:userMessage];
                                                        //
                                                        //                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                        //                                                                                            [self.tbv_List reloadData];
                                                        //                                                                                            [self.tbv_List layoutIfNeeded];
                                                        //                                                                                        });
                                                        //                                                                                    }];
                                                        //                                                                         }];
                                                        
                                                        
                                                        
                                                        //                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{
                                                        //                                                                                                             @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                                        //                                                                                                             @"channelUrl":str_ChannelUrl}
                                                        //                                                                                                   options:NSJSONWritingPrettyPrinted
                                                        //                                                                                                     error:&error];
                                                        //                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                        //                                                [SendBird sendMessage:@"regist-leave" withData:jsonString];
                                                        ////                                                [SendBird disconnect];
                                                        
                                                    }
                                                    else
                                                    {
                                                        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                    }
                                                }
                                            }];
        }
    }];
    
    
}

- (void)chatTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}

- (void)topImageTap:(UIGestureRecognizer *)gestureRecognizer
{
    if( [str_ChatType isEqualToString:@"group"] )
    {
        NSMutableArray *arM = [NSMutableArray array];
        [arM addObject:@"추가하기"];
        [arM addObject:@"참여자"];
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
                 //추가하기
                 [self addMemberList];
             }
             else if( buttonIndex == 1 )
             {
                 //참여자
                 [self showMemberList];
             }
             else if( buttonIndex == 2 )
             {
                 //나가기
                 [self leaveChat];
             }
         }];
    }
    else if( [str_ChatType isEqualToString:@"user"] )
    {
        NSMutableArray *arM = [NSMutableArray array];
        [arM addObject:[self.dic_Data objectForKey_YM:@"userName"]];
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
                 //유저 페이지로 이동
                 MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
                 vc.isAnotherUser = YES;
                 vc.str_UserIdx = [NSString stringWithFormat:@"%@", [self.dic_Data objectForKey_YM:@"userId"]];
                 [self.navigationController pushViewController:vc animated:YES];
             }
             else if( buttonIndex == 1 )
             {
                 //나가기
                 [self leaveChat];
             }
         }];
    }
}


- (IBAction)goSendMsg:(id)sender
{
    //    [self sendMsgCmd:kInviteChat withMsg:@"초대 메세지 테스트"];
    
    if( self.isAskMode && self.isPdfMode )
    {
        if( self.str_PdfImageUrl )
        {
            
        }
    }
    else if( self.isAskMode && self.dic_NormalQuestionInfo )
    {
        
    }
    else if( self.v_CommentKeyboardAccView.tv_Contents.text.length <= 0 )
    {
        return;
    }
    
    //    NSString *str_Dump = self.v_CommentKeyboardAccView.tv_Contents.text;
    
    [self sendMsg:self.v_CommentKeyboardAccView.tv_Contents.text];
}

- (void)sendNormalQuestion
{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.dic_NormalQuestionInfo options:0 error:&err];
    NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:@"0"];
    [strM appendString:@"-"];
    
    [strM appendString:@"normalQuestion"];
    [strM appendString:@"-"];
    
    [strM appendString:@"0"];
    [strM appendString:@"-"];
    
    [strM appendString:@"N"];
    [strM appendString:@"-"];
    
    NSString *str_Tmp = str_Data;
    NSString *str_NoEncoding = str_Tmp;
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    //[]{}#%^*+=_/
    [strM appendString:str_Tmp];
    
    [MBProgressHUD hide];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        //                                        self.str_RId, @"rId",
                                        strM, @"replyContents",
                                        @"qna", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
                                        @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    //    [self.v_CommentKeyboardAccView removeContents];
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSString *str_CreateTime = [NSString stringWithFormat:@"%04ld%02ld%02ld%02d%02d%02d", nYear, nMonth, nDay, nHour, nMinute, nSecond];
    //    __block NSDictionary *dic_Temp = @{@"questionId":[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]],
    //                                       @"contents":str_NoEncoding,
    //                                       @"type":@"text",
    //                                       @"createDate":str_CreateTime,
    //                                       @"temp":@"YES",
    //                                       @"isDone":@"N",
    //                                       };
    
    
    //    [self.dicM_TempMyContents setObject:dic_Temp forKey:[NSString stringWithFormat:@"%ld", self.messages.count]];
    //    [self.messages addObject:dic_Temp];
    //    [self.tbv_List reloadData];
    //    [self.tbv_List layoutIfNeeded];
    //    [self scrollToTheBottom:YES];
    
    //    NSMutableDictionary *dicM_Msg = [NSMutableDictionary dictionaryWithDictionary:dic_Temp];
    //    [self.arM_List addObject:dicM_Msg];
    
    
    //    if( isFirstLoad )
    //    {
    //        [self.arM_TempList addObject:dicM_Msg];
    //    }
    
    [dicM_Params setObject:str_Tmp forKey:@"msg"];
    [dicM_Params setObject:str_CreateTime forKey:@"createDate"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.arM_List.count] forKey:@"tempIdx"];
    [dicM_Params setObject:@"Y" forKey:@"normalQuestion"];
    
    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dumpLoadQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                
                [self performSelectorOnMainThread:@selector(onSendMsgInterval3:) withObject:dicM_Params waitUntilDone:YES];
                
            });
            
        });
    });
}

- (void)sendMsg:(NSString *)aMsg
{
    if( self.isAskMode && self.isPdfMode )
    {
        if( self.str_PdfImageUrl )
        {
            //PDF문제를 질문했을땐 먼저 이미지를 붙여준다
            NSArray *ar = [self.str_PdfImageUrl componentsSeparatedByString:@"|"];
            NSString *str_TmpUrl = [NSString stringWithFormat:@"%@", self.str_PdfImageUrl];
            //            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[ar firstObject]]];
            NSData *imageData = [NSData dataWithContentsOfURL:[Util createImageUrl:str_ImagePreFix withFooter:[ar firstObject]]];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImage *resizeImage = [Util imageWithImage:image convertToWidth:self.view.bounds.size.width - 30];
            [self uploadData:@{@"type":@"pdfQuestion", @"obj":UIImageJPEGRepresentation(image, 0.3f), @"thumb":resizeImage, @"msg":aMsg, @"imageUrl":str_TmpUrl}];
            self.str_PdfImageUrl = nil;
            
            self.v_CommentKeyboardAccView.lc_AddWidth.constant = 0.f;
            
            return;
        }
    }
    else if( self.isAskMode && self.dic_NormalQuestionInfo )
    {
        str_NormalTmpMessage = aMsg;
        [self sendNormalQuestion];
        self.dic_NormalQuestionInfo = nil;
        
        self.v_CommentKeyboardAccView.lc_AddWidth.constant = 0.f;
        
        return;
    }
    
    if( aMsg == nil || aMsg.length <= 0 )   return;
    
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:@"0"];
    [strM appendString:@"-"];
    
    [strM appendString:@"text"];
    [strM appendString:@"-"];
    
    [strM appendString:@"0"];
    [strM appendString:@"-"];
    
    [strM appendString:@"N"];
    [strM appendString:@"-"];
    
    NSString *str_Tmp = aMsg;
    NSString *str_NoEncoding = str_Tmp;
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    //[]{}#%^*+=_/
    [strM appendString:str_Tmp];
    
    [MBProgressHUD hide];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        //                                        self.str_RId, @"rId",
                                        strM, @"replyContents",
                                        @"qna", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
                                        @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [self.v_CommentKeyboardAccView removeContents];
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSString *str_CreateTime = [NSString stringWithFormat:@"%04ld%02ld%02ld%02d%02d%02d", nYear, nMonth, nDay, nHour, nMinute, nSecond];
    __block NSDictionary *dic_Temp = @{@"questionId":[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]],
                                       @"contents":str_NoEncoding,
                                       @"type":@"text",
                                       @"createDate":str_CreateTime,
                                       @"temp":@"YES",
                                       @"isDone":@"N",
                                       //                               @"check":@"Y"
                                       };
    
    
    [self.dicM_TempMyContents setObject:dic_Temp forKey:[NSString stringWithFormat:@"%ld", self.messages.count]];
    [self.messages addObject:dic_Temp];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tbv_List reloadData];
        [self.tbv_List layoutIfNeeded];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tbv_List reloadData];
            [self scrollToTheBottom:YES];
        });
    });
    
    //    [self.tbv_List reloadData];
    //    [self.tbv_List layoutIfNeeded];
    
    NSMutableDictionary *dicM_Msg = [NSMutableDictionary dictionaryWithDictionary:dic_Temp];
    [self.arM_List addObject:dicM_Msg];
    
    
    //    if( isFirstLoad )
    //    {
    //        //        [dicM_Msg setObject:@"Y" forKey:@"check"];
    //        [self.arM_TempList addObject:dicM_Msg];
    //    }
    
    [dicM_Params setObject:str_Tmp forKey:@"msg"];
    [dicM_Params setObject:str_CreateTime forKey:@"createDate"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.arM_List.count] forKey:@"tempIdx"];
    
    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dumpLoadQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                
                [self performSelectorOnMainThread:@selector(onSendMsgInterval3:) withObject:dicM_Params waitUntilDone:YES];
                
            });
            
        });
    });
}

//- (void)onSendMsgInterval1:(NSMutableDictionary *)dicM_Params
//{
//    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(dumpLoadQueue, ^{
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            [self.tbv_List reloadData];
//            [self.tbv_List setNeedsLayout];
//
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//
//                [self scrollToTheBottom:NO];
//
//
//            });
//
//        });
//    });
//
//
//
////    NSInteger lastSectionIndex = [self.tbv_List numberOfSections] - 1;
////    NSInteger lastItemIndex = [self.tbv_List numberOfRowsInSection:lastSectionIndex] - 1;
////    NSIndexPath *pathToLastItem = [NSIndexPath indexPathForItem:lastItemIndex inSection:lastSectionIndex];
////    NSArray *array = [NSArray arrayWithObjects:pathToLastItem, nil];
//
////    [self.tbv_List beginUpdates];
////    if( self.arM_List.count > 1 )
////    {
////        NSMutableArray *arM = [NSMutableArray array];
////        for( NSInteger i = 0; i < self.arM_List.count; i++ )
////        {
////            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
////            [arM addObject:indexPath];
////        }
//////        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:self.arM_List.count - 1 inSection:0];
//////        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:self.arM_List.count - 2 inSection:0];
//////        NSArray *array = [NSArray arrayWithObjects:indexPath1, indexPath2, nil];
////        [self.tbv_List reloadRowsAtIndexPaths:arM withRowAnimation:UITableViewRowAnimationNone];
////    }
////    else
////    {
////        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:self.arM_List.count - 1 inSection:0];
////        NSArray *array = [NSArray arrayWithObjects:indexPath1, nil];
////        [self.tbv_List reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
////    }
////    [self.tbv_List endUpdates];
//
////    [self.tbv_List beginUpdates];
////    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:self.arM_List.count - 1 inSection:0];
////    NSArray *array = [NSArray arrayWithObjects:indexPath1, nil];
////    [self.tbv_List reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
////    [self.tbv_List endUpdates];
////
////
////    [self.tbv_List setNeedsLayout];
////
////    [self.view setNeedsLayout];
////    [self.view updateConstraints];
//
////    [self performSelector:@selector(onSendMsgInterval2) withObject:dicM_Params afterDelay:0.0f];
////    [self performSelector:@selector(onSendMsgInterval3:) withObject:dicM_Params afterDelay:0.2f];
//    [self performSelectorOnMainThread:@selector(onSendMsgInterval3:) withObject:dicM_Params waitUntilDone:YES];
//
////    [self.arM_MessageQ addObject:dicM_Params];
//}

//- (void)onSendMsgInterval2
//{
//    [self scrollToTheBottom:NO];
//}

//-(void)onTest100:(NSDictionary *)dic
//{
//    NSInteger nIdx = [[dic objectForKey:@"idx"] integerValue];
//    NSLog(@"nIdx : %ld", nIdx);
//    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"resulte"]];
//
//    [self.arM_List replaceObjectAtIndex:nIdx withObject:dicM];
//}

- (void)sendPush:(NSDictionary *)dic
{
    //str_ChannelId
    NSString *str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
    NSString *str_ChannelName = self.channel.name;
    NSString *str_NotiType = @"qna-noti";
    NSString *str_NId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"nId"]];
    NSString *str_QuestionType = @"QNA";
    NSString *str_ChannelUrl = self.channel.channelUrl;
    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    //    NSDictionary *dic_DataMap = [dic objectForKey:@"dataMap"];
    NSDictionary *dic_DataMap = [ar_Body firstObject];
    NSString *str_FileType = [dic_DataMap objectForKey:@"qnaType"];
    NSString *str_ToUser = @""; //대상 지정해서 보낼때만 사용, 전체 보낼땐 빈값
    
    NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
    [dicM_Param setObject:@"0" forKey:@"channelId"];
    [dicM_Param setObject:str_QuestionId forKey:@"questionId"];
    [dicM_Param setObject:str_ChannelName forKey:@"channelName"];
    [dicM_Param setObject:str_NotiType forKey:@"notiType"];
    [dicM_Param setObject:str_NId forKey:@"nId"];
    [dicM_Param setObject:str_QuestionType forKey:@"questionType"];
    [dicM_Param setObject:str_ChannelUrl forKey:@"openChannelUrl"];
    [dicM_Param setObject:self.str_RId forKey:@"roomId"];
    [dicM_Param setObject:str_UserId forKey:@"userId"];
    [dicM_Param setObject:str_FileType forKey:@"fileType"];
    [dicM_Param setObject:str_ToUser forKey:@"toUserId"];
    [dicM_Param setObject:@"dev" forKey:@"dbType"];
    //#ifdef DEBUG
    //    [dicM_Param setObject:@"dev" forKey:@"dbType"];
    //#else
    //    [dicM_Param setObject:@"dev" forKey:@"dbType"];
    //#endif
    
    [[WebAPI sharedData] callPushGCM:@"" param:dicM_Param withMethod:@"" withBlock:^(id resulte, NSError *error) {
        
        if( resulte )
        {
            
        }
    }];
}

- (void)onSendMsgInterval3:(NSMutableDictionary *)dicM_Params
{
    __weak __typeof(&*self)weakSelf = self;
    
    //    NSString *str_Dump = self.v_CommentKeyboardAccView.tv_Contents.text;
    
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }
    
    NSString *str_IsNormalQuestion = [dicM_Params objectForKey_YM:@"normalQuestion"];
    if( [str_IsNormalQuestion isEqualToString:@"Y"] )
    {
        MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeYM;
        hud.labelText = @"질문 등록중...";
    }
    
    [dicM_Params removeObjectForKey:@"normalQuestion"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/add/reply/question/and/view"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        //chat_check_fail@2x.png
                                        
                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                        if( nCode == 200 )
                                        {
                                            //                                            nAutoAnswerIdx = -1;
                                            //                                            UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
                                            //                                            UIView *view = [window viewWithTag:1982];
                                            //                                            UITableView *tbv = [view viewWithTag:1983];
                                            //                                            [tbv reloadData];
                                            
                                            //                                            NSDictionary *dic_DataMap = [resulte objectForKey:@"dataMap"];
                                            NSArray *ar_Body = [resulte objectForKey:@"qnaBody"];
                                            NSDictionary *dic_DataMap = [ar_Body firstObject];
                                            
                                            NSError * err;
                                            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
                                            NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                            __block NSString *str_Msg = [dic_DataMap objectForKey:@"qnaBody"];
                                            
                                            if( [[dic_DataMap objectForKey:@"qnaType"] isEqualToString:@"normalQuestion"] == NO )
                                            {
                                                [MBProgressHUD hide];
                                                
                                                NSArray *ar_Tmp = [self.dicM_TempMyContents allKeys];
                                                NSString *str_FindKey = nil;
                                                for( NSInteger i = 0; i < ar_Tmp.count; i++ )
                                                {
                                                    NSString *str_Key = ar_Tmp[i];
                                                    id tmp = [self.dicM_TempMyContents objectForKey:str_Key];
                                                    if( [tmp isKindOfClass:[NSDictionary class]] )
                                                    {
                                                        NSDictionary *dic_Tmp = (NSDictionary *)tmp;
                                                        NSString *str_TmpContents = [dic_Tmp objectForKey:@"contents"];
                                                        NSString *str_IsTmp = [dic_Tmp objectForKey:@"temp"];
                                                        if( [str_TmpContents isEqualToString:str_Msg] && [str_IsTmp isEqualToString:@"YES"] )
                                                        {
                                                            //                                                                                 findMessage = tmpMessage;
                                                            str_FindKey = str_Key;
                                                            [self.dicM_TempMyContents removeObjectForKey:str_Key];
                                                            break;
                                                        }
                                                    }
                                                }
                                                
                                                if( self.channel && self.channel.memberCount <= 1 )
                                                {
                                                    //1:1 챗에서 나 혼자 남았을 경우 대화 상대 초대 후 메세지 전송하기
                                                    if( self.dic_Info )
                                                    {
                                                        NSArray *ar_Users = [self.dic_Info objectForKey:@"userThumbnail"];
                                                        if( ar_Users && ar_Users.count > 1 )
                                                        {
                                                            NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
                                                            for( NSInteger i = 0; i < ar_Users.count; i++ )
                                                            {
                                                                NSDictionary *dic = ar_Users[i];
                                                                NSInteger nUserId = [[dic objectForKey:@"userId"] integerValue];
                                                                if( nMyId != nUserId )
                                                                {
                                                                    //내가 아닌 경우 초대
                                                                    [self.channel inviteUserId:[NSString stringWithFormat:@"%ld", nUserId] completionHandler:^(SBDError * _Nullable error) {
                                                                        
                                                                        [self.channel sendUserMessage:str_Msg
                                                                                                 data:str_Data
                                                                                           customType:@"text"
                                                                                    completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                                                        
                                                                                        [self.messages replaceObjectAtIndex:[str_FindKey integerValue] withObject:userMessage];
                                                                                        
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            
                                                                                            [self.tbv_List reloadData];
                                                                                            [self.tbv_List layoutIfNeeded];
                                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                
                                                                                                [self.tbv_List reloadData];
                                                                                            });
                                                                                        });
                                                                                    }];
                                                                    }];
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    if( self.dic_BotInfo )
                                                    {
                                                        NSData *jsonData = [str_Data dataUsingEncoding:NSUTF8StringEncoding];
                                                        id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                        NSMutableDictionary *dicM_Tmp = [NSMutableDictionary dictionaryWithDictionary:obj];
                                                        [dicM_Tmp setObject:@"botChat" forKey:@"roomType"];
                                                        [dicM_Tmp setObject:@"user" forKey:@"userType"];
                                                        [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [self.dic_BotInfo objectForKey:@"userId"]] forKey:@"botUserId"];
                                                        [dicM_Tmp setObject:@"" forKey:@"selectExamlist"];
                                                        
                                                        NSDictionary *dic_SelectedAutoAnswer = nil;
                                                        NSString *str_UserMsg = [dicM_Params objectForKey:@"msg"];
                                                        NSInteger nSelectedNum = 0;
                                                        for( NSInteger i = 0; i < self.arM_AutoAnswer.count; i++ )
                                                        {
                                                            NSDictionary *dic_Tmp = self.arM_AutoAnswer[i];
                                                            NSString *str_CurrentMsg = @"";
                                                            if( self.autoChatMode == kPrintExam )
                                                            {
                                                                str_CurrentMsg = [dic_Tmp objectForKey:@"examTitle"];
                                                            }
                                                            else if( self.autoChatMode == kPrintItem )
                                                            {
                                                                str_CurrentMsg = [NSString stringWithFormat:@"%@ %@",
                                                                                  [dic_Tmp objectForKey:@"itemNo"], [dic_Tmp objectForKey:@"itemBody"]];
                                                            }
                                                            else if( self.autoChatMode == kPrintAnswer || self.autoChatMode == kNextExam || self.autoChatMode == kPrintContinue )
                                                            {
                                                                //답 입력
                                                                str_CurrentMsg = [dic_Tmp objectForKey:@"title"];
                                                            }
                                                            
                                                            str_CurrentMsg = [str_CurrentMsg stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
                                                            str_CurrentMsg = [str_CurrentMsg stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
                                                            str_CurrentMsg = [str_CurrentMsg stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
                                                            str_CurrentMsg = [str_CurrentMsg stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                                                            
                                                            if( [str_UserMsg isEqualToString:str_CurrentMsg] )
                                                            {
                                                                dic_SelectedAutoAnswer = dic_Tmp;
                                                                nSelectedNum = i + 1;
                                                                break;
                                                            }
                                                        }
                                                        
                                                        if( dic_SelectedAutoAnswer )
                                                        {
                                                            //제대로 입력 했으면
                                                            if( self.autoChatMode == kPrintExam )
                                                            {
                                                                [dicM_Tmp setObject:@"selectedExam" forKey:@"mesgAction"];
                                                                [dicM_Tmp setObject:@"selectedExam" forKey:@"chatScreen"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [dic_SelectedAutoAnswer objectForKey:@"examId"]] forKey:@"examId"];
                                                                [dicM_Tmp setObject:@"0" forKey:@"questionId"];
                                                            }
                                                            else if( self.autoChatMode == kPrintItem )
                                                            {
                                                                [dicM_Tmp setObject:@"selectedAnswer" forKey:@"mesgAction"];
                                                                [dicM_Tmp setObject:@"selectedAnswer" forKey:@"chatScreen"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%ld", nSelectedNum] forKey:@"userAnswer"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"correctAnswer"]]
                                                                             forKey:@"correctAnswer"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"examId"]]
                                                                             forKey:@"examId"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"printQuestionId"]]
                                                                             forKey:@"printQuestionId"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"testerId"]]
                                                                             forKey:@"testerId"];
                                                            }
                                                            else if( self.autoChatMode == kPrintAnswer )
                                                            {
                                                                //답을 입력 했을때
                                                                NSString *str_UserInputMsg = [dic_SelectedAutoAnswer objectForKey:@"title"];
                                                                if( [str_UserInputMsg rangeOfString:@"정답"].location != NSNotFound )
                                                                {
                                                                    [weakSelf.arM_AutoAnswer removeObject:dic_SelectedAutoAnswer];
                                                                    [dicM_Tmp setObject:@"showCorrectAnswer" forKey:@"mesgAction"];
                                                                }
                                                                else if( [str_UserInputMsg rangeOfString:@"해설"].location != NSNotFound )
                                                                {
                                                                    [weakSelf.arM_AutoAnswer removeObject:dic_SelectedAutoAnswer];
                                                                    [dicM_Tmp setObject:@"showExplain" forKey:@"mesgAction"];
                                                                }
                                                                else if( [str_UserInputMsg rangeOfString:@"다음"].location != NSNotFound )
                                                                {
                                                                    [weakSelf.arM_AutoAnswer removeObject:dic_SelectedAutoAnswer];
                                                                    [dicM_Tmp setObject:@"showNextQuestion" forKey:@"mesgAction"];
                                                                    [dicM_Tmp setObject:@"N" forKey:@"readReport"];
                                                                    
                                                                    [weakSelf onKeyboardDownInterval];
                                                                }
                                                                
                                                                [dicM_Tmp setObject:@"answerResult" forKey:@"chatScreen"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"examId"]]
                                                                             forKey:@"examId"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"printQuestionId"]]
                                                                             forKey:@"printQuestionId"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"testerId"]]
                                                                             forKey:@"testerId"];
                                                                
                                                                nAutoAnswerIdx = -1;
                                                                
                                                                UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
                                                                UIView *view = [window viewWithTag:1982];
                                                                UITableView *tbv = [view viewWithTag:1983];
                                                                [tbv reloadData];
                                                            }
                                                            else if( self.autoChatMode == kNextExam )
                                                            {
                                                                [dicM_Tmp setObject:@"showNextQuestion" forKey:@"mesgAction"];
                                                                [dicM_Tmp setObject:@"answerResult" forKey:@"chatScreen"];
                                                                [dicM_Tmp setObject:@"Y" forKey:@"readReport"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"examId"]]
                                                                             forKey:@"examId"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"printQuestionId"]]
                                                                             forKey:@"printQuestionId"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"testerId"]]
                                                                             forKey:@"testerId"];
                                                                
                                                                nAutoAnswerIdx = -1;
                                                                self.autoChatMode = kWatingMode;
                                                            }
                                                            else if( self.autoChatMode == kPrintContinue )
                                                            {
                                                                NSString *str_UserInputMsg = [dic_SelectedAutoAnswer objectForKey:@"title"];
                                                                if( [str_UserInputMsg rangeOfString:@"계속"].location != NSNotFound )
                                                                {
                                                                    [dicM_Tmp setObject:@"showNextQuestion" forKey:@"mesgAction"];
                                                                    [dicM_Tmp setObject:@"selectContinue" forKey:@"chatScreen"];
                                                                }
                                                                else if( [str_UserInputMsg rangeOfString:@"다른"].location != NSNotFound )
                                                                {
                                                                    [dicM_Tmp setObject:@"showExamlist" forKey:@"mesgAction"];
                                                                    [dicM_Tmp setObject:@"selectContinue" forKey:@"chatScreen"];
                                                                }
                                                                
                                                                [dicM_Tmp setObject:@"N" forKey:@"readReport"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"examId"]]
                                                                             forKey:@"examId"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"printQuestionId"]]
                                                                             forKey:@"printQuestionId"];
                                                                [dicM_Tmp setObject:[NSString stringWithFormat:@"%@", [weakSelf.dic_PrintItemInfo objectForKey:@"testerId"]]
                                                                             forKey:@"testerId"];
                                                                
                                                                nAutoAnswerIdx = -1;
                                                                
                                                                UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
                                                                UIView *view = [window viewWithTag:1982];
                                                                UITableView *tbv = [view viewWithTag:1983];
                                                                [tbv reloadData];
                                                            }
                                                            
                                                            NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
                                                            [dicM_Tmp setObject:[NSString stringWithFormat:@"%ld", nMyId] forKey:@"userId"];
                                                        }
                                                        else
                                                        {
                                                            //다른 글을 입력했으면
                                                            [dicM_Tmp setObject:@"userInput" forKey:@"mesgAction"];
                                                            [dicM_Tmp setObject:@"" forKey:@"chatScreen"];
                                                            
                                                            
                                                        }
                                                        
                                                        
                                                        NSData * tmpData = [NSJSONSerialization dataWithJSONObject:dicM_Tmp options:0 error:nil];
                                                        str_Data = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
                                                    }
                                                    
                                                    [self.channel sendUserMessage:str_Msg
                                                                             data:str_Data
                                                                       customType:@"text"
                                                                completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                                    
                                                                    [self.messages replaceObjectAtIndex:[str_FindKey integerValue] withObject:userMessage];
                                                                    
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        
                                                                        [self.tbv_List reloadData];
                                                                        [self.tbv_List layoutIfNeeded];
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            
                                                                            [self.tbv_List reloadData];
                                                                        });
                                                                    });
                                                                }];
                                                }
                                            }
                                            else
                                            {
                                                NSMutableDictionary *dicM_Tmp = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                [dicM_Tmp setObject:self.str_ExamTitle forKey:@"examTitle"];
                                                [dicM_Tmp setObject:self.str_ExamNo forKey:@"examNo"];
                                                [dicM_Tmp setObject:self.str_ExamId forKey:@"examId"];
                                                [dicM_Tmp setObject:self.str_QuestinId forKey:@"questionId"];
                                                resulte = [NSDictionary dictionaryWithDictionary:dicM_Tmp];
                                                
                                                NSError * err;
                                                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
                                                NSString *str_Data2 = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                
                                                [self.channel sendUserMessage:@""
                                                                         data:str_Data2
                                                                   customType:@"normalQuestion"
                                                            completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                                
                                                                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                                                
                                                                [weakSelf.navigationController.view makeToast:@"질문을 등록했습니다" withPosition:kPositionCenter];
                                                                [weakSelf.view endEditing:YES];
                                                                
                                                                for( id message in self.messages )
                                                                {
                                                                    if( [message isKindOfClass:[NSDictionary class]] )
                                                                    {
                                                                        NSDictionary *dic_Message = (NSDictionary *)message;
                                                                        if( [[dic_Message objectForKey_YM:@"temp"] isEqualToString:@"YES"] && [[dic_Message objectForKey:@"type"] isEqualToString:@"normalQuestion"] )
                                                                        {
                                                                            [self.messages removeObject:message];
                                                                            break;
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                if( [[dic_DataMap objectForKey:@"qnaType"] isEqualToString:@"normalQuestion"] )
                                                                {
                                                                    [self.messages addObject:userMessage];
                                                                }
                                                                
                                                                [self sendMsg:str_NormalTmpMessage];
                                                                str_NormalTmpMessage = @"";
                                                            }];
                                            }
                                        }
                                        else
                                        {
                                            if( nCode != 0 && nCode != 200 )
                                            {
                                                [weakSelf.navigationController.view makeToast:@"메세지 전송을 실패 하였습니다" withPosition:kPositionCenter];
                                            }
                                            
                                            NSArray *ar_Tmp = [self.dicM_TempMyContents allKeys];
                                            NSString *str_FindKey = nil;
                                            for( NSInteger i = 0; i < ar_Tmp.count; i++ )
                                            {
                                                NSString *str_Key = ar_Tmp[i];
                                                id tmp = [self.dicM_TempMyContents objectForKey:str_Key];
                                                if( [tmp isKindOfClass:[NSDictionary class]] )
                                                {
                                                    NSDictionary *dic_Tmp = (NSDictionary *)tmp;
                                                    NSInteger nTargetId = [[dic_Tmp objectForKey:@"createDate"] integerValue];
                                                    NSInteger nId = [[dicM_Params objectForKey:@"createDate"] integerValue];
                                                    if( nTargetId != 0 && nTargetId == nId )
                                                    {
                                                        str_FindKey = str_Key;
                                                        
                                                        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];
                                                        [dicM setObject:@"YES" forKey:@"isFail"];
                                                        [self.messages replaceObjectAtIndex:[str_FindKey integerValue] withObject:dicM];
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.tbv_List reloadData];
                                                            [self.tbv_List layoutIfNeeded];
                                                        });
                                                        
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }];
}

//+ (void)registerNotificationHandlerMessagingChannelUpdatedBlock:(void ( ^ ) ( SendBirdMessagingChannel *channel ))messagingChannelUpdated mentionUpdatedBlock:(void ( ^ ) ( SendBirdMention *mention ))mentionUpdated
//{
//
//}
//
//+ (void)broadcastMessageReceived:(SendBirdBroadcastMessage *)msg
//{
//
//}

- (void)sendDashboardUpdate:(NSDictionary *)resulte
{
    //    NSError *error = nil;
    //    NSMutableDictionary *dicM_DashBoard = [NSMutableDictionary dictionaryWithDictionary:resulte];
    //    [dicM_DashBoard setObject:self.str_RId forKey:@"rId"];
    //
    //    NSMutableString *strM = [NSMutableString string];
    //    for( NSInteger i = 0; i < self.arM_User.count; i++ )
    //    {
    //        NSString *str_UserId = [self.arM_User objectAtIndex:i];
    //        [strM appendString:[NSString stringWithFormat:@"%@", str_UserId]];
    //        [strM appendString:@","];
    //    }
    //
    //    if( [strM hasSuffix:@","] )
    //    {
    //        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    //    }
    //
    //    [dicM_DashBoard setObject:strM forKey:@"userIds"];
    //
    //
    //    NSData *dashboardData = [NSJSONSerialization dataWithJSONObject:dicM_DashBoard
    //                                                            options:NSJSONWritingPrettyPrinted
    //                                                              error:&error];
    //    NSString *dashboardString = [[NSString alloc] initWithData:dashboardData encoding:NSUTF8StringEncoding];
    //
    //    [SendBird sendMessage:@"dashBoardUpdate" withData:dashboardString];
}

- (void)sendMsgCmd:(ChatStatus)status withMsg:(NSString *)aMsg withUsers:(NSArray *)users
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:@"0"];
    [strM appendString:@"-"];
    
    [strM appendString:@"text"];
    [strM appendString:@"-"];
    
    [strM appendString:@"0"];
    [strM appendString:@"-"];
    
    [strM appendString:@"N"];
    [strM appendString:@"-"];
    
    
    NSString *str_Tmp = aMsg;
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    //[]{}#%^*+=_/
    [strM appendString:str_Tmp];
    
    [MBProgressHUD hide];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        //                                        self.str_RId, @"rId",
                                        strM, @"replyContents",
                                        @"cmd", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
                                        @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [self.v_CommentKeyboardAccView removeContents];
    //    [self.view endEditing:YES];
    
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/add/reply/question/and/view"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //전송완료 후 센드버드 메세지 호출
                                                //새로운 질문
                                                
                                                //                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                //                                                                                                             @"eId":[resulte objectForKey:@"qnaId"],
                                                //                                                                                                             @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                                //                                                                                                             @"channelUrl":self.str_ChannelUrl}
                                                //                                                                                                   options:NSJSONWritingPrettyPrinted
                                                //                                                                                                     error:&error];
                                                //                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                
                                                if( status == kLeaveChat )
                                                {
                                                    //                                                    [SendBird sendMessage:@"regist-leave" withData:jsonString];
                                                    //                                                    [SendBird sendMessage:@"regist-leave" withData:jsonString];
                                                    
                                                    [self goChatRoomBack:nil];
                                                }
                                                else if( status == kInviteChat )
                                                {
                                                    //                                                    [SendBird sendMessage:@"regist-invite" withData:jsonString];
                                                    
                                                    NSError * err;
                                                    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
                                                    NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                    //                                                    NSDictionary *dic_DataMap = [resulte objectForKey:@"dataMap"];
                                                    NSArray *ar_Body = [resulte objectForKey:@"qnaBody"];
                                                    NSDictionary *dic_DataMap = [ar_Body firstObject];
                                                    
                                                    __block NSString *str_Msg = [dic_DataMap objectForKey:@"qnaBody"];
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    //이 부분을 샌드버드 플랫폼 api를 써서 처리하기로 함
                                                    [self sendSendBirdPlatformApi:kInviteChat withData:users withMsg:aMsg];
                                                    //                                                    [self.channel sendUserMessage:str_Msg
                                                    //                                                                             data:@""
                                                    //                                                                       customType:@"command"
                                                    //                                                                completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                    //
                                                    //                                                                    if( error != nil )
                                                    //                                                                    {
                                                    //                                                                        //에러가 났을 경우
                                                    //                                                                        return ;
                                                    //                                                                    }
                                                    //
                                                    //                                                                    [self.channel updateUserMessage:userMessage messageText:str_Msg data:str_Data customType:@"command" completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                    //
                                                    //                                                                        [self.messages addObject:userMessage];
                                                    //
                                                    //                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                    //                                                                            [self.tbv_List reloadData];
                                                    //                                                                            [self.tbv_List layoutIfNeeded];
                                                    //                                                                        });
                                                    //                                                                    }];
                                                    //
                                                    //                                                                    //                                                               [self sendPush:resulte];
                                                    //
                                                    //                                                           }];
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    //                                                    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
                                                    //                                                    dispatch_async(dumpLoadQueue, ^{
                                                    //
                                                    //                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                    //
                                                    //                                                            [weakSelf.arM_List addObject:resulte];
                                                    //                                                            [weakSelf setMiddleDate];
                                                    //                                                            [weakSelf.tbv_List reloadData];
                                                    //
                                                    //                                                            if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
                                                    //                                                            {
                                                    //                                                                CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
                                                    //                                                                [weakSelf.tbv_List setContentOffset:offset animated:YES];
                                                    //                                                            }
                                                    //                                                        });
                                                    //                                                    });
                                                    
                                                }
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)sendSendBirdPlatformApi:(ChatStatus)type withData:(id)data withMsg:(NSString *)aMsg
{
    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    if( type == kInviteChat )
    {
        //초대
        NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
        [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
        [dicM_Param setObject:aMsg forKey:@"message"];
        [dicM_Param setObject:@"cmd" forKey:@"custom_type"];
        
        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
        [dicM_Data setObject:@"USER_JOIN" forKey:@"type"];
        
        NSMutableDictionary *dicM_Inviter = [NSMutableDictionary dictionary];
        [dicM_Inviter setObject:str_UserId forKey:@"user_id"];
        [dicM_Inviter setObject:str_UserName forKey:@"nickname"];
        [dicM_Data setObject:dicM_Inviter forKey:@"sender"];
        
        
        NSMutableArray *arM_Users = [NSMutableArray array];
        NSArray *ar_Users = [NSArray arrayWithArray:data];
        for( NSInteger i = 0; i < ar_Users.count; i++ )
        {
            NSDictionary *dic_User = ar_Users[i];
            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic_User objectForKey:@"userId"]];
            [arM_Users addObject:@{@"user_id":str_UserId, @"nickname":[dic_User objectForKey:@"userName"]}];
        }
        [dicM_Data setObject:arM_Users forKey:@"users"];
        
        [dicM_Data setObject:aMsg forKey:@"message"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [dicM_Param setObject:jsonString forKey:@"data"];
        
        //        [dicM_Param setObject:@"true" forKey:@"is_silent"];
        [dicM_Param setObject:@"true" forKey:@"is_silent"];
        
        NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
        [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
                                                 param:dicM_Param
                                            withMethod:@"POST"
                                             withBlock:^(id resulte, NSError *error) {
                                                 
                                                 if( resulte )
                                                 {
                                                     
                                                 }
                                             }];
    }
    else if( type == kLeaveChat )
    {
        //나감
        NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
        [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
        [dicM_Param setObject:aMsg forKey:@"message"];
        [dicM_Param setObject:@"cmd" forKey:@"custom_type"];
        
        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
        [dicM_Data setObject:@"USER_LEFT" forKey:@"type"];
        
        NSMutableDictionary *dicM_Inviter = [NSMutableDictionary dictionary];
        [dicM_Inviter setObject:str_UserId forKey:@"user_id"];
        [dicM_Inviter setObject:str_UserName forKey:@"nickname"];
        [dicM_Data setObject:dicM_Inviter forKey:@"sender"];
        
        
        NSMutableArray *arM_Users = [NSMutableArray array];
        NSArray *ar_Users = [NSArray arrayWithArray:data];
        for( NSInteger i = 0; i < ar_Users.count; i++ )
        {
            NSDictionary *dic_User = ar_Users[i];
            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic_User objectForKey:@"userId"]];
            [arM_Users addObject:@{@"user_id":str_UserId, @"nickname":[dic_User objectForKey:@"userName"]}];
        }
        [dicM_Data setObject:arM_Users forKey:@"users"];
        
        [dicM_Data setObject:aMsg forKey:@"message"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [dicM_Param setObject:jsonString forKey:@"data"];
        
        //        [dicM_Param setObject:@"true" forKey:@"is_silent"];
        [dicM_Param setObject:@"true" forKey:@"is_silent"];
        
        NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
        [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
                                                 param:dicM_Param
                                            withMethod:@"POST"
                                             withBlock:^(id resulte, NSError *error) {
                                                 
                                                 if( resulte )
                                                 {
                                                     
                                                 }
                                             }];
    }
    else if( type == kEnterChat )
    {
        //입장
        NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
        [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
        [dicM_Param setObject:aMsg forKey:@"message"];
        [dicM_Param setObject:@"cmd" forKey:@"custom_type"];
        
        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
        [dicM_Data setObject:@"USER_ENTER" forKey:@"type"];
        
        NSMutableDictionary *dicM_Inviter = [NSMutableDictionary dictionary];
        [dicM_Inviter setObject:str_UserId forKey:@"user_id"];
        [dicM_Inviter setObject:str_UserName forKey:@"nickname"];
        [dicM_Data setObject:dicM_Inviter forKey:@"sender"];
        
        
        NSMutableArray *arM_Users = [NSMutableArray array];
        NSArray *ar_Users = [NSArray arrayWithArray:data];
        for( NSInteger i = 0; i < ar_Users.count; i++ )
        {
            NSDictionary *dic_User = ar_Users[i];
            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic_User objectForKey:@"userId"]];
            [arM_Users addObject:@{@"user_id":str_UserId, @"nickname":[dic_User objectForKey:@"userName"]}];
        }
        [dicM_Data setObject:arM_Users forKey:@"users"];
        
        [dicM_Data setObject:aMsg forKey:@"message"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [dicM_Param setObject:jsonString forKey:@"data"];
        
        [dicM_Param setObject:@"true" forKey:@"is_silent"];
        //        [dicM_Param setObject:@"false" forKey:@"is_silent"];
        
        NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
        [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
                                                 param:dicM_Param
                                            withMethod:@"POST"
                                             withBlock:^(id resulte, NSError *error) {
                                                 
                                                 if( resulte )
                                                 {
                                                     
                                                 }
                                             }];
    }
}

- (IBAction)goShowAlbum:(id)sender
{
    [self.view endEditing:YES];
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:@[@"라이브러리", @"사진(카메라)", @"동영상(카메라)"]
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, kUTTypeImage, nil];
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = NO;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else if( buttonIndex == 1 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = NO;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else if( buttonIndex == 2 )
         {
             UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
             imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
             imagePickerController.delegate = self;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
     }];
}

#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 1);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        
        UIImage *resizeImage = [Util imageWithImage:thumb convertToWidth:self.view.bounds.size.width - 30];
        
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        [self uploadData:@{@"type":@"video", @"obj":videoData, @"thumb":UIImageJPEGRepresentation(resizeImage, 0.3f), @"videoUrl":[videoUrl absoluteString]}];
    }
    else
    {
        UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIImage *resizeImage = [Util imageWithImage:outputImage convertToWidth:self.view.bounds.size.width - 30];
        
        [self uploadData:@{@"type":@"image", @"obj":UIImageJPEGRepresentation(resizeImage, 0.3f), @"thumb":resizeImage}];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.tbv_List scrollRectToVisible:CGRectMake(self.tbv_List.contentSize.width - 1, self.tbv_List.contentSize.height - 1, 1, 1) animated:YES];
    }];
}

- (void)uploadData:(NSDictionary *)dic
{
    //데이터를 먼저 붙여준다
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSString *str_CreateTime = [NSString stringWithFormat:@"%04ld%02ld%02ld%02d%02d%02d", nYear, nMonth, nDay, nHour, nMinute, nSecond];
    NSDictionary *dic_Temp = @{@"questionId":[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]],
                               //                               @"contents":str_NoEncoding,
                               @"type":[dic objectForKey:@"type"],
                               @"createDate":str_CreateTime,
                               @"temp":@"YES",
                               @"isDone":@"N",
                               @"obj":([[dic objectForKey:@"type"] isEqualToString:@"image"] || [[dic objectForKey:@"type"] isEqualToString:@"pdfQuestion"]) ? [dic objectForKey:@"obj"] : [dic objectForKey:@"thumb"],
                               };
    
    NSMutableDictionary *dicM_Tmp = [NSMutableDictionary dictionaryWithDictionary:dic_Temp];
    NSString *str_VideoUrl = [dic objectForKey_YM:@"videoUrl"];
    if( str_VideoUrl.length > 0 )
    {
        [dicM_Tmp setObject:str_VideoUrl forKey:@"videoUrl"];
        //        dic_Temp = [NSDictionary dictionaryWithDictionary:dicM_Tmp];
    }
    
    if( [[dic objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
    {
        MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeYM;
        hud.labelText = @"질문 등록중...";
        
        [dicM_Tmp setObject:self.str_ExamTitle forKey:@"examTitle"];
        
        //        [self.dicM_TempMyContents setObject:dicM_Tmp forKey:[NSString stringWithFormat:@"%ld", self.messages.count]];
        //        [self.messages addObject:dicM_Tmp];
    }
    else
    {
        [self.dicM_TempMyContents setObject:dicM_Tmp forKey:[NSString stringWithFormat:@"%ld", self.messages.count]];
        [self.messages addObject:dicM_Tmp];
        [self.tbv_List reloadData];
        [self.tbv_List layoutIfNeeded];
        [self scrollToTheBottom:YES];
    }
    
    
    __block NSMutableDictionary *dicM_Msg = [NSMutableDictionary dictionaryWithDictionary:dic_Temp];
    [self.arM_List addObject:dicM_Msg];
    
    if( isFirstLoad )
    {
        //        [dicM_Msg setObject:@"Y" forKey:@"check"];
        [self.arM_TempList addObject:dicM_Msg];
    }
    
    //    [dicM_Params setObject:str_Tmp forKey:@"msg"];
    //    [dicM_Params setObject:str_CreateTime forKey:@"createDate"];
    //    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.arM_List.count] forKey:@"tempIdx"];
    
    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dumpLoadQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tbv_List reloadData];
            [self.tbv_List setNeedsLayout];
            
            [self scrollToTheBottom:NO];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                
                __weak __typeof__(self) weakSelf = self;
                
                __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                [dicM setObject:[NSString stringWithFormat:@"%ld", self.arM_List.count] forKey:@"tempIdx"];
                
                if( [[dicM objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
                {
                    [dicM setObject:[dic objectForKey_YM:@"imageUrl"] forKey:@"imageUrl"];
                    [self upLoadContents:dicM];
                    
                    return ;
                }
                
                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                    [Util getUUID], @"uuid",
                                                    [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                                    @"reply", @"uploadItem",
                                                    [dicM objectForKey:@"type"], @"type",
                                                    nil];
                
                [[WebAPI sharedData] imageUpload:@"v1/attach/file/uploader"
                                           param:dicM_Params
                                      withImages:[NSDictionary dictionaryWithObject:[dicM objectForKey:@"obj"] forKey:@"file"]
                                       withBlock:^(id resulte, NSError *error) {
                                           
                                           NSInteger nCode = [[resulte objectForKey_YM:@"response_code"] integerValue];
                                           if( nCode == 200 )
                                           {
                                               __block NSDictionary *dic_Old = [NSDictionary dictionaryWithDictionary:resulte];
                                               if( [[dic objectForKey:@"type"] isEqualToString:@"video"] )
                                               {
                                                   NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                       [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                                       [Util getUUID], @"uuid",
                                                                                       [resulte objectForKey:@"tempUploadId"], @"videoTempUploadId",
                                                                                       [resulte objectForKey:@"serviceUrl"], @"videoServiceUrl",
                                                                                       @"reply", @"uploadItem",
                                                                                       @"image", @"type",
                                                                                       nil];
                                                   
                                                   [[WebAPI sharedData] imageUpload:@"v1/attach/video/cover/image/uploader"
                                                                              param:dicM_Params
                                                                         withImages:[NSDictionary dictionaryWithObject:[dicM objectForKey:@"thumb"] forKey:@"file"]
                                                                          withBlock:^(id resulte, NSError *error) {
                                                                              
                                                                              if( resulte )
                                                                              {
                                                                                  NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                                  if( nCode == 200 )
                                                                                  {
                                                                                      [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"tempUploadId"]] forKey:@"tempUploadId"];
                                                                                      [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"serviceUrl"]] forKey:@"serviceUrl"];
                                                                                      [weakSelf upLoadContents:dicM];
                                                                                  }
                                                                                  else
                                                                                  {
                                                                                      [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                                                  }
                                                                              }
                                                                              else
                                                                              {
                                                                                  [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                                              }
                                                                          }];
                                               }
                                               else
                                               {
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"tempUploadId"]] forKey:@"tempUploadId"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"serviceUrl"]] forKey:@"serviceUrl"];
                                                   [weakSelf upLoadContents:dicM];
                                               }
                                           }
                                           else
                                           {
                                               if( nCode != 0 && nCode != 200 )
                                               {
                                                   [weakSelf.navigationController.view makeToast:@"메세지 전송을 실패 하였습니다" withPosition:kPositionCenter];
                                               }
                                               
                                               NSArray *ar_Tmp = [self.dicM_TempMyContents allKeys];
                                               NSString *str_FindKey = nil;
                                               for( NSInteger i = 0; i < ar_Tmp.count; i++ )
                                               {
                                                   NSString *str_Key = ar_Tmp[i];
                                                   id tmp = [self.dicM_TempMyContents objectForKey:str_Key];
                                                   if( [tmp isKindOfClass:[NSDictionary class]] )
                                                   {
                                                       NSDictionary *dic_Tmp = (NSDictionary *)tmp;
                                                       NSInteger nTargetId = [[dic_Tmp objectForKey:@"createDate"] integerValue];
                                                       NSInteger nId = [[dicM_Msg objectForKey:@"createDate"] integerValue];
                                                       if( nTargetId != 0 && nTargetId == nId )
                                                       {
                                                           str_FindKey = str_Key;
                                                           
                                                           NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];
                                                           [dicM setObject:@"YES" forKey:@"isFail"];
                                                           [self.messages replaceObjectAtIndex:[str_FindKey integerValue] withObject:dicM];
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [self.tbv_List reloadData];
                                                               [self.tbv_List layoutIfNeeded];
                                                           });
                                                           
                                                           break;
                                                       }
                                                   }
                                               }
                                           }
                                       }];
            });
            
        });
    });
    
    
    
    
}

- (void)upLoadContents:(NSDictionary *)dic
{
    __block NSDictionary *dic_Temp = [NSDictionary dictionaryWithDictionary:dic];
    NSMutableString *strM = [NSMutableString string];
    
    if( [[dic_Temp objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
    {
        //        NSError * err;
        //        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:[self.dic_PdfQuestionInfo objectForKey:@"examQuestionInfos"] options:0 error:&err];
        //        NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic_Tmp = @{@"examQuestionInfos":[self.dic_PdfQuestionInfo objectForKey:@"examQuestionInfos"]};
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_Tmp options:0 error:nil];
        NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [strM appendString:@"0"];
        [strM appendString:@"-"];
        
        [strM appendString:[dic objectForKey:@"type"]];
        [strM appendString:@"-"];
        
        [strM appendString:@"0"];
        [strM appendString:@"-"];
        
        [strM appendString:@"N"];
        [strM appendString:@"-"];
        
        NSString *str_Tmp = str_Data;
        NSString *str_NoEncoding = str_Tmp;
        str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
        str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
        str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
        str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        //[]{}#%^*+=_/
        [strM appendString:str_Tmp];
        
        
        
        
        
        
        
        //        [strM appendString:@"0"];
        //        [strM appendString:@"-"];
        //
        //        [strM appendString:[dic objectForKey:@"type"]];
        //        [strM appendString:@"-"];
        //
        //        [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"tempUploadId"]]];
        //        [strM appendString:@"-"];
        //
        //        [strM appendString:@"N"];
        //        [strM appendString:@"-"];
        //
        //        [strM appendString:[dic objectForKey:@"imageUrl"]];
    }
    else
    {
        [strM appendString:@"0"];
        [strM appendString:@"-"];
        
        [strM appendString:[dic objectForKey:@"type"]];
        [strM appendString:@"-"];
        
        [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"tempUploadId"]]];
        [strM appendString:@"-"];
        
        [strM appendString:@"N"];
        [strM appendString:@"-"];
        
        [strM appendString:[dic objectForKey:@"serviceUrl"]];
    }
    
    
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        strM, @"replyContents",
                                        @"qna", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
                                        @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
                                        @"0", @"groupId",
                                        nil];
    
    [self.v_CommentKeyboardAccView removeContents];
    [self.view endEditing:YES];
    
    __weak __typeof(&*self)weakSelf = self;
    
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/add/reply/question/and/view"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                //                                                [dicM setObject:@"Y" forKey:@"isDone"];
                                                //                                                [weakSelf.arM_List addObject:dicM];
                                                //                                                nLastMyIdx = weakSelf.arM_List.count - 1;
                                                //                                                [weakSelf setMiddleDate];
                                                //                                                [weakSelf.tbv_List reloadData];
                                                
                                                
                                                
                                                
                                                //                                                NSDictionary *dic_DataMap = [resulte objectForKey:@"dataMap"];
                                                NSArray *ar_Body = [resulte objectForKey:@"qnaBody"];
                                                NSDictionary *dic_DataMap = [ar_Body firstObject];
                                                
                                                if( [[dic_DataMap objectForKey:@"qnaType"] isEqualToString:@"pdfQuestion"] )
                                                {
                                                    //PDF문제 질문일 경우 데이터 만들어 주기
                                                    //examTitle, examNo, examId
                                                    NSMutableDictionary *dicM_Tmp = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                    [dicM_Tmp setObject:self.str_ExamTitle forKey:@"examTitle"];
                                                    [dicM_Tmp setObject:self.str_ExamNo forKey:@"examNo"];
                                                    [dicM_Tmp setObject:self.str_ExamId forKey:@"examId"];
                                                    [dicM_Tmp setObject:self.str_PdfPage forKey:@"pdfPage"];
                                                    [dicM_Tmp setObject:self.str_QuestinId forKey:@"questionId"];
                                                    //                                                    [dicM_Tmp setObject:[self.dic_PdfQuestionInfo objectForKey:@"examQuestionInfos"] forKey:@"qnaBody"];
                                                    
                                                    //                                                    NSDictionary *dic_Tmp = @{@"examQuestionInfos":[self.dic_PdfQuestionInfo objectForKey:@"examQuestionInfos"]};
                                                    //                                                    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_Tmp options:0 error:nil];
                                                    //                                                    NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                    
                                                    //                                                    NSMutableDictionary *dicM_DataMap = [NSMutableDictionary dictionaryWithDictionary:[resulte objectForKey:@"dataMap"]];
                                                    //                                                    [dicM_DataMap setObject:str_Data forKey:@"qnaBody"];
                                                    //                                                    [dicM_Tmp setObject:dicM_DataMap forKey:@"dataMap"];
                                                    //
                                                    //                                                    NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionaryWithDictionary:[resulte objectForKey:@"data"]];
                                                    //                                                    [dicM_Data setObject:str_Data forKey:@"qnaBody"];
                                                    //                                                    [dicM_Tmp setObject:dicM_Data forKey:@"data"];
                                                    //
                                                    //                                                    NSMutableDictionary *dicM_QnaData = [NSMutableDictionary dictionaryWithDictionary:[resulte objectForKey:@"qnaBody"]];
                                                    //                                                    [dicM_QnaData setObject:str_Data forKey:@"qnaBody"];
                                                    //                                                    [dicM_Tmp setObject:dicM_QnaData forKey:@"qnaBody"];
                                                    
                                                    
                                                    self.dic_PdfQuestionInfo = nil;
                                                    
                                                    resulte = [NSDictionary dictionaryWithDictionary:dicM_Tmp];
                                                }
                                                
                                                NSError * err;
                                                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
                                                NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                //                                                __block NSString *str_Msg = [dic_DataMap objectForKey:@"qnaBody"];
                                                
                                                NSArray *ar_Tmp = [self.dicM_TempMyContents allKeys];
                                                NSString *str_FindKey = nil;
                                                for( NSInteger i = 0; i < ar_Tmp.count; i++ )
                                                {
                                                    NSString *str_Key = ar_Tmp[i];
                                                    id tmp = [self.dicM_TempMyContents objectForKey:str_Key];
                                                    if( [tmp isKindOfClass:[NSDictionary class]] )
                                                    {
                                                        NSDictionary *dic_Tmp = (NSDictionary *)tmp;
                                                        NSString *str_TmpType = [dic_Tmp objectForKey:@"type"];
                                                        NSString *str_IsTmp = [dic_Tmp objectForKey:@"temp"];
                                                        if( ([str_TmpType isEqualToString:@"image"] || [str_TmpType isEqualToString:@"video"]) && [str_IsTmp isEqualToString:@"YES"] )
                                                        {
                                                            str_FindKey = str_Key;
                                                            [self.dicM_TempMyContents removeObjectForKey:str_Key];
                                                            break;
                                                        }
                                                    }
                                                }
                                                
                                                NSLog(@"%@", [dic_DataMap objectForKey:@"qnaType"]);
                                                NSString *str_CustomType = @"";
                                                NSString *str_Msg = @"";
                                                if( [[dic_DataMap objectForKey:@"qnaType"] isEqualToString:@"image"] )
                                                {
                                                    str_CustomType = @"image";
                                                    str_Msg = @"이미지를 전송 했습니다";
                                                }
                                                else if( [[dic_DataMap objectForKey:@"qnaType"] isEqualToString:@"pdfQuestion"] )
                                                {
                                                    str_CustomType = @"pdfQuestion";
                                                    str_Msg = @"새로운 질문이 등록 되었습니다";
                                                }
                                                else
                                                {
                                                    str_CustomType = @"video";
                                                    str_Msg = @"동영상을 전송 했습니다";
                                                }
                                                
                                                //                                                if( [[dic objectForKey_YM:@"mode"] isEqualToString:@"pdf"] )
                                                //                                                {
                                                //                                                    str_CustomType = @"pdfQuestion";
                                                //                                                }
                                                //                                                else if( [[dic objectForKey_YM:@"mode"] isEqualToString:@"normal"] )
                                                //                                                {
                                                //                                                    //일반문제
                                                //
                                                //                                                }
                                                [self.channel sendUserMessage:str_Msg
                                                                         data:str_Data
                                                                   customType:str_CustomType
                                                            completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                                
                                                                for( id message in self.messages )
                                                                {
                                                                    if( [message isKindOfClass:[NSDictionary class]] )
                                                                    {
                                                                        NSDictionary *dic_Message = (NSDictionary *)message;
                                                                        if( [[dic_Message objectForKey_YM:@"temp"] isEqualToString:@"YES"] && [[dic_Message objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
                                                                        {
                                                                            [self.messages removeObject:message];
                                                                            break;
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                if( [[dic_DataMap objectForKey:@"qnaType"] isEqualToString:@"pdfQuestion"] )
                                                                {
                                                                    [self.messages addObject:userMessage];
                                                                }
                                                                else
                                                                {
                                                                    [self.messages replaceObjectAtIndex:[str_FindKey integerValue] withObject:userMessage];
                                                                }
                                                                
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [self.tbv_List reloadData];
                                                                    [self.tbv_List layoutIfNeeded];
                                                                });
                                                                
                                                                if( [[dic_Temp objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
                                                                {
                                                                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                                                    [weakSelf.navigationController.view makeToast:@"질문을 등록했습니다" withPosition:kPositionCenter];
                                                                    
                                                                    [self sendMsg:[dic objectForKey:@"msg"]];
                                                                }
                                                                
                                                                //                                                                [self.channel updateUserMessage:userMessage
                                                                //                                                                                    messageText:@""
                                                                //                                                                                           data:str_Data
                                                                //                                                                                     customType:str_CustomType
                                                                //                                                                              completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                                //
                                                                //                                                                                  [self.messages replaceObjectAtIndex:[str_FindKey integerValue] withObject:userMessage];
                                                                //                                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                //                                                                                      [self.tbv_List reloadData];
                                                                //                                                                                      [self.tbv_List layoutIfNeeded];
                                                                //                                                                                  });
                                                                //                                                                }];
                                                                ////                                                                [self sendPush:resulte];
                                                                
                                                            }];
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                //                                                NSError * err;
                                                //                                                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
                                                //                                                NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                //                                                NSDictionary *dic_DataMap = [resulte objectForKey:@"dataMap"];
                                                //                                                [SBDGroupChannel getChannelWithUrl:self.channel.channelUrl
                                                //                                                                 completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                //
                                                //                                                                     NSLog(@"%@", [dic_DataMap objectForKey:@"qnaType"]);
                                                //                                                                     NSString *str_CustomType = @"";
                                                //                                                                     if( [[dic_DataMap objectForKey:@"qnaType"] isEqualToString:@"image"] )
                                                //                                                                     {
                                                //                                                                         str_CustomType = @"image";
                                                //                                                                     }
                                                //                                                                     else
                                                //                                                                     {
                                                //                                                                         str_CustomType = @"video";
                                                //                                                                     }
                                                //
                                                //                                                                     [channel sendUserMessage:@"" data:str_Data customType:str_CustomType
                                                //                                                                            completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                                                //
                                                //                                                                     }];
                                                //                                                                 }];
                                                
                                                NSInteger nFindIdx = [[dic_Temp objectForKey:@"tempIdx"] integerValue] - 1;
                                                if( nFindIdx > -1 )
                                                {
                                                    [self.arM_List replaceObjectAtIndex:nFindIdx withObject:resulte];
                                                    
                                                    NSDictionary *dic_Result = @{@"resulte":resulte, @"idx":[NSString stringWithFormat:@"%ld", nFindIdx]};
                                                    [weakSelf performSelector:@selector(messageCheckInteval:) withObject:dic_Result afterDelay:0.1f];
                                                }
                                                
                                                //                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                //                                                                                                             @"eId":[resulte objectForKey:@"qnaId"],
                                                //                                                                                                             @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                                //                                                                                                             @"channelUrl":self.str_ChannelUrl,
                                                //                                                                                                             @"result":resulte}
                                                //
                                                //                                                                                                   options:NSJSONWritingPrettyPrinted
                                                //                                                                                                     error:&error];
                                                //
                                                //                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                ////                                                [SendBird sendMessage:@"regist-qna" withData:jsonString];
                                                
                                                //                                                NSArray *ar_Body = [NSArray arrayWithArray:[resulte objectForKey:@"qnaBody"]];
                                                //                                                if( ar_Body.count > 0 )
                                                //                                                {
                                                //                                                    NSDictionary *dic = [ar_Body firstObject];
                                                //                                                    NSMutableDictionary *dicM_Resulte = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                //                                                    [dicM_Resulte setObject:[dic objectForKey:@"qnaType"] forKey:@"msgType"];
                                                //                                                    [self sendDashboardUpdate:dicM_Resulte];
                                                //                                                }
                                                
                                                //                                                [weakSelf.arM_List addObject:resulte];
                                                //                                                [weakSelf setMiddleDate];
                                                //                                                [weakSelf.tbv_List reloadData];
                                                
                                                if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
                                                {
                                                    CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
                                                    [self.tbv_List setContentOffset:offset animated:YES];
                                                }
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            //                                            [self.view endEditing:YES];
                                        }
                                    }];
}






#pragma mark - SendBird
- (void)startSendBird
{
    //    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
    //
    //        NSLog(@"%@", channel.url);
    //        NSLog(@"%@", str_ChannelUrl);
    //    } errorBlock:^(NSInteger code) {
    //
    //    } channelLeftBlock:^(SendBirdChannel *channel) {
    //
    //    } messageReceivedBlock:^(SendBirdMessage *message) {
    //
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
    //        NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
    //        NSInteger nTargetId = [[dicM_Result objectForKey_YM:@"userId"] integerValue];
    //
    //        NSString *str_ChannelUrlTmp = [NSString stringWithFormat:@"%@", [dicM_Result objectForKey_YM:@"channelUrl"]];
    ////        if( [str_ChannelUrlTmp rangeOfString:str_ChannelUrl].location != NSNotFound )
    //        if( 1 )
    //        {
    //            if( [message.message isEqualToString:@"leave-chat"] )
    //            {
    //                //            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
    //                //                                                                         @"userName":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]}
    //                //                                                               options:NSJSONWritingPrettyPrinted
    //                //                                                                 error:nil];
    //
    //                if( nMyId != nTargetId )
    //                {
    //                    NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다.", [dicM_Result objectForKey:@"userName"]];
    //                    //                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //                    [self.view makeToast:str_Msg withPosition:kPositionCenter];
    //                }
    //
    //                [SendBird leaveChannel:str_ChannelUrl];
    //                [SendBird disconnect];
    //            }
    //            else if( [message.message isEqualToString:@"join-chat"] )
    //            {
    //                if( nMyId != nTargetId )
    //                {
    //                    NSString *str_Msg = [NSString stringWithFormat:@"%@님이 입장하셨습니다.", [dicM_Result objectForKey:@"userName"]];
    //                    //                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //                    [self.view makeToast:str_Msg withPosition:kPositionCenter];
    //                }
    //            }
    //            else if( [message.message isEqualToString:@"regist-qna"] )
    //            {
    //                if( nMyId != nTargetId )
    //                {
    //                    NSDictionary *dic_Tmp = [dicM_Result objectForKey:@"result"];
    //                    if( dic_Tmp )
    //                    {
    //                        dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    //                        dispatch_async(dumpLoadQueue, ^{
    //
    //                            dispatch_async(dispatch_get_main_queue(), ^{
    //
    //                                [self.arM_List addObject:dic_Tmp];
    //                                [self.tbv_List reloadData];
    //                                [self.tbv_List setNeedsLayout];
    //                                [self scrollToTheBottom:YES];
    //                            });
    //                        });
    //                    }
    //                    else
    //                    {
    //                        [dicM_Result setObject:@"qna" forKey:@"itemType"];
    //                        [self updateOneList:dicM_Result];
    //                    }
    //                }
    //            }
    //            else if( [message.message isEqualToString:@"regist-leave"] )
    //            {
    //                [dicM_Result setObject:@"cmd" forKey:@"itemType"];
    //                [self updateOneList:dicM_Result];
    //            }
    //            else if( [message.message isEqualToString:@"regist-invite"] )
    //            {
    //                [dicM_Result setObject:@"cmd" forKey:@"itemType"];
    //                [self updateOneList:dicM_Result];
    //            }
    //            else if( [message.message isEqualToString:@"delete-qna"] )
    //            {
    //                //질문삭제
    //                NSInteger nFindIdx = -1;
    //                NSInteger nGroupId = 0;
    //                NSInteger nEId = [[dicM_Result objectForKey:@"eId"] integerValue];
    //                for( NSInteger i = 0; i < self.arM_List.count; i++ )
    //                {
    //                    NSDictionary *dic_Tmp = self.arM_List[i];
    //                    NSInteger nEId_Tmp = [[dic_Tmp objectForKey:@"eId"] integerValue];
    //                    if( nEId == nEId_Tmp )
    //                    {
    //                        nFindIdx = i;
    //                        nGroupId = [[dic_Tmp objectForKey:@"groupId"] integerValue];
    //                        break;
    //                    }
    //                }
    //
    //                if( nFindIdx > -1 )
    //                {
    //                    [self.arM_List removeObjectAtIndex:nFindIdx];
    //                    [self setMiddleDate];
    //                }
    //
    //
    //                dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    //                dispatch_async(dumpLoadQueue, ^{
    //
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //                        [self.tbv_List reloadData];
    //                    });
    //                });
    //
    //
    ////                NSMutableArray *arM_Tmp = [NSMutableArray array];
    ////                for( NSInteger i = 0; i < self.arM_List.count; i++ )
    ////                {
    ////                    NSDictionary *dic_Tmp = self.arM_List[i];
    ////                    NSInteger nGroupIdTmp = [[dic_Tmp objectForKey:@"groupId"] integerValue];
    ////                    if( nGroupId != nGroupIdTmp )
    ////                    {
    ////                        [arM_Tmp addObject:dic_Tmp];
    ////                    }
    ////                }
    ////
    ////                self.arM_List = arM_Tmp;
    ////                [self setMiddleDate];
    ////                [self.tbv_List reloadData];
    //            }
    //            else if( [message.message isEqualToString:@"solve-exam"] )
    //            {
    //                [dicM_Result setObject:@"cmd" forKey:@"itemType"];
    //                [self updateOneShare:dicM_Result];
    //            }
    //            else if( [message.message isEqualToString:@"shareExam"] )
    //            {
    //                [dicM_Result setObject:@"cmd" forKey:@"itemType"];
    //                [self updateOneShare:dicM_Result];
    //            }
    //            else if( [message.message isEqualToString:@"shareQuestion"] )
    //            {
    //                [dicM_Result setObject:@"cmd" forKey:@"itemType"];
    //                [self updateOneShare:dicM_Result];
    //            }
    //
    //        }
    //        else
    //        {
    ////            if( [message.message isEqualToString:@"dashBoardUpdate"] )
    ////            {
    ////                [[NSNotificationCenter defaultCenter] postNotificationName:@"DashBoardUpdate" object:message.data];
    ////            }
    //        }
    //
    //
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
}

- (void)updateOneShare:(NSDictionary *)dic
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]], @"eId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"itemType"]], @"itemType",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    //    __block BOOL isMy = NO;
    //    if( [[dic objectForKey:@"userId"] integerValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
    //    {
    //        isMy = YES;
    //        return;
    //    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/files/info"
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
                                                dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
                                                dispatch_async(dumpLoadQueue, ^{
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        NSDictionary *dic_Tmp = [NSDictionary dictionaryWithDictionary:resulte];
                                                        //                                                        NSDictionary *dic_DataMap = [dic_Tmp objectForKey:@"dataMap"];
                                                        NSArray *ar_Body = [resulte objectForKey:@"qnaBody"];
                                                        NSDictionary *dic_DataMap = [ar_Body firstObject];
                                                        
                                                        NSDictionary *dic_Action = [dic_DataMap objectForKey:@"actionMap"];
                                                        
                                                        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                        [dicM setObject:dic_Action forKey:@"actionMap"];
                                                        
                                                        [weakSelf.arM_List addObject:dicM];
                                                        [weakSelf.tbv_List reloadData];
                                                        [weakSelf scrollToTheBottom:YES];
                                                        
                                                        
                                                        
                                                        NSMutableDictionary *dicM_DashBoard = [NSMutableDictionary dictionary];
                                                        [dicM_DashBoard setObject:@"share" forKey:@"msgType"];
                                                        [dicM_DashBoard setObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]] forKey:@"eId"];
                                                        [dicM_DashBoard setObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]] forKey:@"questionId"];
                                                        
                                                        //                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_DashBoard
                                                        //                                                                                                   options:NSJSONWritingPrettyPrinted
                                                        //                                                                                                     error:&error];
                                                        //                                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                        
                                                        [weakSelf sendDashboardUpdate:dicM_DashBoard];
                                                        //                                                [SendBird sendMessage:@"dashBoardUpdate" withData:jsonString];
                                                    });
                                                });
                                                
                                            }
                                        }
                                    }];
}

- (void)updateOneList:(NSDictionary *)dic
{
    /*
     질문
     eId = 9022;
     itemType = qna;
     questionId = 18119;
     
     
     댓글
     eId = 9004;
     itemType = reply;
     questionId = 18119;
     replyId = 8990;        //부모의 eId
     */
    
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]], @"eId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"itemType"]], @"itemType",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    __block BOOL isMy = NO;
    //    if( [[dic objectForKey:@"userId"] integerValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
    //    {
    //        isMy = YES;
    //        return;
    //    }
    //이건 아이템 하나에 대한 정보를 가져오는 api임
    //근데 등록을 하면 리턴값으로 해당 아이템이 넘어오지 않나?
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/files/info"
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
                                                //                                                //////전송완료 업데이트 코드//////////
                                                //                                                if( [[dic objectForKey:@"userId"] integerValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
                                                //                                                {
                                                //                                                    if( self.arM_List == nil || self.arM_List.count <= 0 || nLastMyIdx < 0 )
                                                //                                                    {
                                                //                                                        //예외처리
                                                //                                                        return;
                                                //                                                    }
                                                //
                                                //                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[nLastMyIdx]];
                                                //                                                    if( [[dicM objectForKey_YM:@"type"] isEqualToString:@"date"] )
                                                //                                                    {
                                                //                                                        nLastMyIdx++;
                                                //                                                        if( self.arM_List.count > nLastMyIdx )
                                                //                                                        {
                                                //                                                            nLastMyIdx = -1;
                                                //                                                            return;
                                                //                                                        }
                                                //                                                        dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[nLastMyIdx]];
                                                //                                                    }
                                                //
                                                //                                                    [dicM setObject:@"Y" forKey:@"isDone"];
                                                //                                                    [self.arM_List replaceObjectAtIndex:nLastMyIdx withObject:dicM];
                                                //
                                                ////                                                    [self.tbv_List beginUpdates];
                                                ////                                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nLastMyIdx inSection:0];
                                                ////                                                    NSArray *array = [NSArray arrayWithObjects:indexPath, nil];
                                                ////                                                    [self.tbv_List reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
                                                ////                                                    [self.tbv_List endUpdates];
                                                //
                                                //                                                    [self.tbv_List reloadData];
                                                //                                                    nLastMyIdx = -1;
                                                //                                                    return;
                                                //                                                }
                                                //                                                ///////////////////////////////
                                                
                                                
                                                
                                                if( [[dic objectForKey:@"itemType"] isEqualToString:@"qna"] )
                                                {
                                                    //질문
                                                    if( isMy )
                                                    {
                                                        for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                        {
                                                            NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                            if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                            {
                                                                [weakSelf.arM_List removeObjectAtIndex:i];
                                                                [weakSelf.arM_List insertObject:resulte atIndex:i];
                                                                //                                                                [weakSelf setMiddleDate];
                                                                //                                                                [weakSelf.tbv_List reloadData];
                                                                return;
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        [weakSelf.arM_List addObject:resulte];
                                                    }
                                                }
                                                else if( [[dic objectForKey:@"itemType"] isEqualToString:@"cmd"] )
                                                {
                                                    //나감 또는 초대
                                                    if( isMy )
                                                    {
                                                        for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                        {
                                                            NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                            if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                            {
                                                                [weakSelf.arM_List removeObjectAtIndex:i];
                                                                [weakSelf.arM_List insertObject:resulte atIndex:i];
                                                                //                                                                [weakSelf setMiddleDate];
                                                                //                                                                [weakSelf.tbv_List reloadData];
                                                                return;
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        [weakSelf.arM_List addObject:resulte];
                                                    }
                                                }
                                                else
                                                {
                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                    {
                                                        NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                        NSInteger nEId = [[dic_Sub objectForKey:@"groupId"] integerValue];
                                                        NSInteger nParentEid = [[dic objectForKey:@"replyId"] integerValue];
                                                        if( nEId == nParentEid )
                                                        {
                                                            BOOL isLastObj = YES;
                                                            NSInteger nPK = i;
                                                            for( NSInteger j = nPK; j < weakSelf.arM_List.count; j++ )
                                                            {
                                                                NSDictionary *dic_Sub2 = weakSelf.arM_List[j];
                                                                NSInteger nGroupId = [[dic_Sub2 objectForKey:@"groupId"] integerValue];
                                                                if( nGroupId != nParentEid )
                                                                {
                                                                    isLastObj = NO;
                                                                    nPK = j;
                                                                    break;
                                                                }
                                                            }
                                                            
                                                            if( isLastObj )
                                                            {
                                                                NSDictionary *dic_Tmp = [weakSelf.arM_List lastObject];
                                                                NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                
                                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                
                                                                if( isMy )
                                                                {
                                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                                    {
                                                                        NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                                        if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                                        {
                                                                            [weakSelf.arM_List removeObjectAtIndex:i];
                                                                            [weakSelf.arM_List insertObject:resulte atIndex:i];
                                                                            //                                                                            [weakSelf setMiddleDate];
                                                                            //                                                                            [weakSelf.tbv_List reloadData];
                                                                            return;
                                                                        }
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    [weakSelf.arM_List addObject:resulte];
                                                                }
                                                            }
                                                            else
                                                            {
                                                                NSDictionary *dic_Tmp = [weakSelf.arM_List objectAtIndex:nPK - 1];
                                                                NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                
                                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                
                                                                if( isMy )
                                                                {
                                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                                    {
                                                                        NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                                        if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                                        {
                                                                            [weakSelf.arM_List replaceObjectAtIndex:i withObject:resulte];
                                                                            //                                                                            [weakSelf setMiddleDate];
                                                                            //                                                                            [weakSelf.tbv_List reloadData];
                                                                            return;
                                                                        }
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    [weakSelf.arM_List insertObject:dicM atIndex:nPK];
                                                                }
                                                            }
                                                            break;
                                                        }
                                                    }
                                                }
                                                
                                                //혹시라도 같은게 있으면 빼주기 (중복되어 올라오는 현상에 대한 방어코드)
                                                for( NSInteger i = 0; i < weakSelf.arM_List.count - 1; i++ )
                                                {
                                                    NSDictionary *dic_Current = weakSelf.arM_List[i];
                                                    NSDictionary *dic_Next = weakSelf.arM_List[i + 1];
                                                    
                                                    if( [[dic_Current objectForKey_YM:@"eId"] integerValue] != 0 && [[dic_Current objectForKey_YM:@"eId"] integerValue] == [[dic_Next objectForKey_YM:@"eId"] integerValue] )
                                                    {
                                                        [weakSelf.arM_List removeObjectAtIndex:i + 1];
                                                        break;
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
                                            dispatch_async(dumpLoadQueue, ^{
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    NSLog(@"@@@@@@@@@@@@@@@@@@@Start@@@@@@@@@@@@@@@@@@@");
                                                    [weakSelf setMiddleDate];
                                                    [weakSelf.tbv_List reloadData];
                                                    
                                                    if( self.arM_List.count > 0 )
                                                    {
                                                        //다른 사람이 글을 썼을때 하단부터 오프셋이 150보다 작으면 스크롤 내려
                                                        if( (weakSelf.tbv_List.contentSize.height - (weakSelf.tbv_List.contentOffset.y + weakSelf.tbv_List.frame.size.height)) <
                                                           ([self getMargin] + weakSelf.v_CommentKeyboardAccView.frame.size.height) )
                                                        {
                                                            [weakSelf scrollToTheBottom:YES];
                                                        }
                                                    }
                                                    NSLog(@"@@@@@@@@@@@@@@@@@@@End@@@@@@@@@@@@@@@@@@@");
                                                });
                                            });
                                            
                                        }
                                    }];
}

- (NSInteger)getMargin
{
    id message = [self.messages lastObject];
    
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = message;
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
    if( ar_Body.count > 0 )
    {
        NSDictionary *dic_Body = [ar_Body firstObject];
        NSString *str_QnaType = [dic_Body objectForKey:@"qnaType"];
        if( [str_QnaType isEqualToString:@"image"] || [str_QnaType isEqualToString:@"video"] )
        {
            return 550;
        }
    }
    
    return 250;
}

- (void)onReload:(NSNotification *)noti
{
    NSLog(@"%@", noti.object);
    
    //    [self startSendBird];
    
    
    ////    self.str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", self.str_RId];
    //    NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.str_RoomName, self.str_RId];
    //    
    //    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                        kSendBirdApiToken, @"auth",
    //                                        self.str_ChannelUrl, @"channel_url",
    //                                        str_ChannelName, @"name",
    //                                        nil];
    //    
    //    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:@"channel/create"
    //                                             param:dicM_Params
    //                                        withMethod:@"POST"
    //                                         withBlock:^(id resulte, NSError *error) {
    //                                             
    //                                             if( resulte )
    //                                             {
    //                                                 NSString *str_DashBoardChannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"DashBoardChannel"];
    //
    //                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
    //                                                 {
    //                                                     //이미 방이 있으면 조인
    ////                                                     [SendBird joinChannel:str_ChannelUrl];
    ////                                                     [SendBird joinMultipleChannels:@[str_ChannelUrl, str_DashBoardChannel]];
    ////                                                     [SendBird connect];
    //                                                 }
    //                                                 else
    //                                                 {
    ////                                                     str_ChannelUrl = [resulte objectForKey:@"channel_url"];
    ////                                                     [SendBird joinChannel:str_ChannelUrl];
    ////                                                     [SendBird joinMultipleChannels:@[[resulte objectForKey:@"channel_url"], str_DashBoardChannel]];
    ////                                                     [SendBird connect];
    //                                                 }
    //                                             }
    ////                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"Test33" object:nil];
    //                                             
    //
    //                                             [self performSelector:@selector(sendReloadDelay:) withObject:noti.object afterDelay:1.0f];
    //                                         }];
}

- (void)sendReloadDelay:(NSString *)aTesterId
{
    NSInteger nTesterId = [aTesterId integerValue];
    if( nTesterId > 0 )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            aTesterId, @"testerId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/exit/solve/exam"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                
                                            }
                                        }];
    }
    
    //    [SendBird sendMessage:@"solve-exam" withData:nil];
}

- (void)userImageTap:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    //    NSDictionary *dic = self.arM_List[view.tag];
    SBDUserMessage *message = self.messages[view.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    //    vc.isManagerView = YES;
    //    vc.isPermission = YES;
    SBDUser *user = (SBDUser *)message.sender;
    vc.str_UserIdx = user.userId;
    vc.isShowNavi = YES;
    vc.isAnotherUser = YES;
    //    vc.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:vc animated:YES];
}





- (void)scrollToBottomWithForce:(BOOL)force
{
    if (self.messages.count == 0) {
        return;
    }
    
    //    if (self.scrollLock && force == NO) {
    //        return;
    //    }
    
    NSInteger currentRowNumber = [self.tbv_List numberOfRowsInSection:0];
    
    //    NSLog(@"in table view: %lld", (long long)currentRowNumber);
    //    NSLog(@"in count in t: %lld", (long long)self.messages.count);
    
    //    if (currentRowNumber != self.messages.count) {
    //        return;
    //    }
    
    [self.tbv_List scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowNumber - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark - SBDelegate
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    // Received a chat message
    
    if (sender == self.channel)
    {
        SBDUserMessage *data = (SBDUserMessage *)message;
        NSLog(@"%@", data.message);
        NSLog(@"%@", data.customType);
        NSLog(@"%@", data.data);
        
        NSString *str_Data = data.data;
        NSData *jsonData = [str_Data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        NSString *str_Action = [dic objectForKey_YM:@"mesgAction"];
        if( [str_Action isEqualToString:@"wellcomeMesg"] )
        {
            [self.arM_AutoAnswer removeAllObjects];
            
            self.autoChatMode = kPrintExam;
            
            NSString *str_ExamList = [dic objectForKey:@"examList"];
            if( str_ExamList != nil )
            {
                NSData *jsonData = [str_ExamList dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *ar_ExamList = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                for( NSInteger i = 0; i < ar_ExamList.count; i++ )
                {
                    NSDictionary *dic_ExamList = ar_ExamList[i];
                    [self.arM_AutoAnswer addObject:dic_ExamList];
                }
                
                [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
                [self showTempleteKeyboard];
            }
        }
        else if( [str_Action isEqualToString:@"selectNextStep"] || [data.message isEqualToString:@"계속 풀겠습니까?"] )
        {
            [self.arM_AutoAnswer removeAllObjects];
            
            self.autoChatMode = kPrintContinue;
            self.dic_PrintItemInfo = dic;
            
            [self.arM_AutoAnswer addObject:@{@"title":@"계속 풀기"}];
            [self.arM_AutoAnswer addObject:@{@"title":@"다른 문제로"}];

            [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
            [self showTempleteKeyboard];
        }
        else if( [str_Action isEqualToString:@"printQuestionItem"] )
        {
            [self.arM_AutoAnswer removeAllObjects];
            
            self.autoChatMode = kPrintItem;
            self.dic_PrintItemInfo = dic;
            self.arM_AutoAnswer = [NSMutableArray arrayWithArray:[dic objectForKey_YM:@"itemInfo"]];
            [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
            [self showTempleteKeyboard];
        }
        else if( [str_Action isEqualToString:@"checkUserAnswer"] )
        {
            self.autoChatMode = kPrintAnswer;
            
            [self.arM_AutoAnswer removeAllObjects];
            
            self.dic_PrintItemInfo = dic;
            
            NSString *str_IsExplain = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"existExplain"]];    //해설 여부
            NSString *str_IsCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"isCorrect"]];       //정답 여부
            
            if( [str_IsCorrect isEqualToString:@"N"] )
            {
                //오답일 경우
                [self.arM_AutoAnswer addObject:@{@"title":@"정답을 알려주세요"}];
                
                if( [str_IsExplain isEqualToString:@"Y"] )
                {
                    [self.arM_AutoAnswer addObject:@{@"title":@"해설을 보여주세요"}];
                }
                
                [self.arM_AutoAnswer addObject:@{@"title":@"다음 문제"}];
            }
            else
            {
                //정답일 경우
                if( [str_IsExplain isEqualToString:@"Y"] )
                {
                    [self.arM_AutoAnswer addObject:@{@"title":@"해설을 보여주세요"}];
                }
                
                [self.arM_AutoAnswer addObject:@{@"title":@"다음 문제"}];
            }
            
            [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
            [self showTempleteKeyboard];
        }
        else if( [str_Action isEqualToString:@"printReport"] )
        {
            //새로운 문제
            self.autoChatMode = kNextExam;
            
            [self.arM_AutoAnswer removeAllObjects];
            
            self.dic_PrintItemInfo = dic;
            
            [self.arM_AutoAnswer addObject:@{@"title":@"다음 문제"}];
            
            [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
            [self showTempleteKeyboard];
        }
        
        if( [data.customType isEqualToString:@"audio"] )
        {
            
        }
        
        [self.channel markAsRead];
        
        if( [message isKindOfClass:[SBDAdminMessage class]] )
        {
            SBDUserMessage *userMessage = (SBDUserMessage *)message;
            if( [userMessage.customType isEqualToString:@"cmd"] )
            {
                NSLog(@"%@", userMessage.data);
                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", json);
                
                if( [[json objectForKey:@"type"] isEqualToString:@"USER_ENTER"] )
                {
                    NSDictionary *dic_Sender = nil;
                    id sender = [json objectForKey:@"sender"];
                    if( [sender isKindOfClass:[NSDictionary class]] )
                    {
                        dic_Sender = sender;
                    }
                    else if( [sender isKindOfClass:[NSArray class]] )
                    {
                        dic_Sender = [sender firstObject];
                    }
                    else if( [sender isKindOfClass:[NSString class]] )
                    {
                        dic_Sender = [NSJSONSerialization JSONObjectWithData:[sender dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    }
                    
                    NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
                    if( nMyId != [[dic_Sender objectForKey:@"user_id"] integerValue] )
                    {
                        NSString *str_Msg = [NSString stringWithFormat:@"%@님이 입장하였습니다", [dic_Sender objectForKey:@"nickname"]];
                        [self.navigationController.view makeToast:str_Msg withPosition:kPositionCenter];
                    }
                    
                    return;
                }
                
                [self.channel markAsRead];
                
                [self.messages addObject:message];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tbv_List reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                [self scrollToBottomWithForce:NO];
                        
                        if( self.messages.count > 0 )
                        {
                            //다른 사람이 글을 썼을때 하단부터 오프셋이 200보다 작으면 스크롤 내려
                            if( (self.tbv_List.contentSize.height - (self.tbv_List.contentOffset.y + self.tbv_List.frame.size.height)) <
                               ([self getMargin] + self.v_CommentKeyboardAccView.frame.size.height) )
                            {
                                [self scrollToTheBottom:YES];
                            }
                        }
                        
                    });
                });
            }
        }
        else
        {
            [self.messages addObject:message];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tbv_List reloadData];
                
                //                NSArray *visibleRows = [self.tbv_List indexPathsForVisibleRows];
                
                //                            [UIView setAnimationsEnabled:NO];
                //                            [self.tbv_List beginUpdates];
                //                [self.tbv_List reloadRowsAtIndexPaths:visibleRows
                //                                     withRowAnimation:UITableViewRowAnimationNone];
                
                //                [self.tbv_List reloadRowsAtIndexPaths:visibleRows
                //                                     withRowAnimation:UITableViewRowAnimationNone];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                [self scrollToBottomWithForce:NO];
                    
                    if( self.messages.count > 0 )
                    {
                        //                    SBDUserMessage *data = (SBDUserMessage *)message;
                        //                    NSLog(@"data.message : %@", data.message);
                        //                    NSLog(@"data.customType : %@", data.customType);
                        //                    NSLog(@"data.data : %@", data.data);
                        
                        //다른 사람이 글을 썼을때 하단부터 오프셋이 200보다 작으면 스크롤 내려
                        if( (self.tbv_List.contentSize.height - (self.tbv_List.contentOffset.y + self.tbv_List.frame.size.height)) <
                           ([self getMargin] + fKeyboardHeight) )
                        {
                            [self scrollToTheBottom:YES];
                        }
                        else
                        {
                            //새로운 메세지
                            if( self.v_CommentKeyboardAccView.tv_Contents.isFirstResponder )
                            {
                                [ALToastView toastKeyboardTop:[UIApplication sharedApplication].keyWindow withText:@"새로운 메세지"];
                            }
                            else
                            {
                                [Util showToast:@"새로운 메세지"];
                            }
                        }
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [self.tbv_List reloadData];
                            
                            //                            NSArray *visibleRows = [self.tbv_List indexPathsForVisibleRows];
                            
                            //                            [UIView setAnimationsEnabled:NO];
                            //                            [self.tbv_List beginUpdates];
                            //                            [self.tbv_List reloadRowsAtIndexPaths:visibleRows
                            //                                                  withRowAnimation:UITableViewRowAnimationNone];
                            //                            [self.tbv_List endUpdates];
                            //                            [UIView setAnimationsEnabled:YES];
                            
                        });
                    }
                });
            });
        }
    }
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender didUpdateMessage:(SBDBaseMessage * _Nonnull)message
{
    //    if (sender == self.channel)
    //    {
    //        [self.channel markAsRead];
    //        
    //        [self.messages addObject:message];
    //        
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self.tbv_List reloadData];
    //            
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                //                [self scrollToBottomWithForce:NO];
    //                
    //                if( self.messages.count > 0 )
    //                {
    //                    //                    SBDUserMessage *data = (SBDUserMessage *)message;
    //                    //                    NSLog(@"data.message : %@", data.message);
    //                    //                    NSLog(@"data.customType : %@", data.customType);
    //                    //                    NSLog(@"data.data : %@", data.data);
    //                    
    //                    //다른 사람이 글을 썼을때 하단부터 오프셋이 200보다 작으면 스크롤 내려
    //                    if( (self.tbv_List.contentSize.height - (self.tbv_List.contentOffset.y + self.tbv_List.frame.size.height)) <
    //                       ([self getMargin] + self.v_CommentKeyboardAccView.frame.size.height) )
    //                    {
    //                        [self scrollToTheBottom:YES];
    //                    }
    //                    
    //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                        [self.tbv_List reloadData];
    //                    });
    //                }
    //                
    //            });
    //        });
    //    }
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
    
    //    SBDBaseChannel *baseChannel = (SBDBaseChannel *)sender;
    //    NSLog(@"%@", baseChannel.channelUrl);
    //    
    //    NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
    //    if( nMyId != [user.userId integerValue] )
    //    {
    //        NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다.", user.nickname];
    //        //                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //        [self.view makeToast:str_Msg withPosition:kPositionCenter];
    //    }
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidEnter:(SBDUser * _Nonnull)user {
    // When a new user entered the open channel
    
    //    SBDBaseChannel *baseChannel = (SBDBaseChannel *)sender;
    //    NSLog(@"%@", baseChannel.channelUrl);
    //    
    //    NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
    //    if( nMyId != [user.userId integerValue] )
    //    {
    //        NSString *str_Msg = [NSString stringWithFormat:@"%@님이 입장하셨습니다.", user.nickname];
    //        //                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //        [self.view makeToast:str_Msg withPosition:kPositionCenter];
    //    }
    
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
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    // When a channel has been deleted
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    // When a message has been deleted
    
    if (sender == self.channel)
    {
        for (id message in self.messages)
        {
            if( [message isKindOfClass:[SBDBaseMessage class]] )
            {
                SBDBaseMessage *ms = (SBDBaseMessage *)message;
                if (ms.messageId == messageId)
                {
                    //                    [self.navigationController.view makeToast:@"삭제 되었습니다" withPosition:kPositionCenter];
                    [ALToastView toastInView:self.navigationController.view withText:@"삭제 되었습니다"];
                    
                    [self.messages removeObject:message];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tbv_List reloadData];
                    });
                    break;
                }
            }
        }
        
        //        for (SBDBaseMessage *message in self.messages)
        //        {
        //            if (message.messageId == messageId)
        //            {
        //                [self.messages removeObject:message];
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    [self.tbv_List reloadData];
        //                });
        //                break;
        //            }
        //        }
    }
}

/**
 *  Invoked when reconnection is failed.
 */
- (void)didFailReconnection
{
    
}

/**
 *  Invoked when reconnection is cancelled.
 */
- (void)didCancelReconnection
{
    
}

#pragma mark - SBDConnectionDelegate

- (void)didStartReconnection
{
    
}

- (void)didSucceedReconnection
{
    //나갔다 다시 들어 왔을때
    if( self.messages.count > 0 )
    {
        isLoding = YES;
        
        [self getNextMessage];
    }
}

- (void)getNextMessage
{
    id message = [self.messages lastObject];
    if( [message isKindOfClass:[SBDBaseMessage class]] == NO )
    {
        return;
    }
    
    SBDUserMessage *lastMessage = [self.messages lastObject];
    [self.channel getNextMessagesByMessageId:lastMessage.messageId
                                       limit:100
                                     reverse:NO
                                 messageType:SBDMessageTypeFilterAll
                                  customType:@""
                           completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
                               
                               [self.channel markAsRead];
                               
                               if (messages.count == 0)
                               {
                                   return ;
                               }
                               
                               for (SBDBaseMessage *message in messages)
                               {
                                   [self.messages addObject:message];
                                   
                                   if (self.minMessageTimestamp > message.createdAt)
                                   {
                                       self.minMessageTimestamp = message.createdAt;
                                   }
                               }
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   //                                       CGSize contentSizeBefore = self.tbv_List.contentSize;
                                   
                                   [self.tbv_List reloadData];
                                   [self.tbv_List layoutIfNeeded];
                                   
                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       [self.tbv_List reloadData];
                                   });
                                   
                                   //                                       CGSize contentSizeAfter = self.tbv_List.contentSize;
                                   //
                                   //                                       CGPoint newContentOffset = CGPointMake(0, contentSizeAfter.height - contentSizeBefore.height);
                                   //                                       [self.tbv_List setContentOffset:newContentOffset animated:NO];
                                   
                                   isLoding = NO;
                               });
                           }];
}

@end


