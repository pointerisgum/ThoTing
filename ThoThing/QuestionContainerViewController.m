//
//  QuestionContainerViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 28..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionContainerViewController.h"
#import "PauseViewController.h"

@interface QuestionContainerViewController ()
@property (nonatomic, strong) NSTimer *tm_Time;
@property (nonatomic, strong) QuestionListSwipeViewController *vc;
@end

@implementation QuestionContainerViewController


- (void)updateNaviBar:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
//    [self.v_Title.btn_Back setTitle:[dic objectForKey:@"title"] forState:UIControlStateNormal];
//    self.v_Title.lb_Count.text = [dic objectForKey:@"count"];
    self.v_Title.lb_Title.text = [dic objectForKey_YM:@"title"];
    self.v_Title.lb_CurrentCount.text = [dic objectForKey_YM:@"currentCount"];
    self.v_Title.lb_TotalCount.text = [dic objectForKey_YM:@"totlaCount"];
}

- (void)updateNaviTimer:(NSNotification *)noti
{
    if( self.tm_Time == nil )
    {
        NSNumber *num = noti.object;
        self.nTime = [num integerValue];

        self.tm_Time = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onUpdateTime) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.tm_Time forMode:NSRunLoopCommonModes];  //메인스레드에 돌리면 터치를 잡고 있을때 어는 현상이 있어서 스레드 분기시킴
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNaviBar];

//    self.navigationController.navigationBarHidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNaviBar:) name:@"kUpdateNaviBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNaviTimer:) name:@"kUpdateNaviTimer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTimerToggle:) name:@"kPauseTimer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPopVc) name:@"popVc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowNormalQuestion:) name:@"showNormalQuestion" object:nil];

    [self showQuesionVc:nil];

//    QuestionListSwipeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionListSwipeViewController"];
//    vc.str_Idx = self.str_Idx;
//    vc.str_StartIdx = @"1";
//
//    
////    CATransition* transition = [CATransition animation];
////    transition.duration = 0.5;
////    //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
////    transition.type = kCATransitionMoveIn;
////    //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
////    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
////    //    [self.navigationController.view.layer addAnimation:transition forKey:nil];
////    [self.view.layer addAnimation:transition forKey:nil];
//    
//    [self addChildViewController:vc];
//    //    [self.view addSubview:viewController.view];
//    [self addConstraintsForViewController:vc];
    
    
    
    //[self.navigationController pushViewController:vc animated:YES];
    
}

- (void)viewDidLayoutSubviews
{
//    self.v_Title.backgroundColor = [UIColor redColor];
    
//    CGRect frame = self.v_Title.frame;
//    frame.size.width = self.view.bounds.size.width - 30;
//    self.v_Title.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [MBProgressHUD hide];
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWrongCheckNoti) name:@"WrongCheckNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWrongNonCheckNoti) name:@"WrongNonCheckNoti" object:nil];
}

//- (void)removeChildVc
//{
//    NSMutableArray *arM_Tmp = [self.childViewControllers mutableCopy];
//    for( NSInteger i = 1; i < arM_Tmp.count; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }
//}

- (void)onShowNormalQuestion:(NSNotification *)noti
{
//    [self.vc removeFromParentViewController];
//    self.vc = nil;
    
    [MBProgressHUD show];
    
//    NSMutableArray *arM_ViewControllers = [NSMutableArray array];
    
//    NSMutableArray *arM_Tmp = [self.childViewControllers mutableCopy];
//    for( NSInteger i = 1; i < arM_Tmp.count; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }

//    if( self.vc )
//    {
//        [self.vc removeFromParentViewController];
//        self.vc = nil;
//    }
    
    NSDictionary *obj = noti.object;
    NSDictionary *resulte = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"resulte"]];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithDictionary:[obj objectForKey:@"params"]];

    self.vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionListSwipeViewController"];
    self.vc.vc_Parent = self;
    self.vc.str_Idx = self.str_Idx;
    self.vc.str_StartIdx = [dicM_Params objectForKey_YM:@"examNo"];
    self.vc.str_SortType = self.str_SortType;
    self.vc.isNew = self.isNew;
    self.vc.str_LowPer = self.str_LowPer;
    self.vc.isPdf = self.isPdf;
    self.vc.nStartPdfPage = self.nStartPdfPage == 0 ? 1 : self.nStartPdfPage;
    self.vc.str_ChannelId = self.str_ChannelId;
    self.vc.str_SubjectName = self.str_SubjectName;
    self.vc.isWrong = self.isWrong;
    self.vc.isStar = self.isStar;
    self.vc.btn_Check = self.v_Title.btn_WrongTitle;
    self.vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
    self.vc.str_PdfPage = self.str_PdfPage;
    self.vc.str_PdfNo = self.str_PdfNo;

    //    vc.str_Idx = @"494";
    //    vc.str_StartIdx = @"4";
    
    
    //    CATransition* transition = [CATransition animation];
    //    transition.duration = 0.5;
    //    //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    transition.type = kCATransitionMoveIn;
    //    //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    //    //    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    //    [self.view.layer addAnimation:transition forKey:nil];
    
    [self addChildViewController:self.vc];
    
    //    [self.view addSubview:viewController.view];
    [self addConstraintsForViewController:self.vc];

    
    
//    NSDictionary *obj = noti.object;
//    NSDictionary *resulte = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"resulte"]];
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithDictionary:[obj objectForKey:@"params"]];
//    self.str_StartIdx = [obj objectForKey:@"startIdx"];
//    [self showWrongViewing:resulte withParam:dicM_Params];
    
//    NSMutableArray *arM_Tmp = [self.childViewControllers mutableCopy];
//    for( NSInteger i = 0; i < arM_Tmp.count - 1; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }

    NSLog(@"종료");
}

- (void)onPopVc
{
    [self leftBackSideMenuButtonPressed:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];


    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"WrongCheckNoti"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"WrongNonCheckNoti"
                                                  object:nil];

//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"kUpdateNaviBar"
//                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"kUpdateNaviTimer"
                                                  object:nil];

//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"kPauseTimer"
//                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"popVc"
                                                  object:nil];


    self.navigationController.navigationBarHidden = NO;
    
    UIImageView *iv = (UIImageView *)[self.navigationController.view viewWithTag:999];
    [iv removeFromSuperview];

    [MBProgressHUD hide];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *str_CurrentQuestionIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentQuestionIdx"];
    if( [str_CurrentQuestionIdx integerValue] > 0 )
    {
        return;
    }

//    [self showQuesionVc];

}

- (void)showQuesionVc:(QuestionListSwipeViewController *)vc_Tmp
{
    NSMutableArray *arM_Tmp = [self.childViewControllers mutableCopy];
    for( NSInteger i = 1; i < arM_Tmp.count; i++ )
    {
        id subViewController = [arM_Tmp objectAtIndex:i];
        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
        {
            UIViewController *vc_Tmp = (UIViewController *)subViewController;
            [vc_Tmp willMoveToParentViewController:nil];
            [vc_Tmp.view removeFromSuperview];
            [vc_Tmp removeFromParentViewController];
        }
    }

//    if( self.vc )
//    {
//        [self.vc removeFromParentViewController];
//        self.vc = nil;
//    }

    if( vc_Tmp == nil )
    {
        self.vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionListSwipeViewController"];
        self.vc.vc_Parent = self;
        self.vc.str_Idx = self.str_Idx;
        self.vc.str_StartIdx = self.str_StartIdx;
        self.vc.str_SortType = self.str_SortType;
        self.vc.isNew = self.isNew;
        self.vc.str_LowPer = self.str_LowPer;
        self.vc.isPdf = self.isPdf;
        self.vc.nStartPdfPage = self.nStartPdfPage == 0 ? 1 : self.nStartPdfPage;
        self.vc.str_ChannelId = self.str_ChannelId;
        self.vc.str_SubjectName = self.str_SubjectName;
        self.vc.isWrong = self.isWrong;
        self.vc.isStar = self.isStar;
        self.vc.btn_Check = self.v_Title.btn_WrongTitle;
        self.vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
        self.vc.str_PdfPage = self.str_PdfPage;
        self.vc.str_PdfNo = self.str_PdfNo;

    }
    else
    {
        self.vc = vc_Tmp;
    }
    
    
    //    vc.str_Idx = @"494";
    //    vc.str_StartIdx = @"4";
    
    
    //    CATransition* transition = [CATransition animation];
    //    transition.duration = 0.5;
    //    //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    transition.type = kCATransitionMoveIn;
    //    //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    //    //    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    //    [self.view.layer addAnimation:transition forKey:nil];
    
    [self addChildViewController:self.vc];
    
    //    [self.view addSubview:viewController.view];
    [self addConstraintsForViewController:self.vc];
    
//    NSMutableArray *arM_Tmp = [self.childViewControllers mutableCopy];
//    for( NSInteger i = 0; i < arM_Tmp.count - 1; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }

    //    [self.view setNeedsLayout];
    
//    NSMutableArray *arM_Tmp = [self.childViewControllers mutableCopy];
//    for( NSInteger i = 1; i < arM_Tmp.count - 1; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            if( subViewController != self.vc )
//            {
//                UIViewController *vc_Tmp = (UIViewController *)subViewController;
//                [vc_Tmp removeFromParentViewController];
//            }
//        }
//    }
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

- (void)onSideMenu:(UIButton *)btn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSideMenu" object:nil];
}

- (void)onTimePress:(UIButton *)btn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPause" object:nil];
}

- (void)onCheckSelected:(UIButton *)btn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wrongCheckSelected" object:nil];
}

- (void)initNaviBar
{
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"F8F8F8"]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSArray *topLevelObjects = nil;
    if( self.isWrong )
    {
        topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionWrongTitleView" owner:self options:nil];
//        [self.v_Title.btn_Time addTarget:self action:@selector(onTimePress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if( self.isStar )
    {
        topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionStarTitleView" owner:self options:nil];
//        [self.v_Title.btn_Time addTarget:self action:@selector(onTimePress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionListTitleView" owner:self options:nil];
//        [self.v_Title.btn_Time addTarget:self action:@selector(onTimePress:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.v_Title = [topLevelObjects objectAtIndex:0];
    [self.v_Title.btn_Back addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.v_Title.btn_Time addTarget:self action:@selector(onTimePress:) forControlEvents:UIControlEventTouchUpInside];
//    [self.v_Title.btn_Time addTarget:self action:@selector(onTimerToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.v_Title.btn_SideMenu addTarget:self action:@selector(onSideMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.v_Title.btn_Check addTarget:self action:@selector(onCheckSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.v_Title.btn_WrongTitle addTarget:self action:@selector(onCheckSelected:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.v_Title];
    
    CGRect frame = leftItem.customView.frame;
    frame.size.width = self.view.bounds.size.width - 30;
    leftItem.customView.frame = frame;
    
//    [leftItem.customView setNeedsLayout];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    //오른쪽 버튼들 (타이머, 카운트)
//    self.v_Title = [topLevelObjects objectAtIndex:0];
//    self.navigationItem.titleView = self.v_Title;
    
//    [self.navigationController.view addSubview:self.v_Title];
    
//    self.navigationController.navigationBar = self.v_Title;
//    [self.v_Title.btn_Back addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.v_Title];
//
//    [self.v_Title.btn_Time addTarget:self action:@selector(onTimerToggle:) forControlEvents:UIControlEventTouchUpInside];
    
//    CGRect frame = self.v_Title.frame;
//    frame.size.width = self.view.bounds.size.width - 30;
//    self.v_Title.frame = frame;
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QuesionBack" object:nil];

    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)onUpdateTime
{
    self.nTime++;
    
    NSInteger nSecond = self.nTime % 60;
    NSInteger nMinute = self.nTime / 60;
//    [self.v_Title.btn_Time setTitle:[NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond] forState:UIControlStateNormal];
    [self.v_Title.btn_Time setTitle:[NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond] forState:UIControlStateNormal];
//    self.v_Title.lb_Timer.text = [NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTimer" object:[NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond]];
//    NSLog(@"%@", self.v_Title.lb_Timer.text);
}

- (void)onTimerToggle:(UIButton *)btn
{
    if( self.tm_Time )
    {
        [self.tm_Time invalidate];
        self.tm_Time = nil;

//        UIImageView *iv_Tim = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
//        iv_Tim.backgroundColor = [UIColor blackColor];
//        iv_Tim.alpha = 0.7f;
//        iv_Tim.userInteractionEnabled = YES;
//        iv_Tim.tag = 999;
//        [self.navigationController.view addSubview:iv_Tim];
//        
//        [self.v_Title.btn_Time setImage:BundleImage(@"pause.png") forState:UIControlStateNormal];
    }
    else
    {
        self.tm_Time = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onUpdateTime) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.tm_Time forMode:NSRunLoopCommonModes];  //메인스레드에 돌리면 터치를 잡고 있을때 어는 현상이 있어서 스레드 분기시킴
        
//        UIImageView *iv = (UIImageView *)[self.navigationController.view viewWithTag:999];
//        [iv removeFromSuperview];
//        
//        [self.v_Title.btn_Time setImage:BundleImage(@"clock.png") forState:UIControlStateNormal];
    }
}

- (void)onWrongCheckNoti
{
    self.v_Title.btn_WrongTitle.selected = !self.v_Title.btn_WrongTitle.selected;
}

- (void)onWrongNonCheckNoti
{
    self.v_Title.btn_WrongTitle.selected = NO;
}

//- (IBAction)goTime:(id)sender
//{
//    PauseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PauseViewController"];
//    [self presentViewController:vc animated:YES completion:nil];
//}

@end
