//
//  QuestionListSwipeViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 28..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

/*
 CATransition* transition = [CATransition animation];
 transition.duration = 0.5;
 transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
 transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
 //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
 [self.navigationController.view.layer addAnimation:transition forKey:nil];
 [[self navigationController] popViewControllerAnimated:NO];
 */

#import "QuestionListSwipeViewController.h"
#import "QuestionContainerViewController.h"
#import "TLYShyNavBarManager.h"
#import "QuestionListCell.h"
#import "QuestionListHeaderCell.h"
#import "QuestionListTitleView.h"
#import "AnswerNumberView.h"
#import "AnswerView.h"
#import "QuestionDiscriptionViewController.h"

#import "AnswerTitleCell.h"
#import "Answer6Cell.h"
#import "AnswerDiscripCell.h"
#import "AnswerSubjectiveCell.h"

#import "AnswerPrintNumber2Cell.h"
#import "AnswerPrintSubjectCell.h"
#import "YTPlayerView.h"
#import "YmExtendButton.h"
#import "ReportDetailViewController.h"
#import "AudioView.h"
#import "SideMenuViewController.h"
#import "WrongSideViewController.h"

#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "PageControllerView2.h"
#import "QuestionDiscriptionViewController.h"
#import "PauseViewController.h"

#import "QuestionBottomView.h"
#import "AddDiscripViewController.h"

#import "InvitationViewController.h"
#import "SharedViewController.h"

#import "ChatFeedViewController.h"
#import "SSZipArchive.h"

@import AVFoundation;
@import MediaPlayer;

static const NSInteger kPlayButtonTag = 10;
static BOOL isBackOk = NO;
static NSMutableArray *arM_Vc = nil;

@import AMPopTip;

@interface QuestionListSwipeViewController () <UITextFieldDelegate, ReaderViewControllerDelegate>
{
    BOOL isFirst;
    BOOL isFinish;      //문제를 풀었는지
    BOOL isFinishPass;  //문제를 풀고 맞췄는지
    BOOL isAnswerShow;  //답 뷰가 열렸는지 여부
    NSInteger nCellCount;   //셀 갯수 (정답입력화면 유무에 따른)
    NSInteger nCurrentSection;
    //    NSInteger nTime;
    
    NSInteger nQuestionCount;   //전체 문제 수
    CGFloat fContentsHeight;    //컨텐츠 셀 높이
    
    NSString *str_MultipleChoice;   //주관식인지 객관식인지 ox인지 (주관식Y 객관식N OX:O)
    NSInteger nCorrectCnt;  //답 갯수
    NSString *str_UserThumbUrl; //유저 섬네일
    
    NSString *str_CurrentExamNo;    //현재 문제 번호
    
    NSInteger nNaviNowCnt;          //네비에 표시되는 현재 문제 번호
    NSInteger nNaviTotalCnt;        //네비에 표시되는 전체 문제 수
    
    NSMutableString *str_MyCorrect;    //내가 선택 또는 입력한 답
    NSInteger correctAnswerCount;   //답 갯수
    NSInteger itemCount;
    BOOL isNumberQuestion;  //객관식 여부 (객관식이면 Y, 주관식이면 N)
    BOOL isStopAudio;
    
    BOOL isUpdateLayout;
    
    CGFloat fKeyboardHeight;

}
//음성문제 관련
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
//@property (nonatomic, strong) AudioView *v_Audio;
/////////

//비디오 관련
@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
///////////

//유튜브
@property (nonatomic, strong) YTPlayerView *playerView;
//////////

@property (nonatomic, strong) NSMutableDictionary *dicM_CellHeight;
@property (nonatomic, strong) NSString *str_ImagePreFix;
@property (nonatomic, strong) AMPopTip *popTip;
@property (nonatomic, strong) NSDictionary *dic_PackageInfo;
@property (nonatomic, strong) NSDictionary *dic_UserInfo;
@property (nonatomic, strong) NSTimer *tm_Time;
@property (nonatomic, strong) UIButton *btn_LeftBarItem;
@property (nonatomic, strong) UIButton *btn_RightBarItem;
@property (nonatomic, strong) QuestionListTitleView *v_Title;
@property (nonatomic, strong) QuestionListCell *questionListCell;


@property (nonatomic, strong) AnswerTitleCell *v_AnswerTitleCell;
@property (nonatomic, strong) Answer6Cell *v_Answer6Cell;
@property (nonatomic, strong) AnswerDiscripCell *v_AnswerDiscripCell;
@property (nonatomic, strong) AnswerSubjectiveCell *v_AnswerSubjectiveCell;
@property (nonatomic, strong) AnswerPrintNumber2Cell *v_AnswerPrintNumber2Cell;
@property (nonatomic, strong) AnswerPrintSubjectCell *v_AnswerPrintSubjectCell;


@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
//@property (nonatomic, weak) IBOutlet UIButton *btn_Menu;
//@property (nonatomic, weak) IBOutlet AnswerView *v_Answer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerHeight;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerBottom;
@property (nonatomic, weak) IBOutlet UITableView *tbv_Answer;

//정답출력
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerPrintHeight;
@property (nonatomic, weak) IBOutlet UITableView *tbv_AnswerPrint;

//문제풀이 뷰
@property (nonatomic, weak) IBOutlet UIView *v_Discription;
@property (nonatomic, weak) IBOutlet UIButton *btn_Discription;


@property (nonatomic, weak) IBOutlet UIView *v_Navi;

@property (nonatomic, strong) PauseViewController *vc_PauseViewController;



@property (nonatomic, strong) NSString *str_AudioBody;

@property (nonatomic, strong) NSDictionary *dic_CurrentQuestion;
@property (nonatomic, strong) NSDictionary *dic_ExamUserInfo;
@property (nonatomic, strong) NSMutableArray *ar_Question;

////////////////////
@property (nonatomic, strong) NSDictionary *dic_AudioInfo;
@property (nonatomic, strong) UIView *v_Number;
//네비
@property (nonatomic, weak) IBOutlet UIView *v_Timer;
@property (nonatomic, weak) IBOutlet UILabel *lb_QCurrentCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_QTotalCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_QTitle;
@property (nonatomic, weak) IBOutlet UIButton *btn_Time;
@property (nonatomic, weak) IBOutlet UIButton *btn_SideMenu;
@property (nonatomic, weak) IBOutlet UILabel *lb_PauseQCurrentCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_PauseQTotalCnt;
//
@property (nonatomic, weak) IBOutlet QuestionBottomView *v_Bottom;
@property (nonatomic, weak) IBOutlet UIButton *btn_Menu;
@property (nonatomic, weak) IBOutlet UIButton *btn_Star;
@property (nonatomic, weak) IBOutlet UIButton *btn_Comment;
@property (nonatomic, weak) IBOutlet UIButton *btn_Share;
@property (nonatomic, weak) IBOutlet UIView *v_Answer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerBottom;
@property (nonatomic, weak) IBOutlet UIButton *btn_Correct;
@property (nonatomic, weak) IBOutlet UIButton *btn_MyCorrect;
@property (nonatomic, weak) IBOutlet UIView *v_Correct;
@property (nonatomic, weak) IBOutlet UIView *v_Pause;
@property (nonatomic, weak) IBOutlet UIView *v_PauseTime;
@property (nonatomic, weak) IBOutlet UIButton *btn_PauseTime;
@property (nonatomic, weak) IBOutlet UILabel *lb_MultiAnswer;

@property (nonatomic, weak) IBOutlet UIView *v_AudioContainer;
@property (nonatomic, strong) AudioView *v_Audio;

@property (nonatomic, weak) IBOutlet UIImageView *iv_Star;
@property (nonatomic, weak) IBOutlet PageControllerView4 *v_PageControllerView4;
@property (nonatomic, weak) IBOutlet PageControllerView2 *v_PageControllerView2;
////////////////////


//주관식
@property (nonatomic, weak) IBOutlet UITextField *tf_NonNumberAnswer1;
@property (nonatomic, weak) IBOutlet UITextField *tf_NonNumberAnswer2;
@property (nonatomic, weak) IBOutlet UIImageView *iv_NonNumberStatus;
@property (nonatomic, weak) IBOutlet UILabel *lb_StringMyCorrent;
@property (nonatomic, weak) IBOutlet UILabel *lb_StringCorrent;

@property (nonatomic, weak) IBOutlet UIView *v_AnswerNonNumber;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerNonNumberBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerNonNumberCheckWidth1;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerNonNumberCheckWidth2;

@property (nonatomic, strong) NSMutableArray *arM_Audios;



///////////////
//@property (nonatomic, weak) IBOutlet UIButton *btn_Letf;
//@property (nonatomic, weak) IBOutlet UIButton *btn_Right;

@property (nonatomic, strong) NSTimer *tm_Arrow;
@property (nonatomic, weak) IBOutlet UIView *v_Left;
@property (nonatomic, weak) IBOutlet UIView *v_Right;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_LeftArrowLeading;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_RightArrowTail;

@end

@implementation QuestionListSwipeViewController

- (void)stopAllContents
{
    if( self.vc_Movie )
    {
        [self.vc_Movie.moviePlayer stop];
        self.vc_Movie = nil;
    }
    
    if( self.v_Audio.player && isStopAudio )
    {
        for( NSInteger i = 0; i < self.arM_Audios.count; i++ )
        {
            AudioView *tmp_Audio = [self.arM_Audios objectAtIndex:i];
            [tmp_Audio.player seekToTime:CMTimeMake(0, 1)];
            [tmp_Audio.player pause];
        }
        
        [self.arM_Audios removeAllObjects];
        
        [self.v_Audio stop];
        self.v_Audio.player = nil;
    }
    
    if( self.playerView )
    {
        [self.playerView stopVideo];
        self.playerView = nil;
    }
}

- (void)prevSwipeGesture:(UISwipeGestureRecognizer *)gesture;
{
    //이전
    if( nNaviNowCnt <= 1 )
    {
        [self.navigationController.view makeToast:@"첫 문제 입니다" withPosition:kPositionCenter];
        return;
    }

    [self moveToPrevPage:str_CurrentExamNo];
}

- (void)moveToPrevPage:(NSString *)aIdx
{
    [self stopAllContents];
    [self.v_Bottom deallocBottomView];
    
//    NSMutableArray *arM_Tmp = [self.vc_Parent.childViewControllers mutableCopy];
//    for( NSInteger i = 1; i < arM_Tmp.count; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"backNoti"
                                                  object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"showNormalQuestion"
//                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updateTimer"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showSideMenu"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showPause"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"removePause"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"QuesionBack"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"wrongCheckSelected"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showNormalQuestion"
                                                  object:nil];

    QuestionListSwipeViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionListSwipeViewController"];
    vc.vc_Parent = self.vc_Parent;
//    vc.str_Idx = self.str_Idx;
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_Idx = self.str_Idx;
    }

    if( self.isWrong || self.isStar )
    {
        vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [aIdx integerValue] - 1 ];
    }
    else
    {
        vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] - 1];
    }
    vc.str_SortType = self.str_SortType;
    vc.Prev = YES;
    vc.str_ChannelId = self.str_ChannelId;
    vc.isWrong = self.isWrong;
    vc.isStar = self.isStar;
    vc.str_SubjectName = self.str_SubjectName;
    vc.str_SubjectTotalCount = self.str_SubjectTotalCount;

    if( self.isWrong || self.isStar )
    {
        [self.vc_Parent showQuesionVc:vc];
    }
    else
    {
        CATransition* transition = [CATransition animation];
        transition.duration = .7f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        //    transition.subtype = kCATransitionFromRight;
        [self.view.layer addAnimation:transition forKey:nil];
        [self.view endEditing:YES];
        [self.vc_Parent addChildViewController:vc];
        [self addConstraintsForViewController:vc];
    }
}

- (void)nextSwipeGesture:(UISwipeGestureRecognizer *)gesture;
{
    //다음
    if( nNaviNowCnt >= nNaviTotalCnt )
    {
        [self.navigationController.view makeToast:@"마지막 문제 입니다" withPosition:kPositionCenter];
        return;
    }

    [self moveToNextPage:str_CurrentExamNo];
}

- (void)moveToNextPage:(NSString *)aIdx
{
    [self stopAllContents];
    [self.v_Bottom deallocBottomView];
    
//    NSMutableArray *arM_Tmp = [self.vc_Parent.childViewControllers mutableCopy];
//    for( NSInteger i = 1; i < arM_Tmp.count; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"backNoti"
                                                  object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"showNormalQuestion"
//                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updateTimer"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showSideMenu"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showPause"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"removePause"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"QuesionBack"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"wrongCheckSelected"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showNormalQuestion"
                                                  object:nil];

    QuestionListSwipeViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionListSwipeViewController"];
    vc.vc_Parent = self.vc_Parent;
//    vc.str_Idx = self.str_Idx;
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_Idx = self.str_Idx;
    }

    
    if( self.isWrong || self.isStar )
    {
        vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [aIdx integerValue] + 1 ];
    }
    else
    {
        vc.str_StartIdx = aIdx;
    }
    vc.str_SortType = self.str_SortType;
    vc.Prev = NO;
    vc.str_ChannelId = self.str_ChannelId;
    vc.isWrong = self.isWrong;
    vc.isStar = self.isStar;
    vc.str_SubjectName = self.str_SubjectName;
    vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
    
    if( self.isWrong || self.isStar )
    {
        [self.vc_Parent showQuesionVc:vc];
    }
    else
    {
        CATransition* transition = [CATransition animation];
        transition.duration = .7f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        //    transition.subtype = kCATransitionFromRight;
        [self.view.layer addAnimation:transition forKey:nil];
        [self.view endEditing:YES];
        [self.vc_Parent addChildViewController:vc];
        [self addConstraintsForViewController:vc];
    }
}

- (void)moveToPage:(NSString *)aIdx
{
    [self stopAllContents];
    
//    NSMutableArray *arM_Tmp = [self.vc_Parent.childViewControllers mutableCopy];
//    for( NSInteger i = 1; i < arM_Tmp.count; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"backNoti"
                                                  object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"showNormalQuestion"
//                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updateTimer"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showSideMenu"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showPause"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"removePause"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"QuesionBack"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"wrongCheckSelected"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showNormalQuestion"
                                                  object:nil];
    
//    [self removeFromParentViewController];
    
    QuestionListSwipeViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionListSwipeViewController"];
    vc.vc_Parent = self.vc_Parent;
//    vc.str_Idx = self.str_Idx;
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_Idx = self.str_Idx;
    }

    vc.str_StartIdx = aIdx;
    vc.str_SortType = self.str_SortType;
    vc.Prev = NO;
    vc.str_ChannelId = self.str_ChannelId;
    vc.isWrong = self.isWrong;
    vc.isStar = self.isStar;
    vc.str_SubjectName = self.str_SubjectName;
    vc.str_SubjectTotalCount = self.str_SubjectTotalCount;

    if( self.isWrong || self.isStar )
    {
        [self.vc_Parent showQuesionVc:vc];
    }
    else
    {
        CATransition* transition = [CATransition animation];
        transition.duration = .7f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        //    transition.subtype = kCATransitionFromRight;
        [self.view.layer addAnimation:transition forKey:nil];
        [self.view endEditing:YES];
        [self.vc_Parent addChildViewController:vc];
        [self addConstraintsForViewController:vc];
    }
}

- (void)onViewAlpha
{
    self.view.alpha = YES;
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [self addConstraintsForViewController:toViewController];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
    }];
}

- (void)addConstraintsForViewController:(UIViewController *)viewController
{
    UIView *containerView = self.vc_Parent.view;
    UIView *childView = viewController.view;
    [childView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [containerView addSubview:childView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(childView);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
}







- (void)initNaviBar
{
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"F8F8F8"]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    //오른쪽 버튼들 (타이머, 카운트)
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionListTitleView" owner:self options:nil];
    self.v_Title = [topLevelObjects objectAtIndex:0];
        
    [self.v_Title.btn_Back addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.v_Title];
    
    //    self.tm_Time = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onUpdateTime) userInfo:nil repeats:YES];
    //    [[NSRunLoop mainRunLoop] addTimer:self.tm_Time forMode:NSRunLoopCommonModes];  //메인스레드에 돌리면 터치를 잡고 있을때 어는 현상이 있어서 스레드 분기시킴
    
    
    [AMPopTip appearance].font = [UIFont fontWithName:@"Avenir-Medium" size:12];
    
    //    __weak __typeof(&*self)weakSelf = self;
    
    self.popTip = [AMPopTip popTip];
    self.popTip.edgeMargin = 5;
    self.popTip.offset = 2;
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.animationIn = 0;
    self.popTip.animationOut = 0;
    self.popTip.tapHandler = ^{
        NSLog(@"Tap!");
        //        [weakSelf.popTip hide];
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };
    
    nCurrentSection = -1;
}

//- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
//{
////    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)viewDidLayoutSubviews
{
    [self rounding:self.v_Answer6Cell.btn1];
    [self rounding:self.v_Answer6Cell.btn2];
    [self rounding:self.v_Answer6Cell.btn3];
    [self rounding:self.v_Answer6Cell.btn4];
    [self rounding:self.v_Answer6Cell.btn5];
    [self rounding:self.v_Answer6Cell.btn6];

    CGRect frame = self.v_Title.frame;
    frame.size.width = self.view.bounds.size.width - 30;
    self.v_Title.frame = frame;
}

//- (void)onUpdateTime
//{
//    nTime++;
//
//    NSInteger nSecond = nTime % 60;
//    NSInteger nMinute = nTime / 60;
//    [self.v_Title.btn_Time setTitle:[NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond] forState:UIControlStateNormal];
//}

- (void)onBackNoti
{
    if( isBackOk == NO )
    {
        isBackOk = YES;
        
//        [self goBack:nil];
        [self.navigationController popViewControllerAnimated:YES];
        [self performSelector:@selector(onBackStatusChange) withObject:nil afterDelay:0.3f];
    }
}

- (void)onBackStatusChange
{
    isBackOk = NO;
}

- (void)onShowNormalQuestion:(NSNotification *)noti
{
    return;
    
    [MBProgressHUD show];
    
    NSDictionary *obj = noti.object;
    NSDictionary *resulte = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"resulte"]];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithDictionary:[obj objectForKey:@"params"]];
    self.str_StartIdx = [obj objectForKey:@"startIdx"];
    [self showWrongViewing:resulte withParam:dicM_Params withIdx:self.str_StartIdx];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( arM_Vc == nil )
    {
        arM_Vc = [NSMutableArray array];
    }
    
    isFirst = YES;
    
    self.arM_Audios = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    
    //    self.view.alpha = NO;
//    self.navigationController.navigationBarHidden = NO;
    
    //    [self initNaviWithTitle:@"토팅" withLeftItem:[self leftBackMenuBarButtonItem] withRightItem:[self rightBookMarkItem]];
    
    //히든을 안하면 레이아웃이 일그러짐 예전에 이거 숨겼는데.. 이유가 있을텐데 왜 일까?
    self.navigationController.navigationBarHidden = YES;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowNormalQuestion:) name:@"showNormalQuestion" object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"WrongNonCheckNoti" object:nil];
    
    [self.v_Bottom initConstant];
    
    
    
    self.tf_NonNumberAnswer1.layer.cornerRadius = self.tf_NonNumberAnswer2.layer.cornerRadius = 5.f;
    self.tf_NonNumberAnswer1.layer.borderWidth = self.tf_NonNumberAnswer2.layer.borderWidth = 1.f;
    self.tf_NonNumberAnswer1.layer.borderColor = self.tf_NonNumberAnswer2.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
    
    [self.tf_NonNumberAnswer1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.tf_NonNumberAnswer2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.tf_NonNumberAnswer1 setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_NonNumberAnswer1.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_NonNumberAnswer1.frame.size.height)];
    
    [self.tf_NonNumberAnswer2 setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_NonNumberAnswer2.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_NonNumberAnswer2.frame.size.height)];
    
    self.tf_NonNumberAnswer1.attributedText = self.tf_NonNumberAnswer2.attributedText = nil;
    self.tf_NonNumberAnswer1.text = self.tf_NonNumberAnswer2.text = @"";

    self.iv_NonNumberStatus.layer.cornerRadius = 4.f;
    self.iv_NonNumberStatus.layer.borderWidth = 1.f;
    self.iv_NonNumberStatus.layer.borderColor = [UIColor blackColor].CGColor;

    [self.btn_Correct setBackgroundColor:[UIColor whiteColor]];
    [self.btn_Correct setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
    [self.btn_MyCorrect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.btn_Correct.layer.cornerRadius = self.btn_Correct.frame.size.width / 2;
    self.btn_Correct.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    self.btn_Correct.layer.borderWidth = 1.f;

    self.btn_MyCorrect.layer.cornerRadius = self.btn_MyCorrect.frame.size.width / 2;
    self.btn_MyCorrect.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btn_MyCorrect.layer.borderWidth = 1.f;

    self.v_Bottom.isNavi = YES;
    
    self.btn_Menu.hidden = YES;
    self.v_Navi.hidden = YES;
    self.tbv_List.hidden = YES;
    
    self.btn_Discription.layer.cornerRadius = 8.f;
    self.btn_Discription.layer.borderColor = kMainColor.CGColor;
    self.btn_Discription.layer.borderWidth = 1.f;
    
    self.v_Timer.layer.cornerRadius = 20.f;
    self.v_Timer.layer.borderWidth = 1.f;
    self.v_Timer.layer.borderColor = [UIColor lightGrayColor].CGColor;

    self.v_PauseTime.layer.cornerRadius = 20.f;
    self.v_PauseTime.layer.borderWidth = 1.f;
    self.v_PauseTime.layer.borderColor = [UIColor whiteColor].CGColor;

    self.vc_PauseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PauseViewController"];

    //    nTime = 0;
    nCellCount = 1;
//    [self initNaviBar];
//    self.navigationController.navigationBarHidden = YES;
    
    UISwipeGestureRecognizer *nextSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextSwipeGesture:)];
    nextSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;  //다음
    [self.view addGestureRecognizer:nextSwipeRecognizer];
    
    UISwipeGestureRecognizer *prevSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(prevSwipeGesture:)];
    prevSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;  //이전
    [self.view addGestureRecognizer:prevSwipeRecognizer];
    
    //    UIView *view = view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f)];
    //    view.backgroundColor = kMainRedColor;
    
    /* Library code */
    //    self.shyNavBarManager.scrollView = self.tbv_List;
    /* Can then be remove by setting the ExtensionView to nil */
    //    [self.shyNavBarManager setExtensionView:view];
    
    self.dicM_CellHeight = [NSMutableDictionary dictionary];
    
    self.questionListCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([QuestionListCell class])];
    self.v_Answer6Cell = [self.tbv_Answer dequeueReusableCellWithIdentifier:NSStringFromClass([Answer6Cell class])];
    self.v_AnswerTitleCell = [self.tbv_Answer dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerTitleCell class])];
    self.v_AnswerSubjectiveCell = [self.tbv_Answer dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerSubjectiveCell class])];
    self.v_AnswerPrintNumber2Cell = [self.tbv_AnswerPrint dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerPrintNumber2Cell class])];
    self.v_AnswerPrintSubjectCell = [self.tbv_AnswerPrint dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerPrintSubjectCell class])];
    self.v_AnswerDiscripCell = [self.tbv_Answer dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerDiscripCell class])];
    
//    if( self.isPdf )
//    {
//        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString  *documentsDirectory = [paths objectAtIndex:0];
//
//        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
//        [urlData writeToFile:filePath atomically:YES];
//
//        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
//        document.isLocalPDf = YES;
//        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
//        {
//            [Common setPdfDocument:document];
//
//            ReaderViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
//            self.navigationController.navigationBarHidden = YES;
//            [self.navigationController pushViewController:vc animated:NO];
//        }
//
//
////        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
////        NSString  *documentsDirectory = [paths objectAtIndex:0];
////        
////        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
////        [urlData writeToFile:filePath atomically:YES];
////        
////        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
////        document.isLocalPDf = YES;
////        
////        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
////        {
////            [Common setPdfDocument:document];
////            
////            ReaderViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
////            self.navigationController.navigationBarHidden = YES;
////            vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
////            vc.vc_Parent = self.vc_Parent;
////            vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
////            vc.str_QTitle = strM_BackTitle;
////            vc.dicM_Parameter = dicM_Params;
////            vc.str_Idx = self.str_Idx;
////            vc.str_StartIdx = self.str_StartIdx;
////            vc.str_Prefix = self.str_ImagePreFix;
////            [vc setDocument:document];
////            //                                                                        ReaderViewController *vc = [[ReaderViewController alloc] initWithReaderDocument:document];
////            //                    vc.isViewMode = YES;
////            //                    vc.dic_Info = nil;
////            ////                    vc.ar_Question = ar;    //이건 문제 정보의 배열
////            //                    vc.delegate = self; // Set the ReaderViewController delegate to self
////            //
////            //                    NSMutableDictionary *dicM_SchoolInfo = [NSMutableDictionary dictionary];
////            //                    [dicM_SchoolInfo setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"targetSchoolIdStr"] integerValue]] forKey:@"targetSchoolIdStr"];
////            //                    [dicM_SchoolInfo setObject:[dic objectForKey_YM:@"targetSchoolIdStr"] forKey:@"schoolGrade"];
////            //
////            //                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
////            //                    vc.str_Title = [dic objectForKey:@"e_title"];
////            //                    vc.str_SubTitle = [dic objectForKey:@"subjectName"];
////            //                    vc.dic_School = dicM_SchoolInfo;
////            //                    vc.nSchoolLevel = [[dic objectForKey:@"personGrade"] integerValue];
////            //                    vc.isNew = YES;
////            
////            vc.view.backgroundColor = [UIColor whiteColor];
////            //                                                                        [self.view addSubview:vc.view];
////            [self.navigationController pushViewController:vc animated:NO];
//    }
//    else
//    {
//        [self updateList];
//    }
    
    self.tm_Arrow = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(onHideArrow) userInfo:nil repeats:NO];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTap];

//    [self.tm_Arrow fire];
//    [[NSRunLoop mainRunLoop] addTimer:self.tm_Arrow forMode:NSRunLoopCommonModes];  //메인스레드에 돌리면 터치를 잡고 있을때 어는 현상이 있어서 스레드 분기시킴

    
    self.v_Left.hidden = self.v_Right.hidden = YES;
//    self.v_Left.layer.cornerRadius = 20.f;
//    self.v_Right.layer.cornerRadius = 20.f;
    self.v_Left.layer.cornerRadius = self.v_Right.layer.cornerRadius = 8.f;
//    self.v_Left.clipsToBounds = self.v_Right.clipsToBounds = YES;
    
    if( self.isWrong )
    {
        [self updateWrongList];
    }
    else if( self.isStar )
    {
        [self updateWrongList];
    }
    else
    {
        NSString *str_NormalQKey = [NSString stringWithFormat:@"NormalQuestion_%@",
                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        
        NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
        NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
        NSDictionary *dic = [dicM_NormalQ objectForKey:[NSString stringWithFormat:@"%@_%@", self.str_Idx, self.str_StartIdx]];
        if( dic )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                self.str_Idx, @"examId",
                                                //                                            @"1770", @"examId",
                                                @"testing", @"viewMode",   //풀기 상태 [testing-문제풀기, scoring-문제리뷰]
                                                @"", @"testerId",   //답안지 ID
                                                //                                            @"", @"firstExamNo",   //화면에 표시된 첫 문제 번호
                                                //                                            self.str_StartIdx, @"lastExamNo",    //화면에 표시된 마지막 문제 번호
                                                //                                            @"next", @"scrollType",
                                                self.str_SortType ? self.str_SortType : @"all", @"questionType", //문제 형식 [all - 전체, inCorrectQuestion - 틀린문제, myStarQuestion - 내가 별표 한 문제, solveQuestion - 푼문제, nonSolveQuestion - 안푼 문제, manyQNAQuestion - 질문이 달린 문제]
                                                @"package", @"examMode", //문제 유형 [package - 일반문제, category - 단원문제]
                                                @"1", @"limitCount",
                                                //                                            self.isNew ? @"new" : @"solve", @"solveMode",
                                                @"solve", @"solveMode",
                                                //                                            @"pdfExam", @"examType",
                                                nil];
            
            if( self.Prev )
            {
                [dicM_Params setObject:@"" forKey:@"lastExamNo"];
                
                [dicM_Params setObject:self.str_StartIdx forKey:@"firstExamNo"];
                [dicM_Params setObject:@"pre" forKey:@"scrollType"];
            }
            else
            {
                [dicM_Params setObject:@"" forKey:@"firstExamNo"];
                
                [dicM_Params setObject:self.str_StartIdx forKey:@"lastExamNo"];
                [dicM_Params setObject:@"next" forKey:@"scrollType"];
            }
            
            if( self.str_LowPer )
            {
                [dicM_Params setObject:self.str_LowPer forKey:@"lowPercent"];
            }
            
            //        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            //                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
            //                                            [Util getUUID], @"uuid",
            //                                            self.str_Idx, @"examId",
            //                                            self.str_StartIdx, @"questionId",   //풀기 상태 [testing-문제풀기, scoring-문제리뷰]
            //                                            nil];
            
            
            if( self.isPdf )
            {
                //            [dicM_Params removeObjectForKey:@"viewMode"];
                //            [dicM_Params removeObjectForKey:@"questionType"];
                //            [dicM_Params removeObjectForKey:@"examMode"];
                //            [dicM_Params removeObjectForKey:@"limitCount"];
                //            [dicM_Params removeObjectForKey:@"solveMode"];
                [dicM_Params removeObjectForKey:@"lastExamNo"];
                [dicM_Params removeObjectForKey:@"firstExamNo"];
                //            [dicM_Params removeObjectForKey:@"scrollType"];
                //            [dicM_Params removeObjectForKey:@"lowPercent"];
                [dicM_Params setObject:@"pdfExam" forKey:@"examType"];
                [dicM_Params setObject:@"1000" forKey:@"limitCount"];
                [dicM_Params setObject:@"1" forKey:@"pdfPage"];
                //            [dicM_Params setObject:@"solve" forKey:@"solveMode"];
                
                self.v_Navi.hidden = YES;
                self.tbv_List.hidden = YES;
                
                self.v_Bottom.hidden = YES;
                self.v_Answer.hidden = YES;
                self.v_AnswerNonNumber.hidden = YES;
                
            }
            else
            {
                self.v_Navi.hidden = NO;
                self.tbv_List.hidden = NO;
                
                self.v_Bottom.hidden = NO;
                self.v_Answer.hidden = NO;
                self.v_AnswerNonNumber.hidden = NO;
                
            }

            [self performSelector:@selector(onLocalLoad:) withObject:@{@"dic":dic, @"dicM_Params":dicM_Params} afterDelay:0.1f];


//            [self setData:dic withParam:dicM_Params];
        }
        else
        {
            [self updateList];
        }
    }
    

    [self.btn_Time setTitle:@"00:00" forState:UIControlStateNormal];
    [self.btn_PauseTime setTitle:@"00:00" forState:UIControlStateNormal];
    
//    self.v_Bottom.lc_BgTop
    self.lc_AnswerNonNumberBottom.constant = -250.f;
    self.lc_AnswerBottom.constant = -250;
    
    
    
//    self.lb_StringCorrent.layer.borderWidth = 1.f;
//    self.lb_StringCorrent.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //맞은
//    self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"4388FA"];

    
    //틀린
//    self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];

    
}

- (void)onLocalLoad:(NSDictionary *)param
{
    NSDictionary *dic = [param objectForKey:@"dic"];
    NSMutableDictionary *dicM_Params = [param objectForKey:@"dicM_Params"];
    
    [self setData:dic withParam:dicM_Params];
    
    [self updatePreLoad:dicM_Params];
}

- (void)singleTap:(UIGestureRecognizer *)gestureRecognizer
{ 
    if( self.lc_LeftArrowLeading.constant < 0 )
    {
        self.tm_Arrow = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(onHideArrow) userInfo:nil repeats:NO];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            if( nNaviNowCnt >= nNaviTotalCnt )
            {
                //마지막 문제일 경우
                self.lc_LeftArrowLeading.constant = 10.f;
                self.lc_RightArrowTail.constant = -60.f;
            }
            else
            {
                self.lc_LeftArrowLeading.constant = 10.f;
                self.lc_RightArrowTail.constant = 10.f;
            }
            
            [self.view layoutIfNeeded];
        }];
    }
    else
    {
        [self onHideArrow];
    }
}

- (void)onHideArrow
{
    [self.tm_Arrow invalidate];
    self.tm_Arrow = nil;
    
    [UIView animateWithDuration:0.3f animations:^{
       
        self.lc_LeftArrowLeading.constant = -60.f;
        self.lc_RightArrowTail.constant = -60.f;
        [self.view layoutIfNeeded];
    }];
}

- (void)updateWrongList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_StartIdx, @"examNo",
                                        @"1", @"limitCount",
                                        self.str_SubjectName, @"subjectName",
                                        @"0", @"schoolGrade",
                                        @"0", @"personGrade",
                                        nil];

    __weak __typeof(&*self)weakSelf = self;
    
    NSString *str_Path = @"";
    if( self.isWrong )
    {
        str_Path = @"v1/get/my/incorrect/question/list";
    }
    else
    {
        str_Path = @"v1/get/my/star/question/list";
    }
    
//    NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
//    NSString *str_Key = [NSString stringWithFormat:@"%ld_%@_%@", nMyId, self.str_SubjectName, self.str_StartIdx];
//    id data = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
//    if( data )
//    {
//        NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        [self showWrongViewing:dic withParam:dicM_Params withIdx:self.str_StartIdx];
//        return;
//    }

    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
     //        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            //로컬 저장
//                                            NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
//                                            NSString *str_Key = [NSString stringWithFormat:@"%ld_%@_%@", nMyId, self.str_SubjectName, self.str_StartIdx];
//                                            
//                                            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resulte];
//                                            [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_Key];
//                                            [[NSUserDefaults standardUserDefaults] synchronize];

                                            [weakSelf showWrongViewing:resulte withParam:dicM_Params withIdx:self.str_StartIdx];
                                        }
                                    }];
}

- (void)showWrongViewing:(NSDictionary *)resulte withParam:(NSMutableDictionary *)dicM_Params withIdx:(NSString *)aIdx
{
//    self.view.alpha = NO;
    
    str_CurrentExamNo = self.str_StartIdx;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"resulte : %@", resulte);
    
    NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
    if( nCode == 200 )
    {
        //성공
        str_UserThumbUrl = [resulte objectForKey:@"userThumbnail"];
        self.dic_UserInfo = [resulte objectForKey:@"examUserInfo"];
        self.dic_PackageInfo = [resulte objectForKey:@"examPackageInfo"];
        
        self.str_ImagePreFix = [resulte objectForKey:@"img_prefix"];
        
        if( self.isWrong )
        {
            self.lb_QTitle.text = @" 오답 리스트에서 삭제";
        }
        else
        {
            self.lb_QTitle.text = @" 별표 리스트에서 삭제";
        }
        
        NSInteger nUserProgress = [[self.dic_UserInfo objectForKey:@"u_progress"] integerValue];
        nQuestionCount = [[self.dic_PackageInfo objectForKey:@"questionCount"] integerValue];
        
        BOOL isFirstLoad = NO;
        if( self.arM_List == nil )
        {
            isFirstLoad = YES;
            
            NSInteger nTime = [[self.dic_UserInfo objectForKey:@"examLapTime"] integerValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNaviTimer" object:[NSNumber numberWithInteger:nTime/1000]];
        }
        
        self.isPdf = NO;
        self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
        if( self.arM_List.count > 0 )
        {
            NSDictionary *dic_QuestionInfos = [self.arM_List firstObject];
            self.dic_CurrentQuestion = [self.arM_List firstObject];
            //                                                    self.str_Idx = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"examId"]];
            [self updateAnswerView];
            correctAnswerCount = [[self.dic_CurrentQuestion objectForKey:@"correctAnswerCount"] integerValue];
            self.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
            self.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
            
            NSInteger nQnaCnt = [[dic_QuestionInfos objectForKey:@"explainCount"] integerValue] + [[dic_QuestionInfos objectForKey:@"qnaCount"] integerValue];
            
            [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[dic_QuestionInfos objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
            
            if( self.isStar )
            {
                self.btn_Star.selected = YES;
            }
            
            [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
            NSArray *ar_Tmp = [dic_QuestionInfos objectForKey:@"examQuestionInfos"];
            if( ar_Tmp.count > 0 )
            {
                NSDictionary *dic = [ar_Tmp firstObject];
                if( [[dic objectForKey:@"questionType"] isEqualToString:@"pdf"] )
                {
                    self.isPdf = YES;
                    
                    NSString *str_Body = [dic_QuestionInfos objectForKey:@"pdfUrl"];
                    NSArray *ar_Tmp = [str_Body componentsSeparatedByString:@"/"];
                    NSString *str_FileName = [ar_Tmp lastObject];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                    if( fileExists )
                    {
                        NSLog(@"IN IN IN IN IN IN IN IN IN IN IN IN IN IN IN IN");
                        //파일을 가지고 있으면 바로 띄움
                        [self showPdfVC:filePath withParam:dicM_Params withResulte:resulte];
                    }
                    else
                    {
                        NSLog(@"OUT OUT OUT OUT OUT OUT OUT OUT OUT OUT OUT OUT OUT");
                        //가지고 있지 않으면 로컬에 저장 후 띄움
                        NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
                        NSURL  *url = [NSURL URLWithString:str_Url];
                        NSData *urlData = [NSData dataWithContentsOfURL:url];
                        if ( urlData )
                        {
                            //                                                                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            //                                                                        NSString *documentsDirectory = [paths objectAtIndex:0];
                            //
                            //                                                                        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
                            [urlData writeToFile:filePath atomically:YES];
                            
                            [self showPdfVC:filePath withParam:dicM_Params withResulte:resulte];
                        }
                        else
                        {
                            [self.navigationController.view makeToast:@"PDF 파일을 찾지 못했습니다" withPosition:kPositionCenter];
                            NSLog(@"data null");
                        }
                    }
                }
            }
            
            if( self.isPdf )
            {
                self.v_Navi.hidden = YES;
                self.tbv_List.hidden = YES;
            }
            else
            {
                self.v_Navi.hidden = NO;
                self.tbv_List.hidden = NO;
            }
            
            //                                                    str_CurrentExamNo = [NSString stringWithFormat:@"%@", [dic_QuestionInfos objectForKey:@"examNo"]];
            
            //                                                    nNaviNowCnt = [[dic_QuestionInfos objectForKey:@"examNo"] integerValue];
            nNaviNowCnt = [self.str_StartIdx integerValue];
            nNaviTotalCnt = [self.str_SubjectTotalCount integerValue];
            
            self.lb_QCurrentCnt.text = self.lb_PauseQCurrentCnt.text = [NSString stringWithFormat:@"%ld", nNaviNowCnt];
            self.lb_QTotalCnt.text = self.lb_PauseQTotalCnt.text = [NSString stringWithFormat:@"%ld", nNaviTotalCnt];
            
            if( [self.str_StartIdx integerValue] <= 1 )
            {
                self.v_Left.hidden = YES;
            }
            else if( [self.str_StartIdx integerValue] >= nNaviTotalCnt )
            {
                self.v_Right.hidden = YES;
            }
            else
            {
                self.v_Left.hidden = self.v_Right.hidden = NO;
            }

            //                                                        NSString *str_Count = [NSString stringWithFormat:@"%ld/%ld", nNaviNowCnt, nNaviTotalCnt];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNaviBar" object:@{@"title":self.lb_QTitle.text, @"totlaCount":self.lb_QTotalCnt.text, @"currentCount" : self.lb_QCurrentCnt.text}];
        }
        
        if( self.isPdf == NO )
        {
            dispatch_queue_t concurrentQueue = dispatch_queue_create("com.my.backgroundQueue", NULL);
            dispatch_async(concurrentQueue, ^{

                dispatch_queue_t mainThreadQueue = dispatch_get_main_queue();
                dispatch_async(mainThreadQueue, ^{
                    
                    [self.tbv_List reloadData];
                });
            });
            
            [self setFinishCheck:self.arM_List];
        }
        //                                                    [weakSelf.tbv_Answer reloadData];
        //                                                    [weakSelf.tbv_AnswerPrint reloadData];
        
        if( isFinish && isFirstLoad )
        {
            self.tbv_AnswerPrint.hidden = NO;
            self.lc_AnswerPrintHeight.constant = self.tbv_AnswerPrint.contentSize.height;
        }
        
        //바탐뷰 관련
        self.v_Bottom.alpha = YES;
        if( self.str_Idx == nil || self.str_Idx.length <= 0 )
        {
            self.v_Bottom.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
        }
        else
        {
            self.v_Bottom.str_ExamId = self.str_Idx;
        }
        
        self.v_Bottom.str_ChannelId = self.str_ChannelId;
        [self.v_Bottom setUpdateCountBlock:^(id completeResult) {
            
            NSString *str_DCount = [completeResult objectForKey:@"dCount"];
            NSString *str_QCount = [completeResult objectForKey:@"qCount"];
            [self.btn_Comment setTitle:[NSString stringWithFormat:@"풀이 %ld", [str_DCount integerValue] + [str_QCount integerValue]] forState:UIControlStateNormal];
        }];
        [self.v_Bottom setAddCompletionBlock:^(id completeResult) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
            [vc setDismissBlock:^(id completeResult) {
                
                self.v_Bottom.str_QId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
                [self.v_Bottom updateDList];
                [self.v_Bottom updateQList];
            }];
            vc.str_Idx = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        [self.v_Bottom setCompletionBlock:^(id completeResult) {
            
            CGFloat fAlpha = [[completeResult objectForKey:@"alpha"] floatValue];
            NSLog(@"fAlpha : %f", fAlpha);
            if( fAlpha > 0 )
            {
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            }
            else
            {
                [self.navigationController setNavigationBarHidden:YES animated:NO];
            }
            self.btn_Menu.alpha = fAlpha;
            self.btn_Star.alpha = fAlpha;
            self.btn_Share.alpha = fAlpha;
            
            id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
            if( [userCorrect isEqual:[NSNull null]] || [userCorrect integerValue] == 0 )
            {
                isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
                
                //안푼문제
                if( [[completeResult objectForKey:@"IsTop"] boolValue] == NO )
                {
                    if( isNumberQuestion )
                    {
                        self.v_Correct.hidden = NO;
                        self.lb_StringCorrent.hidden = YES;
                        self.btn_MyCorrect.hidden = YES;
                        
                        NSString *str_Correct = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                        str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                        [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
                        
                        self.v_Correct.alpha = 1 - fAlpha;
                    }
                    else
                    {
                        self.v_Correct.hidden = YES;
                        self.lb_StringCorrent.hidden = NO;
                        self.lb_StringMyCorrent.hidden = YES;
                        self.lb_StringCorrent.alpha = 1 - fAlpha;
                        self.lb_StringMyCorrent.alpha = 1 - fAlpha;
                        
                        self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                    }
                }
            }
            else
            {
                isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
                
                //푼 문제
                if( isNumberQuestion )
                {
                    self.lb_StringCorrent.hidden = YES;
                    self.lb_StringMyCorrent.hidden = YES;
                    
                    self.v_Correct.hidden = NO;
                    self.lb_StringCorrent.hidden = NO;
                    self.lb_StringMyCorrent.hidden = NO;
                    //            self.btn_MyCorrect.hidden = YES;
                    
                    NSString *str_Correct = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                    str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                    [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
                    [self.btn_MyCorrect setTitle:[self.dic_CurrentQuestion objectForKey:@"user_correct"] forState:UIControlStateNormal];
                }
                else
                {
                    self.v_Correct.hidden = YES;
                    
                    self.lb_StringCorrent.hidden = NO;
                    self.lb_StringMyCorrent.hidden = NO;
                    
                    self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                    self.lb_StringMyCorrent.text = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
                    
                    if( [self.lb_StringCorrent.text isEqualToString:self.lb_StringMyCorrent.text] )
                    {
                        //맞은 문제는 내 정답 표시하지 않는다
//                        self.lb_StringMyCorrent.text = @"";
                        
                        self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"4388FA"];
                    }
                    else
                    {
                        self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];
                    }
                }
            }
            
            if( [[completeResult objectForKey:@"IsTop"] boolValue] == YES )
            {
                self.v_Correct.hidden = YES;
                self.lb_StringCorrent.hidden = YES;
                self.lb_StringMyCorrent.hidden = YES;
            }
        }];
        
        self.v_Bottom.str_QId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
        [self bottomViewInit];
        [self.v_Bottom updateDList];
        [self.v_Bottom updateQList];
        
        
        
        
        isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
        id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
        if( [userCorrect isEqual:[NSNull null]] || [userCorrect integerValue] == 0 )
        {
            
            //안푼문제
            if( isNumberQuestion )
            {
                self.v_Correct.hidden = NO;
                self.lb_StringCorrent.hidden = YES;
                self.btn_MyCorrect.hidden = YES;
                self.v_Correct.alpha = NO;
                
                self.lc_AnswerNonNumberBottom.constant = -150.f;
                self.lc_AnswerBottom.constant = 0;
            }
            else
            {
                self.v_Correct.hidden = YES;
                self.lb_StringCorrent.hidden = NO;
                self.lb_StringMyCorrent.hidden = YES;
                self.lb_StringCorrent.alpha = NO;
                self.lb_StringMyCorrent.alpha = NO;
                
                self.lc_AnswerNonNumberBottom.constant = 0.f;
                self.lc_AnswerBottom.constant = -150;
                
                self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
            }
        }
        else
        {
            //푼 문제
            if( isNumberQuestion )
            {
                self.lb_StringCorrent.hidden = YES;
                self.lb_StringMyCorrent.hidden = YES;
                
                self.v_Correct.hidden = NO;
                self.lb_StringCorrent.hidden = NO;
                self.lb_StringMyCorrent.hidden = NO;
                //            self.btn_MyCorrect.hidden = YES;
                
                NSString *str_Correct = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
                [self.btn_MyCorrect setTitle:[self.dic_CurrentQuestion objectForKey:@"user_correct"] forState:UIControlStateNormal];
                
                if( [self.btn_MyCorrect.titleLabel.text isEqualToString:self.btn_Correct.titleLabel.text] )
                {
//                    self.btn_MyCorrect.hidden = YES;
                    [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"4388FA"]];
                }
                else
                {
                    [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
                }
            }
            else
            {
                self.v_Correct.hidden = YES;
                
                self.lb_StringCorrent.hidden = NO;
                self.lb_StringMyCorrent.hidden = NO;
                
                self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                self.lb_StringMyCorrent.text = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
                
                if( [self.lb_StringCorrent.text isEqualToString:self.lb_StringMyCorrent.text] )
                {
                    //맞은 문제는 내 정답 표시하지 않는다
                    self.lb_StringMyCorrent.text = @"";
                }
            }
        }
    }
    else
    {
        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
    }
    
    [MBProgressHUD hide];
    
//    [self performSelector:@selector(onViewAlphaInterval) withObject:nil afterDelay:0.5f];
}

- (void)onViewAlphaInterval
{
    self.view.alpha = YES;
}

- (void)showPdfVC:(NSString *)filePath withParam:(NSMutableDictionary *)dicM_Params withResulte:(NSDictionary *)resulte
{
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
    document.isLocalPDf = YES;
    
    if (document != nil)
    {
        [Common setPdfDocument:document];
        
        [self performSelector:@selector(onShowIndicator) withObject:nil afterDelay:0.5f];
        
        ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
        self.navigationController.navigationBarHidden = YES;
        vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
        vc.vc_Parent = self.vc_Parent;
        vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
        vc.str_QTitle = self.lb_QTitle.text;
        vc.dicM_Parameter = dicM_Params;
//        vc.str_Idx = self.str_Idx;
        vc.str_PdfPage = self.str_PdfPage;
        vc.str_PdfNo = self.str_PdfNo;
        vc.str_SortType = self.str_SortType;
        
        if( self.str_Idx == nil || self.str_Idx.length <= 0 )
        {
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
        }
        else
        {
            vc.str_Idx = self.str_Idx;
        }

        vc.str_StartIdx = self.str_StartIdx;
        vc.str_Prefix = self.str_ImagePreFix;
        vc.nStartPdfPage = self.nStartPdfPage;
        vc.str_ChannelId = self.str_ChannelId;
        vc.str_WrongTitle = self.lb_QTitle.text;
        vc.isWrong = self.isWrong;
        vc.isStar = self.isStar;
        vc.str_SubjectName = self.str_SubjectName;
        vc.dic_Resulte = [NSDictionary dictionaryWithDictionary:resulte];
        vc.btn_WrongCheck = self.btn_Check;
        vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
        
        [vc setCompleteBlock:^(id completeResult){
            
            //pdf가 아닐시 호출 될 함수
            [self updateWrongList];
        }];
        [vc setDocument:document];
        vc.view.backgroundColor = [UIColor whiteColor];
        [self presentViewController:vc animated:NO completion:^{
            
        }];
    }
}

- (void)bottomViewInit
{
    [self.v_Bottom initFrame:self];
    
    self.btn_Menu.alpha = YES;
    self.btn_Star.alpha = YES;
    self.btn_Share.alpha = YES;
    self.v_Correct.alpha = YES;
    self.lb_StringCorrent.alpha = YES;
    self.lb_StringMyCorrent.alpha = YES;
}

- (void)onShowPause:(NSNotification *)noti
{
//    BOOL isPlaying = NO;
//    if ((self.v_Audio.player.rate != 0) && (self.v_Audio.player.error == nil))
//    {
//        // player is playing
//        isPlaying = YES;
//    }

//    [UIView animateWithDuration:0.3f animations:^{
//        
//        for( NSInteger i = 0; i < self.arM_Audios.count; i++ )
//        {
//            AudioView *tmp_Audio = [self.arM_Audios objectAtIndex:i];
//            if ((tmp_Audio.player.rate != 0) && (tmp_Audio.player.error == nil))
//            {
//                [tmp_Audio pause];
//            }
//        }

//        if( self.v_Audio && isPlaying )
//        {
//            [self.v_Audio pause];
//        }
//    }];

    [self performSelector:@selector(onPauseDataInterval) withObject:nil afterDelay:0.1f];
}

- (void)onPauseDataInterval
{
    if( self.vc_Parent.v_Title.iv_Bg.alpha == NO )
    {
        //일시정지
        self.view.userInteractionEnabled = NO;
        self.vc_Parent.v_Title.lb_CurrentCount.textColor = [UIColor whiteColor];
        self.vc_Parent.v_Title.lb_Seper.textColor = [UIColor whiteColor];
        self.vc_Parent.v_Title.lb_TotalCount.textColor = [UIColor whiteColor];
        self.vc_Parent.v_Title.btn_Time.selected = YES;
        [self.vc_Parent.v_Title.btn_Time setBackgroundColor:kMainYellowColor];
        self.vc_Parent.v_Title.btn_Time.layer.borderColor = [UIColor whiteColor].CGColor;

        [UIView animateWithDuration:0.3f animations:^{
            
            self.vc_Parent.v_Title.iv_Bg.alpha = 0.7f;
        }];
        
        for( NSInteger i = 0; i < self.arM_Audios.count; i++ )
        {
            AudioView *tmp_Audio = [self.arM_Audios objectAtIndex:i];
            if ((tmp_Audio.player.rate != 0) && (tmp_Audio.player.error == nil))
            {
                [tmp_Audio pause];
            }
        }
    }
    else
    {
        //재생
        self.view.userInteractionEnabled = YES;
        self.vc_Parent.v_Title.lb_CurrentCount.textColor = [UIColor darkGrayColor];
        self.vc_Parent.v_Title.lb_Seper.textColor = [UIColor lightGrayColor];
        self.vc_Parent.v_Title.lb_TotalCount.textColor = [UIColor lightGrayColor];
        self.vc_Parent.v_Title.btn_Time.selected = NO;
        [self.vc_Parent.v_Title.btn_Time setBackgroundColor:[UIColor whiteColor]];
        self.vc_Parent.v_Title.btn_Time.layer.borderColor = [UIColor lightGrayColor].CGColor;

        [UIView animateWithDuration:0.3f animations:^{
            
            self.vc_Parent.v_Title.iv_Bg.alpha = 0.0f;
        }];
    }
//    [self presentViewController:self.vc_PauseViewController animated:YES completion:nil];
//
//    [self.vc_PauseViewController updateDataWithTitle:self.lb_QTitle.text withStartCnt:self.lb_QCurrentCnt.text withTotalCnt:self.lb_QTotalCnt.text withTime:self.btn_Time.titleLabel.text];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPauseTimer" object:nil];
}

- (void)onRemovePause:(NSNotification *)noti
{
    BOOL isPlaying = NO;
    if ((self.v_Audio.player.rate != 0) && (self.v_Audio.player.error == nil))
    {
        // player is playing
        isPlaying = YES;
    }
    
    if( self.v_Audio && isPlaying )
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.v_Audio resume];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPauseTimer" object:nil];
}

- (void)onShowSideMenu:(NSNotification *)noti
{
    if( self.isWrong || self.isStar )
    {
        [self onShowWrongSideMenu:noti];
    }
    else
    {
        __weak __typeof(&*self)weakSelf = self;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        SideMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
        vc.str_TesterId = [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey_YM:@"testerId"]];
        vc.str_Idx = self.str_Idx;
        vc.str_StartNo = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
        [vc setCompletionBlock:^(id completeResult) {
            
            [self stopAllContents];
            
            NSDictionary *dic = [completeResult objectForKey:@"obj"];
            self.str_SortType = [completeResult objectForKey:@"type"];
            
            NSInteger nExamNo = [[dic objectForKey:@"examNo"] integerValue];
            weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo - 1];
            [weakSelf moveToPage:weakSelf.str_StartIdx];
            
            //        if( nExamNo < [weakSelf.str_StartIdx integerValue] )
            //        {
            //            //이전
            //            weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo];
            //            [weakSelf moveToPrevPage:weakSelf.str_StartIdx];
            //        }
            //        else if( nExamNo > [weakSelf.str_StartIdx integerValue] )
            //        {
            //            //다음
            //            weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo - 1];
            //            [weakSelf moveToPage:weakSelf.str_StartIdx];
            //        }
            //        else
            //        {
            //
            //        }
        }];
        
        [self presentViewController:vc animated:NO completion:^{
            
        }];
    }
}

- (void)onShowWrongSideMenu:(NSNotification *)noti
{
    __weak __typeof(&*self)weakSelf = self;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    WrongSideViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WrongSideViewController"];
    vc.str_TesterId = [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey_YM:@"testerId"]];
//    vc.str_Idx = self.str_Idx;
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_Idx = self.str_Idx;
    }

    vc.str_StartNo = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
    vc.nNowQuestionNum = [[self.dic_CurrentQuestion objectForKey:@"examNo"] integerValue];
    vc.str_SubjectName = self.str_SubjectName;
    vc.listType = self.isWrong ? kWrong : kStarQ;

    [vc setCompletionBlock:^(id completeResult) {
        
        [self stopAllContents];
        
        NSDictionary *dic = [completeResult objectForKey:@"obj"];
        self.str_SortType = [completeResult objectForKey:@"type"];
        
        NSInteger nExamNo = [[completeResult objectForKey:@"idx"] integerValue];
//        weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo];
        [weakSelf moveToPage:weakSelf.str_StartIdx];
    }];
    
    [self presentViewController:vc animated:NO completion:^{
        
    }];
}

- (void)updateTimer:(NSNotification *)noti
{
    [self.btn_Time setTitle:self.vc_Parent.v_Title.btn_Time.titleLabel.text forState:UIControlStateNormal];
    [self.btn_PauseTime setTitle:self.vc_Parent.v_Title.btn_Time.titleLabel.text forState:UIControlStateNormal];
    
    //    NSLog(@"%ld", self.vc_Parent.nTime);
}

- (void)rounding:(UIView *)view
{
    view.layer.cornerRadius = view.frame.size.width/2;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = 1.f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSMutableArray *arM_Tmp = [self.vc_Parent.childViewControllers mutableCopy];
//    for( NSInteger i = 1; i < arM_Tmp.count - 1; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }

    if( self.isWrong || self.isStar )
    {
        self.v_Left.hidden = self.v_Right.hidden = NO;
    }
    else
    {
        self.v_Left.hidden = self.v_Right.hidden = YES;
    }

    if( self.btn_Menu.alpha > 0 )
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBackNoti) name:@"backNoti" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimer:) name:@"updateTimer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowSideMenu:) name:@"showSideMenu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowPause:) name:@"showPause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemovePause:) name:@"removePause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onQuesionBack:) name:@"QuesionBack" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWrongCheckSelected:) name:@"wrongCheckSelected" object:nil];

    isStopAudio = YES;
    [self.tbv_List reloadData];
    
    isUpdateLayout = NO;
    
//    NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, self.str_AudioBody];
//    if( self.str_ImagePreFix.length > 0 && self.str_AudioBody.length > 0 )
//    {
//        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
//        self.v_Audio = [topLevelObjects objectAtIndex:0];
//        [self.v_Audio initPlayer:str_Url];
//    }

    //    if( self.arM_List )
    //    {
    //        [self.tbv_List reloadData];
    //    }
    
    //    [self.tbv_List setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MBProgressHUD hide];

    self.view.alpha = YES;
    
    [self.view bringSubviewToFront:self.v_Pause];

    if( self.btn_Menu.alpha > 0 )
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }

    if( isFirst )
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    isFirst = NO;
    //    [self.tbv_List setNeedsLayout];
 
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hide];

    //    [self.navigationController.navigationBar setBarTintColor:kMainColor];
    //    [self.navigationController.navigationBar setTranslucent:NO];
    //
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self stopAllContents];
    
    [self.tm_Arrow invalidate];
    self.tm_Arrow = nil;
    self.v_Left.hidden = self.v_Right.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"backNoti"
                                                  object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"showNormalQuestion"
//                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updateTimer"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showSideMenu"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showPause"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"removePause"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"QuesionBack"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"wrongCheckSelected"
                                                  object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    /*
     firstExamNo: 화면에 표시된 첫 문제 번호
     lastExamNo: 화면에 표시된 마지막 문제 번호
     scrollType: 문제를 더 불러오기 위한 스크롤 타입 [next - 아래로 내린 경우, 위로 올린 경우 - pre]
     questionType: 문제 형식 [all - 전체, inCorrectQuestion - 틀린문제, myStarQuestion - 내가 별표 한 문제, solveQuestion - 푼문제, nonSolveQuestion - 안푼 문제, manyQNAQuestion - 질문이 달린 문제]
     examMode: 문제 유형 [package - 일반문제, category - 단원문제]
     limitCount: 가져올 문제수
     */
    
    if( 0 )
    {
        //        [self.tbv_List reloadData];
    }
    else
    {
        __block NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                    [Util getUUID], @"uuid",
                                                    self.str_Idx, @"examId",
                                                    //                                            @"1770", @"examId",
                                                    @"testing", @"viewMode",   //풀기 상태 [testing-문제풀기, scoring-문제리뷰]
                                                    @"", @"testerId",   //답안지 ID
                                                    //                                            @"", @"firstExamNo",   //화면에 표시된 첫 문제 번호
                                                    //                                            self.str_StartIdx, @"lastExamNo",    //화면에 표시된 마지막 문제 번호
                                                    //                                            @"next", @"scrollType",
                                                    self.str_SortType ? self.str_SortType : @"all", @"questionType", //문제 형식 [all - 전체, inCorrectQuestion - 틀린문제, myStarQuestion - 내가 별표 한 문제, solveQuestion - 푼문제, nonSolveQuestion - 안푼 문제, manyQNAQuestion - 질문이 달린 문제]
                                                    @"package", @"examMode", //문제 유형 [package - 일반문제, category - 단원문제]
                                                    @"1", @"limitCount",
                                                    //                                            self.isNew ? @"new" : @"solve", @"solveMode",
                                                    @"solve", @"solveMode",
                                                    //                                            @"pdfExam", @"examType",
                                                    nil];
        
        if( self.Prev )
        {
            [dicM_Params setObject:@"" forKey:@"lastExamNo"];

            [dicM_Params setObject:self.str_StartIdx forKey:@"firstExamNo"];
            [dicM_Params setObject:@"pre" forKey:@"scrollType"];
        }
        else
        {
            [dicM_Params setObject:@"" forKey:@"firstExamNo"];

            [dicM_Params setObject:self.str_StartIdx forKey:@"lastExamNo"];
            [dicM_Params setObject:@"next" forKey:@"scrollType"];
        }
        
        if( self.str_LowPer )
        {
            [dicM_Params setObject:self.str_LowPer forKey:@"lowPercent"];
        }
        
        //        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        //                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
        //                                            [Util getUUID], @"uuid",
        //                                            self.str_Idx, @"examId",
        //                                            self.str_StartIdx, @"questionId",   //풀기 상태 [testing-문제풀기, scoring-문제리뷰]
        //                                            nil];
        
        
        if( self.isPdf )
        {
//            [dicM_Params removeObjectForKey:@"viewMode"];
//            [dicM_Params removeObjectForKey:@"questionType"];
//            [dicM_Params removeObjectForKey:@"examMode"];
//            [dicM_Params removeObjectForKey:@"limitCount"];
//            [dicM_Params removeObjectForKey:@"solveMode"];
            [dicM_Params removeObjectForKey:@"lastExamNo"];
            [dicM_Params removeObjectForKey:@"firstExamNo"];
//            [dicM_Params removeObjectForKey:@"scrollType"];
//            [dicM_Params removeObjectForKey:@"lowPercent"];
            [dicM_Params setObject:@"pdfExam" forKey:@"examType"];
            [dicM_Params setObject:@"1000" forKey:@"limitCount"];
            [dicM_Params setObject:@"1" forKey:@"pdfPage"];
//            [dicM_Params setObject:@"solve" forKey:@"solveMode"];
            
            self.v_Navi.hidden = YES;
            self.tbv_List.hidden = YES;
            
            self.v_Bottom.hidden = YES;
            self.v_Answer.hidden = YES;
            self.v_AnswerNonNumber.hidden = YES;

        }
        else
        {
            self.v_Navi.hidden = NO;
            self.tbv_List.hidden = NO;
            
            self.v_Bottom.hidden = NO;
            self.v_Answer.hidden = NO;
            self.v_AnswerNonNumber.hidden = NO;

        }
        
        
        __weak __typeof(&*self)weakSelf = self;

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
         //        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question"
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            [weakSelf setData:resulte withParam:dicM_Params];
                                            
                                            [self updatePreLoad:dicM_Params];
                                        }];
    }
}

- (void)updatePreLoad:(NSMutableDictionary *)dicM_Params
{
    //마지막 문제가 아니고 로컬에 저장된 다음 문제가 없을때
    NSInteger nLastExamNo = [[dicM_Params objectForKey:@"lastExamNo"] integerValue];
    
    NSString *str_NormalQKey = [NSString stringWithFormat:@"NormalQuestion_%@",
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    
    NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
    NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
    NSDictionary *dic = [dicM_NormalQ objectForKey:[NSString stringWithFormat:@"%@_%ld", self.str_Idx, nLastExamNo + 1]];
    
    if( nLastExamNo < nNaviTotalCnt - 1 && dic == nil )
    {
        //다음 문제 미리 로드하여 저장하기
        
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nLastExamNo + 1] forKey:@"lastExamNo"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSString *str_NormalQKey = [NSString stringWithFormat:@"NormalQuestion_%@",
                                                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                
                                                NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
                                                NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
                                                [dicM_NormalQ setObject:resulte forKey:[NSString stringWithFormat:@"%@_%ld", self.str_Idx, nLastExamNo + 1]];
                                                
                                                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM_NormalQ];
                                                [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_NormalQKey];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                            }
                                        }];
    }
}

- (void)setData:(NSDictionary *)resulte withParam:(NSMutableDictionary *)dicM_Params
{
    if( resulte )
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"resulte : %@", resulte);
        
        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
        if( nCode == 200 )
        {
            NSString *str_NormalQKey = [NSString stringWithFormat:@"NormalQuestion_%@",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            
            NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
            NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
            [dicM_NormalQ setObject:resulte forKey:[NSString stringWithFormat:@"%@_%@", self.str_Idx, self.str_StartIdx]];

            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM_NormalQ];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_NormalQKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            //성공
            str_UserThumbUrl = [resulte objectForKey:@"userThumbnail"];
            self.dic_UserInfo = [resulte objectForKey:@"examUserInfo"];
            self.dic_PackageInfo = [resulte objectForKey:@"examPackageInfo"];
            
            
            self.str_ImagePreFix = [resulte objectForKey:@"img_prefix"];
            
            NSMutableString *strM_BackTitle = [NSMutableString string];
            [strM_BackTitle appendString:[self.dic_PackageInfo objectForKey:@"subjectName"]];
            [strM_BackTitle appendString:[NSString stringWithFormat:@"(%@", [self.dic_PackageInfo objectForKey:@"schoolGrade"]]];
            NSInteger nGrade = [[self.dic_PackageInfo objectForKey:@"persongrade"] integerValue];
            if( nGrade == 0 )
            {
                [strM_BackTitle appendString:@")"];
            }
            else
            {
                [strM_BackTitle appendString:[NSString stringWithFormat:@"%ld)", nGrade]];
            }
            [strM_BackTitle appendString:[self.dic_PackageInfo objectForKey:@"examTitle"]];
            NSLog(@"%@", strM_BackTitle);
            self.lb_QTitle.text = strM_BackTitle;
            //                                                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNaviBar:) name:@"kUpdateNaviBar" object:nil];
            
            //                                                    [self.v_Title.btn_Back setTitle:strM_BackTitle forState:UIControlStateNormal];
            
            NSInteger nUserProgress = [[self.dic_UserInfo objectForKey:@"u_progress"] integerValue];
            nQuestionCount = [[self.dic_PackageInfo objectForKey:@"questionCount"] integerValue];
            //                                                    self.v_Title.lb_Count.text = [NSString stringWithFormat:@"%ld/%ld", nUserProgress, nQuestionCount];
            
            //seqExamNo/seqTotalQuestionCount
            //                                                    NSString *str_Count = [NSString stringWithFormat:@"%ld/%ld", nUserProgress, nQuestionCount];
            //                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNaviBar" object:@{@"title":strM_BackTitle, @"count":str_Count}];
            
            
            BOOL isFirstLoad = NO;
            if( self.arM_List == nil )
            {
                isFirstLoad = YES;
                
                NSInteger nTime = [[self.dic_UserInfo objectForKey:@"examLapTime"] integerValue];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNaviTimer" object:[NSNumber numberWithInteger:nTime/1000]];
                
                //                                                        NSLog(@"nTime : %ld", nTime);
                //                                                        nTime = [[self.dic_UserInfo objectForKey:@"examLapTime"] integerValue];
                //                                                        nTime = 10;
                //                                                        NSLog(@"nTime : %ld", nTime);
            }
            
            BOOL isPdf = NO;
            self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
            if( self.arM_List.count > 0 )
            {
                NSDictionary *dic_QuestionInfos = [self.arM_List firstObject];
                self.dic_CurrentQuestion = [self.arM_List firstObject];
                [self updateAnswerView];
                correctAnswerCount = [[self.dic_CurrentQuestion objectForKey:@"correctAnswerCount"] integerValue];
                if( correctAnswerCount > 1 )
                {
                    self.lb_MultiAnswer.hidden = NO;
                }
                else
                {
                    self.lb_MultiAnswer.hidden = YES;
                }
                self.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                self.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                
                NSInteger nQnaCnt = [[dic_QuestionInfos objectForKey:@"explainCount"] integerValue] + [[dic_QuestionInfos objectForKey:@"qnaCount"] integerValue];
                //                                                        [self.btn_Comment setTitle:[NSString stringWithFormat:@"풀이와 질문 %ld", nQnaCnt] forState:UIControlStateNormal];
                
                [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[dic_QuestionInfos objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
                
                [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                NSArray *ar_Tmp = [dic_QuestionInfos objectForKey:@"examQuestionInfos"];
                if( ar_Tmp.count > 0 )
                {
                    NSDictionary *dic = [ar_Tmp firstObject];
                    if( [[dic objectForKey:@"questionType"] isEqualToString:@"pdf"] )
                    {
                        isPdf = YES;
                        
                        NSString *str_Body = [dic objectForKey:@"questionBody"];
                        NSArray *ar_Tmp = [str_Body componentsSeparatedByString:@"/"];
                        NSString *str_FileName = [ar_Tmp lastObject];
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        
                        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];

                        NSString *str_ZipName = [str_FileName stringByReplacingOccurrencesOfString:@".pdf" withString:@".zip"];
                        str_ZipName = [str_ZipName stringByReplacingOccurrencesOfString:@".PDF" withString:@".zip"];
                        NSString *str_ZipFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_ZipName];

                        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:str_ZipFilePath];
                        if( fileExists )
                        {
                            //zip파일을 가지고 있으면 압축을 풀고 열어준다
                            BOOL isSuccess = [SSZipArchive unzipFileAtPath:str_ZipFilePath toDestination:documentsDirectory];
                            
                            
                            NSLog(@"IN IN IN IN IN IN IN IN IN IN IN IN IN IN IN IN");
                            //파일을 가지고 있으면 바로 띄움
                            ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
                            document.isLocalPDf = YES;
                            //                                                                    document.pageNumber = @1;
                            
                            if (document != nil)
                            {
                                [Common setPdfDocument:document];
                                
                                [self performSelector:@selector(onShowIndicator) withObject:nil afterDelay:0.5f];
                                
                                [dicM_Params removeObjectForKey:@"lastExamNo"];
                                [dicM_Params removeObjectForKey:@"firstExamNo"];
                                [dicM_Params setObject:@"pdfExam" forKey:@"examType"];
                                [dicM_Params setObject:@"1000" forKey:@"limitCount"];
                                [dicM_Params setObject:@"1" forKey:@"pdfPage"];
                                
                                ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
                                self.navigationController.navigationBarHidden = YES;
                                vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                                vc.vc_Parent = self.vc_Parent;
                                vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                                vc.str_QTitle = strM_BackTitle;
                                vc.dicM_Parameter = dicM_Params;
                                vc.str_Idx = self.str_Idx;
                                vc.str_StartIdx = self.str_StartIdx;
                                vc.str_Prefix = self.str_ImagePreFix;
                                vc.nStartPdfPage = self.nStartPdfPage;
                                vc.str_ChannelId = self.str_ChannelId;
                                //                                                                        vc.btn_WrongCheck = self.btn_Check;
                                vc.str_PdfPage = self.str_PdfPage;
                                vc.str_PdfNo = self.str_PdfNo;
                                vc.str_SortType = self.str_SortType;
                                
                                [vc setDocument:document];
                                vc.view.backgroundColor = [UIColor whiteColor];
                                [self presentViewController:vc animated:NO completion:^{
                                    
                                }];
                            }
                        }
                        else
                        {
                            NSLog(@"OUT OUT OUT OUT OUT OUT OUT OUT OUT OUT OUT OUT OUT");
                            //가지고 있지 않으면 로컬에 저장 후 띄움
                            NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
                            NSURL  *url = [NSURL URLWithString:str_Url];
                            NSData *urlData = [NSData dataWithContentsOfURL:url];
                            if ( urlData )
                            {
                                //                                                                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                //                                                                        NSString *documentsDirectory = [paths objectAtIndex:0];
                                //
                                //                                                                        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
                                [urlData writeToFile:filePath atomically:YES];
                                
                                //pdf를 zip으로 저장
                                NSString *str_ZipName = [str_FileName stringByReplacingOccurrencesOfString:@".pdf" withString:@".zip"];
                                str_ZipName = [str_ZipName stringByReplacingOccurrencesOfString:@".PDF" withString:@".zip"];
                                [SSZipArchive createZipFileAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, str_ZipName] withFilesAtPaths:@[filePath]];
                                //////////////////
                                
                                ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
                                document.isLocalPDf = YES;
                                
                                if (document != nil)
                                {
                                    [Common setPdfDocument:document];
                                    
                                    [self performSelector:@selector(onShowIndicator) withObject:nil afterDelay:0.5f];
                                    
                                    [dicM_Params removeObjectForKey:@"lastExamNo"];
                                    [dicM_Params removeObjectForKey:@"firstExamNo"];
                                    [dicM_Params setObject:@"pdfExam" forKey:@"examType"];
                                    [dicM_Params setObject:@"1000" forKey:@"limitCount"];
                                    [dicM_Params setObject:@"1" forKey:@"pdfPage"];
                                    
                                    ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
                                    self.navigationController.navigationBarHidden = YES;
                                    vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                                    vc.vc_Parent = self.vc_Parent;
                                    vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                                    vc.str_QTitle = strM_BackTitle;
                                    vc.dicM_Parameter = dicM_Params;
                                    vc.str_Idx = self.str_Idx;
                                    vc.str_StartIdx = self.str_StartIdx;
                                    vc.str_Prefix = self.str_ImagePreFix;
                                    vc.nStartPdfPage = self.nStartPdfPage;
                                    vc.str_ChannelId = self.str_ChannelId;
                                    
                                    vc.str_PdfPage = self.str_PdfPage;
                                    vc.str_PdfNo = self.str_PdfNo;
                                    vc.str_SortType = self.str_SortType;
                                    
                                    [vc setDocument:document];
                                    vc.view.backgroundColor = [UIColor whiteColor];
                                    [self presentViewController:vc animated:NO completion:^{
                                        
                                    }];
                                }
                            }
                            else
                            {
                                NSLog(@"data null");
                            }
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        //                                                                NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
                        //                                                                NSURL  *url = [NSURL URLWithString:str_Url];
                        //                                                                NSData *urlData = [NSData dataWithContentsOfURL:url];
                        //                                                                if ( urlData )
                        //                                                                {
                        //                                                                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        //                                                                    NSString *documentsDirectory = [paths objectAtIndex:0];
                        //
                        //                                                                    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
                        //                                                                    [urlData writeToFile:filePath atomically:YES];
                        //
                        //                                                                    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
                        //                                                                    document.isLocalPDf = YES;
                        //
                        //                                                                    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
                        //                                                                    {
                        //                                                                        [Common setPdfDocument:document];
                        //
                        //                                                                        [self performSelector:@selector(onShowIndicator) withObject:nil afterDelay:0.5f];
                        //
                        //                                                                        ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
                        //                                                                        self.navigationController.navigationBarHidden = YES;
                        //                                                                        vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                        //                                                                        vc.vc_Parent = self.vc_Parent;
                        //                                                                        vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                        //                                                                        vc.str_QTitle = strM_BackTitle;
                        //                                                                        vc.dicM_Parameter = dicM_Params;
                        //                                                                        vc.str_Idx = self.str_Idx;
                        //                                                                        vc.str_StartIdx = self.str_StartIdx;
                        //                                                                        vc.str_Prefix = self.str_ImagePreFix;
                        //                                                                        vc.nStartPdfPage = self.nStartPdfPage;
                        //                                                                        vc.str_ChannelId = self.str_ChannelId;
                        //                                                                        [vc setDocument:document];
                        ////                                                                        ReaderViewController *vc = [[ReaderViewController alloc] initWithReaderDocument:document];
                        //                                                                        //                    vc.isViewMode = YES;
                        //                                                                        //                    vc.dic_Info = nil;
                        //                                                                        ////                    vc.ar_Question = ar;    //이건 문제 정보의 배열
                        //                                                                        //                    vc.delegate = self; // Set the ReaderViewController delegate to self
                        //                                                                        //
                        //                                                                        //                    NSMutableDictionary *dicM_SchoolInfo = [NSMutableDictionary dictionary];
                        //                                                                        //                    [dicM_SchoolInfo setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"targetSchoolIdStr"] integerValue]] forKey:@"targetSchoolIdStr"];
                        //                                                                        //                    [dicM_SchoolInfo setObject:[dic objectForKey_YM:@"targetSchoolIdStr"] forKey:@"schoolGrade"];
                        //                                                                        //
                        //                                                                        //                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
                        //                                                                        //                    vc.str_Title = [dic objectForKey:@"e_title"];
                        //                                                                        //                    vc.str_SubTitle = [dic objectForKey:@"subjectName"];
                        //                                                                        //                    vc.dic_School = dicM_SchoolInfo;
                        //                                                                        //                    vc.nSchoolLevel = [[dic objectForKey:@"personGrade"] integerValue];
                        //                                                                        //                    vc.isNew = YES;
                        //
                        //                                                                        vc.view.backgroundColor = [UIColor whiteColor];
                        ////                                                                        [self.view addSubview:vc.view];
                        //                                                                        [self presentViewController:vc animated:NO completion:^{
                        //
                        //                                                                        }];
                        ////                                                                        [self.navigationController pushViewController:vc animated:NO];
                        //                                                                    }
                        //                                                                }
                        //                                                                else // Log an error so that we know that something went wrong
                        //                                                                {
                        //                                                                    NSLog(@"data null");
                        //                                                                }
                        
                    }
                }
                
                str_CurrentExamNo = [NSString stringWithFormat:@"%@", [dic_QuestionInfos objectForKey:@"examNo"]];
                
                nNaviNowCnt = [[dic_QuestionInfos objectForKey:@"seqExamNo"] integerValue];
                nNaviTotalCnt = [[self.dic_PackageInfo objectForKey:@"seqTotalQuestionCount"] integerValue];
                
                self.lb_QCurrentCnt.text = self.lb_PauseQCurrentCnt.text = [NSString stringWithFormat:@"%ld", nNaviNowCnt];
                self.lb_QTotalCnt.text = self.lb_PauseQTotalCnt.text = [NSString stringWithFormat:@"%ld", nNaviTotalCnt];
                
                //                                                        NSString *str_Count = [NSString stringWithFormat:@"%ld/%ld", nNaviNowCnt, nNaviTotalCnt];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNaviBar" object:@{@"title":strM_BackTitle, @"totlaCount":self.lb_QTotalCnt.text, @"currentCount" : self.lb_QCurrentCnt.text}];
            }
            
            if( isPdf == NO )
            {
                [self.tbv_List reloadData];
                [self setFinishCheck:self.arM_List];
            }
            //                                                    [self.tbv_Answer reloadData];
            //                                                    [self.tbv_AnswerPrint reloadData];
            
            if( isFinish && isFirstLoad )
            {
                self.tbv_AnswerPrint.hidden = NO;
                self.lc_AnswerPrintHeight.constant = self.tbv_AnswerPrint.contentSize.height;
            }
            
            //                                                    [self startSendBird];
            //
            //                                                    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_channel_%@", [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]]]];
            //                                                    [SendBird joinChannel:str_ChannelUrl];
            //                                                    [SendBird connect];
            //
            //                                                    [self performSelector:@selector(onJoinMessageInterval) withObject:nil afterDelay:1.f];
            
            //바탐뷰 관련
            self.v_Bottom.alpha = YES;
            self.v_Bottom.str_ExamId = self.str_Idx;
            self.v_Bottom.str_ChannelId = self.str_ChannelId;

            [self.v_Bottom setUpdateCountBlock:^(id completeResult) {
                
//                [self.btn_Comment setTitle:[NSString stringWithFormat:@"풀이와 질문 %@", completeResult] forState:UIControlStateNormal];
            }];
            [self.v_Bottom setAddCompletionBlock:^(id completeResult) {
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
                AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
                [vc setDismissBlock:^(id completeResult) {
                    
                    self.v_Bottom.str_QId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
                    [self.v_Bottom updateDList];
                    [self.v_Bottom updateQList];
                }];
                vc.str_Idx = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
                [self presentViewController:vc animated:YES completion:nil];
            }];
            [self.v_Bottom setCompletionBlock:^(id completeResult) {
                
                CGFloat fAlpha = [[completeResult objectForKey:@"alpha"] floatValue];
                NSLog(@"fAlpha : %f", fAlpha);
                if( fAlpha > 0 )
                {
                    [self.navigationController setNavigationBarHidden:NO animated:NO];
                }
                else
                {
                    [self.navigationController setNavigationBarHidden:YES animated:NO];
                }
                self.btn_Menu.alpha = fAlpha;
                self.btn_Star.alpha = fAlpha;
                self.btn_Share.alpha = fAlpha;
                
                id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
                if( [userCorrect isEqual:[NSNull null]] || [userCorrect integerValue] == 0 )
                {
                    isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
                    
                    //안푼문제
                    if( [[completeResult objectForKey:@"IsTop"] boolValue] == NO )
                    {
                        if( isNumberQuestion )
                        {
                            self.v_Correct.hidden = NO;
                            self.lb_StringCorrent.hidden = YES;
                            self.btn_MyCorrect.hidden = YES;
                            
                            NSString *str_Correct = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                            str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                            [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
                            
                            self.v_Correct.alpha = 1 - fAlpha;
                        }
                        else
                        {
                            self.v_Correct.hidden = YES;
                            self.lb_StringCorrent.hidden = NO;
                            self.lb_StringMyCorrent.hidden = YES;
                            self.lb_StringCorrent.alpha = 1 - fAlpha;
                            self.lb_StringMyCorrent.alpha = 1 - fAlpha;
                            
                            self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                        }
                    }
                }
                else
                {
                    isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
                    
                    //푼 문제
                    if( isNumberQuestion )
                    {
                        self.lb_StringCorrent.hidden = YES;
                        self.lb_StringMyCorrent.hidden = YES;
                        
                        self.v_Correct.hidden = NO;
                        self.lb_StringCorrent.hidden = NO;
                        self.lb_StringMyCorrent.hidden = NO;
                        //            self.btn_MyCorrect.hidden = YES;
                        
                        NSString *str_Correct = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                        str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                        [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
                        [self.btn_MyCorrect setTitle:[self.dic_CurrentQuestion objectForKey:@"user_correct"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        self.v_Correct.hidden = YES;
                        
                        self.lb_StringCorrent.hidden = NO;
                        self.lb_StringMyCorrent.hidden = NO;
                        
                        self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                        self.lb_StringMyCorrent.text = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
                        
                        if( [self.lb_StringCorrent.text isEqualToString:self.lb_StringMyCorrent.text] )
                        {
                            //맞은 문제는 내 정답 표시하지 않는다
                            //                                                                    self.lb_StringMyCorrent.text = @"";
                        }
                    }
                }
                
                if( [[completeResult objectForKey:@"IsTop"] boolValue] == YES )
                {
                    self.v_Correct.hidden = YES;
                    self.lb_StringCorrent.hidden = YES;
                    self.lb_StringMyCorrent.hidden = YES;
                }
            }];
            
            self.v_Bottom.str_QId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
            [self bottomViewInit];
            [self.v_Bottom updateDList];
            [self.v_Bottom updateQList];
            
            
            
            
            isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
            id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
            if( [userCorrect isEqual:[NSNull null]] || [userCorrect integerValue] == 0 )
            {
                
                //안푼문제
                if( isNumberQuestion )
                {
                    self.v_Correct.hidden = NO;
                    self.lb_StringCorrent.hidden = YES;
                    self.btn_MyCorrect.hidden = YES;
                    self.v_Correct.alpha = NO;
                    
                    self.lc_AnswerNonNumberBottom.constant = -150.f;
                    self.lc_AnswerBottom.constant = 0;
                }
                else
                {
                    self.v_Correct.hidden = YES;
                    self.lb_StringCorrent.hidden = NO;
                    self.lb_StringMyCorrent.hidden = YES;
                    self.lb_StringCorrent.alpha = NO;
                    self.lb_StringMyCorrent.alpha = NO;
                    
                    self.lc_AnswerNonNumberBottom.constant = 0.f;
                    self.lc_AnswerBottom.constant = -150;
                    
                    self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                }
            }
            else
            {
                //푼 문제
                if( isNumberQuestion )
                {
                    self.lb_StringCorrent.hidden = YES;
                    self.lb_StringMyCorrent.hidden = YES;
                    
                    self.v_Correct.hidden = NO;
                    self.lb_StringCorrent.hidden = NO;
                    self.lb_StringMyCorrent.hidden = NO;
                    //            self.btn_MyCorrect.hidden = YES;
                    
                    NSString *str_Correct = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                    str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                    [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
                    [self.btn_MyCorrect setTitle:[self.dic_CurrentQuestion objectForKey:@"user_correct"] forState:UIControlStateNormal];
                    
                    if( [self.btn_MyCorrect.titleLabel.text isEqualToString:self.btn_Correct.titleLabel.text] )
                    {
                        //                                                                self.btn_MyCorrect.hidden = YES;
                        [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"4388FA"]];
                    }
                    else
                    {
                        [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
                    }
                }
                else
                {
                    self.v_Correct.hidden = YES;
                    
                    self.lb_StringCorrent.hidden = NO;
                    self.lb_StringMyCorrent.hidden = NO;
                    
                    self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                    self.lb_StringMyCorrent.text = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
                    
                    if( [self.lb_StringCorrent.text isEqualToString:self.lb_StringMyCorrent.text] )
                    {
                        //맞은 문제는 내 정답 표시하지 않는다
                        //                                                                self.lb_StringMyCorrent.text = @"";
                        self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"4388FA"];
                    }
                    else
                    {
                        self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];
                    }
                    
                    self.lb_StringCorrent.layer.borderWidth = 1.f;
                    self.lb_StringCorrent.layer.borderColor = [UIColor lightGrayColor].CGColor;
                }
            }
        }
        else
        {
            [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
        }
    }
}

- (void)onShowIndicator
{
    [MBProgressHUD show];
}

- (void)setFinishCheck:(NSArray *)ar
{
    NSDictionary *dic = [ar firstObject];
    id userCorrect = [dic objectForKey:@"user_correct"];
    if( [userCorrect isEqual:[NSNull null]] || [userCorrect integerValue] == 0 )
    {
        //안푼문제
        isFinish = NO;
        self.btn_Menu.hidden = NO;
    }
    else
    {
        //푼 문제
        [self.btn_Menu removeFromSuperview];
        
        isFinish = YES;
        
        //내답
        NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey:@"user_correct"]];
        
        //정답
        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
        str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if( [str_UserCorrect isEqualToString:str_Correct] )
        {
            isFinishPass = YES;
        }
        else
        {
            isFinishPass = NO;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( self.popTip.isHidden == NO )
    {
        [self.popTip hide];
    }
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    self.btn_Menu.hidden = YES;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    self.btn_Menu.hidden = NO;
//}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_List )
    {
        return 1;
    }
    
    if( tableView == self.tbv_AnswerPrint )
    {
        if( isFinish )
        {
            return 1;
        }
        
        return 0;
    }
    
    return nCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_List )
    {
        QuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionListCell" forIndexPath:indexPath];
        [self configureCell:cell forRowAtIndexPath:indexPath];
        [self.questionListCell updateConstraintsIfNeeded];
        [self.questionListCell layoutIfNeeded];
        
        return cell;
    }
    
    if( tableView == self.tbv_AnswerPrint && isFinish )
    {
        NSDictionary *dic = [self.arM_List firstObject];
        str_MultipleChoice = [dic objectForKey:@"isMultipleChoice"];
        nCorrectCnt = [[dic objectForKey:@"correctAnswerCount"] integerValue];
        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
        NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey:@"user_correct"]];
        
        str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        str_UserCorrect = [str_UserCorrect stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if( [str_MultipleChoice isEqualToString:@"Y"] )
        {
            //객관식일 경우
            if( nCorrectCnt == 1 )
            {
                self.v_AnswerPrintNumber2Cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerPrintNumber1Cell" forIndexPath:indexPath];
                [self.v_AnswerPrintNumber2Cell.btn_Correct1 setTitle:str_Correct forState:UIControlStateNormal];
                if( [str_Correct isEqualToString:str_UserCorrect] )
                {
                    //맞춘 문제면 그냥 냅둔다
                    [self.v_AnswerPrintNumber2Cell.btn_Correct1 removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
                }
                else
                {
                    //틀린 문제면
                    [self.v_AnswerPrintNumber2Cell.btn_Correct1 addTarget:self action:@selector(onShowCorrectOne:) forControlEvents:UIControlEventTouchUpInside];
                    
                }
                return self.v_AnswerPrintNumber2Cell;
                
            }
            else
            {
                self.v_AnswerPrintNumber2Cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerPrintNumber2Cell" forIndexPath:indexPath];
                NSArray *ar_Correct = [str_Correct componentsSeparatedByString:@"|"];
                
                [self.v_AnswerPrintNumber2Cell.btn_Correct1 setTitle:ar_Correct[1] forState:UIControlStateNormal];
                [self.v_AnswerPrintNumber2Cell.btn_Correct2 setTitle:ar_Correct[0] forState:UIControlStateNormal];
                
                if( [str_Correct isEqualToString:str_UserCorrect] )
                {
                    //맞춘 문제면 그냥 냅둔다
                    [self.v_AnswerPrintNumber2Cell.btn_Correct1 removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
                    [self.v_AnswerPrintNumber2Cell.btn_Correct2 removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
                }
                else
                {
                    //틀린 문제면
                    [self.v_AnswerPrintNumber2Cell.btn_Correct1 addTarget:self action:@selector(onShowCorrectTwo:) forControlEvents:UIControlEventTouchUpInside];
                    [self.v_AnswerPrintNumber2Cell.btn_Correct2 addTarget:self action:@selector(onShowCorrectTwo:) forControlEvents:UIControlEventTouchUpInside];
                }
                return self.v_AnswerPrintNumber2Cell;
                
            }
            
        }
        else
        {
            //주관식일 경우
            self.v_AnswerPrintSubjectCell = [tableView dequeueReusableCellWithIdentifier:@"AnswerPrintSubjectCell" forIndexPath:indexPath];
            NSMutableString *strM_Correct = [NSMutableString string];
            NSArray *ar_Sep = [str_Correct componentsSeparatedByString:@","];
            if( ar_Sep.count == 1 )
            {
                [strM_Correct appendString:str_Correct];
            }
            else
            {
                for( NSInteger i = 0; i < ar_Sep.count; i++ )
                {
                    NSString *str = ar_Sep[i];
                    NSArray *ar_Sep2 = [str componentsSeparatedByString:@"-"];
                    if( ar_Sep2.count == 3 )
                    {
                        [strM_Correct appendString:ar_Sep2[1]];
                        [strM_Correct appendString:@", "];
                    }
                }
            }
            
            if( [strM_Correct hasSuffix:@", "] )
            {
                [strM_Correct deleteCharactersInRange:NSMakeRange([strM_Correct length]-2, 2)];
            }
            
            self.v_AnswerPrintSubjectCell.lb_Title.text = [NSString stringWithFormat:@"정답: %@", strM_Correct];
            
            if( [str_Correct isEqualToString:str_UserCorrect] == NO )
            {
                [self.v_AnswerPrintSubjectCell.btn_Answer addTarget:self action:@selector(onShowCorrectSubject:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            return self.v_AnswerPrintSubjectCell;
        }
    }
    else
    {
        if( indexPath.row == 0 )
        {
            self.v_AnswerTitleCell = [tableView dequeueReusableCellWithIdentifier:@"AnswerTitleCell" forIndexPath:indexPath];
            if( [str_MultipleChoice isEqualToString:@"Y"] )
            {
                if( isFinish == NO )
                {
                    if( nCorrectCnt > 1 )
                    {
                        self.v_AnswerTitleCell.lb_Title.text = [NSString stringWithFormat:@"이 문제는 정답이 %ld개 입니다 %ld개를 %ld번씩 눌러주세요.", nCorrectCnt, nCorrectCnt, nCorrectCnt];
                    }
                }
            }
            
            return self.v_AnswerTitleCell;
        }
        
        if( [str_MultipleChoice isEqualToString:@"Y"] )
        {
            if( indexPath.row == 1 )
            {
                NSDictionary *dic = [self.arM_List firstObject];
                NSInteger nItemCount = [[dic objectForKey:@"itemCount"] integerValue];
                if( nItemCount == 2 )
                {
                    self.v_Answer6Cell = [tableView dequeueReusableCellWithIdentifier:@"Answer2Cell" forIndexPath:indexPath];
                }
                else if( nItemCount == 3 )
                {
                    self.v_Answer6Cell = [tableView dequeueReusableCellWithIdentifier:@"Answer3Cell" forIndexPath:indexPath];
                }
                else if( nItemCount == 4 )
                {
                    self.v_Answer6Cell = [tableView dequeueReusableCellWithIdentifier:@"Answer4Cell" forIndexPath:indexPath];
                }
                else if( nItemCount == 5 )
                {
                    self.v_Answer6Cell = [tableView dequeueReusableCellWithIdentifier:@"Answer5Cell" forIndexPath:indexPath];
                }
                else if( nItemCount == 6 )
                {
                    self.v_Answer6Cell = [tableView dequeueReusableCellWithIdentifier:@"Answer6Cell" forIndexPath:indexPath];
                }
                
                //            self.v_Answer6Cell = [tableView dequeueReusableCellWithIdentifier:@"Answer5Cell" forIndexPath:indexPath];
                for( id subVuew in self.v_Answer6Cell.v_ButtonContainer.subviews )
                {
                    if( [subVuew isKindOfClass:[UIButton class]] )
                    {
                        UIButton *btn = (UIButton *)subVuew;
                        [btn addTarget:self action:@selector(onSelectedNumber:) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
                
                return self.v_Answer6Cell;
            }
            else if( indexPath.row == 2 )
            {
                self.v_AnswerDiscripCell = [tableView dequeueReusableCellWithIdentifier:@"AnswerDiscripCell" forIndexPath:indexPath];
                return self.v_AnswerDiscripCell;
            }
        }
        else
        {
            if( indexPath.row < nCorrectCnt + 1 )
            {
                //주관식 셀
                AnswerSubjectiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerSubjectiveCell" forIndexPath:indexPath];
                
                NSString *str_Number = @"";
                NSDictionary *dic = [self.arM_List firstObject];
                NSString *str_Correct = [dic objectForKey:@"correctAnswer"];
                NSArray *ar_Sep = [str_Correct componentsSeparatedByString:@","];
                if( ar_Sep.count > 0 )
                {
                    NSString *str_Tmp = ar_Sep[indexPath.row - 1];  //1-답-1
                    NSArray *ar_Tmp = [str_Tmp componentsSeparatedByString:@"-"];
                    if( ar_Tmp.count > 1 )
                    {
                        str_Number = [ar_Tmp firstObject];
                        cell.lc_ContainerLeading.constant = 10;
                    }
                }
                
                //            NSInteger nAsciiCode = indexPath.row + 63;
                cell.tf_Answer.tag = indexPath.row;
                cell.tf_Answer.delegate = self;
                str_Number = [str_Number stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                cell.lb_Title.text = str_Number;
                //            [cell.btn_Back addTarget:self action:@selector(onAnswerBack:) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
            else
            {
                //마지막 셀
                self.v_AnswerDiscripCell = [tableView dequeueReusableCellWithIdentifier:@"AnswerDiscripCell" forIndexPath:indexPath];
                return self.v_AnswerDiscripCell;
            }
        }
    }
    return nil;
    //    [cell updateConstraintsIfNeeded];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_List )
    {
//        if( fContentsHeight > 20 )
//        {
//            return fContentsHeight;
//        }
        
        [self configureCell:self.questionListCell forRowAtIndexPath:indexPath];
        
        [self.questionListCell updateConstraintsIfNeeded];
        [self.questionListCell layoutIfNeeded];
        
        self.questionListCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.questionListCell.bounds));
        
//        fContentsHeight = [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//        return self.questionListCell.bounds.size.height;
        return fContentsHeight + 20;
    }
    
    if( tableView == self.tbv_AnswerPrint && isFinish )
    {
        return 80.f;
    }
    
    if( indexPath.row == 0 )
    {
        return 30.0f;
    }
    else if( indexPath.row == 1 )
    {
        return 70.f;
    }
    
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
    
//    if( tableView == self.tbv_List )
//    {
//        return 44.0f;
//    }
//
//    return 0;
}

- (void)onSegChange:(UISegmentedControl *)seg
{
    [[NSUserDefaults standardUserDefaults] setObject:self.str_StartIdx forKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *dic = [self.arM_List firstObject];
    QuestionDiscriptionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionDiscriptionViewController"];

    if( seg.selectedSegmentIndex == 0 )
    {
        vc.isQuestion = NO;
    }
    else
    {
        vc.isQuestion = YES;
    }
    
    
    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
    vc.ar_Info = [dic objectForKey:@"examExplainInfos"];
    vc.str_ExamId = self.str_Idx;
    //    vc.str_ImagePreFix = self.str_ImagePreFix;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"QuestionListHeaderCell";
    QuestionListHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.btn_QnaCnt.selected = NO;
    
    [cell.btn_Play removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.btn_QnaCnt removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];

    //        NSDictionary *dic = self.arM_List[[self.str_StartIdx integerValue] - 1];
    NSDictionary *dic = self.arM_List[section];
    [cell.btn_ViewCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"totalAnswerCount"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_CommentCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"replyCount"] integerValue]] forState:UIControlStateNormal];
    //    NSInteger nVideoExplainCount = [[dic objectForKey:@"videoExplainCount"] integerValue];
    NSInteger nExplainCount = [[dic objectForKey:@"explainCount"] integerValue];
    
//    cell.seg.selectedSegmentIndex = -1;
//    
//    [cell.seg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", [[dic objectForKey:@"explainCount"] integerValue]] forSegmentAtIndex:0];
//    [cell.seg setTitle:[NSString stringWithFormat:@"질문 %ld", [[dic objectForKey:@"qnaCount"] integerValue]] forSegmentAtIndex:1];
//    [cell.seg addTarget:self action:@selector(onSegChange:) forControlEvents:UIControlEventValueChanged];

    NSInteger nQnaCnt = [[dic objectForKey:@"explainCount"] integerValue] + [[dic objectForKey:@"qnaCount"] integerValue];
    [cell.btn_QnaCnt setTitle:[NSString stringWithFormat:@"풀이 %ld", nQnaCnt] forState:UIControlStateNormal];
    [cell.btn_QnaCnt addTarget:self action:@selector(onDiscription:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btn_Discription setTitle:[NSString stringWithFormat:@"풀이 %ld", nQnaCnt] forState:UIControlStateNormal];
    
    if( nExplainCount > 0 )
    {
        cell.v_PlayContainer.hidden = NO;
        [cell.btn_Play addTarget:self action:@selector(onDiscription:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell.v_PlayContainer.hidden = YES;
    }
    
    cell.v_PlayContainer.hidden = YES;
    
    cell.btn_Info.tag = section;
    [cell.btn_Info addTarget:self action:@selector(onInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger nMyStarCnt = [[dic objectForKey:@"existStarCount"] integerValue];
    if( nMyStarCnt > 0 )
    {
        //별표를 했으면 별 온 시키고 시험나올듯 글씨 없애준다
        cell.btn_StarCnt.selected = YES;
        [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
    }
    else
    {
        //별표를 안했으면 시험나올듯과 별표카운트 표시
        cell.btn_StarCnt.selected = NO;
//        [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"시험나올듯 %ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
        [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];

    }
    
    [cell.btn_StarCnt addTarget:self action:@selector(onStarToggle:) forControlEvents:UIControlEventTouchUpInside];
    
     
    if( isFinish )
    {
        [cell setLabelColor:[UIColor whiteColor]];
        
        [cell.btn_ViewCnt setImage:BundleImage(@"eye_white.png") forState:UIControlStateNormal];
        [cell.btn_CommentCnt setImage:BundleImage(@"comment_off_white.png") forState:UIControlStateNormal];
        [cell.btn_StarCnt setImage:BundleImage(@"star_white.png") forState:UIControlStateNormal];
        [cell.btn_Info setImage:BundleImage(@"sidemenu_white.png") forState:UIControlStateNormal];
        cell.btn_QnaCnt.selected = YES;
        
        if( isFinishPass )
        {
            //맞춘문제
            cell.backgroundColor = [UIColor colorWithHexString:@"3bd1fe"];
        }
        else
        {
            //틀린문제
            cell.backgroundColor = kMainRedColor;
        }
        
        //        [cell.btn_ViewCnt setTitle:@"" forState:UIControlStateNormal];
        cell.iv_User.layer.cornerRadius = cell.iv_User.frame.size.width / 2;
        
        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_UserThumbUrl];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            NSString *str_Title = cell.btn_ViewCnt.titleLabel.text;
            [cell.btn_ViewCnt setTitle:[NSString stringWithFormat:@"   %@", str_Title] forState:UIControlStateNormal];
        }];
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == nCurrentSection )
    {
//        [UIView animateWithDuration:0.3f
//                         animations:^{
//                             
//                             self.v_Answer.alpha = NO;
//                         }];
    }
    
    NSLog(@"out : %ld", indexPath.section);
    
    //    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    //    {
    //        if( indexPath.section == nCurrentSection )
    //        {
    //            [UIView animateWithDuration:0.7f
    //                             animations:^{
    //
    //                                 CGRect frame = self.v_Answer.frame;
    //                                 frame.origin.y = self.view.bounds.size.height;
    //                                 self.v_Answer.frame = frame;
    //                             }completion:^(BOOL finished) {
    //
    //                                 [self.v_Answer removeFromSuperview];
    //                             }];
    //        }
    //        NSLog(@"out : %ld", indexPath.section);
    //    }
}

- (void)configureCell:(QuestionListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
    
    for( id subView in cell.contentView.subviews )
    {
        if( [subView isKindOfClass:[AudioView class]] == NO )
        {
            [subView removeFromSuperview];
        }
    }
    
    //    NSDictionary *dic = self.arM_List[[self.str_StartIdx integerValue] - 1];
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    __block CGFloat fSampleViewTotalHeight = 20;
    NSMutableArray *ar_ExamQuestionInfos = [NSMutableArray arrayWithArray:[dic objectForKey:@"examQuestionInfos"]];
    for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamQuestionInfos[i];
        NSString *str_Type = [dic objectForKey:@"questionType"];
        if( [str_Type isEqualToString:@"audio"] )
        {
            fSampleViewTotalHeight = 0;
            [ar_ExamQuestionInfos exchangeObjectAtIndex:i withObjectAtIndex:0];
            break;
        }
    }
    
    for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
    {
        CGFloat fX = 15.f;
        NSDictionary *dic = ar_ExamQuestionInfos[i];
        NSString *str_Type = [dic objectForKey:@"questionType"];
        NSString *str_Body = [dic objectForKey:@"questionBody"];
        //        NSLog(@"%@", str_Type);
        if( [str_Type isEqualToString:@"pdf"] )
        {
            continue;
            /*
             height = 140;
             orderInx = 0;
             questionBody = "000/000/54a129b585823628b2e09094eaef30e4.pdf";
             questionType = pdf;
             width = 326;
             */
            NSString *str_Body = [dic objectForKey:@"questionBody"];
            NSArray *ar_Tmp = [str_Body componentsSeparatedByString:@"/"];
            NSString *str_FileName = [ar_Tmp lastObject];
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
            NSURL  *url = [NSURL URLWithString:str_Url];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
                [urlData writeToFile:filePath atomically:YES];
                
                ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
                document.isLocalPDf = YES;
                
                if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
                {
                    [Common setPdfDocument:document];
                    
                    ReaderViewController *vc = [[ReaderViewController alloc] initWithReaderDocument:document];
//                    vc.isViewMode = YES;
//                    vc.dic_Info = nil;
////                    vc.ar_Question = ar;    //이건 문제 정보의 배열
//                    vc.delegate = self; // Set the ReaderViewController delegate to self
//                    
//                    NSMutableDictionary *dicM_SchoolInfo = [NSMutableDictionary dictionary];
//                    [dicM_SchoolInfo setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"targetSchoolIdStr"] integerValue]] forKey:@"targetSchoolIdStr"];
//                    [dicM_SchoolInfo setObject:[dic objectForKey_YM:@"targetSchoolIdStr"] forKey:@"schoolGrade"];
//                    
//                    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
//                    vc.str_Title = [dic objectForKey:@"e_title"];
//                    vc.str_SubTitle = [dic objectForKey:@"subjectName"];
//                    vc.dic_School = dicM_SchoolInfo;
//                    vc.nSchoolLevel = [[dic objectForKey:@"personGrade"] integerValue];
//                    vc.isNew = YES;
                    
                    vc.view.backgroundColor = [UIColor redColor];
                    [self.view addSubview:vc.view];
//                    [cell.contentView addSubview:vc.view];
//                    [self.navigationController pushViewController:vc animated:NO];
                }
            }
            else // Log an error so that we know that something went wrong
            {
                NSLog(@"data null");
            }
        }
        else if( [str_Type isEqualToString:@"text"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (fX*2), 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:20.f];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;
            
            [cell.contentView addSubview:lb_Contents];
            
            fSampleViewTotalHeight += lb_Contents.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"html"] )
        {
            UIFont *font = [UIFont fontWithName:@"Helvetica" size:20.f];
//            NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, nil];

            NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName : font } documentAttributes:nil error:nil];
//            [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrStr.length)];
            
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (fX*2), rect.size.height)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.numberOfLines = 0;
            lb_Contents.attributedText = attrStr;
            
            [cell.contentView addSubview:lb_Contents];
            
            fSampleViewTotalHeight += rect.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (fX*2), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            
            
            CGFloat fPer = iv.frame.size.width / [[dic objectForKey:@"width"] floatValue];
            CGFloat fHeight = [[dic objectForKey:@"height"] floatValue] * fPer;
            
            if( isnan(fHeight) )    fHeight = 300.f;
            
            CGRect frame = iv.frame;
            frame.size.height = fHeight;
            iv.frame = frame;
            
            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
            [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
            
            [cell.contentView addSubview:iv];
            
            fSampleViewTotalHeight += iv.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"videoLink"] )
        {
            //유튜브
            self.playerView = [[YTPlayerView alloc] initWithFrame:
                               CGRectMake(fX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (fX*2), (cell.contentView.frame.size.width - (fX*2)) * 0.7f)];
            
            NSDictionary *playerVars = @{
                                         @"controls" : @1,
                                         @"playsinline" : @1,
                                         @"autohide" : @1,
                                         @"showinfo" : @0,
                                         @"modestbranding" : @1
                                         };
            
            [self.playerView loadWithVideoId:str_Body playerVars:playerVars];
            
            [cell.contentView addSubview:self.playerView];
            
            fSampleViewTotalHeight += self.playerView.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"audio"] )
        {
            //음성
            //            self.btn_QuestionPlay = [YmExtendButton buttonWithType:UIButtonTypeCustom];
            //            self.btn_QuestionPlay.dic_Info = dic;
            //            self.btn_QuestionPlay.frame = CGRectMake(8, fSampleViewTotalHeight, 50, 50);
            //            [self.btn_QuestionPlay setImage:BundleImage(@"play_big.png") forState:UIControlStateNormal];
            //            [self.btn_QuestionPlay setImage:BundleImage(@"pause_big.png") forState:UIControlStateSelected];
            //            [self.btn_QuestionPlay addTarget:self action:@selector(onQuestionPlay:) forControlEvents:UIControlEventTouchUpInside];
            //            [cell.contentView addSubview:self.btn_QuestionPlay];
            //
            //            fSampleViewTotalHeight += self.btn_QuestionPlay.frame.size.height + 10;
            
//            if( self.v_Audio == nil )
            if( isUpdateLayout == NO )
            {
                if( self.v_Audio )
                {
                    [self.arM_Audios addObject:self.v_Audio];
                }
                
                NSString *str_Body = [dic objectForKey:@"questionBody"];
                self.str_AudioBody = str_Body;
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, self.str_AudioBody];
                
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
                self.v_Audio = [topLevelObjects objectAtIndex:0];
                [self.v_Audio initPlayer:str_Url];
            }
            
            CGRect frame = self.v_Audio.frame;
            frame.origin.y = fSampleViewTotalHeight;
            frame.size.width = self.view.bounds.size.width;
            frame.size.height = 48;
            self.v_Audio.frame = frame;
             
            [cell.contentView addSubview:self.v_Audio];
            
            fSampleViewTotalHeight += self.v_Audio.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (fX*2), (cell.contentView.frame.size.width - (fX*2)) * 0.7f)];
            
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
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
            [cell.contentView addSubview:view];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            
            fSampleViewTotalHeight += view.frame.size.height + 20;
        }
    }
    
    
    //보기입력
    CGFloat fX = 15.f;
    NSArray *ar_ExamUserItemInfos = [dic objectForKey:@"examUserItemInfos"];
    for( NSInteger i = 0; i < ar_ExamUserItemInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamUserItemInfos[i];
        NSString *str_Type = [dic objectForKey:@"type"];
        NSString *str_Body = [dic objectForKey:@"itemBody"];
        NSString *str_Number = [NSString stringWithFormat:@"%@ ", [dic objectForKey_YM:@"printNo"]];   //printNo 이걸쓰라고? itemNo
        
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
            [cell.contentView addSubview:lb_Contents];
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX + 20, fSampleViewTotalHeight, ((self.view.bounds.size.width / 2) - 50), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFit;
            iv.clipsToBounds = YES;
//            iv.backgroundColor = [UIColor redColor];
            
            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_ImageUrl]];
            UIImage *image = [UIImage imageWithData:imageData];
//            UIImage *resizeImage = [Util imageWithImage:image convertToWidth:iv.frame.size.width];
//            iv.image = resizeImage;
            iv.image = image;
            
//            CGRect frame = iv.frame;
//            frame.size.height = resizeImage.size.height;
//            iv.frame = frame;

            CGRect frame = iv.frame;
            frame.size.height = 150.f;
            iv.frame = frame;

            [cell.contentView addSubview:iv];
            
            if( i == ar_ExamUserItemInfos.count - 1 )
            {
                fSampleViewTotalHeight += 200;
            }
        }
        else if( [str_Type isEqualToString:@"itemHtml"] )
        {
            UIFont *font = [UIFont fontWithName:@"Helvetica" size:19.f];
            NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
                                                                 forKey:NSFontAttributeName];
            
            NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", str_Number] attributes:dic_Attr];
//            [attrStr appendAttributedString:attrStr_Html];
            
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 30, rect.size.height)];
            lb_Contents.numberOfLines = 0;
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:24.f];
            lb_Contents.text = attrStr.string;
            //            lb_Contents.attributedText = attrStr;
//                        lb_Contents.backgroundColor = [UIColor redColor];
            
            CGSize size = [Util getTextSize:lb_Contents];
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = size.height;
            lb_Contents.frame = frame;
            
            [cell.contentView addSubview:lb_Contents];
            
            if( isNumberQuestion == NO )
            {
                lb_Contents.text = @"";
            }
            
            //마지막에 줄바꿈이 들어가서 없애줌
            NSArray *charSet = [attrStr_Html.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSString *str_Contents = [charSet componentsJoinedByString:@""];
            ////////////////////////////
            
            UILabel * lb_Contents2 = [[UILabel alloc] initWithFrame:CGRectMake(lb_Contents.text.length > 0 ?
                                                                               lb_Contents.frame.origin.x + lb_Contents.frame.size.width : fX, fSampleViewTotalHeight,
                                                                               lb_Contents.text.length > 0 ?
                                                                               cell.contentView.frame.size.width - (lb_Contents.frame.origin.x + lb_Contents.frame.size.width + fX) :
                                                                               cell.contentView.frame.size.width - (fX * 2),
                                                                               0)];
            lb_Contents2.numberOfLines = 0;
            lb_Contents2.font = [UIFont fontWithName:@"Helvetica" size:20.f];
            lb_Contents2.text = str_Contents;
            lb_Contents2.textColor = [UIColor colorWithHexString:@"030304"];
//            lb_Contents2.backgroundColor = [UIColor blueColor];
            //            lb_Contents.attributedText = attrStr;
            
            size = [Util getTextSize:lb_Contents2];
            
            frame = lb_Contents2.frame;
            frame.size.height = size.height < lb_Contents.frame.size.height ? lb_Contents.frame.size.height : size.height;
            lb_Contents2.frame = frame;
            
            [cell.contentView addSubview:lb_Contents2];
            
            
            
            fSampleViewTotalHeight += size.height + 15;
        }
        else
        {
            UIFont *font = [UIFont fontWithName:@"Helvetica" size:19.f];
            NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
                                                                 forKey:NSFontAttributeName];

            NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[@"" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str_Number, str_Body] attributes:dic_Attr];
            [attrStr appendAttributedString:attrStr_Html];
            
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 30, rect.size.height)];
            lb_Contents.numberOfLines = 0;
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:24.f];
            lb_Contents.text = str_Number;
//            lb_Contents.attributedText = attrStr;
//            lb_Contents.backgroundColor = [UIColor redColor];
            
            CGSize size = [Util getTextSize:lb_Contents];
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = size.height;
            lb_Contents.frame = frame;
            
            [cell.contentView addSubview:lb_Contents];
            
            UILabel * lb_Contents2 = [[UILabel alloc] initWithFrame:CGRectMake(lb_Contents.frame.origin.x + lb_Contents.frame.size.width, fSampleViewTotalHeight,
                                                                               cell.contentView.frame.size.width - (lb_Contents.frame.origin.x + lb_Contents.frame.size.width + fX), 0)];
            lb_Contents2.numberOfLines = 0;
            lb_Contents2.font = [UIFont fontWithName:@"Helvetica" size:20.f];
            lb_Contents2.text = str_Body;
            lb_Contents2.textColor = [UIColor colorWithHexString:@"030304"];
//            lb_Contents2.backgroundColor = [UIColor blueColor];
            //            lb_Contents.attributedText = attrStr;
            
            size = [Util getTextSize:lb_Contents2];
            
            frame = lb_Contents2.frame;
            frame.size.height = size.height < lb_Contents.frame.size.height ? lb_Contents.frame.size.height : size.height;
            lb_Contents2.frame = frame;

            [cell.contentView addSubview:lb_Contents2];
            
            
            
            fSampleViewTotalHeight += size.height + 15;
        }
    }
    
    
    CGRect frame = cell.frame;
    frame.size.height = fSampleViewTotalHeight > (self.tbv_List.frame.size.height - 50) ? fSampleViewTotalHeight + 120 : fSampleViewTotalHeight;
    cell.frame = frame;
    
    fContentsHeight = fSampleViewTotalHeight;
    fContentsHeight += 70;  //간혹 일반문제에서 보기가 다 스크롤 되지 않던 현상 수정한것임
    
    //    [cell setNeedsLayout];
    //    [cell updateConstraints];
    
    //    [self.dicM_CellHeight setObject:[NSNumber numberWithFloat:fSampleViewTotalHeight] forKey:[NSNumber numberWithInteger:indexPath.section + 1]];
    
    
    //    self.v_Sample.backgroundColor = kMainRedColor;
    
    //    self.sv_Main.contentSize = CGSizeMake(0, self.v_LastObj.frame.origin.y + self.v_Sample.frame.size.height + 20);
    
    
    
}

- (void)onQuestionPlay:(YmExtendButton *)btn
{
    NSString *str_Body = [btn.dic_Info objectForKey:@"questionBody"];
    NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
    NSURL *url = [NSURL URLWithString:str_Url];
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player = [AVPlayer playerWithURL:url];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    //    [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self.player play];
    self.btn_QuestionPlay.selected = YES;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//
//    if (object == self.player && [keyPath isEqualToString:@"status"])
//    {
//        if (self.player.status == AVPlayerStatusFailed)
//        {
//            NSLog(@"AVPlayer Failed");
//
//        }
//        else if (self.player.status == AVPlayerStatusReadyToPlay)
//        {
//            NSLog(@"AVPlayerStatusReadyToPlay");
//
//
//        }
//        else if (self.player.status == AVPlayerItemStatusUnknown)
//        {
//            NSLog(@"AVPlayer Unknown");
//
//        }
//    }
//}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next sound file
    NSLog(@"End");
    self.btn_QuestionPlay.selected = NO;
    //    [self.player removeObserver:self forKeyPath:@"status"];
}

- (void)onStarToggle:(UIButton *)btn
{
    NSDictionary *dic = [self.arM_List firstObject];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                        !btn.selected ? @"on" : @"off", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/question/star"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                [self updateList];
                                            }
                                        }
                                    }];
}

- (void)onAnswerBack:(UIButton *)btn
{
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.tbv_List];
    NSIndexPath *indexPath = [self.tbv_List indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        AnswerSubjectiveCell *cell =  (AnswerSubjectiveCell *)[self.tbv_List cellForRowAtIndexPath:indexPath];
        NSLog(@"%@", cell);
        //        AnswerSubjectiveCell *cell = (AnswerSubjectiveCell *)[(UITableView *)self cellForRowAtIndexPath:indexPath];
        
        self.btn_Menu.alpha = YES;
        nCellCount = 1;
        [self.tbv_List reloadData];
        isUpdateLayout = NO;
    }
    
}

- (void)onShowCorrectOne:(UIButton *)btn
{
    NSDictionary *dic = [self.arM_List firstObject];
    NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey:@"user_correct"]];
    
    self.v_AnswerPrintNumber2Cell.lb_Title.hidden = NO;
    self.v_AnswerPrintNumber2Cell.lb_Title.text = [NSString stringWithFormat:@"당신은 %@번을 선택했었습니다.", str_UserCorrect];
    
    self.v_AnswerPrintNumber2Cell.btn_UserCorrect1.hidden = NO;
    [self.v_AnswerPrintNumber2Cell.btn_UserCorrect1 setTitle:str_UserCorrect forState:UIControlStateNormal];
}

- (void)onShowCorrectTwo:(UIButton *)btn
{
    NSDictionary *dic = [self.arM_List firstObject];
    NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey:@"user_correct"]];
    NSArray *ar_UserCorrect = [str_UserCorrect componentsSeparatedByString:@"|"];
    
    self.v_AnswerPrintNumber2Cell.lb_Title.hidden = NO;
    self.v_AnswerPrintNumber2Cell.lb_Title.text = [NSString stringWithFormat:@"당신은 %@번, %@번을 선택했었습니다.", ar_UserCorrect[0], ar_UserCorrect[1]];
    
    self.v_AnswerPrintNumber2Cell.btn_UserCorrect1.hidden = NO;
    self.v_AnswerPrintNumber2Cell.btn_UserCorrect2.hidden = NO;
    [self.v_AnswerPrintNumber2Cell.btn_UserCorrect1 setTitle:ar_UserCorrect[1] forState:UIControlStateNormal];
    [self.v_AnswerPrintNumber2Cell.btn_UserCorrect2 setTitle:ar_UserCorrect[0] forState:UIControlStateNormal];
}

- (void)onShowCorrectSubject:(UIButton *)btn
{
    NSDictionary *dic = [self.arM_List firstObject];
    
    
    
    
    NSString *str_Correct = [dic objectForKey:@"user_correct"];
    
    NSMutableString *strM_Correct = [NSMutableString string];
    NSArray *ar_Sep = [str_Correct componentsSeparatedByString:@","];
    if( ar_Sep.count == 1 )
    {
        [strM_Correct appendString:str_Correct];
    }
    else
    {
        for( NSInteger i = 0; i < ar_Sep.count; i++ )
        {
            NSString *str = ar_Sep[i];
            NSArray *ar_Sep2 = [str componentsSeparatedByString:@"-"];
            if( ar_Sep2.count == 3 )
            {
                NSString *str2 = ar_Sep2[1];
                if( str2.length > 0 )
                {
                    [strM_Correct appendString:ar_Sep2[1]];
                    [strM_Correct appendString:@", "];
                }
            }
        }
    }
    
    if( [strM_Correct hasSuffix:@", "] )
    {
        [strM_Correct deleteCharactersInRange:NSMakeRange([strM_Correct length]-2, 2)];
    }
    
    
    
    
    
    
    
    NSString *str_UserCorrect = [NSString stringWithFormat:@"당신은 '%@'이였습니다.", [NSString stringWithFormat:@"%@", strM_Correct]];
    str_UserCorrect = [str_UserCorrect stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    self.v_AnswerPrintSubjectCell.lb_MyAnswer.hidden = NO;
    self.v_AnswerPrintSubjectCell.lb_MyAnswer.text = str_UserCorrect;
}




#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
//            if( self.btn_Star.alpha == YES )
//            {
//                self.lc_AnswerBottom.constant = keyboardBounds.size.height;
//                [self.tbv_Answer updateConstraints];
//            }
            
            if( self.btn_Star.alpha == YES )
            {
                self.lc_AnswerNonNumberBottom.constant = keyboardBounds.size.height;
            }

            //            self.tbv_List.contentSize = CGSizeMake(self.tbv_List.bounds.size.width, self.tbv_List.contentSize.height + keyboardBounds.size.height);
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
//            if( self.btn_Star.alpha == YES )
//            {
//                self.lc_AnswerBottom.constant = 0;
//                [self.tbv_Answer updateConstraints];
//            }
            
            if( self.btn_Star.alpha == YES )
            {
                self.lc_AnswerNonNumberBottom.constant = -150.f;
            }

            //            self.tbv_List.contentSize = CGSizeMake(self.tbv_List.bounds.size.width, self.tbv_List.contentSize.height - keyboardBounds.size.height);
        }
    }completion:^(BOOL finished) {
        
    }];
}


#pragma mark - UITextFieldDelegate
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.tbv_List];
//    NSIndexPath *indexPath = [self.tbv_List indexPathForRowAtPoint:buttonPosition];
//    if (indexPath != nil)
//    {
//        AnswerSubjectiveCell *cell =  (AnswerSubjectiveCell *)[self.tbv_List cellForRowAtIndexPath:indexPath];
//        //        cell.lc_BackWidth.constant = 47.f;
//    }
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.tbv_List];
//    NSIndexPath *indexPath = [self.tbv_List indexPathForRowAtPoint:buttonPosition];
//    if (indexPath != nil)
//    {
//        AnswerSubjectiveCell *cell =  (AnswerSubjectiveCell *)[self.tbv_List cellForRowAtIndexPath:indexPath];
//        //        cell.lc_BackWidth.constant = 0;
//    }
//}

- (void)textFieldDidChange:(UITextField *)tf
{
    if( tf.text.length > 0 )
    {
        self.lc_AnswerNonNumberCheckWidth1.constant = 63.f;
        self.iv_NonNumberStatus.backgroundColor = [UIColor darkGrayColor];
    }
    else
    {
        self.lc_AnswerNonNumberCheckWidth1.constant = 0.f;
        self.iv_NonNumberStatus.backgroundColor = [UIColor whiteColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField.text.length > 0 )
    {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];

        if( self.isWrong == NO && self.isStar == NO )
        {
            [self sendCorrect:dic];
        }
        else
        {
            [self onShowResult:dic];
        }
    }

//    NSMutableArray *arM_MyCorrect = [NSMutableArray array];
//    
//    for( NSInteger i = 0; i < nCellCount; i++ )
//    {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        id cell =  [self.tbv_Answer cellForRowAtIndexPath:indexPath];
//        if( [cell isKindOfClass:[AnswerSubjectiveCell class]] )
//        {
//            AnswerSubjectiveCell *findCell = (AnswerSubjectiveCell *)cell;
//            if( findCell.tf_Answer.text.length <= 0 )
//            {
//                [self.navigationController.view makeToast:@"정답을 입력해 주세요" withPosition:kPositionCenter];
//                return YES;
//            }
//            
//            [arM_MyCorrect addObject:findCell.tf_Answer.text];
//        }
//    }
//    
//    
//    
//    
//    //TODO: 정답전송
//    NSMutableString *strM_Correct = [NSMutableString string];
//    
//    NSDictionary *dic = [self.arM_List firstObject];
//    NSString *str_Correct = [dic objectForKey:@"correctAnswer"];
//    
//    NSArray *ar_Sep = [str_Correct componentsSeparatedByString:@","];
//    for( NSInteger i = 0; i < ar_Sep.count; i++ )
//    {
//        //        NSString *str_Tmp = ar_Sep[i];
//        //        NSArray *ar_Tmp = [str_Tmp componentsSeparatedByString:@"-"];
//        //        if( ar_Tmp.count > 1 )
//        //        {
//        //            NSString *str_Number = ar_Tmp[0];
//        //            str_Number = [str_Number stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        //            [strM_Correct appendString:str_Number];
//        //            [strM_Correct appendString:@"-"];
//        //            NSString *str_Tmp = [arM_MyCorrect[i] stringByReplacingOccurrencesOfString:@"," withString:@""];
//        //            [strM_Correct appendString:str_Tmp];
//        //            [strM_Correct appendString:@"-"];
//        //            [strM_Correct appendString:@"1"];
//        //            [strM_Correct appendString:@","];
//        //        }
//        //        else
//        //        {
//        //            NSString *str_Tmp = [arM_MyCorrect[i] stringByReplacingOccurrencesOfString:@"," withString:@""];
//        //            [strM_Correct appendString:str_Tmp];
//        //            [strM_Correct appendString:@","];
//        //        }
//        
//        NSString *str_Tmp = ar_Sep[i];
//        NSArray *ar_Tmp = [str_Tmp componentsSeparatedByString:@"-"];
//        if( ar_Tmp.count > 1 )
//        {
//            NSString *str_Number = ar_Tmp[0];
//            str_Number = [str_Number stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            [strM_Correct appendString:str_Number];
//            [strM_Correct appendString:@"-"];
//            
//            NSString *str_Tmp = arM_MyCorrect[i];
//            NSString *str_MyCorrect = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            [strM_Correct appendString:str_MyCorrect];
//            [strM_Correct appendString:@"-"];
//            [strM_Correct appendString:@"1"];
//            [strM_Correct appendString:@","];
//        }
//        else
//        {
//            NSString *str_Tmp = arM_MyCorrect[i];
//            NSString *str_MyCorrect = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            [strM_Correct appendString:str_MyCorrect];
//            [strM_Correct appendString:@","];
//        }
//    }
//    
//    if( [strM_Correct hasSuffix:@","] )
//    {
//        [strM_Correct deleteCharactersInRange:NSMakeRange([strM_Correct length]-1, 1)];
//    }
//    
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
//                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
//                                        strM_Correct, @"userAnswer", //사용자가 입력한 답
//                                        [NSString stringWithFormat:@"%ld", self.vc_Parent.nTime * 1000], @"examLapTime",  //경과시간
//                                        @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
//                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
//                                        [NSString stringWithFormat:@"%ld", nQuestionCount], @"totalQuestionCount", //전체문제수
//                                        @"on", @"setMode",
//                                        nil];
//    
//    __weak __typeof(&*self)weakSelf = self;
//
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
//                                        param:dicM_Params
//                                   withMethod:@"POST"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
////                                            [self updateList];
//                                           
//                                            [weakSelf setFinishCheck:@[@{@"user_correct":strM_Correct, @"correctAnswer":[dic objectForKey:@"correctAnswer"]}]];
//                                            [weakSelf.tbv_List reloadData];
//                                            isUpdateLayout = NO;
////                                            [weakSelf.tbv_Answer reloadData];
////                                            [weakSelf.tbv_AnswerPrint reloadData];
//
//                                            NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
////                                            if( nDiscriptionCnt > 0 )
//                                            if( 1 )
//                                            {
//                                                weakSelf.v_Discription.hidden = NO;
//                                                weakSelf.lc_AnswerBottom.constant = 70;
//                                            }
//
//
//                                            NSString *str_IsExamFinish = [resulte objectForKey:@"isExamFinish"];
//                                            if( [str_IsExamFinish isEqualToString:@"Y"] )
//                                            {
//                                                UIAlertView *alert = CREATE_ALERT(nil, @"결과를 확인하시겠습니까?", @"예", @"아니요");
//                                                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                                    if( buttonIndex == 0 )
//                                                    {
//                                                        [weakSelf showResultView];
//                                                    }
//                                                }];
//                                            }
//                                        }
//                                    }];
//    
//    NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
////    if( nDiscriptionCnt > 0 )
//    if( 1 )
//    {
//        //해설이 있다면 문제 풀이가 있다면 문제풀이 쇼
//        nCellCount += 1;
//    }
//    
//    //텍스트필드 입력을 못하게 막는다
//    for( NSInteger i = 0; i < nCellCount; i++ )
//    {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        id cell =  [self.tbv_Answer cellForRowAtIndexPath:indexPath];
//        if( [cell isKindOfClass:[AnswerSubjectiveCell class]] )
//        {
//            AnswerSubjectiveCell *findCell = (AnswerSubjectiveCell *)cell;
//            findCell.tf_Answer.userInteractionEnabled = NO;
//        }
//    }
//    
//    [self.view endEditing:YES];
//    
////    [self updateList];
//    
//    str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    if( [str_Correct isEqualToString:strM_Correct] )
//    {
//        self.v_AnswerTitleCell.lb_Title.text = @"정답입니다!";
//        self.v_AnswerTitleCell.lb_Title.textColor = [UIColor blackColor];
//    }
//    else
//    {
//        self.v_AnswerTitleCell.lb_Title.backgroundColor = kMainRedColor;
//        self.v_AnswerTitleCell.lb_Title.textColor = [UIColor whiteColor];
//        self.v_AnswerTitleCell.lb_Title.text = [NSString stringWithFormat:@"정답이 아닙니다! (정답: %@)", str_Correct] ;
//    }
    
    return YES;
}

- (void)showResultView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }
    vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)onSelectedNumber:(UIButton *)btn
{
    NSLog(@"%@", btn.superview);
    
    if( nCorrectCnt <= 1 )
    {
        if( btn.selected == NO )
        {
            //처음선택
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        btn_Sub.selected = NO;
                        //                        btn_Sub.layer.borderColor = [UIColor whiteColor].CGColor;
                        btn_Sub.backgroundColor = [UIColor whiteColor];
                        [btn_Sub setTitleColor:kMainColor forState:UIControlStateNormal];
                    }
                }
            }
            
            btn.selected = YES;
            btn.backgroundColor = [UIColor yellowColor];
            [btn setTitleColor:kMainColor forState:UIControlStateSelected];
            //            [btn setTitleColor:kMainColor forState:UIControlStateNormal];
            
            //            btn.layer.borderColor = [UIColor yellowColor].CGColor;
            
            //correctAnswer
            self.v_AnswerTitleCell.lb_Title.text = @"답이라고 생각하시면 한 번 더 눌러주세요!";
        }
        else
        {
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        btn_Sub.userInteractionEnabled = NO;
                    }
                }
            }
            
            //두번째선택
            NSDictionary *dic = [self.arM_List firstObject];
            NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
            if( [str_Correct isEqualToString:btn.titleLabel.text] )
            {
                //            self.v_Answer.lb_Title.backgroundColor = kMainRedColor;
                self.v_AnswerTitleCell.lb_Title.textColor = [UIColor blackColor];
                self.v_AnswerTitleCell.lb_Title.text = @"정답입니다!";
            }
            else
            {
                self.v_AnswerTitleCell.lb_Title.backgroundColor = kMainRedColor;
                self.v_AnswerTitleCell.lb_Title.textColor = [UIColor whiteColor];
                self.v_AnswerTitleCell.lb_Title.text = [NSString stringWithFormat:@"%@번이 정답입니다!", str_Correct];
            }
            
            //모든 버튼을 흰색으로 바꾼다
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        btn_Sub.selected = NO;
                        //                        btn_Sub.layer.borderColor = [UIColor whiteColor].CGColor;
                        btn_Sub.backgroundColor = [UIColor whiteColor];
                        [btn_Sub setTitleColor:kMainColor forState:UIControlStateNormal];
                    }
                }
            }
            
            
            //내가 선택한 버튼을 빨간색으로 바꾼다
            UIButton *btn_MyCorrect = [self.v_Answer6Cell.v_ButtonContainer viewWithTag:[btn.titleLabel.text integerValue]];
            btn_MyCorrect.backgroundColor = kMainRedColor;
            [btn_MyCorrect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            btn_MyCorrect.layer.borderColor = kMainRedColor.CGColor;
            
            
            //정답 버튼을 파란색으로 바꾼다
            UIButton *btn_Correct = [self.v_Answer6Cell.v_ButtonContainer viewWithTag:[str_Correct integerValue]];
            btn_Correct.backgroundColor = kMainColor;
            [btn_Correct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            btn_Correct.layer.borderColor = kMainColor.CGColor;
            
            
            
            
            NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
//            if( nDiscriptionCnt > 0 )
            if( 1 )
            {
                //해설이 있다면 문제 풀이가 있다면 문제풀이 쇼
                nCellCount = 4;
            }
            
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                                btn.titleLabel.text, @"userAnswer", //사용자가 입력한 답
                                                [NSString stringWithFormat:@"%ld", self.vc_Parent.nTime * 1000], @"examLapTime",  //경과시간
                                                @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                                [NSString stringWithFormat:@"%ld", nQuestionCount], @"totalQuestionCount", //전체문제수
                                                @"on", @"setMode",
                                                nil];
            
            __weak __typeof(&*self)weakSelf = self;

            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                                param:dicM_Params
                                           withMethod:@"POST"
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [MBProgressHUD hide];
                                                
                                                if( resulte )
                                                {
//                                                    [weakSelf updateList];
                                                    
                                                    [weakSelf setFinishCheck:@[@{@"user_correct":btn.titleLabel.text, @"correctAnswer":[dic objectForKey:@"correctAnswer"]}]];
                                                    [weakSelf.tbv_List reloadData];
                                                    isUpdateLayout = NO;
//                                                    [weakSelf.tbv_Answer reloadData];
//                                                    [weakSelf.tbv_AnswerPrint reloadData];

                                                    NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
//                                                    if( nDiscriptionCnt > 0 )
                                                    if( 1 )
                                                    {
                                                        self.v_Discription.hidden = NO;
                                                        self.lc_AnswerBottom.constant = 70;
                                                    }
                                                    
                                                    NSString *str_IsExamFinish = [resulte objectForKey:@"isExamFinish"];
                                                    if( [str_IsExamFinish isEqualToString:@"Y"] )
//                                                    if( 1 )
                                                    {
                                                        UIAlertView *alert = CREATE_ALERT(nil, @"결과를 확인하시겠습니까?", @"예", @"아니요");
                                                        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                            if( buttonIndex == 0 )
                                                            {
                                                                [self showResultView];
                                                            }
                                                        }];
                                                    }
                                                }
                                            }];
        }
    }
    else
    {
        if( [btn.backgroundColor isEqual:kMainColor] )
        {
            //두번 입력한걸 또 눌렀을때, 이땐 취소
            btn.tag = 1;
            btn.selected = NO;
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitleColor:kMainColor forState:UIControlStateNormal];
            
            //            btn.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        else
        {
            if( btn.selected == NO )
            {
                //첫번째 입력
                btn.tag = 1;
                btn.selected = YES;
                btn.backgroundColor = [UIColor yellowColor];
                [btn setTitleColor:kMainColor forState:UIControlStateSelected];

                //                btn.layer.borderColor = [UIColor yellowColor].CGColor;
                
            }
            else
            {
                //두번째 입력
                //                btn.tag = 888;
                btn.backgroundColor = kMainColor;
                //                btn.layer.borderColor = kMainColor.CGColor;
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
            }
        }
        
        //블루컬러가 답 갯수가 되는 순간 api 태운다
        NSMutableString *strM_MyCorrect = [NSMutableString string];
        NSInteger nMyAnswerCnt = 0;
        for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn_Sub = (UIButton *)subView;
                if( btn_Sub.tag > 0 )
                {
                    if( [btn_Sub.backgroundColor isEqual:kMainColor] )
                        //                    if( btn_Sub.tag == 888 )
                    {
                        nMyAnswerCnt++;
                        [strM_MyCorrect appendString:btn_Sub.titleLabel.text];
                        [strM_MyCorrect appendString:@"|"];
                    }
                }
            }
        }
        
        if( [strM_MyCorrect hasSuffix:@"|"] )
        {
            [strM_MyCorrect deleteCharactersInRange:NSMakeRange([strM_MyCorrect length]-1, 1)];
        }
        
        if( nMyAnswerCnt == nCorrectCnt )
        {
            NSDictionary *dic = [self.arM_List firstObject];
            NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
            NSLog(@"%@", str_Correct);
            
            
            
            //먼저 모두 흰색으로 바꾸고
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        btn_Sub.selected = NO;
                        btn_Sub.backgroundColor = [UIColor whiteColor];
                        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
                        
                        //                        btn_Sub.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                    }
                }
            }
            
            //그 다음 내가 택한 답을 빨간색으로 바꾸고
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        NSArray *ar_MyCorrect = [strM_MyCorrect componentsSeparatedByString:@"|"];
                        for( NSInteger j = 0; j < ar_MyCorrect.count; j++ )
                        {
                            NSString *str_MyCorrect = ar_MyCorrect[j];
                            if( [str_MyCorrect isEqualToString:btn_Sub.titleLabel.text] )
                            {
                                btn_Sub.backgroundColor = kMainRedColor;
                                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                //                                btn_Sub.layer.borderColor = kMainRedColor.CGColor;
                            }
                        }
                    }
                }
            }
            
            
            //그 다음 정답을 파란색으로 바꾼다
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        NSArray *ar_Correct = [str_Correct componentsSeparatedByString:@"|"];
                        for( NSInteger j = 0; j < ar_Correct.count; j++ )
                        {
                            NSString *str_Correct = ar_Correct[j];
                            if( [str_Correct isEqualToString:btn_Sub.titleLabel.text] )
                            {
                                btn_Sub.backgroundColor = kMainColor;
                                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                //                                btn_Sub.layer.borderColor = kMainColor.CGColor;
                            }
                        }
                    }
                }
            }
            
            
            if( [str_Correct isEqualToString:strM_MyCorrect] )
            {
                //정답
                self.v_AnswerTitleCell.lb_Title.textColor = [UIColor blackColor];
                self.v_AnswerTitleCell.lb_Title.text = @"정답입니다!";
                
            }
            else
            {
                //오답
                self.v_AnswerTitleCell.lb_Title.backgroundColor = kMainRedColor;
                self.v_AnswerTitleCell.lb_Title.textColor = [UIColor whiteColor];
                self.v_AnswerTitleCell.lb_Title.text = @"정답이 아닙니다!";
                
            }
            
            NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
//            if( nDiscriptionCnt > 0 )
            if( 1 )
            {
                //해설이 있다면 문제 풀이가 있다면 문제풀이 쇼
                nCellCount = 4;
            }
            
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        btn_Sub.userInteractionEnabled = NO;
                    }
                }
            }
            
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                                strM_MyCorrect, @"userAnswer", //사용자가 입력한 답
                                                [NSString stringWithFormat:@"%ld", self.vc_Parent.nTime * 1000], @"examLapTime",  //경과시간
                                                @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                                [NSString stringWithFormat:@"%ld", nQuestionCount], @"totalQuestionCount", //전체문제수
                                                @"on", @"setMode",
                                                nil];
            
            __weak __typeof(&*self)weakSelf = self;

            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                                param:dicM_Params
                                           withMethod:@"POST"
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [MBProgressHUD hide];
                                                
                                                if( resulte )
                                                {
//                                                    [weakSelf updateList];
                                                    
                                                    [weakSelf setFinishCheck:@[@{@"user_correct":strM_MyCorrect, @"correctAnswer":[dic objectForKey:@"correctAnswer"]}]];
                                                    [weakSelf.tbv_List reloadData];
                                                    isUpdateLayout = NO;
//                                                    [weakSelf.tbv_Answer reloadData];
//                                                    [weakSelf.tbv_AnswerPrint reloadData];

                                                    
                                                    NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
//                                                    if( nDiscriptionCnt > 0 )
                                                    if( 1 )
                                                    {
                                                        weakSelf.v_Discription.hidden = NO;
                                                        weakSelf.lc_AnswerBottom.constant = 70;
                                                    }

                                                    NSString *str_IsExamFinish = [resulte objectForKey:@"isExamFinish"];
                                                    if( [str_IsExamFinish isEqualToString:@"Y"] )
                                                    {
                                                        UIAlertView *alert = CREATE_ALERT(nil, @"결과를 확인하시겠습니까?", @"예", @"아니요");
                                                        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                            if( buttonIndex == 0 )
                                                            {
                                                                [weakSelf showResultView];
                                                            }
                                                        }];
                                                    }
                                                }
                                            }];
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //    if( btn.selected == NO )
    //    {
    //        //처음선택
    //        AnswerNumberView *view = (AnswerNumberView *)self.v_Answer;
    //        for( id subView in view.v_Buttons.subviews )
    //        {
    //            if( [subView isKindOfClass:[UIButton class]] )
    //            {
    //                UIButton *btn_Sub = (UIButton *)subView;
    //                if( btn_Sub.tag > 0 )
    //                {
    //                    btn_Sub.selected = NO;
    //                    btn_Sub.backgroundColor = [UIColor whiteColor];
    //                }
    //            }
    //        }
    //
    //        btn.selected = YES;
    //        btn.backgroundColor = [UIColor yellowColor];
    //        //correctAnswer
    //        self.v_Answer.lb_Title.text = @"답이라고 생각하시면 한 번 더 눌러주세요";
    //    }
    //    else
    //    {
    //        //두번째선택
    //        NSDictionary *dic = [self.arM_List firstObject];
    //        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
    //        if( [str_Correct isEqualToString:btn.titleLabel.text] )
    //        {
    ////            self.v_Answer.lb_Title.backgroundColor = kMainRedColor;
    //            self.v_Answer.lb_Title.text = @"정답입니다!";
    //        }
    //        else
    //        {
    //            self.v_Answer.lb_Title.backgroundColor = [UIColor colorWithHexString:@"f68a85"];
    //            self.v_Answer.lb_Title.text = [NSString stringWithFormat:@"%@번이 정답입니다!", str_Correct];
    //        }
    //
    //        AnswerNumberView *view = (AnswerNumberView *)self.v_Answer;
    //        UIButton *btn_Correct = [view.v_Buttons viewWithTag:[str_Correct integerValue]];
    //        btn_Correct.backgroundColor = [UIColor colorWithHexString:@"4285F4"];
    //
    //        NSInteger nQuestionCount = [[self.dic_PackageInfo objectForKey:@"questionCount"] integerValue];
    //
    //        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
    //                                            [Util getUUID], @"uuid",
    //                                            [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
    //                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
    //                                            btn.titleLabel.text, @"userAnswer", //사용자가 입력한 답
    //                                            [NSString stringWithFormat:@"%ld", nTime * 1000], @"examLapTime",  //경과시간
    //                                            @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
    //                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
    //                                            [NSString stringWithFormat:@"%ld", nQuestionCount], @"totalQuestionCount", //전체문제수
    //                                            @"on", @"setMode",
    //                                            nil];
    //
    //        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
    //                                            param:dicM_Params
    //                                       withMethod:@"POST"
    //                                        withBlock:^(id resulte, NSError *error) {
    //
    //                                            if( resulte )
    //                                            {
    //
    //                                            }
    //                                        }];
    //
    //        NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
    //        if( nDiscriptionCnt > 0 )
    //        {
    //            //해설이 있다면 문제 풀이가 있다면 문제풀이 쇼
    //            view.lc_DiscriptionHeight.constant = 60;
    //            [view.btn_Discription addTarget:self action:@selector(onDiscription:) forControlEvents:UIControlEventTouchUpInside];
    //        }
    //    }
    
    
}

- (void)onDiscription:(UIButton *)btn
{
    if( isFinish == NO )
    {
        ALERT(nil, @"문제를 먼저 풀어주세요", nil, @"확인", nil);
        return;
    }
    
    
    
    
    
    
    //    NSDictionary *dic = [self.arM_List firstObject];
    //    QuestionDiscriptionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionDiscriptionViewController"];
    //    vc.ar_Info = [dic objectForKey:@"examExplainInfos"];
    //    vc.str_ImagePreFix = self.str_ImagePreFix;
    //
    //
    //    CATransition* transition = [CATransition animation];
    //    transition.duration = .7f;
    //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    transition.type = kCATransitionFade;
    //    transition.subtype = kCATransitionFromRight;
    //
    //    [self.view.layer addAnimation:transition forKey:nil];
    //    [self.view endEditing:YES];
    //    [self addChildViewController:vc];
    //    [self addConstraintsForViewController:vc];
    
    
    
    
    
    
    
    
    
//    [[NSUserDefaults standardUserDefaults] setObject:self.str_StartIdx forKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1] forKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *dic = [self.arM_List firstObject];
    QuestionDiscriptionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionDiscriptionViewController"];
    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
    vc.ar_Info = [dic objectForKey:@"examExplainInfos"];
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }

//    vc.str_ImagePreFix = self.str_ImagePreFix;
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - IBAction
- (IBAction)goMenu:(id)sender
{
    //    self.tbv_List. = UIEdgeInsetsMake(0, 0, -1000, 0);
    
    //    isAnswerShow = YES;
    
    self.btn_Menu.alpha = NO;
    
    NSDictionary *dic = [self.arM_List firstObject];
    str_MultipleChoice = [dic objectForKey:@"isMultipleChoice"];
    nCorrectCnt = [[dic objectForKey:@"correctAnswerCount"] integerValue];
    if( [str_MultipleChoice isEqualToString:@"N"] )
    {
        //주관식일 경우
        //답 갯수
        nCellCount = 1+nCorrectCnt;
    }
    else
    {
        //주관식이 아닐 경우 3개
        nCellCount = 2;
    }
    
    //    [self.tbv_List reloadData];
    [self.tbv_Answer reloadData];
    self.tbv_Answer.hidden = NO;
    self.lc_AnswerHeight.constant = self.tbv_Answer.contentSize.height;
}


//- (void)onInfo:(UIButton *)btn
//{
//    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.tbv_List];
//    
//    NSDictionary *dic = [self.arM_List firstObject];
//    
//    NSMutableString *strM_Msg = [NSMutableString string];
//    
//    //과목
//    NSString *str_SubjectName = [NSString stringWithFormat:@"과목 : %@", [self.dic_PackageInfo objectForKey:@"subjectName"]];
//    [strM_Msg appendString:str_SubjectName];
//    
//    //정답율
//    NSInteger nUserCorrectAnswerCnt = [[dic objectForKey:@"userCorrectAnswerCount"] integerValue];
//    NSInteger nTotalAnswerCnt = [[dic objectForKey:@"totalAnswerCount"] integerValue];
//    
//    CGFloat fVal = (CGFloat)nUserCorrectAnswerCnt / (CGFloat)nTotalAnswerCnt;
//    if( isnan(fVal) )
//    {
//        fVal = .0f;
//    }
//    NSInteger nPer = fVal * 100;
//    NSString *str_CorrectAnswer = [NSString stringWithFormat:@"정답율 : %ld%%", nPer];
//    [strM_Msg appendString:@"\n"];
//    [strM_Msg appendString:str_CorrectAnswer];
//    
//    //이 문제를 푼 사람
//    NSString *str_TotalAnswerCnt = [NSString stringWithFormat:@"이 문제를 푼 사람 : %ld명", nTotalAnswerCnt];
//    [strM_Msg appendString:@"\n"];
//    [strM_Msg appendString:str_TotalAnswerCnt];
//    
//    //이 문제를 맞힌 사람
//    NSString *str_UserCorrentAnswerCnt = [NSString stringWithFormat:@"이 문제를 맞힌 사람 : %ld명", nUserCorrectAnswerCnt];
//    [strM_Msg appendString:@"\n"];
//    [strM_Msg appendString:str_UserCorrentAnswerCnt];
//    
//    
//    //    //과목
//    //    NSString *str_Target = [NSString stringWithFormat:@"과목 : %@", [dic_ExamInfo objectForKey:@"subjectName"]];
//    //    [strM_Msg appendString:str_Target];
//    //
//    //    //단원
//    //    NSInteger nGroupId = [[dic_ExamInfo objectForKey:@"groupId"] integerValue];
//    //    if( nGroupId > 0 )
//    //    {
//    //        [strM_Msg appendString:@"\n"];
//    //        NSString *str_Group = [NSString stringWithFormat:@"단원 : %@", [dic_ExamInfo objectForKey:@"groupName"]];
//    //        [strM_Msg appendString:str_Group];
//    //    }
//    //
//    //    //정답율
//    //    NSInteger nUserCorrectAnswerCnt = [[dic_SampleQuestionInfo objectForKey:@"userCorrectAnswerCount"] integerValue];
//    //    NSInteger nTotalAnswerCnt = [[dic_SampleQuestionInfo objectForKey:@"totalAnswerCount"] integerValue];
//    //
//    //    CGFloat fVal = (CGFloat)nUserCorrectAnswerCnt / (CGFloat)nTotalAnswerCnt;
//    //    if( isnan(fVal) )
//    //    {
//    //        fVal = .0f;
//    //    }
//    //    NSInteger nPer = fVal * 100;
//    //    NSString *str_CorrectAnswer = [NSString stringWithFormat:@"정답율 : %ld%%", nPer];
//    //    [strM_Msg appendString:@"\n"];
//    //    [strM_Msg appendString:str_CorrectAnswer];
//    //
//    //    //이 문제를 푼 사람
//    //    NSString *str_TotalAnswerCnt = [NSString stringWithFormat:@"이 문제를 푼 사람 : %ld명", nTotalAnswerCnt];
//    //    [strM_Msg appendString:@"\n"];
//    //    [strM_Msg appendString:str_TotalAnswerCnt];
//    //    
//    //    //이 문제를 맞힌 사람
//    //    NSString *str_UserCorrentAnswerCnt = [NSString stringWithFormat:@"이 문제를 맞힌 사람 : %ld명", nUserCorrectAnswerCnt];
//    //    [strM_Msg appendString:@"\n"];
//    //    [strM_Msg appendString:str_UserCorrentAnswerCnt];
//    
//    
//    self.popTip.popoverColor = kMainColor;
//    //    static int direction = 0;
//    [self.popTip showText:strM_Msg direction:AMPopTipDirectionDown maxWidth:200 inView:self.tbv_List fromFrame:CGRectMake(buttonPosition.x, buttonPosition.y, btn.frame.size.width, btn.frame.size.height) duration:0];
//    //    direction = (direction + 1) % 4;
//    
//}

- (IBAction)goDiscription:(id)sender
{
    [self onDiscription:nil];
}



- (void)onInfo:(UIButton *)btn
{
    __weak __typeof(&*self)weakSelf = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    SideMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
    vc.str_TesterId = [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]];
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_Idx = self.str_Idx;
    }

    vc.str_StartNo = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
    vc.str_ChannelId = self.str_ChannelId;
    [vc setCompletionBlock:^(id completeResult) {
        
        NSDictionary *dic = [completeResult objectForKey:@"obj"];
        self.str_SortType = [completeResult objectForKey:@"type"];
        
        NSInteger nExamNo = [[dic objectForKey:@"examNo"] integerValue];
        weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo - 1];
        [weakSelf moveToPage:weakSelf.str_StartIdx];

//        if( nExamNo < [weakSelf.str_StartIdx integerValue] )
//        {
//            //이전
//            weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo];
//            [weakSelf moveToPrevPage:weakSelf.str_StartIdx];
//        }
//        else if( nExamNo > [weakSelf.str_StartIdx integerValue] )
//        {
//            //다음
//            weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo - 1];
//            [weakSelf moveToPage:weakSelf.str_StartIdx];
//        }
//        else
//        {
//            
//        }
    }];
    
    [self presentViewController:vc animated:NO completion:^{
        
    }];
}



















- (void)updateAnswerView
{
    id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
    if( [userCorrect isEqual:[NSNull null]] || [userCorrect integerValue] == 0 )
    {
        //안푼문제
        correctAnswerCount = [[self.dic_CurrentQuestion objectForKey:@"correctAnswerCount"] integerValue];
        //    correctAnswerCount = 2;
        
        if( correctAnswerCount > 1 )
        {
            self.lb_MultiAnswer.hidden = NO;

            CGRect frame = self.btn_Correct.frame;
            frame.origin.x = -20;
            frame.size.width = 50;
            self.btn_Correct.frame = frame;
            
            frame = self.btn_MyCorrect.frame;
            frame.origin.x = 15;
            frame.size.width = 50;
            self.btn_MyCorrect.frame = frame;
        }
        else
        {
            self.lb_MultiAnswer.hidden = YES;

            CGRect frame = self.btn_Correct.frame;
            frame.origin.x = -10;
            frame.size.width = 40;
            self.btn_Correct.frame = frame;
            
            frame = self.btn_MyCorrect.frame;
            frame.origin.x = 15;
            frame.size.width = 40;
            self.btn_MyCorrect.frame = frame;
        }

        //보기 갯수
        itemCount = [[self.dic_CurrentQuestion objectForKey:@"itemCount"] integerValue];
        
        //객관식 여부
        isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
        
        if( correctAnswerCount > 1 )
        {
            self.v_PageControllerView4.hidden = NO;
            self.v_PageControllerView2.hidden = YES;
        }
        else
        {
            self.v_PageControllerView4.hidden = YES;
            self.v_PageControllerView2.hidden = NO;
        }
        
        for( UIView *subView in self.v_Answer.subviews )
        {
            if( subView.tag > 0 )
            {
                subView.hidden = YES;
            }
        }
        
        for( UIView *subView in self.v_Answer.subviews )
        {
            if( subView.tag == itemCount )
            {
                self.v_Number = subView;
                break;
            }
        }
        
        self.v_Number.hidden = NO;
        for( id subView in self.v_Number.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn = (UIButton *)subView;
                if( btn.tag > 0 )
                {
                    btn.selected = NO;
                    btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                    [btn setBackgroundColor:[UIColor whiteColor]];
                    [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateSelected];
                }
            }
        }
        
        self.lc_AnswerBottom.constant = 0;
    }
    else
    {
        //푼문제
        self.lc_AnswerBottom.constant = -150;
    }
}

//////////////////////////////////////
- (IBAction)goAnswer:(id)sender
{
    //답 갯수
    correctAnswerCount = [[self.dic_CurrentQuestion objectForKey:@"correctAnswerCount"] integerValue];
    //    correctAnswerCount = 2;
    
    //보기 갯수
    itemCount = [[self.dic_CurrentQuestion objectForKey:@"itemCount"] integerValue];
    
    //객관식 여부
    isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
    
    if( isNumberQuestion )
    {
        if( correctAnswerCount > 1 )
        {
            self.v_PageControllerView4.hidden = NO;
            self.v_PageControllerView2.hidden = YES;
        }
        else
        {
            self.v_PageControllerView4.hidden = YES;
            self.v_PageControllerView2.hidden = NO;
        }
        
        for( UIView *subView in self.v_Answer.subviews )
        {
            if( subView.tag > 0 )
            {
                subView.hidden = YES;
            }
        }
        
        for( UIView *subView in self.v_Answer.subviews )
        {
            if( subView.tag == itemCount )
            {
                self.v_Number = subView;
                break;
            }
        }
        
        self.v_Number.hidden = NO;
        for( id subView in self.v_Number.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn = (UIButton *)subView;
                if( btn.tag > 0 )
                {
                    btn.selected = NO;
                    btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                    [btn setBackgroundColor:[UIColor whiteColor]];
                    [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateSelected];
                }
            }
        }
        
//        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            self.lc_AnswerBottom.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            self.lc_AnswerNonNumberBottom.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)goAnswerClose:(id)sender
{
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        if( isNumberQuestion )
        {
            self.lc_AnswerBottom.constant = -150;
        }
        else
        {
            [self.view endEditing:YES];
            self.lc_AnswerNonNumberBottom.constant = -150;
        }
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)goSelectNumber:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    str_MyCorrect = [NSMutableString string];
    
    if( correctAnswerCount > 1 )
    {
        //다중 답일 경우
        if( btn.selected )
        {
            if( [btn.backgroundColor isEqual:kMainColor] )
            {
                btn.selected = NO;
                btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn setBackgroundColor:[UIColor whiteColor]];
            }
            else
            {
                [btn setBackgroundColor:kMainColor];
                
                NSInteger nSelectedCnt = 0;
                UIView *superView = [btn superview];
                for( UIButton *btn_Sub in superView.subviews )
                {
                    if( btn_Sub.selected && [btn_Sub.backgroundColor isEqual:kMainColor] )
                    {
                        nSelectedCnt++;
                        
                        [str_MyCorrect appendString:btn_Sub.titleLabel.text];
                        [str_MyCorrect appendString:@","];
                    }
                }
                
                if( [str_MyCorrect hasSuffix:@","] )
                {
                    [str_MyCorrect deleteCharactersInRange:NSMakeRange([str_MyCorrect length]-1, 1)];
                }
                
                //정답 갯수와 같으면 정답 전송
                if( nSelectedCnt == correctAnswerCount )
                {
                    //정답 갯수와 같음, 서버로 전송!
                    //우선 내가 선택한 답을 빨간색으로
                    NSArray *ar_CorrectTmp = [str_MyCorrect componentsSeparatedByString:@","];
                    UIView *superView = [btn superview];
                    for( UIButton *btn_Sub in superView.subviews )
                    {
                        if( btn_Sub.selected )
                        {
                            for( NSInteger i = 0; i < ar_CorrectTmp.count; i++ )
                            {
                                if( [btn_Sub.titleLabel.text isEqualToString:[ar_CorrectTmp objectAtIndex:i]] )
                                {
                                    [btn_Sub setBackgroundColor:[UIColor whiteColor]];
                                    btn_Sub.layer.borderColor = [UIColor redColor].CGColor;
                                    [btn_Sub setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                    [btn_Sub setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                                }
                            }
                        }
                    }
                    
                    //정답은 파란색으로
                    NSString *str_CorrectTmp = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                    ar_CorrectTmp = [str_CorrectTmp componentsSeparatedByString:@","];
                    for( UIButton *btn_Sub in superView.subviews )
                    {
                        if( btn_Sub.selected )
                        {
                            for( NSInteger i = 0; i < ar_CorrectTmp.count; i++ )
                            {
                                if( [btn_Sub.titleLabel.text isEqualToString:[ar_CorrectTmp objectAtIndex:i]] )
                                {
                                    //정답이면
                                    [btn_Sub setBackgroundColor:kMainColor];
                                    btn_Sub.layer.borderColor = kMainColor.CGColor;
                                    [btn_Sub setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                    [btn_Sub setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                                }
                            }
                        }
                    }
                    
                    
                    if( [str_CorrectTmp isEqualToString:str_MyCorrect] == NO )
                    {
                        //오답이면 진동
#if !TARGET_IPHONE_SIMULATOR
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
                    }
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
                    if( self.isWrong || self.isStar )
                    {
                        [self onShowResult:dic];
                    }
                    else
                    {
                        [self sendCorrect:dic];
                    }
                }
            }
        }
        else
        {
            [btn setBackgroundColor:[UIColor colorWithHexString:@"FFFF00"]];
            btn.selected = YES;
        }
    }
    else
    {
        UIView *superView = [btn superview];
        for( UIButton *btn_Sub in superView.subviews )
        {
            if( btn != btn_Sub )
            {
                btn_Sub.selected = NO;
                btn_Sub.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn_Sub setBackgroundColor:[UIColor whiteColor]];
            }
        }
        
        if( btn.selected )
        {
            if( self.dic_CurrentQuestion == nil )   return;
            
            UIView *superView = [btn superview];
            for( UIButton *btn_Sub in superView.subviews )
            {
                btn_Sub.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn_Sub setBackgroundColor:[UIColor whiteColor]];
            }
            
            //두번째 선택일 경우
            NSInteger nCorrect = [[self.dic_CurrentQuestion objectForKey:@"correctAnswer"] integerValue];
            str_MyCorrect = [NSMutableString stringWithString:btn.titleLabel.text];
            if( [[self.dic_CurrentQuestion objectForKey:@"correctAnswer"] isEqualToString:str_MyCorrect] == NO )
            {
                //정답이 아닐 경우
                [btn setBackgroundColor:[UIColor whiteColor]];
                btn.layer.borderColor = [UIColor redColor].CGColor;
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                
                //바이브레이션
#if !TARGET_IPHONE_SIMULATOR
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
            }
            
            //정답표현
            UIButton *btn_Correct = nil;
            for( UIView *v_Sub in self.v_Number.subviews )
            {
                if( v_Sub.tag > 0 )
                {
                    if( v_Sub.tag == nCorrect )
                    {
                        btn_Correct = (UIButton *)v_Sub;
                    }
                }
            }
            [btn_Correct setBackgroundColor:kMainColor];
            btn_Correct.layer.borderColor = kMainColor.CGColor;
            [btn_Correct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn_Correct setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
            if( self.isWrong || self.isStar )
            {
                [self onShowResult:dic];
            }
            else
            {
                [self sendCorrect:dic];
            }
        }
        else
        {
            UIView *superView = [btn superview];
            
            for( UIButton *btn in superView.subviews )
            {
                btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn setBackgroundColor:[UIColor whiteColor]];
            }
            
            [btn setBackgroundColor:[UIColor colorWithHexString:@"FFFF00"]];
            btn.selected = YES;
        }
    }
    
    
    /////////페이지컨트롤러//////////
    NSInteger nBlueCnt = 0;
    NSInteger nYellowCnt = 0;
    UIView *superView = [btn superview];
    for( UIButton *btn_Sub in superView.subviews )
    {
        if( [btn_Sub.backgroundColor isEqual:kMainColor] )
        {
            nBlueCnt++;
        }
        
        if( [btn_Sub.backgroundColor isEqual:[UIColor colorWithHexString:@"FFFF00"]] )
        {
            nYellowCnt++;
        }
        
    }
    
    self.v_PageControllerView4.btn_1.selected = self.v_PageControllerView4.btn_2.selected =
    self.v_PageControllerView4.btn_3.selected = self.v_PageControllerView4.btn_4.selected = NO;
    
    NSInteger nFillCnt = (nBlueCnt * 2) + (nYellowCnt > 0 ? 1 : 0);
    NSLog(@"nFillCnt : %ld", nFillCnt);
    if( nFillCnt == 1 )
    {
        self.v_PageControllerView4.btn_1.selected = YES;
        
        self.v_PageControllerView2.btn_1.selected = YES;
    }
    else if( nFillCnt == 2 )
    {
        self.v_PageControllerView4.btn_1.selected = YES;
        self.v_PageControllerView4.btn_2.selected = YES;
        
        self.v_PageControllerView2.btn_1.selected = YES;
        self.v_PageControllerView2.btn_2.selected = YES;
    }
    else
    {
        if( correctAnswerCount > 1 )
        {
            if( nFillCnt == 3 )
            {
                self.v_PageControllerView4.btn_1.selected = YES;
                self.v_PageControllerView4.btn_2.selected = YES;
                self.v_PageControllerView4.btn_3.selected = YES;
            }
            else if( nFillCnt == 4 )
            {
                self.v_PageControllerView4.btn_1.selected = YES;
                self.v_PageControllerView4.btn_2.selected = YES;
                self.v_PageControllerView4.btn_3.selected = YES;
                self.v_PageControllerView4.btn_4.selected = YES;
            }
        }
    }
    ////////////////////////
}
//https://drive.google.com/open?id=0B2tAUSvs4Xo_NWtKaEJPWHNyekk
//https://drive.google.com/open?id=0B2tAUSvs4Xo_UFBsVjgyUVdiSmc
//https://drive.google.com/drive/folders/0B2tAUSvs4Xo_UFBsVjgyUVdiSmc?usp=sharing
//https://drive.google.com/open?id=0B2tAUSvs4Xo_a0d0T09NeXR3RFE
//https://drive.google.com/file/d/0B2tAUSvs4Xo_a0d0T09NeXR3RFE/view?usp=sharing
//https://drive.google.com/open?id=0B2tAUSvs4Xo_UFBsVjgyUVdiSmc
//
//https://drive.google.com/file/d/0B2tAUSvs4Xo_cDhYX1FvcTBJclU/view?usp=sharing
//
//https://drive.google.com/drive/folders/0B2tAUSvs4Xo_UFBsVjgyUVdiSmc?usp=sharing
//https://drive.google.com/file/d/0B2tAUSvs4Xo_cDhYX1FvcTBJclU/view?usp=sharing
//
//https://drive.google.com/file/d/0B2tAUSvs4Xo_ZDRadVBqWFdSZms/view?usp=sharing
//
//
//https://googledrive.com/host/0B2tAUSvs4Xo_ZDRadVBqWFdSZms
//
//https://drive.google.com/open?id=0B2tAUSvs4Xo_ZDRadVBqWFdSZms

//https://drive.google.com/file/d/0B2tAUSvs4Xo_eDlUV0VORkQ4VVU/view?usp=sharing
//https://drive.google.com/open?id=0B2tAUSvs4Xo_eDlUV0VORkQ4VVU
//https://drive.google.com/open?id=0B2tAUSvs4Xo_a0d0T09NeXR3RFE
//itms-services://?action=download-manifest&url=https://googledrive.com/host/0B2tAUSvs4Xo_eDlUV0VORkQ4VVU
//
//itms-services://?action=download-manifest&url=https://drive.google.com/open?id=0B2tAUSvs4Xo_eDlUV0VORkQ4VVU
//
//https://drive.google.com/open?id=0B2tAUSvs4Xo_eDlUV0VORkQ4VVU
//https://drive.google.com/open?id=0B2tAUSvs4Xo_a0d0T09NeXR3RFE
- (void)sendCorrect:(NSDictionary *)dic
{
    //여기 (오답문제다시풀기시 정답전송은 서버로 보내지 않게 수정)
//    if( [self.str_SortType isEqualToString:@"inCorrectQuestionSolve"] )
//    {
//        //오답문제 다시 풀기
//        //이 경우엔 정답을 서버에 전송하지 않고 보여만 줌
//        self.v_Correct.alpha = YES;
//        self.v_Correct.hidden = NO;
//        self.btn_Menu.hidden = YES;
//
//        NSString *str_Correct = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
//
//        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
//        if( isNumberQuestion )
//        {
//            NSString *str_UserCorrect = [str_MyCorrect stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            [dicM setObject:str_UserCorrect forKey:@"user_correct"];
//            
//            self.lb_StringCorrent.hidden = YES;
//            self.lb_StringMyCorrent.hidden = YES;
//            
//            self.btn_Correct.hidden = NO;
//            self.btn_MyCorrect.hidden = NO;
//            
//            str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
//            [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
//            [self.btn_MyCorrect setTitle:str_UserCorrect forState:UIControlStateNormal];
//
//            if( [str_Correct isEqualToString:str_UserCorrect] )
//            {
//                //객관식 정답이면
//                [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"4388FA"]];
//            }
//            else
//            {
//                //객관식 오답이면
//                [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
//            }
//
//
//        }
//        else
//        {
//            [dicM setObject:str_MyCorrect forKey:@"user_correct"];
//
//            self.lb_StringCorrent.hidden = NO;
//            self.lb_StringMyCorrent.hidden = NO;
//            
//            self.btn_Correct.hidden = YES;
//            self.btn_MyCorrect.hidden = YES;
//
//            if( [str_Correct isEqualToString:self.tf_NonNumberAnswer1.text] )
//            {
//                //주관식 정답이면
//                self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"4388FA"];
//            }
//            else
//            {
//                //주관식 오답이면
//                self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];
//            }
//            
//        }
//        
//        self.lc_AnswerNonNumberBottom.constant = -150.f;
//        self.lc_AnswerBottom.constant = -150;
//
//        self.dic_CurrentQuestion = [NSDictionary dictionaryWithDictionary:dicM];
//
//        return;
//    }
    
    
    if( isNumberQuestion )
    {
        NSString *str_UserCorrect = [str_MyCorrect stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            //                                        [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                            [NSString stringWithFormat:@"%@", [self.dic_ExamUserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                            str_UserCorrect, @"userAnswer", //사용자가 입력한 답
                                            [NSString stringWithFormat:@"%ld", self.vc_Parent.nTime * 1000], @"examLapTime",  //경과시간
                                            @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                            [NSString stringWithFormat:@"%ld", self.ar_Question.count], @"totalQuestionCount", //전체문제수
                                            @"on", @"setMode",
                                            nil];
        
        __weak __typeof(&*self)weakSelf = self;
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                [weakSelf onShowResult:dic];
                                                isUpdateLayout = YES;
                                                [weakSelf updateList];
                                                
                                                [self performSelector:@selector(onShowResultIfNeed:) withObject:resulte afterDelay:0.1f];
                                            }
                                        }];
    }
    else
    {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
        if( self.isWrong || self.isStar )
        {
            [self onShowResult:dic];
            return;
        }

        __weak __typeof(&*self)weakSelf = self;
        
        //주관식이면
        str_MyCorrect = [NSMutableString string];
        NSString *str_CorrectTmp = [dic objectForKey:@"correctAnswer"];
        [str_MyCorrect appendString:self.tf_NonNumberAnswer1.text];
        
        self.lb_StringCorrent.text = @"";
        self.lb_StringMyCorrent.text = @"";
        
        if( [str_CorrectTmp isEqualToString:str_MyCorrect] == NO )
        {
            //오답이면 진동
#if !TARGET_IPHONE_SIMULATOR
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
            self.lb_StringMyCorrent.text = str_MyCorrect;
        }
        else
        {

        }
        
        self.lb_StringCorrent.text = str_CorrectTmp;
        
        
        NSString *str_Tmp = self.tf_NonNumberAnswer1.text;
        NSArray *ar_MyCorrent = [str_Tmp componentsSeparatedByString:@","];
        //TODO: 정답전송
        NSMutableString *strM_Correct = [NSMutableString string];
        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
        
        NSArray *ar_Sep = [str_Correct componentsSeparatedByString:@","];
        
        if( ar_MyCorrent.count < ar_Sep.count )
        {
            [self.navigationController.view makeToast:[NSString stringWithFormat:@"정답이 %ld개 입니다\n,로 구분해서 입력해 주세요", ar_Sep.count] withPosition:kPositionCenter];
            self.lb_StringCorrent.text = @"";
            self.lb_StringMyCorrent.text = @"";
            self.btn_Menu.hidden = NO;
            return;
        }
        
        [self.view endEditing:YES];
        self.btn_Menu.hidden = YES;
        
        for( NSInteger i = 0; i < ar_Sep.count; i++ )
        {
            NSString *str_Tmp = ar_Sep[i];
            NSArray *ar_Tmp = [str_Tmp componentsSeparatedByString:@"-"];
            if( ar_Tmp.count > 1 )
            {
                NSString *str_Number = ar_Tmp[0];
                str_Number = [str_Number stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [strM_Correct appendString:str_Number];
                [strM_Correct appendString:@"-"];
                
                NSString *str_Tmp = ar_MyCorrent[i];
                NSString *str_MyCorrectTmp = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [strM_Correct appendString:str_MyCorrectTmp];
                [strM_Correct appendString:@"-"];
                [strM_Correct appendString:@"1"];
                [strM_Correct appendString:@","];
            }
            else
            {
                NSString *str_Tmp = ar_MyCorrent[i];
                NSString *str_MyCorrectTmp = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [strM_Correct appendString:str_MyCorrectTmp];
                [strM_Correct appendString:@","];
            }
        }
        
        if( [strM_Correct hasSuffix:@","] )
        {
            [strM_Correct deleteCharactersInRange:NSMakeRange([strM_Correct length]-1, 1)];
        }
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            [NSString stringWithFormat:@"%@", [self.dic_ExamUserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                            strM_Correct, @"userAnswer", //사용자가 입력한 답
                                            [NSString stringWithFormat:@"%ld", self.vc_Parent.nTime * 1000], @"examLapTime",  //경과시간
                                            @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                            [NSString stringWithFormat:@"%ld", self.ar_Question.count], @"totalQuestionCount", //전체문제수
                                            @"on", @"setMode",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                //                                                    //                                            [self.dicM_Parameter setObject:@"solve" forKey:@"solveMode"];
                                                //
                                                //                                                    [weakSelf onShowResult:dic];
                                                [weakSelf updateList];
                                                
                                                self.lb_StringCorrent.hidden = self.lb_StringMyCorrent.hidden = NO;
                                                self.lb_StringCorrent.alpha = self.lb_StringMyCorrent.alpha = YES;
                                                
                                                [self performSelector:@selector(onShowResultIfNeed:) withObject:resulte afterDelay:0.1f];
                                            }
                                        }];
        
        self.tf_NonNumberAnswer1.text = @"";
        self.tf_NonNumberAnswer2.text = @"";
        
    }
}

- (void)onShowResultIfNeed:(NSDictionary *)dic
{
    NSString *str_IsExamFinish = [dic objectForKey:@"isExamFinish"];
    if( [str_IsExamFinish isEqualToString:@"Y"] )
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"결과를 확인하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if( buttonIndex == 0 )
            {
                [self showResultView];
            }
        }];
    }
}

//- (void)onUpdateInterval
//{
//    [self updateList];
////    [self updateQuestionStatusWithUpdateCount:NO];
//}


- (void)onShowResult:(NSDictionary *)dic
{
    [self goAnswerClose:nil];
    
    isNumberQuestion = [[dic objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
    
    if( isNumberQuestion == NO )
    {
        if( self.isWrong || self.isStar )
        {
            self.btn_Menu.hidden = YES;
            self.v_Correct.hidden = YES;

            self.lb_StringCorrent.hidden = self.lb_StringMyCorrent.hidden = NO;
            self.lb_StringCorrent.alpha = self.lb_StringMyCorrent.alpha = YES;

            self.lb_StringCorrent.text = [dic objectForKey:@"correctAnswer"];
            self.lb_StringMyCorrent.text = self.tf_NonNumberAnswer1.text;
            
//            if( [self.lb_StringCorrent.text isEqualToString:self.lb_StringMyCorrent.text] )
//            {
//                //맞은 문제는 내 정답 표시하지 않는다
//                self.lb_StringMyCorrent.text = @"";
//            }

            if( [self.lb_StringCorrent.text isEqualToString:self.lb_StringMyCorrent.text] )
            {
                //맞은 문제는 내 정답 표시하지 않는다
                //                                                                self.lb_StringMyCorrent.text = @"";
                self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"4388FA"];
            }
            else
            {
                self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];
            }
            
            self.lb_StringCorrent.layer.borderWidth = 1.f;
            self.lb_StringCorrent.layer.borderColor = [UIColor lightGrayColor].CGColor;

        }

    }
    else
    {
        if( self.isWrong || self.isStar )
        {
            self.v_Correct.alpha = YES;
        }
        
        self.btn_Menu.hidden = YES;
        self.v_Correct.hidden = NO;
        
        [self.btn_Correct setBackgroundColor:[UIColor whiteColor]];
        [self.btn_Correct setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        self.btn_Correct.layer.cornerRadius = self.btn_Correct.frame.size.width / 2;
        self.btn_Correct.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
        self.btn_Correct.layer.borderWidth = 1.f;

        
        [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];

        self.btn_MyCorrect.layer.cornerRadius = self.btn_MyCorrect.frame.size.width / 2;
        self.btn_MyCorrect.layer.borderColor = [UIColor whiteColor].CGColor;
        self.btn_MyCorrect.layer.borderWidth = 1.f;
        
        self.btn_Correct.hidden = self.btn_MyCorrect.hidden = NO;
        
        if( [[dic objectForKey:@"correctAnswer"] integerValue] == [str_MyCorrect integerValue] )
            //    if( [[dic objectForKey:@"correctAnswer"] isEqualToString:str_MyCorrect] )
        {
//            self.btn_MyCorrect.hidden = YES;
            [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"4388FA"]];
        }
        else
        {
            self.btn_MyCorrect.hidden = NO;
            [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
        }
        
        [self.btn_MyCorrect setTitle:str_MyCorrect forState:UIControlStateNormal];
        
        
        NSString *str_Correct = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
        str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
        [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
        
        
        for( UIButton *btn in self.v_Number.subviews )
        {
            if( btn.tag > 0 )
            {
                btn.selected = NO;
            }
        }
    }
}

- (IBAction)goStarToggle:(id)sender
{
    if( self.isStar )
    {
        //별표 리스트일 경우엔 별표 리스트 삭제를 누른 효과와 동일하게 작동하게
        [self onWrongCheckSelected:nil];
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                        !self.btn_Star.selected ? @"on" : @"off", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/question/star"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                if( self.btn_Star.selected )
                                                {
                                                    self.btn_Star.selected = NO;
                                                    
                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
                                                    NSInteger nStarCnt = [[dicM objectForKey:@"existStarCount"] integerValue];
                                                    if( nStarCnt > 0 )
                                                    {
                                                        [dicM setObject:[NSString stringWithFormat:@"%ld", --nStarCnt] forKey:@"existStarCount"];
                                                    }
                                                    self.dic_CurrentQuestion = dicM;
                                                    
//                                                    [self.ar_Question replaceObjectAtIndex:self.nCurrentIdx withObject:self.dic_CurrentQuestion];
//                                                    [self updateQuestionStatus];

                                                    NSInteger nStarCount = [self.btn_Star.titleLabel.text integerValue];
                                                    nStarCount--;
                                                    [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", nStarCount] forState:UIControlStateNormal];

                                                    self.view.userInteractionEnabled = YES;
                                                }
                                                else
                                                {
                                                    self.iv_Star.hidden = NO;
                                                    [self performSelector:@selector(onMoveStar) withObject:nil afterDelay:0.5f];
                                                    
                                                    NSInteger nStarCount = [self.btn_Star.titleLabel.text integerValue];
                                                    nStarCount++;
                                                    [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", nStarCount] forState:UIControlStateNormal];
                                                }
                                            }
                                        }
                                        else
                                        {
                                            self.view.userInteractionEnabled = YES;
                                        }
                                    }];
}

- (void)onMoveStar
{
    [UIView animateWithDuration:1.0f animations:^{
        
        self.iv_Star.frame = CGRectMake(80, self.view.bounds.size.height - 35, 25, 25);
    }completion:^(BOOL finished) {
        
        self.iv_Star.hidden = YES;
        self.iv_Star.frame = CGRectMake((self.view.bounds.size.width / 2) - 52, (self.view.bounds.size.height / 2) - 52, 104, 104);
        self.btn_Star.selected = YES;
        
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
        NSInteger nStarCnt = [[dicM objectForKey:@"existStarCount"] integerValue];
        [dicM setObject:[NSString stringWithFormat:@"%ld", ++nStarCnt] forKey:@"existStarCount"];
        self.dic_CurrentQuestion = dicM;
        
//        [self.ar_Question replaceObjectAtIndex:self.nCurrentIdx withObject:self.dic_CurrentQuestion];
//        [self updateQuestionStatus];
        
        self.view.userInteractionEnabled = YES;
    }];
}

- (IBAction)goShowComment:(id)sender
{
    isStopAudio = NO;
    [self.v_Audio pause];

    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1] forKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    QuestionDiscriptionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionDiscriptionViewController"];
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
    //    vc.ar_Info = [self.dic_CurrentQuestion objectForKey:@"examExplainInfos"];
//    vc.str_ExamId = self.str_Idx;
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }

    //    vc.str_ImagePreFix = self.str_ImagePreFix;
    //    [self.navigationController pushViewController:vc animated:YES];
    [self presentViewController:navi animated:YES completion:nil];
    
}

- (IBAction)goSideMenu:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    SideMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
    vc.str_TesterId = [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]];
    vc.str_Idx = self.str_Idx;
    vc.str_StartNo = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
    [vc setCompletionBlock:^(id completeResult) {
        
        NSDictionary *dic = [completeResult objectForKey:@"obj"];
        self.str_SortType = [completeResult objectForKey:@"type"];
        
        NSInteger nExamNo = [[dic objectForKey:@"examNo"] integerValue];
        weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo - 1];
        [weakSelf moveToPage:weakSelf.str_StartIdx];
        
        //        if( nExamNo < [weakSelf.str_StartIdx integerValue] )
        //        {
        //            //이전
        //            weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo];
        //            [weakSelf moveToPrevPage:weakSelf.str_StartIdx];
        //        }
        //        else if( nExamNo > [weakSelf.str_StartIdx integerValue] )
        //        {
        //            //다음
        //            weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo - 1];
        //            [weakSelf moveToPage:weakSelf.str_StartIdx];
        //        }
        //        else
        //        {
        //
        //        }
    }];
    
    [self presentViewController:vc animated:NO completion:^{
        
    }];
}

- (IBAction)goPlayToggle:(id)sender
{
    BOOL isPlaying = NO;
    if ((self.v_Audio.player.rate != 0) && (self.v_Audio.player.error == nil))
    {
        // player is playing
        isPlaying = YES;
    }

    if( self.btn_Time.selected )
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            self.v_Pause.alpha = NO;
            [self.v_Audio resume];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            self.v_Pause.alpha = YES;
            
            if( self.v_Audio )
            {
                [self.v_Audio pause];
            }
        }];
    }
    
    self.btn_Time.selected = !self.btn_Time.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPauseTimer" object:nil];
}

///////////////////////////////////////

- (IBAction)goShared:(id)sender
{
//    ALERT(nil, @"준비중 입니다.", nil, @"확인", nil);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
    SharedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SharedViewController"];
//    vc.str_ExamId = self.str_Idx;
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }
    //    questionId = 26467;
    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)onJoinMessageInterval
//{
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
//                                                                 @"userName":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]}
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    [SendBird sendMessage:@"join-chat" withData:jsonString];
//}

- (IBAction)goStringAnswerSend:(id)sender
{
    if( self.tf_NonNumberAnswer1.text.length > 0 )
    {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
        [self sendCorrect:dic];
    }
}

- (void)onQuesionBack:(NSNotification *)noti
{
    [self.v_Bottom deallocBottomView];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatReloadNoti" object:[self.dic_UserInfo objectForKey:@"testerId"]];

//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/exit/solve/exam"
//                                        param:dicM_Params
//                                   withMethod:@"POST"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                             if( resulte )
//                                             {
//                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatReloadNoti" object:nil];
//                                             }
//                                         }];
}

- (void)onWrongCheckSelected:(NSNotification *)noti
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]], @"questionId",
                                        nil];

    NSString *str_Path = @"";
    if( self.isWrong )
    {
        str_Path = @"v1/hide/incorrect/question";

        if( self.btn_Check.selected )
        {
            [dicM_Params setObject:@"show" forKey:@"actionType"];
        }
        else
        {
            [dicM_Params setObject:@"hide" forKey:@"actionType"];
        }
    }
    else
    {
        if( self.btn_Check.selected )
        {
            [dicM_Params setObject:@"on" forKey:@"setMode"];
        }
        else
        {
            [dicM_Params setObject:@"off" forKey:@"setMode"];
        }
        
        str_Path = @"v1/set/exam/question/star";
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSArray *ar = nil;
                                                if( self.isWrong )
                                                {
                                                    ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"inCorrectQuestionInfos"]];
                                                }
                                                else
                                                {
                                                    ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"starQuestionInfos"]];
                                                    
                                                    //하단 별표 카운트 업데이트                                                    
                                                    NSInteger nStartCnt = [self.btn_Star.titleLabel.text integerValue];
                                                    if( [[dicM_Params objectForKey:@"setMode"] isEqualToString:@"on"] )
                                                    {
                                                        self.btn_Star.selected = YES;
                                                        nStartCnt++;
                                                    }
                                                    else
                                                    {
                                                        self.btn_Star.selected = NO;
                                                        
                                                        nStartCnt--;
                                                        
                                                        if( nStartCnt < 0 )
                                                        {
                                                            nStartCnt = 0;
                                                        }
                                                    }
                                                    
                                                    [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", nStartCnt] forState:UIControlStateNormal];
                                                }
                                                
                                                for( NSInteger i = 0; i < ar.count; i++ )
                                                {
                                                    NSDictionary *dic = [ar objectAtIndex:i];
                                                    if( [[dic objectForKey:@"subjectName"] isEqualToString:self.str_SubjectName] )
                                                    {
                                                        self.str_SubjectTotalCount = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"questionCount"] integerValue]];
                                                        nNaviTotalCnt = [self.str_SubjectTotalCount integerValue];
                                                        self.lb_QTotalCnt.text = self.lb_PauseQTotalCnt.text = [NSString stringWithFormat:@"%ld", nNaviTotalCnt];
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNaviBar" object:@{@"title":self.lb_QTitle.text, @"totlaCount":self.lb_QTotalCnt.text, @"currentCount" : self.lb_QCurrentCnt.text}];
                                                    }
                                                }
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"WrongCheckNoti" object:nil];
//                                                [weakSelf performSelector:@selector(onNext) withObject:nil afterDelay:0.3f];
                                            }
                                        }
                                    }];
}

- (void)onNext
{
    if( nNaviNowCnt >= nNaviTotalCnt )
    {
        [self.navigationController.view makeToast:@"마지막 문제 입니다" withPosition:kPositionCenter];
        return;
    }
    
    [self moveToNextPage:str_CurrentExamNo];
}

- (IBAction)goPrev:(id)sender
{
    if( nNaviNowCnt <= 1 )
    {
        [self.navigationController.view makeToast:@"첫 문제 입니다" withPosition:kPositionCenter];
        return;
    }

    self.str_StartIdx = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] - 1];
    [self moveToPage:self.str_StartIdx];
}

- (IBAction)goNext:(id)sender
{
    if( nNaviNowCnt >= nNaviTotalCnt )
    {
        [self.navigationController.view makeToast:@"마지막 문제 입니다" withPosition:kPositionCenter];
        return;
    }

    self.str_StartIdx = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
    [self moveToPage:self.str_StartIdx];
}

- (IBAction)goAsk:(id)sender
{
    //질문
    NSDictionary *dic_ExamPackageInfo = self.dic_PackageInfo;
    __block NSString *str_TeacherId = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserId"]];
    __block NSString *str_TeacherName = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserName"]];
    __block NSString *str_TeacherImgUrl = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserThumbnail"]];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        @"", @"roomName",
                                        str_TeacherId, @"inviteUserIdStr",
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
                                                __block NSString *str_RId = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"rId"]];
                                                
                                                NSString *str_SBChannelUrl = [resulte objectForKey_YM:@"sendbirdChannelUrl"];
                                                NSString *str_TmpRId = [NSString stringWithFormat:@"%ld", [[resulte objectForKey_YM:@"rId"] integerValue]];
                                                if( str_SBChannelUrl.length > 0 && [str_TmpRId integerValue] > 0 )
                                                {
                                                    //기존 방이 있을 경우 기존걸 사용
                                                    [SBDGroupChannel getChannelWithUrl:str_SBChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                        
                                                        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                                        ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                                        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
                                                        navi.navigationBarHidden = YES;
                                                        vc.str_RId = str_RId;
                                                        vc.dic_Info = dic_QnaInfo;
                                                        //                                                        vc.str_RoomName = str_TeacherName;
                                                        vc.str_RoomTitle = str_TeacherName;
                                                        vc.str_RoomThumb = str_TeacherImgUrl;
                                                        vc.ar_UserIds = [NSArray arrayWithObject:str_TeacherId];
                                                        vc.channel = channel;
                                                        [self presentViewController:navi animated:YES completion:^{
                                                            
                                                        }];
                                                    }];
                                                }
                                                else
                                                {
                                                    NSMutableArray *arM_UserList = [NSMutableArray array];
                                                    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                                                    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
                                                    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
                                                    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
                                                    [arM_UserList addObject:dicM_MyInfo];
                                                    
                                                    NSMutableDictionary *dicM_OtherInfo = [NSMutableDictionary dictionary];
                                                    [dicM_OtherInfo setObject:[NSString stringWithFormat:@"%@", str_TeacherId] forKey:@"userId"];
                                                    [dicM_OtherInfo setObject:str_TeacherName forKey:@"userName"];
                                                    [dicM_OtherInfo setObject:str_TeacherImgUrl forKey:@"imgUrl"];
                                                    [arM_UserList addObject:dicM_OtherInfo];
                                                    
                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_QnaInfo];
                                                    [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                    
                                                    NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", @"1:1", str_RId];
                                                    
                                                    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
                                                    NSError * err;
                                                    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
                                                    NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                    
                                                    [SBDGroupChannel createChannelWithName:@"" isDistinct:NO userIds:@[str_TeacherId] coverUrl:@"" data:str_Dic customType:nil
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
                                                                             
                                                                             NSDictionary *dic_RoomInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"qnaRoomInfo"]];
                                                                             
                                                                             UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                                                             ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                                                             UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
                                                                             navi.navigationBarHidden = YES;
                                                                             vc.str_RId = str_RId;
                                                                             vc.dic_Info = dic_RoomInfo;
                                                                             vc.str_RoomName = str_ChannelName;
                                                                             vc.str_RoomTitle = nil;
                                                                             vc.str_RoomThumb = str_TeacherImgUrl;
                                                                             vc.ar_UserIds = [NSArray arrayWithObject:str_TeacherId];
                                                                             vc.channel = channel;
                                                                             [self presentViewController:navi animated:YES completion:^{
                                                                                 
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

@end
