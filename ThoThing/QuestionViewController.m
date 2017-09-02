//
//  QuestionViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 5. 17..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "QuestionViewController.h"
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
#import "QuestionCell.h"

#import "QuestionPauseViewController.h"

@import AVFoundation;
@import MediaPlayer;

#import "QuestionBottomViewController.h"
#import "PageControllerView2.h"
#import "ChatFeedViewController.h"

static NSString *kDownLoadLimit = @"50";

@interface QuestionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSInteger nQnaCount;
    NSInteger nOldPage;
}
@property (nonatomic, assign) NSInteger nCurrentPage;
@property (nonatomic, assign) NSInteger nStartIdx;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableDictionary *dicM_Info;
@property (nonatomic, strong) NSString *str_ImagePreFix;
@property (nonatomic, strong) NSString *str_UserThum;
@property (nonatomic, strong) NSMutableArray *arM_Audios;
@property (nonatomic, strong) NSString *str_AudioBody;
@property (nonatomic, strong) NSTimer *tm_Time;
@property (nonatomic, assign) NSInteger nTime;


//음성문제 관련
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
@property (nonatomic, strong) AudioView *v_Audio;
/////////

//비디오 관련
@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
///////////

//유튜브
@property (nonatomic, strong) YTPlayerView *playerView;


@property (nonatomic, weak) IBOutlet UIView *v_Navi;
@property (nonatomic, weak) IBOutlet UIView *v_Bottom;
@property (nonatomic, weak) IBOutlet UICollectionView *collection;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIView *v_Timer;
@property (nonatomic, weak) IBOutlet UIButton *btn_Time;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentQ;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalQ;

//바탐뷰
@property (nonatomic, weak) IBOutlet UIView *v_BottomSub;
@property (nonatomic, weak) IBOutlet UIButton *btn_ShowAnswer;
@property (nonatomic, weak) IBOutlet UIButton *btn_Star;
@property (nonatomic, weak) IBOutlet UIButton *btn_QnA;
@property (nonatomic, weak) IBOutlet PageControllerView4 *v_PageControllerView4;
@property (nonatomic, weak) IBOutlet PageControllerView2 *v_PageControllerView2;
@property (nonatomic, weak) IBOutlet UILabel *lb_MultiAnswer;

//답 입력 뷰
@property (nonatomic, weak) IBOutlet UIView *v_Answer;
@property (nonatomic, weak) IBOutlet UIView *v_AnswerItem;
@property (nonatomic, weak) IBOutlet UIButton *btn_AnswerDown;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerBottom;

//주관식 입력 뷰
@property (nonatomic, weak) IBOutlet UIView *v_NonNumberAnswer;
@property (nonatomic, weak) IBOutlet UITextField *tf_NonNumberAnswer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_NonNumberAnswerDoneWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_NonNumberAnswerBottom;
@property (nonatomic, weak) IBOutlet UILabel *lb_NonNumberMultiAnswer;
@property (nonatomic, weak) IBOutlet UIView *v_NonNumberCorrect;
@property (nonatomic, weak) IBOutlet UILabel *lb_NonNumberCorrect;
@property (nonatomic, weak) IBOutlet UILabel *lb_NonNumberMyCorrect;
@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lb_Title.text = self.str_Title;
    self.lb_CurrentQ.text = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
    
    self.tf_NonNumberAnswer.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_NonNumberAnswer.frame.size.height)];
    
    self.lc_AnswerBottom.constant = self.lc_NonNumberAnswerBottom.constant = -120.f;

    self.v_Timer.layer.cornerRadius = 20.f;
    self.v_Timer.layer.borderWidth = 1.f;
    self.v_Timer.layer.borderColor = [UIColor lightGrayColor].CGColor;

    self.arM_Audios = [NSMutableArray array];
    
    self.nStartIdx = [self.str_StartIdx integerValue];
    
    self.btn_ShowAnswer.hidden = YES;

    self.lb_NonNumberCorrect.layer.borderWidth = 0.5f;
    self.lb_NonNumberCorrect.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.tf_NonNumberAnswer addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    
    NSString *str_DataKey = [NSString stringWithFormat:@"Q_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSData *qData = [[NSUserDefaults standardUserDefaults] objectForKey:str_DataKey];
    NSArray *ar_Tmp = [NSKeyedUnarchiver unarchiveObjectWithData:qData];
    self.arM_List = [NSMutableArray arrayWithArray:ar_Tmp];
    
    NSString *str_InfoKey = [NSString stringWithFormat:@"QInfo_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSData *qInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:str_InfoKey];
    NSDictionary *dic_Tmp = [NSKeyedUnarchiver unarchiveObjectWithData:qInfoData];
    self.dicM_Info = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];
    
    if( self.arM_List && self.arM_List.count > 0 )
    {
        //저장된게 있으면
//        [self setOnceQData];
        
        [self downLoadData];
    }
    else
    {
        //저장된게 없으면
        [self downLoadData];

    }
    
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

- (void)viewWillLayoutSubviews;
{
    [super viewWillLayoutSubviews];
    UICollectionViewFlowLayout *flowLayout = (id)self.collection.collectionViewLayout;
    
    if (UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation))
    {
        flowLayout.itemSize = CGSizeMake(MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height),
                                         (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)) - self.v_Navi.frame.size.height - self.v_Bottom.frame.size.height + 29);
    }
    else
    {
        flowLayout.itemSize = CGSizeMake(MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height),
                                         (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)) - self.v_Navi.frame.size.height - self.v_Bottom.frame.size.height + 29);
    }
    
    [flowLayout invalidateLayout]; //force the elements to get laid out again with the new size
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft];
    //    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //    if( toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight )

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    self.collection.alpha = NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.collection.alpha = YES;
    
    if( fromInterfaceOrientation == UIDeviceOrientationLandscapeLeft || fromInterfaceOrientation == UIDeviceOrientationLandscapeRight )
    {
        //세로모드
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

        self.collection.contentOffset = CGPointMake(self.collection.frame.size.width * self.nCurrentPage, 0);

//        [UIView animateWithDuration:0.3f animations:^{
//            
//        }];

    }
    else
    {
        //가로모드
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

        self.collection.contentOffset = CGPointMake(self.view.frame.size.width * self.nCurrentPage, 0);

//        [UIView animateWithDuration:0.3f animations:^{
//            
//        }];

    }
    
    [self updateQuestionWithNonPassMode:NO];
    [self.collection reloadData];

    [self updateAudioView];
}

- (void)updateAudioView
{
    for( NSInteger i = 0; i < self.arM_Audios.count; i++ )
    {
        AudioView *tmp_Audio = [self.arM_Audios objectAtIndex:i];
        if ((tmp_Audio.player.rate != 0) && (tmp_Audio.player.error == nil))
        {
            //재생중인놈
            [tmp_Audio.player seekToTime:CMTimeMake(0, 1)];
            [tmp_Audio.player pause];
        }
    }

}

#pragma makr - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView == self.collection )
    {
        [self goDownAnswerView:nil];
        
        nOldPage = self.nCurrentPage;
        
        self.nCurrentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
        NSLog(@"self.nCurrentPage : %ld", self.nCurrentPage);
        [self didChangePage];
        
        self.collection.scrollEnabled = YES;
        
        [self updateQuestionWithNonPassMode:self.isNonPassMode];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( scrollView == self.collection )
    {
        NSInteger nPage = scrollView.contentOffset.x / scrollView.frame.size.width;
        if( nPage == self.nCurrentPage || (nPage + 1) == self.nCurrentPage )
        {
            scrollView.scrollEnabled = YES;
        }
        else
        {
            scrollView.scrollEnabled = NO;
        }
    }
}

- (void)didChangePage
{
    if( self.nCurrentPage == self.arM_List.count - 1 )
    {
        if( self.nCurrentPage < [self.lb_TotalQ.text integerValue] - 1 )
        {
            //마지막 페이지면 다음 문제 로드
            [self updateMoreList];
//            [self.collection reloadData];
        }
    }
    
    if( nOldPage != self.nCurrentPage )
    {
        [self stopAllContents];

        NSIndexPath *index = [NSIndexPath indexPathForRow:nOldPage inSection:0];
        //            [self.collection reloadItemsAtIndexPaths:@[index]];
    }
    
    self.lb_CurrentQ.text = [NSString stringWithFormat:@"%ld", self.nCurrentPage + 1];
    
    NSDictionary *dic = [self.arM_List objectAtIndex:self.nCurrentPage];
    [self updateBottomCount:dic];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateQuestionWithNonPassMode:(BOOL)isNonPass
{
    UIView *correctTmp = [self.v_BottomSub viewWithTag:100];
    if( correctTmp )
    {
        [correctTmp removeFromSuperview];
    }
    
    UIView *myCorrectTmp = [self.v_BottomSub viewWithTag:101];
    if( myCorrectTmp )
    {
        [myCorrectTmp removeFromSuperview];
    }
    
    for( id subview in self.v_AnswerItem.subviews )
    {
        [subview removeFromSuperview];
    }
    
//    [self.v_BottomSub viewWithTag:101];
    
    self.v_PageControllerView2.btn_1.selected = NO;
    self.v_PageControllerView2.btn_2.selected = NO;

    self.v_PageControllerView4.btn_1.selected = NO;
    self.v_PageControllerView4.btn_2.selected = NO;
    self.v_PageControllerView4.btn_3.selected = NO;
    self.v_PageControllerView4.btn_4.selected = NO;

    self.v_NonNumberCorrect.hidden = YES;

    if( self.nCurrentPage > 0 && self.arM_List.count <= self.nCurrentPage )
    {
        [self downLoadData];
        return;
    }
    
    NSDictionary *dic = [self.arM_List objectAtIndex:self.nCurrentPage];
    id userCorrect = [dic objectForKey:@"user_correct"];                                        //품 여부
    NSInteger correctAnswerCount = [[dic objectForKey:@"correctAnswerCount"] integerValue];     //답 갯수
    NSInteger nItemCount = [[dic objectForKey:@"itemCount"] integerValue];                      //하단 보기 갯수

    BOOL isNumberQuestion = [[dic objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
    if( isNumberQuestion )
    {
        if( isNonPass || [userCorrect isEqual:[NSNull null]] || [userCorrect integerValue] == 0 )
        {
            //안푼 문제
            
            /*********답 갯수에 따른 변화*********/
            if( correctAnswerCount > 1 )
            {
                //답이 두개일때
                self.lb_MultiAnswer.hidden = NO;
                self.v_PageControllerView4.hidden = NO;
                self.v_PageControllerView2.hidden = YES;
            }
            else
            {
                //답이 하나일때
                self.lb_MultiAnswer.hidden = YES;
                self.v_PageControllerView4.hidden = YES;
                self.v_PageControllerView2.hidden = NO;
            }
            /*******************************/


            /*********보기 아이템 붙이기*********/
            static NSInteger nItemWidth = 50;
            static NSInteger nItemMargin = 16;
            self.btn_ShowAnswer.hidden = NO;

            NSInteger nLeadingMargin = (self.v_AnswerItem.frame.size.width - (((nItemWidth + nItemMargin) * (nItemCount - 1)) + nItemWidth)) / 2;

            CGFloat fMargin = nLeadingMargin;
            for( NSInteger i = 0; i < nItemCount; i++ )
            {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = i + 1;
                btn.frame = CGRectMake(fMargin, 2, nItemWidth, nItemWidth);
                btn.backgroundColor = [UIColor whiteColor];
                [btn setTitle:[NSString stringWithFormat:@"%ld", i + 1] forState:UIControlStateNormal];
                [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.f]];
                [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateNormal];
                btn.layer.cornerRadius = nItemWidth / 2;
                btn.layer.borderWidth = 2.f;
                btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn addTarget:self action:@selector(onNumberSelected:) forControlEvents:UIControlEventTouchUpInside];
                
                fMargin = fMargin + nItemWidth + nItemMargin;
                
                [self.v_AnswerItem addSubview:btn];
            }
            /*******************************/
            
            
            [self goShowAnswerView:nil];
        }
        else
        {
            //푼 문제
            self.btn_ShowAnswer.hidden = YES;

            [self goDownAnswerView:nil];
            
            NSString *str_Correct = [dic objectForKey:@"correctAnswer"];    //답
            str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];

            NSString *str_MyCorrect = [dic objectForKey:@"user_correct"];   //나의 답
            str_MyCorrect = [str_MyCorrect stringByReplacingOccurrencesOfString:@"|" withString:@","];

            //(정답)(내답)
            //정답
            UIButton *btn_Correct = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_Correct.tag = 100;
            btn_Correct.frame = CGRectMake(self.view.frame.size.width - 80, 2, 40, 40);
            [btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
            btn_Correct.backgroundColor = [UIColor whiteColor];
            [btn_Correct.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:13.f]];
            [btn_Correct setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn_Correct.layer.cornerRadius = btn_Correct.frame.size.width/2;
            btn_Correct.layer.borderColor = [UIColor lightGrayColor].CGColor;
            btn_Correct.layer.borderWidth = 1.f;
            
            //내답
            UIButton *btn_MyCorrect = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_MyCorrect.tag = 101;
            btn_MyCorrect.frame = CGRectMake(self.view.frame.size.width - 48, 2, 40, 40);
            [btn_MyCorrect setTitle:str_MyCorrect forState:UIControlStateNormal];
            if( [str_Correct isEqualToString:str_MyCorrect] )
            {
                //맞았으면
                btn_MyCorrect.backgroundColor = kMainColor;
            }
            else
            {
                //틀렸으면
                btn_MyCorrect.backgroundColor = kMainRedColor;
            }
            [btn_MyCorrect.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:13.f]];
            [btn_MyCorrect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn_MyCorrect.layer.cornerRadius = btn_MyCorrect.frame.size.width/2;

            [self.v_BottomSub addSubview:btn_Correct];
            [self.v_BottomSub addSubview:btn_MyCorrect];

        }
    }
    else
    {
        //주관식
        if( isNonPass || [userCorrect isEqual:[NSNull null]] )
        {
            self.btn_ShowAnswer.hidden = NO;

            //안푼 문제
            /*********답 갯수에 따른 변화*********/
            if( correctAnswerCount > 1 )
            {
                //답이 두개일때
                self.lb_NonNumberMultiAnswer.hidden = NO;
            }
            else
            {
                //답이 하나일때
                self.lb_NonNumberMultiAnswer.hidden = YES;
            }
            /*******************************/

            if( self.tf_NonNumberAnswer.text.length > 0 )
            {
                self.lc_NonNumberAnswerDoneWidth.constant = 63.f;
            }
            else
            {
                self.lc_NonNumberAnswerDoneWidth.constant = 0.f;
            }
            
            [self goShowAnswerView:nil];
        }
        else
        {
            //푼 문제
            self.btn_ShowAnswer.hidden = YES;
            self.v_NonNumberCorrect.hidden = NO;
            
            [self goDownAnswerView:nil];
            
            NSString *str_Correct = [dic objectForKey:@"correctAnswer"];    //답
            str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.lb_NonNumberCorrect.text = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
            
            NSString *str_MyCorrect = [dic objectForKey:@"user_correct"];   //나의 답
            self.lb_NonNumberMyCorrect.text = [str_MyCorrect stringByReplacingOccurrencesOfString:@"|" withString:@","];
            
            if( [self.lb_NonNumberCorrect.text isEqualToString:self.lb_NonNumberMyCorrect.text] )
            {
                //정답
                self.lb_NonNumberMyCorrect.backgroundColor = kMainColor;
            }
            else
            {
                //오답
                self.lb_NonNumberMyCorrect.backgroundColor = kMainRedColor;
            }
        }
    }
}

- (void)onNumberSelected:(UIButton *)btn
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:[self.arM_List objectAtIndex:self.nCurrentPage]];
    NSInteger correctAnswerCount = [[dicM objectForKey:@"correctAnswerCount"] integerValue];     //답 갯수
    if( correctAnswerCount == 1 )
    {
        if( btn.selected )
        {
            //최종 선택
            self.v_PageControllerView2.btn_1.selected = YES;
            self.v_PageControllerView2.btn_2.selected = YES;
            
            NSInteger nCorrect = [[dicM objectForKey:@"correctAnswer"] integerValue];
            NSInteger nMyCorrect = btn.tag;
            
            //내 답을 먼저 표시 (화이트 빨강)
            
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitleColor:kMainRedColor forState:UIControlStateNormal];
            btn.layer.borderColor = kMainRedColor.CGColor;
            
            //정답을 표시 (블루 하얀)
            UIButton *btn_Correct = [self.v_AnswerItem viewWithTag:nCorrect];
            btn_Correct.backgroundColor = kMainColor;
            [btn_Correct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

            if( nCorrect == nMyCorrect )
            {
                btn_Correct.layer.borderColor = kMainColor.CGColor;
            }
            else
            {
#if !TARGET_IPHONE_SIMULATOR
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif

                btn_Correct.layer.borderColor = kMainColor.CGColor;
                btn.layer.borderColor = kMainRedColor.CGColor;
            }
            
            [self performSelector:@selector(goDownAnswerView:) withObject:nil afterDelay:0.3f];
            
            
            [dicM setObject:[NSString stringWithFormat:@"%ld", nMyCorrect] forKey:@"user_correct"];
            [self.arM_List replaceObjectAtIndex:self.nCurrentPage withObject:dicM];
            [self saveQuestion];

            [self updateQuestionWithNonPassMode:NO];

            if( self.isNonPassMode )  return;

            NSString *str_UserCorrect = [[NSString stringWithFormat:@"%ld", nMyCorrect] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                //                                        [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                                self.str_TesterId, @"testerId",   //답안지 ID
                                                [NSString stringWithFormat:@"%@", [dicM objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                                str_UserCorrect, @"userAnswer", //사용자가 입력한 답
                                                [NSString stringWithFormat:@"%ld", self.nTime], @"examLapTime",  //경과시간
                                                @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                                [NSString stringWithFormat:@"%@", [dicM objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                                [NSString stringWithFormat:@"%ld", [self.lb_TotalQ.text integerValue]], @"totalQuestionCount", //전체문제수
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
                                                    [weakSelf performSelector:@selector(onShowResultIfNeed:) withObject:resulte afterDelay:0.1f];
                                                }
                                            }];
            
            return;
        }
        
        for( id subView in self.v_AnswerItem.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn_Sub = (UIButton *)subView;
                btn_Sub.selected = NO;
                btn_Sub.backgroundColor = [UIColor whiteColor];
            }
        }
        
        self.v_PageControllerView2.btn_1.selected = YES;
        
        btn.selected = YES;
        btn.backgroundColor = [UIColor yellowColor];
    }
    else
    {
        if( [btn.backgroundColor isEqual:kMainColor] )
        {
            return;
        }
        
        if( [btn.backgroundColor isEqual:[UIColor yellowColor]] )
        {
            //한번 선택한 답
            btn.backgroundColor = kMainColor;
            btn.layer.borderColor = kMainColor.CGColor;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            self.v_PageControllerView4.btn_1.selected = YES;
            self.v_PageControllerView4.btn_2.selected = YES;
//            self.v_PageControllerView4.btn_3.selected = YES;

        }
        
        NSMutableString *strM_MyCorrect = [NSMutableString string];
        NSInteger nAnswerCount = 0;
        for( id subView in self.v_AnswerItem.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn_Sub = (UIButton *)subView;
                if( [btn_Sub.backgroundColor isEqual:kMainColor] )
                {
                    nAnswerCount++;
                    
                    [strM_MyCorrect appendString:btn_Sub.titleLabel.text];
                    [strM_MyCorrect appendString:@"|"];
                }
                
                if( [btn_Sub.backgroundColor isEqual:kMainColor] == NO )
                {
                    btn_Sub.backgroundColor = [UIColor whiteColor];
                }
            }
        }
        
        if( [strM_MyCorrect hasSuffix:@"|"] )
        {
            [strM_MyCorrect deleteCharactersInRange:NSMakeRange([strM_MyCorrect length]-1, 1)];
        }

        
        if( [btn.backgroundColor isEqual:kMainColor] == NO )
        {
            btn.backgroundColor = [UIColor yellowColor];
            
            if( nAnswerCount == 0 )
            {
                self.v_PageControllerView4.btn_1.selected = YES;
            }
            else if( nAnswerCount == 1 )
            {
                self.v_PageControllerView4.btn_1.selected = YES;
                self.v_PageControllerView4.btn_2.selected = YES;
                self.v_PageControllerView4.btn_3.selected = YES;
            }
        }
        
        if( nAnswerCount == 2 )
        {
            //두개 모두 입력 했을때
            NSString *str_Correct = [dicM objectForKey:@"correctAnswer"];
            if( [strM_MyCorrect isEqualToString:str_Correct] == NO )
            {
#if !TARGET_IPHONE_SIMULATOR
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
            }
            
            self.v_PageControllerView4.btn_1.selected = YES;
            self.v_PageControllerView4.btn_2.selected = YES;
            self.v_PageControllerView4.btn_3.selected = YES;
            self.v_PageControllerView4.btn_4.selected = YES;
            
            [self performSelector:@selector(goDownAnswerView:) withObject:nil afterDelay:0.3f];
            

            
            
            [dicM setObject:strM_MyCorrect forKey:@"user_correct"];
            [self.arM_List replaceObjectAtIndex:self.nCurrentPage withObject:dicM];
            [self saveQuestion];

            [self updateQuestionWithNonPassMode:NO];

            if( self.isNonPassMode )  return;

            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                //                                        [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                                self.str_TesterId, @"testerId",   //답안지 ID
                                                [NSString stringWithFormat:@"%@", [dicM objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                                strM_MyCorrect, @"userAnswer", //사용자가 입력한 답
                                                [NSString stringWithFormat:@"%ld", self.nTime], @"examLapTime",  //경과시간
                                                @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                                [NSString stringWithFormat:@"%@", [dicM objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                                [NSString stringWithFormat:@"%ld", [self.lb_TotalQ.text integerValue]], @"totalQuestionCount", //전체문제수
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
                                                    [weakSelf performSelector:@selector(onShowResultIfNeed:) withObject:resulte afterDelay:0.1f];
                                                }
                                            }];
        }
    }
}

- (void)downLoadData
{
    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dumpLoadQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.collection reloadData];
            
        });
    });

    __block BOOL isFirst = NO;
    __weak __typeof(&*self)weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_Idx, @"examId",
                                        @"testing", @"viewMode",   //풀기 상태 [testing-문제풀기, scoring-문제리뷰]
                                        @"", @"testerId",   //답안지 ID
                                        self.str_SortType ? self.str_SortType : @"all", @"questionType", //문제 형식 [all - 전체, inCorrectQuestion - 틀린문제, myStarQuestion - 내가 별표 한 문제, solveQuestion - 푼문제, nonSolveQuestion - 안푼 문제, manyQNAQuestion - 질문이 달린 문제]
                                        @"package", @"examMode", //문제 유형 [package - 일반문제, category - 단원문제]
                                        kDownLoadLimit, @"limitCount",
                                        @"solve", @"solveMode",
                                        nil];

    if( [self.str_SortType isEqualToString:@"inCorrectQuestionSolve"] )
    {
        [dicM_Params setObject:@"inCorrectQuestionSolve" forKey:@"questionType"];
    }
    
    if( self.arM_List == nil || self.arM_List.count == 0 )
    {
//        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.nStartIdx] forKey:@"firstExamNo"];
//        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.nStartIdx] forKey:@"lastExamNo"];
        [dicM_Params setObject:@"0" forKey:@"lastExamNo"];
        [dicM_Params setObject:@"next" forKey:@"scrollType"];
        
        //초기 로드시엔 20개만
        [dicM_Params setObject:@"20" forKey:@"limitCount"];

        isFirst = YES;
    }
    else
    {
        NSDictionary *dic_Tmp = [self.arM_List lastObject];
        NSInteger nLastExamNo = [[dic_Tmp objectForKey:@"examNo"] integerValue];
        
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nLastExamNo] forKey:@"lastExamNo"];
        [dicM_Params setObject:@"next" forKey:@"scrollType"];

        if( nLastExamNo >= [self.lb_TotalQ.text integerValue] )
        {
            [self setOnceQData];

            //저장되어 있다 하더라도 문제에 대한 정보(타이머등)를 업데이트 해줘야 하기 때문에 한번만 호출해줌
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                                param:dicM_Params
                                           withMethod:@"GET"
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [MBProgressHUD hide];
                                                
                                                if( resulte )
                                                {
                                                    weakSelf.dicM_Info = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                    
                                                    NSString *str_InfoKey = [NSString stringWithFormat:@"QInfo_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.dicM_Info];
                                                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_InfoKey];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
//                                                    [weakSelf setOnceQData];
                                                }
                                            }];
            return;
        }
    }
    
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            if( weakSelf.dicM_Info == nil || weakSelf.dicM_Info.allKeys.count == 0 )
                                            {
                                                weakSelf.dicM_Info = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                
                                                NSString *str_InfoKey = [NSString stringWithFormat:@"QInfo_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.dicM_Info];
                                                [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_InfoKey];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                            }
                                            
//                                            if( weakSelf.arM_List == nil || weakSelf.arM_List.count == 0 )
//                                            {
//                                                [weakSelf setOnceQData];
//                                            }

                                            [weakSelf.arM_List addObjectsFromArray:[resulte objectForKey:@"questionInfos"]];
                                            
                                            if( isFirst )
                                            {
                                                [weakSelf setOnceQData];
                                            }
                                            
                                            [weakSelf saveQuestion];

                                            [weakSelf downLoadData];
                                        }
                                        
                                        //로드 끝나면 한번 더 콜
                                    }];
}

//초기에 데이터 한번만 셋팅 해주는거
- (void)setOnceQData
{
    NSDictionary *dic_ExamUserInfo = [self.dicM_Info objectForKey:@"examUserInfo"];
    
    self.nTime = [[dic_ExamUserInfo objectForKey:@"examLapTime"] integerValue];
    
    if( self.tm_Time )
    {
        [self.tm_Time invalidate];
        self.tm_Time = nil;
    }

    self.tm_Time = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onUpdateTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.tm_Time forMode:NSRunLoopCommonModes];
    
    self.str_TesterId = [NSString stringWithFormat:@"%@", [dic_ExamUserInfo objectForKey:@"testerId"]];
    
    self.str_ImagePreFix = [self.dicM_Info objectForKey:@"img_prefix"];
    
    NSDictionary *dic_ExamPackageInfo = [self.dicM_Info objectForKey:@"examPackageInfo"];
    
    if( [self.str_SortType isEqualToString:@"inCorrectQuestionSolve"] )
    {
        self.lb_TotalQ.text = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"seqTotalQuestionCount"]];
    }
    else
    {
        self.lb_TotalQ.text = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"questionCount"]];
    }
    
    if( self.lb_TotalQ.text.length <= 0 || [self.lb_TotalQ.text integerValue] <= 0 )
    {
        self.lb_TotalQ.text = [NSString stringWithFormat:@"%ld", self.arM_List.count];
    }
    
//    self.arM_List = [NSMutableArray arrayWithArray:[self.dicM_Info objectForKey:@"questionInfos"]];
    self.nStartIdx = self.arM_List.count;
    
    [self.collection reloadData];
    
    if( self.arM_List && self.arM_List.count > 0 )
    {
        NSDictionary *dic = [self.arM_List firstObject];
        [self updateBottomCount:dic];
        [self updateQuestionWithNonPassMode:self.isNonPassMode];
    }
    
    if( self.nStartIdx > 1 )
    {
        //OO번부터 풀기
        [self performSelector:@selector(onMoveToQuestionInteval) withObject:nil afterDelay:0.1f];
    }
}

- (void)saveQuestion
{
    NSString *str_dataKey = [NSString stringWithFormat:@"Q_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.arM_List];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_dataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)onMoveToQuestionInteval
{
    self.nCurrentPage = [self.str_StartIdx integerValue];
    [self updateQuestionWithNonPassMode:self.isNonPassMode];
    
    if( self.nCurrentPage > 0 && self.arM_List.count <= self.nCurrentPage )
    {
        [self.collection reloadData];
        return;
    }

    NSDictionary *dic = [self.arM_List objectAtIndex:self.nCurrentPage];
    [self updateBottomCount:dic];
    
    [UIView animateWithDuration:0.3f animations:^{
    
        self.collection.contentOffset = CGPointMake(self.collection.frame.size.width * [self.str_StartIdx integerValue], 0);
    }];
}

- (void)updateMoreList
{
    self.view.userInteractionEnabled = NO;
    
    __block NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                self.str_Idx, @"examId",
                                                @"testing", @"viewMode",   //풀기 상태 [testing-문제풀기, scoring-문제리뷰]
                                                @"", @"testerId",   //답안지 ID
                                                self.str_SortType ? self.str_SortType : @"all", @"questionType", //문제 형식 [all - 전체, inCorrectQuestion - 틀린문제, myStarQuestion - 내가 별표 한 문제, solveQuestion - 푼문제, nonSolveQuestion - 안푼 문제, manyQNAQuestion - 질문이 달린 문제]
                                                @"package", @"examMode", //문제 유형 [package - 일반문제, category - 단원문제]
                                                @"20", @"limitCount",
                                                @"solve", @"solveMode",
                                                nil];
    
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.nStartIdx] forKey:@"lastExamNo"];
    [dicM_Params setObject:@"next" forKey:@"scrollType"];
    
    __weak __typeof(&*self)weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{

    [MBProgressHUD show];
    
    });
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSMutableArray *arM_Tmp = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                                            [weakSelf.arM_List addObjectsFromArray:arM_Tmp];
                                            weakSelf.nStartIdx = weakSelf.arM_List.count;

                                            dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
                                            dispatch_async(dumpLoadQueue, ^{
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{

                                                    [weakSelf.collection reloadData];

                                                });
                                            });
                                            
                                            [weakSelf saveQuestion];
                                        }
                                        
                                        self.view.userInteractionEnabled = YES;
                                    }];
}

- (void)updateBottomCount:(NSDictionary *)dic
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]], @"questionId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/count/question/qna/explain"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            nQnaCount = [[resulte objectForKey:@"explainCount"] integerValue] + [[resulte objectForKey:@"qnaCount"] integerValue];
                                            [self.btn_QnA setTitle:[NSString stringWithFormat:@"풀이 %ld", nQnaCount] forState:UIControlStateNormal];
                                            
                                            NSInteger nStarCount = [[resulte objectForKey:@"starCount"] integerValue];
                                            [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", nStarCount] forState:UIControlStateNormal];
                                        }
                                    }];

    
    BOOL isMyStarOn = [[dic objectForKey:@"existStarCount"] boolValue];
    if( isMyStarOn )
    {
        self.btn_Star.selected = YES;
    }
    else
    {
        self.btn_Star.selected = NO;
    }
}

- (void)onUpdateTime
{
    self.nTime++;
    
    NSInteger nSecond = self.nTime % 60;
    NSInteger nMinute = self.nTime / 60;
    [self.btn_Time setTitle:[NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond] forState:UIControlStateNormal];
}



#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arM_List.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"QuestionCell";
    
    QuestionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dumpLoadQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for( id subview in cell.sv_Contents.subviews )
            {
//                if( [subview isKindOfClass:[AudioView class]] == NO )
//                {
//                    [subview removeFromSuperview];
//                }
                
                [subview removeFromSuperview];
            }
            
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
                
                if( [str_Type isEqualToString:@"text"] )
                {
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
                    UIFont *font = [UIFont fontWithName:@"Helvetica" size:20.f];
                    //            NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, nil];
                    
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
                else if( [str_Type isEqualToString:@"image"] )
                {
                    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.sv_Contents.frame.size.width - (fX*2), 0)];
                    
                    if (UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation))
                    {
                        CGRect frame = iv.frame;
                        frame.size.width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - (fX * 2);
                        iv.frame = frame;
                    }
                    else
                    {
                        CGRect frame = iv.frame;
                        frame.size.width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - (fX * 2);
                        iv.frame = frame;
                    }
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    
                    
                    CGFloat fPer = iv.frame.size.width / [[dic objectForKey:@"width"] floatValue];
                    CGFloat fHeight = [[dic objectForKey:@"height"] floatValue] * fPer;
                    
                    if( isnan(fHeight) )    fHeight = 300.f;
                    
                    CGRect frame = iv.frame;
                    frame.size.height = fHeight;
                    iv.frame = frame;
                    
                    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
//                    [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                    [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       
                        NSLog(@"cacheType : %ld", cacheType);
                    }];
                    
                    [cell.sv_Contents addSubview:iv];
                    
                    fSampleViewTotalHeight += iv.frame.size.height + 20;
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
//                    if( self.v_Audio )
//                    {
//                        [self.arM_Audios addObject:self.v_Audio];
//                    }

//                    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
//                    dispatch_async(dumpLoadQueue, ^{
//                        
//                        dispatch_async(dispatch_get_main_queue(), ^{
//
//                        });
//                    });
                    
                    NSString *str_Body = [dic objectForKey:@"questionBody"];
                    self.str_AudioBody = str_Body;
                    NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, self.str_AudioBody];

                    AudioView *v_Audio = [cell.sv_Contents viewWithTag:10];
                    if( v_Audio == nil )
                    {
                        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
                        v_Audio = [topLevelObjects objectAtIndex:0];
                        v_Audio.tag = 10;
                        [v_Audio initPlayer:str_Url];
                        
                        [self.arM_Audios addObject:v_Audio];
                    }
                    
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
                    [cell.sv_Contents addSubview:view];
                    
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
                    
                    fSampleViewTotalHeight += view.frame.size.height + 20;
                }
            }
            
            
            //보기입력
            NSMutableString *strM_Item = [NSMutableString string];
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
                    [cell.sv_Contents addSubview:lb_Contents];
                    
                    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX + 20, fSampleViewTotalHeight, ((self.view.bounds.size.width / 2) - 50), 0)];
                    iv.contentMode = UIViewContentModeScaleAspectFit;
                    iv.clipsToBounds = YES;
                    //            iv.backgroundColor = [UIColor redColor];
                    
                    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
                    
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
//                    str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</p>" withString:@"#####"];
//                    str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</pre>" withString:@"#####"];
//                    str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</br>" withString:@"#####"];
//
//                    if( [str_Body hasSuffix:@"#####"] == NO )
//                    {
//                        str_Body = [NSString stringWithFormat:@"%@#####", str_Body];
//                    }

                    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUTF8StringEncoding]
                                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                          NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                                     documentAttributes:nil
                                                                                  error:nil];
                    NSString *finalString = [attr string];
//                    finalString = [finalString stringByReplacingOccurrencesOfString:@"#####" withString:@"\n"];
                    finalString = [finalString stringByReplacingOccurrencesOfString:@"-" withString:@"="];

                    if( [finalString hasSuffix:@"\n"] == NO )
                    {
                        finalString = [NSString stringWithFormat:@"%@\n", finalString];
                    }

                    [strM_Item appendString:[NSString stringWithFormat:@"%@ %@", str_Number, finalString]];

//                    UIFont *font = [UIFont fontWithName:@"Helvetica" size:19.f];
//                    NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
//                                                                         forKey:NSFontAttributeName];
//                    
//                    NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//                    
//                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", str_Number] attributes:dic_Attr];
//                    //            [attrStr appendAttributedString:attrStr_Html];
//                    
//                    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.sv_Contents.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
//                    
//                    UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 30, rect.size.height)];
//                    lb_Contents.numberOfLines = 0;
//                    lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:24.f];
//                    lb_Contents.text = attrStr.string;
//                    //            lb_Contents.attributedText = attrStr;
//                    //                        lb_Contents.backgroundColor = [UIColor redColor];
//                    
//                    CGSize size = [Util getTextSize:lb_Contents];
//                    
//                    CGRect frame = lb_Contents.frame;
//                    frame.size.height = size.height;
//                    lb_Contents.frame = frame;
//                    
//                    [cell.sv_Contents addSubview:lb_Contents];
//                    
//                    //            if( isNumberQuestion == NO )
//                    //            {
//                    //                lb_Contents.text = @"";
//                    //            }
//                    
//                    //마지막에 줄바꿈이 들어가서 없애줌
//                    NSArray *charSet = [attrStr_Html.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//                    NSString *str_Contents = [charSet componentsJoinedByString:@""];
//                    ////////////////////////////
//                    
//                    UILabel * lb_Contents2 = [[UILabel alloc] initWithFrame:CGRectMake(lb_Contents.text.length > 0 ?
//                                                                                       lb_Contents.frame.origin.x + lb_Contents.frame.size.width : fX, fSampleViewTotalHeight,
//                                                                                       lb_Contents.text.length > 0 ?
//                                                                                       cell.sv_Contents.frame.size.width - (lb_Contents.frame.origin.x + lb_Contents.frame.size.width + fX) :
//                                                                                       cell.sv_Contents.frame.size.width - (fX * 2),
//                                                                                       0)];
//                    lb_Contents2.numberOfLines = 0;
//                    lb_Contents2.font = [UIFont fontWithName:@"Helvetica" size:20.f];
//                    lb_Contents2.text = str_Contents;
//                    lb_Contents2.textColor = [UIColor colorWithHexString:@"030304"];
//                    //            lb_Contents2.backgroundColor = [UIColor blueColor];
//                    //            lb_Contents.attributedText = attrStr;
//                    
//                    size = [Util getTextSize:lb_Contents2];
//                    
//                    frame = lb_Contents2.frame;
//                    frame.size.height = size.height < lb_Contents.frame.size.height ? lb_Contents.frame.size.height : size.height;
//                    lb_Contents2.frame = frame;
//                    
//                    [cell.sv_Contents addSubview:lb_Contents2];
//                    
//                    
//                    
//                    fSampleViewTotalHeight += size.height + 15;
                }
                else if( [str_Type isEqualToString:@"item"] )
                {
//                    str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</p>" withString:@"#####"];
//                    str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</pre>" withString:@"#####"];
//                    str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</br>" withString:@"#####"];
//                    
//                    if( [str_Body hasSuffix:@"#####"] == NO )
//                    {
//                        str_Body = [NSString stringWithFormat:@"%@#####", str_Body];
//                    }

                    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUTF8StringEncoding]
                                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                          NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                                     documentAttributes:nil
                                                                                  error:nil];
                    NSString *finalString = [attr string];
//                    finalString = [finalString stringByReplacingOccurrencesOfString:@"#####" withString:@"\n"];
                    finalString = [finalString stringByReplacingOccurrencesOfString:@"-" withString:@"="];
  
                    if( [finalString hasSuffix:@"\n"] == NO )
                    {
                        finalString = [NSString stringWithFormat:@"%@\n", finalString];
                    }

                    [strM_Item appendString:[NSString stringWithFormat:@"%@ %@", str_Number, finalString]];
                }
                else
                {
                    NSString *str_Body = [dic objectForKey:@"itemBody"];
                    if( [str_Body hasSuffix:@"\n"] == NO )
                    {
                        str_Body = [NSString stringWithFormat:@"%@\n", str_Body];
                    }

                    [strM_Item appendString:[NSString stringWithFormat:@"%@ %@", str_Number, str_Body]];

//                    UIFont *font = [UIFont fontWithName:@"Helvetica" size:19.f];
//                    NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
//                                                                         forKey:NSFontAttributeName];
//                    
//                    NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[@"" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//                    
//                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str_Number, str_Body] attributes:dic_Attr];
//                    [attrStr appendAttributedString:attrStr_Html];
//                    
//                    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.sv_Contents.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
//                    
//                    UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 30, rect.size.height)];
//                    lb_Contents.numberOfLines = 0;
//                    lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:24.f];
//                    lb_Contents.text = str_Number;
//                    //            lb_Contents.attributedText = attrStr;
//                    //            lb_Contents.backgroundColor = [UIColor redColor];
//                    
//                    CGSize size = [Util getTextSize:lb_Contents];
//                    
//                    CGRect frame = lb_Contents.frame;
//                    frame.size.height = size.height;
//                    lb_Contents.frame = frame;
//                    
//                    [cell.sv_Contents addSubview:lb_Contents];
//                    
//                    UILabel * lb_Contents2 = [[UILabel alloc] initWithFrame:CGRectMake(lb_Contents.frame.origin.x + lb_Contents.frame.size.width, fSampleViewTotalHeight,
//                                                                                       cell.sv_Contents.frame.size.width - (lb_Contents.frame.origin.x + lb_Contents.frame.size.width + fX), 0)];
//                    lb_Contents2.numberOfLines = 0;
//                    lb_Contents2.font = [UIFont fontWithName:@"Helvetica" size:20.f];
//                    lb_Contents2.text = str_Body;
//                    lb_Contents2.textColor = [UIColor colorWithHexString:@"030304"];
//                    //            lb_Contents2.backgroundColor = [UIColor blueColor];
//                    //            lb_Contents.attributedText = attrStr;
//                    
//                    size = [Util getTextSize:lb_Contents2];
//                    
//                    frame = lb_Contents2.frame;
//                    frame.size.height = size.height < lb_Contents.frame.size.height ? lb_Contents.frame.size.height : size.height;
//                    lb_Contents2.frame = frame;
//                    
//                    [cell.sv_Contents addSubview:lb_Contents2];
//                    
//                    
//                    
//                    fSampleViewTotalHeight += size.height + 15;
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

            
            cell.sv_Contents.contentSize = CGSizeMake(self.collection.frame.size.width, fSampleViewTotalHeight + 50);
            
        });
    });

    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if( [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight )
//    {
//        return CGSizeMake(554, 375);
////        return CGSizeMake(self.view.frame.size.width, (CGRectGetHeight(collectionView.frame)));
//    }
//    
//    return CGSizeMake(375, 554);
////    return CGSizeMake(self.view.frame.size.width, (CGRectGetHeight(collectionView.frame)));
//}


- (void)stopAllContents
{
    if( self.vc_Movie )
    {
        [self.vc_Movie.moviePlayer stop];
        self.vc_Movie = nil;
    }
    
        for( NSInteger i = 0; i < self.arM_Audios.count; i++ )
        {
            AudioView *tmp_Audio = [self.arM_Audios objectAtIndex:i];
            [tmp_Audio.player seekToTime:CMTimeMake(0, 1)];
            [tmp_Audio.player pause];
        }
        
//        [self.arM_Audios removeAllObjects];
    
//        [self.v_Audio stop];
//        self.v_Audio.player = nil;
    
    
    if( self.playerView )
    {
        [self.playerView stopVideo];
        self.playerView = nil;
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

- (void)showResultView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
//        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
        [self.navigationController.view makeToast:@"examId error" withPosition:kPositionCenter];
        return;
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }
    vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    [self presentViewController:vc animated:YES completion:^{
        
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
        self.lc_NonNumberAnswerDoneWidth.constant = 63.f;
//        self.iv_NonNumberStatus.backgroundColor = [UIColor darkGrayColor];
    }
    else
    {
        self.lc_NonNumberAnswerDoneWidth.constant = 0.f;
//        self.iv_NonNumberStatus.backgroundColor = [UIColor whiteColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField.text.length > 0 )
    {
        [self goNonNumberAnswerDone:nil];
    }

    return YES;
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
            self.lc_NonNumberAnswerBottom.constant = keyboardBounds.size.height;
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            self.lc_NonNumberAnswerBottom.constant = -120.f;
        }
    }completion:^(BOOL finished) {
        
    }];
}


#pragma mark - IBAction
- (IBAction)goModalBack:(id)sender
{
    [self stopAllContents];
    
    [self.tm_Time invalidate];
    self.tm_Time = nil;

    NSString *str_Path = [NSString stringWithFormat:@"%@/api/v1/get/exam/question/list", kBaseUrl];
    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];

    if( self.str_TesterId )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            self.str_TesterId, @"testerId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/exit/solve/exam"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatReloadNoti" object:nil];
                                            }
                                        }];
    }
    
    [super goModalBack:sender];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goTimerToggle:(id)sender
{
    if( self.tm_Time )
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Question" bundle:nil];
        QuestionPauseViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"QuestionPauseViewController"];
        vc.str_CurrentQ = self.lb_CurrentQ.text;
        vc.str_TotalQ = self.lb_TotalQ.text;
        vc.nTime = self.nTime;
        [vc setCompletionBlock:^(id completeResult) {

            self.tm_Time = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onUpdateTime) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.tm_Time forMode:NSRunLoopCommonModes];  //메인스레드에 돌리면 터치를 잡고 있을때 어는 현상이 있어서 스레드 분기시킴
        }];
        
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
        [self.tm_Time invalidate];
        self.tm_Time = nil;
    }
    else
    {
        self.tm_Time = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onUpdateTime) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.tm_Time forMode:NSRunLoopCommonModes];  //메인스레드에 돌리면 터치를 잡고 있을때 어는 현상이 있어서 스레드 분기시킴
    }
}

- (IBAction)goSideMenu:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    SideMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
    vc.str_TesterId = self.str_TesterId;
//    vc.str_Idx = [NSString stringWithFormat:@"%ld", self.nCurrentPage];
    vc.str_StartNo = [NSString stringWithFormat:@"%ld", self.nCurrentPage + 1];
    
    if( [self.str_SortType isEqualToString:@"inCorrectQuestionSolve"] )
    {
        NSDictionary *dic = [self.arM_List objectAtIndex:self.nCurrentPage];
        vc.str_ExamNo = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examNo"]];
        vc.str_SortType = @"inCorrectQuestionSolve";
    }
    
    [vc setCompletionBlock:^(id completeResult) {
        
        [weakSelf.collection reloadData];
        
        NSDictionary *dic = [completeResult objectForKey:@"obj"];
//        weakSelf.str_SortType = [completeResult objectForKey:@"type"];
        
        NSInteger nExamNo = [[dic objectForKey:@"examNo"] integerValue];
        if( [self.str_SortType isEqualToString:@"inCorrectQuestionSolve"] )
        {
            for( NSInteger i = 0; i < self.arM_List.count; i++ )
            {
                NSDictionary *dic_Tmp = self.arM_List[i];
                NSInteger nExamNoTmp = [[dic_Tmp objectForKey:@"examNo"] integerValue];
                if( nExamNo == nExamNoTmp )
                {
                    weakSelf.nCurrentPage = i;
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        
                        weakSelf.collection.contentOffset = CGPointMake(weakSelf.collection.frame.size.width * weakSelf.nCurrentPage, 0);
                    }completion:^(BOOL finished) {
                        
                        [weakSelf didChangePage];
                        [weakSelf updateQuestionWithNonPassMode:NO];
                    }];
                    
                    break;
                }
            }
        }
        else
        {
            if( nExamNo <= self.arM_List.count )
            {
                weakSelf.nCurrentPage = nExamNo - 1;
                
                [UIView animateWithDuration:0.3f animations:^{
                    
                    weakSelf.collection.contentOffset = CGPointMake(self.collection.frame.size.width * self.nCurrentPage, 0);
                }completion:^(BOOL finished) {
                    
                    [weakSelf didChangePage];
                    [weakSelf updateQuestionWithNonPassMode:NO];
                }];
            }
        }
        
//        weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo - 1];
//        [weakSelf moveToPage:weakSelf.str_StartIdx];
//        
//        nOldPage = self.nCurrentPage;
//        
//        self.nCurrentPage = scrollView.contentOffset.x / scrollView.frame.size.width;

    }];
    
    [self presentViewController:vc animated:NO completion:^{
        
    }];
}

- (IBAction)goShared:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
    SharedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SharedViewController"];
    //    vc.str_ExamId = self.str_Idx;
    
    NSDictionary *dic = [self.arM_List objectAtIndex:self.nCurrentPage];
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }
    //    questionId = 26467;
    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
    [vc setCompletionBlock:^(id completeResult) {
       
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goStar:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    __weak __typeof(&*self)weakSelf = self;

    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[self.nCurrentPage]];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dicM objectForKey:@"questionId"]], @"questionId",   //문제 ID
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
                                                NSInteger nTotalStarCount = [btn.titleLabel.text integerValue];
                                                if( btn.selected == NO )
                                                {
                                                    //추가
                                                    weakSelf.btn_Star.selected = YES;
                                                    nTotalStarCount++;
                                                    [dicM setObject:@"1" forKey:@"existStarCount"];
                                                }
                                                else
                                                {
                                                    //삭제
                                                    weakSelf.btn_Star.selected = NO;
                                                    nTotalStarCount--;
                                                    [dicM setObject:@"0" forKey:@"existStarCount"];
                                                }
                                                
                                                //해당 문제에 대한 별표 총 갯수
                                                [dicM setObject:[NSString stringWithFormat:@"%ld", nTotalStarCount] forKey:@"starCount"];
                                                
                                                [weakSelf.arM_List replaceObjectAtIndex:self.nCurrentPage withObject:dicM];
                                                [weakSelf saveQuestion];

                                                [weakSelf updateBottomCount:dicM];
                                            }
                                        }
                                    }];
}

- (IBAction)goQnA:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Question" bundle:nil];

    NSDictionary *dic = [self.arM_List objectAtIndex:self.nCurrentPage];

    QuestionBottomViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"QuestionBottomViewController"];
    vc.str_QId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }
    vc.str_ChannelId = self.str_ChannelId;
    vc.nTotalCount = nQnaCount;
    
    [vc setUpdateCountBlock:^(id completeResult) {
        
        NSString *str_DCount = [completeResult objectForKey:@"dCount"];
        NSString *str_QCount = [completeResult objectForKey:@"qCount"];
        nQnaCount = [str_DCount integerValue] + [str_QCount integerValue];
        [self.btn_QnA setTitle:[NSString stringWithFormat:@"풀이 %ld", nQnaCount] forState:UIControlStateNormal];
    }];

    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (IBAction)goShowAnswerView:(id)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        
        NSDictionary *dic = [self.arM_List objectAtIndex:self.nCurrentPage];
        BOOL isNumberQuestion = [[dic objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
        if( isNumberQuestion )
        {
            self.lc_AnswerBottom.constant = 0.f;
        }
        else
        {
            self.lc_NonNumberAnswerBottom.constant = 0.f;
        }
        
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)goDownAnswerView:(id)sender
{
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.lc_AnswerBottom.constant = self.lc_NonNumberAnswerBottom.constant = -120.f;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)goNonNumberAnswerDone:(id)sender
{
    if( self.tf_NonNumberAnswer.text.length <= 0 )
    {
        return;
    }
    
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:[self.arM_List objectAtIndex:self.nCurrentPage]];

    NSString *str_MyCorrect = [self.tf_NonNumberAnswer.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *ar_Correct = [str_MyCorrect componentsSeparatedByString:@","];

    NSInteger correctAnswerCount = [[dicM objectForKey:@"correctAnswerCount"] integerValue];     //답 갯수

    if( correctAnswerCount > 1 )
    {
        if( ar_Correct.count == 1 )
        {
            [self.navigationController.view makeToast:[NSString stringWithFormat:@"정답이 %ld개 입니다\n,로 구분해서 입력해 주세요", correctAnswerCount] withPosition:kPositionCenter];
            return;
        }
    }

    
    
    
    
    
    
    
    NSMutableString *strM_MyCorrect = [NSMutableString stringWithString:str_MyCorrect];
    NSString *str_CorrectTmp = [dicM objectForKey:@"correctAnswer"];
    str_CorrectTmp = [str_CorrectTmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if( [str_CorrectTmp isEqualToString:strM_MyCorrect] == NO )
    {
        //오답이면 진동
#if !TARGET_IPHONE_SIMULATOR
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
    }
    
    NSString *str_Tmp = str_MyCorrect;
    NSArray *ar_MyCorrent = [str_Tmp componentsSeparatedByString:@","];
    //TODO: 정답전송
    NSMutableString *strM_Correct = [NSMutableString string];
    NSString *str_Correct = [NSString stringWithFormat:@"%@", [dicM objectForKey:@"correctAnswer"]];
    str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSArray *ar_Sep = [str_Correct componentsSeparatedByString:@","];
    
    
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

    
    
    [dicM setObject:str_MyCorrect forKey:@"user_correct"];
    [self.arM_List replaceObjectAtIndex:self.nCurrentPage withObject:dicM];
    [self saveQuestion];

    [self updateQuestionWithNonPassMode:NO];
    
    __weak __typeof(&*self)weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf goDownAnswerView:nil];
    });
    
//    [self goDownAnswerView:nil];
//    
//    [self performSelectorOnMainThread:@selector(goDownAnswerView:) withObject:nil waitUntilDone:YES];

    self.tf_NonNumberAnswer.text = @"";

    if( self.isNonPassMode )  return;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", self.str_TesterId], @"testerId",   //답안지 ID
                                        [NSString stringWithFormat:@"%@", [dicM objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                        strM_Correct, @"userAnswer", //사용자가 입력한 답
                                        [NSString stringWithFormat:@"%ld", self.nTime], @"examLapTime",  //경과시간
                                        @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                        [NSString stringWithFormat:@"%@", [dicM objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                        [NSString stringWithFormat:@"%ld", [self.lb_TotalQ.text integerValue]], @"totalQuestionCount", //전체문제수
                                        @"on", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                
                                                [weakSelf onShowResultIfNeed:resulte];
                                            });
                                        }
                                    }];
}

- (IBAction)goAsk:(id)sender
{
    if( self.dicM_Info == nil )
    {
        return;
    }
    
    NSDictionary *dic_ExamPackageInfo = [self.dicM_Info objectForKey:@"examPackageInfo"];
    __block NSString *str_TeacherId = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserId"]];
    __block NSString *str_TeacherName = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserName"]];
    __block NSString *str_TeacherImgUrl = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserThumbnail"]];

    NSDictionary *dic_Main = [self.arM_List objectAtIndex:self.nCurrentPage];
    __block NSString *str_QuestionId = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"questionId"]];

    NSMutableDictionary *dicM_QuesionInfo = [NSMutableDictionary dictionary];
    NSMutableArray *arM_Exam = [NSMutableArray array];
    NSArray *ar_ExamQuestionInfos = [dic_Main objectForKey:@"examQuestionInfos"];
    for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamQuestionInfos[i];
        if( [[dic objectForKey_YM:@"questionType"] isEqualToString:@"audio"] == NO )
        {
            NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
            [dicM setObject:[dic objectForKey:@"questionType"] forKey:@"questionType"];
            if( [[dic objectForKey:@"questionType"] isEqualToString:@"html"] )
            {
                NSString *str_Body = [dic objectForKey:@"questionBody"];
                str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</p>" withString:@"#####"];
                str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</pre>" withString:@"#####"];
                str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</br>" withString:@"#####"];
                str_Body = [str_Body stringByReplacingOccurrencesOfString:@"<br/>" withString:@"#####"];

                NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                      NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                                 documentAttributes:nil
                                                                              error:nil];
                NSString *finalString = [attr string];
//                finalString = [finalString stringByReplacingOccurrencesOfString:@"#####" withString:@"\n"];
                finalString = [finalString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                finalString = [finalString stringByReplacingOccurrencesOfString:@"-" withString:@"="];


                [dicM setObject:finalString forKey:@"questionBody"];
                [dicM setObject:@"text" forKey:@"questionType"];
            }
            else
            {
                [dicM setObject:[dic objectForKey:@"questionBody"] forKey:@"questionBody"];
            }
            [dicM setObject:[dic objectForKey:@"width"] forKey:@"width"];
            [dicM setObject:[dic objectForKey:@"height"] forKey:@"height"];
            [arM_Exam addObject:dicM];
        }
    }
    [dicM_QuesionInfo setObject:arM_Exam forKey:@"examQuestionInfos"];

    
    NSMutableArray *arM_Item = [NSMutableArray array];
    NSArray *ar_ExamUserItemInfos = [dic_Main objectForKey:@"examUserItemInfos"];
    for( NSInteger i = 0; i < ar_ExamUserItemInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamUserItemInfos[i];
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        [dicM setObject:[dic objectForKey:@"itemNo"] forKey:@"itemNo"];
        [dicM setObject:[dic objectForKey:@"printNo"] forKey:@"printNo"];
        [dicM setObject:[dic objectForKey:@"type"] forKey:@"type"];
        [dicM setObject:[dic objectForKey:@"width"] forKey:@"width"];
        [dicM setObject:[dic objectForKey:@"height"] forKey:@"height"];
        if( [[dic objectForKey:@"type"] isEqualToString:@"itemHtml"] )
        {
            NSString *str_Body = [dic objectForKey:@"itemBody"];
//            str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</p>" withString:@"#####"];
//            str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</pre>" withString:@"#####"];
//            str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</br>" withString:@"#####"];
//            
//            if( [str_Body hasSuffix:@"#####"] == NO )
//            {
//                str_Body = [NSString stringWithFormat:@"%@#####", str_Body];
//            }
            
            NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUTF8StringEncoding]
                                                                        options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                  NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                             documentAttributes:nil
                                                                          error:nil];
            NSString *finalString = [attr string];
//            finalString = [finalString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            finalString = [finalString stringByReplacingOccurrencesOfString:@"-" withString:@"="];

            if( [finalString hasSuffix:@"\n"] == NO )
            {
                finalString = [NSString stringWithFormat:@"%@\n", finalString];
            }

            [dicM setObject:finalString forKey:@"itemBody"];
//            [dicM setObject:@"text" forKey:@"type"];
        }
        else if( [[dic objectForKey:@"type"] isEqualToString:@"item"] )
        {
            NSString *str_Body = [dic objectForKey:@"itemBody"];
//            str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</p>" withString:@"#####"];
//            str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</pre>" withString:@"#####"];
//            str_Body = [str_Body stringByReplacingOccurrencesOfString:@"</br>" withString:@"#####"];
//            
//            if( [str_Body hasSuffix:@"#####"] == NO )
//            {
//                str_Body = [NSString stringWithFormat:@"%@#####", str_Body];
//            }

            NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUTF8StringEncoding]
                                                                        options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                  NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                             documentAttributes:nil
                                                                          error:nil];
            NSString *finalString = [attr string];
//            finalString = [finalString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            finalString = [finalString stringByReplacingOccurrencesOfString:@"-" withString:@"="];
            
            if( [finalString hasSuffix:@"\n"] == NO )
            {
                finalString = [NSString stringWithFormat:@"%@\n", finalString];
            }

            [dicM setObject:finalString forKey:@"itemBody"];
//            [dicM setObject:@"text" forKey:@"type"];
        }
        else
        {
            NSString *str_Body = [dic objectForKey:@"itemBody"];
            if( [str_Body hasSuffix:@"\n"] == NO )
            {
                str_Body = [NSString stringWithFormat:@"%@\n", str_Body];
            }

            [dicM setObject:str_Body forKey:@"itemBody"];
        }
        [arM_Item addObject:dicM];
    }
    [dicM_QuesionInfo setObject:arM_Item forKey:@"examUserItemInfos"];

    NSDictionary *dic_Question = @{
                                   @"examQuestionInfos":arM_Exam,
                                   @"examUserItemInfos":arM_Item,
                                   @"examTitle":[dic_ExamPackageInfo objectForKey:@"examTitle"],
                                   @"examNo":[NSString stringWithFormat:@"%ld", self.nCurrentPage + 1],
                                   @"examId":[dic_ExamPackageInfo objectForKey:@"examId"]};
    
    
    
    
//    NSDictionary *dic_ExamPackageInfo = [self.dicM_Info objectForKey:@"examPackageInfo"];
//    __block NSString *str_TeacherId = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserId"]];
//    __block NSString *str_TeacherName = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserName"]];
//    __block NSString *str_TeacherImgUrl = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserThumbnail"]];
//
//    NSMutableDictionary *dicM_QuesionInfo = [NSMutableDictionary dictionary];
//    [dicM_QuesionInfo setObject:[dic_ExamPackageInfo objectForKey:@"examTitle"] forKey:@"examTitle"];
//    [dicM_QuesionInfo setObject:[NSString stringWithFormat:@"%ld", self.nCurrentPage + 1] forKey:@"examNo"];
//    [dicM_QuesionInfo setObject:[dic_ExamPackageInfo objectForKey:@"examId"] forKey:@"examId"];
//    
//    NSMutableArray *arM_Bodys = [NSMutableArray array];
//    NSDictionary *dic_Tmp = [self.arM_List objectAtIndex:self.nCurrentPage];
//    __block NSString *str_QuestionId = [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"questionId"]];
//    NSArray *ar_Tmp = [dic_Tmp objectForKey:@"examQuestionInfos"];
//    NSInteger nCnt = ar_Tmp.count;
//    if( nCnt > 2 )
//    {
//        nCnt = 2;
//    }
//    
//    for( NSInteger i = 0; i < ar_Tmp.count; i++ )
//    {
//        NSDictionary *dic = ar_Tmp[i];
//        NSString *str_Type = [dic objectForKey:@"questionType"];
//        if( [str_Type isEqualToString:@"audio"] == NO )
//        {
//            NSMutableString *strM_Body = [NSMutableString stringWithString:[dic objectForKey:@"questionBody"]];
//            
//            if( [str_Type isEqualToString:@"text"] )
//            {
//                if( strM_Body.length > 250 )
//                {
//                    NSString *str_Tmp = [strM_Body substringWithRange:NSMakeRange(0, 250)];
//                    strM_Body = [NSMutableString stringWithString:str_Tmp];
//                    [strM_Body appendString:@"..."];
//                }
//            }
//
//            [arM_Bodys addObject:@{@"questionBody":strM_Body, @"questionType":str_Type}];
//        }
//    }
//    
//    [dicM_QuesionInfo setObject:arM_Bodys forKey:@"qnaBody"];
    
    
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
                                                        
                                                        vc.isAskMode = YES;
                                                        vc.dic_NormalQuestionInfo = dic_Question;
                                                        vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey_YM:@"examId"]];
                                                        vc.str_ExamTitle = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey_YM:@"examTitle"]];
                                                        vc.str_ExamNo = [NSString stringWithFormat:@"%ld", self.nCurrentPage + 1];
                                                        vc.str_QuestinId = str_QuestionId;
                                                        
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
                                                                             
                                                                             vc.isAskMode = YES;
                                                                             vc.dic_NormalQuestionInfo = dic_Question;

                                                                             vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey_YM:@"examId"]];
                                                                             vc.str_ExamTitle = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey_YM:@"examTitle"]];
                                                                             vc.str_ExamNo = [NSString stringWithFormat:@"%ld", self.nCurrentPage + 1];
                                                                             vc.str_QuestinId = str_QuestionId;
                                                                             
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
