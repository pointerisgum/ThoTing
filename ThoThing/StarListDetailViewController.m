//
//  StarListDetailViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 8..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "StarListDetailViewController.h"
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
#import "QuestionIngStarNaviView.h"
#import "QuestionContainerViewController.h"
#import "AudioView.h"
#import "SideMenuViewController.h"

@import AVFoundation;
@import MediaPlayer;
@import AMPopTip;

static const NSInteger kPlayButtonTag = 10;
static NSMutableArray *arM_TotalList = nil;


@interface StarListDetailViewController () <UITextFieldDelegate>
{
    BOOL isFinish;      //문제를 풀었는지
    BOOL isFinishPass;  //문제를 풀고 맞췄는지
    BOOL isAnswerShow;  //답 뷰가 열렸는지 여부
    NSInteger nCellCount;   //셀 갯수 (정답입력화면 유무에 따른)
    NSInteger nCurrentSection;
    NSInteger nTime;
    
    NSInteger nQuestionCount;   //전체 문제 수
    CGFloat fContentsHeight;    //컨텐츠 셀 높이
    
    NSString *str_MultipleChoice;   //주관식인지 객관식인지 ox인지 (주관식Y 객관식N OX:O)
    NSInteger nCorrectCnt;  //답 갯수
    NSString *str_UserThumbUrl; //유저 섬네일
    
    NSString *str_CurrentExamNo;    //현재 문제 번호

    NSInteger nNaviNowCnt;          //네비에 표시되는 현재 문제 번호
    NSInteger nNaviTotalCnt;        //네비에 표시되는 전체 문제 수
}

@property (nonatomic, strong) NSString *str_TesterId;

//음성문제 관련
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
@property (nonatomic, strong) AudioView *v_Audio;
/////////

//비디오 관련
@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
///////////

@property (nonatomic, strong) QuestionIngStarNaviView *v_RightMenu;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSString *str_Idx;
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

@property (nonatomic, strong) YTPlayerView *playerView;


@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_Menu;
@property (nonatomic, weak) IBOutlet AnswerView *v_Answer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerBottom;
@property (nonatomic, weak) IBOutlet UITableView *tbv_Answer;

//정답출력
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerPrintHeight;
@property (nonatomic, weak) IBOutlet UITableView *tbv_AnswerPrint;

//문제풀이 뷰
@property (nonatomic, weak) IBOutlet UIView *v_Discription;
@property (nonatomic, weak) IBOutlet UIButton *btn_Discription;

@end

@implementation StarListDetailViewController

- (void)stopAllContents
{
    if( self.vc_Movie )
    {
        [self.vc_Movie.moviePlayer stop];
        self.vc_Movie = nil;
    }
    if( self.v_Audio.player )
    {
        [self.v_Audio.player pause];
        [self.v_Audio.player seekToTime:CMTimeMake(0, 1)];
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
    if( self.nPage <= 1 )
    {
        [self.navigationController.view makeToast:@"첫 문제 입니다" withPosition:kPositionCenter];
        return;
    }
    
    [self stopAllContents];
    
    StarListDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StarListDetailViewController"];
    vc.nPage = --self.nPage;
    vc.nTotalPage = self.nTotalPage;
    vc.str_SchoolGrade = self.str_SchoolGrade;
    vc.str_PersonGrade = self.str_PersonGrade;
    vc.str_SubjectName = self.str_SubjectName;
    
    CATransition* transition = [CATransition animation];
    transition.duration = .7f;
    transition.type = kCATransitionPush;
    [self.view.layer addAnimation:transition forKey:nil];
    [self.view endEditing:YES];
    [self addChildViewController:vc];
    [self addConstraintsForViewController:vc];
}

- (void)nextSwipeGesture:(UISwipeGestureRecognizer *)gesture;
{
    //다음nTotalCount
    if( self.nPage >= self.nTotalPage )
    {
        [self.navigationController.view makeToast:@"마지막 문제 입니다" withPosition:kPositionCenter];
        return;
    }
    
    [self stopAllContents];
    
    StarListDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StarListDetailViewController"];
    vc.nPage = ++self.nPage;
    vc.nTotalPage = self.nTotalPage;
    vc.str_SchoolGrade = self.str_SchoolGrade;
    vc.str_PersonGrade = self.str_PersonGrade;
    vc.str_SubjectName = self.str_SubjectName;
    
    CATransition* transition = [CATransition animation];
    transition.duration = .7f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.layer addAnimation:transition forKey:nil];
    [self.view endEditing:YES];
    [self addChildViewController:vc];
    [self addConstraintsForViewController:vc];
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
    UIView *containerView = self.view;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    self.view.alpha = NO;
    self.navigationController.navigationBarHidden = NO;
    self.btn_Menu.hidden = YES;
    
    self.btn_Discription.layer.cornerRadius = 8.f;
    self.btn_Discription.layer.borderColor = kMainColor.CGColor;
    self.btn_Discription.layer.borderWidth = 1.f;
 
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionIngStarNaviView" owner:self options:nil];
    self.v_RightMenu = [topLevelObjects objectAtIndex:0];
    self.v_RightMenu.btn_Count.userInteractionEnabled = NO;
    [self.v_RightMenu.btn_Count setImage:BundleImage(@"") forState:UIControlStateNormal];
    self.v_RightMenu.btn_Count.layer.cornerRadius = 0.f;
    self.v_RightMenu.btn_Count.layer.borderWidth = 0.0f;
    self.v_RightMenu.btn_Count.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [self initNaviWithTitle:@"별표한 문제" withLeftItem:[self leftBackBlackMenuBarButtonItem]
              withRightItem:[[UIBarButtonItem alloc] initWithCustomView:self.v_RightMenu]
                  withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    
    nCellCount = 1;
    
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

    self.dicM_CellHeight = [NSMutableDictionary dictionary];
    
    self.questionListCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([QuestionListCell class])];
    self.v_Answer6Cell = [self.tbv_Answer dequeueReusableCellWithIdentifier:NSStringFromClass([Answer6Cell class])];
    self.v_AnswerTitleCell = [self.tbv_Answer dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerTitleCell class])];
    self.v_AnswerSubjectiveCell = [self.tbv_Answer dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerSubjectiveCell class])];
    self.v_AnswerPrintNumber2Cell = [self.tbv_AnswerPrint dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerPrintNumber2Cell class])];
    self.v_AnswerPrintSubjectCell = [self.tbv_AnswerPrint dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerPrintSubjectCell class])];
    
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
    //    if( self.arM_List )
    //    {
    //        [self.tbv_List reloadData];
    //    }
    
    //    [self.tbv_List setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.alpha = YES;
    
    //    [self.tbv_List setNeedsLayout];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self.navigationController.navigationBar setBarTintColor:kMainColor];
//    [self.navigationController.navigationBar setTranslucent:NO];
//    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
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
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"star", @"questionType",
                                        self.str_SchoolGrade, @"schoolGrade",
                                        self.str_PersonGrade, @"personGrade",
                                        self.str_SubjectName, @"subjectName",
                                        [NSString stringWithFormat:@"%ld", self.nPage], @"examNo",
                                        @"1", @"limitCount",
                                        nil];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/star/question/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            NSInteger nCode = [[resulte objectForKey_YM:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //성공
                                                nQuestionCount = [[resulte objectForKey_YM:@"questionInfoCount"] integerValue];
                                                NSString *str_Cnt = [NSString stringWithFormat:@"%ld/%ld",
                                                                     [[resulte objectForKey_YM:@"solveQuestionCount"] integerValue],
                                                                     self.nTotalPage];
                                                
                                                [self.v_RightMenu.btn_Count setTitle:str_Cnt forState:UIControlStateNormal];

                                                str_UserThumbUrl = [resulte objectForKey_YM:@"userThumbnail"];
//                                                self.dic_UserInfo = [resulte objectForKey_YM:@"examUserInfo"];
//                                                self.dic_PackageInfo = [resulte objectForKey_YM:@"examPackageInfo"];
                                                
                                                self.str_ImagePreFix = [resulte objectForKey_YM:@"img_prefix"];
                                                
//                                                NSMutableString *strM_BackTitle = [NSMutableString string];
//                                                [strM_BackTitle appendString:[self.dic_PackageInfo objectForKey_YM:@"subjectName"]];
//                                                [strM_BackTitle appendString:[NSString stringWithFormat:@"(%@", [self.dic_PackageInfo objectForKey_YM:@"schoolGrade"]]];
//                                                NSInteger nGrade = [[self.dic_PackageInfo objectForKey_YM:@"persongrade"] integerValue];
//                                                if( nGrade == 0 )
//                                                {
//                                                    [strM_BackTitle appendString:@")"];
//                                                }
//                                                else
//                                                {
//                                                    [strM_BackTitle appendString:[NSString stringWithFormat:@"%ld)", nGrade]];
//                                                }
//                                                [strM_BackTitle appendString:[self.dic_PackageInfo objectForKey_YM:@"examTitle"]];
//                                                NSLog(@"%@", strM_BackTitle);
//                                                
//                                                //                                                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNaviBar:) name:@"kUpdateNaviBar" object:nil];
//                                                
//                                                //                                                    [self.v_Title.btn_Back setTitle:strM_BackTitle forState:UIControlStateNormal];
//                                                
//                                                NSInteger nUserProgress = [[self.dic_UserInfo objectForKey_YM:@"u_progress"] integerValue];
//                                                nQuestionCount = [[self.dic_PackageInfo objectForKey_YM:@"questionCount"] integerValue];
//                                                //                                                    self.v_Title.lb_Count.text = [NSString stringWithFormat:@"%ld/%ld", nUserProgress, nQuestionCount];
//                                                
//                                                NSString *str_Count = [NSString stringWithFormat:@"%ld/%ld", nUserProgress, nQuestionCount];
//                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNaviBar" object:@{@"title":strM_BackTitle, @"count":str_Count}];
                                                
                                                
                                                BOOL isFirstLoad = NO;
                                                if( self.arM_List == nil )
                                                {
                                                    isFirstLoad = YES;
                                                }
                                                
                                                
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey_YM:@"questionInfos"]];
                                                
                                                NSDictionary *dic = [self.arM_List firstObject];
                                                self.str_TesterId = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"testerId"] integerValue]];
                                                self.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examId"] integerValue]];
                                                
                                                NSMutableArray *arM_Tmp = [NSMutableArray array];
                                                [arM_Tmp addObject:[self.arM_List firstObject]];
                                                self.arM_List = [NSMutableArray arrayWithArray:arM_Tmp];
                                                [self setFinishCheck:self.arM_List];
                                                [self.tbv_List reloadData];
                                                [self.tbv_Answer reloadData];
                                                [self.tbv_AnswerPrint reloadData];
                                                
                                                if( isFinish && isFirstLoad )
                                                {
                                                    self.tbv_AnswerPrint.hidden = NO;
                                                    self.lc_AnswerPrintHeight.constant = self.tbv_AnswerPrint.contentSize.height;
                                                }
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey_YM:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)setFinishCheck:(NSArray *)ar
{
    NSDictionary *dic = [ar firstObject];
    NSString *str_SolveStatus = [dic objectForKey_YM:@"solveStatus"];
    if( [str_SolveStatus isEqualToString:@"not-solve"] )
//    if( 1)
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
        NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"user_correct"]];
        
        //정답
        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"correctAnswer"]];
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

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    self.btn_Menu.hidden = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.btn_Menu.hidden = NO;
}


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
        str_MultipleChoice = [dic objectForKey_YM:@"isMultipleChoice"];
        nCorrectCnt = [[dic objectForKey_YM:@"correctAnswerCount"] integerValue];
        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"correctAnswer"]];
        NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"user_correct"]];
        
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
            //주관식을 경우
            self.v_AnswerPrintSubjectCell = [tableView dequeueReusableCellWithIdentifier:@"AnswerPrintSubjectCell" forIndexPath:indexPath];
            self.v_AnswerPrintSubjectCell.lb_Title.text = [NSString stringWithFormat:@"정답: %@", str_Correct];
            
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
                NSInteger nItemCount = [[dic objectForKey_YM:@"itemCount"] integerValue];
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
                NSString *str_Correct = [dic objectForKey_YM:@"correctAnswer"];
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
        if( fContentsHeight > 20 )
        {
            return fContentsHeight;
        }
        
        [self configureCell:self.questionListCell forRowAtIndexPath:indexPath];
        
        [self.questionListCell updateConstraintsIfNeeded];
        [self.questionListCell layoutIfNeeded];
        
        self.questionListCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.questionListCell.bounds));
        
        fContentsHeight = [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return fContentsHeight;
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
    else if( indexPath.row == 1 )
    {
        return 70.f;
    }
    
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_List )
    {
        return 44.0f;
    }
    
    return 0;
}

//B2B POC_ID
//B2C Event ID
//브랜드별 카테고리
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"QuestionListHeaderCell";
    QuestionListHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell.btn_Play removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    //        NSDictionary *dic = self.arM_List[[self.str_StartIdx integerValue] - 1];
    NSDictionary *dic = self.arM_List[section];
    [cell.btn_ViewCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"totalAnswerCount"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"starCount"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_CommentCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"replyCount"] integerValue]] forState:UIControlStateNormal];
    //    NSInteger nVideoExplainCount = [[dic objectForKey_YM:@"videoExplainCount"] integerValue];
    
    
    NSInteger nQnaCnt = [[dic objectForKey:@"explainCount"] integerValue] + [[dic objectForKey:@"qnaCount"] integerValue];
    [cell.btn_QnaCnt setTitle:[NSString stringWithFormat:@"풀이와 질문 %ld", nQnaCnt] forState:UIControlStateNormal];
    [cell.btn_QnaCnt addTarget:self action:@selector(onDiscription:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btn_Discription setTitle:[NSString stringWithFormat:@"풀이와 질문 %ld", nQnaCnt] forState:UIControlStateNormal];

    
    NSInteger nVideoExplainCount = [[dic objectForKey_YM:@"explainCount"] integerValue];
    if( nVideoExplainCount > 0 )
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
    
    NSInteger nMyStarCnt = [[dic objectForKey_YM:@"existStarCount"] integerValue];
    if( nMyStarCnt > 0 )
    {
        //별표를 했으면 별 온 시키고 시험나올듯 글씨 없애준다
        cell.btn_StarCnt.selected = YES;
        [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"starCount"] integerValue]] forState:UIControlStateNormal];
    }
    else
    {
        //별표를 안했으면 시험나올듯과 별표카운트 표시
        cell.btn_StarCnt.selected = NO;
//        [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"시험나올듯 %ld", [[dic objectForKey_YM:@"starCount"] integerValue]] forState:UIControlStateNormal];
        [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"starCount"] integerValue]] forState:UIControlStateNormal];
    }
    
    [cell.btn_StarCnt addTarget:self action:@selector(onStarToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btn_Info setImage:BundleImage(@"info.png") forState:UIControlStateNormal];

    
    if( isFinish )
    {
        [cell setLabelColor:[UIColor whiteColor]];
        
        [cell.btn_ViewCnt setImage:BundleImage(@"eye_white.png") forState:UIControlStateNormal];
        [cell.btn_CommentCnt setImage:BundleImage(@"comment_off_white.png") forState:UIControlStateNormal];
        [cell.btn_StarCnt setImage:BundleImage(@"star_white.png") forState:UIControlStateNormal];
        [cell.btn_Info setImage:BundleImage(@"info_white.png") forState:UIControlStateNormal];

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

}

- (void)configureCell:(QuestionListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
    
    for( UIView *subView in cell.contentView.subviews )
    {
        [subView removeFromSuperview];
    }
    
    //    NSDictionary *dic = self.arM_List[[self.str_StartIdx integerValue] - 1];
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    __block CGFloat fSampleViewTotalHeight = 20;
    NSArray *ar_ExamQuestionInfos = [dic objectForKey_YM:@"examQuestionInfos"];
    for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamQuestionInfos[i];
        NSString *str_Type = [dic objectForKey_YM:@"questionType"];
        NSString *str_Body = [dic objectForKey_YM:@"questionBody"];
        //        NSLog(@"%@", str_Type);
        if( [str_Type isEqualToString:@"text"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;
            
            [cell.contentView addSubview:lb_Contents];
            
            fSampleViewTotalHeight += lb_Contents.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"html"] )
        {
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, rect.size.height)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.numberOfLines = 0;
            lb_Contents.attributedText = attrStr;
            [cell.contentView addSubview:lb_Contents];
            
            fSampleViewTotalHeight += rect.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, 0)];
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
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
            
        }
        else if( [str_Type isEqualToString:@"videoLink"] )
        {
            //유튜브
            self.playerView = [[YTPlayerView alloc] initWithFrame:
                                        CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, (cell.contentView.frame.size.width - 16) * 0.7f)];
            
            NSDictionary *playerVars = @{
                                         @"controls" : @1,
                                         @"playsinline" : @1,
                                         @"autohide" : @1,
                                         @"showinfo" : @0,
                                         @"modestbranding" : @1
                                         };
            
            [self.playerView loadWithVideoId:str_Body playerVars:playerVars];
            
            [cell.contentView addSubview:self.playerView];
            
            fSampleViewTotalHeight += self.playerView.frame.size.height + 10;
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
            
            if( self.v_Audio == nil )
            {
                NSString *str_Body = [dic objectForKey:@"questionBody"];
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
                
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
            
            fSampleViewTotalHeight += self.v_Audio.frame.size.height + 10;

        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, (cell.contentView.frame.size.width - 16) * 0.7f)];
            
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
            
            fSampleViewTotalHeight += view.frame.size.height + 10;
        }
    }
    
    
    //보기입력
    CGFloat fX = 15.f;
    NSArray *ar_ExamUserItemInfos = [dic objectForKey_YM:@"examUserItemInfos"];
    for( NSInteger i = 0; i < ar_ExamUserItemInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamUserItemInfos[i];
        NSString *str_Type = [dic objectForKey_YM:@"type"];
        NSString *str_Body = [dic objectForKey_YM:@"itemBody"];
        NSString *str_Number = [NSString stringWithFormat:@"%@ ", [dic objectForKey_YM:@"printNo"]];
        
        if( [str_Type isEqualToString:@"itemImage"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 20, 20)];
            lb_Contents.numberOfLines = 0;
            lb_Contents.text = str_Number;
            [cell.contentView addSubview:lb_Contents];
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX + 20, fSampleViewTotalHeight, cell.contentView.frame.size.width - (20 + (fX * 2)), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            
            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_ImageUrl]];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImage *resizeImage = [Util imageWithImage:image convertToWidth:iv.frame.size.width];
            iv.image = resizeImage;
            
            CGRect frame = iv.frame;
            frame.size.height = resizeImage.size.height;
            iv.frame = frame;
            
            [cell.contentView addSubview:iv];
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
        }
        else
        {
            NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.f];
            NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
                                                                 forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str_Number attributes:dic_Attr];
            [attrStr appendAttributedString:attrStr_Html];
            
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, rect.size.height)];
            lb_Contents.numberOfLines = 0;
            lb_Contents.attributedText = attrStr;
            [cell.contentView addSubview:lb_Contents];
            
            fSampleViewTotalHeight += rect.size.height + 10;
        }
    }
    
    CGRect frame = cell.frame;
    frame.size.height = fSampleViewTotalHeight > (self.tbv_List.frame.size.height - 50) ? fSampleViewTotalHeight + 120 : fSampleViewTotalHeight;
    cell.frame = frame;
}

- (void)onQuestionPlay:(YmExtendButton *)btn
{
    NSString *str_Body = [btn.dic_Info objectForKey_YM:@"questionBody"];
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
                                        [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]], @"questionId",   //문제 ID
                                        !btn.selected ? @"on" : @"off", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/question/star"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey_YM:@"response_code"] integerValue];
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
    }
    
}

- (void)onShowCorrectOne:(UIButton *)btn
{
    NSDictionary *dic = [self.arM_List firstObject];
    NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"user_correct"]];
    
    self.v_AnswerPrintNumber2Cell.lb_Title.hidden = NO;
    self.v_AnswerPrintNumber2Cell.lb_Title.text = [NSString stringWithFormat:@"당신은 %@번을 선택했었습니다.", str_UserCorrect];
    
    self.v_AnswerPrintNumber2Cell.btn_UserCorrect1.hidden = NO;
    [self.v_AnswerPrintNumber2Cell.btn_UserCorrect1 setTitle:str_UserCorrect forState:UIControlStateNormal];
}

- (void)onShowCorrectTwo:(UIButton *)btn
{
    NSDictionary *dic = [self.arM_List firstObject];
    NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"user_correct"]];
    NSArray *ar_UserCorrect = [str_UserCorrect componentsSeparatedByString:@"|"];
    
    if( ar_UserCorrect.count < 2 )
    {
        [self.navigationController.view makeToast:@"데이터 오류" withPosition:kPositionCenter];
        return;
    }
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
    NSString *str_UserCorrect = [NSString stringWithFormat:@"당신은 '%@'이였습니다.", [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"user_correct"]]];
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
            self.lc_AnswerBottom.constant = keyboardBounds.size.height;
            [self.tbv_Answer updateConstraints];
            //            self.tbv_List.contentSize = CGSizeMake(self.tbv_List.bounds.size.width, self.tbv_List.contentSize.height + keyboardBounds.size.height);
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            self.lc_AnswerBottom.constant = 0;
            [self.tbv_Answer updateConstraints];
            //            self.tbv_List.contentSize = CGSizeMake(self.tbv_List.bounds.size.width, self.tbv_List.contentSize.height - keyboardBounds.size.height);
        }
    }completion:^(BOOL finished) {
        
    }];
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.tbv_List];
    NSIndexPath *indexPath = [self.tbv_List indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        AnswerSubjectiveCell *cell =  (AnswerSubjectiveCell *)[self.tbv_List cellForRowAtIndexPath:indexPath];
        //        cell.lc_BackWidth.constant = 47.f;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.tbv_List];
    NSIndexPath *indexPath = [self.tbv_List indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        AnswerSubjectiveCell *cell =  (AnswerSubjectiveCell *)[self.tbv_List cellForRowAtIndexPath:indexPath];
        //        cell.lc_BackWidth.constant = 0;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSMutableArray *arM_MyCorrect = [NSMutableArray array];
    
    for( NSInteger i = 0; i < nCellCount; i++ )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        id cell =  [self.tbv_Answer cellForRowAtIndexPath:indexPath];
        if( [cell isKindOfClass:[AnswerSubjectiveCell class]] )
        {
            AnswerSubjectiveCell *findCell = (AnswerSubjectiveCell *)cell;
            if( findCell.tf_Answer.text.length <= 0 )
            {
                [self.navigationController.view makeToast:@"정답을 입력해 주세요" withPosition:kPositionCenter];
                return YES;
            }
            
            [arM_MyCorrect addObject:findCell.tf_Answer.text];
        }
    }
    
    
    
    
    NSMutableString *strM_Correct = [NSMutableString string];
    
    NSDictionary *dic = [self.arM_List firstObject];
    NSString *str_Correct = [dic objectForKey_YM:@"correctAnswer"];
    
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
            
            NSString *str_Tmp = arM_MyCorrect[i];
            NSString *str_MyCorrect = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [strM_Correct appendString:str_MyCorrect];
            [strM_Correct appendString:@"-"];
            [strM_Correct appendString:@"1"];
            [strM_Correct appendString:@","];
        }
        else
        {
            NSString *str_Tmp = arM_MyCorrect[i];
            NSString *str_MyCorrect = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [strM_Correct appendString:str_MyCorrect];
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
                                        self.str_TesterId, @"testerId",   //답안지 ID
                                        [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]], @"questionId",   //문제 ID
                                        strM_Correct, @"userAnswer", //사용자가 입력한 답
                                        [NSString stringWithFormat:@"%ld", nTime * 1000], @"examLapTime",  //경과시간
                                        @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                        [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                        [NSString stringWithFormat:@"%ld", nQuestionCount], @"totalQuestionCount", //전체문제수
                                        @"on", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            [self updateList];

                                            NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
//                                            if( nDiscriptionCnt > 0 )
                                            if( 1 )
                                            {
                                                self.v_Discription.hidden = NO;
                                                self.lc_AnswerBottom.constant = 70;
                                            }

                                        }
                                    }];
    
    NSInteger nDiscriptionCnt = [[dic objectForKey_YM:@"explainCount"] integerValue];
//    if( nDiscriptionCnt > 0 )
    if( 1 )
    {
        //해설이 있다면 문제 풀이가 있다면 문제풀이 쇼
        nCellCount += 1;
    }
    
    //텍스트필드 입력을 못하게 막는다
    for( NSInteger i = 0; i < nCellCount; i++ )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        id cell =  [self.tbv_Answer cellForRowAtIndexPath:indexPath];
        if( [cell isKindOfClass:[AnswerSubjectiveCell class]] )
        {
            AnswerSubjectiveCell *findCell = (AnswerSubjectiveCell *)cell;
            findCell.tf_Answer.userInteractionEnabled = NO;
        }
    }
    
    [self.view endEditing:YES];
    
    [self updateList];
    
    str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if( [str_Correct isEqualToString:strM_Correct] )
    {
        self.v_AnswerTitleCell.lb_Title.textColor = [UIColor blackColor];
        self.v_AnswerTitleCell.lb_Title.text = @"정답입니다";
    }
    else
    {
        self.v_AnswerTitleCell.lb_Title.textColor = [UIColor whiteColor];
        self.v_AnswerTitleCell.lb_Title.backgroundColor = kMainRedColor;
        self.v_AnswerTitleCell.lb_Title.text = @"정답이 아닙니다";
    }
    
    return YES;
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
                        btn_Sub.backgroundColor = [UIColor whiteColor];
                    }
                }
            }
            
            btn.selected = YES;
            btn.backgroundColor = [UIColor yellowColor];
            //correctAnswer
            self.v_AnswerTitleCell.lb_Title.text = @"답이라고 생각하시면 한 번 더 눌러주세요";
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
            NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"correctAnswer"]];
            if( [str_Correct isEqualToString:btn.titleLabel.text] )
            {
                //            self.v_Answer.lb_Title.backgroundColor = kMainRedColor;
                self.v_AnswerTitleCell.lb_Title.textColor = [UIColor blackColor];
                self.v_AnswerTitleCell.lb_Title.text = @"정답입니다";
            }
            else
            {
                self.v_AnswerTitleCell.lb_Title.backgroundColor = kMainRedColor;
                self.v_AnswerTitleCell.lb_Title.textColor = [UIColor whiteColor];
                self.v_AnswerTitleCell.lb_Title.text = [NSString stringWithFormat:@"%@번이 정답입니다", str_Correct];
            }
            
            //모든 버튼을 흰색으로 바꾼다
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        btn_Sub.backgroundColor = [UIColor whiteColor];
                    }
                }
            }
            
            
            //내가 선택한 버튼을 빨간색으로 바꾼다
            UIButton *btn_MyCorrect = [self.v_Answer6Cell.v_ButtonContainer viewWithTag:[btn.titleLabel.text integerValue]];
            btn_MyCorrect.backgroundColor = kMainRedColor;
            
            
            //정답 버튼을 파란색으로 바꾼다
            UIButton *btn_Correct = [self.v_Answer6Cell.v_ButtonContainer viewWithTag:[str_Correct integerValue]];
            btn_Correct.backgroundColor = [UIColor colorWithHexString:@"4285F4"];
            
            
            
            
            NSInteger nDiscriptionCnt = [[dic objectForKey_YM:@"explainCount"] integerValue];
//            if( nDiscriptionCnt > 0 )
            if( 1 )
            {
                //해설이 있다면 문제 풀이가 있다면 문제풀이 쇼
                nCellCount = 4;
            }
            
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                self.str_TesterId, @"testerId",   //답안지 ID
                                                [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]], @"questionId",   //문제 ID
                                                btn.titleLabel.text, @"userAnswer", //사용자가 입력한 답
                                                [NSString stringWithFormat:@"%ld", nTime * 1000], @"examLapTime",  //경과시간
                                                @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                                [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                                [NSString stringWithFormat:@"%ld", nQuestionCount], @"totalQuestionCount", //전체문제수
                                                @"on", @"setMode",
                                                nil];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                                param:dicM_Params
                                           withMethod:@"POST"
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [MBProgressHUD hide];
                                                
                                                if( resulte )
                                                {
                                                    [self updateList];
                                                    
                                                    NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
//                                                    if( nDiscriptionCnt > 0 )
                                                    if( 1 )
                                                    {
                                                        self.v_Discription.hidden = NO;
                                                        self.lc_AnswerBottom.constant = 70;
                                                    }
                                                }
                                            }];
        }
    }
    else
    {
        if( [btn.backgroundColor isEqual:[UIColor colorWithHexString:@"4285F4"]] )
        {
            //두번 입력한걸 또 눌렀을때, 이땐 취소
            btn.selected = NO;
            btn.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            if( btn.selected == NO )
            {
                //첫번째 입력
                btn.selected = YES;
                btn.backgroundColor = [UIColor yellowColor];
                
            }
            else
            {
                //두번째 입력
                btn.backgroundColor = [UIColor colorWithHexString:@"4285F4"];
                
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
                    if( [btn_Sub.backgroundColor isEqual:[UIColor colorWithHexString:@"4285F4"]] )
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
            NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"correctAnswer"]];
            NSLog(@"%@", str_Correct);
            
            
            
            //먼저 모두 흰색으로 바꾸고
            for( id subView in self.v_Answer6Cell.v_ButtonContainer.subviews )
            {
                if( [subView isKindOfClass:[UIButton class]] )
                {
                    UIButton *btn_Sub = (UIButton *)subView;
                    if( btn_Sub.tag > 0 )
                    {
                        btn_Sub.backgroundColor = [UIColor whiteColor];
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
                                btn_Sub.backgroundColor = [UIColor colorWithHexString:@"4285F4"];
                            }
                        }
                    }
                }
            }
            
            
            if( [str_Correct isEqualToString:strM_MyCorrect] )
            {
                //정답
                self.v_AnswerTitleCell.lb_Title.textColor = [UIColor blackColor];
                self.v_AnswerTitleCell.lb_Title.text = @"정답입니다";
                
            }
            else
            {
                //오답
                self.v_AnswerTitleCell.lb_Title.backgroundColor = kMainRedColor;
                self.v_AnswerTitleCell.lb_Title.textColor = [UIColor whiteColor];
                self.v_AnswerTitleCell.lb_Title.text = @"정답이 아닙니다";
                
            }
            
            NSInteger nDiscriptionCnt = [[dic objectForKey_YM:@"explainCount"] integerValue];
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
                                                self.str_TesterId, @"testerId",   //답안지 ID
                                                [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]], @"questionId",   //문제 ID
                                                strM_MyCorrect, @"userAnswer", //사용자가 입력한 답
                                                [NSString stringWithFormat:@"%ld", nTime * 1000], @"examLapTime",  //경과시간
                                                @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                                [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                                [NSString stringWithFormat:@"%ld", nQuestionCount], @"totalQuestionCount", //전체문제수
                                                @"on", @"setMode",
                                                nil];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                                param:dicM_Params
                                           withMethod:@"POST"
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [MBProgressHUD hide];
                                                
                                                if( resulte )
                                                {
                                                    [self updateList];
                                                    
                                                    NSInteger nDiscriptionCnt = [[dic objectForKey:@"explainCount"] integerValue];
//                                                    if( nDiscriptionCnt > 0 )
                                                    if( 1 )
                                                    {
                                                        self.v_Discription.hidden = NO;
                                                        self.lc_AnswerBottom.constant = 70;
                                                    }
                                                }
                                            }];
        }
        
    }
}

- (void)onDiscription:(UIButton *)btn
{
    if( isFinish == NO )
    {
        ALERT(nil, @"문제를 먼저 풀어주세요", nil, @"확인", nil);
        return;
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:self.str_Idx forKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *dic = [self.arM_List firstObject];
    QuestionDiscriptionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionDiscriptionViewController"];
    vc.ar_Info = [dic objectForKey_YM:@"examExplainInfos"];
    vc.str_ExamId = self.str_Idx;
    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];

//    vc.str_ImagePreFix = self.str_ImagePreFix;
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - IBAction
- (IBAction)goMenu:(id)sender
{
    UIAlertView *alert = CREATE_ALERT(nil, @"문제풀기 화면으로 이동하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if( buttonIndex == 0 )
        {
            //TODO: 문제풀기 화면으로 이동
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSDictionary *dic = [self.arM_List firstObject];
            QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examId"] integerValue]];
            vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examNo"] integerValue]];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

//- (void)onInfo:(UIButton *)btn
//{
//    NSDictionary *dic = self.arM_List[btn.tag];
//    
//    NSInteger nExamNo = [[dic objectForKey:@"examNo"] integerValue];
//    
//    SideMenuViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
//    vc.str_TesterId = self.str_TesterId;
//    vc.str_Idx = self.str_Idx;
//    vc.str_StartNo = [NSString stringWithFormat:@"%ld", nExamNo];
//    [self presentViewController:vc animated:NO completion:^{
//        
//    }];
//}

- (void)onInfo:(UIButton *)btn
{
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.tbv_List];
    
    NSDictionary *dic = [self.arM_List firstObject];
    
    NSMutableString *strM_Msg = [NSMutableString string];
    
    //과목
    NSString *str_SubjectName = [NSString stringWithFormat:@"과목 : %@", [dic objectForKey_YM:@"subjectName"]];
    [strM_Msg appendString:str_SubjectName];
    
    //정답율
    NSInteger nUserCorrectAnswerCnt = [[dic objectForKey_YM:@"userCorrectAnswerCount"] integerValue];
    NSInteger nTotalAnswerCnt = [[dic objectForKey_YM:@"totalAnswerCount"] integerValue];
    
    CGFloat fVal = (CGFloat)nUserCorrectAnswerCnt / (CGFloat)nTotalAnswerCnt;
    if( isnan(fVal) )
    {
        fVal = .0f;
    }
    NSInteger nPer = fVal * 100;
    NSString *str_CorrectAnswer = [NSString stringWithFormat:@"정답율 : %ld%%", nPer];
    [strM_Msg appendString:@"\n"];
    [strM_Msg appendString:str_CorrectAnswer];
    
    //이 문제를 푼 사람
    NSString *str_TotalAnswerCnt = [NSString stringWithFormat:@"이 문제를 푼 사람 : %ld명", nTotalAnswerCnt];
    [strM_Msg appendString:@"\n"];
    [strM_Msg appendString:str_TotalAnswerCnt];
    
    //이 문제를 맞힌 사람
    NSString *str_UserCorrentAnswerCnt = [NSString stringWithFormat:@"이 문제를 맞힌 사람 : %ld명", nUserCorrectAnswerCnt];
    [strM_Msg appendString:@"\n"];
    [strM_Msg appendString:str_UserCorrentAnswerCnt];
    
    
    self.popTip.popoverColor = kMainColor;
    //    static int direction = 0;
    [self.popTip showText:strM_Msg direction:AMPopTipDirectionDown maxWidth:200 inView:self.tbv_List fromFrame:CGRectMake(buttonPosition.x, buttonPosition.y, btn.frame.size.width, btn.frame.size.height) duration:0];
    //    direction = (direction + 1) % 4;
    
}

@end
