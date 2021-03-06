//
//  ChatFeedViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 24..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#define IMPEDE_PLAYBACK NO

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
#import "ChatDateCell.h"
#import "AudioSessionManager.h"
#import "MyAudioCell.h"
#import "KikRoomInfoViewController.h"
#import "ChatIngUserCell.h"
#import "TwoOtherChatCell.h"
#import "TwoAutoChatAudioCell.h"

@import AVFoundation;
@import MediaPlayer;

#import "KikMyViewController.h"
#import "DZImageEditingController.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSInteger kMoreCount = 30;
static AVPlayer *currentPlayer = nil;
static NSURL *currentUrl = nil;
static AutoChatAudioCell *currentCell = nil;
static UILabel *lb_PlayerTime = nil;
static NSInteger currentEId = -1;
static NSInteger currentTag = 0;
static long long currentCreateTime = -1;
static long long llCurrentMessageId = -1;

static NSInteger kReJoinInterval = 3;
static CGFloat kImageMargin = 80;


static MyAudioCell *myAudioCell = nil;

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
    kEtc            = 4,    //etc
} AutoChatMode;

@interface ChatFeedViewController () <AVAudioPlayerDelegate, AVAudioRecorderDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate, SBDChannelDelegate, SBDConnectionDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UITextFieldDelegate, MPMediaPickerControllerDelegate, DZImageEditingControllerDelegate>
{
    BOOL isLoding;
    BOOL isFirstLoad;   //첫 로드인지 기억했다가 첫로드면 로드중 추가된 메세지는 로드후 애드 시키기 위함
    BOOL hasNext;
    BOOL isShowInRoomMsg;
    BOOL isPlay;
//    BOOL bLastKeybaordStatus;
    BOOL isSendPassible;
    BOOL isMicAni;
    
    NSInteger nPlayEId;
    NSInteger nTmpPlayEId;
    NSInteger nTotalCnt;
    NSInteger nTmpPlayTag;
    NSInteger nTmpEId;
    NSInteger nMicTime;
    
    CGFloat fKeyboardHeight;
    
    NSString *str_UserImagePrefix;
    NSString *str_ImagePreFix;
    NSString *str_TargetUserImageUrl;
    NSString *str_TargetUserName;
    
    NSString *str_ChatType;
    NSString *str_NormalTmpMessage;
    
    NSString *str_ImagePrefix;
    NSString *str_ChannelId;
    
    MWPhotoBrowser *browser;
    
    NSInteger nLastMyIdx;   //내가 등록한 마지막 글 인덱스 (전송완료 체크를 위해 필요)
    
    //    NSString *str_ChannelUrl;
    
    NSInteger nAutoAnswerIdx;
    
    NSString *str_MsgQuestionId;
    NSString *str_MsgTesterId;
    NSString *str_MsgExamId;
    NSString *str_MsgCorrectAnswer;
}
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_TempList;
@property (nonatomic, strong) NSMutableArray *arM_MessageQ;
@property (nonatomic, strong) NSMutableArray *arM_AtList;
@property (nonatomic, strong) NSMutableArray *arM_AtListBackUp;
@property (nonatomic, strong) NSMutableDictionary *dicM_TempMyContents;
@property (nonatomic, strong) NSMutableDictionary *dicM_NextPlayInfo;
@property (nonatomic, strong) NSDictionary *dic_PrintItemInfo;
@property (nonatomic, strong) NSTimer *tm_MessageQ;
@property (nonatomic, strong) NSDictionary *dic_Data;
@property (nonatomic, strong) NSMutableArray *arM_User;
@property (nonatomic, strong) NSMutableArray *arM_AutoAnswer;
@property (nonatomic, strong) NSArray *ar_AutoAnswerBtnInfo;
@property (nonatomic, strong) NSMutableDictionary *dicM_AutoAudio;
@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
@property (nonatomic, assign) AutoChatMode autoChatMode;
@property (nonatomic, strong) NSTimer *tm_Mic;
@property (nonatomic, strong) NSDictionary *dic_SelectedMention;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalUserCount;
@property (nonatomic, weak) IBOutlet UILabel *lb_GroupCount;
@property (nonatomic, weak) IBOutlet UIImageView *iv_TopUser;
@property (nonatomic, weak) IBOutlet UIButton *btn_GroupInfo;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_AtList;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AtHeight;
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
@property (nonatomic, strong) ChatDateCell *c_ChatDateCell;
@property (nonatomic, strong) TwoOtherChatCell *c_TwoOtherChatCell;
@property (nonatomic, strong) TwoAutoChatAudioCell *c_TwoAutoChatAudioCell;
@property (atomic) long long minMessageTimestamp;
//@property (strong, nonatomic) NSArray<SBDBaseMessage *> *dumpedMessages;
//@property (strong, nonatomic) NSMutableArray<SBDBaseMessage *> *messages;
@property (strong, nonatomic) NSMutableArray *messages;

//음성문제 관련
@property (nonatomic, strong) AVPlayerItem *playerItem;
//@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
@property (nonatomic, strong) AudioView *v_Audio;
/////////

//유튜브
@property (nonatomic, strong) YTPlayerView *playerView;
@property (nonatomic, strong) NSString *str_AudioBody;
@property (nonatomic, strong) NSMutableArray *arM_Audios;

@property (nonatomic, strong) AutoAnswerCell *c_AutoAnswerCell;

@property (nonatomic, weak) IBOutlet UITableView *tbv_TempleteList;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BotomListHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_MicWidth;
@property (nonatomic, weak) IBOutlet UIView *v_Mic;
@property (nonatomic, weak) IBOutlet UIView *v_MicContent;

@property (nonatomic, weak) IBOutlet UILabel *lb_MicTimer;
@property (nonatomic, weak) IBOutlet UILabel *lb_MicDescription;
@property (nonatomic, weak) IBOutlet UILabel *lb_MicCancelDescription;
@property (nonatomic, weak) IBOutlet UIImageView *iv_MicAni;
@property (nonatomic, weak) IBOutlet UIButton *btn_Mic;

@property (nonatomic, strong)     AVAudioPlayer       *mic_Player;
@property (nonatomic, strong)     AVAudioRecorder     *mic_Recorder;
@property (nonatomic, strong)     NSString            *mic_RecordedAudioFileName;
@property (nonatomic, strong)     NSURL               *mic_RecordedAudioURL;

@property (nonatomic, weak) IBOutlet UIButton *btn_Title;

@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, assign) CGRect frameRect;

@end

@implementation ChatFeedViewController

- (void)onEnterForegroundNoti
{
//    NSLog(@"BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK BACK ");
//    if( self.dic_BotInfo )
//    {
//        isSendPassible = YES;
//        [self sendBotWelcome];
//    }
//    else
//    {
//        [self.view endEditing:YES];
//        self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
//        self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;
//
//        [UIView animateWithDuration:0.25f animations:^{
//            [self.view layoutIfNeeded];
//        }];
//
//    }
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

//- (void)updateRoomStatus:(NSString *)aStatus
//{
////    __weak __typeof(&*self)weakSelf = self;
//
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        aStatus, @"status",
//                                        self.str_RId, @"rId",
//                                        nil];
//
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/update/chat/user/status"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
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
//                                        }
//                                    }];
//}

- (UIImageView *)createOverlayImageViewWithImage:(UIImage *)image
{
    CGFloat newX = [UIScreen mainScreen].bounds.size.width / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat newY = [UIScreen mainScreen].bounds.size.height / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    self.frameRect = CGRectMake(newX, newY, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    return [[UIImageView alloc] initWithFrame:self.frameRect];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //    [self startSendBird];
    
//    [self updateRoomStatus:@"enter"];
    
    UIImage *overlayImage = [UIImage imageNamed:@"kik_image_edith.png"];
    self.overlayImageView = [self createOverlayImageViewWithImage:overlayImage];
    self.overlayImageView.image = overlayImage;

    self.v_Mic.hidden = YES;

    self.tbv_AtList.layer.borderWidth = 1.f;
    self.tbv_AtList.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
    
    if (IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
    }

    isSendPassible = YES;

    NSLog(@"self.str_PdfImageUrl : %@", self.str_PdfImageUrl);
    
//    self.v_CommentKeyboardAccView.tv_Contents.autocorrectionType = UITextAutocorrectionTypeNo;

    __weak typeof(self)weakSelf = self;

    self.v_MicContent.layer.cornerRadius = self.v_MicContent.frame.size.width / 2;
    self.iv_MicAni.layer.cornerRadius = self.iv_MicAni.frame.size.width / 2;
    
    [self.v_CommentKeyboardAccView setCompletionBlock:^(id completeResult) {
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          
            [weakSelf scrollToTheBottom2:[NSNumber numberWithBool:YES]];
//            [weakSelf performSelector:@selector(scrollToTheBottom2:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4f];
        });
//        [weakSelf moveToScroll:YES];
    }];
    [self.v_CommentKeyboardAccView setCompletionTextChangeBlock:^(id completeResult) {
        
        NSLog(@"%@", completeResult);

        /*
         cc = 2;
         rId = 2492;
         userAffiliation = "\Uc9c4\Uba85\Ud559\Uc6d0\Uc120\Uc0dd";
         userEmail = "ss4@t.com";
         userId = 141;
         userMajor = "";
         userName = jason4;
         userThumbnail = "000/000/noImage3.png";
         userType = user;
         */

        NSMutableString *strM_InputWord = [NSMutableString stringWithString:completeResult];;

        [weakSelf.arM_AtList removeAllObjects];

        if( strM_InputWord.length > 0 )
        {
            if( [strM_InputWord hasPrefix:@"@"] )
            {
                self.v_CommentKeyboardAccView.tv_Contents.textColor = kMainColor;

                if( [strM_InputWord hasPrefix:@"@"] )
                {
                    [strM_InputWord deleteCharactersInRange:NSMakeRange(0, 1)];
                }

                if( strM_InputWord.length == 0 )
                {
                    weakSelf.arM_AtList = [NSMutableArray arrayWithArray:weakSelf.arM_AtListBackUp];
                }
                else
                {
                    NSArray *ar = [weakSelf.arM_AtListBackUp filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userName contains[c] %@", strM_InputWord]];
                    weakSelf.arM_AtList = [NSMutableArray arrayWithArray:ar];
                }
            }
            else
            {
                self.v_CommentKeyboardAccView.tv_Contents.textColor = [UIColor blackColor];
            }

            [weakSelf.tbv_AtList reloadData];
        }
        else
        {
//            weakSelf.arM_AtList = [NSMutableArray arrayWithArray:weakSelf.arM_AtListBackUp];

        }

        NSInteger nLineCount = weakSelf.arM_AtList.count;
        if( nLineCount > 3 )
        {
            nLineCount = 3;
        }
        weakSelf.lc_AtHeight.constant = nLineCount * 44.f;
        [UIView animateWithDuration:0.3f animations:^{

            [weakSelf.view layoutIfNeeded];
        }];
    }];
    
    self.autoChatMode = kPrintExam;
    
    if( fKeyboardHeight <= 0 )
    {
        if( self.v_CommentKeyboardAccView.tv_Contents.autocorrectionType == UITextAutocorrectionTypeDefault ||
           self.v_CommentKeyboardAccView.tv_Contents.autocorrectionType == UITextAutocorrectionTypeYes )
        {
            fKeyboardHeight = 258.f;
        }
        else
        {
            fKeyboardHeight = 216.f;
        }
    }
    
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
        self.v_CommentKeyboardAccView.btn_TempleteKeyboard.alpha = YES;
//        self.lc_MicWidth.constant = 45.f;
        [self sendBotWelcome];
        
//        [self updateAtList:@"user"];
    }
    else
    {
        self.v_CommentKeyboardAccView.btn_TempleteKeyboard.alpha = NO;
//        self.lc_MicWidth.constant = 0.f;
        self.tbv_TempleteList.backgroundColor = [UIColor whiteColor];
        
//        [self updateAtList:@"all"];
    }
    
    [self updateAtList:@"bot"];

    //스크롤뷰 내릴때 키보드도 함께 내리기
    BABFrameObservingInputAccessoryView *inputView = [[BABFrameObservingInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    inputView.userInteractionEnabled = NO;
    
    
//    self.v_CommentKeyboardAccView.tv_Contents.inputAccessoryView = inputView;
    
    
    inputView.inputAcessoryViewFrameChangedBlock = ^(CGRect inputAccessoryViewFrame){
        
        CGFloat value = CGRectGetHeight(weakSelf.view.frame) - CGRectGetMinY(inputAccessoryViewFrame) - CGRectGetHeight(weakSelf.v_CommentKeyboardAccView.tv_Contents.inputAccessoryView.frame);
        
        weakSelf.v_CommentKeyboardAccView.lc_Bottom.constant = MAX(0, value);
        
        [weakSelf.view layoutIfNeeded];
        
    };
    ///////////////////////////////
    
    if( self.dic_BotInfo )
    {
//        self.v_CommentKeyboardAccView.btn_KeyboardChange.hidden = NO;
    }
    else
    {
//        self.v_CommentKeyboardAccView.btn_KeyboardChange.hidden = YES;
    }
    
//    [self.v_CommentKeyboardAccView.btn_KeyboardChange addTarget:self action:@selector(onKeyboardChange:) forControlEvents:UIControlEventTouchUpInside];
    
    nAutoAnswerIdx = -1;
    nPlayEId = -1;
    currentEId = -1;
    nTmpPlayEId = -1;
    nTmpPlayTag = -1;
    currentCreateTime = -1;
    lb_PlayerTime = nil;
    
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
    
    self.tbv_TempleteList.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbv_List.frame.size.width, 8.f)];
    self.tbv_TempleteList.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tbv_List.frame.size.width, 8.f)];
    
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
    self.c_ChatDateCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([ChatDateCell class])];
    
    self.c_TwoOtherChatCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([TwoOtherChatCell class])];
    
    self.c_TwoAutoChatAudioCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([TwoAutoChatAudioCell class])];
    
    self.c_AutoAnswerCell = [self.tbv_TempleteList dequeueReusableCellWithIdentifier:NSStringFromClass([AutoAnswerCell class])];
    
//    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AutoAnswerCell" owner:self options:nil];
//    self.c_AutoAnswerCell = [topLevelObjects objectAtIndex:0];
    
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
//        self.messages = [NSMutableArray arrayWithArray:ar];
//        for( NSInteger i = 0; i < self.messages.count; i++ )
//        {
//            id obj = self.messages[i];
//            if( [obj isKindOfClass:[NSDictionary class]] )
//            {
//                NSDictionary *dic = self.messages[i];
//                if( [[dic objectForKey_YM:@"type"] isEqualToString:@"USER_ENTER"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"enterBotRoom"] )
//                {
//                    [self.messages removeObjectAtIndex:i];
//                }
//            }
//        }
//        [self.tbv_List reloadData];
//        [self.tbv_List layoutIfNeeded];
//        [self scrollToTheBottom:NO];
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
    
//    [self.btn_Title setTitle:self.channel.name forState:UIControlStateNormal];
    
    if( self.str_RoomTitle )
    {
        //신규방
//        self.lb_Title.text = self.str_RoomTitle;
//        [self.btn_Title setTitle:self.str_RoomTitle forState:UIControlStateNormal];
        
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
    if( self.arM_AutoAnswer.count <= 0 )
    {
        btn.selected = NO;
        [self.v_CommentKeyboardAccView becomeFirstResponder];
        return;
    }
    
    btn.selected = !btn.selected;
    
//    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    
    if( btn.selected )
    {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - fKeyboardHeight, window.bounds.size.width, fKeyboardHeight)];
//        view.tag = 1982;
//        view.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
//        
//        UITableView *tbv_AutoAnswer = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
//        tbv_AutoAnswer.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 8.f)];
//        tbv_AutoAnswer.tag = 1983;
//        tbv_AutoAnswer.backgroundColor = [UIColor clearColor];
//        tbv_AutoAnswer.separatorStyle = UITableViewCellSeparatorStyleNone;
//        tbv_AutoAnswer.delegate = self;
//        tbv_AutoAnswer.dataSource = self;
//        [tbv_AutoAnswer reloadData];
//        [view addSubview:tbv_AutoAnswer];
//        
//        [window addSubview:view];
//        [window bringSubviewToFront:view];

        [self.v_CommentKeyboardAccView.tv_Contents resignFirstResponder];

//        [UIView animateWithDuration:0.3f animations:^{
//            
//            [self.v_CommentKeyboardAccView resignFirstResponder];
//        }];

    }
    else
    {
//        UIView *view = [window viewWithTag:1982];
//        [view removeFromSuperview];

        [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
        
//        [UIView animateWithDuration:0.3f animations:^{
//           
//            [self.v_CommentKeyboardAccView becomeFirstResponder];
//        }];
        
    }
}

- (void)showTempleteKeyboard
{
    [self.tbv_TempleteList reloadData];
    
    [self.v_CommentKeyboardAccView.tv_Contents resignFirstResponder];
    self.v_CommentKeyboardAccView.keyboardStatus = kTemplete;
    self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;
    
//    self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = YES;
    
    [self moveToScroll:YES];
    
    if( fKeyboardHeight > 0 )
    {
        self.v_CommentKeyboardAccView.lc_Bottom.constant = fKeyboardHeight;
    }
    else
    {
        if( self.v_CommentKeyboardAccView.tv_Contents.autocorrectionType == UITextAutocorrectionTypeDefault ||
           self.v_CommentKeyboardAccView.tv_Contents.autocorrectionType == UITextAutocorrectionTypeYes )
        {
            self.v_CommentKeyboardAccView.lc_Bottom.constant = 258.f;
        }
        else
        {
            self.v_CommentKeyboardAccView.lc_Bottom.constant = 216.f;
        }
        
    }
    
    
    
//    [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
//    [self.v_CommentKeyboardAccView.tv_Contents resignFirstResponder];
    
//    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
//    UIView *view_Tmp = [window viewWithTag:1982];
//    if( view_Tmp )
//    {
//        [view_Tmp removeFromSuperview];
//    }
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - fKeyboardHeight, window.bounds.size.width, fKeyboardHeight)];
//    view.tag = 1982;
//    view.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
//    
//    UITableView *tbv_AutoAnswer = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
//    tbv_AutoAnswer.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 8.f)];
//    tbv_AutoAnswer.tag = 1983;
//    tbv_AutoAnswer.backgroundColor = [UIColor clearColor];
//    tbv_AutoAnswer.separatorStyle = UITableViewCellSeparatorStyleNone;
//    tbv_AutoAnswer.delegate = self;
//    tbv_AutoAnswer.dataSource = self;
//    [tbv_AutoAnswer reloadData];
//    [view addSubview:tbv_AutoAnswer];
//    
//    [window addSubview:view];
//    [window bringSubviewToFront:view];
}

- (void)onKeyboardShow
{
    [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
}

- (void)sendBotWelcome
{
    if( isSendPassible )
    {
        isSendPassible = NO;
        
//        NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//        NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//
//
//        NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
//        [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
//        [dicM_Param setObject:@"test" forKey:@"message"];
//        [dicM_Param setObject:@"cmd" forKey:@"custom_type"];
//        [dicM_Param setObject:@"enterBotRoom" forKey:@"custom_type"];
//
//        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
//        [dicM_Data setObject:@"enterBotRoom" forKey:@"type"];
//
//        NSMutableDictionary *dicM_Inviter = [NSMutableDictionary dictionary];
//        [dicM_Inviter setObject:str_UserId forKey:@"user_id"];
//        [dicM_Inviter setObject:str_UserName forKey:@"nickname"];
//        [dicM_Data setObject:dicM_Inviter forKey:@"sender"];
//
//
//        //    NSMutableArray *arM_Users = [NSMutableArray array];
//        //    [dicM_Data setObject:arM_Users forKey:@"users"];
//
//        [dicM_Data setObject:@"test" forKey:@"message"];
//        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [self.dic_BotInfo objectForKey:@"userId"]] forKey:@"botUserId"];
//        [dicM_Data setObject:@"botChat" forKey:@"roomType"];
//        [dicM_Data setObject:@"user" forKey:@"userType"];
//        [dicM_Data setObject:@"" forKey:@"chatScreen"];
//        [dicM_Data setObject:@"" forKey:@"mesgAction"];
//
//        NSError *error;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data
//                                                           options:NSJSONWritingPrettyPrinted
//                                                             error:&error];
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//        [dicM_Param setObject:jsonString forKey:@"data"];
//
//        [dicM_Param setObject:@"true" forKey:@"is_silent"];

        SBDUser *user = [SBDMain getCurrentUser];
        NSString *str_BotUserId = [NSString stringWithFormat:@"%@", [self.dic_BotInfo objectForKey:@"userId"]];

        NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
        [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
        [dicM_Param setObject:str_BotUserId forKey:@"user_id"];
        [dicM_Param setObject:@"test" forKey:@"message"];
        [dicM_Param setObject:@"enterBotRoom" forKey:@"custom_type"];
        [dicM_Param setObject:@"true" forKey:@"is_silent"];
        
        NSMutableDictionary *dicM_MessageData = [NSMutableDictionary dictionary];
        [dicM_MessageData setObject:@"test" forKey:@"message"];
        [dicM_MessageData setObject:@"chatBot" forKey:@"roomType"];
        [dicM_MessageData setObject:str_BotUserId forKey:@"botUserId"];
        [dicM_MessageData setObject:@"user" forKey:@"userType"];
        
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

        NSLog(@"계속 풀겠습니까 호출 시작");
        NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
        [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
                                                 param:dicM_Param
                                            withMethod:@"POST"
                                             withBlock:^(id resulte, NSError *error) {
        
                                                 NSLog(@"계속 풀겠습니까 호출 끝");
                                                 if( resulte )
                                                 {
                                                     
                                                 }
                                             }];
        
        [self performSelector:@selector(onSendPassibleChange) withObject:nil afterDelay:kReJoinInterval];
    }
}

- (void)onSendPassibleChange
{
    isSendPassible = YES;
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
//                                           [self addTmpImage];
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
                                           NSMutableArray *arM = [NSMutableArray array];
                                           
                                           for( NSInteger i = 0; i < messages.count; i++ )
                                           {
                                               SBDBaseMessage *baseMessage = messages[i];
                                               SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//                                               NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
//                                               NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                               
                                               if( [userMessage.customType isEqualToString:@"USER_ENTER"] ||
                                                  [userMessage.customType isEqualToString:@"enterBotRoom"] ||
                                                  [userMessage.customType isEqualToString:@"cmd"] )
                                               {
                                                   [self.channel deleteMessage:baseMessage completionHandler:^(SBDError * _Nullable error) {
                                                       
                                                   }];
                                                   
//                                                   [arM removeObjectAtIndex:i];
                                               }
                                               else
                                               {
                                                   [arM addObject:baseMessage];
                                               }
                                           }
                                           
                                           
                                           messages = [NSArray arrayWithArray:arM];

                                           
//                                           //이전 메세지 검사해서 날짜 넣어주기
//                                           if( arM.count > 1 )
//                                           {
//                                               NSMutableArray *arM_Tmp = [NSMutableArray array];
//                                               for( NSInteger i = 0; i < arM.count - 1; i++ )
//                                               {
//                                                   id obj = arM[i + 1];
//
//                                                   NSLog(@"%@", obj);
//                                                   if( [obj isKindOfClass:[NSString class]] )
//                                                   {
//
//                                                   }
//                                                   else if( [obj isKindOfClass:[SBDBaseMessage class]] )
//                                                   {
//                                                       SBDBaseMessage *baseMessage = arM[i];
//                                                       [arM_Tmp addObject:baseMessage];
//
//                                                       long long llCreateAt = baseMessage.createdAt;
//                                                       long long llOldCreateAt = [[self getDateNumberHour:llCreateAt] longLongValue] ;
//
//                                                       SBDBaseMessage *nextBaseMessage = arM[i + 1];
//                                                       llCreateAt = nextBaseMessage.createdAt;
//                                                       long long llAfterCreateAt = [[self getDateNumberHour:llCreateAt] longLongValue] ;
//
//                                                       if( llOldCreateAt < llAfterCreateAt )
//                                                       {
//                                                           [arM_Tmp addObject:[self getDateNumber:llCreateAt]];
//                                                       }
//                                                   }
//                                               }
//
//                                               SBDBaseMessage *baseMessage = [arM lastObject];
//                                               [arM_Tmp addObject:baseMessage];
//
//
//                                               [arM_Tmp addObjectsFromArray:self.messages];
//                                               [self.messages removeAllObjects];
//                                               self.messages = [NSMutableArray arrayWithArray:arM_Tmp];
//                                           }
//                                           else
//                                           {
//                                               [arM addObjectsFromArray:self.messages];
//                                               [self.messages removeAllObjects];
//                                               self.messages = [NSMutableArray arrayWithArray:arM];
//                                           }
                                       }

                                       
                                       for (SBDBaseMessage *message in messages)
                                       {
                                           if (self.minMessageTimestamp > message.createdAt)
                                           {
                                               self.minMessageTimestamp = message.createdAt;
                                           }
                                       }

                                       NSMutableArray *arM_Messages = [NSMutableArray arrayWithArray:messages];
                                       [arM_Messages addObjectsFromArray:self.messages];
                                       [self.messages removeAllObjects];
                                       self.messages = [NSMutableArray arrayWithArray:arM_Messages];

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
                                       NSMutableArray *arM = [NSMutableArray array];
                                       for( NSInteger i = 0; i < messages.count; i++ )
                                       {
                                           SBDBaseMessage *baseMessage = messages[i];
                                           SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
                                           NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
//                                           NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                           
                                           if( [userMessage.customType isEqualToString:@"USER_ENTER"] ||
                                              [userMessage.customType isEqualToString:@"enterBotRoom"] ||
                                              [userMessage.customType isEqualToString:@"cmd"] )
                                           {
                                               [self.channel deleteMessage:baseMessage completionHandler:^(SBDError * _Nullable error) {
                                                   
                                               }];
                                               
//                                               [arM removeObjectAtIndex:i];
                                           }
                                           else
                                           {
                                               [arM addObject:baseMessage];
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
                                       
//                                       if( arM.count > 1 )
//                                       {
//                                           //이전 메세지 검사해서 날짜 넣어주기
//                                           NSMutableArray *arM_Tmp = [NSMutableArray array];
//                                           for( NSInteger i = 0; i < self.messages.count - 1; i++ )
//                                           {
//                                               SBDBaseMessage *baseMessage = self.messages[i];
//                                               [arM_Tmp addObject:baseMessage];
//
//                                               long long llCreateAt = baseMessage.createdAt;
//                                               long long llOldCreateAt = [[self getDateNumberHour:llCreateAt] longLongValue] ;
//
//                                               SBDBaseMessage *nextBaseMessage = self.messages[i + 1];
//                                               llCreateAt = nextBaseMessage.createdAt;
//                                               long long llAfterCreateAt = [[self getDateNumberHour:llCreateAt] longLongValue] ;
//
//                                               if( llOldCreateAt < llAfterCreateAt )
//                                               {
//                                                   [arM_Tmp addObject:[self getDateNumber:llCreateAt]];
//                                               }
//                                           }
//
//                                           SBDBaseMessage *baseMessage = [self.messages lastObject];
//                                           [arM_Tmp addObject:baseMessage];
//
//                                           id lastObj = [arM_Tmp lastObject];
//                                           if( [lastObj isKindOfClass:[NSString class]] )
//                                           {
//                                               [arM_Tmp removeLastObject];
//                                           }
//
//                                           self.messages = [NSMutableArray arrayWithArray:arM_Tmp];
//                                       }
                                       
                                       if( self.isAskMode && self.isPdfMode && self.str_PdfImageUrl.length > 0 )
                                       {
                                           [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
//                                           [self addTmpImage];
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
//                                           [self performSelector:@selector(scrollToBottomInterval:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.3f];
                                           
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                               
                                               [self.tbv_List reloadData];
                                               [self performSelector:@selector(scrollToBottomInterval:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1f];
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
    self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;

    
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateRoomStatus) name:@"UpdateRoomStatus" object:nil];


    [self getNextMessage];
    
//    if( self.dic_MoveExamInfo )
//    {
//        [self didSelectedItem:self.dic_MoveExamInfo];
//        self.dic_MoveExamInfo = nil;
//    }
    
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

//- (void)onUpdateRoomStatus
//{
//    [self updateRoomStatus:@"leave"];
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hide];
    
    [self saveChattingMessage];
    
    
    //    [self.v_CommentKeyboardAccView.tv_Contents resignFirstResponder];
    [self.view endEditing:YES];
    self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
    self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;

    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];

    
//    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
//    UIView *view_Tmp = [window viewWithTag:1982];
//    [view_Tmp removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"UpdateRoomStatus"
//                                                  object:nil];

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

- (void)updateAtList:(NSString *)aType
{
    __weak __typeof(&*self)weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        aType, @"userType",
                                        nil];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exist/chat/room/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.arM_AtList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                weakSelf.arM_AtListBackUp = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];

                                            }
                                        }
                                    }];
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
    self.v_CommentKeyboardAccView.fKeyboardHeight = fKeyboardHeight;
    self.lc_BotomListHeight.constant = fKeyboardHeight;

    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
//            self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = bLastKeybaordStatus;
//            if( bLastKeybaordStatus )
//            {
//                [self showTempleteKeyboard];
//            }
            
            if( self.dic_BotInfo && self.arM_AutoAnswer.count > 0 )
            {
                self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = NO;
            }

            self.v_CommentKeyboardAccView.lc_Bottom.constant = keyboardBounds.size.height;
            
            //            self.v_CommentKeyboardAccView.lc_AddWidth.constant = 63.f;
            [self performSelector:@selector(moveToScrollNumber:) withObject:@YES afterDelay:0.3f];
//            [self moveToScroll:YES];
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
//            if( self.dic_BotInfo && self.arM_AutoAnswer.count > 0 )
//            {
//                self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = NO;
//            }
            
//            if( bLastKeybaordStatus )
//            {
//                //템플릿 키보드면
//                return ;
//            }
//            else
//            {
//                
//            }
            
//            bLastKeybaordStatus = self.v_CommentKeyboardAccView.btn_KeyboardChange.selected;
            
//            UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
//            UIView *view_Tmp = [window viewWithTag:1982];
//            [view_Tmp removeFromSuperview];
            
//            self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
            
            
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

- (void)moveToScrollNumber:(NSNumber *)num
{
    [self moveToScroll:[num boolValue]];
}

- (void)moveToScroll:(BOOL)isAnimation
{
    if (self.tbv_List.contentSize.height > self.tbv_List.frame.size.height &&
        self.tbv_List.contentOffset.y < (self.tbv_List.contentSize.height - self.tbv_List.frame.size.height))
    {
        if( self.tbv_List.contentOffset.y + fKeyboardHeight > self.tbv_List.contentSize.height - self.tbv_List.frame.size.height )
        {
            CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
            [self.tbv_List setContentOffset:offset animated:isAnimation];
        }
        else
        {
            CGPoint offset = CGPointMake(0, self.tbv_List.contentOffset.y + fKeyboardHeight);
            [self.tbv_List setContentOffset:offset animated:isAnimation];
        }
    }
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
    if( str_UserImagePrefix == nil || str_UserImagePrefix.length <= 0 )
    {
        str_UserImagePrefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"];
    }

//    SBDUserMessage *lastMessage = (SBDUserMessage *)self.channel.lastMessage;
//    self.lb_Title.text = self.channel.name;
    
    if( self.channel.memberCount == 2 )
    {
        for( NSInteger i = 0; i < self.channel.memberCount; i++ )
        {
            SBDUser *user = self.channel.members[i];
            NSString *str_MyUserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            if( [str_MyUserId isEqualToString:user.userId] == NO )
            {
                [self.btn_Title setTitle:user.nickname forState:UIControlStateNormal];
                break;
            }
        }
    }
    else
    {
        [self.btn_Title setTitle:self.channel.name forState:UIControlStateNormal];
    }
    
    
    
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_RId, @"rId",
//                                        nil];
//    //http://dev2.thoting.com/api/v1/get/chat/room/header/info?uuid=3FF1C31A-7B8A-48DF-8EDB-ACC7212C85B4&rId=515&apiToken=753a15183f55198a4e85bb10542836a9
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/chat/room/header/info"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//
//                                        [MBProgressHUD hide];
//
//                                        if( resulte )
//                                        {
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                NSArray *ar_Tmp = [NSArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
//                                                for( NSInteger i = 0; i < ar_Tmp.count; i++ )
//                                                {
//                                                    NSDictionary *dic = [ar_Tmp objectAtIndex:i];
//                                                    [self.arM_User addObject:[dic objectForKey:@"userId"]];
//                                                }
//
//                                                self.dic_Data = [NSDictionary dictionaryWithDictionary:resulte];
//
//                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
//
//                                                str_ChannelId = [resulte objectForKey_YM:@"channelId"];
//
//                                                NSString *str_HeaderUrl = [resulte objectForKey_YM:@"userImg_prefix"];
//                                                if( str_HeaderUrl.length > 0 )
//                                                {
//                                                    str_ImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
//                                                }
//
//                                                str_HeaderUrl = [resulte objectForKey_YM:@"image_prefix"];
//                                                if( str_HeaderUrl.length > 0 )
//                                                {
//                                                    str_ImagePreFix = [resulte objectForKey_YM:@"image_prefix"];
//                                                }
//                                                else
//                                                {
//                                                    str_ImagePreFix = @"http://data.thoting.com:8282/c_edujm/exam/";
//                                                }
//
////                                                self.lb_Title.text = [resulte objectForKey_YM:@"roomName"];
//                                                [self.btn_Title setTitle:self.channel.name forState:UIControlStateNormal];
//                                                self.lb_GroupCount.text = @"";
//
//                                                str_ChatType = [resulte objectForKey:@"roomType"];
//                                                if( [str_ChatType isEqualToString:@"group"] )
//                                                {
////                                                    self.btn_GroupInfo.hidden = NO;
////                                                    self.iv_TopUser.hidden = YES;
//                                                }
//                                                else if( [str_ChatType isEqualToString:@"channel"] )
//                                                {
////                                                    self.btn_GroupInfo.hidden = YES;
////                                                    self.iv_TopUser.hidden = NO;
//                                                }
//                                                else if( [str_ChatType isEqualToString:@"user"] || [str_ChatType isEqualToString:@"chatBot"] )
//                                                {
////                                                    self.btn_GroupInfo.hidden = YES;
////                                                    self.iv_TopUser.hidden = NO;
//                                                }
//
//                                                if( self.channel.memberCount > 2 && [str_ChatType isEqualToString:@"group"] )
//                                                {
////                                                    self.lb_TotalUserCount.text = str_TotalUserCount;
//                                                    self.iv_TopUser.backgroundColor = self.roomColor ? self.roomColor : [UIColor colorWithHexString:@"9ED8EB"];
//                                                }
//                                                else if( [str_ChatType isEqualToString:@"channel"] )
//                                                {
//                                                    self.lb_TotalUserCount.text = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"userCount"]];
//                                                    [self.iv_TopUser sd_setImageWithURL:self.channelImageUrl];
//                                                }
//                                                else if( [str_ChatType isEqualToString:@"user"] || [str_ChatType isEqualToString:@"chatBot"] )
//                                                {
//                                                    str_TargetUserImageUrl = [resulte objectForKey_YM:@"thumbnail"];
//                                                    str_TargetUserName = [resulte objectForKey_YM:@"userName"];
//
//                                                    if( self.channel.memberCount <= 2 || [str_ChatType isEqualToString:@"chatBot"] )
////                                                    if( 1 )
//                                                    {
//                                                        [self.btn_Title setTitle:@"       " forState:UIControlStateNormal];
//                                                        self.iv_TopUser.alpha = YES;
//                                                        self.iv_TopUser.hidden = NO;
//                                                    }
//                                                    else
//                                                    {
//                                                        [self.btn_Title setTitle:str_TargetUserName forState:UIControlStateNormal];
//                                                    }
////                                                    self.lb_Title.text = [resulte objectForKey_YM:@"userName"];
//                                                    [self.iv_TopUser sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix
//                                                                                                  withFooter:[resulte objectForKey_YM:@"thumbnail"]] placeholderImage:BundleImage(@"no_image.png")];
////                                                    [self.btn_Title setTitle:self.str_RoomTitle forState:UIControlStateNormal];
//                                                }
//
//                                                dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
//                                                dispatch_async(dumpLoadQueue, ^{
//
//                                                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                                                        [self.tbv_List reloadData];
//                                                        [self.tbv_List setNeedsLayout];
//                                                    });
//                                                });
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                        }
//                                    }];
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
        
        [UIView animateWithDuration:0.1f animations:^{
        
            [self.tbv_List setContentOffset:offset];
//            [self.tbv_List setContentOffset:offset animated:animated];
        }];
        
        
        //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.arM_List.count-1 inSection:0];
        //        [self.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)scrollToTheBottom2:(NSNumber *)ani
{
    if( self.tbv_List.contentSize.height < self.tbv_List.frame.size.height )
    {
        return;
    }
    
    if( self.messages.count > 0 )
    {
        if( self.tbv_List.contentSize.height > self.tbv_List.contentOffset.y + self.view.frame.size.height )
        {
//            CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
//            if( self.v_CommentKeyboardAccView.lc_Bottom.constant > 0 )
//            {
//                offset = CGPointMake(0, self.tbv_List.contentSize.height + 8);
//            }
            
            [self.tbv_List setContentOffset:CGPointMake(0, self.tbv_List.contentOffset.y + fKeyboardHeight) animated:[ani boolValue]];
        }
        else
        {
            @try
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
                [self.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:[ani boolValue]];
            }
            @catch (NSException *exception)
            {
                
            }
        }

//        CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
//        if( self.v_CommentKeyboardAccView.lc_Bottom.constant > 0 )
//        {
//            offset = CGPointMake(0, self.tbv_List.contentSize.height + 8);
//        }
//        
////        [self.tbv_List setContentOffset:offset animated:[ani boolValue]];
//        else
//        {
//            @try
//            {
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
//                [self.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:[ani boolValue]];
//            }
//            @catch (NSException *exception)
//            {
//                
//            }
//            //            [self.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:[ani boolValue]];
//        }
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
    if( scrollView == self.tbv_List )
    {
        if( scrollView.contentOffset.y <= 0 && isLoding == NO && self.messages.count > 0 )
        {
            [self updateChatList:NO];
        }
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


- (NSString *)getDateNumber:(long long)lldate
{
    NSTimeInterval seconds = lldate / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  // here replace your format dd.MM.yyyy
    NSLog(@"result: %@", [dateFormatter stringFromDate:date]);
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    //        NSInteger nSecond = [components second];
    
    NSString *str_Date = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute];
    return str_Date;
}

- (NSString *)getDateNumberHour:(long long)lldate
{
    NSTimeInterval seconds = lldate / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  // here replace your format dd.MM.yyyy
    NSLog(@"result: %@", [dateFormatter stringFromDate:date]);
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
//    NSInteger nMinute = [components minute];
    //        NSInteger nSecond = [components second];
    
    NSString *str_Date = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour];
    return str_Date;
}


#pragma mark - setCell
- (void)myTextCell:(MyChatBasicCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBDBaseMessage *baseMessage = self.messages[indexPath.row];
    SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
    NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    SBDUser *user = userMessage.sender;
    NSLog(@"%@", user.userId);
    NSLog(@"%@", user.profileUrl);
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;

    long long llCreateAt = baseMessage.createdAt;
    NSString *str_Date = [self getDateNumber:llCreateAt];

    UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
    [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];

    cell.lc_Top.constant = 12.f;
    
    
    if( indexPath.row > 0 )
    {
        //이전 메세지
        id message = self.messages[indexPath.row - 1];
        if( [message isKindOfClass:[SBDAdminMessage class]] == NO && [message isKindOfClass:[NSString class]] == NO )
        {
            SBDBaseMessage *prev_baseMessage = self.messages[indexPath.row - 1];
            SBDUserMessage *prev_userMessage = (SBDUserMessage *)prev_baseMessage;
            //        SBDUser *prev_user = prev_userMessage.sender;
            
            //        NSData *data = [prev_userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            //        NSDictionary *dic_Prev = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSInteger nTime = 0;
            NSInteger nPrevTime = 0;
            
            NSInteger nUserId = [userMessage.sender.userId integerValue];
            NSInteger nNextUserId = [prev_userMessage.sender.userId integerValue];
            
            long long llprevCreateAt = prev_baseMessage.createdAt;
            
            NSString *str_PrevDate = [self getDateNumber:llprevCreateAt];
            
            if( str_Date.length >= 12 && str_PrevDate.length >= 12 )
            {
                nTime = [[str_Date substringWithRange:NSMakeRange(0, 12)] integerValue];
                nPrevTime = [[str_PrevDate substringWithRange:NSMakeRange(0, 12)] integerValue];
            }
            
            if( nUserId == nNextUserId )
            {
                //이전 메세지가 내 메세지면
                if( nTime == nPrevTime )
                {
                    //1분 이내의 메세지
                    cell.lc_Top.constant = 0.f;
                }
                else
                {
                    //1분이 지난 메세지
                    //                cell.lc_Top.constant = 15.f;
                }
            }
            else
            {
                //이전 메세지가 내 메세지가 아니면
                cell.lc_Top.constant = 15.f;
            }
        }
    }

    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    [self addContent:cell withString:userMessage.message];
    
    cell.tag = indexPath.row;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.delegate = self;
    longPress.cancelsTouchesInView = NO;
    [cell addGestureRecognizer:longPress];
    
    [self addTapGesture:cell];
}

- (void)otherTextCell:(OtherChatBasicCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if( self.channel.memberCount == 2 )
//    {
//        //1:1챗이면
//        cell.lc_NameHeight.constant = 0.f;
//    }

    cell.lc_NameHeight.constant = 0.f;
    
    SBDBaseMessage *baseMessage = self.messages[indexPath.row];
    SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
    NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    SBDUser *user = userMessage.sender;
    NSLog(@"%@", user.userId);
    NSLog(@"%@", user.profileUrl);
    
    cell.lc_Top.constant = 8.f;
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    
    long long llCreateAt = baseMessage.createdAt;
    NSString *str_Date = [self getDateNumber:llCreateAt];
    
    UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
    [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];

    if( indexPath.row > 0 )
    {
        //이전 메세지
        id message = self.messages[indexPath.row - 1];
        if( [message isKindOfClass:[SBDAdminMessage class]] == NO && [message isKindOfClass:[NSString class]] == NO )
        {
            SBDBaseMessage *prev_baseMessage = self.messages[indexPath.row - 1];
            SBDUserMessage *prev_userMessage = (SBDUserMessage *)prev_baseMessage;
            //        SBDUser *prev_user = prev_userMessage.sender;
            
            //        NSData *data = [prev_userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            //        NSDictionary *dic_Prev = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSInteger nTime = 0;
            NSInteger nPrevTime = 0;
            
            NSInteger nUserId = [userMessage.sender.userId integerValue];
            NSInteger nNextUserId = [prev_userMessage.sender.userId integerValue];
            
            long long llprevCreateAt = prev_baseMessage.createdAt;
            
            NSString *str_PrevDate = [self getDateNumber:llprevCreateAt];
            
            if( str_Date.length >= 12 && str_PrevDate.length >= 12 )
            {
                nTime = [[str_Date substringWithRange:NSMakeRange(0, 12)] integerValue];
                nPrevTime = [[str_PrevDate substringWithRange:NSMakeRange(0, 12)] integerValue];
            }
            
            if( nUserId == nNextUserId )
            {
                //이전 메세지가 내 메세지면
                if( nTime == nPrevTime )
                {
                    //1분 이내의 메세지
                    cell.iv_User.hidden = YES;
                    cell.lc_Top.constant = 0.f;
                }
                else
                {
                    //1분이 지난 메세지
                    cell.lc_NameHeight.constant = 15.f;
                    cell.iv_User.hidden = NO;
                    cell.lc_Top.constant = 15.f;
                }
            }
            else
            {
                //이전 메세지가 내 메세지가 아니면
                cell.lc_NameHeight.constant = 15.f;
                cell.iv_User.hidden = NO;
                cell.lc_Top.constant = 15.f;
            }
        }
    }
//    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    cell.lb_Contents.textColor = [UIColor blackColor];
    cell.v_ContentsBg.backgroundColor = [UIColor whiteColor];
    cell.v_ContentsBg.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    cell.v_ContentsBg.layer.borderWidth = 1.f;

    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    [self addContent:cell withString:userMessage.message];
    
    cell.lb_Name.text = user.nickname;
    
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"no_image.png")];
    cell.iv_User.tag = indexPath.row;
    cell.iv_User.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];

    if( cell.lb_Name.text.length <= 0 )
    {
        cell.lc_NameHeight.constant = 0.f;
    }
    
    [self addTapGesture:cell];
    
    cell.tag = indexPath.row;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.delegate = self;
    longPress.cancelsTouchesInView = NO;
    [cell addGestureRecognizer:longPress];
    
    [self addTapGesture:cell];
}

- (void)twoOtherTextCell:(TwoOtherChatCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if( self.channel.memberCount == 2 )
    //    {
    //        //1:1챗이면
    //        cell.lc_NameHeight.constant = 0.f;
    //    }
    
    cell.lc_NameHeight.constant = 0.f;
    
    SBDBaseMessage *baseMessage = self.messages[indexPath.row];
    SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
    NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    SBDUser *user = userMessage.sender;
    NSLog(@"%@", user.userId);
    NSLog(@"%@", user.profileUrl);
    
    cell.lc_Top.constant = 8.f;
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    
    long long llCreateAt = baseMessage.createdAt;
    NSString *str_Date = [self getDateNumber:llCreateAt];
    
    UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
    [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];
    
    if( indexPath.row > 0 )
    {
        //이전 메세지
        id message = self.messages[indexPath.row - 1];
        if( [message isKindOfClass:[SBDAdminMessage class]] == NO && [message isKindOfClass:[NSString class]] == NO )
        {
            SBDBaseMessage *prev_baseMessage = self.messages[indexPath.row - 1];
            SBDUserMessage *prev_userMessage = (SBDUserMessage *)prev_baseMessage;
            //        SBDUser *prev_user = prev_userMessage.sender;
            
            //        NSData *data = [prev_userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            //        NSDictionary *dic_Prev = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSInteger nTime = 0;
            NSInteger nPrevTime = 0;
            
            NSInteger nUserId = [userMessage.sender.userId integerValue];
            NSInteger nNextUserId = [prev_userMessage.sender.userId integerValue];
            
            long long llprevCreateAt = prev_baseMessage.createdAt;
            
            NSString *str_PrevDate = [self getDateNumber:llprevCreateAt];
            
            if( str_Date.length >= 12 && str_PrevDate.length >= 12 )
            {
                nTime = [[str_Date substringWithRange:NSMakeRange(0, 12)] integerValue];
                nPrevTime = [[str_PrevDate substringWithRange:NSMakeRange(0, 12)] integerValue];
            }
            
            if( nUserId == nNextUserId )
            {
                //이전 메세지가 내 메세지면
                if( nTime == nPrevTime )
                {
                    //1분 이내의 메세지
                    cell.iv_User.hidden = YES;
                    cell.lc_Top.constant = 0.f;
                }
                else
                {
                    //1분이 지난 메세지
                    cell.lc_NameHeight.constant = 15.f;
                    cell.iv_User.hidden = NO;
                    cell.lc_Top.constant = 15.f;
                }
            }
            else
            {
                //이전 메세지가 내 메세지가 아니면
                cell.lc_NameHeight.constant = 15.f;
                cell.iv_User.hidden = NO;
                cell.lc_Top.constant = 15.f;
            }
        }
    }
    //    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    cell.lb_Contents.textColor = [UIColor blackColor];
    cell.v_ContentsBg.backgroundColor = [UIColor whiteColor];
    cell.v_ContentsBg.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    cell.v_ContentsBg.layer.borderWidth = 1.f;
    
    cell.lb_Contents2.textColor = kMainColor;
    cell.v_ContentsBg2.backgroundColor = [UIColor whiteColor];
    cell.v_ContentsBg2.layer.borderColor = kMainColor.CGColor;
    cell.v_ContentsBg2.layer.borderWidth = 1.f;

    NSDictionary *dic_BtnInfo = [dic objectForKey:@"btnInfo"];
    cell.lb_Contents2.text = [NSString stringWithFormat:@"@%@", [dic_BtnInfo objectForKey:@"btnLabel"]];
    cell.btn_BotName.tag = indexPath.row;
    [cell.btn_BotName addTarget:self action:@selector(onAddInputBotName:) forControlEvents:UIControlEventTouchUpInside];

    
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    [self addContent:cell withString:userMessage.message];
    
    
    cell.lb_Name.text = user.nickname;
    
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"no_image.png")];
    cell.iv_User.tag = indexPath.row;
    cell.iv_User.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];
    
    if( cell.lb_Name.text.length <= 0 )
    {
        cell.lc_NameHeight.constant = 0.f;
    }
    
//    [self addTapGesture:cell];
    
    cell.tag = indexPath.row;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.delegate = self;
    longPress.cancelsTouchesInView = NO;
    [cell addGestureRecognizer:longPress];
    
    [self addTapGesture:cell];
}

- (CGFloat)setMyImageCell:(id)message withCell:(MyImageCell *)cell withIndexPath:(NSIndexPath *)indexPath withVideo:(BOOL)isVideo
{
    SBDBaseMessage *baseMessage = nil;
    SBDUserMessage *userMessage = nil;
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        baseMessage = (SBDBaseMessage *)message;
        userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    if( isVideo )
    {
        cell.v_Video.hidden = NO;
    }
    else
    {
        cell.v_Video.hidden = YES;
    }
    
    [cell.btn_Origin removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];


    BOOL isPrevMy = NO;
    long long llCreateAt = baseMessage.createdAt;
    NSString *str_Date = [self getDateNumber:llCreateAt];
    
//    if( indexPath.row > 0 )
//    {
//        //이전 메세지
//        id message = self.messages[indexPath.row - 1];
//        if( [message isKindOfClass:[SBDAdminMessage class]] == NO )
//        {
//            SBDBaseMessage *prev_baseMessage = self.messages[indexPath.row - 1];
//            SBDUserMessage *prev_userMessage = (SBDUserMessage *)prev_baseMessage;
//
//            NSInteger nTime = 0;
//            NSInteger nPrevTime = 0;
//
//            NSInteger nUserId = [userMessage.sender.userId integerValue];
//            NSInteger nNextUserId = [prev_userMessage.sender.userId integerValue];
//
//            long long llprevCreateAt = prev_baseMessage.createdAt;
//
//            NSString *str_PrevDate = [self getDateNumber:llprevCreateAt];
//
//            if( str_Date.length >= 12 && str_PrevDate.length >= 12 )
//            {
//                nTime = [[str_Date substringWithRange:NSMakeRange(0, 12)] integerValue];
//                nPrevTime = [[str_PrevDate substringWithRange:NSMakeRange(0, 12)] integerValue];
//            }
//
//            if( nUserId == nNextUserId )
//            {
//                isPrevMy = YES;
//                //이전 메세지가 내 메세지면
//                if( nTime == nPrevTime )
//                {
//                    //1분 이내의 메세지
//                    cell.lc_NameHeight.constant = 0.f;
//                    cell.iv_User.hidden = YES;
//                    cell.lc_Top.constant = 0.f;
//                }
//                else
//                {
//                    //1분이 지난 메세지
//                    cell.lc_NameHeight.constant = 15.f;
//                    cell.iv_User.hidden = NO;
//                    //                    cell.lc_Top.constant = 15.f;
//                    isPrevMy = NO;
//                }
//            }
//            else
//            {
//                //이전 메세지가 내 메세지가 아니면
//                cell.lc_NameHeight.constant = 15.f;
//                cell.iv_User.hidden = NO;
//                //                cell.lc_Top.constant = 15.f;
//            }
//        }
//    }

    
    NSDictionary *dic_ImageSize = [dic objectForKey:@"file_data"];
    
    CGFloat fHeight = (self.view.bounds.size.width - kImageMargin);
    CGFloat fImageWidth = self.view.frame.size.width;
    CGFloat fImageHeight = self.view.frame.size.height;
    
    if( [userMessage.customType isEqualToString:@"video"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"video"] )
    {
        fImageWidth = [[dic_ImageSize objectForKey_YM:@"coverImgWidth"] floatValue];
        fImageHeight = [[dic_ImageSize objectForKey_YM:@"coverImgHeight"] floatValue];
    }
    else if( [userMessage.customType isEqualToString:@"image"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"image"] )
    {
        fImageWidth = [[dic_ImageSize objectForKey_YM:@"width"] floatValue];
        fImageHeight = [[dic_ImageSize objectForKey_YM:@"height"] floatValue];
    }
    
    if( isnan(fImageHeight) || fImageHeight <= 0 )
    {
        fImageHeight = self.view.frame.size.height - kImageMargin;
    }
    
    if( isnan(fImageWidth) || fImageWidth <= 0 )
    {
        fImageWidth = self.view.frame.size.width - kImageMargin;
    }
    
    if( fImageWidth > fImageHeight )
    {
        //가로형
        //가로형이면 가로 기준에 맞춰서 세로 길이 늘리기
        CGFloat fScale = (self.view.bounds.size.width - kImageMargin)/fImageWidth;
        //            fImageHeight = fScale * fImageHeight;
        
        cell.lc_ImageWidth.constant = self.view.bounds.size.width - kImageMargin;
        cell.lc_ImageHeight.constant = fScale * fImageHeight;
    }
    else
    {
        CGFloat fScale = (self.view.bounds.size.width - kImageMargin)/fImageHeight;//0.57
        fImageWidth = fScale * fImageWidth;//196.6f
        
        cell.lc_ImageWidth.constant = fImageWidth;
        cell.lc_ImageHeight.constant = self.view.bounds.size.width - kImageMargin;
    }

    if( [[dic objectForKey:@"temp"] isEqualToString:@"YES"] )
    {
        //템프면
        NSData *data = [dic objectForKey:@"obj"];
        UIImage *image = [UIImage imageWithData:data];
        cell.iv_Contents.image = image;

        //        NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        //        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        //        [btn_Date setTitle:str_Date forState:0];
    }
    else
    {
        NSURL *url = nil;
        if( isVideo )
        {
            NSString *str_CoverImageUrl = [NSString stringWithFormat:@"%@", [dic_ImageSize objectForKey_YM:@"coverImgUrl"]];
            if( [str_CoverImageUrl hasPrefix:@"/"] )
            {
                NSMutableString *strM = [NSMutableString stringWithString:str_CoverImageUrl];
                [strM deleteCharactersInRange:NSMakeRange(0, 1)];
                str_CoverImageUrl = [NSString stringWithFormat:@"%@", strM];
            }

            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [dic objectForKey_YM:@"userImg_prefix"], str_CoverImageUrl]];
            //http://data.thoting.com:8282/c_edujm/exam/c_edujm/temp/138/7617284d1c073c04941d4a83b503559e.jpg
            
        }
        else
        {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", userMessage.message]];
            //http://data.thoting.com:8282/c_edujm/exam/000/000/515287db824f3f9daaa35ef9fdcfd53c.jpg
        }

        [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
        
        cell.iv_Contents.userInteractionEnabled = YES;
        cell.iv_Contents.tag = indexPath.row;
        UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        pinchZoom.delegate = self;
        [cell.iv_Contents addGestureRecognizer:pinchZoom];
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        [cell.iv_Contents addGestureRecognizer:imageTap];

        
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;

        long long llCreateAt = baseMessage.createdAt;
        NSString *str_Date = [self getDateNumber:llCreateAt];
        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];
    }

//    if( isPrevMy )
//    {
//        return cell.lc_ImageHeight.constant - 15.f;
//    }
 
    cell.tag = indexPath.row;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.delegate = self;
    longPress.cancelsTouchesInView = NO;
    [cell addGestureRecognizer:longPress];
    
    [self addTapGesture:cell];

    [cell.iv_Contents setNeedsLayout];
    [cell.iv_Contents layoutIfNeeded];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    return cell.lc_ImageHeight.constant;//295
}

- (CGFloat)setOtherImageCell:(id)message withCell:(OtherImageCell *)cell withIndexPath:(NSIndexPath *)indexPath withVideo:(BOOL)isVideo
{
    SBDBaseMessage *baseMessage = nil;
    SBDUserMessage *userMessage = nil;
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        baseMessage = (SBDBaseMessage *)message;
        userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    if( isVideo )
    {
        cell.v_Video.hidden = NO;
    }
    else
    {
        cell.v_Video.hidden = YES;
    }

    cell.btn_Origin.hidden = YES;
    [cell.btn_Origin removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    BOOL isPrevMy = NO;
    long long llCreateAt = baseMessage.createdAt;
    NSString *str_Date = [self getDateNumber:llCreateAt];

    if( indexPath.row > 0 )
    {
        //이전 메세지
        id message = self.messages[indexPath.row - 1];
        if( [message isKindOfClass:[SBDAdminMessage class]] == NO && [message isKindOfClass:[NSString class]] == NO )
        {
            SBDBaseMessage *prev_baseMessage = self.messages[indexPath.row - 1];
            SBDUserMessage *prev_userMessage = (SBDUserMessage *)prev_baseMessage;

            NSInteger nTime = 0;
            NSInteger nPrevTime = 0;
            
            NSInteger nUserId = [userMessage.sender.userId integerValue];
            NSInteger nNextUserId = [prev_userMessage.sender.userId integerValue];
            
            long long llprevCreateAt = prev_baseMessage.createdAt;
            
            NSString *str_PrevDate = [self getDateNumber:llprevCreateAt];
            
            if( str_Date.length >= 12 && str_PrevDate.length >= 12 )
            {
                nTime = [[str_Date substringWithRange:NSMakeRange(0, 12)] integerValue];
                nPrevTime = [[str_PrevDate substringWithRange:NSMakeRange(0, 12)] integerValue];
            }
            
            if( nUserId == nNextUserId )
            {
                isPrevMy = YES;
                //이전 메세지가 내 메세지면
                if( nTime == nPrevTime )
                {
                    //1분 이내의 메세지
                    cell.lc_NameHeight.constant = 0.f;
                    cell.iv_User.hidden = YES;
                    cell.lc_Top.constant = 0.f;
                }
                else
                {
                    //1분이 지난 메세지
                    cell.lc_NameHeight.constant = 15.f;
                    cell.iv_User.hidden = NO;
//                    cell.lc_Top.constant = 15.f;
                }
            }
            else
            {
                //이전 메세지가 내 메세지가 아니면
                cell.lc_NameHeight.constant = 15.f;
                cell.iv_User.hidden = NO;
//                cell.lc_Top.constant = 15.f;
            }
        }
    }

    BOOL isOrigin = NO;
    NSDictionary *dic_ImageSize = [dic objectForKey:@"file_data"];
    
    CGFloat fHeight = (self.view.bounds.size.width - kImageMargin);
    CGFloat fImageWidth = self.view.frame.size.width;
    CGFloat fImageHeight = self.view.frame.size.height;
    
    if( [userMessage.customType isEqualToString:@"video"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"video"] )
    {
        fImageWidth = [[dic_ImageSize objectForKey_YM:@"coverImgWidth"] floatValue];
        fImageHeight = [[dic_ImageSize objectForKey_YM:@"coverImgHeight"] floatValue];
    }
    else if( [userMessage.customType isEqualToString:@"image"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"image"] )
    {
        fImageWidth = [[dic_ImageSize objectForKey_YM:@"width"] floatValue];
        fImageHeight = [[dic_ImageSize objectForKey_YM:@"height"] floatValue];
    }
    else if( [userMessage.customType isEqualToString:@"pdfImage"] || [[dic objectForKey_YM:@"type"] isEqualToString:@"pdfImage"] )
    {
        isOrigin = YES;
        
        fImageWidth = [[dic_ImageSize objectForKey_YM:@"width"] floatValue];
        fImageHeight = [[dic_ImageSize objectForKey_YM:@"height"] floatValue];

//        cell.btn_Origin.tag = indexPath.row;
////        cell.btn_Read.hidden = YES;
////        cell.lb_Date.hidden = YES;
//
//        cell.btn_Origin.hidden = NO;
//        [cell.btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic objectForKey_YM:@"examTitle"]] forState:UIControlStateNormal];
//        [cell.btn_Origin addTarget:self action:@selector(onMoveToPdf:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if( isnan(fImageHeight) || fImageHeight <= 0 )
    {
        fImageHeight = self.view.frame.size.height - kImageMargin;
    }
    
    if( isnan(fImageWidth) || fImageWidth <= 0 )
    {
        fImageWidth = self.view.frame.size.width - kImageMargin;
    }
    
    if( fImageWidth > fImageHeight )
    {
        //가로형
        //가로형이면 가로 기준에 맞춰서 세로 길이 늘리기
        CGFloat fScale = (self.view.bounds.size.width - kImageMargin)/fImageWidth;
        //            fImageHeight = fScale * fImageHeight;
        
        cell.lc_ImageWidth.constant = self.view.bounds.size.width - kImageMargin;
        cell.lc_ImageHeight.constant = fScale * fImageHeight;
    }
    else
    {
        CGFloat fScale = (self.view.bounds.size.width - kImageMargin)/fImageHeight;//0.57
        fImageWidth = fScale * fImageWidth;//196.6f
        
        cell.lc_ImageWidth.constant = fImageWidth;
        cell.lc_ImageHeight.constant = self.view.bounds.size.width - kImageMargin;
    }
    
    if( [[dic objectForKey:@"temp"] isEqualToString:@"YES"] )
    {
        //템프면
        NSData *data = [dic objectForKey:@"obj"];
        UIImage *image = [UIImage imageWithData:data];
        cell.iv_Contents.image = image;
        
        //        NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        //        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        //        [btn_Date setTitle:str_Date forState:0];
    }
    else
    {
        SBDUser *user = userMessage.sender;

        cell.lb_Name.text = user.nickname;
        
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"no_image.png")];
        cell.iv_User.tag = indexPath.row;
        cell.iv_User.userInteractionEnabled = YES;
        UITapGestureRecognizer *userImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
        [userImageTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:userImageTap];

        
        NSURL *url = nil;
        if( isVideo )
        {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [dic objectForKey_YM:@"userImg_prefix"], [dic_ImageSize objectForKey_YM:@"coverImgUrl"]]];
        }
        else
        {
//            url = [Util createImageUrl:str_ImagePreFix withFooter:[dic objectForKey_YM:@"data_prefix"]];
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", userMessage.message]];
        }
        
        [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
        
        cell.iv_Contents.userInteractionEnabled = YES;
        cell.iv_Contents.tag = indexPath.row;
        UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        pinchZoom.delegate = self;
        [cell.iv_Contents addGestureRecognizer:pinchZoom];
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        [cell.iv_Contents addGestureRecognizer:imageTap];

        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;

        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];
    }
    
//    if( isPrevMy )
//    {
//        return cell.lc_ImageHeight.constant;
//    }
    
    
    cell.tag = indexPath.row;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.delegate = self;
    longPress.cancelsTouchesInView = NO;
    [cell addGestureRecognizer:longPress];
    
    [self addTapGesture:cell];

    return cell.lc_ImageHeight.constant;//295
}

- (CGFloat)setPdfImageCell:(id)message withCell:(NormalQuestionCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    SBDBaseMessage *baseMessage = nil;
    SBDUserMessage *userMessage = nil;
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        baseMessage = (SBDBaseMessage *)message;
        userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    for( id subView in cell.sv_Contents.subviews )
    {
        [subView removeFromSuperview];
    }
    
    [cell.btn_Origin removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    cell.btn_Origin.tag = indexPath.row;
 
    cell.btn_Origin.hidden = NO;
    NSDictionary *dic_BotData = [dic objectForKey:@"bot_data"];
    [cell.btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic_BotData objectForKey_YM:@"examTitle"]] forState:UIControlStateNormal];
    [cell.btn_Origin addTarget:self action:@selector(onMoveToPdf:) forControlEvents:UIControlEventTouchUpInside];
    
    
    SBDUser *user = userMessage.sender;
    
    cell.lb_Name.text = user.nickname;
    
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"no_image.png")];
    cell.iv_User.tag = indexPath.row;
    cell.iv_User.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];

    
    __block CGFloat fSampleViewTotalHeight = 20.f;

    NSDictionary *dic_ImageSize = [dic objectForKey:@"file_data"];
    
    NSString *str_ImageUrl = userMessage.message;
    
    CGFloat fWidth = [[dic_ImageSize objectForKey:@"width"] floatValue];
    CGFloat fHeight = [[dic_ImageSize objectForKey:@"height"] floatValue];
    
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
    
    fSampleViewTotalHeight += iv.frame.size.height;
    
    [cell.sv_Contents addSubview:iv];
    cell.sv_Contents.userInteractionEnabled = YES;

    long long llCreateAt = baseMessage.createdAt;
    NSString *str_Date = [self getDateNumber:llCreateAt];
    UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
    [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];
    
    return iv.frame.size.height + 30.f;//295
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"reloadreloadreloadreloadreloadreloadreloadreloadreloadreloadreloadreload");
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_List )
    {
        if( self.messages.count > 1 )
        {
            //이전 메세지 검사해서 날짜 넣어주기
            NSMutableArray *arM_Tmp = [NSMutableArray array];
            for( NSInteger i = 0; i < self.messages.count; i++ )
            {
                id obj = self.messages[i];
                if( [obj isKindOfClass:[NSString class]] == NO )
                {
                    [arM_Tmp addObject:obj];
                }
            }
            
            self.messages = [NSMutableArray arrayWithArray:arM_Tmp];
            [arM_Tmp removeAllObjects];
            
            for( NSInteger i = 0; i < self.messages.count - 1; i++ )
            {
//                id obj1 = self.messages[i];
//                id obj2 = self.messages[i + 1];
//                if( [obj1 isKindOfClass:[SBDBaseMessage class]] == NO )  continue;
//                if( [obj2 isKindOfClass:[SBDBaseMessage class]] == NO )  continue;
                
                SBDBaseMessage *baseMessage = self.messages[i];
                [arM_Tmp addObject:baseMessage];
                
                long long llCreateAt = baseMessage.createdAt;
                long long llOldCreateAt = [[self getDateNumberHour:llCreateAt] longLongValue] ;
                
                id nextBaseMessage = self.messages[i + 1];
                if( [nextBaseMessage isKindOfClass:[NSDictionary class]] )
                {
                    NSDictionary *nextBaseMessage = self.messages[i + 1];
                    llCreateAt = [[nextBaseMessage objectForKey:@"createDate"] longLongValue] / 10000;
                }
                else
                {
                    SBDBaseMessage *nextBaseMessage = (SBDBaseMessage *)self.messages[i + 1];
                    llCreateAt = nextBaseMessage.createdAt;
                }
                
                long long llAfterCreateAt = [[self getDateNumberHour:llCreateAt] longLongValue] ;
                
                if( llOldCreateAt < llAfterCreateAt )
                {
                    [arM_Tmp addObject:[self getDateNumber:llCreateAt]];
                }
            }
            
            SBDBaseMessage *baseMessage = [self.messages lastObject];
            [arM_Tmp addObject:baseMessage];
            
            id lastObj = [arM_Tmp lastObject];
            if( [lastObj isKindOfClass:[NSString class]] )
            {
                [arM_Tmp removeLastObject];
            }
            
            self.messages = [NSMutableArray arrayWithArray:arM_Tmp];
        }

        
//        NSMutableArray *arM = [NSMutableArray array];
//        for( NSInteger i = 0; i < self.messages.count; i++ )
//        {
//            id obj = self.messages[i];
//            if( [obj isKindOfClass:[NSString class]] == NO )
//            {
//                [arM addObject:obj];
//            }
//        }
//
//        self.messages = arM;
        

//        NSMutableArray *arM_Tmp = [NSMutableArray arrayWithArray:self.messages];
//        for( id message in arM_Tmp )
//        {
//            if( [message isKindOfClass:[NSDictionary class]] )
//            {
//                if( [[message objectForKey_YM:@"type"] isEqualToString:@"USER_ENTER"] ||
//                   [[message objectForKey_YM:@"type"] isEqualToString:@"enterBotRoom"] )
//                {
//                    [self.messages removeObject:message];
//                }
//            }
//            else if( [message isKindOfClass:[SBDBaseMessage class]] )
//            {
//                SBDBaseMessage *baseMessage = message;
//                SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//
//                if( [userMessage.customType isEqualToString:@"USER_ENTER"] ||
//                   [userMessage.customType isEqualToString:@"enterBotRoom"] ||
//                   [userMessage.customType isEqualToString:@"cmd"] )
//                {
//                    [self.messages removeObject:message];
//                }
//            }
//        }
//
//        arM_Tmp = [NSMutableArray arrayWithArray:self.messages];
//        for( NSInteger i = 1; i < arM_Tmp.count; i++ )
//        {
//            id message = [arM_Tmp objectAtIndex:i];
//            if( [message isKindOfClass:[NSDictionary class]] )
//            {
//                if( [[message objectForKey_YM:@"type"] isEqualToString:@"createDate"] )
//                {
//                    [arM_Tmp removeObject:message];
//                }
//            }
//            else if( [message isKindOfClass:[SBDBaseMessage class]] )
//            {
//                SBDBaseMessage *baseMessage = message;
//                SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//
//                if( [[dic objectForKey_YM:@"type"] isEqualToString:@"createDate"] )
//                {
//                    [arM_Tmp removeObject:dic];
//                }
//            }
//        }
//
//        self.messages = arM_Tmp;
//
//
//        NSInteger nCnt = 0;
//        arM_Tmp = [NSMutableArray arrayWithArray:self.messages];
//        for( NSInteger i = 1; i < arM_Tmp.count; i++ )
//        {
//            NSString *str_TimeTmp = @"";
//            NSString *str_PrevTimeTmp = @"";
//
//            id message = [arM_Tmp objectAtIndex:i];
//            if( [message isKindOfClass:[NSDictionary class]] )
//            {
//                str_TimeTmp = [message objectForKey_YM:@"createDate"];
//                if( [[message objectForKey_YM:@"type"] isEqualToString:@"createDate"] )
//                {
//                    [arM_Tmp removeObject:message];
//                }
//            }
//            else if( [message isKindOfClass:[SBDBaseMessage class]] )
//            {
//                SBDBaseMessage *baseMessage = message;
//                SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//
//                str_TimeTmp = [dic objectForKey_YM:@"createDate"];
//                if( [[dic objectForKey_YM:@"type"] isEqualToString:@"createDate"] )
//                {
//                    [arM_Tmp removeObject:dic];
//                }
//            }
//
//            message = [arM_Tmp objectAtIndex:i - 1];
//            if( [message isKindOfClass:[NSDictionary class]] )
//            {
//                str_PrevTimeTmp = [message objectForKey_YM:@"createDate"];
//                if( [[message objectForKey_YM:@"type"] isEqualToString:@"createDate"] )
//                {
//                    [arM_Tmp removeObject:message];
//                }
//            }
//            else if( [message isKindOfClass:[SBDBaseMessage class]] )
//            {
//                SBDBaseMessage *baseMessage = message;
//                SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//
//                str_PrevTimeTmp = [dic objectForKey_YM:@"createDate"];
//                if( [[dic objectForKey_YM:@"type"] isEqualToString:@"createDate"] )
//                {
//                    [arM_Tmp removeObject:dic];
//                }
//            }
//
//            if( str_TimeTmp.length >= 10 && str_PrevTimeTmp.length >= 10 )
//            {
//                NSInteger nTime = [[str_TimeTmp substringWithRange:NSMakeRange(0, 10)] integerValue];
//                NSInteger nPrevTime = [[str_PrevTimeTmp substringWithRange:NSMakeRange(0, 10)] integerValue];
//
//                if( nTime > nPrevTime )
//                {
//                    NSLog(@"nTime: %ld", nTime);
//                    NSLog(@"nPrevTime: %ld", nPrevTime);
//
//                    //1시간 이상이면
//                    [self.messages insertObject:@{@"type":@"createDate", @"createDate":str_TimeTmp} atIndex:i + nCnt];
//                    nCnt++;
//                }
//            }
//
//        }
        
        return self.messages.count;
    }
    else if( tableView == self.tbv_AtList )
    {
        NSArray *ar_Tmp = [NSArray arrayWithArray:self.arM_AtList];
        for( NSInteger i = 0; i < ar_Tmp.count; i++ )
        {
            NSDictionary *dic = ar_Tmp[i];
            NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]];
            for( NSInteger j = 0; j < self.arM_User.count; j++ )
            {
                NSString *str_SubUserId = [NSString stringWithFormat:@"%@", [self.arM_User objectAtIndex:j]];
                if( [str_UserId isEqualToString:str_SubUserId] )
                {
                    [self.arM_AtList removeObject:dic];
                    break;
                }
            }
        }
        
        return self.arM_AtList.count;
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
        long long llMessageId = 0;
        
        NSDictionary *dic = nil;
        if( [message isKindOfClass:[SBDAdminMessage class]] )
        {
            SBDUserMessage *userMessage = (SBDUserMessage *)message;
            if( [userMessage.customType isEqualToString:@"USER_JOIN"] || [userMessage.customType isEqualToString:@"USER_LEFT"] )
            {
                CmdChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CmdChatCell"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self cmdCell:cell forRowAtIndexPath:indexPath];
                [self addTapGesture:cell];
                return cell;
            }

            MyChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
            return cell;
        }

        if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDBaseMessage *baseMessage = self.messages[indexPath.row];
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            llMessageId = baseMessage.messageId;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
//            NSDictionary *dic_BotDataTmp = [dic objectForKey:@"bot_data"];
//            if( dic_BotDataTmp == nil || [dic_BotDataTmp isKindOfClass:[NSNull class]] || [dic_BotDataTmp isKindOfClass:[NSDictionary class]] == NO )
//            {
//                MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyImageCell"];
//                return cell;
//            }

            SBDUser *user = userMessage.sender;
            NSLog(@"%@", user.userId);
            NSLog(@"%@", user.profileUrl);
            
            NSString *str_MyUserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            NSString *str_SenderId = [NSString stringWithFormat:@"%@", user.userId];
            if( [str_MyUserId isEqualToString:str_SenderId] )
            {
                //나의 글
                if( [userMessage.customType isEqualToString:@"image"] )
                {
                    MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyImageCell"];
                    [self setMyImageCell:message withCell:cell withIndexPath:indexPath withVideo:NO];
                    return cell;
                }
                else if( [userMessage.customType isEqualToString:@"video"] )
                {
                    MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyImageCell"];
                    [self setMyImageCell:message withCell:cell withIndexPath:indexPath withVideo:YES];
                    return cell;
                }
                else if( [userMessage.customType isEqualToString:@"audio"] )
                {
                    MyAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyAudioCell"];

                    cell.tag = indexPath.row;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
                    longPress.numberOfTouchesRequired = 1;
                    longPress.delegate = self;
                    longPress.cancelsTouchesInView = NO;
                    [cell addGestureRecognizer:longPress];
                    
                    [self myAudioCell:cell indexPath:indexPath withData:dic withMessageId:llMessageId];
                    
                    return cell;
                }
                else
                {
                    MyChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
                    [self myTextCell:cell forRowAtIndexPath:indexPath];
                    
                    return cell;
                }
            }
            else
            {
                //남의 글
                NSDictionary *dic_BotData = [dic objectForKey:@"bot_data"];
                if( [dic_BotData isKindOfClass:[NSNull class]] == NO )
                {
                    if( [[dic objectForKey:@"userType"] isEqualToString:@"bot"] )
                    {
                        /*
                         botUserId = 709;
                         "bot_data" = "[{\"btnInfoCount\":2,\"btnInfoType\":\"menu\",\"btnInfo\":[{\"btnLabel\":\"\\uc804\\uccb4\",\"returnValue\":\"3731\",\"returnName\":\"examId\",\"chatScreen\":\"selectedExam\",\"mesgAction\":\"selectedExam\"},{\"btnLabel\":\"\\uad6d\\uc81c\\uc601\\uc5b4 \\ucd08\\uae09\",\"returnValue\":\"3361\",\"returnName\":\"examId\",\"chatScreen\":\"selectedExam\",\"mesgAction\":\"selectedExam\"}],\"examCount\":2,\"examList\":\"[{\\\"examTitle\\\":\\\"\\\\uc804\\\\uccb4\\\",\\\"examId\\\":\\\"3731\\\"},{\\\"examTitle\\\":\\\"\\\\uad6d\\\\uc81c\\\\uc601\\\\uc5b4 \\\\ucd08\\\\uae09\\\",\\\"examId\\\":\\\"3361\\\"}]\"}]";
                         chatScreen = selectExamlist;
                         dataCount = 1;
                         "data_prefix" = "http://data.thoting.com:8282/c_edujm/exam/";
                         examCount = 2;
                         "image_prefix" = "http://data.thoting.com:8282/c_edujm/exam/";
                         imgUrl = "http://data.thoting.com:8282/c_edujm/images/user/000/000/noImage11.png";
                         itemType = chat;
                         mesgAction = wellcomeMesg;
                         roomType = chatBot;
                         "userImg_prefix" = "http://data.thoting.com:8282/c_edujm/images/user/";
                         userThumbnail = "000/000/noImage11.png";
                         userType = bot;
                         */
                        //챗봇 메세지
                        OtherChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherChatBasicCell"];
                        [self otherTextCell:cell forRowAtIndexPath:indexPath];
                        
                        return cell;
                    }
                    else if( [[dic_BotData objectForKey:@"mesgAction"] isEqualToString:@"toMessage"] )
                    {
                        NSString *str_FileType = [NSString stringWithFormat:@"%@", [dic_BotData objectForKey:@"type"]];
                        if( [str_FileType isEqualToString:@"audio"] )
                        {
                            TwoAutoChatAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoAutoChatAudioCell"];
                            
                            cell.rightUtilityButtons = [self rightButtons];
                            cell.delegate = self;
                            
                            long long llCreateAt = baseMessage.createdAt;
                            NSString *str_Date = [self getDateNumber:llCreateAt];
                            
                            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
                            [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];
                            
                            NSURL *url = [NSURL URLWithString:userMessage.message];
                            
                            NSDictionary *dic_FileData = [dic objectForKey:@"file_data"];
                            
                            cell.url = url;
                            cell.nEId = llMessageId;
                            cell.messageId = llMessageId;
                            cell.fPlayDuration = [[dic_FileData objectForKey:@"playtime"] floatValue];
                            
                            if( llCurrentMessageId == -1 || llCurrentMessageId != llMessageId )
                            {
                                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                                cell.player = [AVPlayer playerWithPlayerItem:playerItem];
                                cell.player = [AVPlayer playerWithURL:url];
                                cell.lb_Time.text = @"00:00";
                                cell.lb_Time.hidden = YES;
                                cell.lb_BgTime.hidden = NO;
                                cell.btn_PlayPause.selected = NO;
                                
                                CGFloat fCurrentTime = cell.fPlayDuration;
                                NSInteger nMinute = (NSInteger)fCurrentTime / 60;
                                NSInteger nSecond = (NSInteger)fCurrentTime % 60;
                                cell.lb_BgTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                
                                if( cell.player && self.timeObserver )
                                {
                                    @try{
                                        
                                        [cell.player removeTimeObserver:self.timeObserver];
                                        self.timeObserver = nil;
                                        
                                    }@catch(id anException){
                                        //                                                [currentPlayer pause];
                                        //                                                currentPlayer = nil;
                                    }@finally {
                                        
                                    }
                                }
                            }
                            else
                            {
                                NSLog(@"indexPath.row : %ld", indexPath.row);
                                cell.lb_Time.hidden = NO;
                                cell.lb_BgTime.hidden = YES;
                                cell.btn_PlayPause.selected = isPlay;
                                
                                CGFloat fCurrentTime = cell.fPlayDuration;
                                NSInteger nMinute = (NSInteger)fCurrentTime / 60;
                                NSInteger nSecond = (NSInteger)fCurrentTime % 60;
                                NSString *str_Time = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                if( [str_Time isEqualToString:@"00:00"] )
                                {
                                    cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                }
                            }
                            
                            SBDUser *user = userMessage.sender;
                            NSLog(@"%@", user.userId);
                            NSLog(@"%@", user.profileUrl);
                            cell.lb_Name.text = user.nickname;
                            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"no_image.png")];
                            
                            cell.tag = cell.btn_BotName.tag = cell.btn_PlayPause.tag = cell.btn_Replay.tag = indexPath.row;
                            [cell.btn_PlayPause removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                            [cell.btn_Replay removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                            [cell.btn_PlayPause addTarget:self action:@selector(onAutoAudioPlayAndPause:) forControlEvents:UIControlEventTouchUpInside];
                            [cell.btn_Replay addTarget:self action:@selector(onAutoAudioReplay:) forControlEvents:UIControlEventTouchUpInside];
                            
                            
                            cell.lb_Contents2.textColor = kMainColor;
                            cell.v_ContentsBg2.backgroundColor = [UIColor whiteColor];
                            cell.v_ContentsBg2.layer.borderColor = kMainColor.CGColor;
                            cell.v_ContentsBg2.layer.borderWidth = 1.f;
                            
                            NSDictionary *dic_BtnInfo = [dic objectForKey:@"btnInfo"];
                            cell.lb_Contents2.text = [NSString stringWithFormat:@"@%@", [dic_BtnInfo objectForKey:@"btnLabel"]];
                            [cell.btn_BotName addTarget:self action:@selector(onAddInputBotName:) forControlEvents:UIControlEventTouchUpInside];
                            
                            return cell;
                        }
                        else
                        {
                            TwoOtherChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoOtherChatCell"];
                            [self twoOtherTextCell:cell forRowAtIndexPath:indexPath];
                            
                            return cell;
                        }
                    }
                }
                
                if( [userMessage.customType isEqualToString:@"pdfImage"] )
                {
                    //pdf문제일 경우 이미지
                    NormalQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalQuestionCell"];
                    [self setPdfImageCell:message withCell:cell withIndexPath:indexPath];
                    return cell;

//                    OtherImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherImageCell"];
//                    [self setOtherImageCell:message withCell:cell withIndexPath:indexPath withVideo:NO];
//                    return cell;
                }
                else if( [userMessage.customType isEqualToString:@"image"] )
                {
                    OtherImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherImageCell"];
                    [self setOtherImageCell:message withCell:cell withIndexPath:indexPath withVideo:NO];
                    return cell;
                }
                else if( [userMessage.customType isEqualToString:@"video"] )
                {
                    OtherImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherImageCell"];
                    [self setOtherImageCell:message withCell:cell withIndexPath:indexPath withVideo:YES];
                    return cell;
                }
                else if( [userMessage.customType isEqualToString:@"audio"] )
                {
                    AutoChatAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutoChatAudioCell"];
                    
                    cell.rightUtilityButtons = [self rightButtons];
                    cell.delegate = self;
                    
                    long long llCreateAt = baseMessage.createdAt;
                    NSString *str_Date = [self getDateNumber:llCreateAt];
                    
                    UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
                    [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];


//                    SBDUser *user = userMessage.sender;
//                    cell.lb_Name.text = user.nickname;
//
//                    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"no_image.png")];
//                    cell.iv_User.tag = indexPath.row;
//                    cell.iv_User.userInteractionEnabled = YES;
//                    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
//                    [imageTap setNumberOfTapsRequired:1];
//                    [cell.iv_User addGestureRecognizer:imageTap];

                    
                    
                    NSURL *url = [NSURL URLWithString:userMessage.message];
                    
                    NSDictionary *dic_FileData = [dic objectForKey:@"file_data"];
                    
                    cell.url = url;
                    cell.nEId = llMessageId;
                    cell.messageId = llMessageId;
                    cell.fPlayDuration = [[dic_FileData objectForKey:@"playtime"] floatValue];

                    if( llCurrentMessageId == -1 || llCurrentMessageId != llMessageId )
                    {
                        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                        cell.player = [AVPlayer playerWithPlayerItem:playerItem];
                        cell.player = [AVPlayer playerWithURL:url];
                        cell.lb_Time.text = @"00:00";
                        cell.lb_Time.hidden = YES;
                        cell.lb_BgTime.hidden = NO;
                        cell.btn_PlayPause.selected = NO;
                        
                        CGFloat fCurrentTime = cell.fPlayDuration;
                        NSInteger nMinute = (NSInteger)fCurrentTime / 60;
                        NSInteger nSecond = (NSInteger)fCurrentTime % 60;
                        cell.lb_BgTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                        
                        if( cell.player && self.timeObserver )
                        {
                            @try{
                                
                                [cell.player removeTimeObserver:self.timeObserver];
                                self.timeObserver = nil;
                                
                            }@catch(id anException){
                                //                                                [currentPlayer pause];
                                //                                                currentPlayer = nil;
                            }@finally {
                                
                            }
                        }
                    }
                    else
                    {
                        NSLog(@"indexPath.row : %ld", indexPath.row);
                        cell.lb_Time.hidden = NO;
                        cell.lb_BgTime.hidden = YES;
                        cell.btn_PlayPause.selected = isPlay;
                        
                        CGFloat fCurrentTime = cell.fPlayDuration;
                        NSInteger nMinute = (NSInteger)fCurrentTime / 60;
                        NSInteger nSecond = (NSInteger)fCurrentTime % 60;
                        NSString *str_Time = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                        if( [str_Time isEqualToString:@"00:00"] )
                        {
                            cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                        }
                    }
                    
                    cell.tag = cell.btn_PlayPause.tag = cell.btn_Replay.tag = indexPath.row;
                    [cell.btn_PlayPause removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.btn_Replay removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.btn_PlayPause addTarget:self action:@selector(onAutoAudioPlayAndPause:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.btn_Replay addTarget:self action:@selector(onAutoAudioReplay:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return cell;
                }
                else
                {
                    OtherChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherChatBasicCell"];
                    [self otherTextCell:cell forRowAtIndexPath:indexPath];
                    
                    return cell;
                }
            }
        }
        else if( [message isKindOfClass:[NSDictionary class]] )
        {
            //템프면 (이미지, 비디오)
            NSDictionary *dic = (NSDictionary *)message;
            if( [[dic objectForKey:@"temp"] isEqualToString:@"YES"] )
            {
                if( [[dic objectForKey:@"type"] isEqualToString:@"audio"] )
                {
                    MyAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyAudioCell"];

                    cell.btn_Read.selected = NO;
                    
                    double duration = [[dic objectForKey:@"duration"] doubleValue];
                    duration = ceil(duration);
                    
                    NSLog(@"duration: %f", duration);
                    NSInteger nMinute = (NSInteger)duration / 60;
                    NSInteger nSecond = (NSInteger)duration % 60;
                    cell.lb_Time.hidden = YES;
                    cell.lb_BgTime.hidden = NO;
                    cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                    cell.lb_BgTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                    
                    [cell.btn_PlayPause removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.btn_Replay removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];

                    return cell;
                }

                MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyImageCell"];
                [self myImageCell:cell forRowAtIndexPath:indexPath withVideo:NO];
                return cell;
            }
            
            MyChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
            return cell;

        }
        else if( [message isKindOfClass:[NSString class]] )
        {
            //여기
            ChatDateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatDateCell"];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSString *str_Date = message;
            if( str_Date.length >= 12 )
            {
                NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
                NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
                NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
                NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
                NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
                
                NSString *str = [NSString stringWithFormat:@"%@ %ld:%02ld",
                                 [str_Hour integerValue] > 12 ? @"오후" : @"오전",
                                 ([str_Hour integerValue] > 12) ? [str_Hour integerValue] - 12 : [str_Hour integerValue] == 0 ? 12 : [str_Hour integerValue], [str_Minute integerValue]];
                
                NSString *str_ShowingDate = [NSString stringWithFormat:@"%@월 %@일 %@", str_Month, str_Day, str];
                cell.lb_Date.text = str_ShowingDate;
            }
            else
            {
                NSLog(@"@#!@#!@#@!#");
            }
            
            return cell;
        }
        else
        {
            MyChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
//            cell.rightUtilityButtons = [self rightButtons];
//            cell.delegate = self;
//            cell.btn_Read.selected = YES;
//            cell.lb_Contents.text = userMessage.message;
            return cell;
        }
    }
    else if( tableView == self.tbv_AtList )
    {
        /*
         cc = 2;
         rId = 2492;
         userAffiliation = "\Uc9c4\Uba85\Ud559\Uc6d0\Uc120\Uc0dd";
         userEmail = "ss4@t.com";
         userId = 141;
         userMajor = "";
         userName = jason4;
         userThumbnail = "000/000/noImage3.png";
         userType = user;
         */

        NSDictionary *dic = self.arM_AtList[indexPath.row];
        
        ChatIngUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIngUserCell"];
        
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix
                                                   withFooter:[dic objectForKey_YM:@"userThumbnail"]] placeholderImage:BundleImage(@"no_image.png")];
        cell.lb_Name.text = [dic objectForKey_YM:@"userName"];
        cell.lb_NinkName.text = [dic objectForKey_YM:@"userAffiliation"];
        
        return cell;
    }
    else
    {
        AutoAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutoAnswerCell"];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;

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
            cell.userInteractionEnabled = NO;
        }
        else
        {
            cell.lb_Title.textColor = [UIColor colorWithHexString:@"#343B57"];
            cell.v_Bg.backgroundColor = [UIColor whiteColor];
            cell.userInteractionEnabled = YES;
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
        
        [self didSelectedItem:dic withMessage:baseMessage];
    }
    else if( tableView == self.tbv_AtList )
    {
        NSDictionary *dic = [self.arM_AtList objectAtIndex:indexPath.row];
        self.dic_SelectedMention = dic;
        self.v_CommentKeyboardAccView.tv_Contents.text = [NSString stringWithFormat:@"@%@:", [dic objectForKey_YM:@"userName"]];
    }
    else
    {
        nAutoAnswerIdx = indexPath.row;
        
        NSDictionary *dic = self.arM_AutoAnswer[indexPath.row];
        NSString *str_AutoAnswer = @"";
        if( self.autoChatMode == kPrintExam )
        {
            str_AutoAnswer = [dic objectForKey:@"btnLabel"];
            
//            self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = NO;
            [self performSelector:@selector(onKeyboardDownInterval) withObject:nil afterDelay:0.3f];
        }
        else if( self.autoChatMode == kPrintItem )
        {
            str_AutoAnswer = [NSString stringWithFormat:@"%@. %@", [dic objectForKey:@"returnValue"], [dic objectForKey:@"btnLabel"]];
            
//            self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = NO;
            
            [self performSelector:@selector(onKeyboardDownInterval) withObject:nil afterDelay:0.3f];
        }
        else if( self.autoChatMode == kPrintAnswer || self.autoChatMode == kNextExam || self.autoChatMode == kPrintContinue )
        {
            str_AutoAnswer = [dic objectForKey:@"btnLabel"];
//            self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = YES;
            [self performSelector:@selector(onKeyboardShowInterval) withObject:nil afterDelay:0.3f];
        }
        else
        {
            str_AutoAnswer = [dic objectForKey:@"btnLabel"];
            //            self.v_CommentKeyboardAccView.btn_KeyboardChange.selected = YES;
            [self performSelector:@selector(onKeyboardShowInterval) withObject:nil afterDelay:0.3f];
        }
        
        self.v_CommentKeyboardAccView.tv_Contents.text = str_AutoAnswer;
        
        if( [str_AutoAnswer rangeOfString:@"다음"].location != NSNotFound )
        {
            if( currentPlayer )
            {
                if( self.timeObserver )
                {
                    @try{
                        
                        [currentPlayer removeTimeObserver:self.timeObserver];
                        self.timeObserver = nil;
                        
                    }@catch(id anException){
                        [currentPlayer pause];
                        currentPlayer = nil;
                    }@finally {
                        
                    }
                }
                
                [currentPlayer pause];
                currentPlayer = nil;
            }
            
//            nAutoAnswerIdx = -1;
//            [self.tbv_TempleteList reloadData];
//
//            self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
//            self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;
//
//            [UIView animateWithDuration:0.25f animations:^{
//                [self.view layoutIfNeeded];
//            }];
//
//            [self.view endEditing:YES];

            [self performSelector:@selector(onKeyboardShowInterval) withObject:nil afterDelay:0.3f];
        }
        
        [self goSendMsg:nil];
        [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_List )
    {
        id message = self.messages[indexPath.row];
        NSDictionary *dic = nil;
        if( [message isKindOfClass:[SBDAdminMessage class]] )
        {
            SBDUserMessage *userMessage = (SBDUserMessage *)message;
            if( [userMessage.customType isEqualToString:@"USER_JOIN"] || [userMessage.customType isEqualToString:@"USER_LEFT"] )
            {
                return 44.f;
            }
            
            return 0;
        }
        else if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDBaseMessage *baseMessage = self.messages[indexPath.row];
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
//            NSDictionary *dic_BotDataTmp = [dic objectForKey:@"bot_data"];
//            if( dic_BotDataTmp == nil || [dic_BotDataTmp isKindOfClass:[NSNull class]] || [dic_BotDataTmp isKindOfClass:[NSDictionary class]] == NO )
//            {
//                return 0;
//            }
            
            SBDUser *user = userMessage.sender;
            NSString *str_MyUserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            NSString *str_SenderId = [NSString stringWithFormat:@"%@", user.userId];
            if( [str_MyUserId isEqualToString:str_SenderId] )
            {
                if( [userMessage.customType isEqualToString:@"text"] )
                {
                    //나의 글
                    static MyChatBasicCell *sizingCell = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"MyChatBasicCell"];
                    });
                    
                    [self myTextCell:sizingCell forRowAtIndexPath:indexPath];
                    //                sizingCell.lb_Contents.text = userMessage.message;
                    [sizingCell setNeedsLayout];
                    [sizingCell layoutIfNeeded];
                    CGFloat height = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    return height;
                }

                if( [userMessage.customType isEqualToString:@"image"] )
                {
                    static MyImageCell *sizingCell = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"MyImageCell"];
                    });

                    id message = self.messages[indexPath.row];
                    CGFloat fAddHeightValue = 10.f;
                    CGFloat fCellHeight = [self setMyImageCell:message withCell:sizingCell withIndexPath:indexPath withVideo:NO] + fAddHeightValue;
                    
                    [sizingCell setNeedsLayout];
                    [sizingCell layoutIfNeeded];
                    
                    return fCellHeight;
                }

                if( [userMessage.customType isEqualToString:@"video"] )
                {
                    static MyImageCell *sizingCell = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"MyImageCell"];
                    });
                    
                    id message = self.messages[indexPath.row];
                    CGFloat fAddHeightValue = 10.f;
                    CGFloat fCellHeight = [self setMyImageCell:message withCell:sizingCell withIndexPath:indexPath withVideo:YES] + fAddHeightValue;
                    
                    [sizingCell setNeedsLayout];
                    [sizingCell layoutIfNeeded];
                    
                    return fCellHeight;
                }
                
                if( [userMessage.customType isEqualToString:@"audio"] )
                {
                    return 38.f;
                }
                
                return 0;
            }
            else
            {
//                NSDictionary *dic_BotDataTmp = [dic objectForKey:@"bot_data"];
//                if( dic_BotDataTmp == nil || [dic_BotDataTmp isKindOfClass:[NSNull class]] || [dic_BotDataTmp isKindOfClass:[NSDictionary class]] == NO )
//                {
//                    return 0;
//                }

                NSDictionary *dic_BotData = [dic objectForKey:@"bot_data"];
                if( [dic_BotData isKindOfClass:[NSNull class]] == NO )
                {
                    if( [[dic_BotData objectForKey:@"mesgAction"] isEqualToString:@"toMessage"] )
                    {
                        NSString *str_FileType = [NSString stringWithFormat:@"%@", [dic_BotData objectForKey:@"type"]];
                        if( [str_FileType isEqualToString:@"audio"] )
                        {
                            //                        return 38.f;
                            return 106.f;
                        }
                        else
                        {
                            static TwoOtherChatCell *sizingCell = nil;
                            static dispatch_once_t onceToken;
                            dispatch_once(&onceToken, ^{
                                sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"TwoOtherChatCell"];
                            });
                            
                            [self twoOtherTextCell:sizingCell forRowAtIndexPath:indexPath];
                            //                sizingCell.lb_Contents.text = userMessage.message;
                            [sizingCell setNeedsLayout];
                            [sizingCell layoutIfNeeded];
                            CGFloat height = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                            return height;
                        }
                    }
                }
                
                if( [userMessage.customType isEqualToString:@"text"] )
                {
                    //남의 글
                    static OtherChatBasicCell *sizingCell = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"OtherChatBasicCell"];
                    });
                    
                    [self otherTextCell:sizingCell forRowAtIndexPath:indexPath];
                    //                sizingCell.lb_Contents.text = userMessage.message;
                    [sizingCell setNeedsLayout];
                    [sizingCell layoutIfNeeded];
                    CGFloat height = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    return height;
                }
                
                if( [userMessage.customType isEqualToString:@"pdfImage"] )
                {
                    static NormalQuestionCell *sizingCell = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"NormalQuestionCell"];
                    });
                    
                    id message = self.messages[indexPath.row];
                    CGFloat fAddHeightValue = 60.f;
                    CGFloat fCellHeight = [self setPdfImageCell:message withCell:sizingCell withIndexPath:indexPath] + fAddHeightValue;

                    [sizingCell setNeedsLayout];
                    [sizingCell layoutIfNeeded];
                    
                    return fCellHeight;
                }
                
                if( [userMessage.customType isEqualToString:@"image"] )
                {
                    static OtherImageCell *sizingCell = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"OtherImageCell"];
                    });
                    
                    id message = self.messages[indexPath.row];
                    CGFloat fAddHeightValue = 30.f;
                    CGFloat fCellHeight = [self setOtherImageCell:message withCell:sizingCell withIndexPath:indexPath withVideo:NO] + fAddHeightValue;
                    
                    [sizingCell setNeedsLayout];
                    [sizingCell layoutIfNeeded];
                    
                    return fCellHeight;
                }
                
                if( [userMessage.customType isEqualToString:@"video"] )
                {
                    static OtherImageCell *sizingCell = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"OtherImageCell"];
                    });
                    
                    id message = self.messages[indexPath.row];
                    CGFloat fAddHeightValue = 30.f;
                    CGFloat fCellHeight = [self setOtherImageCell:message withCell:sizingCell withIndexPath:indexPath withVideo:YES] + fAddHeightValue;
                    
                    [sizingCell setNeedsLayout];
                    [sizingCell layoutIfNeeded];
                    
                    return fCellHeight;
                }

                if( [userMessage.customType isEqualToString:@"audio"] )
                {
                    return 38.f;
                }
                
                return 0;

                //                OtherChatBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherChatBasicCell"];
                //                cell.rightUtilityButtons = [self rightButtons];
                //                cell.delegate = self;
                //                cell.lb_Contents.text = userMessage.message;
                //
                //                [self.c_OtherChatBasicCell updateConstraintsIfNeeded];
                //                [self.c_OtherChatBasicCell layoutIfNeeded];
                //
                //                //            self.c_MyChatBasicCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_MyChatBasicCell.bounds));
                //
                //                return [self.c_OtherChatBasicCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            }
        }
        else if( [message isKindOfClass:[NSString class]] )
        {
            return 37.f;
        }
        else
        {
            if( [message isKindOfClass:[NSDictionary class]] )
            {
                NSDictionary *dic = (NSDictionary *)message;
                if( [[dic objectForKey:@"temp"] isEqualToString:@"YES"] )
                {
                    if( [[dic objectForKey:@"type"] isEqualToString:@"audio"] )
                    {
                        return 38.f;
                    }
                    
                    BOOL isVideo = [[dic objectForKey_YM:@"type"] isEqualToString:@"video"];
                    static MyImageCell *sizingCell = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        sizingCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"MyImageCell"];
                    });
                    
                    id message = self.messages[indexPath.row];
                    CGFloat fAddHeightValue = 10.f;

                    return [self setMyImageCell:message withCell:sizingCell withIndexPath:indexPath withVideo:isVideo] + fAddHeightValue;
                }
            }
            return 0.f;
        }
        
        return 0.f;
    }
    else if( tableView == self.tbv_AtList )
    {
        return 44.f;
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

- (void)myAudioCell:(MyAudioCell *)cell indexPath:(NSIndexPath *)indexPath withData:(NSDictionary *)dic withMessageId:(long long)llMessageId
{
    NSDictionary *dic_FileData = [dic objectForKey:@"file_data"];
    double duration = [[dic_FileData objectForKey:@"playtime"] doubleValue];
    duration = ceil(duration);

    if( [[dic objectForKey:@"temp"] isEqualToString:@"YES"] )
    {
        NSLog(@"temptemptemptemptemptemptemptemptemptemptemp");
    }
    
    if( llMessageId <= 0 )
    {
        //템프일 경우
        return;
    }
    
    SBDBaseMessage *baseMessage = self.messages[indexPath.row];
    SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;

    cell.btn_Read.selected = YES;

    NSURL *url = [NSURL URLWithString:userMessage.message];
    
    cell.url = url;
    cell.nEId = llMessageId;
    cell.messageId = llMessageId;
    cell.fPlayDuration = duration;

    if( llCurrentMessageId == -1 || llCurrentMessageId != llMessageId )
    {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        cell.player = [AVPlayer playerWithPlayerItem:playerItem];
        cell.player = [AVPlayer playerWithURL:url];
//        cell.lb_Time.text = @"00:00";
        cell.lb_Time.hidden = YES;
        cell.lb_BgTime.hidden = NO;
        cell.btn_PlayPause.selected = NO;
        
        CGFloat fCurrentTime = cell.fPlayDuration;
        NSInteger nMinute = (NSInteger)fCurrentTime / 60;
        NSInteger nSecond = (NSInteger)fCurrentTime % 60;
        cell.lb_BgTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
        
        if( cell.player && self.timeObserver )
        {
            @try{
                
                [cell.player removeTimeObserver:self.timeObserver];
                self.timeObserver = nil;
                
            }@catch(id anException){
                //                                                [currentPlayer pause];
                //                                                currentPlayer = nil;
            }@finally {
                
            }
        }
    }
    else
    {
        NSLog(@"indexPath.row : %ld", indexPath.row);
        cell.lb_Time.hidden = NO;
        cell.lb_BgTime.hidden = YES;
        cell.btn_PlayPause.selected = isPlay;
        
        CGFloat fCurrentTime = cell.fPlayDuration;
        NSInteger nMinute = (NSInteger)fCurrentTime / 60;
        NSInteger nSecond = (NSInteger)fCurrentTime % 60;
        NSString *str_Time = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
        if( [str_Time isEqualToString:@"00:00"] )
        {
            cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
        }
    }
    
    NSMutableDictionary *dicM_Info = [NSMutableDictionary dictionary];
    [dicM_Info setObject:cell forKey:@"cell"];
    [dicM_Info setObject:url forKey:@"url"];
    [dicM_Info setObject:[NSNumber numberWithLongLong:llMessageId] forKey:@"eId"];
    [dicM_Info setObject:[NSNumber numberWithInteger:cell.tag] forKey:@"tag"];
    [dicM_Info setObject:[NSNumber numberWithInteger:llMessageId] forKey:@"messageId"];
//    [dicM_Info setObject:cell.lb_Time forKey:@"timeLabel"];
    [self.dicM_AutoAudio setObject:dicM_Info forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];

    cell.btn_PlayPause.obj = cell;
    cell.tag = cell.btn_PlayPause.tag = cell.btn_Replay.tag = indexPath.row;
    [cell.btn_PlayPause removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.btn_Replay removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.btn_PlayPause addTarget:self action:@selector(onMyAudioPlayAndPause:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onMyAudioPlayAndPause:(ExtentionButton *)btn
{
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    
    NSDictionary *dic_AudioInfo = [self.dicM_AutoAudio objectForKey:[NSString stringWithFormat:@"%ld", btn.tag]];
    
    NSInteger messageId = [[dic_AudioInfo objectForKey:@"messageId"] integerValue];
    if( messageId <= 0 )
    {
        return;
    }
    
    AutoChatAudioCell* cell = [dic_AudioInfo objectForKey:@"cell"];
    
    if( cell.nEId != currentEId )
    {
        //다른 플레이어를 선택했을때
        isPlay = NO;
    }
    
    if( isPlay == NO )
    {
        if( cell.nEId == currentEId )
        {
            if ((currentPlayer.rate == 0) && (currentPlayer.error == nil))
            {
                isPlay = YES;
                [currentPlayer play];
                //                [self.tbv_List reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tbv_List reloadData];
                    [self.tbv_List layoutIfNeeded];
                });
                
                return;
            }
        }
        
        @try
        {
            [currentPlayer removeTimeObserver:self.timeObserver];
            self.timeObserver = nil;
        }
        @catch(id anException)
        {
            [currentPlayer pause];
            currentPlayer = nil;
        }@finally {
            
        }
        
        currentCell = [dic_AudioInfo objectForKey:@"cell"];
        currentUrl = [dic_AudioInfo objectForKey:@"url"];
        currentEId = [[dic_AudioInfo objectForKey:@"eId"] integerValue]; //42940
        currentTag = [[dic_AudioInfo objectForKey:@"tag"] integerValue];
        llCurrentMessageId = [[dic_AudioInfo objectForKey:@"messageId"] integerValue];
//        lb_PlayerTime = [dic_AudioInfo objectForKey:@"timeLabel"];
        lb_PlayerTime = currentCell.lb_Time;
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:currentUrl];
        currentPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        currentPlayer = [AVPlayer playerWithURL:cell.url];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        self.timeObserver = [currentPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 2)
                                                                        queue:dispatch_get_main_queue()
                                                                   usingBlock:^(CMTime time)
                             {
                                 NSLog(@"onAutoAudioPlay");
                                 
                                 CGFloat fCurrentTime = currentCell.fPlayDuration - CMTimeGetSeconds(time);
                                 NSInteger nMinute = (NSInteger)fCurrentTime / 60;
                                 NSInteger nSecond = (NSInteger)fCurrentTime % 60;
                                 currentCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                 cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                 lb_PlayerTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                             }];
        
        isPlay = YES;
        
        __weak __typeof(&*self)weakSelf = self;
        [currentPlayer addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:CMTimeMake(1, 2)]]
                                                 queue:dispatch_get_main_queue()
                                            usingBlock:^{
                                                
                                                //                                                [weakSelf.tbv_List reloadData];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [weakSelf.tbv_List reloadData];
                                                    [weakSelf.tbv_List layoutIfNeeded];
                                                });
                                                
                                            }];
        
        [currentPlayer play];
    }
    else
    {
        [currentPlayer pause];
        isPlay = NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tbv_List reloadData];
        [self.tbv_List layoutIfNeeded];
    });
}

- (void)onAutoAudioPlayAndPause:(ExtentionButton *)btn
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    
    AutoChatAudioCell* cell = [self.tbv_List cellForRowAtIndexPath:indexPath];

    if( cell.nEId != currentEId )
    {
        //다른 플레이어를 선택했을때
        isPlay = NO;
    }

    if( isPlay == NO )
    {
        if( cell.nEId == currentEId )
        {
            if ((currentPlayer.rate == 0) && (currentPlayer.error == nil))
            {
                isPlay = YES;
                [currentPlayer play];
//                [self.tbv_List reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tbv_List reloadData];
                    [self.tbv_List layoutIfNeeded];
                });

                return;
            }
        }
        
        @try
        {
            [currentPlayer removeTimeObserver:self.timeObserver];
            self.timeObserver = nil;
        }
        @catch(id anException)
        {
            [currentPlayer pause];
            currentPlayer = nil;
        }@finally {
            
        }

//        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
//        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

//        long long llCreateTime = [[dic objectForKey:@"createDate"] longLongValue];

        
        
//        currentCell = [self.dicM_AutoAudio objectForKey:@"cell"];
//        currentUrl = [self.dicM_AutoAudio objectForKey:@"url"];
//        currentEId = [[self.dicM_AutoAudio objectForKey:@"eId"] integerValue]; //42940
//        currentTag = [[self.dicM_AutoAudio objectForKey:@"tag"] integerValue];
//        llCurrentMessageId = [[self.dicM_AutoAudio objectForKey:@"messageId"] integerValue];
//        lb_PlayerTime = [self.dicM_AutoAudio objectForKey:@"timeLabel"];

        currentCell = cell;
        currentUrl = cell.url;
        currentEId = cell.nEId; //42940
        currentTag = cell.tag;
        llCurrentMessageId = cell.messageId;
        lb_PlayerTime = cell.lb_Time;
        
//        currentCreateTime = llCreateTime;
//        nPlayEId = currentEId;
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:currentUrl];
        currentPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        currentPlayer = [AVPlayer playerWithURL:cell.url];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

//        CGFloat fDuration = CMTimeGetSeconds(playerItem.asset.duration);
        //    NSLog(@"%f", fDuration);
        
        
        self.timeObserver = [currentPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 2)
                                                    queue:dispatch_get_main_queue()
                                               usingBlock:^(CMTime time)
         {
             NSLog(@"onAutoAudioPlay");
             
             CGFloat fCurrentTime = currentCell.fPlayDuration - CMTimeGetSeconds(time);
             NSInteger nMinute = (NSInteger)fCurrentTime / 60;
             NSInteger nSecond = (NSInteger)fCurrentTime % 60;
             currentCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
             cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
             lb_PlayerTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
         }];
        
        isPlay = YES;

        __weak __typeof(&*self)weakSelf = self;
        [currentPlayer addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:CMTimeMake(1, 2)]]
                                                 queue:dispatch_get_main_queue()
                                            usingBlock:^{
                                                
//                                                [weakSelf.tbv_List reloadData];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [weakSelf.tbv_List reloadData];
                                                    [weakSelf.tbv_List layoutIfNeeded];
                                                });

                                            }];

        [currentPlayer play];
    }
    else
    {
        [currentPlayer pause];
        isPlay = NO;
    }
    
//    [self.tbv_List reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tbv_List reloadData];
        [self.tbv_List layoutIfNeeded];
    });

    
    
    
    
    
    
//    player
    
//    AutoChatAudioCell *cell = [dic_PlayerData objectForKey:@"cell"];
//    if ((cell.player.rate != 0) && (cell.player.error == nil))
//    {
//        [cell.player pause];
//    }
//    else
//    {
////        id observer = [dic_PlayerData objectForKey:@"observer"];
//
//        [cell.player play];
//    }
//    
//    btn.selected = !btn.selected;
}

- (void)onAutoAudioReplay:(UIButton *)btn
{
    if( currentPlayer == nil )  return;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    AutoChatAudioCell* cell = [self.tbv_List cellForRowAtIndexPath:indexPath];
    if( cell.nEId != currentEId )
    {
        //다른 플레이어를 선택했을때
        return;
    }

    isPlay = YES;

    [UIView animateWithDuration:0.15f animations:^{
       
        btn.transform = CGAffineTransformMakeRotation(degreesToRadian(-180));

    }completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15f animations:^{
           
            btn.transform = CGAffineTransformMakeRotation(degreesToRadian(0));
        }];
    }];
//    [Util rotationImage:btn withRadian:-180];
//    [Util rotationImage:btn withRadian:0];

    
    
    
    
    [currentPlayer seekToTime:CMTimeMake(0, 1)];
    [currentPlayer play];
//    [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.6f];
    
//    NSString *str_Key = [NSString stringWithFormat:@"%ld", btn.tag];
//    NSDictionary *dic_PlayerData = [self.dicM_AutoAudio objectForKey:str_Key];
//    //    AVPlayer *player = [dic_PlayerData objectForKey:@"player"];
//    
//    AutoChatAudioCell *cell = [dic_PlayerData objectForKey:@"cell"];
//    if ((currentPlayer.rate != 0) && (currentPlayer.error == nil))
//    {
//        [currentPlayer seekToTime:CMTimeMake(0, 1)];
//        [currentPlayer play];
//    }
}

- (void)onReloadInterval
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tbv_List reloadData];
        [self.tbv_List layoutIfNeeded];
    });
}

- (void)itemDidFinishPlaying:(NSNotification *)noti
{
    NSInteger nTempTag = currentTag;
    isPlay = NO;
    currentCell = nil;
    currentUrl = nil;
    currentEId = -1;
    currentTag = -1;
    llCurrentMessageId = -1;
    
    if( self.dicM_NextPlayInfo )
    { 
        llCurrentMessageId = [[self.dicM_NextPlayInfo objectForKey:@"messageId"] longLongValue];
        currentUrl = [self.dicM_NextPlayInfo objectForKey:@"url"];
        self.dicM_NextPlayInfo = nil;
        
        
        
        
        
        for (UIView *view in self.tbv_List.subviews)
        {
            for (UITableViewCell *cell in view.subviews)
            {
                if( [cell isKindOfClass:[AutoChatAudioCell class]] )
                {
                    AutoChatAudioCell *findCell = (AutoChatAudioCell *)cell;
                    if( llCurrentMessageId == findCell.messageId )
                    {
                        nTmpPlayTag = findCell.tag;
                        
                        currentCell = findCell;
                        currentUrl = findCell.url;
                        currentEId = findCell.nEId; //42940
                        currentTag = findCell.tag;
                        lb_PlayerTime = findCell.lb_Time;

                        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:currentUrl];
                        currentPlayer = [AVPlayer playerWithPlayerItem:playerItem];
                        currentPlayer = [AVPlayer playerWithURL:currentCell.url];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                        
                        isPlay = YES;
                        [currentPlayer play];
                        
                        if( currentPlayer && self.timeObserver )
                        {
                            @try{
                                
                                [currentPlayer removeTimeObserver:self.timeObserver];
                                self.timeObserver = nil;
                                
                            }@catch(id anException){
                                [currentPlayer pause];
                                currentPlayer = nil;
                            }@finally {
                                
                            }
                        }
                        
                        self.timeObserver = [currentPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 2)
                                                                                        queue:dispatch_get_main_queue()
                                                                                   usingBlock:^(CMTime time)
                                             {
                                                 NSLog(@"didEndDisplay");

//                                                 CGFloat fCurrentTime = CMTimeGetSeconds(time);
                                                 CGFloat fCurrentTime = currentCell.fPlayDuration - CMTimeGetSeconds(time);
                                                 NSInteger nMinute = (NSInteger)fCurrentTime / 60;
                                                 NSInteger nSecond = (NSInteger)fCurrentTime % 60;
                                                 currentCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                                 findCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                                 lb_PlayerTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                                 
                                                 for (UIView *view in self.tbv_List.subviews)
                                                 {
                                                     for (UITableViewCell *cell in view.subviews)
                                                     {
                                                         if( [cell isKindOfClass:[AutoChatAudioCell class]] )
                                                         {
                                                             AutoChatAudioCell *findCell = (AutoChatAudioCell *)cell;
                                                             findCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                                         }
                                                     }
                                                 }
                                             }];
                        
                        
                        __weak __typeof(&*self)weakSelf = self;
                        [currentPlayer addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:CMTimeMake(1, 2)]]
                                                                 queue:dispatch_get_main_queue()
                                                            usingBlock:^{
                                                                
                                                                nPlayEId = -1;
                                                                isPlay = YES;
//                                                                [weakSelf.tbv_List reloadData];
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [weakSelf.tbv_List reloadData];
                                                                    [weakSelf.tbv_List layoutIfNeeded];
                                                                });

                                                            }];
                        
                        nPlayEId = -1;
                        isPlay = YES;
//                        [weakSelf.tbv_List reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tbv_List reloadData];
                            [weakSelf.tbv_List layoutIfNeeded];
                        });

                        
//                        [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.3f];
//                        [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.6f];
                        [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.9f];
                    }
                }
            }
        }
        
        
//        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:nTempTag+1 inSection:0];
//        AutoChatAudioCell* cell = [self.tbv_List cellForRowAtIndexPath:indexPath];
//        currentCell = cell;
//        
//        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:currentUrl];
//        currentPlayer = [AVPlayer playerWithPlayerItem:playerItem];
//        currentPlayer = [AVPlayer playerWithURL:currentUrl];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//        
////        CGFloat fDuration = CMTimeGetSeconds(playerItem.asset.duration);
//        //    NSLog(@"%f", fDuration);
//        
//        
//        if( currentPlayer && self.timeObserver )
//        {
//            @try{
//                
//                [currentPlayer removeTimeObserver:self.timeObserver];
//                self.timeObserver = nil;
//                
//            }@catch(id anException){
//                
//            }
//        }
//        
//        self.timeObserver = [currentPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 2)
//                                                                        queue:dispatch_get_main_queue()
//                                                                   usingBlock:^(CMTime time)
//                             {
//                                 CGFloat fCurrentTime = CMTimeGetSeconds(time);
//                                 NSInteger nMinute = (NSInteger)fCurrentTime / 60;
//                                 NSInteger nSecond = (NSInteger)fCurrentTime % 60;
//                                 currentCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
//                                 cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
//                                 lb_PlayerTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
//                                 
//                             }];
//        
//        [currentPlayer play];
//        isPlay = YES;
//        
//        nPlayEId = -1;
    }
    
//    [self.tbv_List reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tbv_List reloadData];
        [self.tbv_List layoutIfNeeded];
    });

}

- (void)onKeyboardShowInterval
{
    [self showTempleteKeyboard];
}

- (void)onKeyboardDownInterval
{
//    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
//    __block UIView *view = [window viewWithTag:1982];
//    //    __block UITableView *tbv = [view viewWithTag:1983];
//    
//    [UIView animateWithDuration:0.3f animations:^{
//        
//        view.frame = CGRectMake(0, self.view.frame.size.height, view.frame.size.width, view.frame.size.height);
//    }];
    
    self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
    self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;

    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];

    nAutoAnswerIdx = -1;
}



- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if( tableView == self.tbv_TempleteList )    return;
    
    if( tableView == self.tbv_AtList )    return;

    if( indexPath == nil )  return;
    
    if( self.messages.count == 0 )  return;
    
    if( indexPath.row > self.messages.count - 1 )   return;

        
    id message = self.messages[indexPath.row];
    
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//        NSLog(@"mesage: %@, customType: %@", userMessage.message, userMessage.customType);
        if( [userMessage.customType isEqualToString:@"audio"] )
        {
            NSLog(@"audio cell didEndDisplaying");
            
            if( nPlayEId > -1 && nTmpPlayEId == nPlayEId )
            {
                NSLog(@"ININININININININININININININININ");
                if( currentPlayer )
                {
                    if( self.timeObserver )
                    {
                        @try{
                            
                            [currentPlayer removeTimeObserver:self.timeObserver];
                            self.timeObserver = nil;
                            
                        }@catch(id anException){
                            [currentPlayer pause];
                            currentPlayer = nil;
                        }@finally {
                            
                        }
                    }

                    [currentPlayer pause];
                    currentPlayer = nil;
                }
                
                AutoChatAudioCell* nowCell = (AutoChatAudioCell *)cell;
                
//                [self performSelector:@selector(playInterval:) withObject:currentCell.btn_PlayPause afterDelay:1.7f];
//                [self onAutoAudioPlayAndPause:currentCell.btn_PlayPause];

//                SBDBaseMessage *baseMessage = message;
//                SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
//                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
//                long long llCreateTime = [[dic objectForKey:@"createDate"] longLongValue];
                long long llMessageId = baseMessage.messageId;

                if( llCurrentMessageId == llMessageId )
//                if( 0 )
                {
                    nTmpPlayTag = cell.tag;

                    currentCell = nowCell;
                    currentUrl = nowCell.url;
                    currentEId = nowCell.nEId; //42940
                    currentTag = nowCell.tag;
                    lb_PlayerTime = nowCell.lb_Time;

                    //                currentCell.createTime = llCreateTime;
                    //                currentCreateTime = llCreateTime;
                    
                    //        nPlayEId = currentEId;
                    
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:currentUrl];
                    currentPlayer = [AVPlayer playerWithPlayerItem:playerItem];
                    currentPlayer = [AVPlayer playerWithURL:currentCell.url];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                    
                    isPlay = YES;
                    [currentPlayer play];

                    if( currentPlayer && self.timeObserver )
                    {
                        @try{
                            
                            [currentPlayer removeTimeObserver:self.timeObserver];
                            self.timeObserver = nil;
                            
                        }@catch(id anException){
                            [currentPlayer pause];
                            currentPlayer = nil;
                        }@finally {
                            
                        }
                    }
                    
                    self.timeObserver = [currentPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 2)
                                                                queue:dispatch_get_main_queue()
                                                           usingBlock:^(CMTime time)
                     {
                         NSLog(@"didEndDisplay");

//                         CGFloat fCurrentTime = CMTimeGetSeconds(time);
                         CGFloat fCurrentTime = currentCell.fPlayDuration - CMTimeGetSeconds(time);
                         NSInteger nMinute = (NSInteger)fCurrentTime / 60;
                         NSInteger nSecond = (NSInteger)fCurrentTime % 60;
                         currentCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                         nowCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                         lb_PlayerTime.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];

                         for (UIView *view in self.tbv_List.subviews)
                         {
                             for (UITableViewCell *cell in view.subviews)
                             {
                                 if( [cell isKindOfClass:[AutoChatAudioCell class]] )
                                 {
                                     AutoChatAudioCell *findCell = (AutoChatAudioCell *)cell;
                                     findCell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
                                 }
                             }
                         }
                     }];
                    

                    __weak __typeof(&*self)weakSelf = self;
                    [currentPlayer addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:CMTimeMake(1, 2)]]
                                                             queue:dispatch_get_main_queue()
                                                        usingBlock:^{
                                                           
                                                            nPlayEId = -1;
                                                            isPlay = YES;
//                                                            [weakSelf.tbv_List reloadData];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [weakSelf.tbv_List reloadData];
                                                                [weakSelf.tbv_List layoutIfNeeded];
                                                            });

                                                        }];
                    
                    nPlayEId = -1;
                    isPlay = YES;
//                    [weakSelf.tbv_List reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tbv_List reloadData];
                        [weakSelf.tbv_List layoutIfNeeded];
                    });

                    
//                    [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.3f];
//                    [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.6f];
                    [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.9f];
                }
                else
                {
//                    [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.3f];
//                    [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.6f];
                    [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.9f];
                }
            }
        }
    }
}

- (void)playInterval:(UIButton *)btn
{
    [self onAutoAudioPlayAndPause:btn];
    nPlayEId = -1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

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
        cell.lb_Title.text = [dic objectForKey_YM:@"btnLabel"];
    }
    else if( self.autoChatMode == kPrintItem )
    {
        cell.lb_Title.text = [NSString stringWithFormat:@"%@. %@", [dic objectForKey:@"returnValue"], [dic objectForKey:@"btnLabel"]];
    }
    else if( self.autoChatMode == kPrintAnswer || self.autoChatMode == kNextExam || self.autoChatMode == kPrintContinue )
    {
        cell.lb_Title.text = [dic objectForKey:@"btnLabel"];
    }
    else
    {
        cell.lb_Title.text = [dic objectForKey:@"btnLabel"];
    }
}

- (void)didSelectedItem:(NSDictionary *)dic withMessage:(SBDBaseMessage *)baseMessage
{
    SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSMutableDictionary *dic_Main = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSDictionary *dic_ActionMap = [dic_Main objectForKey:@"actionMap"];
    NSString *str_MsgType = [dic_ActionMap objectForKey:@"msgType"];
    
    if( [[dic_Main objectForKey:@"fileType"] isEqualToString:@"video"] )
    {
        NSArray *ar_Body = [dic_Main objectForKey:@"qnaBody"];
        if( ar_Body.count > 0 )
        {
            NSDictionary *dic_Body = [ar_Body firstObject];
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
            
            return;
        }
    }
    
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
        self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
        self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;
        
        [UIView animateWithDuration:0.25f animations:^{
            [self.view layoutIfNeeded];
        }];
        
        [self.view endEditing:YES];

//        if( [userMessage.customType isEqualToString:@"image"] || [userMessage.customType isEqualToString:@"pdfImage"] )
//        {
//            self.ar_Photo = [NSMutableArray array];
//            self.thumbs = [NSMutableArray array];
//
//            NSURL *url = [NSURL URLWithString:userMessage.message];
//            [self.thumbs addObject:[MWPhoto photoWithURL:url]];
//            [self.ar_Photo addObject:[MWPhoto photoWithURL:url]];
//
//            BOOL displayActionButton = NO;
//            BOOL displaySelectionButtons = NO;
//            BOOL displayNavArrows = YES;
//            BOOL enableGrid = NO;
//            BOOL startOnGrid = NO;
//
//            browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
//            browser.displayActionButton = displayActionButton;
//            browser.displayNavArrows = displayNavArrows;
//            browser.displaySelectionButtons = displaySelectionButtons;
//            browser.alwaysShowControls = displaySelectionButtons;
//            browser.zoomPhotosToFill = YES;
//#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
//            browser.wantsFullScreenLayout = YES;
//#endif
//            browser.enableGrid = enableGrid;
//            browser.startOnGrid = startOnGrid;
//            browser.enableSwipeToDismiss = YES;
//            [browser setCurrentPhotoIndex:0];
//
//            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
//            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//            [self presentViewController:nc animated:YES completion:nil];
//
//            // Release
//
//            // Test reloading of data after delay
//            double delayInSeconds = 3;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            });
//        }
//        else if( [userMessage.customType isEqualToString:@"video"] )
//        {
////            NSString *str_Contents = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"data_prefix"]];
//
//            NSURL *url = [NSURL URLWithString:userMessage.message];
//            self.vc_Movie = [[MPMoviePlayerViewController alloc]initWithContentURL:url];
//            self.vc_Movie.view.frame = self.view.bounds;
//            self.vc_Movie.moviePlayer.repeatMode = MPMovieRepeatModeOne;
//            self.vc_Movie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
//            self.vc_Movie.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//            self.vc_Movie.moviePlayer.shouldAutoplay = YES;
//            self.vc_Movie.moviePlayer.repeatMode = NO;
//            [self.vc_Movie.moviePlayer prepareToPlay];
//
//            [self presentViewController:self.vc_Movie animated:YES completion:nil];
//        }
//        else
//        {
//            self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
//            self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;
//
//            [UIView animateWithDuration:0.25f animations:^{
//                [self.view layoutIfNeeded];
//            }];
//
//            [self.view endEditing:YES];
//        }
    }
}

- (void)paste:(id)sender
{
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:userMessage.message]];
//    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"video"];

//    [[UIPasteboard generalPasteboard]

    NSData *data = [[UIPasteboard generalPasteboard]dataForPasteboardType:@"video"];

    UIImage *image = [UIPasteboard generalPasteboard].image;
    if( image )
    {
        UIImage *resizeImage = [Util imageWithImage:image convertToWidth:self.view.bounds.size.width - 30];
        [self uploadData:@{@"type":@"image", @"obj":UIImageJPEGRepresentation(resizeImage, 0.3f), @"thumb":resizeImage,
                           @"file_data":@{@"width":[NSString stringWithFormat:@"%f", resizeImage.size.width], @"height":[NSString stringWithFormat:@"%f", resizeImage.size.height]}}];
    }
    else if( data )
    {
        NSString *str = [UIPasteboard generalPasteboard].string;
        NSURL *url = [NSURL URLWithString:str];
        
        //비디오
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        CMTime time = [asset duration];
        time.value = 1;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);

        NSData *videoData = data;//[NSData dataWithContentsOfURL:url];
        [self uploadData:@{@"type":@"video", @"obj":videoData, @"thumb":UIImageJPEGRepresentation(thumbnail, 0.3f), @"videoUrl":[url absoluteString],
                           @"file_data":@{@"width":[NSString stringWithFormat:@"%f", thumbnail.size.width], @"height":[NSString stringWithFormat:@"%f", thumbnail.size.height]}}];
    }
    else
    {
        [super paste:sender];
    }
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self.view endEditing:YES];

        self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
        self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;

        [UIView animateWithDuration:0.25f animations:^{
            [self.view layoutIfNeeded];
        }];

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
            
            NSString *str_MyUserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            NSString *str_SenderId = [NSString stringWithFormat:@"%@", user.userId];
            if( [str_MyUserId isEqualToString:str_SenderId] )
            {
//                [self deleteQna:view.tag];
                NSMutableArray *arM = [NSMutableArray array];
                if( [userMessage.customType isEqualToString:@"image"] ||
                   [userMessage.customType isEqualToString:@"pdfImage"] ||
                   [userMessage.customType isEqualToString:@"text"])
                {
                    [arM addObject:@"복사하기"];
                }
                [arM addObject:@"삭제하기"];

                [OHActionSheet showSheetInView:self.view
                                         title:nil
                             cancelButtonTitle:@"취소"
                        destructiveButtonTitle:nil
                             otherButtonTitles:arM
                                    completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
                 {
                     if( arM.count <= buttonIndex ) return ;
                     
                     if( [[arM objectAtIndex:buttonIndex] isEqualToString:@"복사하기"] )
                     {
                         //복사
                         if( [userMessage.customType isEqualToString:@"image"] || [userMessage.customType isEqualToString:@"pdfImage"] )
                         {
                             UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userMessage.message]]];
                             [[UIPasteboard generalPasteboard] setImage:image];
                         }
//                         else if( [userMessage.customType isEqualToString:@"video"] )
//                         {
//                             [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:userMessage.message]];
//                         }
                         else
                         {
                             [[UIPasteboard generalPasteboard] setString:userMessage.message];
                         }
                     }
                     else if( [[arM objectAtIndex:buttonIndex] isEqualToString:@"삭제하기"] )
                     {
                         UIAlertView *alert = CREATE_ALERT(nil, @"해당 메세지를 삭제하시겠습니까?", @"확인", @"취소");
                         [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                             
                             if( buttonIndex == 0 )
                             {
                                 [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                                     
                                 }];
                             }
                         }];
                     }
                 }];
            }
            else
            {
                NSMutableArray *arM = [NSMutableArray array];
                if( [userMessage.customType isEqualToString:@"image"] ||
                   [userMessage.customType isEqualToString:@"pdfImage"] ||
                   [userMessage.customType isEqualToString:@"text"])
                {
                    [arM addObject:@"복사하기"];
                }
                [arM addObject:@"신고하기"];
                
                [OHActionSheet showSheetInView:self.view
                                         title:nil
                             cancelButtonTitle:@"취소"
                        destructiveButtonTitle:nil
                             otherButtonTitles:arM
                                    completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
                 {
                     if( arM.count <= buttonIndex ) return ;

                     if( [[arM objectAtIndex:buttonIndex] isEqualToString:@"복사하기"] )
                     {
                         if( [userMessage.customType isEqualToString:@"image"] || [userMessage.customType isEqualToString:@"pdfImage"] )
                         {
                             UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userMessage.message]]];
                             [[UIPasteboard generalPasteboard] setImage:image];
                         }
//                         else if( [userMessage.customType isEqualToString:@"video"] )
//                         {
////                             [[UIPasteboard generalPasteboard] setString:userMessage.message];
////
////                             NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:userMessage.message]];
////                             [[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"video"];
//
//                             [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:userMessage.message]];
//                         }
                         else
                         {
                             [[UIPasteboard generalPasteboard] setString:userMessage.message];
                         }

                     }
                     else if( [[arM objectAtIndex:buttonIndex] isEqualToString:@"신고하기"] )
                     {
                         //신고하기
                         UIAlertView *alert = CREATE_ALERT(nil, @"해당 게시글을 신고하시겠습니까?", @"확인", @"취소");
                         [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                             
                             if( buttonIndex == 0 )
                             {

                             }
                         }];
                     }
                 }];
            }
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
    
    __block NSDictionary *dic_BotData = [dic objectForKey:@"bot_data"];
//    __block NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic_BotData objectForKey:@"examId"]];
    __block NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic_BotData objectForKey:@"orgExamId"]];
    __block BOOL isPdf = YES;
//    //    NSDictionary *dic_Tmp = [dic objectForKey:@"dataMap"];
//    NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
//    NSDictionary *dic_Tmp = [ar_Body firstObject];
//    if( [[dic_Tmp objectForKey_YM:@"qnaType"] isEqualToString:@"normalQuestion"] )
//    {
//        isPdf = NO;
//        //        NSString *str_Tmp = [dic_Tmp objectForKey:@"qnaBody"];
//        //        NSData *data2 = [str_Tmp dataUsingEncoding:NSUTF8StringEncoding];
//        //        dic = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
//    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //    NSMutableDictionary *dic_Main = [NSMutableDictionary dictionaryWithDictionary:dic];
    //    NSDictionary *dic_ActionMap = [dic_Main objectForKey:@"actionMap"];
    //    NSString *str_MsgType = [dic_ActionMap objectForKey:@"msgType"];
    
    //    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[dic_Main objectForKey:@"actionMap"]];
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
                                                    vc.str_Title = [dic_BotData objectForKey:@"examTitle"];
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"orgExamId"] integerValue]];
                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"examNo"] integerValue] - 1];
                                                    vc.str_SortType = @"all";
                                                    vc.isPdf = isPdf;
                                                    vc.str_ChannelId = str_ChannelId;
                                                    
                                                    [self presentViewController:vc animated:NO completion:^{
                                                        
                                                    }];
                                                }
                                                else
                                                {
                                                    QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                                                    vc.hidesBottomBarWhenPushed = YES;
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"orgExamId"] integerValue]];
                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"examNo"] integerValue] - 1];
                                                    vc.str_SortType = @"all";
                                                    vc.isPdf = isPdf;
                                                    vc.str_ChannelId = str_ChannelId;
                                                    if( [[dic_BotData objectForKey:@"pdfPage"] integerValue] > 0 )
                                                    {
                                                        vc.str_PdfPage = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"pdfPage"] integerValue]];
                                                    }
                                                    if( [[dic_BotData objectForKey:@"examNo"] integerValue] > 0 )
                                                    {
                                                        vc.str_PdfNo = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"examNo"] integerValue]];
                                                    }
                                                    
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                            }
                                            else
                                            {
                                                QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
                                                vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"orgExamId"] integerValue]];
                                                vc.str_Title = [dic_BotData objectForKey_YM:@"examTitle"];
                                                [vc setCompletionPriceBlock:^(id completeResult) {
                                                    
                                                    QuestionContainerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                                                    vc.hidesBottomBarWhenPushed = YES;
                                                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"orgExamId"] integerValue]];
                                                    vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic_BotData objectForKey:@"examNo"] integerValue] - 1];
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
            
            fSampleViewTotalHeight += iv.frame.size.height;
            
            [cell.sv_Contents addSubview:iv];
            cell.sv_Contents.userInteractionEnabled = YES;
        }
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
    id message = self.messages[indexPath.row];
    
    SBDBaseMessage *baseMessage = nil;
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        baseMessage = self.messages[indexPath.row];
        SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
    
//    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    NSString *str_IsDone = [dic objectForKey_YM:@"isDone"];
    cell.btn_Read.selected = ![str_IsDone isEqualToString:@"N"];
    
    CGFloat fImageWidth = self.view.frame.size.width;
    CGFloat fImageHeight = self.view.frame.size.height;

    if( isVideo == NO )
    {
        NSDictionary *dic_ImageSize = [dic objectForKey:@"imageSize"];
        if( dic_ImageSize == nil )
        {
            dic_ImageSize = [dic objectForKey:@"file_data"];
        }
        
        fImageWidth = [[dic_ImageSize objectForKey_YM:@"width"] floatValue];
        fImageHeight = [[dic_ImageSize objectForKey_YM:@"height"] floatValue];
        
        cell.v_Video.hidden = YES;
        
        [cell.btn_Origin removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        
//        if( [[dic objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
//        {
//            cell.btn_Origin.tag = indexPath.row;
//            cell.btn_Read.hidden = YES;
//            cell.lb_Date.hidden = YES;
//
//            cell.btn_Origin.hidden = NO;
//            [cell.btn_Origin setTitle:[NSString stringWithFormat:@"출처:%@", [dic objectForKey_YM:@"examTitle"]] forState:UIControlStateNormal];
//            [cell.btn_Origin addTarget:self action:@selector(onMoveToPdf:) forControlEvents:UIControlEventTouchUpInside];
//
//            NSString *str_Contents = [dic_Body objectForKey:@"qnaBody"];
//            NSArray *ar_Tmp = [str_Contents componentsSeparatedByString:@"|"];
//            if( ar_Tmp && ar_Tmp.count > 0 )
//            {
//                NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:[ar_Tmp firstObject]];
//                //                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", str_ImagePreFix, [ar_Tmp firstObject]]];
//                [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
//            }
//        }

        if( [[dic objectForKey:@"temp"] isEqualToString:@"YES"] )
        {
            //템프면
            NSData *data = [dic objectForKey:@"obj"];
            UIImage *image = [UIImage imageWithData:data];
            cell.iv_Contents.image = image;
            
            NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:str_Date forState:0];
        }
        else
        {
            NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:[dic objectForKey_YM:@"data_prefix"]];
            [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
            
            cell.iv_Contents.userInteractionEnabled = YES;
            cell.iv_Contents.tag = indexPath.row;
            UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
            pinchZoom.delegate = self;
            [cell.iv_Contents addGestureRecognizer:pinchZoom];

            long long llCreateAt = baseMessage.createdAt;
            NSString *str_Date = [self getDateNumber:llCreateAt];
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];
        }
    }
    else if( isVideo )
    {
        if( [[dic objectForKey:@"temp"] isEqualToString:@"YES"] )
        {
            //템프면
            NSData *data = [dic objectForKey:@"obj"];
            UIImage *image = [UIImage imageWithData:data];
            cell.iv_Contents.image = image;
            
            NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:str_Date forState:0];
        }
        else
        {
            NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:[dic objectForKey_YM:@"data_prefix"]];
            [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
            
            cell.iv_Contents.userInteractionEnabled = YES;
            cell.iv_Contents.tag = indexPath.row;
            UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
            pinchZoom.delegate = self;
            [cell.iv_Contents addGestureRecognizer:pinchZoom];
            
            long long llCreateAt = baseMessage.createdAt;
            NSString *str_Date = [self getDateNumber:llCreateAt];
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:[Util getDetailDate:[NSString stringWithFormat:@"%@", str_Date]] forState:0];
        }
    }

    if( isnan(fImageHeight) || fImageHeight <= 0 )
    {
        fImageHeight = self.view.frame.size.height - kImageMargin;
    }
    
    if( isnan(fImageWidth) || fImageWidth <= 0 )
    {
        fImageWidth = self.view.frame.size.width - kImageMargin;
    }
    
    if( fImageWidth > fImageHeight )
    {
        //가로형
        //가로형이면 가로 기준에 맞춰서 세로 길이 늘리기
        CGFloat fScale = (self.view.bounds.size.width - kImageMargin)/fImageWidth;
        //            fImageHeight = fScale * fImageHeight;
        
        cell.lc_ImageWidth.constant = self.view.bounds.size.width - kImageMargin;
        cell.lc_ImageHeight.constant = fScale * fImageHeight;
    }
    else
    {
        CGFloat fScale = (self.view.bounds.size.width - kImageMargin)/fImageHeight;
        fImageWidth = fScale * fImageWidth;
        
        cell.lc_ImageWidth.constant = fImageWidth;
        cell.lc_ImageHeight.constant = self.view.bounds.size.width - kImageMargin;
    }
    
    //        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];

}

- (void)videoTap:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    SBDUserMessage *message = self.messages[view.tag];

    NSURL *url = [NSURL URLWithString:message.message];
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

- (void)imageTap:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    //    NSDictionary *dic = self.arM_List[view.tag];
    SBDUserMessage *message = self.messages[view.tag];
    
    if( [message.customType isEqualToString:@"video"] )
    {
        NSURL *url = [NSURL URLWithString:message.message];
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
    else
    {
        self.ar_Photo = [NSMutableArray array];
        self.thumbs = [NSMutableArray array];
        
        NSURL *url = [NSURL URLWithString:message.message];
        [self.thumbs addObject:[MWPhoto photoWithURL:url]];
        [self.ar_Photo addObject:[MWPhoto photoWithURL:url]];
        
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
    
    [self didSelectedItem:dic withMessage:baseMessage];
    
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
    
    
    
    
    
    if( self.channel.memberCount == 2 )
    {
        //1:1챗이면
        cell.lc_NameHeight.constant = 0.f;
    }

    if( indexPath.row > 0 )
    {
        //이전 메세지
        id message = self.messages[indexPath.row - 1];
        if( [message isKindOfClass:[SBDAdminMessage class]] == NO && [message isKindOfClass:[NSString class]] == NO )
        {
            id message = self.messages[indexPath.row - 1];
            NSDictionary *dic_Prev = nil;
            if( [message isKindOfClass:[SBDBaseMessage class]] )
            {
                SBDBaseMessage *baseMessage = self.messages[indexPath.row - 1];
                SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
                if( [userMessage.customType isEqualToString:@"audio"] )
                {
                    //                                isAudioMsg = YES;
                }
                
                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                dic_Prev = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            }
            else
            {
                //                            isAudioMsg = YES;
                dic_Prev = message;
            }
            
            NSInteger nUserId = [[dic objectForKey_YM:@"userId"] integerValue];
            NSInteger nNextUserId = [[dic_Prev objectForKey_YM:@"userId"] integerValue];
            
            NSInteger nTime = 0;
            NSInteger nPrevTime = 0;
            NSString *str_TimeTmp = [dic objectForKey_YM:@"createDate"];
            NSString *str_PrevTimeTmp = [dic_Prev objectForKey:@"createDate"];
            if( str_TimeTmp.length >= 12 && str_PrevTimeTmp.length >= 12 )
            {
                nTime = [[str_TimeTmp substringWithRange:NSMakeRange(0, 12)] integerValue];
                nPrevTime = [[str_PrevTimeTmp substringWithRange:NSMakeRange(0, 12)] integerValue];
            }
            
            if( nUserId == nNextUserId )
            {
                //이전 메세지가 내 메세지면
                if( nTime == nPrevTime )
                {
                    //1분 이내의 메세지
                    cell.iv_User.hidden = YES;
                    cell.lc_Top.constant = 0.f;
                }
                else
                {
                    //1분이 지난 메세지
                    cell.lc_NameHeight.constant = 15.f;
                    cell.iv_User.hidden = NO;
                    cell.lc_Top.constant = 15.f;
                }
            }
            else
            {
                //이전 메세지가 내 메세지가 아니면
                cell.lc_NameHeight.constant = 15.f;
                cell.iv_User.hidden = NO;
                cell.lc_Top.constant = 15.f;
            }
        }
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
//            cell.lb_Name.hidden = NO;
        }
        else if( [str_ChatType isEqualToString:@"channel"] )
        {
//            cell.lb_Name.hidden = NO;
        }
        else if( [str_ChatType isEqualToString:@"user"] )
        {
//            cell.lb_Name.hidden = YES;
        }
        
        cell.lb_Name.text = [dic objectForKey_YM:@"name"];
        
        //bbbbbbbbbbb
        CGFloat fImageWidth = self.view.frame.size.width;
        CGFloat fImageHeight = self.view.frame.size.height;

        if( isVideo == NO )
        {
            cell.v_Video.hidden = YES;
            
            fImageWidth = [[dic_Body objectForKey_YM:@"width"] floatValue];
            fImageHeight = [[dic_Body objectForKey_YM:@"height"] floatValue];
            
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
            fImageWidth = [[dic_Body objectForKey_YM:@"videoCoverWidth"] floatValue];   //640
            fImageHeight = [[dic_Body objectForKey_YM:@"videoCoverHeight"] floatValue]; //360

            cell.v_Video.hidden = NO;
            NSString *str_Contents = [dic_Body objectForKey:@"videoCoverPath"];
            NSURL *url = [Util createImageUrl:str_ImagePreFix withFooter:str_Contents];
            [cell.iv_Contents sd_setImageWithURL:url placeholderImage:BundleImage(@"no_thum_error.png")];
        }
        
        if( isnan(fImageHeight) || fImageHeight <= 0 )
        {
            fImageHeight = self.view.frame.size.height - kImageMargin;
        }

        if( isnan(fImageWidth) || fImageWidth <= 0 )
        {
            fImageWidth = self.view.frame.size.width - kImageMargin;
        }

        if( fImageWidth > fImageHeight )
        {
            //가로형
            //가로형이면 가로 기준에 맞춰서 세로 길이 늘리기
            CGFloat fScale = (self.view.bounds.size.width - kImageMargin)/fImageWidth;
            //            fImageHeight = fScale * fImageHeight;
            

            cell.lc_ImageWidth.constant = self.view.bounds.size.width - kImageMargin;
            cell.lc_ImageHeight.constant = fScale * fImageHeight;
        }
        else
        {
            CGFloat fScale = (self.view.bounds.size.width - kImageMargin)/fImageHeight;
//            fImageWidth = fScale * fImageWidth;
            

            cell.lc_ImageWidth.constant = fScale * fImageWidth;
            cell.lc_ImageHeight.constant = self.view.bounds.size.width - kImageMargin;
        }

//        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
        NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
        cell.lb_Date.text = @"";
        
        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        [btn_Date setTitle:str_Date forState:0];

//        cell.btn_Origin.hidden = NO;
//        cell.iv_Contents.backgroundColor = [UIColor blackColor];
//        cell.btn_Origin.backgroundColor = [UIColor redColor];
//        cell.backgroundColor = [UIColor yellowColor];
//        cell.contentView.backgroundColor = [UIColor yellowColor];
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
//            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            cell.lb_Date.text = @"";
            
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:str_Date forState:0];

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
//            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            cell.lb_Date.text = @"";
            
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:str_Date forState:0];

            
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
//            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            cell.lb_Date.text = @"";
            
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:str_Date forState:0];

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
//        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        cell.lb_Date.text = @"";
        
        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        [btn_Date setTitle:str_Date forState:0];

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
            cell.lb_Date.text = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
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
//        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"createDate"]]];
        NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        cell.lb_Date.text = @"";
        
        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        [btn_Date setTitle:str_Date forState:0];

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
    
    
    
    
    
    
    
    
    
    
    
    cell.lc_Top.constant = 5.f;
    
    if( indexPath.row > 0 )
    {
        //이전 메세지
        id message = self.messages[indexPath.row - 1];
        NSDictionary *dic_Prev = nil;
        if( [message isKindOfClass:[SBDBaseMessage class]] )
        {
            SBDBaseMessage *baseMessage = self.messages[indexPath.row - 1];
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
            dic_Prev = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        else
        {
            dic_Prev = message;
        }
        
        NSInteger nUserId = [[dic objectForKey_YM:@"userId"] integerValue];
        NSInteger nNextUserId = [[dic_Prev objectForKey_YM:@"userId"] integerValue];
        
        NSInteger nTime = 0;
        NSInteger nPrevTime = 0;
        NSString *str_TimeTmp = [dic objectForKey_YM:@"createDate"];
        NSString *str_PrevTimeTmp = [dic_Prev objectForKey:@"createDate"];
        if( str_TimeTmp.length >= 12 && str_PrevTimeTmp.length >= 12 )
        {
            nTime = [[str_TimeTmp substringWithRange:NSMakeRange(0, 12)] integerValue];
            nPrevTime = [[str_PrevTimeTmp substringWithRange:NSMakeRange(0, 12)] integerValue];
        }
        
        if( nUserId == nNextUserId )
        {
            cell.lc_Top.constant = 0.f;

//            //이전 메세지가 내 메세지면
//            if( nTime == nPrevTime )
//            {
//                //1분 이내의 메세지
//                cell.lc_Top.constant = 0.f;
//            }
//            else
//            {
//                //1분이 지난 메세지
////                cell.lc_Top.constant = 15.f;
//            }
        }
        else
        {
            //이전 메세지가 내 메세지가 아니면
            cell.lc_Top.constant = 15.f;
        }
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
    
//    cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
    NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
    cell.lb_Date.text = @"";
    
    UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
    [btn_Date setTitle:str_Date forState:0];

    [self addContent:cell withString:[dic objectForKey:@"contents"]];
    
    //    cell.lb_Contents.text = [dic objectForKey:@"contents"];
}

- (void)cmdCell:(CmdChatCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.v_Bg.backgroundColor = [UIColor colorWithHexString:@"ECEFF1"];
    
    //    NSDictionary *dic = self.arM_List[indexPath.row];
    
    id message = self.messages[indexPath.row];
    SBDBaseMessage *baseMessage = nil;
    SBDUserMessage *userMessage = nil;
    NSDictionary *dic = nil;
    if( [message isKindOfClass:[SBDBaseMessage class]] )
    {
        baseMessage = self.messages[indexPath.row];
        userMessage = (SBDUserMessage *)baseMessage;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        dic = message;
    }
    
//    [self hidenDateIfNeed:cell indexPath:indexPath];
    
    if( [userMessage.customType isEqualToString:@"USER_JOIN"] || [userMessage.customType isEqualToString:@"USER_LEFT"] )
    {
        //초대, 나감
        cell.lb_Cmd.text = [dic objectForKey:@"message"];
    }
    else if( [userMessage.customType isEqualToString:@"USER_ENTER"] )
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
//            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            cell.lb_Date.text = @"";
            
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:str_Date forState:0];

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
//        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        cell.lb_Date.text = @"";
        
        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        [btn_Date setTitle:str_Date forState:0];

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
//            cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic_Body objectForKey:@"createDate"]]];
            cell.lb_Date.text = @"";
            
            UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
            [btn_Date setTitle:str_Date forState:0];

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
//        cell.lb_Date.text = [Util getThotingChatDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        NSString *str_Date = [Util getDetailDate:[NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]]];
        cell.lb_Date.text = @"";
        
        UIButton *btn_Date = [cell.rightUtilityButtons firstObject];
        [btn_Date setTitle:str_Date forState:0];

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
    
    if( self.timeObserver )
    {
        @try{
            
            [currentPlayer removeTimeObserver:self.timeObserver];
            self.timeObserver = nil;
            
        }@catch(id anException){
            [currentPlayer pause];
            currentPlayer = nil;
        }@finally {
            
        }
    }

    [currentPlayer pause];
    currentPlayer = nil;
    
    
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
    
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_RId, @"rId",
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

    self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
    self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;

    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];

//    bLastKeybaordStatus = self.v_CommentKeyboardAccView.btn_KeyboardChange.selected;
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

- (void)updateRoom:(NSString *)aType withChatBotId:(NSString *)aChatBotId
{
    //봇을 초대한 경우
    //1.제권님이 만들어준 api로 방 업데이트
    //2.룸 상단 정보 가져오는 api로 화면 갱신
    //3.해당 방 샌드버드 정보도 업데이트
    
    __weak __typeof(&*self)weakSelf = self;

    NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSMutableDictionary *dicM_ChatInfo = [NSMutableDictionary dictionaryWithDictionary:[dic_Tmp objectForKey:@"qnaRoomInfos"]];
    NSString *str_OldRoomType = [dicM_ChatInfo objectForKey:@"roomType"];
    if( [str_OldRoomType isEqualToString:aType] == NO )
//    if( 1 )
    {
        //이전 룸 타입과 업데이트 된 룸 타입이 같지 않은 경우에만 업데이트
        
        [dicM_ChatInfo setObject:aType forKey:@"roomType"];
        if( aChatBotId )
        {
            [dicM_ChatInfo setObject:aChatBotId forKey:@"botUserId"];
        }
        
        NSError *err = nil;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:@{@"qnaRoomInfos":dicM_ChatInfo} options:0 error:&err];
        NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self.channel updateChannelWithName:self.channel.name coverUrl:self.channel.coverUrl data:str_Dic completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
            
        }];

        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            self.str_RId, @"rId",
                                            aType, @"roomType",//roomType: 채팅방 type [user, group, chatBot, 기본값-group], required=true
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/update/chat/room/type"
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
                                                    [weakSelf updateTopData];
                                                }
                                            }
                                            
                                            isSendPassible = YES;
                                            weakSelf.dic_BotInfo = @{@"userId":aChatBotId};
                                            [weakSelf sendBotWelcome];
                                        }];
    }
}


- (void)sendMsg:(NSString *)aMsg
{
//    SBDUser *user = [SBDMain getCurrentUser];
//    NSString *str_Msg = [NSString stringWithFormat:@"%@님이 %@님을 이 그룹에 추가했습니다.", user.nickname, @"00님을"];
//    NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
//    [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
//    [dicM_Param setObject:@"154" forKey:@"user_id"];
//    [dicM_Param setObject:str_Msg forKey:@"message"];
//    [dicM_Param setObject:@"USER_JOIN" forKey:@"custom_type"];
//    [dicM_Param setObject:@"true" forKey:@"is_silent"];
//
//    NSMutableDictionary *dicM_MessageData = [NSMutableDictionary dictionary];
//    [dicM_MessageData setObject:str_Msg forKey:@"message"];
//
//    NSMutableDictionary *dicM_Sender = [NSMutableDictionary dictionary];
//    [dicM_Sender setObject:user.nickname forKey:@"nickname"];
//    [dicM_Sender setObject:user.userId forKey:@"user_id"];
//    [dicM_MessageData setObject:dicM_Sender forKey:@"sender"];
//
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_MessageData
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:&error];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    [dicM_Param setObject:jsonString forKey:@"data"];
//
//    NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
//    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
//                                             param:dicM_Param
//                                        withMethod:@"POST"
//                                         withBlock:^(id resulte, NSError *error) {
//
//                                             if( resulte )
//                                             {
//
//                                             }
//                                         }];
//
//    return;
    
    
    
    
    
    //sendMsg
    BOOL isMention = NO;
    __block NSString *str_MentionId = @"";
    __block NSString *str_MentionName = @"";
    NSString *str_MentionMsg = @"";
    if( [self.v_CommentKeyboardAccView.tv_Contents.text hasPrefix:@"@"] )
    {
        //멘션
//        __weak __typeof(&*self)weakSelf = self;
        
//        NSString *str_MentionSelectedName = [NSString stringWithFormat:@"%@", [self.dic_SelectedMention objectForKey:@"userName"]];
//
//        NSDictionary *dic_InviteUser = nil;
//        for( NSInteger i = 0; i < self.arM_AtListBackUp.count; i++ )
//        {
//            dic_InviteUser = [self.arM_AtListBackUp objectAtIndex:i];
//            if( [str_MentionSelectedName isEqualToString:[NSString stringWithFormat:@"@%@", [dic_InviteUser objectForKey_YM:@"userName"]]] )
//            {
//                break;
//            }
//        }
        
        if( self.dic_SelectedMention != nil )
        {
            str_MentionId = [NSString stringWithFormat:@"%@", [self.dic_SelectedMention objectForKey_YM:@"userId"]];
            str_MentionName = [NSString stringWithFormat:@"%@", [self.dic_SelectedMention objectForKey_YM:@"userName"]];
            NSArray *ar = [aMsg componentsSeparatedByString:@":"];
            if( ar.count > 1 )
            {
                str_MentionMsg = ar[1];
                isMention = YES;
            }
        }
        
//        [self.channel inviteUserIds:@[str_InviteUserId] completionHandler:^(SBDError * _Nullable error) {
//
//            NSLog(@"%@", error);
//        }];
        
//        __block BOOL isBot = [[dic_InviteUser objectForKey_YM:@"userType"] isEqualToString:@"bot"];
//
//        if( isBot )
//        {
//            //봇을 초대 했으면 검색 리스트에서 봇 빼주기
//            str_BotId = str_InviteUserId;
//            [self updateAtList:@"user"];
//        }
//
//        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                            [Util getUUID], @"uuid",
//                                            self.str_RId, @"rId",
//                                            str_InviteUserId, @"inviteUserIdStr",
//                                            nil];
//
//        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/chat/room/add/invite/user"
//                                            param:dicM_Params
//                                       withMethod:@"POST"
//                                        withBlock:^(id resulte, NSError *error) {
//
//                                            [MBProgressHUD hide];
//
//                                            if( resulte )
//                                            {
//                                                NSLog(@"resulte : %@", resulte);
//
//                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                                if( nCode == 200 )
//                                                {
//                                                    NSDictionary *completeResult = @{@"userName":str_InviteUserName,
//                                                                                     @"count":@1,
//                                                                                     @"users":@[@{@"userId":str_InviteUserId, @"userName":str_InviteUserName}]};
//                                                    NSArray *ar_Users = [NSArray arrayWithArray:[completeResult objectForKey:@"users"]];
//                                                    for( NSInteger i = 0; i < ar_Users.count; i++ )
//                                                    {
//                                                        NSDictionary *dic_Tmp = ar_Users[i];
//                                                        [weakSelf.arM_User addObject:[dic_Tmp objectForKey:@"userId"]];
//                                                    }
//
//                                                    NSString *str_MyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//                                                    NSString *str_UserName = [completeResult objectForKey_YM:@"userName"];
//                                                    NSInteger nCnt = [[completeResult objectForKey_YM:@"count"] integerValue];
//                                                    NSString *str_Msg = @"";
//                                                    if( nCnt == 1 )
//                                                    {
//                                                        str_Msg = [NSString stringWithFormat:@"%@님이 %@님을 이 그룹에 추가했습니다.", str_MyName, str_UserName];
//                                                    }
//                                                    else
//                                                    {
//                                                        str_Msg = [NSString stringWithFormat:@"%@님이 %@님 외 %ld명을 이 그룹에 추가했습니다.", str_MyName, str_UserName, nCnt - 1];
//                                                    }
//
//                                                    [weakSelf sendMsgCmd:kInviteChat withMsg:str_Msg withUsers:ar_Users];
//
//                                                    //대시보드 업데이트 할 데이터 만들기 (lastMsg와 lastChatDate)
//                                                    NSDate *date = [NSDate date];
//                                                    NSCalendar* calendar = [NSCalendar currentCalendar];
//                                                    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
//                                                    NSInteger nYear = [components year];
//                                                    NSInteger nMonth = [components month];
//                                                    NSInteger nDay = [components day];
//                                                    NSInteger nHour = [components hour];
//                                                    NSInteger nMinute = [components minute];
//                                                    NSInteger nSecond = [components second];
//                                                    NSString *str_LastChatDate = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond];
//
//
//                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
//                                                    [dicM setObject:str_Msg forKey:@"lastMsg"];
//                                                    [dicM setObject:str_LastChatDate forKey:@"lastChatDate"];
//                                                    [dicM setObject:@"text" forKey:@"msgType"];
//
//                                                    [weakSelf sendDashboardUpdate:dicM];
//
//                                                    if( isBot )
//                                                    {
//                                                        weakSelf.dic_BotInfo = @{@"userId":str_InviteUserId};
//                                                        [weakSelf updateRoom:@"chatBot" withChatBotId:str_InviteUserId];
//                                                    }
//                                                    else if( self.dic_BotInfo == nil )
//                                                    {
//                                                        [weakSelf updateRoom:@"group" withChatBotId:nil];
//                                                    }
//                                                }
//                                            }
//                                        }];
        
    }

    
    
    
    
    
    
    
    
    
    __weak __typeof(&*self)weakSelf = self;

    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@"chat" forKey:@"itemType"];
//    [dicM setObject:@"text" forKey:@"message_type"];
    [dicM setObject:@"" forKey:@"file_ext"];
    [dicM setObject:@"" forKey:@"data_prefix"];
    if( str_UserImagePrefix && str_UserImagePrefix.length > 0 )
    {
        [dicM setObject:str_UserImagePrefix forKey:@"userImg_prefix"];
    }
    else
    {
        [dicM setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"] forKey:@"userImg_prefix"];
    }
    [dicM setObject:@"user" forKey:@"userType"];


    

    NSDictionary *dic_SelectedAutoAnswer = nil;
    NSInteger nSelectedNum = 0;
    for( NSInteger i = 0; i < self.arM_AutoAnswer.count; i++ )
    {
        NSDictionary *dic_Tmp = self.arM_AutoAnswer[i];
        NSString *str_CurrentMsg = @"";
        if( self.autoChatMode == kPrintExam )
        {
            str_CurrentMsg = [dic_Tmp objectForKey:@"btnLabel"];
        }
        else if( self.autoChatMode == kPrintItem )
        {
            str_CurrentMsg = [NSString stringWithFormat:@"%@. %@",
                              [dic_Tmp objectForKey:@"returnValue"], [dic_Tmp objectForKey:@"btnLabel"]];
        }
        else if( self.autoChatMode == kPrintAnswer || self.autoChatMode == kNextExam || self.autoChatMode == kPrintContinue )
        {
            //답 입력
            str_CurrentMsg = [dic_Tmp objectForKey:@"btnLabel"];
        }
        else
        {
            str_CurrentMsg = [dic_Tmp objectForKey:@"btnLabel"];
        }
        
        str_CurrentMsg = [str_CurrentMsg stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
        str_CurrentMsg = [str_CurrentMsg stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
        str_CurrentMsg = [str_CurrentMsg stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
        str_CurrentMsg = [str_CurrentMsg stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        NSString *str_TmpMsg = aMsg;
        str_TmpMsg = [str_TmpMsg stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
        str_TmpMsg = [str_TmpMsg stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
        str_TmpMsg = [str_TmpMsg stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
        str_TmpMsg = [str_TmpMsg stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

        if( [str_TmpMsg isEqualToString:str_CurrentMsg] )
        {
            dic_SelectedAutoAnswer = dic_Tmp;
            nSelectedNum = i + 1;
            break;
        }
    }
    
    NSString *str_CustomType = @"text";
    if( dic_SelectedAutoAnswer )
    {
        self.v_CommentKeyboardAccView.tv_Contents.text = @"";
        
        //제대로 입력 했으면
        NSMutableDictionary *dicM_BotData = [NSMutableDictionary dictionaryWithDictionary:dic_SelectedAutoAnswer];
        NSString *str_MsgAction = [NSString stringWithFormat:@"%@", [dic_SelectedAutoAnswer objectForKey:@"mesgAction"]];
        if( [str_MsgAction isEqualToString:@"apiBotMessage"] && [aMsg isEqualToString:@"다음"] )
        {
//            str_CustomType = @"cmd";
        }
        
        NSString *str_ReturnName = [NSString stringWithFormat:@"%@", [dic_SelectedAutoAnswer objectForKey:@"returnName"]];
        if( str_ReturnName.length > 0 )
        {
            [dicM_BotData setObject:[dic_SelectedAutoAnswer objectForKey:@"returnValue"] forKey:str_ReturnName];
        }
        
        NSString *str_BotUserId = [self.dic_BotInfo objectForKey:@"userId"];
        if( str_BotUserId && str_BotUserId.length > 0 )
        {
            [dicM_BotData setObject:str_BotUserId forKey:@"botUserId"];
        }
        [dicM_BotData setObject:@"chatBot" forKey:@"roomType"];
        
        if( str_MsgQuestionId && str_MsgQuestionId.length > 0 )
        {
            [dicM_BotData setObject:str_MsgQuestionId forKey:@"printQuestionId"];
        }

        if( str_MsgTesterId && str_MsgTesterId.length > 0 )
        {
            [dicM_BotData setObject:str_MsgTesterId forKey:@"testerId"];
        }
        
        if( str_MsgExamId && str_MsgExamId.length > 0 )
        {
            [dicM_BotData setObject:str_MsgExamId forKey:@"examId"];
        }

        if( str_MsgCorrectAnswer && str_MsgCorrectAnswer.length > 0 )
        {
            [dicM_BotData setObject:str_MsgCorrectAnswer forKey:@"correctAnswer"];
        }

        [dicM setObject:dicM_BotData forKey:@"bot_data"];
    }
    else if( isMention )
    {
        self.v_CommentKeyboardAccView.tv_Contents.text = @"";
        
        //멘션
        NSMutableDictionary *dicM_BotData = [NSMutableDictionary dictionaryWithDictionary:dic_SelectedAutoAnswer];
        [dicM_BotData setObject:str_MentionId forKey:@"toUserId"];
        [dicM_BotData setObject:@"user" forKey:@"toUserType"];
        [dicM_BotData setObject:str_MentionMsg forKey:@"toMessage"];
        [dicM_BotData setObject:@"toMesaage" forKey:@"mesgAction"];
        [dicM setObject:dicM_BotData forKey:@"bot_data"];
    }

    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM options:0 error:&err];
    NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    
    [self.channel sendUserMessage:aMsg
                             data:str_Data
                       customType:str_CustomType
                completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {

//                    [self.messages replaceObjectAtIndex:[str_FindKey integerValue] withObject:userMessage];

                    if( dic_SelectedAutoAnswer )
                    {
                        //정답이나 해설을 눌렀을때
                        if( [aMsg rangeOfString:@"정답을"].location != NSNotFound )
                        {
                            [weakSelf.arM_AutoAnswer removeObject:dic_SelectedAutoAnswer];
                            nAutoAnswerIdx = -1;
                        }
                        else if( [aMsg rangeOfString:@"해설을"].location != NSNotFound )
                        {
                            [weakSelf.arM_AutoAnswer removeObject:dic_SelectedAutoAnswer];
                            nAutoAnswerIdx = -1;
                        }
//                        else if( [aMsg rangeOfString:@"다음"].location != NSNotFound )
//                        {
//                            [weakSelf.arM_AutoAnswer removeObject:dic_SelectedAutoAnswer];
//                            nAutoAnswerIdx = -1;
//                        }
//                        else if( [str_CustomType isEqualToString:@"cmd"] )
//                        {
//                            [weakSelf.arM_AutoAnswer removeObject:dic_SelectedAutoAnswer];
//                            nAutoAnswerIdx = -1;
//
//                            weakSelf.v_CommentKeyboardAccView.tv_Contents.text = @"";
//                            weakSelf.v_CommentKeyboardAccView.lc_TfWidth.constant = 45.f;
//
//                            dispatch_async(dispatch_get_main_queue(), ^{
//
//                                [weakSelf.tbv_List reloadData];
//                                [weakSelf.tbv_List layoutIfNeeded];
//                                dispatch_async(dispatch_get_main_queue(), ^{
//
//                                    [weakSelf scrollToTheBottom:YES];
//                                    //                            [weakSelf.tbv_List reloadData];
//                                });
//                            });
//
//                            return ;
//                        }
                    }

                    [weakSelf.messages addObject:userMessage];

                    weakSelf.v_CommentKeyboardAccView.tv_Contents.text = @"";
                    weakSelf.v_CommentKeyboardAccView.lc_TfWidth.constant = 45.f;

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [weakSelf.tbv_List reloadData];
                        [weakSelf.tbv_List layoutIfNeeded];
                        dispatch_async(dispatch_get_main_queue(), ^{

                            [weakSelf scrollToTheBottom:YES];
//                            [weakSelf.tbv_List reloadData];
                        });
                    });
                }];

    return;
    
    NSString *str_BotId = nil;
//    if( [self.v_CommentKeyboardAccView.tv_Contents.text hasPrefix:@"@"] )
//    {
//        //유저 초대
//        __weak __typeof(&*self)weakSelf = self;
//
//        NSDictionary *dic_InviteUser = nil;
//        for( NSInteger i = 0; i < self.arM_AtList.count; i++ )
//        {
//            dic_InviteUser = [self.arM_AtList objectAtIndex:i];
//            if( [aMsg isEqualToString:[NSString stringWithFormat:@"@%@", [dic_InviteUser objectForKey_YM:@"userName"]]] )
//            {
//                break;
//            }
//        }
//
//        if( dic_InviteUser == nil )  return;
//
//        __block NSString *str_InviteUserId = [NSString stringWithFormat:@"%@", [dic_InviteUser objectForKey_YM:@"userId"]];
//        NSString *str_InviteUserName = [NSString stringWithFormat:@"%@", [dic_InviteUser objectForKey_YM:@"userName"]];
//
//        [self.channel inviteUserIds:@[str_InviteUserId] completionHandler:^(SBDError * _Nullable error) {
//
//            NSLog(@"%@", error);
//        }];
//
//        __block BOOL isBot = [[dic_InviteUser objectForKey_YM:@"userType"] isEqualToString:@"bot"];
//
//        if( isBot )
//        {
//            //봇을 초대 했으면 검색 리스트에서 봇 빼주기
//            str_BotId = str_InviteUserId;
//            [self updateAtList:@"user"];
//        }
//
//        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                            [Util getUUID], @"uuid",
//                                            self.str_RId, @"rId",
//                                            str_InviteUserId, @"inviteUserIdStr",
//                                            nil];
//
//        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/chat/room/add/invite/user"
//                                            param:dicM_Params
//                                       withMethod:@"POST"
//                                        withBlock:^(id resulte, NSError *error) {
//
//                                            [MBProgressHUD hide];
//
//                                            if( resulte )
//                                            {
//                                                NSLog(@"resulte : %@", resulte);
//
//                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                                if( nCode == 200 )
//                                                {
//                                                    NSDictionary *completeResult = @{@"userName":str_InviteUserName,
//                                                                                     @"count":@1,
//                                                                                     @"users":@[@{@"userId":str_InviteUserId, @"userName":str_InviteUserName}]};
//                                                    NSArray *ar_Users = [NSArray arrayWithArray:[completeResult objectForKey:@"users"]];
//                                                    for( NSInteger i = 0; i < ar_Users.count; i++ )
//                                                    {
//                                                        NSDictionary *dic_Tmp = ar_Users[i];
//                                                        [weakSelf.arM_User addObject:[dic_Tmp objectForKey:@"userId"]];
//                                                    }
//
//                                                    NSString *str_MyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//                                                    NSString *str_UserName = [completeResult objectForKey_YM:@"userName"];
//                                                    NSInteger nCnt = [[completeResult objectForKey_YM:@"count"] integerValue];
//                                                    NSString *str_Msg = @"";
//                                                    if( nCnt == 1 )
//                                                    {
//                                                        str_Msg = [NSString stringWithFormat:@"%@님이 %@님을 이 그룹에 추가했습니다.", str_MyName, str_UserName];
//                                                    }
//                                                    else
//                                                    {
//                                                        str_Msg = [NSString stringWithFormat:@"%@님이 %@님 외 %ld명을 이 그룹에 추가했습니다.", str_MyName, str_UserName, nCnt - 1];
//                                                    }
//
//                                                    [weakSelf sendMsgCmd:kInviteChat withMsg:str_Msg withUsers:ar_Users];
//
//                                                    //대시보드 업데이트 할 데이터 만들기 (lastMsg와 lastChatDate)
//                                                    NSDate *date = [NSDate date];
//                                                    NSCalendar* calendar = [NSCalendar currentCalendar];
//                                                    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
//                                                    NSInteger nYear = [components year];
//                                                    NSInteger nMonth = [components month];
//                                                    NSInteger nDay = [components day];
//                                                    NSInteger nHour = [components hour];
//                                                    NSInteger nMinute = [components minute];
//                                                    NSInteger nSecond = [components second];
//                                                    NSString *str_LastChatDate = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond];
//
//
//                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
//                                                    [dicM setObject:str_Msg forKey:@"lastMsg"];
//                                                    [dicM setObject:str_LastChatDate forKey:@"lastChatDate"];
//                                                    [dicM setObject:@"text" forKey:@"msgType"];
//
//                                                    [weakSelf sendDashboardUpdate:dicM];
//
//                                                    if( isBot )
//                                                    {
//                                                        weakSelf.dic_BotInfo = @{@"userId":str_InviteUserId};
//                                                        [weakSelf updateRoom:@"chatBot" withChatBotId:str_InviteUserId];
//                                                    }
//                                                    else if( self.dic_BotInfo == nil )
//                                                    {
//                                                        [weakSelf updateRoom:@"group" withChatBotId:nil];
//                                                    }
//                                                }
//                                            }
//                                        }];
//
//    }
    
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
    
//    __weak __typeof(&*self)weakSelf = self;
    
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
    
    
//    [self.dicM_TempMyContents setObject:dic_Temp forKey:[NSString stringWithFormat:@"%ld", self.messages.count]];
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
    
    if( str_BotId && str_BotId.length > 0 )
    {
        [dicM_Params setObject:str_BotId forKey:@"botId"];
    }
    

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
    
    //봇 모드이고 숫자를 입력 했을때
    
    BOOL isBotNumberSelect = NO;
//    for( NSInteger i = 0; i < self.arM_AutoAnswer.count; i++ )
//    {
//        NSDictionary *dic = self.arM_AutoAnswer[i];
//        NSString *str_Number = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"itemNo"]];
//        str_Number = [str_Number stringByReplacingOccurrencesOfString:@" " withString:@""];
//        NSString *str_UserMsg = [NSString stringWithFormat:@"%@", [dicM_Params objectForKey:@"msg"]];
//        str_UserMsg = [str_UserMsg stringByReplacingOccurrencesOfString:@" " withString:@""];
//        
//        if( [str_Number isEqualToString:str_UserMsg] )
//        {
//            isBotNumberSelect = YES;
//            break;
//        }
//    }
    
    
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
    
    if( isBotNumberSelect )
    {
        NSString *str_Msg = [NSString stringWithFormat:@"%@", [dicM_Params objectForKey:@"msg"]];

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
        
        [self.channel sendUserMessage:str_Msg
                                 data:@""
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

        return;
    }
    
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
                                            
                                            NSString *str_BotId = [NSString stringWithFormat:@"%@", [dicM_Params objectForKey_YM:@"botId"]];
                                            if( str_BotId.length > 0 )
                                            {
                                                NSData *jsonData = [str_Data dataUsingEncoding:NSUTF8StringEncoding];
                                                id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                NSMutableDictionary *dicM_Tmp = [NSMutableDictionary dictionaryWithDictionary:obj];
                                                [dicM_Tmp setObject:str_BotId forKey:@"botUserId"];
                                                
                                                jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Tmp options:0 error:&err];
                                                str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                            }
                                            
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
                                                            else
                                                            {
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
                                                                    if( currentPlayer )
                                                                    {
                                                                        if( self.timeObserver )
                                                                        {
                                                                            @try{
                                                                                
                                                                                [currentPlayer removeTimeObserver:self.timeObserver];
                                                                                self.timeObserver = nil;
                                                                                
                                                                            }@catch(id anException){
                                                                                [currentPlayer pause];
                                                                                currentPlayer = nil;
                                                                            }@finally {
                                                                                
                                                                            }
                                                                        }

                                                                        [currentPlayer pause];
                                                                        currentPlayer = nil;
                                                                    }
                                                                    
                                                                    nAutoAnswerIdx = -1;
                                                                    nPlayEId = -1;
                                                                    currentEId = -1;
                                                                    nTmpPlayEId = -1;
                                                                    nTmpPlayTag = -1;
                                                                    currentCreateTime = -1;
                                                                    
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
                                                                
                                                                [weakSelf.tbv_TempleteList reloadData];
                                                                
//                                                                UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
//                                                                UIView *view = [window viewWithTag:1982];
//                                                                UITableView *tbv = [view viewWithTag:1983];
//                                                                [tbv reloadData];
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
                                                                
                                                                [weakSelf.tbv_TempleteList reloadData];

//                                                                UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
//                                                                UIView *view = [window viewWithTag:1982];
//                                                                UITableView *tbv = [view viewWithTag:1983];
//                                                                [tbv reloadData];
                                                            }
                                                            else
                                                            {
                                                                for( NSInteger i = 0; i < self.ar_AutoAnswerBtnInfo.count; i++ )
                                                                {
                                                                    NSDictionary *dic_BtnInfo = self.ar_AutoAnswerBtnInfo[i];
                                                                    NSString *str_TmpTitle = [dic_BtnInfo objectForKey:@"btnLabel"];
                                                                    NSString *str_CurrentTitle = [dic_SelectedAutoAnswer objectForKey:@"title"];
                                                                    if( [str_TmpTitle isEqualToString:str_CurrentTitle] )
                                                                    {
                                                                        [dicM_Tmp setObject:[dic_BtnInfo objectForKey_YM:@"mesgAction"] forKey:@"mesgAction"];
                                                                        [dicM_Tmp setObject:[dic_BtnInfo objectForKey_YM:@"returnValue"] forKey:[dic_BtnInfo objectForKey_YM:@"returnName"]];
                                                                        [dicM_Tmp setObject:[dic_BtnInfo objectForKey_YM:@"chatScreen"] forKey:@"chatScreen"];

                                                                        nAutoAnswerIdx = -1;
                                                                        [weakSelf.tbv_TempleteList reloadData];
                                                                        [weakSelf onKeyboardDownInterval];

                                                                        break;
                                                                    }
                                                                }
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
                                                                weakSelf.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
                                                                weakSelf.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;

                                                                [UIView animateWithDuration:0.25f animations:^{
                                                                    [weakSelf.view layoutIfNeeded];
                                                                }];

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
//        SBDUser *user = [SBDMain getCurrentUser];
//        NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다", user.nickname];
//        NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
//        [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
//        [dicM_Param setObject:str_UserId forKey:@"user_id"];
//        [dicM_Param setObject:str_Msg forKey:@"message"];
//        [dicM_Param setObject:@"USER_JOIN" forKey:@"custom_type"];
//        [dicM_Param setObject:@"true" forKey:@"is_silent"];
//
//        NSMutableDictionary *dicM_MessageData = [NSMutableDictionary dictionary];
//        [dicM_MessageData setObject:str_Msg forKey:@"message"];
//
//        NSMutableDictionary *dicM_Sender = [NSMutableDictionary dictionary];
//        [dicM_Sender setObject:user.nickname forKey:@"nickname"];
//        [dicM_Sender setObject:user.userId forKey:@"user_id"];
//        [dicM_MessageData setObject:dicM_Sender forKey:@"sender"];
//
//        NSError *error;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_MessageData
//                                                           options:NSJSONWritingPrettyPrinted
//                                                             error:&error];
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        [dicM_Param setObject:jsonString forKey:@"data"];
//
//        NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
//        [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
//                                                 param:dicM_Param
//                                            withMethod:@"POST"
//                                             withBlock:^(id resulte, NSError *error) {
//
//                                                 if( resulte )
//                                                 {
//
//                                                 }
//                                             }];
    }
    else if( type == kLeaveChat )
    {
        //나감
        SBDUser *user = [SBDMain getCurrentUser];
        NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다", user.nickname];
        NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
        [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
        [dicM_Param setObject:str_UserId forKey:@"user_id"];
        [dicM_Param setObject:str_Msg forKey:@"message"];
        [dicM_Param setObject:@"USER_LEFT" forKey:@"custom_type"];
        [dicM_Param setObject:@"true" forKey:@"is_silent"];
        
        NSMutableDictionary *dicM_MessageData = [NSMutableDictionary dictionary];
        [dicM_MessageData setObject:str_Msg forKey:@"message"];
        
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
                                                     
                                                 }
                                             }];
    }
    else if( type == kEnterChat )
    {
        //입장
        SBDUser *user = [SBDMain getCurrentUser];
        NSString *str_Msg = [NSString stringWithFormat:@"%@님이 입장하셨습니다", user.nickname];
        NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
        [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
        [dicM_Param setObject:str_UserId forKey:@"user_id"];
        [dicM_Param setObject:str_Msg forKey:@"message"];
        [dicM_Param setObject:@"USER_ENTER" forKey:@"custom_type"];
        [dicM_Param setObject:@"true" forKey:@"is_silent"];

        NSMutableDictionary *dicM_MessageData = [NSMutableDictionary dictionary];
        [dicM_MessageData setObject:str_Msg forKey:@"message"];
        
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
                                                     
                                                 }
                                             }];
    }
}

- (IBAction)goShowAlbum:(id)sender
{
    [self.view endEditing:YES];
    
    self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
    self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;

    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];

    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:@[@"라이브러리", @"사진(카메라)", @"동영상(카메라)", @"소리(음성,mp3)"]
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, kUTTypeImage, nil];
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = NO;
//             imagePickerController.showsCameraControls = NO;

             
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
//             imagePickerController.showsCameraControls = NO;

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
         else if( buttonIndex == 3 )
         {
             MPMediaPickerController *pickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
             pickerController.prompt = @"Select Song";
             pickerController.delegate = self;
             [self presentViewController:pickerController animated:YES completion:nil];

         }
     }];
}


-(void)mediaItemToData : (MPMediaItem * ) curItem
{
    NSURL *url = [curItem valueForProperty: MPMediaItemPropertyAssetURL];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: url options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                      presetName:AVAssetExportPresetAppleM4A];
    
    exporter.outputFileType =   @"com.apple.m4a-audio";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * myDocumentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    [[NSDate date] timeIntervalSince1970];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    NSString *intervalSeconds = [NSString stringWithFormat:@"%0.0f",seconds];
    
    NSString * fileName = [NSString stringWithFormat:@"%@.m4a",intervalSeconds];
    
    NSString *exportFile = [myDocumentsDirectory stringByAppendingPathComponent:fileName];
    
    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    
    // do the export
    // (completion handler block omitted)
    [exporter exportAsynchronouslyWithCompletionHandler:
     ^{
         int exportStatus = exporter.status;
         
         switch (exportStatus)
         {
             case AVAssetExportSessionStatusFailed:
             {
                 NSError *exportError = exporter.error;
                 NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                 break;
             }
             case AVAssetExportSessionStatusCompleted:
             {
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 
                 NSData *data = [NSData dataWithContentsOfFile: [myDocumentsDirectory
                                                                 stringByAppendingPathComponent:fileName]];
                 
                 [self uploadData:@{@"type":@"audio", @"obj":data, @"duration":[NSNumber numberWithDouble:curItem.playbackDuration]}];

                 //DLog(@"Data %@",data);
                 data = nil;
                 
                 break;
             }
             case AVAssetExportSessionStatusUnknown:
             {
                 NSLog (@"AVAssetExportSessionStatusUnknown"); break;
             }
             case AVAssetExportSessionStatusExporting:
             {
                 NSLog (@"AVAssetExportSessionStatusExporting"); break;
             }
             case AVAssetExportSessionStatusCancelled:
             {
                 NSLog (@"AVAssetExportSessionStatusCancelled"); break;
             }
             case AVAssetExportSessionStatusWaiting:
             {
                 NSLog (@"AVAssetExportSessionStatusWaiting"); break;
             }
             default:
             {
                 NSLog (@"didn't get export status"); break;
             }
         }
     }];
}


#pragma mark - MPMediaPickerControllerDelegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *theChosenSong = [[mediaItemCollection items]objectAtIndex:0];
    [self mediaItemToData:theChosenSong];
//    NSString *songTitle = [theChosenSong valueForProperty:MPMediaItemPropertyTitle];
//    NSURL *assetURL = [theChosenSong valueForProperty:MPMediaItemPropertyAssetURL];
//    AVURLAsset  *songAsset  = [AVURLAsset URLAssetWithURL:assetURL options:nil];

    
    
//    // Get raw PCM data from the track
//    NSURL *assetURL = [theChosenSong valueForProperty:MPMediaItemPropertyAssetURL];
//    NSMutableData *data = [[NSMutableData alloc] init];
//    
//    const uint32_t sampleRate = 16000; // 16k sample/sec
//    const uint16_t bitDepth = 16; // 16 bit/sample/channel
//    const uint16_t channels = 2; // 2 channel/sample (stereo)
//    
//    NSDictionary *opts = [NSDictionary dictionary];
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:assetURL options:opts];
//    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:NULL];
//    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
//                              [NSNumber numberWithFloat:(float)sampleRate], AVSampleRateKey,
//                              [NSNumber numberWithInt:bitDepth], AVLinearPCMBitDepthKey,
//                              [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
//                              [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
//                              [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey, nil];
//    
//    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:        [[asset tracks] objectAtIndex:0] outputSettings:settings];
//    [reader addOutput:output];
//    [reader startReading];
//    
//    // read the samples from the asset and append them subsequently
//    while ([reader status] != AVAssetReaderStatusCompleted)
//    {
//        CMSampleBufferRef buffer = [output copyNextSampleBuffer];
//        if (buffer == NULL) continue;
//        
//        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(buffer);
//        size_t size = CMBlockBufferGetDataLength(blockBuffer);
//        uint8_t *outBytes = malloc(size);
//        CMBlockBufferCopyDataBytes(blockBuffer, 0, size, outBytes);
//        CMSampleBufferInvalidate(buffer);
//        CFRelease(buffer);
//        [data appendBytes:outBytes length:size];
//        free(outBytes);
//    }

//    NSURL *url = [theChosenSong valueForProperty: MPMediaItemPropertyAssetURL];
//    NSError *error = nil;
//    NSData *audioData = [NSData dataWithContentsOfURL:url options:nil error:&error];
//    if(!audioData)
//    {
//        NSLog(@"error while reading from %@ - %@", [url absoluteString], [error localizedDescription]);
//    }
//
//    NSData *data = [NSData dataWithContentsOfURL:assetURL];
//    
////    [self uploadData:@{@"type":@"audio", @"obj":data, @"path":[assetURL path], @"duration":[NSNumber numberWithDouble:theChosenSong.playbackDuration]}];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//{
//    if (error)
//    {
//        NSLog(@"error: %@", [error localizedDescription]);
//    }
//    else
//    {
//        NSLog(@"saved");
//    }
//}



#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak __typeof__(self) weakSelf = self;

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];

        // check if video is compatible with album
//        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([videoUrl path]);
//
//        // save
//        if (compatible)
//        {
//            UISaveVideoAtPathToSavedPhotosAlbum([videoUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
//            NSLog(@"saved!!!! %@",[videoUrl path]);
//        }

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
        [self uploadData:@{@"type":@"video", @"obj":videoData, @"thumb":UIImageJPEGRepresentation(resizeImage, 0.3f), @"videoUrl":[videoUrl absoluteString],
                           @"file_data":@{@"width":[NSString stringWithFormat:@"%f", resizeImage.size.width], @"height":[NSString stringWithFormat:@"%f", resizeImage.size.height]}}];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.tbv_List scrollRectToVisible:CGRectMake(self.tbv_List.contentSize.width - 1, self.tbv_List.contentSize.height - 1, 1, 1) animated:YES];
        }];
    }
    else 
    {
//        [self dismissViewControllerAnimated:NO completion:^{
//
//            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//            DZImageEditingController *editingViewController = [DZImageEditingController new];
//            editingViewController.image = image;
//            editingViewController.overlayView = self.overlayImageView;
//            editingViewController.cropRect = self.frameRect;
//            editingViewController.delegate = self;
//
//            [self presentViewController:editingViewController
//                               animated:YES
//                             completion:nil];
//        }];
        

        
        
        
        
        
        
        //2
        NSURL *imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:imageURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *repr = [asset defaultRepresentation];
            NSUInteger size = repr.size;
            NSMutableData *data = [NSMutableData dataWithLength:size];
            NSError *error;
            [repr getBytes:data.mutableBytes fromOffset:0 length:size error:&error];
            /* Now data contains the image data, if no error occurred */
            
            UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
            
            UIImage *resizeImage = [Util imageWithImage:outputImage convertToWidth:self.view.bounds.size.width - 30];

            [weakSelf uploadData:@{@"type":@"image", @"obj":data, @"thumb":resizeImage,
                               @"file_data":@{@"width":[NSString stringWithFormat:@"%f", resizeImage.size.width], @"height":[NSString stringWithFormat:@"%f", resizeImage.size.height]}}];
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
            [UIView animateWithDuration:0.3f animations:^{
                
                [weakSelf.tbv_List scrollRectToVisible:CGRectMake(weakSelf.tbv_List.contentSize.width - 1, weakSelf.tbv_List.contentSize.height - 1, 1, 1) animated:YES];
            }];

        } failureBlock:^(NSError *error) {
            /* handle error */
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
            [UIView animateWithDuration:0.3f animations:^{
                
                [weakSelf.tbv_List scrollRectToVisible:CGRectMake(weakSelf.tbv_List.contentSize.width - 1, weakSelf.tbv_List.contentSize.height - 1, 1, 1) animated:YES];
            }];
        }];

        
        
        
//        NSURL *url=(NSURL*)[info objectForKey:UIImagePickerControllerReferenceURL];
//
//        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
//        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
//            ALAssetRepresentation *rep = [asset defaultRepresentation];
//            Byte *buffer = (Byte*)malloc(rep.size);
//            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
//
//            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
//            NSLog(@"%@",data); //this is what I was expecting
//
//            [self uploadData:@{@"type":@"image", @"obj":data, @"thumb":resizeImage,
//                               @"file_data":@{@"width":[NSString stringWithFormat:@"%f", resizeImage.size.width], @"height":[NSString stringWithFormat:@"%f", resizeImage.size.height]}}];
//        }];
        
    }
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

    NSMutableDictionary *dic_Temp = [NSMutableDictionary dictionary];
//    [dic_Temp setObject:[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]] forKey:@"questionId"];
    [dic_Temp setObject:[dic objectForKey:@"type"] forKey:@"type"];
    [dic_Temp setObject:str_CreateTime forKey:@"createDate"];
    [dic_Temp setObject:@"YES" forKey:@"temp"];
    [dic_Temp setObject:@"N" forKey:@"isDone"];
    
    if( [[dic objectForKey_YM:@"type"] isEqualToString:@"audio"] )
    {
        [dic_Temp setObject:[dic objectForKey:@"obj"] forKey:@"obj"];
        [dic_Temp setObject:[dic objectForKey:@"duration"] forKey:@"duration"];
    }
    else
    {
        [dic_Temp setObject:([[dic objectForKey:@"type"] isEqualToString:@"image"] || [[dic objectForKey:@"type"] isEqualToString:@"pdfQuestion"]) ? [dic objectForKey:@"obj"] : [dic objectForKey:@"thumb"] forKey:@"obj"];
        [dic_Temp setObject:[dic objectForKey_YM:@"file_data"] forKey:@"file_data"];
        [dic_Temp setObject:@"YES" forKey:@"temp"];
    }

//    NSDictionary *dic_Temp = @{@"questionId":[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]],
//                               //                               @"contents":str_NoEncoding,
//                               @"type":[dic objectForKey:@"type"],
//                               @"createDate":str_CreateTime,
//                               @"temp":@"YES",
//                               @"isDone":@"N",
//                               @"obj":([[dic objectForKey:@"type"] isEqualToString:@"image"] || [[dic objectForKey:@"type"] isEqualToString:@"pdfQuestion"]) ? [dic objectForKey:@"obj"] : [dic objectForKey:@"thumb"],
//                               @"imageSize":[dic objectForKey_YM:@"imageSize"]
//                               };
    
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
//        [self.dicM_TempMyContents setObject:dicM_Tmp forKey:[NSString stringWithFormat:@"%ld", self.messages.count]];
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
                //v1/chat/file/uploader
                [[WebAPI sharedData] imageUpload:@"v1/chat/file/uploader"
                                           param:dicM_Params
                                      withImages:[NSDictionary dictionaryWithObject:[dicM objectForKey:@"obj"] forKey:@"file"]
                                       withBlock:^(id resulte, NSError *error) {
                                           
                                           NSInteger nCode = [[resulte objectForKey_YM:@"response_code"] integerValue];
                                           if( nCode == 200 )
                                           {
                                               __block NSDictionary *dic_Old = [NSDictionary dictionaryWithDictionary:resulte];
                                               if( [[dic objectForKey:@"type"] isEqualToString:@"video"] )
                                               {
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"tempUploadId"]] forKey:@"tempUploadId"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"serviceUrl"]] forKey:@"serviceUrl"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [dicM_Msg objectForKey:@"createDate"]] forKey:@"createDate"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"image_prefix"]] forKey:@"image_prefix"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"coverImgUrl"]] forKey:@"coverImgUrl"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"coverImgWidth"]] forKey:@"coverImgWidth"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"coverImgHeight"]] forKey:@"coverImgHeight"];


                                                   [weakSelf upLoadContents:dicM];

//                                                   NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                                                       [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                                                                       [Util getUUID], @"uuid",
//                                                                                       [resulte objectForKey:@"tempUploadId"], @"videoTempUploadId",
//                                                                                       [resulte objectForKey:@"serviceUrl"], @"videoServiceUrl",
//                                                                                       @"reply", @"uploadItem",
//                                                                                       @"image", @"type",
//                                                                                       nil];
//
//                                                   [[WebAPI sharedData] imageUpload:@"v1/attach/video/cover/image/uploader"
//                                                                              param:dicM_Params
//                                                                         withImages:[NSDictionary dictionaryWithObject:[dicM objectForKey:@"thumb"] forKey:@"file"]
//                                                                          withBlock:^(id resulte, NSError *error) {
//
//                                                                              if( resulte )
//                                                                              {
//                                                                                  NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                                                                  if( nCode == 200 )
//                                                                                  {
//                                                                                      [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"tempUploadId"]] forKey:@"tempUploadId"];
//                                                                                      [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"serviceUrl"]] forKey:@"serviceUrl"];
//                                                                                      [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"serviceUrl"]] forKey:@"thumb"];
//                                                                                      [dicM setObject:[NSString stringWithFormat:@"%@", [dicM_Msg objectForKey:@"createDate"]] forKey:@"createDate"];
//                                                                                      [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"image_prefix"]] forKey:@"image_prefix"];
//                                                                                      [weakSelf upLoadContents:dicM];
//                                                                                  }
//                                                                                  else
//                                                                                  {
//                                                                                      [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                                                                  }
//                                                                              }
//                                                                              else
//                                                                              {
//                                                                                  [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                                                              }
//                                                                          }];
                                               }
                                               else
                                               {
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"tempUploadId"]] forKey:@"tempUploadId"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"serviceUrl"]] forKey:@"serviceUrl"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [dicM_Msg objectForKey:@"createDate"]] forKey:@"createDate"];
                                                   [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"image_prefix"]] forKey:@"image_prefix"];

                                                   if( [[dic objectForKey:@"type"] isEqualToString:@"audio"] )
                                                   {
                                                       [dicM setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey:@"duration"]] forKey:@"duration"];
                                                   }
                                                   
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


#pragma mark - DZImageEditingControllerDelegate

- (void)imageEditingControllerDidCancel:(DZImageEditingController *)editingController
{
    [editingController dismissViewControllerAnimated:YES
                                          completion:nil];
}

- (void)imageEditingController:(DZImageEditingController *)editingController
     didFinishEditingWithImage:(UIImage *)editedImage
{
//    [self.imageView setImage:editedImage];
    [editingController dismissViewControllerAnimated:YES
                                          completion:nil];
}


- (void)upLoadContents:(NSDictionary *)dic
{
//    serviceUrl = "/c_edujm/temp/138/8736cf148fd933029baf2ba961e4bc9d.jpg";
//    tempIdx = 2;
//    tempUploadId = 5186;
//    thumb = "<UIImage: 0x6080002b0e60> size {345, 230.5} orientation 0 scale 2.000000";
//    type = image;
//    imageSize =     {
//        height = "230.500000";
//        width = "345.000000";
//    };

    __block NSString *str_CreateDate = [NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]];
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    NSMutableDictionary *dicM_FileInfo = [NSMutableDictionary dictionary];

    NSString *str_CustomType = @"";
    NSString *str_Msg = @"";
    if( [[dic objectForKey:@"type"] isEqualToString:@"image"] )
    {
        str_CustomType = @"image";
        NSString *str_FilePrefix = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"image_prefix"]];
        NSString *str_ServiceUrl = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"serviceUrl"]];
        if( [str_ServiceUrl hasPrefix:@"/"] )
        {
            NSMutableString *strM = [NSMutableString stringWithString:str_ServiceUrl];
            [strM deleteCharactersInRange:NSMakeRange(0, 1)];
            str_ServiceUrl = [NSString stringWithFormat:@"%@", strM];
        }
        str_Msg = [NSString stringWithFormat:@"%@%@", str_FilePrefix, str_ServiceUrl];
//        str_Msg = @"이미지를 전송 했습니다";

        //1
        [dicM setObject:[Util contentTypeForImageData:[dic objectForKey:@"obj"]] forKey:@"file_ext"];

        NSDictionary *dic_SizeInfo = [dic objectForKey:@"file_data"];
        NSString *str_Width = [NSString stringWithFormat:@"%f", [[dic_SizeInfo objectForKey:@"width"] floatValue]];
        NSString *str_Height = [NSString stringWithFormat:@"%f", [[dic_SizeInfo objectForKey:@"height"] floatValue]];
        [dicM_FileInfo setObject:str_Width forKey:@"width"];
        [dicM_FileInfo setObject:str_Height forKey:@"height"];
    }
    else if( [[dic objectForKey:@"type"] isEqualToString:@"audio"] )
    {
        str_CustomType = @"audio";
//        str_Msg = @"음성을 전송 했습니다";
        NSString *str_FilePrefix = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"image_prefix"]];
        NSString *str_ServiceUrl = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"serviceUrl"]];
        if( [str_ServiceUrl hasPrefix:@"/"] )
        {
            NSMutableString *strM = [NSMutableString stringWithString:str_ServiceUrl];
            [strM deleteCharactersInRange:NSMakeRange(0, 1)];
            str_ServiceUrl = [NSString stringWithFormat:@"%@", strM];
        }
        
        str_Msg = [NSString stringWithFormat:@"%@%@", str_FilePrefix, str_ServiceUrl];

        NSString *str_PlayTime = [NSString stringWithFormat:@"%@", [dic objectForKey:@"duration"]];
        NSNumber *playTime = [NSNumber numberWithFloat:[str_PlayTime floatValue]];
        [dicM_FileInfo setObject:playTime forKey:@"playtime"];
        [dicM_FileInfo setObject:str_PlayTime forKey:@"playtime_string"];
    }
    else if( [[dic objectForKey:@"type"] isEqualToString:@"pdfQuestion"] )
    {
        str_CustomType = @"pdfQuestion";
        str_Msg = @"새로운 질문이 등록 되었습니다";
    }
    else if( [[dic objectForKey:@"type"] isEqualToString:@"video"] )
    {
        str_CustomType = @"video";
//        str_Msg = @"동영상을 전송 했습니다";
        
        NSString *str_FilePrefix = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"image_prefix"]];
        NSString *str_ServiceUrl = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"serviceUrl"]];
        if( [str_ServiceUrl hasPrefix:@"/"] )
        {
            NSMutableString *strM = [NSMutableString stringWithString:str_ServiceUrl];
            [strM deleteCharactersInRange:NSMakeRange(0, 1)];
            str_ServiceUrl = [NSString stringWithFormat:@"%@", strM];
        }
        
        str_Msg = [NSString stringWithFormat:@"%@%@", str_FilePrefix, str_ServiceUrl];

        [dicM setObject:@"mp4" forKey:@"file_ext"];
        [dicM_FileInfo setObject:[dic objectForKey_YM:@"coverImgUrl"] forKey:@"coverImgUrl"];
        //        [dicM_FileInfo setObject:[dic objectForKey_YM:@"coverImgUrl"] forKey:@"coverImgUrl"];
        
        NSDictionary *dic_SizeInfo = [dic objectForKey:@"file_data"];
        NSString *str_Width = [NSString stringWithFormat:@"%f", [[dic_SizeInfo objectForKey:@"width"] floatValue]];
        NSString *str_Height = [NSString stringWithFormat:@"%f", [[dic_SizeInfo objectForKey:@"height"] floatValue]];
        [dicM_FileInfo setObject:str_Width forKey:@"width"];
        [dicM_FileInfo setObject:str_Height forKey:@"height"];
        [dicM_FileInfo setObject:[NSString stringWithFormat:@"%f", [[dic objectForKey:@"coverImgWidth"] floatValue]] forKey:@"coverImgWidth"];
        [dicM_FileInfo setObject:[NSString stringWithFormat:@"%f", [[dic objectForKey:@"coverImgHeight"] floatValue]] forKey:@"coverImgHeight"];
    }

    __weak __typeof(&*self)weakSelf = self;

    NSString *str_FilePrefix = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"image_prefix"]];
    [dicM setObject:@"chat" forKey:@"itemType"];
    [dicM setObject:str_FilePrefix forKey:@"data_prefix"];
    [dicM setObject:str_FilePrefix forKey:@"userImg_prefix"];
//    [dicM setObject:[NSString stringWithFormat:@"%@%@", @"http://chatapi.thoting.com/", str_ServiceUrl] forKey:@"data_prefix"];
//    [dicM setObject:@"http://chatapi.thoting.com" forKey:@"userImg_prefix"];
    [dicM setObject:@"user" forKey:@"userType"];
    [dicM setObject:dicM_FileInfo forKey:@"file_data"];

    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM options:0 error:&err];
    NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [self.channel sendUserMessage:str_Msg
                             data:str_Data
                       customType:[dic objectForKey:@"type"]
                completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {

                    for( NSInteger i = 0; i < weakSelf.messages.count; i++ )
                    {
                        id message = weakSelf.messages[i];
                        if( [message isKindOfClass:[NSDictionary class]] )
                        {
                            NSDictionary *dic_Message = (NSDictionary *)message;
                            if( [[dic_Message objectForKey_YM:@"temp"] isEqualToString:@"YES"] )
                            {
                                NSString *str_CurrentCreateDate = [NSString stringWithFormat:@"%@", [dic_Message objectForKey:@"createDate"]];
                                if( [str_CreateDate isEqualToString:str_CurrentCreateDate] )
                                {
                                    [weakSelf.messages replaceObjectAtIndex:i withObject:userMessage];
                                    break;
                                }
                            }
                        }
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tbv_List reloadData];
                        [weakSelf.tbv_List layoutIfNeeded];
                    });
                }];
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
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor whiteColor]
                                           normalIcon:BundleImage(@"")
                                         selectedIcon:BundleImage(@"")];
    
//    [rightUtilityButtons sw_addUtilityButtonWithColor:kMainRedColor
//                                           normalIcon:BundleImage(@"sw_leave.png")
//                                         selectedIcon:BundleImage(@"sw_leave.png")];
    
    return rightUtilityButtons;
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
    SBDUser *user = (SBDUser *)message.sender;

    KikMyViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikMyViewController"];
//    vc.str_UserIdx = user.userId;
    vc.user = user;
    vc.channel = self.channel;
    if( self.channel.memberCount == 2 )
    {
        vc.isOneOneChatIng = YES;
    }
    else
    {
        vc.isOneOneChatIng = NO;
    }
    [self.navigationController pushViewController:vc animated:YES];

//    UIView *view = gesture.view;
//    //    NSDictionary *dic = self.arM_List[view.tag];
//    SBDUserMessage *message = self.messages[view.tag];
//
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
//    //    vc.isManagerView = YES;
//    //    vc.isPermission = YES;
//    SBDUser *user = (SBDUser *)message.sender;
//    vc.str_UserIdx = user.userId;
//    vc.isShowNavi = YES;
//    vc.isAnotherUser = YES;
//    //    vc.hidesBottomBarWhenPushed = NO;
//    [self.navigationController pushViewController:vc animated:YES];
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

//        if( [data.message rangeOfString:@"정답을 알려주세요"].location != NSNotFound || [data.message rangeOfString:@"해설을"].location != NSNotFound )
//        {
//            for( NSInteger i = 0; i < self.arM_AutoAnswer.count; i++ )
//            {
//                NSDictionary *dic = self.arM_AutoAnswer[i];
//                NSString *str = [dic objectForKey_YM:@"title"];
//                if( [str isEqualToString:data.message] )
//                {
//                    [self.arM_AutoAnswer removeObjectAtIndex:i];
//                    [self.tbv_TempleteList reloadData];
//                    break;
//                }
//            }
//        }
        
        if( [data.customType isEqualToString:@"enterBotRoom"] )
        {
            return;
        }
        
        nAutoAnswerIdx = -1;

        
        NSString *str_Data = data.data;
        NSData *jsonData = [str_Data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        NSDictionary *dic_BotData = [dic objectForKey:@"bot_data"];
        
        NSDictionary *dic_BotDataTmp = [dic objectForKey:@"bot_data"];
        if( dic_BotDataTmp == nil || [dic_BotDataTmp isKindOfClass:[NSNull class]] || [dic_BotDataTmp isKindOfClass:[NSDictionary class]] == NO )
        {
//            [Util showToast:@"데이터 오류"];
            return;
        }

        NSString *str_Action = [dic_BotData objectForKey_YM:@"mesgAction"];

        NSLog(@"printQuestionId: %@", [dic objectForKey:@"printQuestionId"]);
        NSLog(@"printQuestionId_botData: %@", [dic_BotData objectForKey:@"printQuestionId"]);
        NSString *str_QuestionId = [NSString stringWithFormat:@"%@", [dic_BotData objectForKey:@"printQuestionId"]];
        if( [str_QuestionId intValue] > 0 )
        {
            str_MsgQuestionId = str_QuestionId;
        }
        else
        {
            str_MsgQuestionId = @"";
        }

        NSString *str_TesterId = [NSString stringWithFormat:@"%@", [dic_BotData objectForKey:@"testerId"]];
        if( [str_TesterId intValue] > 0 )
        {
            str_MsgTesterId = str_TesterId;
        }
        else
        {
            str_MsgTesterId = @"";
        }

        NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic_BotData objectForKey:@"examId"]];
        if( [str_TesterId intValue] > 0 )
        {
            str_MsgExamId = str_ExamId;
        }
        else
        {
            str_MsgExamId = @"";
        }

        NSString *str_CorrectAnswer = [NSString stringWithFormat:@"%@", [dic_BotData objectForKey:@"correctAnswer"]];
        if( [str_CorrectAnswer intValue] > 0 )
        {
            str_MsgCorrectAnswer = str_CorrectAnswer;
        }
        else
        {
            str_MsgCorrectAnswer = @"";
        }

        
        NSString *str_BotId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"botUserId"]];
        if( [data.message hasPrefix:@"@"] )
        {
            //상대방이 누군갈 초대했을때
            if( str_BotId.length > 0 )
            {
                self.dic_BotInfo = @{@"userId":str_BotId};
                [self updateTopData];
                [self updateAtList:@"user"];
            }
        }
        

        if( [str_Action isEqualToString:@"wellcomeMesg"] )
        {
            [self.arM_AutoAnswer removeAllObjects];
            
            self.autoChatMode = kPrintExam;
            
            NSDictionary *dic_BotData = [dic objectForKey:@"bot_data"];
            NSArray *ar_ExamList = [dic_BotData objectForKey:@"btnInfo"];
            self.arM_AutoAnswer = [NSMutableArray arrayWithArray:ar_ExamList];
            [self showTempleteKeyboard];
        }
        else if( [str_Action isEqualToString:@"apiBotMessage"] )
        {
            NSLog(@"%@", dic);
            
            [self.arM_AutoAnswer removeAllObjects];

            self.autoChatMode = kEtc;
            
            NSArray *ar = [dic_BotData objectForKey:@"btnInfo"];
            if( ar && ar.count > 0 )
            {
                self.arM_AutoAnswer = [NSMutableArray arrayWithArray:ar];
                
                [self showTempleteKeyboard];
            }
        }
        else if( [str_Action isEqualToString:@"selectSolveType"] )
        {
            NSLog(@"%@", dic);
            
            self.autoChatMode = kEtc;
            
            NSData *jsonData = [[dic objectForKey:@"btnInfo"] dataUsingEncoding:NSUTF8StringEncoding];
            self.ar_AutoAnswerBtnInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            NSLog(@"%@", self.ar_AutoAnswerBtnInfo);
            
            for( NSInteger i = 0; i < self.ar_AutoAnswerBtnInfo.count; i++ )
            {
                NSDictionary *dic_BtnInfo = self.ar_AutoAnswerBtnInfo[i];
                [self.arM_AutoAnswer addObject:@{@"title":[dic_BtnInfo objectForKey:@"btnLabel"]}];
            }

            [self showTempleteKeyboard];
        }
        else if( [str_Action isEqualToString:@"selectNextStep"] || [data.message isEqualToString:@"계속 풀겠습니까?"] )
        {
            NSLog(@"계속 풀겠습니까 샌드버드 받음");
            
            [self.arM_AutoAnswer removeAllObjects];
            
            self.autoChatMode = kPrintContinue;
//            self.dic_PrintItemInfo = dic;
            
            self.arM_AutoAnswer = [NSMutableArray arrayWithArray:[dic_BotData objectForKey_YM:@"btnInfo"]];

//            [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
            [self showTempleteKeyboard];
        }
        else if( [str_Action isEqualToString:@"printQuestionItem"] )
        {
            [self.arM_AutoAnswer removeAllObjects];
            
            self.autoChatMode = kPrintItem;
//            self.dic_PrintItemInfo = dic;
            self.arM_AutoAnswer = [NSMutableArray arrayWithArray:[dic_BotData objectForKey_YM:@"btnInfo"]];
//            [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
            [self showTempleteKeyboard];
        }
        else if( [str_Action isEqualToString:@"checkUserAnswer"] )
        {
            self.autoChatMode = kPrintAnswer;
            
            [self.arM_AutoAnswer removeAllObjects];
            
//            self.dic_PrintItemInfo = dic;
            
            self.arM_AutoAnswer = [NSMutableArray arrayWithArray:[dic_BotData objectForKey_YM:@"btnInfo"]];

//            NSString *str_IsExplain = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"existExplain"]];    //해설 여부
//            NSString *str_IsCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"isCorrect"]];       //정답 여부
//
//            if( [str_IsCorrect isEqualToString:@"N"] )
//            {
//                //오답일 경우
//                [self.arM_AutoAnswer addObject:@{@"title":@"정답을 알려주세요"}];
//
//                if( [str_IsExplain isEqualToString:@"Y"] )
//                {
//                    [self.arM_AutoAnswer addObject:@{@"title":@"해설을 보여주세요"}];
//                }
//
//                [self.arM_AutoAnswer addObject:@{@"title":@"다음 문제"}];
//            }
//            else
//            {
//                //정답일 경우
//                if( [str_IsExplain isEqualToString:@"Y"] )
//                {
//                    [self.arM_AutoAnswer addObject:@{@"title":@"해설을 보여주세요"}];
//                }
//
//                [self.arM_AutoAnswer addObject:@{@"title":@"다음 문제"}];
//            }
            
            [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
            [self showTempleteKeyboard];
        }
        else if( [str_Action isEqualToString:@"printReport"] )
        {
            //새로운 문제
            self.autoChatMode = kNextExam;
            
            [self.arM_AutoAnswer removeAllObjects];
            
//            self.dic_PrintItemInfo = dic;
            
            NSArray *ar = [NSArray arrayWithArray:[dic_BotData objectForKey:@"btnInfo"]];
            if( ar.count > 0 )
            {
                self.arM_AutoAnswer = [NSMutableArray arrayWithArray:[dic_BotData objectForKey_YM:@"btnInfo"]];
                
                //            [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
                [self showTempleteKeyboard];
            }
            else
            {
                nAutoAnswerIdx = -1;
            }
        }
        
        if( [data.customType isEqualToString:@"audio"] )
        {
            NSInteger nTmp = [[dic objectForKey:@"eId"] integerValue];
            NSLog(@"eId : %ld", nTmp);
            NSLog(@"nPlayEId : %ld", nPlayEId);

            if( nTmpEId != nTmp - 1 )
            {
                NSLog(@"Tartget eId : %ld", nTmp);
                
                nTmpEId = nTmp;
                nPlayEId = nTmp;
                nTmpPlayEId = nPlayEId;
                llCurrentMessageId = data.messageId;
//                long long llCreateTime = [[dic objectForKey:@"createDate"] longLongValue];
//                currentCreateTime = llCreateTime;
                
                NSLog(@"Tartget nPlayEId : %ld", nPlayEId);
                [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:1.0f];
            }
            else if( nTmpEId == nTmp - 1 )
            {
                //두개일 경우
                //연속 재생이 문제가 있어서 우선 막아둠
                
//                NSLog(@"!!!!!!!!!!!!!!!!!!!");
//                self.dicM_NextPlayInfo = [NSMutableDictionary dictionary];
//                [self.dicM_NextPlayInfo setObject:[NSString stringWithFormat:@"%lld", data.messageId] forKey:@"messageId"];
//                
//                NSString *str_Data = data.data;
//                NSData *data = [str_Data dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                NSArray *ar_Body = [dic objectForKey:@"qnaBody"];
//                NSDictionary *dic_Body = [ar_Body firstObject];
//                NSURL *url = [Util createImageUrl:[dic_Body objectForKey:@"image_prefix"] withFooter:[dic_Body objectForKey:@"qnaBody"]];
//                [self.dicM_NextPlayInfo setObject:url forKey:@"url"];
            }
        }
        else if( [data.customType isEqualToString:@"videoLink"] )
        {
            
        }
        
        
        [self.channel markAsRead];
        
        if( [message isKindOfClass:[SBDAdminMessage class]] )
        {
            SBDAdminMessage *adminMessage = (SBDAdminMessage *)message;
            if( [adminMessage.customType isEqualToString:@"USER_ENTER"] )
            {
                NSData *data = [adminMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSDictionary *dic_Sender = [json objectForKey:@"sender"];
                NSInteger senderUserId = [[dic_Sender objectForKey:@"user_id"] integerValue];
                NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
                if( nMyId != senderUserId )
                {
                    [self.navigationController.view makeToast:[json objectForKey:@"message"] withPosition:kPositionCenter];
                }
                
                return;
            }
            else
            {
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
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    if( self.messages.count > 0 )
                    {
                        if( self.messages.count > 1 )
                        {
                            id tmp = [self.messages objectAtIndex:self.messages.count - 2];
                            if( [tmp isKindOfClass:[SBDUserMessage class]] )
                            {
                                SBDUserMessage *tmpData = [self.messages objectAtIndex:self.messages.count - 2];
                                if( [tmpData.message isEqualToString:@"해설을 보여주세요"] )
                                {
                                    [self scrollToTheBottom:YES];
                                    return;
                                }
                            }
                            
//                            if( self.dic_BotInfo )
//                            {
//                                [self.tbv_List reloadData];
//                                [self performSelector:@selector(scrollToTheBottom2:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4f];
//                                return;
//                            }
                            if( [data.customType isEqualToString:@"image"] )
                            {
                                [self scrollToTheBottom:YES];
                                return;
                            }
                            else if( [data.customType isEqualToString:@"pdf"] )
                            {
                                [self.tbv_List reloadData];
                                [self performSelector:@selector(scrollToTheBottom2:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4f];
//                                [self scrollToTheBottom:YES];
                                return;
                            }
                        }
                        
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
                                [ALToastView toastKeyboardTop:self.view withText:@"새로운 메세지"];
                            }
                            else
                            {
                                [ALToastView toastInView:self.view withText:@"새로운 메세지"];
                            }
                        }
                        
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            
//                            [self.tbv_List reloadData];
//                        });
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
//                    [ALToastView toastInView:self.navigationController.view withText:@"삭제 되었습니다"];
                    
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

- (IBAction)goShowTempleteKeyboard:(id)sender
{
    if( self.arM_AutoAnswer.count > 0 )
    {
        [self.v_CommentKeyboardAccView.tv_Contents resignFirstResponder];
        self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;
        self.v_CommentKeyboardAccView.keyboardStatus = kTemplete;
        
        self.tbv_TempleteList.hidden = NO;
        self.v_Mic.hidden = YES;
    }
}

- (IBAction)goMic:(id)sender
{
    [self.v_CommentKeyboardAccView.tv_Contents resignFirstResponder];
    self.v_CommentKeyboardAccView.btn_TempleteKeyboard.hidden = YES;
    self.v_CommentKeyboardAccView.keyboardStatus = kTemplete;

    self.tbv_TempleteList.hidden = YES;
    self.v_Mic.hidden = NO;
    
    if( self.v_CommentKeyboardAccView.lc_Bottom.constant <= 0 )
    {
        if( fKeyboardHeight > 0 )
        {
            self.v_CommentKeyboardAccView.lc_Bottom.constant = fKeyboardHeight;
        }
        else
        {
            if( self.v_CommentKeyboardAccView.tv_Contents.autocorrectionType == UITextAutocorrectionTypeDefault ||
               self.v_CommentKeyboardAccView.tv_Contents.autocorrectionType == UITextAutocorrectionTypeYes )
            {
                self.v_CommentKeyboardAccView.lc_Bottom.constant = 258.f;
            }
            else
            {
                self.v_CommentKeyboardAccView.lc_Bottom.constant = 216.f;
            }
        }
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    __weak typeof(self)weakSelf = self;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [weakSelf scrollToTheBottom2:[NSNumber numberWithBool:YES]];
    });
}

- (IBAction)goRecordTouchDown:(id)sender
{
    NSLog(@"touch down");

    nMicTime = 0;
    self.tm_Mic = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onMicTimer:) userInfo:nil repeats:YES];
    
    [self setupAndPrepareToRecord];
    [self.mic_Recorder recordForDuration:120];

    isMicAni = YES;
    self.lb_MicTimer.textColor = self.v_MicContent.backgroundColor = [UIColor colorWithHexString:@"FF1414"];
    self.lb_MicCancelDescription.hidden = NO;
    self.lb_MicCancelDescription.text = @"";
    self.btn_Mic.selected = YES;
    [self.btn_Mic setImage:BundleImage(@"mic1-red-bold.png") forState:UIControlStateNormal];

    [self micAniStart];
}

- (IBAction)goRecordTouchCancel:(id)sender
{
//    [self.tm_Mic invalidate];
//    self.tm_Mic = nil;
//    
//    NSLog(@"cancel");
//    isMicAni = NO;
//    [self micReset];
    
    NSLog(@"cancel");
    
    self.lb_MicCancelDescription.text = @"취소하려면 버튼 밖으로 손가락을 이동하세요.";
    [self.btn_Mic setImage:BundleImage(@"mic1-red-bold.png") forState:UIControlStateNormal];
}

- (IBAction)goRecoredTouchDragInSide:(id)sender
{
    NSLog(@"drag inside");
    self.lb_MicCancelDescription.text = @"";
}

- (IBAction)goRecordTouchUpInSide:(id)sender
{
    NSLog(@"up");
    
    [self.tm_Mic invalidate];
    self.tm_Mic = nil;

    [self.mic_Recorder stop];

    if (!IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayback];
    }
    
//    self.mic_Player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.mic_RecordedAudioURL error:&audioError];
//    self.mic_Player.duration
//    self.mic_Player.delegate = self;
//    [self.mic_Player play];


    isMicAni = NO;

    NSError *audioError;
    AVAudioPlayer *mic_Player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.mic_RecordedAudioURL error:&audioError];
    
    [self micReset];
    
    NSString *str_Path = [self.mic_RecordedAudioURL path];
    NSData *data = [NSData dataWithContentsOfFile:str_Path];

    [self uploadData:@{@"type":@"audio", @"obj":data, @"path":str_Path, @"duration":[NSNumber numberWithDouble:mic_Player.duration]}];
}

- (IBAction)goRecordTouchUpOutSide:(id)sender
{
    NSLog(@"cancel");
    
    [self.tm_Mic invalidate];
    self.tm_Mic = nil;

    self.lb_MicCancelDescription.text = @"";

    isMicAni = NO;
    [self micReset];

}

- (void)setupAndPrepareToRecord
{
    NSLog(@"setupAndPrepareToRecord");
    
    if (!IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryRecord];
    }
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
    self.mic_RecordedAudioFileName = [NSString stringWithFormat:@"%@", date];
    
    // sets the path for audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"%@.m4a", self.mic_RecordedAudioFileName],
//                               [NSString stringWithFormat:@"%@.mp3", self.mic_RecordedAudioFileName],
                               nil];
    self.mic_RecordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // settings for the recorder
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];

//    NSDictionary *recordSetting =  [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [NSNumber numberWithInt:AVAudioQualityMin],AVEncoderAudioQualityKey,
//                                    [NSNumber numberWithInt:16], AVEncoderBitRateKey,
//                                    [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
//                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
//                                    [NSNumber numberWithInt:kAudioFormatMPEGLayer3], AVFormatIDKey,
//                                    nil];

    // initiate recorder
    NSError *error;
    self.mic_Recorder = [[AVAudioRecorder alloc] initWithURL:self.mic_RecordedAudioURL settings:recordSetting error:&error];
    self.mic_Recorder.delegate = self;
    [self.mic_Recorder prepareToRecord];
}

- (void)micAniStart
{
    if( isMicAni )
    {
        [UIView animateWithDuration:0.7f
                         animations:^{
                             
                             if( self.iv_MicAni.alpha > 0.4 )
                             {
                                 self.iv_MicAni.alpha = NO;
                             }
                             else
                             {
                                 self.iv_MicAni.alpha = 0.4f;
                             }
                             
                         } completion:^(BOOL finished) {
                             
                             [self micAniStart];
                         }];
    }
    else
    {
        [self.iv_MicAni.layer removeAllAnimations];
        [self micReset];
    }
}

- (void)micReset
{
    nMicTime = 0;
    [self.iv_MicAni.layer removeAllAnimations];
    self.iv_MicAni.alpha = NO;
    self.lb_MicCancelDescription.hidden = YES;
    self.lb_MicTimer.textColor = [UIColor colorWithHexString:@"828282"];
    self.v_MicContent.backgroundColor = [UIColor colorWithHexString:@"E6E6E6"];
    self.lb_MicDescription.text = @"눌러서 녹음하기";
    self.lb_MicTimer.text = @"0:00";
    self.btn_Mic.selected = NO;
    [self.btn_Mic setImage:BundleImage(@"mic0-red-bold.png") forState:UIControlStateNormal];
}

- (void)onMicTimer:(NSTimer *)timer
{
    nMicTime++;
    NSInteger nMinute = nMicTime / 60;
    NSInteger nSecond = nMicTime % 60;
    self.lb_MicTimer.text = [NSString stringWithFormat:@"%ld:%02ld", nMinute, nSecond];
}

//음악 재생이 멈춘 후 콜
//- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
//{
//    
//}

- (IBAction)goRoomInfo:(id)sender
{
    NSString *str_CoverUrl = [self.dic_Info objectForKey_YM:@"roomCoverUrl"];

    KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
    vc.str_RoomTitle = self.channel.name;
    vc.dic_Info = self.dic_Info;
    vc.channel = self.channel;
    vc.isFromRoom = YES;
     
    if( self.dic_BotInfo )
    {
        vc.roomType = kBot;
    }
    
    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]];
    if( str_CoverUrl && str_CoverUrl.length > 0 )
    {
        vc.str_RoomThumb = [NSString stringWithFormat:@"%@%@",
                            str_UserImagePrefix, str_CoverUrl];
    }
    
    if( self.channel.memberCount <= 2 )
    {
        vc.str_RoomThumb = [NSString stringWithFormat:@"%@%@",
                            str_UserImagePrefix, str_TargetUserImageUrl];
        vc.str_TargetUserName = str_TargetUserName;
    }
    
    vc.str_MemberCount = [NSString stringWithFormat:@"%ld", self.channel.memberCount];
    vc.bgColor = self.roomColor ? self.roomColor : [UIColor colorWithHexString:@"9ED8EB"];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onAddInputBotName:(UIButton *)btn
{
    SBDBaseMessage *baseMessage = self.messages[btn.tag];
    SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
    NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *dic_BtnInfo = [dic objectForKey:@"btnInfo"];
    self.v_CommentKeyboardAccView.tv_Contents.textColor = kMainColor;
    self.v_CommentKeyboardAccView.tv_Contents.text = [NSString stringWithFormat:@"@%@", [dic_BtnInfo objectForKey:@"btnLabel"]];
    
    NSDictionary *dic_BotData = [dic objectForKey:@"bot_data"];
    NSInteger nTargetUserId = [[dic_BotData objectForKey:@"botUserId"] integerValue];
    
    for( NSInteger i = 0; i < self.arM_AtListBackUp.count; i++ )
    {
        NSDictionary *dic_Sub = self.arM_AtListBackUp[i];
        NSInteger nUserId = [[dic_Sub objectForKey:@"userId"] integerValue];
        if( nTargetUserId == nUserId )
        {
            self.dic_SelectedMention = dic_Sub;
            break;
        }
    }
}

@end


